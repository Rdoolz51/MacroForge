local _,MF=...
-- Reusable searchable selection popup. No dependency on version-specific menu APIs.
function MF:Dropdown(parent,x,y,width,title,options,select)
    local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
    b:SetSize(width,26); b:SetPoint("TOPLEFT",x,y)
    b.options=options; b.select=select; b.title=title
    function b:SetLabel(label) self.labelValue=label; self:SetText(label.."  v") end
    b:SetLabel(title)
    b:SetScript("OnClick",function() MF:OpenDropdown(b) end)
    b:SetScript("OnHide",function() if MF.selectionMenu and MF.selectionMenu.owner==b then MF.selectionMenu:Hide() end end)
    return b
end
function MF:OpenDropdown(owner)
    if not self.selectionMenu then
        local f=CreateFrame("Frame","MacroForgeSelectionMenu",UIParent,"BasicFrameTemplateWithInset")
        self.selectionMenu=f; f:SetSize(420,440); f:SetFrameStrata("TOOLTIP"); f:SetClampedToScreen(true); f:EnableMouse(true); f:EnableMouseWheel(true)
        table.insert(UISpecialFrames,"MacroForgeSelectionMenu")
        local search=CreateFrame("EditBox",nil,f,"InputBoxTemplate")
        f.search=search; search:SetSize(365,26); search:SetPoint("TOPLEFT",25,-42); search:SetAutoFocus(false)
        search:SetScript("OnTextChanged",function() f.offset=0; MF:FilterDropdown() end)
        search:SetScript("OnEscapePressed",function() f:Hide() end)
        search:SetScript("OnEnterPressed",function() local o=f.filtered[f.offset+1]; if o and not o.disabled then f.owner.select(o.value); f:Hide() end end)
        f.rows={}
        for i=1,10 do
            local row=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
            row:SetSize(380,26); row:SetPoint("TOPLEFT",20,-78-(i-1)*28)
            row:SetScript("OnClick",function(self)
                if self.option and not self.option.disabled then f.owner.select(self.option.value); f:Hide() end
            end)
            f.rows[i]=row
        end
        f.count=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); f.count:SetPoint("BOTTOM",0,44)
        local function nav(label,x,delta)
            local b=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
            b:SetSize(175,26); b:SetPoint("BOTTOMLEFT",x,12); b:SetText(label)
            b:SetScript("OnClick",function() f.offset=f.offset+delta; MF:FilterDropdown() end)
        end
        nav("Previous choices",20,-10); nav("More choices",225,10)
        f:SetScript("OnMouseWheel",function(_,delta) f.offset=f.offset-delta*3; MF:FilterDropdown() end)
        f:SetScript("OnHide",function() f.search:ClearFocus() end)
    end
    local f=self.selectionMenu
    f.owner=owner; f.all=owner.options(); f.offset=0
    f.TitleText:SetText(owner.title.." — type to search")
    f:ClearAllPoints(); f:SetPoint("TOPLEFT",owner,"BOTTOMLEFT",0,-3)
    f.search:SetText(""); self:FilterDropdown(); f:Show(); f.search:SetFocus()
end
function MF:FilterDropdown()
    local f=self.selectionMenu; local query=string.lower(f.search:GetText() or "")
    f.filtered={}
    for _,option in ipairs(f.all or {}) do
        if string.find(string.lower(option.label),query,1,true) then f.filtered[#f.filtered+1]=option end
    end
    f.offset=math.max(0,math.min(f.offset or 0,math.max(0,#f.filtered-10)))
    for i,row in ipairs(f.rows) do
        local option=f.filtered[f.offset+i]
        row.option=option
        if option then
            row:SetText(option.label)
            if option.disabled then row:Disable() else row:Enable() end
            row:Show()
        else row:Hide() end
    end
    f.count:SetText(#f.filtered==0 and "No matching choices" or (f.offset+1).."–"..math.min(f.offset+10,#f.filtered).." of "..#f.filtered)
end
