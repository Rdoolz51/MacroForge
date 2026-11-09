local _,MF=...
function MF:PositionMinimap(angle)
    if not self.minimapButton or not Minimap then return end
    local radians=math.rad(angle or self.db.preferences.minimapAngle or 225)
    local radius=Minimap:GetWidth()/2+10
    self.minimapButton:ClearAllPoints()
    self.minimapButton:SetPoint("CENTER",Minimap,"CENTER",math.cos(radians)*radius,math.sin(radians)*radius)
end
function MF:InstallMinimap()
    if not self.db or not Minimap or self:Combat() then return end
    if not self.minimapButton then
        local button=CreateFrame("Button","MacroForgeMinimapButton",Minimap)
        self.minimapButton=button
        button:SetSize(32,32); button:SetFrameStrata("HIGH"); button:SetFrameLevel(Minimap:GetFrameLevel()+8)
        button:SetMovable(true); button:EnableMouse(true); button:RegisterForClicks("LeftButtonUp"); button:RegisterForDrag("LeftButton")
        local background=button:CreateTexture(nil,"BACKGROUND"); background:SetColorTexture(0.05,0.05,0.05,1); background:SetAllPoints()
        local icon=button:CreateTexture(nil,"ARTWORK")
        icon:SetTexture("Interface\\MacroFrame\\MacroFrame-Icon"); icon:SetTexCoord(0.07,0.93,0.07,0.93)
        icon:SetPoint("TOPLEFT",3,-3); icon:SetPoint("BOTTOMRIGHT",-3,3)
        for _,edge in ipairs({"TOP","BOTTOM","LEFT","RIGHT"}) do
            local border=button:CreateTexture(nil,"BORDER"); border:SetColorTexture(0.55,0.45,0.20,1)
            if edge=="TOP" or edge=="BOTTOM" then border:SetHeight(1); border:SetPoint(edge.."LEFT"); border:SetPoint(edge.."RIGHT")
            else border:SetWidth(1); border:SetPoint("TOP"..edge); border:SetPoint("BOTTOM"..edge) end
        end
        local hover=button:CreateTexture(nil,"HIGHLIGHT"); hover:SetColorTexture(1,1,1,0.2); hover:SetAllPoints(icon)
        button:SetScript("OnMouseDown",function(self) self.wasDragged=false end)
        button:SetScript("OnClick",function(self) if not self.wasDragged then MF:Toggle() end end)
        button:SetScript("OnDragStart",function(self)
            self.wasDragged=true; GameTooltip:Hide()
            self:SetScript("OnUpdate",function()
                local mx,my=Minimap:GetCenter()
                if not mx or not my then return end
                local x,y=GetCursorPosition(); local scale=Minimap:GetEffectiveScale()
                MF.minimapDragAngle=math.deg(math.atan2(y/scale-my,x/scale-mx))
                MF:PositionMinimap(MF.minimapDragAngle)
            end)
        end)
        button:SetScript("OnDragStop",function(self)
            self:SetScript("OnUpdate",nil)
            if MF.minimapDragAngle then MF.db.preferences.minimapAngle=MF.minimapDragAngle; MF.minimapDragAngle=nil end
        end)
        button:SetScript("OnEnter",function(self)
            GameTooltip:SetOwner(self,"ANCHOR_LEFT"); GameTooltip:SetText("MacroForge")
            GameTooltip:AddLine("Click: open or close MacroForge",1,1,1)
            GameTooltip:AddLine("Drag: move around the minimap",0.8,0.8,0.8)
            GameTooltip:AddLine("/mf minimap: hide or show this icon",0.8,0.8,0.8); GameTooltip:Show()
        end)
        button:SetScript("OnLeave",function() GameTooltip:Hide() end)
        if Minimap.HookScript then Minimap:HookScript("OnSizeChanged",function() MF:PositionMinimap() end) end
    end
    self:PositionMinimap()
    self.minimapButton:SetShown(not self.db.preferences.minimapHidden)
end
