--[[
Name: CastLib-1.0
Revision: $Rev: 10030 $
Author(s): aviana
Website: https://github.com/Aviana
Description: A library to provide information about casts.
Dependencies: AceLibrary, AceEvent-2.0
]]

local MAJOR_VERSION = "CastLib-1.0"
local MINOR_VERSION = "$Revision: 10030 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end
if not AceLibrary:HasInstance("AceHook-2.1") then error(MAJOR_VERSION .. " requires AceHook-2.1") end

local CastLib = {}
local AimedShot = AceLibrary("Babble-Spell-2.2")["Aimed Shot"]
local Multishot = AceLibrary("Babble-Spell-2.2")["Multi-Shot"]

------------------------------------------------
-- activate, enable, disable
------------------------------------------------

local function activate(self, oldLib, oldDeactivate)
	CastLib = self
	if oldLib then
		oldLib:UnregisterAllEvents()
		oldLib:CancelAllScheduledEvents()
		self.SpellCast = oldLib.SpellCast
		self.SpellCast_backup = oldLib.SpellCast_backup
	end
	if not self.SpellCast then
		self.SpellCast = {}
	end
	if not self.SpellCast_backup then
		self.SpellCast_backup = {}
	end
	if oldDeactivate then oldDeactivate(oldLib) end
end


local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		local AceEvent = instance
		AceEvent:embed(self)
		self:RegisterEvent("SPELLCAST_START")
		self:RegisterEvent("SPELLCAST_INTERRUPTED", "SPELLCAST_FAILED")
		self:RegisterEvent("SPELLCAST_FAILED")
		self:RegisterEvent("SPELLCAST_STOP")
		self:TriggerEvent("CastLib_Enabled")
	end
	if major == "AceHook-2.1" then
		local AceHook = instance
		AceHook:embed(self)
		self:Hook("CastSpell")
		self:Hook("CastSpellByName")
		self:HookScript(WorldFrame, "OnMouseDown")
		self:Hook("UseAction")
		self:Hook("SpellTargetUnit")
		self:Hook("SpellStopTargeting")
		self:Hook("TargetUnit")
	end
end

function CastLib:Enable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end


function CastLib:Disable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end

------------------------------------------------
-- Addon Code
------------------------------------------------

local CastLibTip = CreateFrame("GameTooltip", "CastLibTip", nil, "GameTooltipTemplate")
CastLibTip:SetOwner(WorldFrame, "ANCHOR_NONE")

function CastLib:stopCast(SpellCast)
--	ChatFrame1:AddMessage(SpellCast[1].." ended after delay.")
end

function CastLib:instantCast(SpellCast)
--	ChatFrame1:AddMessage(SpellCast[1].." was instant.")
end

function CastLib:SPELLCAST_START()
	if ( self.SpellCast and self.SpellCast[1] == arg1 ) then
		if self:IsEventScheduled("CastLib_CastInstant") then
			self:CancelScheduledEvent("CastLib_CastInstant")
			
		end
		self.SpellCast_backup[1] = self.SpellCast[1]
		self.SpellCast_backup[2] = self.SpellCast[2]
		self.SpellCast_backup[3] = self.SpellCast[3]
		self.isCasting = true
--		ChatFrame1:AddMessage("Casting "..arg1)
--		self:TriggerEvent("CASTLIB_STARTCAST", arg1)
		local _,_,manaVal = string.find(CastLibTipTextLeft2:GetText() or "","(%d+)")
		if manaVal then
			self.Mana = tonumber(manaVal)
		else
			self.Mana = 0
		end
		self:TriggerEvent("CASTLIB_MANAUSAGE", self.Mana)
	end
	CastLibTip:ClearLines()
end

function CastLib:SPELLCAST_FAILED()
	CastLibTip:ClearLines()
	if self:IsEventScheduled("CastLib_CastEnding") then
		self:CancelScheduledEvent("CastLib_CastEnding")
--		ChatFrame1:AddMessage(self.SpellCast_backup[1].." didn't finish.")
	end
	self.isCasting = nil
	for key in pairs(self.SpellCast) do
		self.SpellCast[key] = nil
	end
	self.Rank = nil
	CastLib_Spell =  nil
	self.Mana = 0
	self:TriggerEvent("CASTLIB_MANAUSAGE", self.Mana)
end

function CastLib:SPELLCAST_STOP()
	CastLibTip:ClearLines()
	if self.SpellCast then
		if not self.isCasting and self.SpellCast then
			if self:IsEventScheduled("CastLib_CastEnding") then
				self:CancelScheduledEvent("CastLib_CastEnding")
--				ChatFrame1:AddMessage(self.SpellCast_backup[1].." ended.")
			end
			self:ScheduleEvent("CastLib_CastInstant", self.instantCast, 0.3, self, self.SpellCast)
			self.SpellCast_backup[1] = self.SpellCast[1]
			self.SpellCast_backup[2] = self.SpellCast[2]
			self.SpellCast_backup[3] = self.SpellCast[3]
		else
			self.isCasting = nil
			self:ScheduleEvent("CastLib_CastEnding", self.stopCast, 0.3, self, self.SpellCast_backup)
		end
		for key in pairs(self.SpellCast) do
			self.SpellCast[key] = nil
		end
		self.Rank = nil
		CastLib_Spell =  nil
		self.Mana = 0
		self:TriggerEvent("CASTLIB_MANAUSAGE", self.Mana)
	end
end

function CastLib:GetSpell()
	return CastLib_Spell or self.SpellCast_backup[1], self.Rank or self.SpellCast_backup[2]
end

function CastLib:GetManaUse()
	return self.Mana
end

