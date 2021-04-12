--[[
# Element: Additional Regen Ticker

A fork of oUF_EnergyManaRegen

## Widget

AdditionalRegenTicker - A status bar.

## Notes

This depends upon the AdditionalPower module.

## Options

.hideTicks        - If this is set no ticks will be shown (boolean)
.hideFive         - If this is set no 5 sec rule will be shown (boolean)
.autoHide         - Hide the ticker in a s.m.a.r.t. way (boolean)
.vertical         - For vertical power bars

## Examples

    -- Position and size
    local AdditionalRegenTicker = CreateFrame("StatusBar", nil, self.Power)
    AdditionalRegenTicker.splitTimer = CreateFrame("StatusBar", nil, self.Power)

    -- Register it with oUF
    self.AdditionalRegenTicker = AdditionalRegenTicker
--]]

local _, ns = ...
local oUF = ns.oUF

--Lua functions
local _G = _G
local GetTime = GetTime
local UnitPower = UnitPower
local UnitClass = UnitClass
local tonumber = tonumber
local UnitPowerType = UnitPowerType
local UnitPowerMax = UnitPowerMax
local GetSpellPowerCost = GetSpellPowerCost

local LastTickTime = GetTime()
local TickDelay = 2.025 -- Average tick time is slightly over 2 seconds
local CurrentValue = UnitPower("player")
local LastValue = CurrentValue
local ignorePowerChange
local myClass = select(2, UnitClass("player"))
local Mp5Delay = 5
local Mp5DelayWillEnd = nil
local Mp5IgnoredSpells = {
	[11689] = true, -- life tap 6
	[11688] = true, -- life tap 5
	[11687] = true, -- life tap 4
	[1456] = true, -- life tap 3
	[1455] = true, -- life tap 2
	[1454] = true, -- life tap 1
	[18182] = true, -- improved life tap 1
	[18183] = true, -- improved life tap 2
}
local backdrop = {
	bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
	tile = true,
	tileSize = 16,
	insets = {left = -1.5, right = -1.5, top = -1.5, bottom = -1.5},
}
local inCombat
local hasTarget
local isStealthed
local doSplit

local function CheckHidden(element)
	if (element.hideFive and element.hideTicks) or element.autoHide and not inCombat and not (isStealthed and hasTarget) and UnitPower("player", Enum.PowerType.Mana) == UnitPowerMax("player", Enum.PowerType.Mana) then
		return true
	end
end

local Update = function(self, elapsed)
	local element = self.AdditionalRegenTicker
	if(element:IsObjectType("StatusBar")) then
		element:SetOrientation(element.vertical and "VERTICAL" or "HORIZONTAL")
		element.Spark:ClearAllPoints()
		element.splitTimer.Spark:ClearAllPoints()
		if element.vertical then
			element.Spark:SetPoint("LEFT", element:GetStatusBarTexture(), "TOPLEFT")
			element.splitTimer.Spark:SetPoint("RIGHT", element:GetStatusBarTexture(), "TOPRIGHT")
		else
			element.Spark:SetPoint("TOP", element:GetStatusBarTexture(), "TOPRIGHT")
			element.splitTimer.Spark:SetPoint("BOTTOM", element:GetStatusBarTexture(), "BOTTOMRIGHT")
		end
		element.splitTimer:SetOrientation(element.vertical and "VERTICAL" or "HORIZONTAL")
	end
end

