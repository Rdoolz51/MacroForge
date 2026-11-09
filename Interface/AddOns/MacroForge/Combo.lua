local _,MF=...
MF.comboKeys={"normal","alt","ctrl","shift"}
MF.comboConditions={normal="nomod",alt="mod:alt,nomod:ctrl,nomod:shift",ctrl="mod:ctrl,nomod:shift",shift="mod:shift"}
MF.comboTargets={"target","focus","mouseover","mouseover_hostile","player"}
function MF:Forms()
    local result={}
    local _,class=UnitClass("player")
    if class~="DRUID" then return result end
    for index=1,self:Call(GetNumShapeshiftForms) or 0 do
        local icon,_,_,id=self:Call(GetShapeshiftFormInfo,index)
        local name=id and self:SpellInfo(id)
        if name then result[#result+1]={id=id,name=name,index=index,icon=icon} end
    end
    return result
end
function MF:ComboRanks(row)
    local choices={{mode="max",label="Max (rank-free)"}}
    local spell
    for _,s in ipairs(self.catalog) do if s.id==row.spellID then spell=s end end
    if not spell then return choices end
    for _,s in ipairs(self:Family(spell)) do
        if s.known and not s.passive and s.rank~="" then choices[#choices+1]={mode="rank",rankID=s.id,label=s.rank} end
    end
    return choices
end
function MF:ComboConfig()
    local _,class=UnitClass("player")
    local c=self.db.preferences.combo
    if type(c)~="table" or c.class~=class then
        c={class=class,normal={action="cast",spellID=self.selected and self.selected.id,target="target"},alt={action="none"},ctrl={action="none"},shift={action="none"}}
        self.db.preferences.combo=c
    end
    return c
end
function MF:ComboChoices(action)
    if action=="form" then return self:Forms() end
    local result,names={},{}
    for _,s in ipairs(self.catalog) do
        if s.known and not s.passive and not names[s.name] then result[#result+1]=s; names[s.name]=true end
    end
    return result
end
function MF:ComboPreset(kind)
    local c=self:ComboConfig()
    if kind=="focus" then
        if not self.selected then return false,"Select the normal spell first." end
        c.normal={action="cast",spellID=self.selected.id,target="target"}
        c.alt={action="cast",spellID=self.selected.id,target="focus"}
        c.ctrl={action="none"}; c.shift={action="none"}
    elseif kind=="druid" then
        if c.class~="DRUID" then return false,"The form preset requires a Druid." end
        local forms=self:Forms()
        local function find(ids)
            for _,id in ipairs(ids) do
                local localized=self:SpellInfo(id)
                for _,form in ipairs(forms) do if form.id==id or localized and form.name==localized then return form end end
            end
        end
        -- Candidate spell IDs are matched against the live form bar; indices are never hardcoded.
        local cat,bear,travel=find({768}),find({9634,5487}),find({783})
        if not cat or not bear or not travel then return false,"Learn Cat, Bear and Travel forms first; all three must be exposed by the live form API." end
        c.normal={action="form",spellID=cat.id,target="player"}
        c.ctrl={action="form",spellID=bear.id,target="player"}
        c.alt={action="form",spellID=travel.id,target="player"}
        c.shift={action="cancel"}
    else return false,"Unknown combo preset." end
    self.comboEnabled=true
    return true
end
function MF:ComboPreview(config,draft)
    local c=config or self:ComboConfig()
    local _,class=UnitClass("player")
    if c.class~=class then return nil,"Combo belongs to another class. Rebuild it for this character." end
    local casts,cancels={},{}
    for _,key in ipairs({"shift","ctrl","alt","normal"}) do
        local row=c[key] or {action="none"}
        local condition=self.comboConditions[key]
        if row.action~="none" then
            if row.formRule and row.formRule.enabled and row.formRule.kind=="require" and row.action~="cast" then return nil,key..": Requires form/stance applies to cast actions only." end
            local clause,err=self:FormClause(row.formRule,draft)
            if not clause then return nil,key..": "..err end
            if clause~="" then condition=condition..","..clause end
        end
        if (row.action=="form" or row.action=="cancel") and class~="DRUID" then return nil,"Form actions are available only to Druids." end
        if row.action=="cancel" then
            cancels[#cancels+1]="["..condition.."]"
        elseif row.action=="cast" or row.action=="form" then
            local name
            if row.action=="form" then
                local form
                for _,f in ipairs(self:Forms()) do if f.id==row.spellID then form=f end end
                if not form then return nil,key..": form unavailable in current form bar." end
                if row.formRule and row.formRule.enabled and row.formRule.kind=="in" and row.formRule.spellID==form.id then
                    return nil,key..": entering this form only when already in it conflicts with the no-recast guard."
                end
                condition=condition..",noform:"..form.index
                name="!"..form.name
            else
                local spell
                for _,s in ipairs(self.catalog) do if s.id==row.spellID then spell=s end end
                if not spell then return nil,key..": select a learned spell." end
                local cast,err=self:CastName(spell,row.mode or "max",row.rankID,draft)
                if not cast then return nil,key..": "..err end
                name=cast
                if row.noToggle then name="!"..name end
                if row.target=="mouseover_hostile" then condition=condition..",@mouseover,harm,nodead"
                elseif row.target=="focus" or row.target=="mouseover" then condition=condition..",@"..row.target..",exists,nodead"
                elseif row.target=="player" then condition=condition..",@player"
                elseif row.target~="target" and row.target~=nil then return nil,"Invalid combo target." end
            end
            local requiredID=row.requiredFormID
            if row.formRule and row.formRule.enabled and row.formRule.kind=="require" then requiredID=row.formRule.spellID end
            if row.action=="cast" and requiredID~=nil then
                local form,err=self:RequiredForm(requiredID,draft)
                if not form then return nil,key..": "..err end
                if row.formRule and row.formRule.enabled and row.formRule.kind~="require" then return nil,key..": use either Only when or Requires form/stance, not both." end
                casts[#casts+1]="["..condition..",noform:"..form.index.."] !"..form.name
                condition=condition..",form:"..form.index
            end
            casts[#casts+1]="["..condition.."] "..name
        elseif row.action~="none" then return nil,"Invalid combo action." end
    end
    if #casts==0 and #cancels==0 then return nil,"Assign at least one combo action." end
    local lines={"#showtooltip"}
    if #cancels>0 then lines[#lines+1]="/cancelform "..table.concat(cancels," ") end
    if #casts>0 then lines[#lines+1]="/cast "..table.concat(casts,"; ") end
    local body=table.concat(lines,"\n")
    local _,_,limit=self:Limits()
    if not draft and #body>limit then return nil,"Combo is "..#body.." bytes; client limit is "..limit..". Shorten it or split it into two macros." end
    return body
end
function MF:CurrentPreview(draft)
    if self.premadeSelection then return self:PremadePreview(self.premadeSelection,draft) end
    local rule=self:SpellFormRule()
    if self.equipmentOnly then return self:EquipmentPreview(draft) end
    if self.comboEnabled then return self:ComboPreview(nil,draft) end
    local body,err=self:Preview(self.selected,self.mode or "max",self.rankID,self.template or "plain",draft,rule.noToggle)
    if not body then return nil,err end
    body,err=self:ApplyFormCondition(body,rule,draft)
    if not body then return nil,err end
    local requiredID=rule.requiredFormID
    if rule.enabled and rule.kind=="require" then requiredID=rule.spellID end
    if requiredID==0 and rule.enabled and rule.kind=="require" then return nil,"Select a required form/stance." end
    return self:ApplyRequiredForm(body,requiredID,rule,draft)
end
