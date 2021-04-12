--[[
# Element: Simple Fader

Provides fading based on unit status.

## Widget

SimpleFader - A table with settings

## Options

.showStatus - Show interrupt auras as an overlay. (boolean)

## Examples

    -- Register it with oUF
    self.SimpleFader = {}
--]]

local _, ns = ...
local oUF = ns.oUF

local PowerTypesFull = {[Enum.PowerType.Mana] = true, [Enum.PowerType.Energy] = true, [Enum.PowerType.Focus] = true}

local function faderOnUpdate(self, elapsed)
	local element = self:GetParent().SimpleFader
	element.timeElapsed = element.timeElapsed + elapsed
	if( element.timeElapsed >= element.fadeTime ) then
		element.__owner:SetAlpha(element.alphaEnd)
		element.onUpdate:Hide()
		
		if( element.fadeIn ) then
			element.__owner.pauseRange = nil
		end
		return
	end
	
	if( element.fadeIn ) then
		self:GetParent():SetAlpha((element.timeElapsed / element.fadeTime) * (element.alphaEnd - element.alphaStart) + element.alphaStart)
	else
		self:GetParent():SetAlpha(((element.fadeTime - element.timeElapsed) / element.fadeTime) * (element.alphaStart - element.alphaEnd) + element.alphaEnd)
	end
end

local function startFading(self, fadeIn, alpha, fastFade)
	local element = self.SimpleFader
	if( element.fadeIn == fadeIn ) then return end
	if( not fadeIn ) then
		self.pauseRange = true
	end
	
	element.fadeTime = fastFade and 0.15 or fadeIn and 0.25 or 0.75
	element.fadeIn = fadeIn
	element.timeElapsed = 0
	element.alphaEnd = alpha
	element.alphaStart = self:GetAlpha()
	element.onUpdate:Show()
end

local function Update(self, event)
	local element = self.SimpleFader
	local unit = self.unit

	if( InCombatLockdown() or event == "PLAYER_REGEN_DISABLED" ) or
	( CastingInfo() or ChannelInfo() ) or
	( PowerTypesFull[UnitPowerType(unit)] and UnitPower(unit) ~= UnitPowerMax(unit) ) or
	( UnitHealth(unit) ~= UnitHealthMax(unit) ) or
	( unit == "player" and self:GetParent() == UIParent and UnitExists("target") ) then
		startFading(self, true, element.combatAlpha, element.fastFade)
	else
		startFading(self, nil, element.inactiveAlpha, element.fastFade)
	end
end

local function ForceUpdate(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function updateEvents(self, event)
	if event == "PLAYER_REGEN_ENABLED" then
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Update, true)
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", Update, true)
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", Update, true)
		self:RegisterEvent("UNIT_SPELLCAST_START", Update, true)
		self:RegisterEvent("UNIT_SPELLCAST_STOP", Update, true)
		self:RegisterEvent("UNIT_HEALTH", Update)
		self:RegisterEvent("UNIT_MAXHEALTH", Update)
		self:RegisterEvent("UNIT_POWER_FREQUENT", Update)
		self:RegisterEvent("UNIT_MAXPOWER", Update)
	else
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", Update)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", Update)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", Update)
		self:UnregisterEvent("UNIT_SPELLCAST_START", Update)
		self:UnregisterEvent("UNIT_SPELLCAST_STOP", Update)
		self:UnregisterEvent("UNIT_HEALTH", Update)
		self:UnregisterEvent("UNIT_MAXHEALTH", Update)
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Update)
		self:UnregisterEvent("UNIT_MAXPOWER", Update)
	end
	Update(self, event)
end

local function Enable(self)
	if self.SimpleFader then
		local element = self.SimpleFader
	
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		element.onUpdate = element.onUpdate or CreateFrame("Frame", nil, self)
		element.onUpdate:SetScript("OnUpdate", faderOnUpdate)
		element.onUpdate:Hide()

		element.fadeIn = true

		element.combatAlpha = element.combatAlpha or 1
		element.inactiveAlpha = element.inactiveAlpha or 0.35

		self:RegisterEvent("PLAYER_REGEN_ENABLED", updateEvents, true)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", updateEvents, true)

		updateEvents(self, not InCombatLockdown() and "PLAYER_REGEN_ENABLED" or "PLAYER_REGEN_DISABLED")

		return true
	end
end

local function Disable(self)
	if self.SimpleFader then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", updateEvents)
		self:UnregisterEvent("PLAYER_REGEN_DISABLED", updateEvents)
		
		updateEvents(self)
		
		self:SetAlpha(1)
		self.SimpleFader.onUpdate:SetScript("OnUpdate", nil)
		self.SimpleFader.fadeIn = nil
		self.pauseRange = nil
	end
end

oUF:AddElement('SimpleFader', nil, Enable, Disable)