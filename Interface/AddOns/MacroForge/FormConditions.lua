local _,MF=...
function MF:FormOptions()
    local list={{id=0,name="Caster (no form)"}}
    for _,f in ipairs(self:Forms()) do list[#list+1]=f end
    return list
end
function MF:SpellFormRule()
    if type(self.db.preferences.formRules)~="table" then self.db.preferences.formRules={} end
    local _,class=UnitClass("player")
    local key=tostring(class)..":"..tostring(self.selected and self.selected.id or "none")
    local rules=self.db.preferences.formRules
    if type(rules[key])~="table" then rules[key]={enabled=false,kind=class=="WARRIOR" and "require" or "in",spellID=0} end
    return rules[key]
end
function MF:FormClause(rule,draft)
    if not rule or not rule.enabled then return "" end
    if rule.kind=="require" then return "" end
    local _,class=UnitClass("player")
    if class~="DRUID" then return nil,"Form conditions are available only to Druids." end
    if rule.kind~="in" and rule.kind~="not" then return nil,"Choose in form or not in form." end
    if rule.spellID==0 then return rule.kind=="in" and "noform" or "form" end
    for _,form in ipairs(self:Forms()) do
        if form.id==rule.spellID then return (rule.kind=="in" and "form:" or "noform:")..form.index end
    end
    return nil,"Conditional form is no longer available. Choose a current form."
end
function MF:ApplyFormCondition(body,rule,draft)
    local clause,err=self:FormClause(rule,draft)
    if not clause then return nil,err end
    if clause=="" then return body end
    local lines={}
    for line in string.gmatch(body,"[^\n]+") do
        if string.sub(line,1,6)=="/cast " then
            local args=string.sub(line,7)
            if string.sub(args,1,1)=="[" then
                args=string.gsub(args,"%[([^%]]*)%]",function(options) return "["..clause..(options~="" and ","..options or "").."]" end)
            else args="["..clause.."] "..args end
            line="/cast "..args
        elseif line=="/stopcasting" then line="/stopcasting ["..clause.."]" end
        lines[#lines+1]=line
    end
    local result=table.concat(lines,"\n")
    local _,_,limit=self:Limits()
    if not draft and #result>limit then return nil,"Conditioned macro exceeds the client body-byte limit of "..limit.."." end
    return result
end
