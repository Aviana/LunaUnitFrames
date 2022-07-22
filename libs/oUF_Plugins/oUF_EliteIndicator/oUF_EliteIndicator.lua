--[[
# Element: Elite Indicator

Toggles the visibility of an indicator based on the unit's elite status.

## Widget

EliteIndicator - A texture.

## Notes

Displays a golden/silver dragon texture to indicate elite/rare status. Do NOT set its position or size.

## Options

.side            - Side of the frame the indicator is meant for due to its "opening", defaults to "RIGHT"

## Examples

    -- Position and size
    local EliteIndicator = self:CreateTexture(nil, 'OVERLAY')

    -- Register it with oUF
    self.EliteIndicator = EliteIndicator
--]]

local addonname, ns = ...
local oUF = _G.oUF or ns.oUF

local UnitIsUnit = UnitIsUnit
local UnitClassification = UnitClassification
local strupper = strupper

local function Update(self, event)
	local element = self.EliteIndicator
	local unit = self.unit

	--[[ Callback: EliteIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the EliteIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local classif
	if UnitIsUnit("player", unit) and oUF.LUF_fakePlayerClassification then
		classif = oUF.LUF_fakePlayerClassification
	elseif UnitIsUnit("pet", unit) and element.LUF_fakePetClassification then
		classif = oUF.LUF_fakePetClassification
	else
		classif = UnitClassification(unit)
	end
	
	local suffix = element.side and strupper(element.side) or "RIGHT"
	
	if( classif == "rare" ) then
		if(element:IsObjectType("Texture")) then
			element:SetTexture("Interface\\AddOns\\"..addonname.."\\libs\\oUF_Plugins\\oUF_EliteIndicator\\UI-DialogBox-Silver-Dragon")
			if not element:GetTexture() then element:SetTexture("Interface\\AddOns\\"..addonname.."\\Libs\\oUF_Plugins\\oUF_EliteIndicator\\UI-DialogBox-Silver-Dragon") end
			if suffix == "RIGHT" then
				element:SetTexCoord(1, 0, 0, 1)
			else
				element:SetTexCoord(0, 1, 0, 1)
			end
		end
		element:Show()
	elseif( classif == "elite" or classif == "worldboss" or classif == "rareelite" ) then
		if(element:IsObjectType("Texture")) then
			element:SetTexture(131078)
			if suffix == "RIGHT" then
				element:SetTexCoord(1, 0, 0, 1)
			else
				element:SetTexCoord(0, 1, 0, 1)
			end
		end
		element:Show()
	else
		element:Hide()
	end
	
	-- We place this here for layouts that change the size of their frames
	local height = self:GetHeight()
	local mod
	if element.side and strupper(element.side) == "LEFT" then
		mod = 1
	else
		mod = -1
	end
	height = (0.0004166667*height*height) + (1.725*height)
	element:SetHeight(height)
	element:SetWidth(height)
	element:SetPoint("CENTER", self, element.side and strupper(element.side) or "RIGHT", mod*(self:GetHeight()*0.375), 0)

	--[[ Callback: EliteIndicator:PostUpdate(isLeader)
	Called after the element has been updated.

	* self     - the EliteIndicator element
	* isLeader - indicates whether the element is shown (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(isLeader)
	end
end

local function Path(self, ...)
	--[[ Override: EliteIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.EliteIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate")
end

local function Enable(self)
	local element = self.EliteIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.EliteIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED", Path)
	end
end

oUF:AddElement("EliteIndicator", Path, Enable, Disable)