function CastLib:CastSpell(spellId, spellbookTabNum)
	-- Call the original function so there's no delay while we process
	self.hooks.CastSpell(spellId, spellbookTabNum)
	if CastLib_Spell then
		return
	end
	CastLibTip:SetSpell(spellId, spellbookTabNum)
	local spellName, rank = GetSpellName(spellId, spellbookTabNum)
	_,_,rank = string.find(rank,"(%d+)")
	if ( SpellIsTargeting() ) then
       -- Spell is waiting for a target
       CastLib_Spell = spellName
	   self.Rank = rank
	elseif ( UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") ) then
       -- Spell is being cast on the current target.  
       -- If ClearTarget() had been called, we'd be waiting target
		if UnitIsPlayer("target") then
			self:ProcessSpellCast(spellName, rank, UnitName("target"))
		end
	else
		self:ProcessSpellCast(spellName, rank, UnitName("player"))
	end
end

function CastLib:CastSpellByName(spellName, onSelf)
	-- Call the original function
	self.hooks.CastSpellByName(spellName, onSelf)
	
	local _,_,rank = string.find(spellName,"(%d+)")
	local _, _, spellName = string.find(spellName, "^([^%(]+)")
	if not rank then
		local i = 1
		while GetSpellName(i, BOOKTYPE_SPELL) do
			local s, r = GetSpellName(i, BOOKTYPE_SPELL)
			if s == spellName then
				CastLibTip:SetSpell(i, BOOKTYPE_SPELL)
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
			self.Rank = rank
		else
			if UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") and onSelf ~= 1 then
				if UnitIsPlayer("target") then
					self:ProcessSpellCast(spellName, rank, UnitName("target"))
				end
			else
				self:ProcessSpellCast(spellName, rank, UnitName("player"))
			end
		end
	end
end

function CastLib:OnMouseDown()
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
	if ( self.hooks.WorldFrameOnMouseDown ) then
		self.hooks.WorldFrameOnMouseDown()
	end
	if ( CastLib_Spell and targetName ) then
		self:ProcessSpellCast(CastLib_Spell, self.Rank, targetName)
	end
end

function CastLib:UseAction(slot, checkCursor, onSelf)
	local spellName
	self.Slot = slot
	
	-- Test to see if this is a macro
	if not GetActionText(slot) then
		CastLibTip:SetAction(slot)
		spellName = CastLibTipTextLeft1:GetText()
		CastLib_Spell = spellName
	end
	-- Call the original function
	self.hooks.UseAction(slot, checkCursor, onSelf)
	
	if CastLib_Spell == AimedShot and not GetActionText(slot) then
		self:ProcessSpellCast(CastLib_Spell, 6, UnitName("target"))
		return
	elseif CastLib_Spell == Multishot and not GetActionText(slot) then
		self:ProcessSpellCast(CastLib_Spell, 4, UnitName("target"))
		return
	end
	
	-- Test to see if this is a macro
	if GetActionText(slot) then
		return
	end
	
	local rank = CastLibTipTextRight1:GetText()
	if rank then
		_,_,rank = string.find(rank,"(%d+)")
	end
	if not rank then
		rank = 1
	end
	self.Rank = rank
	if ( SpellIsTargeting() ) then
		-- Spell is waiting for a target
		return
	elseif ( UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") and onSelf ~= 1) then
		-- Spell is being cast on the current target
		if UnitIsPlayer("target") then
			self:ProcessSpellCast(spellName, rank, UnitName("target"))
		end
	else
		-- Spell is being cast on the player
		self:ProcessSpellCast(spellName, rank, UnitName("player"))
	end
end

function CastLib:SpellTargetUnit(unit)
	-- Call the original function
	local shallTargetUnit
	if ( SpellIsTargeting() ) then
		shallTargetUnit = true
	end
	self.hooks.SpellTargetUnit(unit)
	if ( shallTargetUnit and CastLib_SpellSpell and not SpellIsTargeting() ) then
		if UnitIsPlayer(unit) then
			self:ProcessSpellCast(self.Spell, self.Rank, UnitName(unit))
		end
		self.Spell = nil
		self.Rank = nil
	end
end

function CastLib:SpellStopTargeting()
	self.hooks.SpellStopTargeting()
	self.Spell = nil
	self.Rank = nil
	CastLibTip:ClearLines()
end

function CastLib:TargetUnit(unit)
	-- Look to see if we're currently waiting for a target internally
	-- If we are, then well glean the target info here.
	if ( CastLib_SpellSpell and UnitExists(unit) ) and UnitIsPlayer(unit) then
		self:ProcessSpellCast(self.Spell, self.Rank, UnitName(unit))
	end
	-- Call the original function
	self.hooks.TargetUnit(unit)
end

function CastLib:ProcessSpellCast(spellName, rank, targetName)
	if spellName == AimedShot then
		self.Spell = AimedShot
		if not self.isCasting and self.Slot and IsCurrentAction(self.Slot) then
			self.isCasting = true
			local AceEvent = AceLibrary("AceEvent-2.0")
			AceEvent:TriggerEvent("CASTLIB_STARTCAST", AimedShot)
		end
	elseif spellName == Multishot then
		self.Spell = Multishot
		if not self.isCasting and self.Slot and IsCurrentAction(self.Slot) then
			self.isCasting = true
			local AceEvent = AceLibrary("AceEvent-2.0")
			AceEvent:TriggerEvent("CASTLIB_STARTCAST", Multishot)
		end
	end
	self.SpellCast[1] = spellName
	self.SpellCast[2] = rank
	self.SpellCast[3] = targetName
end

AceLibrary:Register(CastLib, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
CastLib = nil