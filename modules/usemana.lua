local UseManaModule = {}
local UseManaAce = {}
LunaUF:RegisterModule(UseManaModule, "usemana", LunaUF.L["UseMana"]) 

local MAJOR_VERSION = "UseMana-1.0"
local MINOR_VERSION = "$Revision: 0001 $"
local UseManaTip = CreateFrame("GameTooltip", "UseManaTip", nil, "GameTooltipTemplate")
UseManaTip:SetOwner(WorldFrame, "ANCHOR_NONE")
local HealComm = LunaUF.HealComm
local PlayerFrame = nil


------------------------------------------------
-- activate, enable, disable
-- Borrowed from HealComm-1.0.lua
------------------------------------------------

local function activate(self, oldLib, oldDeactivate)
	UseManaAce = self
	if oldLib then
		self.Spells = oldLib.Spells
		self.Mana = oldLib.Mana
		oldLib:UnregisterAllEvents()
		oldLib:CancelAllScheduledEvents()
	end
	if not self.Mana then
		self.Mana = 0
	end
	if not self.Spells then
		self:UpdateSpellsList()
	end
	self.UseManaModule = UseManaModule
	if oldDeactivate then oldDeactivate(oldLib) end
end


local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		local AceEvent = instance
		AceEvent:embed(self)
		self:RegisterEvent("SPELLCAST_START")
		self:RegisterEvent("SPELLCAST_STOP")
		self:RegisterEvent("SPELLCAST_FAILED", "SPELLCAST_STOP")
		self:RegisterEvent("SPELLCAST_INTERRUPTED", "SPELLCAST_STOP")
	end
	if major == "AceHook-2.1" then
		local AceHook = instance
		AceHook:embed(self)
		self:Hook("CastSpell")
		self:Hook("CastSpellByName")
		self:Hook("UseAction")
	end
end

function UseManaAce:Enable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end

function UseManaAce:Disable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end

function UseManaAce:UpdateSpellsList()
	self.Spells = {}
	local index = 1
	local name, lvl = GetSpellName(index,"spell")
	
	-- if spell book hasn't been initialized yet, keep it nil to update when possible
	if not name then self.Spells = nil end
	
	while name do
		_,_,lvl = string.find(lvl,"Rank (%d+)")
		self.Spells[name] = {id=index,rank=lvl}
		index = index + 1
		name, lvl = GetSpellName(index,"spell")
	end
end



function UseManaAce:CastSpell(spellId, spellbookTabNum)
	UseManaTip:ClearLines()
	UseManaTip:SetSpell(spellId, spellbookTabNum)
	self.hooks.CastSpell(spellId, spellbookTabNum)
	
end

function UseManaAce:CastSpellByName(spellName, onSelf)
	UseManaTip:ClearLines()
	
	-- Fix the issue of swapping characters and Spell List not updating
	if not self.Spells then
		self:UpdateSpellsList()
	end
	
	if self.Spells[spellName] then
		UseManaTip:SetSpell(self.Spells[spellName].id, "spell")
	else
		local _,_,rank = string.find(spellName,"%(Rank (%d+)%)")
		local _,_,name = string.find(spellName,"([%w%s]+)")
		
		if self.Spells[name] then
			-- Test to see if this spell is still accurate
			local tempName, tempRank = GetSpellName(self.Spells[name].id, "spell")
			_,_,tempRank = string.find(tempRank,"Rank (%d+)")
			if tempName ~= name or tempRank ~= self.Spells[name].rank then
				self:UpdateSpellsList()
			end
		
			local idVal = rank - self.Spells[name].rank
			tempName, tempRank = GetSpellName(self.Spells[name].id + idVal, "spell")
			_,_,tempRank = string.find(tempRank,"Rank (%d+)")
			if tempName == name and tempRank == rank then
				UseManaTip:SetSpell(self.Spells[name].id + idVal, "spell")
			end
		end
	end
	
	self.hooks.CastSpellByName(spellName, onSelf)
end

