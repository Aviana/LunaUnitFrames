--[[
# Element: Status Portraits

Provides portraits that can also display cc effects.

## Widget

StatusPortrait - A table with a player model and a texture

## Options

.showStatus - Show interrupt auras as an overlay. (boolean)

## Notes

A question mark model will be used if the widget is a PlayerModel and the client doesn't have the model information for
the unit.

## Examples

    -- 3D Portrait
    -- Position and size
    local StatusPortrait = CreateFrame('PlayerModel', nil, self)
    StatusPortrait:SetSize(32, 32)
    StatusPortrait:SetPoint('RIGHT', self, 'LEFT')

    -- Register it with oUF
    self.StatusPortrait = StatusPortrait

    -- 2D Portrait
    local StatusPortrait = self:CreateTexture(nil, 'OVERLAY')
    StatusPortrait:SetSize(32, 32)
    StatusPortrait:SetPoint('RIGHT', self, 'LEFT')

    -- Register it with oUF
    self.StatusPortrait = StatusPortrait
--]]

local _, ns = ...
local oUF = ns.oUF

local lCD = LibStub("LibClassicDurations")
local LAT = LibStub("LibAuraTypes")
local SL = LibStub("LibSpellLocks")

local function cutTexture(texture)
	local height = texture:GetHeight()
	local width = texture:GetWidth()
	local cutoff
	if height < width then
		cutoff = ((width - height) / 2) / width * 0.9
		texture:SetTexCoord(0.1, 0.9, 0.1 + cutoff, 0.9 - cutoff)
	elseif height > width then
		cutoff = ((height - width) / 2) / height * 0.9
		texture:SetTexCoord(0.1 + cutoff, 0.9 - cutoff, 0.1, 0.9)
	else
		texture:SetTexCoord(0.10, 0.90, 0.10, 0.90)
	end
end

