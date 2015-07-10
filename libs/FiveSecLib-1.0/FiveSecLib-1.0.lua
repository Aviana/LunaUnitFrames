--[[
Name: FiveSecLib-1.0
Revision: $Rev: 10000 $
Author(s): aviana
Website: https://github.com/Aviana
Description: A library to provide feedback about the five second rule for casters.
Dependencies: AceLibrary, AceEvent-2.0
]]

local MAJOR_VERSION = "FiveSecLib-1.0"
local MINOR_VERSION = "$Revision: 10000 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end

local FiveSecLib = CreateFrame("Frame")

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
		FiveSecLib.EventScheduler = instance
		FiveSecLib.EventScheduler:embed(self)
		self:UnregisterAllEvents()
		self:CancelAllScheduledEvents()
		if FiveSecLib.EventScheduler:IsFullyInitialized() then
			self:AceEvent_FullyInitialized()
		else
			self:RegisterEvent("AceEvent_FullyInitialized", "AceEvent_FullyInitialized", true)
		end		
	end
end

function FiveSecLib:Enable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end


function FiveSecLib:Disable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end

------------------------------------------------
-- Internal functions
------------------------------------------------

function FiveSecLib:AceEvent_FullyInitialized()
	self:RegisterEvent("SPELLCAST_INTERRUPTED", FiveSecLib.OnEvent)
	self:RegisterEvent("SPELLCAST_FAILED", FiveSecLib.OnEvent)
	self:RegisterEvent("SPELLCAST_STOP", FiveSecLib.OnEvent)
	self:TriggerEvent("FiveSecLib_Enabled")
end

------------------------------------------------
-- Addon Code
------------------------------------------------

local FiveSecLib_Spell = nil

local FiveSecLibTip = CreateFrame("GameTooltip", "FiveSecLibTip", nil, "GameTooltipTemplate")
FiveSecLibTip:SetOwner(WorldFrame, "ANCHOR_NONE")

local function triggerFSR(spellName)
	FiveSecLib_Spell = nil
	local i = 1
	while GetSpellName(i, BOOKTYPE_SPELL) do
		local s, r = GetSpellName(i, BOOKTYPE_SPELL)
		if s == spellName then
			FiveSecLibTip:ClearLines()
			FiveSecLibTip:SetSpell(i, BOOKTYPE_SPELL)
			local mana = FiveSecLibTipTextLeft2:GetText()
			if mana and string.find(mana,"(%d+) Mana") then
				FiveSecLib.EventScheduler:TriggerEvent("fiveSec")
			end
			return
		end
		i = i+1
	end
end

FiveSecLib.OnEvent = function()
	if (event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED") and FiveSecLib_Spell then
		if FiveSecLib_Spell ~= "Raptor Strike" then
			FiveSecLib.EventScheduler:CancelScheduledEvent("Trigger_fiveSec")
			FiveSecLib_Spell = nil
		end
	elseif event == "SPELLCAST_STOP" and FiveSecLib_Spell then
	--	triggerFSR(FiveSecLib_Spell)
		FiveSecLib.EventScheduler:ScheduleEvent("Trigger_fiveSec", triggerFSR, 0.2, FiveSecLib_Spell)
	end
end

local FiveSecLib_oldCastSpell = CastSpell
local function FiveSecLib_newCastSpell(spellId, spellbookTabNum)
	-- Call the original function so there's no delay while we process
	FiveSecLib_oldCastSpell(spellId, spellbookTabNum)
	FiveSecLib_Spell = GetSpellName(spellId, spellbookTabNum)
end
CastSpell = FiveSecLib_newCastSpell

local FiveSecLib_oldCastSpellByName = CastSpellByName
local function FiveSecLib_newCastSpellByName(spellName, onSelf)
	-- Call the original function
	FiveSecLib_oldCastSpellByName(spellName, onSelf)
	local _, _, spellName = string.find(spellName, "^([^%(]+)")
	if ( spellName ) then
		FiveSecLib_Spell = spellName
	end
end
CastSpellByName = FiveSecLib_newCastSpellByName

local FiveSecLib_oldUseAction = UseAction
local function FiveSecLib_newUseAction(slot, checkCursor, onSelf)
	
	FiveSecLibTip:ClearLines()
	FiveSecLibTip:SetAction(slot)
	local spellName = FiveSecLibTipTextLeft1:GetText()
	-- Call the original function
	FiveSecLib_oldUseAction(slot, checkCursor, onSelf)
	-- Test to see if this is a macro
	if ( GetActionText(slot) or not spellName ) then
		return
	end
	FiveSecLib_Spell = spellName
end
UseAction = FiveSecLib_newUseAction

local FiveSecLib_oldSpellStopTargeting = SpellStopTargeting
local function FiveSecLib_newSpellStopTargeting()
	FiveSecLib_oldSpellStopTargeting()
	FiveSecLib_Spell = nil
end
SpellStopTargeting = FiveSecLib_newSpellStopTargeting

local FiveSecLib_oldCastShapeshiftForm = CastShapeshiftForm
local function FiveSecLib_newCastShapeshiftForm(id)
	FiveSecLib_oldCastShapeshiftForm(id)
	FiveSecLibTip:ClearLines()
	FiveSecLibTip:SetShapeshift(id)
	FiveSecLib_Spell = FiveSecLibTipTextLeft1:GetText()
end
CastShapeshiftForm = FiveSecLib_newCastShapeshiftForm

FiveSecLib:SetScript("OnEvent", FiveSecLib.OnEvent)

AceLibrary:Register(FiveSecLib, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)