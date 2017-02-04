--[[
Name: FiveSecLib-1.0
Revision: $Rev: 10120 $
Author(s): aviana
Website: https://github.com/Aviana
Description: A library to provide feedback about the five second rule for casters.
Dependencies: AceLibrary, AceEvent-2.0
]]

local MAJOR_VERSION = "FiveSecLib-1.0"
local MINOR_VERSION = "$Revision: 10120 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end
if not AceLibrary:HasInstance("Babble-Spell-2.2") then error(MAJOR_VERSION .. " requires Babble-Spell-2.2") end
if not AceLibrary:HasInstance("AceHook-2.1") then error(MAJOR_VERSION .. " requires AceHook-2.1") end

local BS = AceLibrary("Babble-Spell-2.2")

local FiveSecLib = {}

------------------------------------------------
-- activate, enable, disable
------------------------------------------------

local function activate(self, oldLib, oldDeactivate)
	FiveSecLib = self
	if oldLib then
		oldLib:UnregisterAllEvents()
		oldLib:CancelAllScheduledEvents()
	end
	if oldDeactivate then oldDeactivate(oldLib) end
end


local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		local AceEvent = instance
		AceEvent:embed(self)
		self:RegisterEvent("SPELLCAST_INTERRUPTED", "SPELLCAST_FAILED")
		self:RegisterEvent("SPELLCAST_FAILED")
		self:RegisterEvent("SPELLCAST_STOP")
		self:TriggerEvent("FiveSecLib_Enabled")
	end
	if major == "AceHook-2.1" then
		local AceHook = instance
		AceHook:embed(self)
		self:Hook("CastSpell")
		self:Hook("CastSpellByName")
		self:Hook("UseAction")
		self:Hook("SpellStopTargeting")
		self:Hook("CastShapeshiftForm")
	end
end

function FiveSecLib:Enable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end


function FiveSecLib:Disable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end

------------------------------------------------
-- Addon Code
------------------------------------------------

local FiveSecLibTip = CreateFrame("GameTooltip", "FiveSecLibTip", nil, "GameTooltipTemplate")
FiveSecLibTip:SetOwner(WorldFrame, "ANCHOR_NONE")

function FiveSecLib:triggerFSR(spellName)
	self.Spell = nil
	local i = 1
	while GetSpellName(i, BOOKTYPE_SPELL) do
		local s, r = GetSpellName(i, BOOKTYPE_SPELL)
		if s == spellName then
			FiveSecLibTip:ClearLines()
			FiveSecLibTip:SetSpell(i, BOOKTYPE_SPELL)
			local mana = FiveSecLibTipTextLeft2:GetText()
			if mana and string.find(mana,"(%d+) Mana") then
				self:TriggerEvent("fiveSec")
			end
			return
		end
		i = i+1
	end
end

function FiveSecLib:SPELLCAST_FAILED()
	if self.Spell then
		if self.Spell ~= BS["Raptor Strike"] then
			self:CancelScheduledEvent("Trigger_fiveSec")
			self.Spell = nil
		end
	end
end

function FiveSecLib:SPELLCAST_STOP()
	if self.Spell then
	--	triggerFSR(self.Spell)
		self:ScheduleEvent("Trigger_fiveSec", self.triggerFSR, 0.3, self, self.Spell)
	end
end

function FiveSecLib:CastSpell(spellId, spellbookTabNum)
	-- Call the original function so there's no delay while we process
	self.hooks.CastSpell(spellId, spellbookTabNum)
	self.Spell = GetSpellName(spellId, spellbookTabNum)
end

function FiveSecLib:CastSpellByName(spell, onSelf)
	-- Call the original function
	self.hooks.CastSpellByName(spell, onSelf)
	local _, _, spellName = string.find(spell, "^([^%(]+)")
	if ( spellName ) then
		self.Spell = spellName
	end
end

function FiveSecLib:UseAction(slot, checkCursor, onSelf)
	local spellName
	if not GetActionText(slot) then
		FiveSecLibTip:ClearLines()
		FiveSecLibTip:SetAction(slot)
		spellName = FiveSecLibTipTextLeft1:GetText()
	end
	-- Call the original function
	self.hooks.UseAction(slot, checkCursor, onSelf)
	-- Test to see if this is a macro
	if GetActionText(slot) then
		return
	end
	self.Spell = spellName
end

function FiveSecLib:SpellStopTargeting()
	self.hooks.SpellStopTargeting()
	self.Spell = nil
end

function FiveSecLib:CastShapeshiftForm(id)
	self.hooks.CastShapeshiftForm(id)
	FiveSecLibTip:ClearLines()
	FiveSecLibTip:SetShapeshift(id)
	self.Spell = FiveSecLibTipTextLeft1:GetText()
end

AceLibrary:Register(FiveSecLib, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
FiveSecLib = nil