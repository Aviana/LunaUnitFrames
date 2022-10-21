--[[
# Element: Runes

Handles the visibility and updating of Death Knight's runes.

## Widget

Runes - An `table` holding `StatusBar`s.

## Sub-Widgets

.bg - A `Texture` used as a background. It will inherit the color of the main StatusBar.
.hl - A `Texture` used as a highlight. Used to display rune grace

## Notes

A default texture will be applied if the sub-widgets are StatusBars and don't have a texture set.

## Options

.fadeInactive - Fade inactive runes
.disableTimer - Disable the display of a numerical timer even though the widget is provided
.disableGrace - Disable the display of the rune grace highlight even though the widget is provided

## Sub-Widgets Options

.multiplier - Used to tint the background based on the main widgets R, G and B values. Defaults to 1 (number)[0-1]

## Examples

    local Runes = {}
    for index = 1, 6 do
        -- Position and size of the rune bar indicators
        local Rune = CreateFrame('StatusBar', nil, self)
        Rune:SetSize(120 / 6, 20)
        Rune:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * 120 / 6, 0)

        Runes[index] = Rune
    end

    -- Register with oUF
    self.Runes = Runes
--]]

if(select(2, UnitClass('player')) ~= 'DEATHKNIGHT') then return end

local _, ns = ...
local oUF = ns.oUF

local sort, next = sort, next
local UnitHasVehicleUI = UnitHasVehicleUI
local GetSpecialization = GetSpecialization
local GetRuneCooldown = GetRuneCooldown
local UnitIsUnit = UnitIsUnit
local GetTime = GetTime

local runemap = {1, 2, 5, 6, 3, 4}

local function onUpdate(self, elapsed)
	local min, max = self:GetMinMaxValues()
	local duration = self.duration + elapsed
	self.graceTimer = self.graceTimer - elapsed
	self.duration = duration
	if self.grace and self.graceTimer < 0 then
		self:SetScript('OnUpdate', nil)
		if self.hl then self.hl:Hide() end
	end
	if duration < max then
		self:SetValue(duration)
	end
end

local function onUpdateTimer(self, elapsed)
	local min, max = self:GetMinMaxValues()
	local duration = self.duration + elapsed
	self.graceTimer = self.graceTimer - elapsed
	self.duration = duration
	if self.grace and self.graceTimer < 0 then
		self:SetScript('OnUpdate', nil)
		if self.hl then self.hl:Hide() end
	end
	if duration < max then
		self:SetValue(duration)
		self.timer:SetText(math.max(0,ceil(self.max - duration)))
	end
end

local function resetGrace(self)
	local element = self.Runes
	for i=1,6 do
		local rune = element[i]
		rune.grace = nil
		rune.graceTimer = 0
		if rune.hl then rune.hl:Hide() end
	end
end

local function UpdateColor(self, event)
	local element = self.Runes

	for index, runeID in next, runemap do

		if not GetRuneType(runeID) then return end --Sometimes seems to return nil

		local r, g, b = unpack(oUF.colors.runes[GetRuneType(runeID)])
		element[index]:SetStatusBarColor(r,g,b)

		local bg = element[index].bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	--[[ Callback: Runes:PostUpdateColor(r, g, b)
	Called after the element color has been updated.

	* self - the Runes element
	* r    - the red component of the used color (number)[0-1]
	* g    - the green component of the used color (number)[0-1]
	* b    - the blue component of the used color (number)[0-1]
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(r, g, b)
	end
end

local function ColorPath(self, ...)
	--[[ Override: Runes.UpdateColor(self, event, ...)
	Used to completely override the internal function for updating the widgets' colors.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.Runes.UpdateColor or UpdateColor) (self, ...)
end

local function RuneUpdate(self, event, runeID, usable)
	local currentTime = GetTime()
	local alpha = self.Runes.fadeInactive and 0.4 or 1
	local rune = self.Runes[runemap[runeID]]
	local combat = UnitAffectingCombat("player")

	if not rune then return end

	local start, duration, runeReady = GetRuneCooldown(runeID)
	if runeReady then
		rune:SetMinMaxValues(0, 1)
		rune:SetValue(1)
		rune:SetAlpha(1)
		rune:SetScript('OnUpdate', nil)
		if rune.timer then
			rune.timer:SetText("")
		end
		rune.grace = combat and true
		if rune.graceTimer > 0 and rune.hl and not self.Runes.disableGrace then
			rune.hl:Show()
		else
			rune.hl:Hide()
		end
	elseif start then
		if rune.hl then rune.hl:Hide() end
		rune.graceTimer = rune.grace and 10 or 0
		rune.duration = currentTime - start
		rune .max = duration
		rune:SetMinMaxValues(0, duration)
		rune:SetValue(0)
		if rune.timer and not self.Runes.disableTimer then
			rune:SetScript('OnUpdate', onUpdateTimer)
		else
			rune:SetScript('OnUpdate', onUpdate)
		end
		rune:SetAlpha(alpha)
	end

end

local function Update(self, event)
	local element = self.Runes
	local hasVehicle = UnitHasVehicleUI('player')

	for i=1, 6 do
		element[i]:SetShown(not hasVehicle)
		RuneUpdate(self, event, i)
	end

	--[[ Callback: Runes:PostUpdate(runemap)
	Called after the element has been updated.

	* self    - the Runes element
	* runemap - the ordered list of runes' indices (table)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(runemap, hasVehicle)
	end
end

local function Path(self, ...)
	--[[ Override: Runes.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.Runes.Override or Update) (self, ...)
end

local function AllPath(...)
	Path(...)
	ColorPath(...)
end

local function ForceUpdate(element)
	Path(element.__owner, 'ForceUpdate')
	ColorPath(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.Runes
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		resetGrace(self)

		for i = 1, #element do
			local rune = element[i]
			if(rune:IsObjectType('StatusBar') and not (rune:GetStatusBarTexture() or rune:GetStatusBarAtlas())) then
				rune:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		-- ElvUI block
		if element.IsObjectType and element:IsObjectType("Frame") then
			element:Show()
		end
		-- end block

		self:RegisterEvent('UNIT_ENTERED_VEHICLE', Path)
		self:RegisterEvent('UNIT_EXITED_VEHICLE', Path)
		self:RegisterEvent('PLAYER_REGEN_ENABLED', resetGrace, true)
		self:RegisterEvent('RUNE_TYPE_UPDATE', ColorPath, true)
		self:RegisterEvent('RUNE_POWER_UPDATE', RuneUpdate, true)
		self:RegisterEvent('PLAYER_ENTERING_WORLD', Update, true)

		return true
	end
end

local function Disable(self)
	local element = self.Runes
	if(element) then
		for i = 1, #element do
			element[i]:Hide()
		end

		resetGrace(self)

		-- ElvUI block
		if element.IsObjectType and element:IsObjectType("Frame") then
			element:Hide()
		end
		-- end block

		self:UnregisterEvent('UNIT_ENTERED_VEHICLE', Path)
		self:UnregisterEvent('UNIT_EXITED_VEHICLE', Path)
		self:UnregisterEvent('PLAYER_REGEN_ENABLED', resetGrace)
		self:UnregisterEvent('RUNE_TYPE_UPDATE', ColorPath)
		self:UnregisterEvent('RUNE_POWER_UPDATE', RuneUpdate)
		self:UnregisterEvent('PLAYER_ENTERING_WORLD', Update)
	end
end

oUF:AddElement('Runes', AllPath, Enable, Disable)
