local _,MF=...
function MF:Family(spell)
    local ranks={}
    for _,item in ipairs(self.catalog) do if item.name==spell.name then ranks[#ranks+1]=item end end
    return ranks
end
function MF:CastName(spell,mode,rankID,draft)
    if not spell then return nil,"Select an ability." end
    local current
    for _,item in ipairs(self.catalog) do if item.id==spell.id then current=item end end
    if not current then return nil,"Ability no longer present. Refresh and select again." end
    spell=current
    local cast=spell.name
    if mode~="max" then
        local selected
        for _,item in ipairs(self:Family(spell)) do
            if (mode=="one" and item.rankNum==1) or (mode=="rank" and item.id==rankID) then selected=item end
        end
        if not selected or not selected.known then return nil,"That rank is unavailable or not learned." end
        if selected.rank=="" then return nil,"Client did not expose explicit rank text." end
        cast=selected.name.."("..selected.rank..")"
    else
        local known=false
        for _,item in ipairs(self:Family(spell)) do if item.known and not item.passive then known=true end end
        if not known then return nil,"Ability is unlearned or passive." end
    end
    if spell.passive then return nil,"Passive abilities cannot be cast." end
    return cast
end
function MF:Preview(spell,mode,rankID,template,draft,noToggle)
    local cast,err=self:CastName(spell,mode,rankID,draft)
    if not cast then return nil,err end
    local tooltip=cast
    if noToggle then cast="!"..cast end
    local body="#showtooltip "..tooltip.."\n/cast "..cast
    if template and template~="plain" then
        local t=self.templates[template]
        if not t then return nil,"Unknown template." end
        body=t.build(cast)
    end
    return (string.gsub(body,"^#showtooltip !","#showtooltip "))
end
