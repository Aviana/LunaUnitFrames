--[[
# Element: Class Indicator

Displays a corresponding class icon.

## Widget

ClassIndicator - A Texture.

## Examples

    -- Position and size
    local ClassIndicator = self:CreateTexture(nil, 'OVERLAY')
    ClassIndicator:SetSize(16, 16)
    ClassIndicator:SetPoint('BOTTOM', self, 'TOP')

    -- Register it with oUF
    self.ClassIndicator = ClassIndicator
--]]

local _, ns = ...
local oUF = _G.oUF or ns.oUF

local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

local function Update(self, event)
	local element = self.ClassIndicator
	local unit = self.unit

	--[[ Callback: ClassIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the ClassIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local className = select(2,UnitClass(unit))
	if( UnitIsPlayer(unit) and className ) then
		local coords = CLASS_ICON_TCOORDS[className]
		element:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
		element:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: ClassIndicator:PostUpdate(className)
	Called after the element has been updated.

	* self     - the ClassIndicator element
	* className - indicates whether the element is shown (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(className)
	end
end

local function Path(self, ...)
	--[[ Override: ClassIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.ClassIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate")
end

local function Enable(self)
	local element = self.ClassIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		return true
	end
end

local function Disable(self)
	local element = self.ClassIndicator
	if(element) then
		element:Hide()
	end
end

oUF:AddElement("ClassIndicator", Path, Enable, Disable)