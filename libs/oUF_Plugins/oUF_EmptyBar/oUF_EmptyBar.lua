--[[
# Element: Empty Bar

An empty bar to fill space / place tags on.

## Widget

Empty - A `StatusBar`.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture set.

## Options

.smoothGradient                   - 9 color values to be used with the .colorSmooth option (table)
.alpha............................- Transparency (number)[0-1]

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorReaction     - Use to color by reaction (string)
                     'player' = players only
                     'NPC/hostile player' = npcs and hostile players
                     'npc' = npc only
                     'both' = players and npcs
.colorClass        - Use `self.colors.class[class]` to color the bar based on unit class. `class` is defined by the
                     second return of [UnitClass](http://wowprogramming.com/docs/api/UnitClass.html) (boolean)

## Sub-Widgets Options

.multiplier - Used to tint the background based on the main widgets R, G and B values. Defaults to 1 (number)[0-1]

## Examples

    -- Position and size
    local Empty = CreateFrame('StatusBar', nil, self)
    Empty:SetHeight(20)
    Empty:SetPoint('TOP')
    Empty:SetPoint('LEFT')
    Empty:SetPoint('RIGHT')

    -- Options
    Empty.colorClass = true
    Empty.colorReaction = "npc"

    -- Register it with oUF
    self.Empty = Empty
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(not unit or self.unit ~= unit) then return end
	local element = self.Empty

	--[[ Callback: Empty:PreUpdate(unit)
	Called before the element has been updated.

	* self - the Empty element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local r, g, b, t
	if element.colorReaction and (element.colorReaction == "both" or element.colorReaction == "npc" and not UnitIsPlayer(unit) or element.colorReaction == "player" and UnitIsPlayer(unit) or element.colorReaction == "NPC/hostile player" and (not UnitIsPlayer(unit) or not UnitIsFriend(unit, "player"))) then
		t = self.colors.reaction[UnitReaction(unit, 'player')]
	elseif element.colorClass and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		element:SetStatusBarColor(r, g, b, element.alpha or 1)
		element:SetValue(1)
	else
		element:SetValue(0)
	end

	--[[ Callback: Empty:PostUpdate(unit)
	Called after the element has been updated.

	* self - the Empty element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PostUpdate) then
		element:PostUpdate(unit)
	end
end

local function Path(self, event, ...)
	--[[ Override: Empty.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	(self.Empty.Override or Update) (self, event, ...);
end

local function ForceUpdate(element)
	Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Empty
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_FACTION', Path)

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		element:SetMinMaxValues(0,1)

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.Empty
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_FACTION', Path)
	end
end

oUF:AddElement('Empty', Path, Enable, Disable)
