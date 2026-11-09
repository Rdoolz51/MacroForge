local _,MF=...
function MF:RequirementForms()
    local _,class=UnitClass("player")
    local result={}
    if class~="DRUID" and class~="WARRIOR" then return result end
    for i=1,self:Call(GetNumShapeshiftForms) or 0 do
        local icon,_,_,id=self:Call(GetShapeshiftFormInfo,i)
        local name=id and self:SpellInfo(id)
        if name then result[#result+1]={id=id,name=name,index=i,icon=icon} end
    end
    return result
end
function MF:RequiredForm(id,draft)
    local _,class=UnitClass("player")
    if class~="DRUID" and class~="WARRIOR" then return nil,"Form/stance requirements are available to Druids and Warriors." end
    for _,f in ipairs(self:RequirementForms()) do if f.id==id then return f end end
    return nil,"Required form/stance is unavailable. Choose one from the current form/stance bar."
end
function MF:RequirementNote(rule)
    if not rule or not rule.enabled or rule.kind~="require" then return nil end
    local _,class=UnitClass("player")
    local name=class=="WARRIOR" and "the selected stance" or "the selected form"
    for _,form in ipairs(self:RequirementForms()) do if form.id==rule.spellID then name=form.name end end
    return "Switches to "..name.." before the ability. If switching uses a global cooldown, press again after it ends."
end
function MF:ApplyRequiredForm(body,id,rule,draft)
    if not id or id==0 then return body end
    if rule and rule.enabled and rule.kind~="require" then return nil,"Use either Only when or Requires form/stance, not both." end
    local form,err=self:RequiredForm(id,draft)
    if not form then return nil,err end
    local lines={}
    for line in string.gmatch(body,"[^\n]+") do
        if string.sub(line,1,6)=="/cast " then
            local args=string.sub(line,7)
            if string.sub(args,1,1)=="[" then
                args=string.gsub(args,"%[([^%]]*)%]",function(options) return "[form:"..form.index..(options~="" and ","..options or "").."]" end)
            else args="[form:"..form.index.."] "..args end
            line="/cast [noform:"..form.index.."] !"..form.name.."; "..args
        elseif line=="/stopcasting" then line="/stopcasting [form:"..form.index.."]" end
        lines[#lines+1]=line
    end
    local result=table.concat(lines,"\n")
    local _,_,limit=self:Limits()
    if not draft and #result>limit then return nil,"Macro exceeds "..limit.." bytes. Shorten the template or split the macro." end
    return result
end
function MF:EquipmentItems(kind)
    local items,seen={},{}
    local function add(id)
        if not id or seen[id] then return end
        seen[id]=true
        local _,_,_,loc=self:Call(C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant,id)
        if kind=="shield" and loc~="INVTYPE_SHIELD" then return end
        if kind=="weapon" and loc~="INVTYPE_WEAPON" and loc~="INVTYPE_WEAPONMAINHAND" then return end
        local name=self:Call(C_Item and C_Item.GetItemInfo or GetItemInfo,id)
        items[#items+1]={id=id,name=(name or "Item").." (#"..id..")"}
    end
    add(self:Call(GetInventoryItemID,"player",16)); add(self:Call(GetInventoryItemID,"player",17))
    for bag=0,NUM_BAG_SLOTS or 0 do
        for slot=1,self:Call(C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots,bag) or 0 do
            add(self:Call(C_Container and C_Container.GetContainerItemID or GetContainerItemID,bag,slot))
        end
    end
    table.sort(items,function(a,b) return a.name<b.name end)
    return items
end
function MF:EquipmentConfig()
    if type(self.db.preferences.equipment)~="table" then self.db.preferences.equipment={} end
    return self.db.preferences.equipment
end
function MF:EquipmentPreview(draft)
    local _,class=UnitClass("player")
    if class~="WARRIOR" then return nil,"The 1H + shield equipment builder is for Warriors." end
    local c=self:EquipmentConfig()
    local weapon,shield
    for _,item in ipairs(self:EquipmentItems("weapon")) do if item.id==c.weaponID then weapon=item end end
    for _,item in ipairs(self:EquipmentItems("shield")) do if item.id==c.shieldID then shield=item end end
    if not weapon or not shield then return nil,"Select a carried/equipped one-handed main-hand weapon and shield. Refresh if item data is loading." end
    return "#showtooltip\n/equipslot 16 item:"..weapon.id.."\n/equipslot 17 item:"..shield.id
end
