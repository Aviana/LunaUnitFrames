--[[
Name: CastLib-1.0
Revision: $Rev: 10000 $
Author(s): aviana
Website: https://github.com/Aviana
Description: A library to provide information about casts.
Dependencies: AceLibrary, AceEvent-2.0
]]

local MAJOR_VERSION = "CastLib-1.0"
local MINOR_VERSION = "$Revision: 10000 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end

local CastLib = CreateFrame("Frame")

------------------------------------------------
-- activate, enable, disable
------------------------------------------------

local function activate(self, oldLib, oldDeactivate)
	CastLib = self
	if oldLib then
		oldLib:UnregisterAllEvents()
		oldLib:CancelAllScheduledEvents()
	end
	if oldDeactivate then oldDeactivate(oldLib) end
end


local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		CastLib.EventScheduler = instance
		CastLib.EventScheduler:embed(self)
		self:UnregisterAllEvents()
		self:CancelAllScheduledEvents()
		if CastLib.EventScheduler:IsFullyInitialized() then
			self:AceEvent_FullyInitialized()
		else
			self:RegisterEvent("AceEvent_FullyInitialized", "AceEvent_FullyInitialized", true)
		end		
	end
end

function CastLib:Enable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end


function CastLib:Disable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end

------------------------------------------------
-- Internal functions
------------------------------------------------

function CastLib:AceEvent_FullyInitialized()
	self:TriggerEvent("CastLib_Enabled")
	self:RegisterEvent("SPELLCAST_START", CastLib.OnEvent)
	self:RegisterEvent("SPELLCAST_INTERRUPTED", CastLib.OnEvent)
	self:RegisterEvent("SPELLCAST_FAILED", CastLib.OnEvent)
	self:RegisterEvent("SPELLCAST_STOP", CastLib.OnEvent)
end

------------------------------------------------
-- Addon Code
------------------------------------------------

local CastLib_Slot
local CastLib_Spell
local CastLib_Rank
local CastLib_Castname
local CastLib_SpellCast
local CastLib_SpellCast_backup
local CastLib_isCasting

local CastLibTip = CreateFrame("GameTooltip", "CastLibTip", nil, "GameTooltipTemplate")
CastLibTip:SetOwner(WorldFrame, "ANCHOR_NONE")

function CastLib.stopCast(SpellCast)
--	ChatFrame1:AddMessage(SpellCast[1].." ended after delay.")
end

function CastLib.instantCast(SpellCast)
--	ChatFrame1:AddMessage(SpellCast[1].." was instant.")
end

CastLib.OnEvent = function()
	if ( event == "SPELLCAST_START" ) then
		if ( CastLib_SpellCast and CastLib_SpellCast[1] == arg1 ) then
			if CastLib.EventScheduler:IsEventScheduled("CastLib_CastInstant") then
				CastLib.EventScheduler:CancelScheduledEvent("CastLib_CastInstant")
				
			end
			CastLib_SpellCast_backup = CastLib_SpellCast
			CastLib_isCasting = 1
