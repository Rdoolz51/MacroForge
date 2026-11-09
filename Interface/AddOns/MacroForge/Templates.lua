local _,MF=...
-- Original templates, not copied guide content. See docs/API-NOTES.md.
MF.templates={
    plain={label="Standard cast",build=function(s) return "#showtooltip "..s.."\n/cast "..s end},
    mouseover={label="Mouseover (friendly)",build=function(s) return "#showtooltip "..s.."\n/cast [@mouseover,help,nodead] [] "..s end},
    mouseover_hostile={label="Mouseover (hostile)",build=function(s) return "#showtooltip "..s.."\n/cast [@mouseover,harm,nodead] [] "..s end},
    focus={label="Focus (hostile)",build=function(s) return "#showtooltip "..s.."\n/cast [@focus,harm,nodead] [] "..s end},
    modifier={label="Alt: self cast",build=function(s) return "#showtooltip "..s.."\n/cast [mod:alt,@player] [] "..s end},
    stopcasting={label="Stopcasting + cast",build=function(s) return "#showtooltip "..s.."\n/stopcasting\n/cast "..s end},
}
MF.templateOrder={"plain","mouseover","mouseover_hostile","focus","modifier","stopcasting"}
MF.classTemplates={WARRIOR={"focus","stopcasting"},ROGUE={"focus","stopcasting"},HUNTER={"focus","mouseover"},MAGE={"focus","stopcasting","modifier"},WARLOCK={"focus","stopcasting"},PRIEST={"mouseover","modifier","focus"},PALADIN={"mouseover","modifier","stopcasting"},SHAMAN={"mouseover","modifier","focus"},DRUID={"mouseover","modifier","focus"}}
for _,keys in pairs(MF.classTemplates) do keys[#keys+1]="mouseover_hostile" end