local OnUpdate = function(self, elapsed)
	local element = self.AdditionalRegenTicker
	element.sinceLastUpdate = (element.sinceLastUpdate or 0) + (tonumber(elapsed) or 0)

	if element.sinceLastUpdate > 0.01 then
		local powerType = Enum.PowerType.Mana
		if CheckHidden(element) then
			element.Spark:Hide()
			element.splitTimer.Spark:Hide()
			return
		end

		CurrentValue = UnitPower("player", powerType)
		local MaxPower = UnitPowerMax("player", powerType)
		local Now = GetTime()

		if doSplit then
			if not element.hideTicks and not element.hideFive then
				element.splitTimer.Spark:ClearAllPoints()
				if element.vertical then
					element.splitTimer.Spark:SetPoint("RIGHT", element.splitTimer:GetStatusBarTexture(), "TOPRIGHT")
				else
					element.splitTimer.Spark:SetPoint("BOTTOM", element.splitTimer:GetStatusBarTexture(), "BOTTOMRIGHT")
				end
			end
			doSplit = nil
		end

		if Mp5DelayWillEnd and Mp5DelayWillEnd < Now then
			Mp5DelayWillEnd = nil
			element.splitTimer.Spark:ClearAllPoints()
			if element.vertical then
				element.splitTimer.Spark:SetPoint("RIGHT", element:GetStatusBarTexture(), "TOPRIGHT")
			else
				element.splitTimer.Spark:SetPoint("BOTTOM", element:GetStatusBarTexture(), "BOTTOMRIGHT")
			end
		end

		LastTickTime = Now - ((Now - LastTickTime) % TickDelay)

		if element.hideTicks and not Mp5DelayWillEnd then
			element.Spark:Hide()
			element.splitTimer.Spark:Hide()
			return
		end
		element.Spark:Show()
		element.splitTimer.Spark:Show()

		if Mp5DelayWillEnd then
			-- Show 5 second indicator
			element.splitTimer:SetMinMaxValues(0, Mp5Delay)
			element.splitTimer:SetValue(Mp5DelayWillEnd - Now)
			if element.hideTicks then
				element:SetMinMaxValues(0, Mp5Delay)
				element:SetValue(Mp5DelayWillEnd - Now)
				return
			end
		end
		-- Show tick indicator
		element:SetMinMaxValues(0, TickDelay)
		element:SetValue(Now - LastTickTime)

		element.sinceLastUpdate = 0
	end
end

local OnUnitPowerUpdate = function()

	-- We also register ticks from mp5 gear within the 5-second-rule to get a more accurate sync later.
	local CurrentValue = UnitPower("player", Enum.PowerType.Mana)
	if CurrentValue > LastValue and not ignorePowerChange then
		LastTickTime = GetTime()
	end
	ignorePowerChange = nil
	LastValue = CurrentValue
end

local OnUnitSpellcastSucceeded = function(_, _, _, _, spellID)
	local powerType = UnitPowerType("player")
	if powerType ~= Enum.PowerType.Mana then
		return
	end

	local spellCost = false
	local costTable = GetSpellPowerCost(spellID)
	for _, costInfo in next, costTable do
		if costInfo.cost and costInfo.type == Enum.PowerType.Mana then
			spellCost = true
		end
	end

	if not spellCost or Mp5IgnoredSpells[spellID] then
		return
	end

	doSplit = true
	Mp5DelayWillEnd = GetTime() + 5
end

local events = {
	["SPELL_ENERGIZE"] = true,
	["SPELL_DRAIN"] = true,
	["SPELL_LEECH"] = true,
	["SPELL_PERIODIC_ENERGIZE"] = true,
	["SPELL_PERIODIC_DRAIN"] = true,
	["SPELL_PERIODIC_LEECH"] = true,
}
local OnPowerStateIgnore = function()
	local event, _, _, _, _, _, targetID = select(2,CombatLogGetCurrentEventInfo())
	if events[event] and targetID == UnitGUID("player") then
		ignorePowerChange = true
	end
end

local OnSizeChanged = function(self)
	local x,y
	if self.vertical then
		x, y = self:GetWidth()/2, 1
	else
		x, y = 1, self:GetHeight()/2
	end
	if self.splitTimer then
		self.Spark:SetSize(x,y)
		self.splitTimer.Spark:SetSize(x,y)
	else
		self.Spark:SetSize(1,y*2)
	end
end

local stealthIDs = {
	[1784] = true, -- stealth r1
	[1785] = true, -- stealth r2
	[1786] = true, -- stealth r3
	[1787] = true, -- stealth r4
	[5215] = true, -- prowl r1
	[6783] = true, -- prowl r2
	[9913] = true, -- prowl r3
}
function UpdateAura()
	local i = 1
	while UnitBuff("player",i) do
		if stealthIDs[select(10,UnitBuff("player",i))] then
			isStealthed = true
			return
		end
		i = i + 1
	end
	isStealthed = nil
