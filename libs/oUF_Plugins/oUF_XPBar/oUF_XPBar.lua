--[[
# Element: Health Prediction Bars

Handles the visibility and updating of an XP and a reputation bar.

## Widget

XPRepBar - A "table" containing references to sub-widgets and options.

## Sub-Widgets

xpBar          - A "StatusBar" used to represent player or pet xp.
repBar         - A "StatusBar" used to represent reputation with the currently watched faction.

## Sub-Widgets

.bg            - A "Texture" used as background

## Notes

A default texture will be applied to the StatusBar widgets if they don't have a texture set.

## Options

.tooltip - Show a tooltip with detailed information on mouseover.


## Examples

    -- Position and size
    local xpBar = CreateFrame('StatusBar', nil, self)
    local repBar = CreateFrame('StatusBar', nil, self)

    -- Register with oUF
    self.XPRepBar = {
        myBar = myBar,
        otherBar = otherBar,
    }
--]]

local _, ns = ...
local oUF = ns.oUF

local function formatNumber(number)
	local found
	while( true ) do
		number, found = string.gsub(number, "^(-?%d+)(%d%d%d)", "%1,%2")
		if( found == 0 ) then break end
	end
	return number
end

local function OnEnter(self)
	if( self.tooltip ) then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:SetText(self.tooltip)
	end
end

local function OnLeave(self)
	GameTooltip:Hide()
end

