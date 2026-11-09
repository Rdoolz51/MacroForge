local _, MF = ...
function MF:Call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok,a,b,c,d,e,f,g=pcall(fn,...)
    if ok then return a,b,c,d,e,f,g end
end
function MF:SpellInfo(id)
    local info=self:Call(C_Spell and C_Spell.GetSpellInfo,id)
    if type(info)=="table" then return info.name,self:Call(C_Spell.GetSpellSubtext,id) or "",info.iconID,info.spellID or id end
    local name,rank,icon,_,_,_,spellID=self:Call(GetSpellInfo,id)
    return name,rank or "",icon,spellID or id
end
function MF:IsKnown(id)
    for _,fn in ipairs({IsPlayerSpell or false,IsSpellKnown or false,C_SpellBook and C_SpellBook.IsSpellKnown or false}) do
        if self:Call(fn,id)==true then return true end
    end
    return false
end
function MF:Limits()
    local c=Constants and Constants.MacroConsts or {}
    return c.MAX_ACCOUNT_MACROS or MAX_ACCOUNT_MACROS,c.MAX_CHARACTER_MACROS or MAX_CHARACTER_MACROS,MAX_MACRO_LENGTH or 255,MAX_MACRO_NAME_LENGTH or 16
end
function MF:Diagnostics()
    local v,b,_,api=GetBuildInfo()
    local a,c,t,n=self:Limits()
    return string.format("Client %s/%s; interface %s; C_SpellBook=%s; CreateMacro=%s; slots=%s/%s; byte limits=%s/%s",tostring(v),tostring(b),tostring(api),tostring(C_SpellBook~=nil),type(CreateMacro),tostring(a),tostring(c),tostring(t),tostring(n))
end
function MF:OpenNativeMacros()
    if self:Combat() then self:Status("Leave combat before opening macro management."); return end
    if not MacroFrame then self:Call(C_AddOns and C_AddOns.LoadAddOn or LoadAddOn,"Blizzard_MacroUI") end
    if ShowMacroFrame then ShowMacroFrame()
    elseif MacroFrame_Show then MacroFrame_Show()
    elseif MacroFrame then MacroFrame:Show()
    else self:Status("Open native macros through the game menu or /macro."); return end
    -- OnShow defaults to General, so select Character after the native show handler.
    if MacroFrame and type(MacroFrame.ChangeTab)=="function" then
        local ok=pcall(MacroFrame.ChangeTab,MacroFrame,2)
        if not ok then self:Status("Macro window opened. Select the character-specific tab manually on this client.") end
    elseif MacroFrameTab2 and type(MacroFrameTab2.Click)=="function" then
        MacroFrameTab2:Click()
    else self:Status("Macro window opened. Select the character-specific tab manually on this client.") end
end