--			ChatFrame1:AddMessage("Casting "..arg1)
--			CastLib.EventScheduler:TriggerEvent("CASTLIB_STARTCAST", arg1)
		end
	elseif (event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED") then
		if CastLib.EventScheduler:IsEventScheduled("CastLib_CastEnding") then
			CastLib.EventScheduler:CancelScheduledEvent("CastLib_CastEnding")
--			ChatFrame1:AddMessage(CastLib_SpellCast_backup[1].." didn't finish.")
		end
		CastLib_isCasting = nil
		CastLib_SpellCast =  nil
		CastLib_Rank = nil
		CastLib_Spell =  nil
	elseif event == "SPELLCAST_STOP" and CastLib_SpellCast then
		if not CastLib_isCasting and CastLib_SpellCast then
			if CastLib.EventScheduler:IsEventScheduled("CastLib_CastEnding") then
				CastLib.EventScheduler:CancelScheduledEvent("CastLib_CastEnding")
--				ChatFrame1:AddMessage(CastLib_SpellCast_backup[1].." ended.")
			end
			CastLib.EventScheduler:ScheduleEvent("CastLib_CastInstant", CastLib.instantCast, 0.3, CastLib_SpellCast)
			CastLib_SpellCast_backup = CastLib_SpellCast
		else
			CastLib_isCasting = nil
			CastLib.EventScheduler:ScheduleEvent("CastLib_CastEnding", CastLib.stopCast, 0.3, CastLib_SpellCast_backup)
		end
		CastLib_SpellCast =  nil
		CastLib_Rank = nil
		CastLib_Spell =  nil
	end
end

local CastLib_oldCastSpell = CastSpell
function CastLib_newCastSpell(spellId, spellbookTabNum)
	-- Call the original function so there's no delay while we process
	CastLib_oldCastSpell(spellId, spellbookTabNum)
	local spellName, rank = GetSpellName(spellId, spellbookTabNum)
	_,_,rank = string.find(rank,"(%d+)")
	if ( SpellIsTargeting() ) then
       -- Spell is waiting for a target
       CastLib_Spell = spellName
	   CastLib_Rank = rank
	elseif ( UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") ) then
       -- Spell is being cast on the current target.  
       -- If ClearTarget() had been called, we'd be waiting target
		if UnitIsPlayer("target") then
			CastLib_ProcessSpellCast(spellName, rank, UnitName("target"))
		end
	else
		CastLib_ProcessSpellCast(spellName, rank, UnitName("player"))
	end
end
CastSpell = CastLib_newCastSpell

local CastLib_oldCastSpellByName = CastSpellByName
function CastLib_newCastSpellByName(spellName, onSelf)
	-- Call the original function
	CastLib_oldCastSpellByName(spellName, onSelf)
	local _,_,rank = string.find(spellName,"(%d+)")
	local _, _, spellName = string.find(spellName, "^([^%(]+)")
	if not rank then
		local i = 1
		while GetSpellName(i, BOOKTYPE_SPELL) do
			local s, r = GetSpellName(i, BOOKTYPE_SPELL)
			if s == spellName then
				rank = r
			end
			i = i+1
		end
		if rank then
			_,_,rank = string.find(rank,"(%d+)")
		end
	end
	if ( spellName ) then
		if ( SpellIsTargeting() ) then
			CastLib_Spell = spellName
			CastLib_Rank = rank
		else
			if UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") and onSelf ~= 1 then
				if UnitIsPlayer("target") then
					CastLib_ProcessSpellCast(spellName, rank, UnitName("target"))
				end
			else
				CastLib_ProcessSpellCast(spellName, rank, UnitName("player"))
			end
		end
	end
end
CastSpellByName = CastLib_newCastSpellByName

CastLib_oldWorldFrameOnMouseDown = WorldFrame:GetScript("OnMouseDown")
WorldFrame:SetScript("OnMouseDown", function()
	-- If we're waiting to target
	local targetName
	
	if ( CastLib_Spell and UnitName("mouseover") ) then
		targetName = UnitName("mouseover")
	elseif ( CastLib_SpellSpell and GameTooltipTextLeft1:IsVisible() ) then
		local _, _, name = string.find(GameTooltipTextLeft1:GetText(), "^Corpse of (.+)$")
		if ( name ) then
			targetName = name
		end
	end
	if ( CastLib_oldWorldFrameOnMouseDown ) then
		CastLib_oldWorldFrameOnMouseDown()
	end
	if ( CastLib_Spell and targetName ) then
		CastLib_ProcessSpellCast(CastLib_Spell, CastLib_Rank, targetName)
	end
end)

local CastLib_oldUseAction = UseAction
function CastLib_newUseAction(slot, checkCursor, onSelf)
	CastLibTip:ClearLines()
	CastLibTip:SetAction(slot)
	local spellName = CastLibTipTextLeft1:GetText()
	CastLib_Spell = spellName
	CastLib_Slot = slot
	
	-- Call the original function
	CastLib_oldUseAction(slot, checkCursor, onSelf)
	-- Test to see if this is a macro
	if ( GetActionText(slot) or not CastLib_Spell ) then
		return
	end
	local rank = CastLibTipTextRight1:GetText()
	if rank then
		_,_,rank = string.find(rank,"(%d+)")
	end
	if not rank then
		rank = 1
	end
	CastLib_Rank = rank
	if ( SpellIsTargeting() ) then
		-- Spell is waiting for a target
		return
	elseif ( UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") and onSelf ~= 1) then
		-- Spell is being cast on the current target
		if UnitIsPlayer("target") then
			CastLib_ProcessSpellCast(spellName, rank, UnitName("target"))
		end
	else
		-- Spell is being cast on the player
		CastLib_ProcessSpellCast(spellName, rank, UnitName("player"))
	end
end
UseAction = CastLib_newUseAction

local CastLib_oldSpellTargetUnit = SpellTargetUnit
function CastLib_newSpellTargetUnit(unit)
	-- Call the original function
	local shallTargetUnit
	if ( SpellIsTargeting() ) then
		shallTargetUnit = true
	end
	CastLib_oldSpellTargetUnit(unit)
	if ( shallTargetUnit and CastLib_SpellSpell and not SpellIsTargeting() ) then
		if UnitIsPlayer(unit) then
			CastLib_ProcessSpellCast(CastLib_Spell, CastLib_Rank, UnitName(unit))
		end
		CastLib_Spell = nil
		CastLib_Rank = nil
	end
end
SpellTargetUnit = CastLib_newSpellTargetUnit

local CastLib_oldSpellStopTargeting = SpellStopTargeting
function CastLib_newSpellStopTargeting()
	CastLib_oldSpellStopTargeting()
	CastLib_Spell = nil
	CastLib_Rank = nil
end
SpellStopTargeting = CastLib_newSpellStopTargeting

local CastLib_oldTargetUnit = TargetUnit
function CastLib_newTargetUnit(unit)
	-- Look to see if we're currently waiting for a target internally
	-- If we are, then well glean the target info here.
	if ( CastLib_SpellSpell and UnitExists(unit) ) and UnitIsPlayer(unit) then
		CastLib_ProcessSpellCast(CastLib_Spell, CastLib_Rank, UnitName(unit))
	end
	-- Call the original function
	CastLib_oldTargetUnit(unit)
end
TargetUnit = CastLib_newTargetUnit

function CastLib_ProcessSpellCast(spellName, rank, targetName)
	if spellName == "Aimed Shot" and IsCurrentAction(CastLib_Slot) then
		CastLib.EventScheduler:TriggerEvent("CASTLIB_STARTCAST", "Aimed Shot")
	end
	CastLib_SpellCast = { spellName, rank, targetName }
end

CastLib:SetScript("OnEvent", CastLib.OnEvent)

AceLibrary:Register(CastLib, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)