local function Update(self, event)
	local unit = self.unit
	local element = self.XPRepBar

	--[[ Callback: XPRepBar:PreUpdate(unit)
	Called before the element has been updated.

	* self - the XPRepBar element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local currentXP, minXP, maxXP
	if UnitIsUnit(unit, "player") then
		currentXP, maxXP = UnitXP(unit), UnitXPMax(unit)
	elseif UnitIsUnit(unit, "pet") then
		currentXP, maxXP = GetPetExperience()
	end
	minXP = math.min(0, currentXP)
	
	local name, reaction, minRep, maxRep, currentRep = GetWatchedFactionInfo()
	currentRep = math.abs(minRep - currentRep)
	maxRep = math.abs(minRep - maxRep)

	if(element.xpBar) then
		if( UnitLevel(unit) == GetMaxPlayerLevel() or IsXPUserDisabled() or (UnitIsUnit(unit, "pet") and UnitLevel(unit) == UnitLevel("player")) ) then
			element.xpBar:Hide()
		else
			element.xpBar:SetMinMaxValues(minXP, maxXP)
			element.xpBar:SetValue(currentXP)
			element.xpBar:Show()
			if element.tooltip then
				element.xpBar:EnableMouse(true)
			else
				element.xpBar:EnableMouse(false)
			end
			if( UnitIsUnit(unit, "player") and GetXPExhaustion() ) then
				element.xpBar.rested:SetMinMaxValues(minXP, maxXP)
				element.xpBar.rested:SetValue(math.min(currentXP + GetXPExhaustion(), maxXP))
				element.xpBar.rested:Show()
				element.xpBar.tooltip = string.format(LEVEL.." %s - %s: %s/%s (%.2f%% "..DONE.."), %s "..TUTORIAL_TITLE26..".", UnitLevel(unit), UnitLevel(unit) + 1, formatNumber(currentXP), formatNumber(maxXP), (maxXP > 0 and currentXP / maxXP or 0) * 100, formatNumber(GetXPExhaustion()))
			else
				element.xpBar.rested:Hide()
				element.xpBar.tooltip = string.format(LEVEL.." %s - %s: %s/%s (%.2f%% "..DONE..")", UnitLevel(unit), UnitLevel(unit) + 1, formatNumber(currentXP), formatNumber(maxXP), (maxXP > 0 and currentXP / maxXP or 0) * 100)
			end
		end
	end

	if(element.repBar) then
		if reaction ~= 0 then
			local color = oUF.colors.reaction[reaction]
			element.repBar:SetMinMaxValues(0, maxRep)
			element.repBar:SetValue(currentRep)
			element.repBar.tooltip = string.format("%s (%s): %s/%s (%.2f%% "..DONE..")", name, GetText("FACTION_STANDING_LABEL" .. reaction, UnitSex("player")), formatNumber(currentRep), formatNumber(maxRep), (maxRep > 0 and currentRep / maxRep or 0) * 100)
			element.repBar:SetStatusBarColor(unpack(color))
			if element.repBar.bg then
				element.repBar.bg:SetVertexColor(unpack(color))
			end
			element.repBar:Show()
			if element.tooltip then
				element.repBar:EnableMouse(true)
			else
				element.repBar:EnableMouse(false)
			end
		else
			element.repBar:Hide()
		end
	end

	--[[ Callback: XPRepBar:PostUpdate(unit)
	Called after the element has been updated.

	* self              - the XPRepBar element
	* unit              - the unit for which the update has been triggered (string)
	* minXP             - the minimum xp (number)
	* maxXP             - the maximum xp (number)
	* currentXP         - the amount of xp (number)
	* minRep            - the minimum reputation (number)
	* maxRep            - the maximum reputation (number)
	* currentRep        - the amount of reputation (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, minXP, maxXP, currentXP, minRep, maxRep, currentRep)
	end
end

local function Path(self, ...)
	--[[ Override: XPRepBar.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event
	--]]
	return (self.XPRepBar.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.XPRepBar
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("ENABLE_XP_GAIN", Path, true)
		self:RegisterEvent("DISABLE_XP_GAIN", Path, true)

		if( self.unit == "player" ) then
			self:RegisterEvent("PLAYER_XP_UPDATE", Path, true)
			self:RegisterEvent("UPDATE_EXHAUSTION", Path, true)
			self:RegisterEvent("UPDATE_FACTION", Path, true)
			
		else
			self:RegisterEvent("UNIT_PET_EXPERIENCE", Path, true)
			self:RegisterEvent("UNIT_LEVEL", Path)
		end
		self:RegisterEvent("PLAYER_LEVEL_UP", Path, true)

		if(element.xpBar) then
			if(element.xpBar:IsObjectType("StatusBar") and not element.xpBar:GetStatusBarTexture()) then
				element.xpBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
			element.xpBar:SetScript("OnEnter", OnEnter)
			element.xpBar:SetScript("OnLeave", OnLeave)
			if not element.xpBar.rested or not element.xpBar.rested:IsObjectType("StatusBar") then
				element.xpBar.rested = CreateFrame("StatusBar", nil, element.xpBar)
				element.xpBar.rested:SetFrameLevel(element.xpBar:GetFrameLevel() - 1)
				element.xpBar.rested:SetAllPoints(element.xpBar)
				element.xpBar.rested:SetStatusBarTexture(element.xpBar:GetStatusBarTexture())
			end
		end

		if(element.repBar) then
			if(element.repBar:IsObjectType("StatusBar") and not element.repBar:GetStatusBarTexture()) then
				element.repBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
			element.repBar:SetScript("OnEnter", OnEnter)
			element.repBar:SetScript("OnLeave", OnLeave)
		end

		return true
	end
end

local function Disable(self)
	local element = self.XPRepBar
	if(element) then
		if(element.xpBar) then
			element.xpBar:Hide()
		end

		if(element.repBar) then
			element.repBar:Hide()
		end

		self:UnregisterEvent("ENABLE_XP_GAIN", Path)
		self:UnregisterEvent("DISABLE_XP_GAIN", Path)
		self:UnregisterEvent("PLAYER_XP_UPDATE", Path)
		self:UnregisterEvent("UPDATE_EXHAUSTION", Path)
		self:UnregisterEvent("UPDATE_FACTION", Path)
		self:UnregisterEvent("UNIT_PET_EXPERIENCE", Path)
		self:UnregisterEvent("UNIT_LEVEL", Path)
		self:UnregisterEvent("PLAYER_LEVEL_UP", Path)
	end
end

oUF:AddElement('XPRepBar', Path, Enable, Disable)
