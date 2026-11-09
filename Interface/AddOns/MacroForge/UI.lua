local _,MF=...
local function text(parent,value,x,y,width,font)
    local label=parent:CreateFontString(nil,"OVERLAY",font or "GameFontHighlight")
    label:SetPoint("TOPLEFT",x,y); label:SetWidth(width); label:SetJustifyH("LEFT"); label:SetText(value)
    return label
end
local function button(parent,label,x,y,width,click)
    local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
    b:SetSize(width,26); b:SetPoint("TOPLEFT",x,y); b:SetText(label); b:SetScript("OnClick",click)
    return b
end
local function check(parent,label,x,y,key,store,changed)
    local b=CreateFrame("CheckButton",nil,parent,"UICheckButtonTemplate")
    b:SetSize(26,26); b:SetPoint("TOPLEFT",x,y); b:SetChecked(store[key]==true)
    b.label=text(parent,label,x+30,y-5,510)
    b:SetScript("OnClick",function(self) store[key]=self:GetChecked()==true; changed() end)
    return b
end
local function preview(parent,x,y,width,height)
    local scroll=CreateFrame("ScrollFrame",nil,parent)
    scroll:SetSize(width,height); scroll:SetPoint("TOPLEFT",x,y); scroll:EnableMouseWheel(true)
    local child=CreateFrame("Frame",nil,scroll); child:SetSize(width,height); scroll:SetScrollChild(child)
    local label=text(child,"",0,-2,width-8,"GameFontHighlight")
    scroll:SetScript("OnMouseWheel",function(self,delta)
        self:SetVerticalScroll(math.max(0,math.min(self:GetVerticalScroll()-delta*24,self:GetVerticalScrollRange())))
    end)
    local result={}
    function result:SetText(value)
        self.text=value; label:SetText(value)
        child:SetHeight(math.max(height,label:GetStringHeight() or height)+8); scroll:SetVerticalScroll(0)
    end
    return result