function UseManaAce:UseAction(slot, checkCursor, onSelf)
	UseManaTip:ClearLines()
	UseManaTip:SetAction(slot)
	local spellName = UseManaTipTextLeft1:GetText()
	
	self.hooks.UseAction(slot, checkCursor, onSelf)
end

function UseManaAce:SPELLCAST_START()
	local tooltip_name = UseManaTipTextLeft1:GetText()
	local manaVal = 0
	if UseManaTipTextLeft2:GetText() then
		_,_,manaVal = string.find(UseManaTipTextLeft2:GetText(),"(%d+) Mana")
	end
	if arg1 == tooltip_name and manaVal then
		UseManaModule.Mana = manaVal
	end
	if PlayerFrame then
		UseManaModule:FullUpdate(PlayerFrame)
	end
end

function UseManaAce:SPELLCAST_STOP()
	UseManaModule.Mana = 0
	if PlayerFrame then
		UseManaModule:FullUpdate(PlayerFrame)
	end
end

AceLibrary:Register(UseManaAce, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)

------------------------------------------------
-- LunaFrames Module Code
------------------------------------------------

function UseManaModule:OnEnable(frame)
	if not self.UseManaAce then
		self.UseManaAce = UseManaAce
	end
	if frame.unit == "player" then 
		PlayerFrame = frame
		if not frame.usemana then
			frame.usemana = CreateFrame("Frame", nil, frame.powerBar)
		end
		if not frame.usemana.manaBar then
			frame.usemana.manaBar = CreateFrame("StatusBar", nil, frame.powerBar)
			frame.usemana.manaBar:SetMinMaxValues(0,1)
			frame.usemana.manaBar:SetValue(1)
		end
		
		-- Some Jankiness to get the prediction above the bar, but below the text and ticker
		frame.powerBar.ticker:SetFrameLevel(7)
		for align,fontstring in pairs(frame.fontstrings["powerBar"]) do
			fontstring:SetParent(frame.usemana)
		end
		
		UseManaModule.Mana = 0
	end
end

function UseManaModule:OnDisable(frame)
	if frame.usemana then
		frame.usemana.manaBar:Hide()
	end
end

function UseManaModule:FullUpdate(frame)
	if not LunaUF.db.profile.units.player.usemana.enabled then return end

	if healcommTipTextLeft2 and UseManaTipTextLeft2:GetText() then
		local _,_,manaVal = string.find(UseManaTipTextLeft2:GetText(),"(%d+) Mana")
	end
	local manavalue = UseManaModule.Mana
	local manaBar = frame.usemana.manaBar
	if not manavalue or manavalue == 0 then
		manaBar:Hide()
		return
	end
	
	local currMana, maxMana = UnitMana(frame.unit), UnitManaMax(frame.unit)
	local barHeight, barWidth = frame.powerBar:GetHeight(), frame.powerBar:GetWidth()
	local manaHeight = barHeight * (currMana / maxMana)
	local manaWidth = barWidth * (currMana / maxMana)
	
	manaBar:Show()
	manaBar:ClearAllPoints()
	
	if LunaUF.db.profile.units[frame.unitGroup].powerBar.vertical then
	
		local useHeight = barHeight * (manavalue / maxMana)
		manaBar:SetHeight(useHeight)
		manaBar:SetWidth(barWidth)
		manaBar:SetPoint("BOTTOMLEFT", frame.powerBar, "BOTTOMLEFT", 0, manaHeight - useHeight)
		
	else
	
		local useWidth = barWidth * (manavalue / maxMana)
		manaBar:SetWidth(useWidth)
		manaBar:SetHeight(barHeight)
		manaBar:SetPoint("TOPLEFT", frame.powerBar, "TOPLEFT", manaWidth - useWidth, 0)
		
	end
end

function UseManaModule:SetBarTexture(frame,texture)
	frame.usemana.manaBar:SetStatusBarTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	
	frame.usemana.manaBar:SetStatusBarColor(LunaUF.db.profile.powerColors.MANAUSAGE.r, LunaUF.db.profile.powerColors.MANAUSAGE.g, LunaUF.db.profile.powerColors.MANAUSAGE.b, 0.75)
end
