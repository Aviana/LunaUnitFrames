--[[
Name: FiveSecLib-1.0
Revision: $Rev: 10141 $
Author(s): aviana
Website: https://github.com/Aviana
Description: A library to provide feedback about the five second rule for casters.
Dependencies: AceLibrary, AceEvent-2.0
]]

local MAJOR_VERSION = "FiveSecLib-1.0"
local MINOR_VERSION = "$Revision: 10141 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end
if not AceLibrary:HasInstance("AceHook-2.1") then error(MAJOR_VERSION .. " requires AceHook-2.1") end

local FiveSecLib = {}

local L = {}
if( GetLocale() == "deDE" ) then
	L["(%d+) Mana"] = "(%d+) Mana"
	L["Raptor Strike"] = "Raptorstoß"
elseif ( GetLocale() == "frFR" ) then
	L["(%d+) Mana"] = "(%d+) Mana"
	L["Raptor Strike"] = "Attaque du raptor"
elseif GetLocale() == "zhCN" then
	L["(%d+) Mana"] = "(%d+) 法力"
	L["Raptor Strike"] = "猛禽一击"
elseif GetLocale() == "ruRU" then
	L["(%d+) Mana"] = "(%d+) Мана"
	L["Raptor Strike"] = "Удар ящера"
else
	L["(%d+) Mana"] = "(%d+) Mana"
	L["Raptor Strike"] = "Raptor Strike"
end

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

function FiveSecLib:triggerFSR()
	self:TriggerEvent("fiveSec")
	self.prevSpell = nil
end

function FiveSecLib:SPELLCAST_FAILED()
	if self.prevSpell ~= L["Raptor Strike"] then
		self:CancelScheduledEvent("Trigger_fiveSec")
		self.Spell = nil
		self.Mana = nil
	end
end

function FiveSecLib:SPELLCAST_STOP()
	if self.Spell and self.Mana then
		self:ScheduleEvent("Trigger_fiveSec", self.triggerFSR, 0.1, self)
		self.prevSpell = self.Spell
	end
	self.Spell = nil
	self.Mana = nil
end

function FiveSecLib:CastSpell(spellId, spellbookTabNum)
	-- Call the original function so there's no delay while we process
	self.hooks.CastSpell(spellId, spellbookTabNum)
	if self.Spell then return end
	FiveSecLibTip:ClearLines()
	FiveSecLibTip:SetSpell(spellId, spellbookTabNum)
	local mana = FiveSecLibTipTextLeft2:GetText()
	_,_,self.Mana = string.find((mana or "") or "",L["(%d+) Mana"])
	self.Spell = GetSpellName(spellId, spellbookTabNum)
end

function FiveSecLib:CastSpellByName(spell, onSelf)
	-- Call the original function
	self.hooks.CastSpellByName(spell, onSelf)
	local _, _, spellName = string.find(spell, "^([^%(]+)")
	spellName = string.lower(spellName)
	local i = 1
	while GetSpellName(i, BOOKTYPE_SPELL) do
		local s = GetSpellName(i, BOOKTYPE_SPELL)
		if string.lower(s) == spellName then
			self.Spell = GetSpellName(i, BOOKTYPE_SPELL)
			FiveSecLibTip:ClearLines()
			FiveSecLibTip:SetSpell(i, BOOKTYPE_SPELL)
			local mana = FiveSecLibTipTextLeft2:GetText()
			_,_,self.Mana = string.find((mana or ""),L["(%d+) Mana"])
			break
		end
		i = i+1
	end
end

function FiveSecLib:UseAction(slot, checkCursor, onSelf)
	if not GetActionText(slot) and not self.Spell then
		FiveSecLibTip:ClearLines()
		FiveSecLibTip:SetAction(slot)
		self.Spell = FiveSecLibTipTextLeft1:GetText()
		local mana = FiveSecLibTipTextLeft2:GetText()
		_,_,self.Mana = string.find((mana or ""),L["(%d+) Mana"])
	end
	-- Call the original function
	self.hooks.UseAction(slot, checkCursor, onSelf)
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