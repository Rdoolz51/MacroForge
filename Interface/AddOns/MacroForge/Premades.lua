local _,MF=...
-- Original, compact implementations informed by the linked authors' guides.
-- Candidate spell IDs resolve to client-localized names. No scraped guide text.
MF.premades={}
local sourceClass={DRUID="Druid",WARRIOR="Warrior",MAGE="Mage",PRIEST="Priest",PALADIN="Paladin",HUNTER="Hunter",ROGUE="Rogue",WARLOCK="Warlock",SHAMAN="Shaman"}
local function add(class,key,label,spells,style,note,forms)
    MF.premades[#MF.premades+1]={class=class,key=key,label=label,spells=spells,style=style,note=note,forms=forms,
        source="https://foreverdb.net/class/"..sourceClass[class].."/macros",reviewed="2026-11-09",client="Forever 1.60.1 / 70862; not tested in game"}
end
-- Eight ready-configured spell/utility macros per class.
add("DRUID","d_ht","Mouseover Healing Touch",{5185},"help","Friendly mouseover, friendly target, then self.")
add("DRUID","d_rej","Mouseover Rejuvenation",{774},"help","Heal a friendly unit without changing your hostile target.")
add("DRUID","d_curse","Mouseover Remove Curse",{2782},"help","Friendly mouseover, friendly target, then self.")
add("DRUID","d_rebirth","Mouseover Rebirth",{20484},"deadfriend","Point at a dead ally; reagents and combat rules still apply.")
add("DRUID","d_roots","Mouseover Entangling Roots",{339},"harm","Living hostile mouseover, otherwise your target.")
add("DRUID","d_bash","Bear-form Focus Bash",{5211},"focus","Switches to Bear before attempting the focus stun. May need two presses.",{9634,5487})
add("DRUID","d_prowl","Cat-form Prowl Protection",{5215},"toggle","Switches to Cat before !Prowl. Combat still prevents stealth.",{768})
add("DRUID","d_mark","Mouseover Mark of the Wild",{1126},"help","Buff a friendly mouseover, target, or yourself.")
add("WARRIOR","w_charge","Battle-stance Charge",{100},"plain","Switches to Battle Stance before Charge; combat restrictions remain.",{2457})
add("WARRIOR","w_overpower","Battle-stance Overpower",{7384},"plain","Switches stance first. Requires the normal Overpower trigger.",{2457})
add("WARRIOR","w_taunt","Defensive Mouseover Taunt",{355},"harm","Switches to Defensive; taunts hostile mouseover or current target.",{71})
add("WARRIOR","w_pummel","Berserker Focus Pummel",{6552},"focus","Requires a living hostile focus and Berserker Stance.",{2458})
add("WARRIOR","w_bash","Defensive Focus Shield Bash",{72},"focus","Requires a shield and suitable weapon; does not equip them.",{71})
add("WARRIOR","w_sunder","Sunder + Auto Attack",{7386},"attack","Starts melee attack and attempts Sunder Armor on your target.")
add("WARRIOR","w_hamstring","Hamstring + Auto Attack",{1715},"attack","Starts melee attack; normal stance and range rules still apply.")
add("WARRIOR","w_block","Defensive Shield Block",{2565},"plain","Switches to Defensive before Shield Block. Requires a shield.",{71})
add("MAGE","m_poly","Focus Polymorph",{118},"focus","Crowd-control your living hostile focus without changing target.")
add("MAGE","m_cs","Stopcasting Focus Counterspell",{2139},"stopfocus","Interrupts your current cast, then attempts Counterspell on focus.")
add("MAGE","m_blink","Stopcasting Blink",{1953},"stop","Ends your current cast before attempting Blink.")
add("MAGE","m_nova","Stopcasting Frost Nova",{122},"stop","Ends your current cast before attempting Frost Nova.")
add("MAGE","m_fs","Cursor Flamestrike",{2120},"cursor","Places the targeting location at your cursor. Verify cursor support.")
add("MAGE","m_blizzard","Cursor Blizzard",{10},"cursor","Uses your cursor location; channel and targeting rules still apply.")
add("MAGE","m_int","Mouseover Arcane Intellect",{1459},"help","Friendly mouseover, friendly target, then self.")
add("MAGE","m_curse","Mouseover Remove Lesser Curse",{475},"help","Cleanse a friendly unit without dropping your current target.")
add("PRIEST","p_lh","Mouseover Lesser Heal",{2050},"help","Friendly mouseover, friendly target, then self.")
add("PRIEST","p_fh","Mouseover Flash Heal",{2061},"help","Fast heal on the friendly unit you point at.")
add("PRIEST","p_shield","Mouseover Power Word: Shield",{17},"help","Shield a friendly mouseover, target, or yourself.")
add("PRIEST","p_renew","Mouseover Renew",{139},"help","Apply Renew without changing your hostile target.")
add("PRIEST","p_dispel","Mouseover Dispel Magic",{527},"anymouse","A living mouseover takes priority; can target friends or foes.")
add("PRIEST","p_disease","Mouseover Cure Disease",{528},"help","Friendly mouseover, friendly target, then self.")
add("PRIEST","p_shackle","Focus Shackle Undead",{9484},"focus","Use on a living hostile focus of the correct creature type.")
add("PRIEST","p_scream","Stopcasting Psychic Scream",{8122},"stop","Ends your current cast before the fear attempt.")
add("PALADIN","pa_hl","Mouseover Holy Light",{635},"help","Friendly mouseover, friendly target, then self.")
add("PALADIN","pa_fl","Mouseover Flash of Light",{19750},"help","Fast heal without changing your hostile target.")
add("PALADIN","pa_cleanse","Mouseover Cleanse",{4987},"help","Uses your learned Cleanse on the friendly unit you point at.")
add("PALADIN","pa_purify","Mouseover Purify",{1152},"help","Friendly mouseover, friendly target, then self.")
add("PALADIN","pa_bop","Protection / Alt Self",{1022},"altself","Normal friendly mouseover/target; Alt explicitly targets yourself.")
add("PALADIN","pa_loh","Stopcasting Lay on Hands",{633},"stophelp","Stops your cast, then uses a friendly mouseover, target, or self.")
add("PALADIN","pa_hoj","Focus Hammer of Justice",{853},"focus","Stun your living hostile focus without changing target.")
add("PALADIN","pa_might","Mouseover Blessing of Might",{19740},"help","Friendly mouseover, friendly target, then self.")
add("HUNTER","h_mark","Hunter's Mark + Pet Attack",{1130},"petmark","Sends your pet to your hostile target and attempts Hunter's Mark.")
add("HUNTER","h_conc","Mouseover Concussive Shot",{5116},"harm","Living hostile mouseover, otherwise your target.")
add("HUNTER","h_scare","Focus Scare Beast",{1513},"focus","Crowd-control a living hostile focus of the correct creature type.")
add("HUNTER","h_raptor","Raptor Strike + Auto Attack",{2973},"attack","Starts melee attack and attempts Raptor Strike.")
add("HUNTER","h_wing","Wing Clip + Auto Attack",{2974},"attack","Starts melee attack before attempting the slow.")
add("HUNTER","h_feign","Stop Attack + Feign Death",{5384},"stopattack","Stops your auto-attack before attempting Feign Death.")
add("HUNTER","h_auto","Auto Shot Toggle Protection",{75},"toggle","Uses !Auto Shot to avoid toggling supported auto fire off.")
add("HUNTER","h_pet","Pet Attack / Follow / Stay",{},"petcontrol","Normal: attack; Shift: follow; Ctrl: stay. Requires a pet.")
add("ROGUE","r_stealth","Stealth Toggle Protection",{1784},"toggle","Uses !Stealth. Combat and stealth restrictions still apply.")
add("ROGUE","r_kick","Focus Kick",{1766},"focus","Interrupt a living hostile focus without changing target.")
add("ROGUE","r_blind","Focus Blind",{2094},"focus","Crowd-control your living hostile focus.")
add("ROGUE","r_sap","Mouseover Sap",{6770},"harm","Uses a hostile mouseover or target. Normal Sap rules remain.")
add("ROGUE","r_vanish","Stop Attack + Vanish",{1856},"stopattack","Stops auto-attack before Vanish; normal requirements still apply.")
add("ROGUE","r_backstab","Backstab + Auto Attack",{53},"stealthattack","Auto-attack starts only outside stealth; positioning still matters.")
add("ROGUE","r_ss","Sinister Strike + Auto Attack",{1752},"attack","Starts melee attack and attempts Sinister Strike.")
add("ROGUE","r_escape","Evasion / Shift Sprint",{5277,2983},"shiftspell","Normal: Evasion. Shift: Sprint. Both abilities must be learned.")
add("WARLOCK","wl_fear","Focus Fear",{5782},"focus","Fear your living hostile focus without changing target.")
add("WARLOCK","wl_banish","Focus Banish",{710},"focus","Use on a hostile focus of a banishable creature type.")
add("WARLOCK","wl_corrupt","Mouseover Corruption",{172},"harm","Apply Corruption to a hostile mouseover or current target.")
add("WARLOCK","wl_immo","Mouseover Immolate",{348},"harm","Living hostile mouseover, otherwise your target.")
add("WARLOCK","wl_drain","Drain Soul Channel Guard",{1120},"channel","Does not restart the selected channel while it is already channeling.")
add("WARLOCK","wl_curses","Weakness / Shift Tongues",{702,1714},"shiftspell","Normal: Weakness. Shift: Tongues. Both curses must be learned.")
add("WARLOCK","wl_pet","Demon Attack / Follow / Stay",{},"petcontrol","Normal: attack; Shift: follow; Ctrl: stay. Requires a demon.")
add("WARLOCK","wl_coil","Stopcasting Focus Death Coil",{6789},"stopfocus","Stops your cast before attempting Death Coil on focus.")
add("SHAMAN","s_hw","Mouseover Healing Wave",{331},"help","Friendly mouseover, friendly target, then self.")
add("SHAMAN","s_lhw","Mouseover Lesser Healing Wave",{8004},"help","Fast heal without changing your hostile target.")
add("SHAMAN","s_chain","Mouseover Chain Heal",{1064},"help","Choose the initial friendly target with your mouseover.")
add("SHAMAN","s_shock","Stopcasting Focus Earth Shock",{8042},"stopfocus","Stops your cast and attempts Earth Shock on your hostile focus.")
add("SHAMAN","s_purge","Mouseover Purge",{370},"harm","Purge a living hostile mouseover or current target.")
add("SHAMAN","s_poison","Mouseover Cure Poison",{526},"help","Friendly mouseover, friendly target, then self.")
add("SHAMAN","s_disease","Mouseover Cure Disease",{2870},"help","Friendly mouseover, friendly target, then self.")
add("SHAMAN","s_shields","Lightning / Shift Water Shield",{324,52127},"shiftspell","Normal: Lightning Shield. Shift: Water Shield; requires both learned.")
local shared={
    {"all_focus","Set Focus / Alt Clear","/clearfocus [mod:alt]\n/focus [nomod,@mouseover,exists,nodead][nomod,exists,nodead]","Normal: focus mouseover or target. Alt: clear focus."},
    {"all_assist","Assist Focus","/assist [@focus,exists,nodead]","Targets your living focus unit's target."},
    {"all_previous","Previous Target","/targetlasttarget","Returns to your previous target, which may be friendly."},
    {"all_stop","Stop Current Cast","/stopcasting","Manually stops your current cast when you press this macro."},
}
for _,row in ipairs(shared) do
    MF.premades[#MF.premades+1]={class="ALL",key=row[1],label=row[2],spells={},raw=row[3],note=row[4],source="https://muchamielwow.github.io/en/comunes/",reviewed="2026-11-09",client="Forever 1.60.1 / 70862; not tested in game"}
end
function MF:PremadeResolve(entry,draft)
    local names,primary={},nil
    for _,id in ipairs(entry.spells) do
        local name=self:SpellInfo(id)
        local learned
        for _,s in ipairs(self.catalog) do
            if (s.id==id or name and s.name==name) and s.known and not s.passive then learned=s; break end
        end
        if not draft and not learned and not self:IsKnown(id) then return nil,"Learn the required spell first: "..(name or "spell #"..id).."." end
        if not name and learned then name=learned.name end
        if not name then return nil,"Client spell data unavailable for #"..id..". Refresh after spell data loads." end
        names[#names+1]=name; primary=primary or learned or {id=id,name=name,icon=134400}
    end
    return names,nil,primary
end
function MF:PremadePrimary(entry)
    local _,_,spell=self:PremadeResolve(entry,true)
    return spell
end
function MF:PremadeIcon(entry)
    for _,id in ipairs(entry.spells or {}) do
        local _,_,icon=self:SpellInfo(id)
        if icon then return icon end
    end
    return "Interface\\MacroFrame\\MacroFrame-Icon"
end
function MF:PremadePreview(entry,draft)
    local _,class=UnitClass("player")
    if not entry or entry.class~="ALL" and entry.class~=class then return nil,"Choose a premade for your class." end
    local s,err=self:PremadeResolve(entry,draft)
    if not s then return nil,err end
    local first=s[1] or ""
    local body=entry.raw
    if not body then
        local args,extra=first,""
        local style=entry.style
        if style=="help" then args="[@mouseover,help,nodead][help,nodead][@player] "..first
        elseif style=="deadfriend" then args="[@mouseover,help,dead][help,dead] "..first
        elseif style=="harm" then args="[@mouseover,harm,nodead][] "..first
        elseif style=="anymouse" then args="[@mouseover,exists,nodead][] "..first
        elseif style=="focus" or style=="stopfocus" then args="[@focus,harm,nodead] "..first
        elseif style=="cursor" then args="[@cursor] "..first
        elseif style=="altself" then args="[mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] "..first
        elseif style=="toggle" then args="!"..first
        elseif style=="channel" then args="[nochanneling:"..first.."] "..first
        elseif style=="shiftspell" then args="[mod:shift] "..s[2].."; [nomod] "..first
        elseif style=="petcontrol" then body="/petfollow [mod:shift]\n/petstay [mod:ctrl,nomod:shift]\n/petattack [nomod,@mouseover,harm,nodead][nomod,harm,nodead]"
        end
        if style=="attack" or style=="petmark" then extra=(style=="attack" and "/startattack" or "/petattack").." [harm,nodead]\n"
        elseif style=="stealthattack" then extra="/startattack [nostealth,harm,nodead]\n"
        elseif style=="stop" or style=="stophelp" or style=="stopfocus" then extra="/stopcasting\n"
        elseif style=="stopattack" then extra="/stopattack\n" end
        if style=="stophelp" then args="[@mouseover,help,nodead][help,nodead][@player] "..first end
        if not body then body="#showtooltip "..first.."\n"..extra.."/cast "..args end
    end
    if entry.forms then
        local required
        for _,id in ipairs(entry.forms) do
            for _,form in ipairs(self:RequirementForms()) do if form.id==id then required=id; break end end
            if required then break end
        end
        if not required then return nil,"Learn and expose the required form/stance on the native form/stance bar first." end
        body,err=self:ApplyRequiredForm(body,required,nil,draft)
        if not body then return nil,err end
    end
    local _,_,limit=self:Limits()
    if not draft and #body>limit then return nil,"Premade exceeds this client's "..limit.."-byte limit with localized spell names." end
    return body
end
