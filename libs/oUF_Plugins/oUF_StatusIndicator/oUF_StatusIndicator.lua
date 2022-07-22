--[[
# Element: Status Indicator

Combines the combat and resting indicators.

## Widget

StatusIndicator - A texture.

## Notes

Custom Textures are not supported

## Examples

    -- Position and size
    local StatusIndicator = self:CreateTexture(nil, 'OVERLAY')
    StatusIndicator:SetSize(16, 16)
    StatusIndicator:SetPoint('TOPLEFT', self)

    -- Register it with oUF
    self.StatusIndicator = StatusIndicator
--]]

local _, ns = ...
local oUF = _G.oUF or ns.oUF

local function Update(self, event)
	local element = self.StatusIndicator
	local unit = self.unit

	--[[ Callback: StatusIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the StatusIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local inCombat = UnitAffectingCombat(unit)
	local isResting = IsResting()
	
	if(inCombat) then
		element:Show()
		if(element:IsObjectType("Texture")) then
			element:SetTexCoord(.5, 1, 0, .49)
		end
	elseif(isResting and unit == "player") then
		element:Show()
		if(element:IsObjectType("Texture")) then
			element:SetTexCoord(0, 0.5, 0, 0.421875)
		end
	else
		element:Hide()
	end

	--[[ Callback: StatusIndicator:PostUpdate(inCombat, isResting)
	Called after the element has been updated.

	* self      - the StatusIndicator element
	* inCombat  - indicates whether the unit is currently in combat (boolean)
	* isResting - indicates whether the unit is currently resting (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(inCombat, isResting)
	end
end

local function Path(self, ...)
	--[[ Override: StatusIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.StatusIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate")
end

local function Enable(self)
	local element = self.StatusIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_COMBAT', Path)
		self:RegisterEvent('UNIT_FLAGS', Path)
		self:RegisterEvent('PLAYER_REGEN_DISABLED', Path, true)
		self:RegisterEvent('PLAYER_REGEN_ENABLED', Path, true)
		self:RegisterEvent("PLAYER_UPDATE_RESTING", Path, true)

		if(element:IsObjectType("Texture") and not element:GetTexture()) then
			element:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.StatusIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_COMBAT', Path)
		self:UnregisterEvent('UNIT_FLAGS', Path)
		self:UnregisterEvent('PLAYER_REGEN_DISABLED', Path)
		self:UnregisterEvent('PLAYER_REGEN_ENABLED', Path)
		self:UnregisterEvent("PLAYER_UPDATE_RESTING", Path)
	end
end

oUF:AddElement("StatusIndicator", Path, Enable, Disable)
