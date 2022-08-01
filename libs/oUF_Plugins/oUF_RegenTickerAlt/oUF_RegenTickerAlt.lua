--[[
# Element: Additional Regen Ticker

A fork of oUF_EnergyManaRegen

## Widget

AdditionalRegenTicker - A status bar.

## Notes

This depends upon the AdditionalPower module.

## Options

.vertical         - For vertical power bars

## Examples

    -- Position and size
    local AdditionalRegenTicker = CreateFrame("StatusBar", nil, self.Power)

    -- Register it with oUF
    self.AdditionalRegenTicker = AdditionalRegenTicker
--]]

local _, ns = ...
local oUF = ns.oUF

--Lua functions
local GetTime = GetTime
local UnitClass = UnitClass
local tonumber = tonumber
local UnitPowerType = UnitPowerType
local GetSpellPowerCost = GetSpellPowerCost

local myClass = select(2, UnitClass("player"))
local Mp5EndTime = nil
local backdrop = {
	bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
	tile = true,
	tileSize = 16,
	insets = {left = -1.5, right = -1.5, top = -1.5, bottom = -1.5},
}

local Update = function(self, elapsed)
	local element = self.AdditionalRegenTicker
	if(element:IsObjectType("StatusBar")) then
		element:SetOrientation(element.vertical and "VERTICAL" or "HORIZONTAL")
		element.Spark:ClearAllPoints()
		if element.vertical then
			element.Spark:SetPoint("LEFT", element:GetStatusBarTexture(), "TOPLEFT")
		else
			element.Spark:SetPoint("TOP", element:GetStatusBarTexture(), "TOPRIGHT")
		end
	end
end

local OnUpdate = function(self, elapsed)
	local element = self.AdditionalRegenTicker
	element.sinceLastUpdate = (element.sinceLastUpdate or 0) + (tonumber(elapsed) or 0)

	if element.sinceLastUpdate > 0.01 then
		local powerType = Enum.PowerType.Mana
		local Now = GetTime()

		if not Mp5EndTime then
			element.Spark:Hide()
			return
		elseif Mp5EndTime < Now then
			Mp5EndTime = nil
			return
		end

		element.Spark:Show()
		element:SetMinMaxValues(0, 5)
		element:SetValue(Mp5EndTime - Now)

		element.sinceLastUpdate = 0
	end
end

local OnUnitSpellcastSucceeded = function(_, _, _, _, spellID)
	local powerType = UnitPowerType("player")
	if powerType ~= Enum.PowerType.Mana then
		return
	end

	local spellCost = false
	local costTable = GetSpellPowerCost(spellID)
	for _, costInfo in next, costTable do
		if costInfo.cost then
			spellCost = true
		end
	end

	if not spellCost then
		return
	end

	Mp5EndTime = GetTime() + 5
end

local OnSizeChanged = function(self)
	local x,y
	if self.vertical then
		x, y = self:GetWidth(), 1
	else
		x, y = 1, self:GetHeight()
	end
	self.Spark:SetSize(1,y)
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
				element.Spark = CreateFrame("Frame", nil, element, "BackdropTemplate")
				element.Spark:SetBackdrop(backdrop)
				element.Spark:SetBackdropColor(0,0,0)
				element.Spark.texture = element.Spark:CreateTexture(nil, "OVERLAY")
				element.Spark.texture:SetAllPoints(element.Spark)
				element.Spark.texture:SetTexture([[Interface\Buttons\WHITE8X8]])
			end
			element:SetScript("OnSizeChanged", OnSizeChanged)
		end

		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", OnUnitSpellcastSucceeded)

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

		element.Spark:Hide()
		element:SetScript("OnUpdate", nil)
		element:SetScript("OnSizeChanged", nil)

		return false
	end
end

oUF:AddElement("RegenTickerAlt", Path, Enable, Disable)