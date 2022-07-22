--[[
# Element: Ghoul Indicator

Handles the updating and visibility of Ghouls.

## Widget

Ghoul - Statusbar UI widget.

## Examples

    -- Position and size
    local Ghoul = CreateFrame('StatusBar', nil, self)
    Ghoul:SetSize(20, 20)
    Ghoul:SetPoint('TOP')
    Ghoul:SetPoint('LEFT')
    Ghoul:SetPoint('RIGHT')

    -- Add a background
    local Background = Ghoul:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(Ghoul)
    Background:SetTexture(1, 1, 1, .5)

    -- Register it with oUF
    Ghoul.bg = Background
    self.Ghoul = Ghoul
--]]

if(select(2, UnitClass('player')) ~= 'DEATHKNIGHT') then return end

local _, ns = ...
local oUF = ns.oUF

local function UpdateGhoul(self, event)
	local element = self.Ghoul

	--[[ Callback: Ghoul:PreUpdate()
	Called before the element has been updated.

	* self - the Ghoul element
	--]]
	if(element.PreUpdate) then element:PreUpdate() end

    local haveGhoul, name, start, duration, icon = GetTotemInfo(1)

	if(not UnitHasVehicleUI('player') and haveGhoul and duration > 0) then
		if element:IsObjectType("Statusbar") then
			element:SetValue(0)
			element:SetScript("OnUpdate",function(self,elapsed)
				self.total = (self.total or 0) + elapsed
				if (self.total >= .01) then
					self.total = 0
					local _, _, startTime, expiration = GetTotemInfo(1)
					if (startTime == 0) then
						self:SetValue(0)
					elseif expiration and expiration > 0 then
						self:SetValue(1 - ((GetTime() - startTime) / expiration))
					end
				end
			end)
		end
	end

	--[[ Callback: Ghoul:PostUpdate()
	Called after the element has been updated.
	* self      - the Ghoul element
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate()
	end
end

local function Path(self, ...)
	--[[ Override: Ghoul.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.Ghoul.Override or UpdateGhoul) (self, ...)
end

local function Update(self, event)
	Path(self, event)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.Ghoul
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_ENTERED_VEHICLE', Path)
		self:RegisterEvent('UNIT_EXITED_VEHICLE', Path)
		self:RegisterEvent('PLAYER_TOTEM_UPDATE', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.Ghoul
	if(element) then

		self:RegisterEvent('UNIT_ENTERED_VEHICLE', Path)
		self:RegisterEvent('UNIT_EXITED_VEHICLE', Path)
		self:UnregisterEvent('PLAYER_TOTEM_UPDATE', Path)
	end
end

oUF:AddElement('Ghoul', Update, Enable, Disable)
