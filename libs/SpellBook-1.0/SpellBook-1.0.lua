local MAJOR_VERSION = "SpellBook-1.0"
local MINOR_VERSION = "$Revision: 4 $"
local ManaTip = CreateFrame("GameTooltip", "ManaTip", nil, "GameTooltipTemplate")
ManaTip:SetOwner(WorldFrame, "ANCHOR_NONE")
local SpellBook = {}

------------------------------------------------
-- activate, enable, disable
-- Borrowed from HealComm-1.0.lua
------------------------------------------------

local function activate(self, oldLib, oldDeactivate)
	SpellBook = self
	if oldLib then
		self.Spells = oldLib.Spells
		oldLib:UnregisterAllEvents()
		oldLib:CancelAllScheduledEvents()
	end
	self.Mana = 0
	if not self.Spells then
		self:UpdateSpellsList()
	end
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

function SpellBook:Enable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end

function SpellBook:Disable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end


function SpellBook:UpdateSpellsList()
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


function SpellBook:CastSpell(spellId, spellbookTabNum)
	ManaTip:ClearLines()
	ManaTip:SetSpell(spellId, spellbookTabNum)
	self.hooks.CastSpell(spellId, spellbookTabNum)
end

function SpellBook:CastSpellByName(spellName, onSelf)
	ManaTip:ClearLines()
	
	-- Fix the issue of swapping characters and Spell List not updating
	if not self.Spells then
		self:UpdateSpellsList()
	end
	
	if self.Spells[spellName] then
		ManaTip:SetSpell(self.Spells[spellName].id, "spell")
	else
		local _,_,rank = string.find(spellName,"%(Rank (%d+)%)")
		local _,_,name = string.find(spellName,"([%w%s]+)") 
		-- Doesn't include spells with special characters
		-- TODO: Include spells with apostrophes and parenthesis ' or ) or (
		-- TODO: Confirm there aren't any other special characters, or add them if there are some
		
		if self.Spells[name] then
			-- Test to see if the spell list is still accurate
			local tempName, tempRank = GetSpellName(self.Spells[name].id, "spell")
			_,_,tempRank = string.find(tempRank,"Rank (%d+)")
			if tempName ~= name or tempRank ~= self.Spells[name].rank then
				self:UpdateSpellsList()
			end
		
			local idVal = rank - self.Spells[name].rank
			tempName, tempRank = GetSpellName(self.Spells[name].id + idVal, "spell")
			_,_,tempRank = string.find(tempRank,"Rank (%d+)")
			if tempName == name and tempRank == rank then
				ManaTip:SetSpell(self.Spells[name].id + idVal, "spell")
			end
		end
	end
	
	self.hooks.CastSpellByName(spellName, onSelf)
end

function SpellBook:UseAction(slot, checkCursor, onSelf)
	ManaTip:ClearLines()
	ManaTip:SetAction(slot)
	self.hooks.UseAction(slot, checkCursor, onSelf)
end


function SpellBook:SPELLCAST_START()
	local tooltip_name = ManaTipTextLeft1:GetText()
	local manaVal = 0
	if ManaTipTextLeft2:GetText() then
		_,_,manaVal = string.find(ManaTipTextLeft2:GetText(),"(%d+) Mana")
	end
	if arg1 == tooltip_name and manaVal then
		self.Mana = manaVal
	end
	self:TriggerEvent("SpellBook_SpellUpdate")
end

function SpellBook:SPELLCAST_STOP()
	self.Mana = 0
	self:TriggerEvent("SpellBook_SpellUpdate")
end

AceLibrary:Register(SpellBook, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
SpellBook = nil