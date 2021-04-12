--[[
# Element: Combat Text

Flashes combat values (heal, damage, ...).

## Widget

CombatText - A frame.

## Options

.feedbackFontHeight     Font Height (integer)
.font                   Font (string)

## Examples

    -- Register with oUF
    self.CombatText = CreateFrame("Frame", nil, self)
    self.CombatText.feedbackFontHeight = 10
    self.CombatText.font = "Fonts\FRIZQT__.TTF"
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	local element = self.CombatText
	local unit = self.unit

	--[[ Callback: CombatText:PreUpdate()
	Called before the element has been updated.

	* self - the CombatText element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	element.feedbackText:SetFont(element.font, element.feedbackFontHeight, "OUTLINE")

	--[[ Callback: CombatText:PostUpdate(object)
	Called after the element has been updated.

	* self         - the CombatText element
	* object       - the parent object
	* inRange      - indicates if the unit was within 40 yards of the player (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(self, inRange, checkedRange, connected)
	end
end

local function Eventhandler(self, event, unit, eventtype, flags, amount, type)
	local element = self.CombatText
	
	if( type == "IMMUNE" ) then
		element.feedbackText:SetTextHeight((element.feedbackFontHeight + 1) * 0.75)
	end
	
	local scale = element.feedbackText:GetStringHeight() / element.feedbackFontHeight
	if( scale > 0 ) then
		element.feedbackText:SetScale(scale)
	end

	CombatFeedback_OnCombatEvent(element, eventtype, flags, amount, type)
end

local function Path(self, ...)
	--[[ Override: CombatText.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
	return (self.CombatText.Override or Update) (self, ...)
end

local function Enable(self)
	local element = self.CombatText
	if(element) then
		element.__owner = self

		if not element.feedbackText or not element.feedbackText:IsObjectType("FontString") then
			element.feedbackText = element:CreateFontString(nil, "ARTWORK")
			element.feedbackText:SetFont("Fonts\FRIZQT__.TTF", 10)
			element.feedbackText:SetShadowColor(0, 0, 0, 1.0)
			element.feedbackText:SetShadowOffset(0.80, -0.80)
			element.feedbackText:SetPoint("CENTER", element, "CENTER")
		end

		self:RegisterEvent("UNIT_COMBAT", Eventhandler)
		element:SetScript("OnUpdate", CombatFeedback_OnUpdate)
		element.feedbackStartTime = 0

		return true
	end
end

local function Disable(self)
	local element = self.CombatText
	if(element) then
		element:SetScript("OnUpdate", nil)
		element:Hide()
		self:UnregisterEvent("UNIT_COMBAT")
	end
end

oUF:AddElement('CombatText', Path, Enable, Disable)