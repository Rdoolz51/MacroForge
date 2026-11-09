local _,MF=...
local function fill(parent,layer,r,g,b,a)
    local texture=parent:CreateTexture(nil,layer)
    texture:SetColorTexture(r,g,b,a)
    return texture
end
function MF:InstallShortcut()
    if not self.db or self:Combat() then return end
    local parent=PlayerSpellsFrame or SpellBookFrame
    if not parent then return end
    local host=parent.SpellBookFrame or parent
    self.shortcutParent=parent; self.shortcutHost=host
    if not self.shortcut then
        local button=CreateFrame("Button","MacroForgeSpellBookButton",UIParent)
        button:SetSize(34,34); button:SetFrameStrata("HIGH"); button:Hide()
        local background=fill(button,"BACKGROUND",0.05,0.05,0.05,0.95)
        background:SetAllPoints()
        for _,edge in ipairs({"TOP","BOTTOM","LEFT","RIGHT"}) do
            local border=fill(button,"BORDER",0.55,0.45,0.20,1)
            if edge=="TOP" or edge=="BOTTOM" then
                border:SetHeight(1); border:SetPoint(edge.."LEFT"); border:SetPoint(edge.."RIGHT")
            else
                border:SetWidth(1); border:SetPoint("TOP"..edge); border:SetPoint("BOTTOM"..edge)
            end
        end
        local icon=button:CreateTexture(nil,"ARTWORK")
        icon:SetPoint("TOPLEFT",3,-3); icon:SetPoint("BOTTOMRIGHT",-3,3)
        icon:SetTexture("Interface\\MacroFrame\\MacroFrame-Icon")
        icon:SetTexCoord(0.07,0.93,0.07,0.93)
        local highlight=fill(button,"HIGHLIGHT",1,1,1,0.15); highlight:SetAllPoints(icon)
        button.glow=fill(button,"OVERLAY",1,0.82,0.2,0.25); button.glow:SetAllPoints(); button.glow:Hide()
        button:SetScript("OnClick",function() MF:Toggle(); MF:UpdateShortcutGlow() end)
        button:SetScript("OnEnter",function(self)
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT"); GameTooltip:SetText("MacroForge")
            GameTooltip:AddLine("Click to open or close MacroForge.",0.8,0.8,0.8,true); GameTooltip:Show()
        end)
        button:SetScript("OnLeave",function() GameTooltip:Hide() end)
        self.shortcut=button
    end
    self.shortcut:ClearAllPoints()
    if WhatsTrainingSpellBookButton then
        self.shortcut:SetPoint("BOTTOMLEFT",WhatsTrainingSpellBookButton,"TOPLEFT",0,4)
    else self.shortcut:SetPoint("TOPLEFT",parent,"TOPRIGHT",0,-10) end
    local function sync()
        MF.shortcut:SetShown(MF.shortcutParent:IsShown() and MF.shortcutHost:IsShown() and MF.db.preferences.shortcut~=false)
        MF:UpdateShortcutGlow()
    end
    if self.hookedParent~=parent and parent.HookScript then
        parent:HookScript("OnShow",sync); parent:HookScript("OnHide",sync); self.hookedParent=parent
    end
    if host~=parent and self.hookedHost~=host and host.HookScript then
        host:HookScript("OnShow",sync); host:HookScript("OnHide",sync); self.hookedHost=host
    end
    sync()
end
function MF:UpdateShortcutGlow()
    if self.shortcut and self.shortcut.glow then self.shortcut.glow:SetShown(self.frame and self.frame:IsShown() or false) end
end