end

local function TargetChanged()
	hasTarget = UnitExists("target") and UnitCanAttack("player", "target")
end

function EnableCombat()
	inCombat = true
end

function DisableCombat()
	inCombat = nil
end

local OnUpdatePath = function(self, ...)
	return (self.AdditionalRegenTicker.OnUpdate or OnUpdate) (self, ...)
end

local Path = function(self, ...)
	return (self.AdditionalRegenTicker.Override or Update) (self, ...)
end

local Enable = function(self, unit)
	if myClass ~= "DRUID" then return end
	local element = self.AdditionalRegenTicker
	local AdditionalPower = self.AdditionalPower

	if (unit == "player") and element and AdditionalPower then
		element.__owner = self

		if(element:IsObjectType("StatusBar")) then
			element:SetStatusBarTexture([[Interface\Buttons\WHITE8X8]])
			element:GetStatusBarTexture():SetAlpha(0)
			element:SetMinMaxValues(0, 2)
			element:ClearAllPoints()
			element:SetAllPoints(AdditionalPower)
			if not element.Spark then
				element.Spark = CreateFrame("Frame", nil, element)
				element.Spark:SetBackdrop(backdrop)
				element.Spark:SetBackdropColor(0,0,0)
				element.Spark.texture = element.Spark:CreateTexture(nil, "OVERLAY")
				element.Spark.texture:SetAllPoints(element.Spark)
				element.Spark.texture:SetTexture([[Interface\Buttons\WHITE8X8]])
			end
			element:SetScript("OnSizeChanged", OnSizeChanged)
			
			if not element.splitTimer or not element.splitTimer:IsObjectType("StatusBar") then
				element.splitTimer = CreateFrame("StatusBar", nil, AdditionalPower)
				element.splitTimer:SetStatusBarTexture([[Interface\Buttons\WHITE8X8]])
				element.splitTimer:GetStatusBarTexture():SetAlpha(0)
				element.splitTimer:SetMinMaxValues(0, 2)
				element.splitTimer:ClearAllPoints()
				element.splitTimer:SetAllPoints(AdditionalPower)
				element.splitTimer.Spark = CreateFrame("Frame", nil, element.splitTimer)
				element.splitTimer.Spark:SetBackdrop(backdrop)
				element.splitTimer.Spark:SetBackdropColor(0,0,0)
				element.splitTimer.Spark.texture = element.Spark:CreateTexture(nil, "OVERLAY")
				element.splitTimer.Spark.texture:SetAllPoints(element.splitTimer.Spark)
				element.splitTimer.Spark.texture:SetTexture([[Interface\Buttons\WHITE8X8]])
			end
		end

		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", OnUnitSpellcastSucceeded)
		self:RegisterEvent("UNIT_POWER_UPDATE", OnUnitPowerUpdate)
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", OnPowerStateIgnore, true)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", DisableCombat, true)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", EnableCombat, true)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", TargetChanged, true)
		self:RegisterEvent("UNIT_AURA", UpdateAura)
		inCombat = UnitAffectingCombat("player")
		TargetChanged()
		UpdateAura()

		element:SetScript("OnUpdate", function(_, elapsed) OnUpdatePath(self, elapsed) end)

		return true
	end
end

local Disable = function(self)
	if myClass ~= "DRUID" then return end
	local element = self.AdditionalRegenTicker
	local AdditionalPower = self.AdditionalPower

	if (AdditionalPower) and (element) then
		
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", OnUnitSpellcastSucceeded)
		self:UnregisterEvent("UNIT_POWER_UPDATE", OnUnitPowerUpdate)
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", OnPowerStateIgnore)
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", DisableCombat)
		self:UnregisterEvent("PLAYER_REGEN_DISABLED", EnableCombat)
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", TargetChanged)
		self:UnregisterEvent("UNIT_AURA", UpdateAura)

		element.Spark:Hide()
		element.splitTimer.Spark:Hide()
		element:SetScript("OnUpdate", nil)
		element:SetScript("OnSizeChanged", nil)

		return false
	end
end

oUF:AddElement("RegenTickerAlt", Path, Enable, Disable)