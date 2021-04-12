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
local playerGUID = UnitGUID("player")
local reckoningName = GetSpellInfo(20182)
local currStacks = 0

local function Update(self, event)

	local element = self.Reckoning

	--[[ Callback: Reckoning:PreUpdate(event)
	Called before the element has been updated.

	* self  - the Reckoning element
	]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

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

local function OnCombatlog(self)
	local type, _, sourceGUID, _, _, _, destGUID = select(2,CombatLogGetCurrentEventInfo())
	if type == "SWING_DAMAGE" and sourceGUID == playerGUID then
		if currStacks > 0 then
			currStacks = 0
			Path(self)
		end
	elseif type == "SPELL_EXTRA_ATTACKS" then
		local name = select(13, CombatLogGetCurrentEventInfo())
		if ( name == reckoningName and destGUID == playerGUID and currStacks < 4 ) then
			currStacks = currStacks + 1
			Path(self)
		end 
	end
end

local function resetStacks(self)
	currStacks = 0
	Path(self)
end

local function Enable(self, unit)
	local element = self.Reckoning
	if element and playerClass == "PALADIN" then
		element.__owner = self
		element.__max = #element
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("PLAYER_ENTERING_WORLD", resetStacks, true)
		self:RegisterEvent("PLAYER_DEAD", resetStacks, true)
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", OnCombatlog, true)

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
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", resetStacks)
		self:UnregisterEvent("PLAYER_DEAD", resetStacks)
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", OnCombatlog)
	end
end

oUF:AddElement("Reckoning", Path, Enable, Disable)