end
function MF:BuildRuleControls(parent,x,y,modeX,formX,formWidth,getRule)
    local controls={getRule=getRule}
    local b=CreateFrame("CheckButton",nil,parent,"UICheckButtonTemplate")
    b:SetSize(26,26); b:SetPoint("TOPLEFT",x,y); controls.check=b
    controls.label=text(parent,"Only when",x+28,y-5,110)
    b:SetScript("OnClick",function(self) getRule().enabled=self:GetChecked()==true; MF:UpdateEditor() end)
    controls.mode=self:Dropdown(parent,modeX,y,120,"Form/stance rule",function()
        local _,class=UnitClass("player")
        local list={{label=class=="WARRIOR" and "Requires stance" or "Requires form",value="require"}}
        if class=="DRUID" then table.insert(list,1,{label="Not in selected form",value="not"}); table.insert(list,1,{label="In selected form",value="in"}) end
        return list
    end,function(value) getRule().kind=value; MF:UpdateEditor() end)
    controls.form=self:Dropdown(parent,formX,y,formWidth,"Select form/stance",function()
        local result={}
        local list=getRule().kind=="require" and MF:RequirementForms() or MF:FormOptions()
        for _,form in ipairs(list) do result[#result+1]={label=form.name,value=form.id} end
        return result
    end,function(value) getRule().spellID=value; MF:UpdateEditor() end)
    local function explain(self)
        local note=MF:RequirementNote(getRule()) or "Requires Form/Stance switches to the selected form or stance before the macro ability. Another press may be needed after its global cooldown."
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT"); GameTooltip:SetText("Requires Form / Stance")
        GameTooltip:AddLine(note,1,1,1,true); GameTooltip:Show()
    end
    for _,control in ipairs({b,controls.mode,controls.form}) do
        control:SetScript("OnEnter",explain); control:SetScript("OnLeave",function() GameTooltip:Hide() end)
    end
    return controls
end
function MF:RefreshRuleControls(controls,visible)
    controls.check:SetShown(visible); controls.label:SetShown(visible); controls.mode:SetShown(visible); controls.form:SetShown(visible)
    if not visible then return end
    local rule=controls.getRule()
    controls.check:SetChecked(rule.enabled==true)
    controls.label:SetText(rule.kind=="require" and "Requires" or "Only when")
    local _,class=UnitClass("player")
    controls.mode:SetLabel(rule.kind=="require" and (class=="WARRIOR" and "Stance" or "Form") or rule.kind=="not" and "Not in" or "In")
    local label="Form unavailable"
    local list=rule.kind=="require" and self:RequirementForms() or self:FormOptions()
    for _,form in ipairs(list) do if form.id==rule.spellID then label=form.name end end
    controls.form:SetLabel(label)
end
function MF:SelectSpell(spell)
    if self.premadeFrame then self.premadeFrame:Hide() end
    self.premadeSelection=nil
    self.selected=spell; self.rankID=spell.id; self.mode="max"; self.comboEnabled=false; self.equipmentOnly=false
    self.nameBox:SetText(self:MacroInitials(spell.name))
    self.editor:Show(); self:UpdateEditor()
end
function MF:UpdateEditor()
    if not self.editor or not self.editor:IsShown() then return end
    local spell=self.selected
    self.editor.TitleText:SetText(self.equipmentOnly and "Warrior: equip 1H + shield" or spell.name)
    local rankLabel="Unknown"
    for _,s in ipairs(self:Family(spell)) do if s.id==self.rankID then rankLabel=s.rank..(s.known and " (learned)" or " (unlearned)") end end
    self.rankText:SetText((self.mode=="max" and "Max rank: rank-free /cast" or self.mode=="one" and "Rank 1" or "Selected rank: "..rankLabel).."\nTemplate: "..self.templates[self.template or "plain"].label)
    local body,draftError=self:CurrentPreview(true)
    local valid,err=self:CurrentPreview()
    local nameError=self:MacroNameError(self.nameBox:GetText())
    if self.comboEnabled then self.rankText:SetText("Modifier combo enabled — each branch has its own rank selection.\nEdit branches with Modifier combos...") end
    self.previewText:SetText(body or draftError or "Select options to preview.")
    if valid and not nameError and not self:Combat() then self.generateButton:Enable() else self.generateButton:Disable() end
    local status=self:Combat() and "Creation disabled during combat lockdown." or nameError or err or "Preview only. Click Generate to create."
    local requirement=not self.comboEnabled and self:RequirementNote(self:SpellFormRule())
    self.editorStatus:SetText(status..(requirement and "\n"..requirement or ""))
    local _,class=UnitClass("player")
    self:RefreshRuleControls(self.spellRuleControls,(class=="DRUID" or class=="WARRIOR") and not self.comboEnabled and not self.equipmentOnly)
    self.rankDropdown:SetLabel(self.mode=="max" and "Max rank (rank-free)" or self.mode=="one" and "Rank 1" or rankLabel)
    self.templateDropdown:SetLabel(self.templates[self.template or "plain"].label)
    self.spellBang:SetChecked(self:SpellFormRule().noToggle==true)
    if self.comboFrame and self.comboFrame:IsShown() then self:RefreshComboUI() end
end
function MF:BuildEditor()
    local e=CreateFrame("Frame","MacroForgeEditor",self.frame,"BasicFrameTemplateWithInset")
    self.editor=e; e:SetSize(540,540); e:SetPoint("CENTER"); e:SetFrameStrata("DIALOG"); e:EnableMouse(true)
    table.insert(UISpecialFrames,"MacroForgeEditor")
    self.rankDropdown=self:Dropdown(e,22,-40,490,"Select rank",function()
        local result={{label="Max rank (rank-free)",value={mode="max"}}}
        for _,s in ipairs(MF:Family(MF.selected)) do
            if s.rank~="" then result[#result+1]={label=s.rank..(s.known and " — learned" or " — unlearned"),value={mode="rank",id=s.id},disabled=not s.known} end
        end
        return result
    end,function(value) MF.mode=value.mode; MF.rankID=value.id; MF:UpdateEditor() end)
    self.rankText=text(e,"",22,-80,490)
    text(e,"Macro name",22,-126,100)
    local name=CreateFrame("EditBox",nil,e,"InputBoxTemplate")
    name:SetSize(240,24); name:SetPoint("TOPLEFT",130,-120); name:SetAutoFocus(false)
    name:SetScript("OnEscapePressed",function(self) self:ClearFocus() end); self.nameBox=name
    name:SetScript("OnTextChanged",function() MF:UpdateEditor() end)
    text(e,"Generated macro preview — mouse wheel to scroll",22,-205,490,"GameFontNormal")
    self.previewText=preview(e,22,-230,490,85)
    self.templateDropdown=self:Dropdown(e,22,-161,250,"Select template",function()
        local result={}
        for _,key in ipairs(MF.templateOrder) do result[#result+1]={label=MF.templates[key].label,value=key} end
        return result
    end,function(value) MF.template=value; MF.db.preferences.template=value; MF:UpdateEditor() end)
    button(e,"Modifier combos...",290,-161,220,function() MF:OpenComboUI() end)
    self.spellRuleControls=self:BuildRuleControls(e,22,-332,180,310,200,function() return MF:SpellFormRule() end)
    self.spellBang=CreateFrame("CheckButton",nil,e,"UICheckButtonTemplate")
    self.spellBang:SetSize(26,26); self.spellBang:SetPoint("TOPLEFT",22,-366)
    text(e,"Keep active aura on (!) — e.g. !Prowl",52,-371,450)
    self.spellBang:SetScript("OnEnter",function(self)
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT"); GameTooltip:SetText("Keep active aura on (!)")
        GameTooltip:AddLine("Adds ! to the cast. Prevents supported toggles from switching off; does not check whether every spell's aura is present.",1,1,1,true); GameTooltip:Show()
    end)
    self.spellBang:SetScript("OnLeave",function() GameTooltip:Hide() end)
    self.spellBang:SetScript("OnClick",function(self) MF:SpellFormRule().noToggle=self:GetChecked()==true; MF:UpdateEditor() end)
    self.editorStatus=text(e,"",22,-406,490)
    self.generateButton=button(e,"Generate",22,-486,150,function()
        local ok,message=MF:Generate(); MF:Status(message); MF.editorStatus:SetText(message)
        if ok then MF:Refresh() end
    end)
    button(e,"Open Macro Window",190,-486,150,function() MF:OpenNativeMacros() end)
    button(e,"Cancel",358,-486,150,function() e:Hide() end)
    e:Hide()
end
function MF:Refresh()
    if not self.frame then return end
    local tab=self.db.selectedTab or 1
    local query=string.lower(self.search:GetText() or "")
    local entries={}
    if tab==3 then
        local list,err,account,character=self:Inventory()
        list=list or {}
        table.sort(list,function(a,b)
            if a.location~=b.location then return a.location=="Character" end
            local left,right=string.lower(a.name),string.lower(b.name)
            if left==right then return a.index<b.index end
            return left<right
        end)
        for _,m in ipairs(list) do
            if string.find(string.lower(m.name.." "..(m.body or "")),query,1,true) then
                entries[#entries+1]={title=m.name,subtitle=m.location=="Character" and "This character" or "General (shared)",icon=m.icon,macro=m}
            end
        end
        self.coverage:SetText(err or "All available macros: "..(character or 0).." for this character + "..(account or 0).." general/shared. Click one to view its full text. No macros are changed.")
    elseif tab==2 then
        local _,class=UnitClass("player")
        for _,premade in ipairs(self.premades) do
            if (premade.class==class or premade.class=="ALL") and string.find(string.lower(premade.label.." "..premade.note),query,1,true) then
                entries[#entries+1]={title=premade.label,subtitle=premade.class=="ALL" and "Shared utility" or (premade.forms and "Class premade — form / stance" or "Class premade"),icon=self:PremadeIcon(premade),premade=premade}
            end
        end
        self.coverage:SetText("Premade macros for your class + shared utility. Select one to review its body, prerequisites and source. Generate is always explicit.")
    else
        for _,s in ipairs(self.catalog) do
            if not s.passive and string.find(string.lower(s.name.." "..s.rank),query,1,true) and (self.filter==nil or self.filter=="all" or self.filter=="learned" and s.known or self.filter=="unlearned" and not s.known) then
                entries[#entries+1]={title=s.name,subtitle=(s.rank~="" and s.rank or "Rank-free")..(s.known and " — Learned" or " — Unlearned"),icon=s.icon,spell=s}
            end
        end
        self.coverage:SetText(self.discovery or "Open outside combat to discover spells.")
    end
    local pageSize=#self.rows
    local pages=math.max(1,math.ceil(#entries/pageSize)); self.page=math.max(1,math.min(self.page or 1,pages))
    for i,row in ipairs(self.rows) do
        local entry=entries[(self.page-1)*pageSize+i]
        row.entry=entry
        if entry then
            row.label:SetText(entry.title); row.detail:SetText(entry.subtitle or "")
            row.icon:SetTexture(entry.icon or 134400)
            row.icon:SetDesaturated(entry.spell and not entry.spell.known or false)
            row:Show()
        else row:Hide() end
    end
    self.pageText:SetText("Page "..self.page.." / "..pages.."  •  "..#entries.." entries")
    self:Status(self.message or "Select an ability to preview a macro.")
    self:UpdateEditor()
    if self.equipmentFrame and self.equipmentFrame:IsShown() then self:RefreshEquipmentUI() end
    if self.premadeFrame and self.premadeFrame:IsShown() then self:RefreshPremadeUI() end
end
function MF:CreateWindow()
    local f=CreateFrame("Frame","MacroForgeFrame",UIParent,"BasicFrameTemplateWithInset")
    self.frame=f; f:SetSize(780,680); f:SetPoint("CENTER"); f:SetClampedToScreen(true)
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart",function(self) self:StartMoving() end)
    f:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
    f:SetScript("OnHide",function() if MF.comboFrame then MF.comboFrame:Hide() end; if MF.premadeFrame then MF.premadeFrame:Hide() end; if MF.storedMacroFrame then MF.storedMacroFrame:Hide() end; if MF.editor then MF.editor:Hide() end; MF:UpdateShortcutGlow(); MF:OnClose() end)
    f:SetScript("OnShow",function() MF:UpdateShortcutGlow() end)
    f.TitleText:SetText("MacroForge — WoW Forever")
    table.insert(UISpecialFrames,"MacroForgeFrame")
    for i,label in ipairs({"Spellbook","Premade Macros","My Macros"}) do
        local index=i
        button(f,label,22+(i-1)*247,-40,237,function() MF.db.selectedTab=index; MF.page=1; MF:Refresh() end)
    end
    local search=CreateFrame("EditBox",nil,f,"InputBoxTemplate")
    self.search=search; search:SetSize(300,26); search:SetPoint("TOPLEFT",28,-84); search:SetAutoFocus(false)
    search:SetScript("OnTextChanged",function() MF.page=1; MF:Refresh() end)
    search:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    text(f,"Search",28,-69,100,"GameFontNormalSmall")
    local filter
    filter=self:Dropdown(f,350,-82,175,"Filter: all",function() return {{label="All abilities",value="all"},{label="Learned",value="learned"},{label="Unlearned",value="unlearned"}} end,function(value)
        MF.filter=value; filter:SetLabel("Filter: "..value); MF.page=1; MF:Refresh()
    end)
    button(f,"Refresh",579,-82,175,function() MF:Discover(); MF:Refresh() end)
    self.coverage=text(f,"",24,-121,730,"GameFontHighlightSmall")
    self.rows={}
    for i=1,12 do
        local row=CreateFrame("Button",nil,f)
        local column=math.floor((i-1)/6)
        local line=(i-1)%6
        row:SetSize(350,56); row:SetPoint("TOPLEFT",26+column*378,-164-line*56)
        row.icon=row:CreateTexture(nil,"ARTWORK"); row.icon:SetSize(44,44); row.icon:SetPoint("LEFT",0,0)
        row.label=text(row,"",56,-8,294,"GameFontNormal")
        row.detail=text(row,"",56,-31,294,"GameFontHighlightSmall")
        row.label:SetWordWrap(false); row.detail:SetWordWrap(false)
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight","ADD")
        row:SetScript("OnEnter",function(self)
            local entry=self.entry
            if not entry then return end
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT"); GameTooltip:SetText(entry.title)
            if entry.subtitle then GameTooltip:AddLine(entry.subtitle,0.8,0.8,0.8,true) end
            if entry.premade then GameTooltip:AddLine(entry.premade.note,1,1,1,true) end
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave",function() GameTooltip:Hide() end)
        row:SetScript("OnClick",function(self)
            local entry=self.entry
            if entry.spell then MF:SelectSpell(entry.spell)
            elseif entry.premade then MF:OpenPremadeUI(entry.premade)
            elseif entry.template then MF.template=entry.template; MF.db.preferences.template=entry.template; MF.db.selectedTab=1; MF.page=1; MF:Status("Template selected: "..MF.templates[entry.template].label); MF:Refresh()
            elseif entry.macro then MF:OpenStoredMacroUI(entry.macro) end
        end)
        self.rows[i]=row
    end
    button(f,"Previous",24,-516,110,function() MF.page=(MF.page or 1)-1; MF:Refresh() end)
    self.pageText=text(f,"",150,-524,270)
    button(f,"Next",440,-516,110,function() MF.page=(MF.page or 1)+1; MF:Refresh() end)
    button(f,"Open Macro Window",564,-516,190,function() MF:OpenNativeMacros() end)
    local _,class=UnitClass("player")
    if class=="WARRIOR" then button(f,"1H + shield equipment macro",24,-600,300,function() MF:OpenEquipmentUI() end) end
    self.statusText=text(f,"",24,-559,730,"GameFontHighlightSmall")
    local feedback=CreateFrame("Button",nil,f)
    self.feedbackFooter=feedback; feedback:SetSize(730,22); feedback:SetPoint("BOTTOMLEFT",24,12)
    feedback.label=feedback:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    feedback.label:SetAllPoints(); feedback.label:SetJustifyH("LEFT")
    feedback.label:SetText("Report bugs or suggest features on GitHub")
    feedback:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight","ADD")
    feedback:SetScript("OnClick",function() MF:OpenFeedbackUI() end)
    self.template=self.db.preferences.template
    if not self.templates[self.template or "plain"] then self.template="plain" end
    self:BuildEditor(); self:Refresh(); self:UpdateShortcutGlow()
end

function MF:RefreshComboUI()
    local c=self:ComboConfig()
    local druid=c.class=="DRUID"
    self.druidPreset:SetShown(druid)
    for _,key in ipairs(self.comboKeys) do
        local row=c[key] or {action="none"}
        local controls=self.comboControls[key]
        controls.action:SetLabel(row.action)
        local name="Choose spell"
        for _,s in ipairs(self:ComboChoices(row.action)) do if s.id==row.spellID then name=s.name end end
        controls.spell:SetLabel(row.action=="cancel" and "/cancelform" or row.action=="none" and "No action" or name)
        controls.spell:SetShown(row.action=="cast" or row.action=="form")
        local targets={target="Current target",focus="Focus",mouseover="Mouseover",mouseover_hostile="Mouseover (hostile)",player="Self"}
        controls.target:SetLabel(row.action=="form" and "Self (form)" or targets[row.target or "target"] or "Choose target")
        local rankLabel=(row.mode==nil or row.mode=="max") and "Max (rank-free)" or "Rank unavailable"
        for _,rank in ipairs(self:ComboRanks(row)) do if rank.mode==row.mode and rank.rankID==row.rankID then rankLabel=rank.label end end
        controls.rank:SetLabel(rankLabel); controls.rank:SetShown(row.action=="cast")
        controls.target:SetShown(row.action=="cast")
        controls.bang:SetChecked(row.noToggle==true); controls.bang:SetShown(row.action=="cast"); controls.bang.label:SetShown(row.action=="cast")
        if controls.formRule then self:RefreshRuleControls(controls.formRule,row.action~="none") end
    end
    self.comboToggle:SetText(self.comboEnabled and "Combo: ON" or "Combo: OFF")
    local body,err=self:ComboPreview(c,true)
    local _,blocked=self:ComboPreview(c)
    self.comboPreviewText:SetText(body or err)
    self.comboStatusText:SetText(blocked or "Draft preview. Return to the editor and click Generate to create.")
end
function MF:OpenComboUI()
    if not self.comboFrame then
        local f=CreateFrame("Frame","MacroForgeCombo",self.editor,"BasicFrameTemplateWithInset")
        local _,class=UnitClass("player"); local druid=class=="DRUID"; local hasRules=druid or class=="WARRIOR"; local extra=hasRules and 120 or 0
        self.comboFrame=f; f:SetSize(730,590+extra); f:SetPoint("CENTER"); f:SetFrameStrata("FULLSCREEN_DIALOG"); f:EnableMouse(true)
        f.TitleText:SetText("Modifier combo builder — select from dropdowns")
        table.insert(UISpecialFrames,"MacroForgeCombo")
        self.comboToggle=button(f,"Combo: OFF",20,-40,150,function() MF.comboEnabled=not MF.comboEnabled; MF:UpdateEditor() end)
        button(f,"Alt: focus preset",190,-40,210,function() local ok,err=MF:ComboPreset("focus"); if not ok then MF:Status(err) end; MF:UpdateEditor() end)
        self.druidPreset=button(f,"Druid forms preset",420,-40,280,function() local ok,err=MF:ComboPreset("druid"); if not ok then MF:Status(err); MF.comboPreviewText:SetText(err); return end; MF:UpdateEditor() end)
        text(f,"One action per press. Priority: Shift > Ctrl > Alt > normal. Unassigned modifiers do nothing.",20,-83,690,"GameFontHighlightSmall")
        self.comboControls={}
        for i,key in ipairs(self.comboKeys) do
            local rowKey=key
            local y=-118-(i-1)*(hasRules and 78 or 48)
            text(f,key,20,y-6,65,"GameFontNormal")
            local controls={}
            controls.action=self:Dropdown(f,90,y,95,"Select action",function()
                local list={{label="No action",value="none"},{label="Cast spell",value="cast"}}
                if druid then list[#list+1]={label="Enter form",value="form"}; list[#list+1]={label="Cancel form",value="cancel"} end
                return list
            end,function(value)
                local row=MF:ComboConfig()[rowKey]; row.action=value; row.target="target"; row.mode="max"; row.rankID=nil; row.formRule=nil
                row.spellID=nil; MF:UpdateEditor()
            end)
            controls.spell=self:Dropdown(f,195,y,200,"Select ability — search all learned spells",function()
                local row=MF:ComboConfig()[rowKey]; local list={}
                for _,s in ipairs(MF:ComboChoices(row.action)) do list[#list+1]={label=s.name,value=s.id} end
                return list
            end,function(value)
                local row=MF:ComboConfig()[rowKey]; row.spellID=value; row.mode="max"; row.rankID=nil; MF:UpdateEditor()
            end)
            controls.rank=self:Dropdown(f,405,y,145,"Select branch rank",function()
                local list={}
                for _,rank in ipairs(MF:ComboRanks(MF:ComboConfig()[rowKey])) do list[#list+1]={label=rank.label,value=rank} end
                return list
            end,function(value) local row=MF:ComboConfig()[rowKey]; row.mode=value.mode; row.rankID=value.rankID; MF:UpdateEditor() end)
            controls.target=self:Dropdown(f,560,y,140,"Select target",function()
                return {{label="Current target",value="target"},{label="Focus",value="focus"},{label="Mouseover",value="mouseover"},{label="Mouseover (hostile)",value="mouseover_hostile"},{label="Self",value="player"}}
            end,function(value) MF:ComboConfig()[rowKey].target=value; MF:UpdateEditor() end)
            controls.bang=CreateFrame("CheckButton",nil,f,"UICheckButtonTemplate")
            controls.bang:SetSize(24,24); controls.bang:SetPoint("TOPLEFT",20,y-28)
            controls.bang.label=text(f,"!",48,y-33,25)
            controls.bang:SetScript("OnEnter",function(self)
                GameTooltip:SetOwner(self,"ANCHOR_RIGHT"); GameTooltip:SetText("Keep active aura on (!)")
                GameTooltip:AddLine("Toggle protection, such as !Prowl. This is not a generic check for an existing aura.",1,1,1,true); GameTooltip:Show()
            end)
            controls.bang:SetScript("OnLeave",function() GameTooltip:Hide() end)
            controls.bang:SetScript("OnClick",function(self) MF:ComboConfig()[rowKey].noToggle=self:GetChecked()==true; MF:UpdateEditor() end)
            if hasRules then
                controls.formRule=self:BuildRuleControls(f,90,y-30,250,390,310,function()
                    local row=MF:ComboConfig()[rowKey]
                    if not row.formRule then row.formRule={enabled=false,kind=class=="WARRIOR" and "require" or "in",spellID=0} end
                    return row.formRule
                end)
            end
            self.comboControls[key]=controls
        end
        text(f,hasRules and "Requires Form/Stance switches to your choice before the ability. Press again after its global cooldown if needed." or "Each branch has its own rank and target. Focus has no fallback.",20,-351-extra,690,"GameFontHighlightSmall")
        self.comboPreviewText=preview(f,20,-379-extra,690,90)
        self.comboStatusText=text(f,"",20,-479-extra,690,"GameFontHighlightSmall")
        button(f,"Done — return to Generate",20,-538-extra,300,function() f:Hide(); MF:UpdateEditor() end)
        button(f,"Disable combo",420,-538-extra,280,function() MF.comboEnabled=false; f:Hide(); MF:UpdateEditor() end)
    end
    self.comboFrame:Show(); self:RefreshComboUI()
end
function MF:RefreshEquipmentUI()
    local c=self:EquipmentConfig()
    for _,kind in ipairs({"weapon","shield"}) do
        local name=kind=="weapon" and "Select one-handed main-hand weapon" or "Select shield"
        for _,item in ipairs(self:EquipmentItems(kind)) do if item.id==c[kind.."ID"] then name=item.name end end
        self.equipmentControls[kind]:SetLabel(name)
    end
    local body,err=self:EquipmentPreview(true)
    local valid,blocked=self:EquipmentPreview()
    local nameError=self:MacroNameError(self.equipmentNameBox:GetText())
    self.equipmentPreviewText:SetText(body or err)
    self.equipmentStatus:SetText(self:Combat() and "Creation disabled during combat." or nameError or blocked or "Equipment-only macro. Equipping may require additional presses before using an ability.")
    if valid and not nameError and not self:Combat() then self.equipmentGenerate:Enable() else self.equipmentGenerate:Disable() end
end
function MF:OpenEquipmentUI()
    local _,class=UnitClass("player")
    if class~="WARRIOR" then return end
    if self.premadeFrame then self.premadeFrame:Hide() end
    self.premadeSelection=nil
    if not self.equipmentFrame then
        local f=CreateFrame("Frame","MacroForgeEquipment",self.frame,"BasicFrameTemplateWithInset")
        self.equipmentFrame=f; f:SetSize(600,430); f:SetPoint("CENTER"); f:SetFrameStrata("FULLSCREEN_DIALOG"); f:EnableMouse(true)
        f.TitleText:SetText("Equipment macro — one-handed weapon + shield")
        table.insert(UISpecialFrames,"MacroForgeEquipment")
        self.equipmentControls={}
        for i,kind in ipairs({"weapon","shield"}) do
            local itemKind=kind
            self.equipmentControls[kind]=self:Dropdown(f,22,-42-(i-1)*40,550,"Select "..kind,function()
                local list={}
                for _,item in ipairs(MF:EquipmentItems(itemKind)) do list[#list+1]={label=item.name,value=item.id} end
                return list
            end,function(value) MF:EquipmentConfig()[itemKind.."ID"]=value; MF:RefreshEquipmentUI() end)
        end
        text(f,"Macro name",22,-131,120)
        local name=CreateFrame("EditBox",nil,f,"InputBoxTemplate")
        self.equipmentNameBox=name; name:SetSize(350,26); name:SetPoint("TOPLEFT",160,-124); name:SetAutoFocus(false); name:SetText("EWS")
        name:SetScript("OnTextChanged",function() if MF.equipmentGenerate then MF:RefreshEquipmentUI() end end)
        self.equipmentPreviewText=text(f,"",22,-170,550)
        text(f,"Equipment-only macro. Click Generate to create it, then use it from your action bar.",22,-255,550,"GameFontHighlightSmall")
        self.equipmentStatus=text(f,"",22,-300,550,"GameFontHighlightSmall")
        self.equipmentGenerate=button(f,"Generate equipment macro",22,-375,290,function()
            MF.equipmentOnly=true; MF.nameBox:SetText(MF.equipmentNameBox:GetText())
            local ok,message=MF:Generate(); MF.equipmentStatus:SetText(message); MF:Status(message)
            if ok then MF:Refresh() end
        end)
        button(f,"Close",340,-375,230,function() f:Hide() end)
        f:SetScript("OnHide",function() MF.equipmentOnly=false; MF:UpdateEditor() end)
    end
    self.equipmentOnly=true; self.equipmentFrame:Show(); self:RefreshEquipmentUI()
end
function MF:RefreshPremadeUI()
    local entry=self.premadeSelection
    if not entry then return end
    local body,draftError=self:PremadePreview(entry,true)
    local valid,blocked=self:PremadePreview(entry)
    local nameError=self:MacroNameError(self.premadeNameBox:GetText())
    self.premadeFrame.TitleText:SetText("Premade: "..entry.label)
    self.premadeDescription:SetText(entry.note.."\n"..entry.client)
    self.premadePreviewText:SetText(body or draftError)
    self.premadeSource:SetText(entry.source)
    self.premadeVersion:SetText("Source reviewed "..entry.reviewed..". Original MacroForge implementation. Spells resolve to client-localized, rank-free names.")
    self.premadeStatus:SetText(self.premadeMessage or (self:Combat() and "Creation disabled during combat." or nameError or blocked or "Preview only. Source review is not in-game verification. Click Generate to create."))
    if valid and not nameError and not self:Combat() then self.premadeGenerate:Enable() else self.premadeGenerate:Disable() end
end
function MF:OpenPremadeUI(entry)
    if self.comboFrame then self.comboFrame:Hide() end
    if self.editor then self.editor:Hide() end
    if self.equipmentFrame then self.equipmentFrame:Hide() end
    self.equipmentOnly=false; self.comboEnabled=false
    if not self.premadeFrame then
        local f=CreateFrame("Frame","MacroForgePremade",self.frame,"BasicFrameTemplateWithInset")
        self.premadeFrame=f; f:SetSize(740,610); f:SetPoint("CENTER"); f:SetClampedToScreen(true); f:SetFrameStrata("FULLSCREEN_DIALOG"); f:EnableMouse(true)
        table.insert(UISpecialFrames,"MacroForgePremade")
        self.premadeDescription=text(f,"",22,-45,690)
        text(f,"Macro name",22,-111,120,"GameFontNormal")
        local name=CreateFrame("EditBox",nil,f,"InputBoxTemplate")
        self.premadeNameBox=name; name:SetSize(400,26); name:SetPoint("TOPLEFT",170,-104); name:SetAutoFocus(false)
        name:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
        name:SetScript("OnTextChanged",function() if MF.premadeGenerate then MF.premadeMessage=nil; MF:RefreshPremadeUI() end end)
        text(f,"Generated preview — mouse wheel to scroll",22,-149,690,"GameFontNormal")
        self.premadePreviewText=preview(f,22,-177,690,190)
        text(f,"Source — select to copy",22,-389,690,"GameFontNormal")
        local source=CreateFrame("EditBox",nil,f,"InputBoxTemplate")
        self.premadeSource=source; source:SetSize(680,26); source:SetPoint("TOPLEFT",28,-413); source:SetAutoFocus(false)
        source:SetScript("OnEditFocusGained",function(self) self:HighlightText() end)
        source:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
        self.premadeVersion=text(f,"",22,-451,690,"GameFontHighlightSmall")
        self.premadeStatus=text(f,"",22,-485,690,"GameFontHighlightSmall")
        self.premadeGenerate=button(f,"Generate",22,-557,200,function()
            MF.nameBox:SetText(MF.premadeNameBox:GetText())
            local ok,message=MF:Generate(); MF.premadeMessage=message; MF:Status(message)
            MF:RefreshPremadeUI()
        end)
        button(f,"Open Macro Window",270,-557,200,function() MF:OpenNativeMacros() end)
        button(f,"Cancel",518,-557,200,function() f:Hide() end)
        f:SetScript("OnHide",function() MF.premadeSelection=nil; MF.premadeMessage=nil end)
    end
    self.premadeSelection=entry; self.premadeMessage=nil
    self.premadeNameBox:SetText(self:MacroInitials(entry.label))
    self.premadeFrame:Show(); self:RefreshPremadeUI()
end
function MF:OpenStoredMacroUI(macro)
    if self.comboFrame then self.comboFrame:Hide() end
    if self.editor then self.editor:Hide() end
    if self.premadeFrame then self.premadeFrame:Hide() end
    if self.equipmentFrame then self.equipmentFrame:Hide() end
    if not self.storedMacroFrame then
        local f=CreateFrame("Frame","MacroForgeStoredMacro",self.frame,"BasicFrameTemplateWithInset")
        self.storedMacroFrame=f; f:SetSize(600,410); f:SetPoint("CENTER"); f:SetClampedToScreen(true); f:SetFrameStrata("FULLSCREEN_DIALOG"); f:EnableMouse(true)
        table.insert(UISpecialFrames,"MacroForgeStoredMacro")
        self.storedMacroLocation=text(f,"",22,-45,550,"GameFontNormal")
        self.storedMacroBody=preview(f,22,-82,550,215)
        text(f,"Read-only snapshot. Reopen from My Macros after native edits. Mouse wheel scrolls the text.",22,-315,550,"GameFontHighlightSmall")
        button(f,"Open Macro Window",22,-358,260,function() MF:OpenNativeMacros() end)
        button(f,"Close",310,-358,260,function() f:Hide() end)
    end
    self.storedMacroFrame.TitleText:SetText(macro.name)
    self.storedMacroLocation:SetText(macro.location=="Character" and "Storage: this character" or "Storage: general macros (shared)")
    self.storedMacroBody:SetText(macro.body or "")
    self.storedMacroFrame:Show()
end
function MF:OpenFeedbackUI()
    if not self.feedbackFrame then
        local f=CreateFrame("Frame","MacroForgeFeedback",self.frame,"BasicFrameTemplateWithInset")
        self.feedbackFrame=f; f:SetSize(570,190); f:SetPoint("CENTER"); f:SetClampedToScreen(true); f:SetFrameStrata("FULLSCREEN_DIALOG"); f:EnableMouse(true)
        f.TitleText:SetText("MacroForge — report bugs or suggest features")
        table.insert(UISpecialFrames,"MacroForgeFeedback")
        self.feedbackDescription=text(f,"",22,-46,525)
        local link=CreateFrame("EditBox",nil,f,"InputBoxTemplate")
        self.feedbackLink=link; link:SetSize(510,26); link:SetPoint("TOPLEFT",28,-92); link:SetAutoFocus(false)
        link:SetScript("OnEditFocusGained",function(self) self:HighlightText() end)
        link:SetScript("OnEscapePressed",function() f:Hide() end)
        button(f,"Close",22,-145,525,function() f:Hide() end)
    end
    self.feedbackDescription:SetText(self.feedbackURL and "Copy this link into your browser to report a bug or suggest a feature." or "The GitHub repository link has not been configured yet.")
    self.feedbackLink:SetText(self.feedbackURL or "")
    self.feedbackFrame:Show()
    if self.feedbackURL then self.feedbackLink:SetFocus(); self.feedbackLink:HighlightText() end
end
function MF:Toggle()
    if not self.db then return end
    if not self.frame then self:Discover(); self:CreateWindow(); return end
    if self.frame:IsShown() then self.frame:Hide() else self:Discover(); self.frame:Show(); self:Refresh() end
end
