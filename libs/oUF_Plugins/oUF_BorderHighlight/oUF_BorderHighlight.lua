--[[
# Element: Border Highlight

Show a "glowing" texture when certain conditions are met.

## Widget

BorderHighlight - A "Table".

## Options

.target           - Highlight when this is your current target (boolean)
.mouseover        - Highlight when your mouse is over this unit (boolean)
.aggro            - Highlight when this unit has aggro (boolean)
.debuff           - Highlight when this unit has a debuff (integer)
                    1 - off (same as nil)
                    2 - Only highlight on debuffs you can dispel
                    3 - Highlight on all dispellable debuffs

#colors
.targetColor      - {1, 1, 1}
.mouseoverColor   - {1, 1, 1}

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture set.

## Examples

    -- Position and size
    local BorderHighlight = {}

    -- Register it with oUF
    self.BorderHighlight = BorderHighlight
--]]

local _, ns = ...
local oUF = ns.oUF

local playerClass = select(2, UnitClass("player"))
local canCure = {}
local cures = {
	["DRUID"] = {[2782] = {"Curse"}, [2893] = {"Poison"}, [8946] = {"Poison"}},
	["PRIEST"] = {[528] = {"Disease"}, [552] = {"Disease"}, [527] = {"Magic"}, [988] = {"Magic"}},
	["PALADIN"] = {[4987] = {"Poison", "Disease", "Magic"}, [1152] = {"Poison", "Disease"}},
	["SHAMAN"] = {[526] = {"Poison", "Disease"}, [51886] = {"Curse", "Poison", "Disease"}},
	["MAGE"] = {[475] = {"Curse"}},
}
cures = cures[playerClass]

local function OnSizeChanged(self)
	if not self then return end
	local x, y = self:GetWidth(), self:GetHeight()
	if x == 0 or y == 0 then return end
	self.top:SetSize(x, self.size)
	self.bottom:SetSize(x, self.size)
	self.left:SetSize(self.size, y + (self.size * 2))
	self.right:SetSize(self.size, y + (self.size * 2))
end

local function Update(self, event)
	local element = self.BorderHighlight
	local unit = self.unit
	if not UnitExists(unit) then return end

	if element.center.size ~= element.size then
		element.center.size = element.size
		OnSizeChanged(element.center)
	end

	--[[ Callback: BorderHighlight:PreUpdate()
	Called before the element has been updated.

	* self - the BorderHighlight element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local hasMouseover = self == GetMouseFocus()
	local isTarget = UnitIsUnit("target", unit)
	local hasAggro = (UnitThreatSituation(unit) or 0) > 1
	local showOwn, showAll, hasDebuff, highlightReason = element.debuff == 2, element.debuff == 3
	if UnitIsFriend(unit, "player") then
		for i=1, 16 do
			local name, _, _, auraType = UnitDebuff(unit, i)
			if( not name ) then break end
			
			if( showOwn and canCure[auraType] and UnitCanAssist("player", unit) or (showAll and auraType) ) then
				hasDebuff = auraType
				break
			end
		end
	end

	local color
	if element.debuff and element.debuff ~= 1 and hasDebuff then
		color = oUF.colors.debuff[hasDebuff]
		highlightReason = "debuff"
	elseif element.aggro and hasAggro then
		color = oUF.colors.threat[4]
		highlightReason = "aggro"
	elseif element.target and isTarget then
		color = element.targetColor
		highlightReason = "target"
	elseif element.mouseover and hasMouseover then
		color = element.mouseoverColor
		highlightReason = "mouseover"
	end
	
	if not color then
		element.center:Hide()
	else
		element.center:Show()
		element.center.top:SetVertexColor(unpack(color))
		element.center.bottom:SetVertexColor(unpack(color))
		element.center.left:SetVertexColor(unpack(color))
		element.center.right:SetVertexColor(unpack(color))
	end

	--[[ Callback: BorderHighlight:PostUpdate(highlightReason)
	Called after the element has been updated.

	* self              - the BorderHighlight element
	* highlightReason   - what type of highlight is shown (nil, "mouseover", "target", "aggro", "debuff") (string)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(highlightReason)
	end
end

local function checkCurableSpells(self, event, arg1)
	if event == "UNIT_PET" and (arg1 ~= "player" or playerClass ~= "WARLOCK") then return end
	table.wipe(canCure)
	
	if playerClass == "WARLOCK" then
		if IsUsableSpell(GetSpellInfo(19505)) then
			canCure["Magic"] = true
		end
	elseif cures then
		for spellID, types in pairs(cures) do
			if( IsPlayerSpell(spellID) ) then
				for _, type in pairs(types) do
					canCure[type] = true
				end
			end
		end
	else
		return
	end
	Update(self, event, self.unit)
end

local function Path(self, ...)
	--[[ Override: BorderHighlight.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.BorderHighlight.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.BorderHighlight
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", Path, true)
		self:RegisterEvent("UNIT_AURA", Path)
		self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Path, true)
		
		self:RegisterEvent("LEARNED_SPELL_IN_TAB", checkCurableSpells, true)
		self:RegisterEvent("PLAYER_LOGIN", checkCurableSpells, true)
		self:RegisterEvent("UNIT_PET", checkCurableSpells, true)

		if not element.center then
			element.center = CreateFrame("Frame", nil, self)
			element.center:SetScript("OnSizeChanged", OnSizeChanged)
			element.center:SetAllPoints(self)
			element.center.top = element.center:CreateTexture(nil, "BACKGROUND")
			element.center.top:SetTexture([[Interface\Buttons\WHITE8X8]])
			element.center.top:SetPoint("BOTTOMLEFT", element.center, "TOPLEFT")
			element.center.bottom = element.center:CreateTexture(nil, "BACKGROUND")
			element.center.bottom:SetTexture([[Interface\Buttons\WHITE8X8]])
			element.center.bottom:SetPoint("TOPLEFT", element.center, "BOTTOMLEFT")
			element.center.left = element.center:CreateTexture(nil, "BACKGROUND")
			element.center.left:SetTexture([[Interface\Buttons\WHITE8X8]])
			element.center.left:SetPoint("BOTTOMRIGHT", element.center.bottom, "BOTTOMLEFT")
			element.center.right = element.center:CreateTexture(nil, "BACKGROUND")
			element.center.right:SetTexture([[Interface\Buttons\WHITE8X8]])
			element.center.right:SetPoint("BOTTOMLEFT", element.center.bottom, "BOTTOMRIGHT")
		end
		element.size = element.size or 1
		element.center:Hide()

		checkCurableSpells(self)

		return true
	end
end

local function Disable(self)
	local element = self.BorderHighlight
	if(element) then
		element.center:Hide()
		
		self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT", Path)
		self:UnregisterEvent("UNIT_AURA", Path)
		self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path)
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", Path)
		
		self:UnregisterEvent("LEARNED_SPELL_IN_TAB", checkCurableSpells)
		self:UnregisterEvent("PLAYER_LOGIN", checkCurableSpells)
		self:UnregisterEvent("UNIT_PET", checkCurableSpells)
	end
end

oUF:AddElement("BorderHighlight", Path, Enable, Disable)