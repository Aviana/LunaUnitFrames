--[[
# Element: Totem Indicator

Handles the updating and visibility of totems.

## Widget

Totems - A `table` to hold sub-widgets.

## Sub-Widgets

Totem - Any UI widget.

## Sub-Widget Options

.Icon     - A `Texture` representing the totem icon.
.Cooldown - A `Cooldown` representing the duration of the totem.

## Notes

OnEnter and OnLeave script handlers will be set to display a Tooltip if the `Totem` widget is mouse enabled.

## Examples

    local Totems = {}
    for index = 1, 5 do
        -- Position and size of the totem indicator
        local Totem = CreateFrame('Button', nil, self)
        Totem:SetSize(40, 40)
        Totem:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * Totem:GetWidth(), 0)

        local Icon = Totem:CreateTexture(nil, 'OVERLAY')
        Icon:SetAllPoints()

        local Cooldown = CreateFrame('Cooldown', nil, Totem, 'CooldownFrameTemplate')
        Cooldown:SetAllPoints()

        Totem.Icon = Icon
        Totem.Cooldown = Cooldown

        Totems[index] = Totem
    end

    -- Register with oUF
    self.Totems = Totems
--]]

if(select(2, UnitClass('player')) ~= 'SHAMAN') then return end

local _, ns = ...
local oUF = ns.oUF

local function UpdateTooltip(self)
	GameTooltip:SetTotem(self:GetID())
end

local function OnEnter(self)
	if(not self:IsVisible()) then return end

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	self:UpdateTooltip()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function UpdateTotem(self, event, slot)
	local element = self.Totems
	if(slot > #element) then return end

	--[[ Callback: Totems:PreTotemUpdate(slot)
	Called before the element has been updated.

	* self - the Totems element
	* slot - the slot of the totem to be updated (number)
	--]]
	if(element.PreTotemUpdate) then element:PreTotemUpdate(slot) end

	local totem = element[slot]
	local haveTotem, name, start, duration, icon = GetTotemInfo(slot)
	if(haveTotem and duration > 0) then
		if(totem.Icon) then
			totem.Icon:SetTexture(icon)
		end

		if(totem.Cooldown) then
			totem.Cooldown:SetCooldown(start, duration)
		end

		if totem:IsObjectType("Statusbar") then
			totem:SetValue(0)
			if totem.timer then
				totem.timer:SetText("")
			end
			totem:SetScript("OnUpdate",function(self,elapsed)
				self.total = (self.total or 0) + elapsed
				if (self.total >= .01) then
					self.total = 0
					local _, _, startTime, duration = GetTotemInfo(slot)
					if (startTime == 0) then
						self:SetValue(0)
						self.timer:SetText("")
						self:SetScript("OnUpdate", nil)
					elseif duration and duration > 0 then
						self:SetValue(1 - ((GetTime() - startTime) / duration))
						if totem.timer and not element.disableTimer then
							self.timer:SetText(max(0,ceil(duration + startTime - GetTime())))
						end
					end
				end
			end)
		end
	end

	--[[ Callback: Totems:PostTotemUpdate(slot, haveTotem, name, start, duration, icon)
	Called after the element has been updated.

	* self      - the Totems element
	* slot      - the slot of the updated totem (number)
	* haveTotem - indicates if a totem is present in the given slot (boolean)
	* name      - the name of the totem (string)
	* start     - the value of `GetTime()` when the totem was created (number)
	* duration  - the total duration for which the totem should last (number)
	* icon      - the totem's icon (Texture)
	--]]
	if(element.PostTotemUpdate) then
		return element:PostTotemUpdate(slot, haveTotem, name, start, duration, icon)
	end
end

local function Update(self, event)
	local element = self.Totems

	--[[ Callback: Totems:PreUpdate(slot)
	Called before the element has been updated.

	* self - the Totems element
	* slot - the slot of the totem to be updated (number)
	--]]
	if(element.PreUpdate) then element:PreUpdate(slot) end

	for i=1, 4 do
		UpdateTotem(self, event, i)
	end

	--[[ Callback: Totems:PostUpdate(slot, haveTotem, name, start, duration, icon)
	Called after the element has been updated.

	* self      - the Totems element
	* slot      - the slot of the updated totem (number)
	* haveTotem - indicates if a totem is present in the given slot (boolean)
	* name      - the name of the totem (string)
	* start     - the value of `GetTime()` when the totem was created (number)
	* duration  - the total duration for which the totem should last (number)
	* icon      - the totem's icon (Texture)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(slot, haveTotem, name, start, duration, icon)
	end
end

local function Path(self, ...)
	--[[ Override: Totem.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.Totems.Override or Update) (self, ...)
end

local function Update(self, event)
	for i = 1, #self.Totems do
		Path(self, event, i)
	end
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.Totems
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		for i = 1, #element do
			local totem = element[i]

			totem:SetID(i)

			if(totem:IsMouseEnabled()) then
				totem:SetScript('OnEnter', OnEnter)
				totem:SetScript('OnLeave', OnLeave)

				--[[ Override: Totems[slot]:UpdateTooltip()
				Used to populate the tooltip when the totem is hovered.

				* self - the widget at the given slot index
				--]]
				if(not totem.UpdateTooltip) then
					totem.UpdateTooltip = UpdateTooltip
				end
			end
		end

		self:RegisterEvent('PLAYER_TOTEM_UPDATE', UpdateTotem, true)

		return true
	end
end

local function Disable(self)
	local element = self.Totems
	if(element) then
		for i = 1, #element do
			element[i]:Hide()
		end

		self:UnregisterEvent('PLAYER_TOTEM_UPDATE', UpdateTotem)
	end
end

oUF:AddElement('Totems', Update, Enable, Disable)
