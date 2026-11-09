local addonName, MF = ...
MF.version = "0.7.1"
MF.catalog = {}
function MF:MacroInitials(name)
    local _,_,_,limit=self:Limits()
    name=string.match(name or "","^%s*(.-)%s*$")
    local words={}
    for word in string.gmatch(name,"%S+") do words[#words+1]=word end
    -- Keep a single word intact. The name validator reports any client limit.
    if #words==1 then return name end
    local result=""
    for _,word in ipairs(words) do
        word=string.gsub(word,"^%p+","")
        local first=string.match(word,"^[%z\1-\127\194-\244][\128-\191]*")
        if first and #result+#first<=limit then result=result..string.upper(first) end
    end
    return result~="" and result or "MF"
end
function MF:Combat() return InCombatLockdown and InCombatLockdown() or false end
function MF:Status(message)
    self.message=message
    if self.statusText then self.statusText:SetText(message) end
end

function MF:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100MacroForge:|r " .. message)
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, name)
    if event ~= "ADDON_LOADED" then
        if not MF.db then return end
        if not MF:Combat() and event ~= "UPDATE_MACROS" then MF:Discover(event); MF:InstallShortcut(); MF:InstallMinimap() end
        if MF.frame and MF.frame:IsShown() then MF:Refresh() end
        return
    end
    if name ~= addonName then if MF.db then MF:InstallShortcut() end; return end
    if type(MacroForgeDB) ~= "table" then MacroForgeDB = {} end
    MF.db = MacroForgeDB
    for _, key in ipairs({"preferences", "owned", "catalog", "verified"}) do
        if type(MF.db[key]) ~= "table" then MF.db[key]={} end
    end
    MF.db.schema=1
    SLASH_MACROFORGE1 = "/mf"
    SLASH_MACROFORGE2 = "/macroforge"
    SlashCmdList.MACROFORGE = function(text)
        if text == "diagnostics" then MF:Print(MF:Diagnostics())
        elseif text == "minimap" then MF.db.preferences.minimapHidden=not MF.db.preferences.minimapHidden; MF:InstallMinimap()
        elseif text == "minimap reset" then MF.db.preferences.minimapAngle=225; MF.db.preferences.minimapHidden=false; MF:InstallMinimap()
        else MF:Toggle() end
    end
    for _, e in ipairs({"PLAYER_LOGIN","SPELLS_CHANGED","PLAYER_REGEN_DISABLED","PLAYER_REGEN_ENABLED","UPDATE_MACROS","TRAINER_SHOW","TRAINER_UPDATE"}) do pcall(self.RegisterEvent,self,e) end
    MF:Print("Loaded. Type /mf to open the workshop.")
    MF:InstallMinimap()
end)
