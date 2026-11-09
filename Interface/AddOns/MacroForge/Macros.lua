local _,MF=...
function MF:Inventory()
    local aLimit,cLimit=self:Limits()
    local account,character=self:Call(GetNumMacros)
    if not aLimit or not cLimit or not account or not character or not GetMacroInfo then return nil,"Macro APIs or runtime slot limits unavailable; creation disabled." end
    local list={}
    for i=1,aLimit+cLimit do
        local name,icon,body=self:Call(GetMacroInfo,i)
        if name then list[#list+1]={index=i,name=name,icon=icon,body=body,location=i>aLimit and "Character" or "General"} end
    end
    return list,nil,account,character,aLimit,cLimit
end
function MF:OwnedMacros()
    local list,err=self:Inventory()
    local result={}
    for _,item in ipairs(list or {}) do
        for _,r in pairs(self.db.owned) do
            if type(r)=="table" and item.name==r.name and item.body==r.body and item.location==r.location then result[#result+1]=item; break end
        end
    end
    return result,err
end
function MF:MacroNameError(name,list)
    local _,_,_,limit=self:Limits()
    if type(name)~="string" or not string.find(name,"%S") or string.find(name,"[%c]") then return "Enter a macro name without control characters." end
    if #name>limit then return "Macro name exceeds "..limit.." bytes. Enter a shorter name." end
    if not list then
        local err
        list,err=self:Inventory()
        if not list then return err end
    end
    for _,macro in ipairs(list) do
        if string.lower(macro.name)==string.lower(name) then
            return "Name '"..name.."' already exists in "..macro.location.." macros. Enter a unique name; the existing macro will not be overwritten."
        end
    end
    if GetMacroIndexByName and (self:Call(GetMacroIndexByName,name) or 0)>0 then return "Name already exists. Enter a unique name; no overwrite is allowed." end
    return nil
end
function MF:Generate()
    if self:Combat() then return false,"Creation disabled during combat lockdown." end
    local body,err=self:CurrentPreview()
    if not body then return false,err end
    local _,_,textLimit,nameLimit=self:Limits()
    local name=self.nameBox:GetText()
    if name=="" or string.match(name,"[%c]") then return false,"Enter a name without control characters." end
    if #name>nameLimit or #body>textLimit then return false,"Macro exceeds client byte limits (name "..nameLimit..", body "..textLimit..")." end
    local list,inventoryError,account,character,aLimit,cLimit=self:Inventory()
    if not list then return false,inventoryError end
    local nameError=self:MacroNameError(name,list)
    if nameError then return false,nameError end
    for _,item in ipairs(list) do
        if item.body==body then return false,"Identical macro exists: "..item.name.." ("..item.location..")." end
        if item.name==name then return false,"Name already in use. Choose another name; existing macro preserved." end
    end
    if GetMacroIndexByName and (self:Call(GetMacroIndexByName,name) or 0)>0 then return false,"Name already in use." end
    local perCharacter=character<cLimit
    if not perCharacter and account>=aLimit then return false,"All slots full. Use Open Macro Window to review them." end
    if not CreateMacro then return false,"CreateMacro API unavailable." end
    local macroSpell=self.selected
    if self.premadeSelection then macroSpell=self:PremadePrimary(self.premadeSelection) end
    local ok,index=pcall(CreateMacro,name,macroSpell and macroSpell.icon or 134400,body,perCharacter)
    if not ok or type(index)~="number" or index<=0 then return false,"Client rejected creation. No existing macro edited." end
    local actualName,_,actualBody=self:Call(GetMacroInfo,index)
    if actualName~=name or actualBody~=body then return false,"Creation result unverified. Inspect native macros before retrying." end
    local location=index>aLimit and "Character" or "General"
    self.db.owned[name]={name=name,body=body,location=location,spellID=macroSpell and macroSpell.id,premadeKey=self.premadeSelection and self.premadeSelection.key,version=self.version}
    self.dirty=true
    return true,"Created in "..location.." macros. Use Open Macro Window and drag its icon to an action bar."
end