local function Update(self, event, unit)
	if(not unit or not UnitIsUnit(self.unit, unit)) then return end

	--[[ Callback: StatusPortrait:PreUpdate(unit)
	Called before the element has been updated.

	* self - the StatusPortrait element
	* unit - the unit for which the update has been triggered (string)
	--]]

	local element = self.StatusPortrait
	if not element.showStatus and (event == "UNIT_AURA" or event == "UPDATE_INTERRUPT") then return end
	
	local maxPrio, spellType, icon, duration, expirationTime = 0
	if element.showStatus then
		local CUTOFF_AURA_TYPE = element.verbosePortraitIcon and "SPEED_BOOST" or "SILENCE"
		local PRIO_SILENCE = LAT.GetAuraTypePriority(CUTOFF_AURA_TYPE, UnitCanAttack("player",unit))
		icon, duration, expirationTime = select(3,SL:GetSpellLockInfo(unit))
		if not icon then
			for i=1, 32 do
				local name, tmpicon, _, _, tmpduration, tmpexpirationTime, _, _, _, spellId = lCD:UnitAura(unit, i, "HELPFUL")
				if not name then break end
				local prio = LAT.GetAuraInfo(spellId, UnitCanAttack("player",unit))
				if prio and prio > maxPrio and prio >= PRIO_SILENCE then
					maxPrio = prio
					icon = tmpicon
					duration = tmpduration
					expirationTime = tmpexpirationTime
				end
			end
			for i=1, 16 do
				local name, tmpicon, _, _, tmpduration, tmpexpirationTime, _, _, _, spellId = lCD:UnitAura(unit, i, "HARMFUL")
				if not name then break end
				local prio = LAT.GetAuraInfo(spellId, UnitCanAttack("player",unit))
				if prio and prio > maxPrio and prio >= PRIO_SILENCE then
					maxPrio = prio
					icon = tmpicon
					duration = tmpduration
					expirationTime = tmpexpirationTime
				end
			end
		end
	end
	
	if(element.PreUpdate) then element:PreUpdate(unit) end

	if icon then
		element.texture:SetTexture(icon)
		element.texture:SetTexCoord(0.10, 0.90, 0.10, 0.90)
		element.texture:Show()
		element.model:Hide()
		element.texture.cd:Show()
		element.texture.cd:SetCooldown(expirationTime - duration, duration)
		element.texture.hasStatus = true
		return
	end

	local guid = UnitGUID(unit)
	local isAvailable = UnitIsConnected(unit) and UnitIsVisible(unit)
	element.stateChanged = event == "UNIT_PORTRAIT_UPDATE" or event == "OnShow" or event == "RefreshUnit" or element.guid ~= guid or element.state ~= isAvailable or (not icon and element.texture.hasStatus)
	if element.stateChanged then
		element.state = isAvailable
		element.guid = guid
		element.texture.cd:Hide()
		element.texture.hasStatus = nil
		if element.type == "3D" or element.type == "class" and not UnitIsPlayer(unit) then
			if not isAvailable then
				element.model:SetCamDistanceScale(0.5)
				element.model:SetPortraitZoom(0)
				element.model:SetModelScale(2)
				element.model:SetPosition(0, 0, -0.08)
				element.model:ClearModel()
				element.model:SetModel([[Interface\Buttons\TalkToMeQuestionMark.m2]])
			else
				element.model:SetCamDistanceScale(1)
				element.model:SetPortraitZoom(1)
				element.model:SetPosition(0, 0, 0)
				element.model:ClearModel()
				element.model:SetUnit(unit)
			end
			element.texture:Hide()
			element.model:Show()
		elseif element.type == "class" or element.type == "2dclass" and UnitIsPlayer(unit) then
			local class = select(2,UnitClass(unit)) or "WARRIOR"
			element.texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			element.texture:SetTexCoord(CLASS_ICON_TCOORDS[class][1], CLASS_ICON_TCOORDS[class][2], CLASS_ICON_TCOORDS[class][3], CLASS_ICON_TCOORDS[class][4])
			element.texture:Show()
			element.model:Hide()
		elseif not element.customTexture then
			cutTexture(element.texture)
			SetPortraitTexture(element.texture, unit)
			element.texture:Show()
			element.model:Hide()
		end
	end

	--[[ Callback: StatusPortrait:PostUpdate(unit)
	Called after the element has been updated.

	* self - the StatusPortrait element
	* unit - the unit for which the update has been triggered (string)
	* event - the event (string)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, event)
	end
end

local function Path(self, ...)
	--[[ Override: StatusPortrait.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	return (self.StatusPortrait.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.StatusPortrait
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if element.texture and not element.texture.cd then
			element.texture.cd = CreateFrame("Cooldown", unit.."PortraitCooldown", self, "CooldownFrameTemplate")
			element.texture.cd:SetAllPoints(element.model)
			element.texture.cd:SetReverse(true)
		end

		self:RegisterEvent("UNIT_MODEL_CHANGED", Path)
		self:RegisterEvent("UNIT_PORTRAIT_UPDATE", Path)
		self:RegisterEvent("PORTRAITS_UPDATED", Path, true)
		self:RegisterEvent("UNIT_CONNECTION", Path)
		self:RegisterEvent("UNIT_AURA", Path)

		local function OnUpdate(event, destGUID)
			if self.StatusPortrait and self:IsVisible() then
				if self.unit and UnitGUID(self.unit) == destGUID then
					Path(self, event, self.unit)
				end
			end
		end

		SL.RegisterCallback(element, "UPDATE_INTERRUPT", OnUpdate)

		-- The quest log uses PARTY_MEMBER_{ENABLE,DISABLE} to handle updating of
		-- party members overlapping quests. This will probably be enough to handle
		-- model updating.
		--
		-- DISABLE isn't used as it fires when we most likely don't have the
		-- information we want.
		if(unit == 'party') then
			self:RegisterEvent('PARTY_MEMBER_ENABLE', Path)
		end

		element.model:Show()

		return true
	end
end

local function Disable(self)
	local element = self.StatusPortrait
	if(element) then
		element.model:Hide()

		self:UnregisterEvent('UNIT_MODEL_CHANGED', Path)
		self:UnregisterEvent('UNIT_PORTRAIT_UPDATE', Path)
		self:UnregisterEvent('PORTRAITS_UPDATED', Path)
		self:UnregisterEvent('PARTY_MEMBER_ENABLE', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
	end
end

oUF:AddElement('StatusPortrait', Path, Enable, Disable)