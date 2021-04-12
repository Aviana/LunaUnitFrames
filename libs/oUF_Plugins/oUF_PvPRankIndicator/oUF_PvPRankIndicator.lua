--[[
# Element: PvP Rank Indicator

Toggles the visibility of an indicator based on the unit's leader status.

## Widget

PvPRankIndicator - A texture.

## Notes

Displays a texture corresponding to the current rank in the PvP system

## Examples

    -- Position and size
    local PvPRankIndicator = self:CreateTexture(nil, 'OVERLAY')
    PvPRankIndicator:SetSize(16, 16)
    PvPRankIndicator:SetPoint('BOTTOM', self, 'TOP')

    -- Register it with oUF
    self.PvPRankIndicator = PvPRankIndicator
--]]

local _, ns = ...
local oUF = _G.oUF or ns.oUF

local UnitPVPRank = UnitPVPRank

local function Update(self, event)
	local element = self.PvPRankIndicator
	local unit = self.unit

	--[[ Callback: PvPRankIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the PvPRankIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local rank = UnitPVPRank(unit) or 1
	if rank < 5 then
		element:Hide()
	else
		rank = rank - 4
		if rank < 10 then
			if(element:IsObjectType("Texture")) then
				element:SetTexture("Interface\\PvPRankBadges\\PvPRank0"..rank)
			end
		else
			if(element:IsObjectType("Texture")) then
				element:SetTexture("Interface\\PvPRankBadges\\PvPRank"..rank)
			end
		end
		element:Show()
	end

	--[[ Callback: PvPRankIndicator:PostUpdate(rank)
	Called after the element has been updated.

	* self     - the PvPRankIndicator element
	* rank     - indicates the current rank according to UnitPVPRank (integer)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(rank)
	end
end

local function Path(self, ...)
	--[[ Override: PvPRankIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.PvPRankIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.PvPRankIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("PLAYER_PVP_RANK_CHANGED", Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.PvPRankIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent("PLAYER_PVP_RANK_CHANGED", Path)
	end
end

oUF:AddElement('PvPRankIndicator', Path, Enable, Disable)
