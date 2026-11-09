local _,MF=...
function MF:Discover(event)
    if self:Combat() then return end
    local _,class=UnitClass("player")
    if not class then return end
    if type(self.db.catalog[class])~="table" then self.db.catalog[class]={} end
    local cache,found=self.db.catalog[class],{}
    local function add(id,known,source,rankHint,passiveHint)
        if type(id)~="number" or id<=0 then return end
        local name,rank,icon=MF:SpellInfo(id)
        if not name then return end
        rank=rank~="" and rank or rankHint or ""
        local previous=found[id]
        local passive=passiveHint
        if passive==nil then passive=MF:Call(C_Spell and C_Spell.IsSpellPassive,id) end
        if passive==nil then passive=previous and previous.passive or cache[id] and cache[id].passive or false end
        found[id]={id=id,name=name,rank=rank,rankNum=tonumber(string.match(rank,"(%d+)")),icon=icon or 134400,
            known=known==true or MF:IsKnown(id) or (previous and previous.known) or false,source=source,
            passive=passive==true}
        cache[id]={id=id,name=name,rank=rank,icon=icon,source=source,passive=passive==true}
    end
    for id in pairs(cache) do add(id,nil,"Previously discovered") end
    local book=C_SpellBook
    if book and book.GetNumSpellBookSkillLines and book.GetSpellBookSkillLineInfo and book.GetSpellBookItemInfo then
        local bank=Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or 0
        local types=Enum and Enum.SpellBookItemType or {}
        for line=1,self:Call(book.GetNumSpellBookSkillLines) or 0 do
            local info=self:Call(book.GetSpellBookSkillLineInfo,line)
            if info then
                for slot=(info.itemIndexOffset or 0)+1,(info.itemIndexOffset or 0)+(info.numSpellBookItems or 0) do
                    local item=self:Call(book.GetSpellBookItemInfo,slot,bank)
                    if item and (item.itemType==(types.Spell or 1) or item.itemType==(types.FutureSpell or 2)) then
                        local passive=self:Call(book.IsSpellBookItemPassive,slot,bank)
                        if passive==nil then passive=item.isPassive end
                        add(item.spellID or item.actionID,item.itemType==(types.Spell or 1) and not item.isOffSpec,"Spellbook",item.subName,passive)
                    elseif item and item.itemType==(types.Flyout or 3) and GetFlyoutInfo and GetFlyoutSlotInfo then
                        local _,_,slots=self:Call(GetFlyoutInfo,item.actionID)
                        for i=1,slots or 0 do local id,override,known=self:Call(GetFlyoutSlotInfo,item.actionID,i); add(override or id,known,"Flyout") end
                    end
                end
            end
        end
        self.discovery="Spellbook + exposed future spells; catalog completeness unverified"
        local cap=self:Call(GetMaxPlayerLevel)
        if type(cap)=="number" and cap>0 and cap<=1000 and book.GetCurrentLevelSpells then
            for level=1,cap do
                local ids=self:Call(book.GetCurrentLevelSpells,level)
                if type(ids)=="table" then for _,id in ipairs(ids) do add(id,nil,"Level spell API") end end
            end
        end
    elseif GetNumSpellTabs and GetSpellTabInfo and GetSpellBookItemInfo then
        for tab=1,GetNumSpellTabs() do
            local _,_,offset,count=GetSpellTabInfo(tab)
            for slot=offset+1,offset+count do
                local kind,id=GetSpellBookItemInfo(slot,BOOKTYPE_SPELL or "spell")
                if kind=="SPELL" then add(id,true,"Legacy spellbook",nil,self:Call(IsPassiveSpell,slot,BOOKTYPE_SPELL or "spell")) end
            end
        end
        self.discovery="Legacy spellbook; unlearned spells require trainer discovery"
    else self.discovery="No supported spellbook API detected" end
    if event=="TRAINER_SHOW" or event=="TRAINER_UPDATE" then
        for i=1,self:Call(GetNumTrainerServices) or 0 do
            local link=self:Call(GetTrainerServiceItemLink,i)
            add(link and tonumber(string.match(link,"spell:(%d+)")),nil,"Visited trainer")
        end
    end
    self.catalog={}
    for _,spell in pairs(found) do if not spell.passive then self.catalog[#self.catalog+1]=spell end end
    table.sort(self.catalog,function(a,b) if a.name==b.name then return (a.rankNum or 0)<(b.rankNum or 0) end return a.name<b.name end)
end
