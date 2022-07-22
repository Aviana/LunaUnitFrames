--[[
# Element: Reckoning

Your one and only trusty "reckoning bomb" meter.

## Widget

Reckoning - A `table` consisting of 5 StatusBars.

## Notes

A default texture will be applied if the sub-widgets are StatusBars and don"t have a texture set.
If the sub-widgets are StatusBars, their minimum and maximum values will be set to 0 and 1 respectively.

## Examples

    local Reckoning = {}
    for index = 1, 5 do
        local Bar = CreateFrame("StatusBar", nil, self)

        -- Position and size.
        Bar:SetSize(16, 16)
        Bar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", (index - 1) * Bar:GetWidth(), 0)

        Reckoning[index] = Bar
    end

    -- Register with oUF
    self.Reckoning = Reckoning
--]]

local _, ns = ...
local oUF = ns.oUF

local playerClass = select(2,UnitClass("player"))

local function Update(self, event)

	local element = self.Reckoning

	--[[ Callback: Reckoning:PreUpdate(event)
	Called before the element has been updated.

	* self  - the Reckoning element
	]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local i, currStacks, stacks, spellId, _ = 1,.0

	repeat
		stacks, _, _, _, _, _, _, spellId = select(3, UnitBuff("player", i))
		if spellId == 20178 then
			currStacks = stacks
			break
		end
		i = i + 1
	until (not spellId)

-- Do the thing here
	for i = 1, #element do
		local bar = element[i]
		if i <= currStacks then
			if(bar:IsObjectType("StatusBar")) then
				bar:SetValue(1)
				bar:Show()
			else
				bar:Show()
			end
		else
			if(bar:IsObjectType("StatusBar")) then
				bar:SetValue(0)
				bar:Hide()
			else
				bar:Hide()
			end
		end
	end

	--[[ Callback: Reckoning:PostUpdate(stacks)
	Called after the element has been updated.

	* self          - the Reckoning element
	* stacks        - the current amount of reckoning stacks (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(currStacks)
	end
end

local function Path(self, ...)
	--[[ Override: Reckoning.Override(self, event, unit, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.Reckoning.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Reckoning
	if element and playerClass == "PALADIN" then
		element.__owner = self
		element.__max = #element
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_AURA", Path)

		for i = 1, #element do
			local bar = element[i]
			if(bar:IsObjectType("StatusBar")) then
				if(not bar:GetStatusBarTexture()) then
					bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
				end

				bar:SetMinMaxValues(0, 1)
			end
		end

		return true
	end
end

local function Disable(self)
	if(self.Reckoning) then
		self:UnregisterEvent("UNIT_AURA", Path)
	end
end

oUF:AddElement("Reckoning", Path, Enable, Disable)
