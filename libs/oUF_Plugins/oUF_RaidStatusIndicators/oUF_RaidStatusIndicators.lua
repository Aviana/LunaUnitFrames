--[[
# Element: Raid Status Indicators

Shows different statuses for group play (aggro, auras, dispel).

## Widget

RaidStatusIndicators - A `table` containing frames with a .texture to show the status on.

## Sub Widget Options

.texture     - The texture object (texture)
.type        - Type of indicator (string)
               "aggro", "legacythreat", "aura", "dispel", "missing", "ownaura"
.showTexture - Show corresponding icon on aura / dispel type instead of a color (boolean)
.timer       - Show spinning timer (boolean)
.value      .- Table containing string buff/debuff names. For missing its a table of tables of strings. Tables are logically linked "AND" and strings in the tables themselves are logically linked "OR"

## Notes

???

## Examples

    -- Position and size
    local RaidStatusIndicators = {}

    local indicator = CreateFrame("Frame", nil, self)
    indicator.texture = indicator:CreateTexture(nil, "OVERLAY")
    indicator.texture:SetAllPoints(indicator)
    indicator.type = "aggro"

    -- Register with oUF
    self.RaidStatusIndicators = {
        indicator = indicator,
    }
--]]

local _, ns = ...
local oUF = ns.oUF

local lCD = LibStub("LibClassicDurations")
local Vex = LibStub("LibVexation-1.0")

local playerClass = select(2, UnitClass("player"))
local canCure = {}
local cures = {
	["DRUID"] = {[2782] = {"Curse"}, [2893] = {"Poison"}, [8946] = {"Poison"}},
	["PRIEST"] = {[528] = {"Disease"}, [552] = {"Disease"}, [527] = {"Magic"}, [988] = {"Magic"}},
	["PALADIN"] = {[4987] = {"Poison", "Disease", "Magic"}, [1152] = {"Poison", "Disease"}},
	["SHAMAN"] = {[2870] = {"Disease"}, [526] = {"Poison"}},
	["MAGE"] = {[475] = {"Curse"}},
}
cures = cures[playerClass]

local function checkDispel(unit)
	if not UnitCanAssist("player", unit) then return end
	local i, name, _, _, debuffType = 1, UnitDebuff(unit, 1)
	while name do
		if canCure[debuffType] then
			return lCD:UnitAura(unit, i, "HARMFUL")
		end
		i = i + 1
		name, _, _, debuffType = UnitDebuff(unit, i)
	end
end

local function isManaUser(unit)
	local unitClass = select(2, UnitClass(unit))
	if unitClass == "ROGUE" or unitClass == "WARRIOR" then
		return false
	else
		return true
	end
end

local function checkMissingBuff(unit, spells)
	local found, missingSpell
	for _, spellGroup in ipairs(spells) do
		-- Allow "Arcane Intellect[mana]/Arcane Brilliance[mana]"
		-- Should only show as missing if both are missing.
		-- Should only check mana users.
--		local localSpells = {strsplit("/",spellGroup)}
		for _,spell in ipairs(spellGroup) do
			if strfind(spell, "%[mana%]") then
				spell = spell:gsub("%[mana%]", "")
				if not isManaUser(unit) then
					found = true
				end
			end
			if not found then
				missingSpell = spell
				spell = tonumber(spell) or select(7, GetSpellInfo(spell))
				if not spell then
					found = true
				else
					local i, spellID = 1, select(10,UnitAura(unit, 1))
					while spellID do
						if spellID == spell then
							found = true
						end
						i = i + 1
						spellID = select(10, UnitAura(unit, i))
					end
				end
			end
		end
		if found or not missingSpell then
			found = nil
		else
			return missingSpell
		end
	end
end

local function checkAura(unit, spells, playeronly)
	for k,spell in ipairs(spells) do
		if tonumber(spell) then
			local i, casterunit,_,_,spellID = 1, select(7,UnitAura(unit, 1))
			while spellID do
				if spellID == tonumber(spell) and (not playeronly or playeronly and casterunit and UnitIsUnit(casterunit,"player")) then
					return lCD:UnitAura(unit, i)
				end
				i = i + 1
				casterunit,_,_,spellID = select(7, UnitAura(unit, i))
			end
			i, casterunit,_,_,spellID = 1, select(7,UnitAura(unit, 1, "HARMFUL"))
			while spellID do
				if spellID == tonumber(spell) and (not playeronly or playeronly and casterunit and UnitIsUnit(casterunit,"player")) then
					return lCD:UnitAura(unit, i, "HARMFUL")
				end
				i = i + 1
				casterunit,_,_,spellID = select(7, UnitAura(unit, i, "HARMFUL"))
			end
		elseif type(spell) == "string" then
			local i, spellName = 1, UnitAura(unit, 1)
			local casterunit = select(7,UnitAura(unit, 1))
			local lowerSpell = strlower(spell)
			while spellName do
				if strmatch(strlower(spellName),lowerSpell) and (not playeronly or playeronly and casterunit and UnitIsUnit(casterunit,"player")) then
					return lCD:UnitAura(unit, i)
				end
				i = i + 1
				spellName = UnitAura(unit, i)
				casterunit = select(7,UnitAura(unit, i))
			end
			i, spellName = 1, UnitAura(unit, 1, "HARMFUL")
			casterunit = select(7,UnitAura(unit, 1, "HARMFUL"))
			while spellName do
				if strmatch(strlower(spellName),lowerSpell) and (not playeronly or playeronly and casterunit and UnitIsUnit(casterunit,"player")) then
					return lCD:UnitAura(unit, i, "HARMFUL")
				end
				i = i + 1
				spellName = UnitAura(unit, i, "HARMFUL")
				casterunit = select(7,UnitAura(unit, i, "HARMFUL"))
			end
		end
	end
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.RaidStatusIndicators

	--[[ Callback: RaidStatusIndicators:PreUpdate(unit)
	Called before the element has been updated.

	* self - the RaidStatusIndicators element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local hasAggro = UnitThreatSituation(UnitExists(unit) and unit or "player")
	local legacyThreat = Vex and Vex:GetUnitAggroByUnitId(unit)
	local icon, _, dispelType, duration, expirationTime = select(2, checkDispel(unit))
	local hasAura, isMissing, hasOwn

	for _, indicator in pairs(element) do
		if type(indicator) == "table" then
			if indicator.type then
				if indicator.type == "aggro" then
					if hasAggro and hasAggro > 0 then
						indicator:Show()
						indicator.cd:Hide()
						
						indicator.texture:SetTexture([[Interface\Buttons\WHITE8X8]])
						
						local color = hasAggro == 1 and oUF.colors.reaction[4] or oUF.colors.reaction[1]
						indicator.texture:SetVertexColor(unpack(color))
					else
						indicator:Hide()
					end
				elseif indicator.type == "legacythreat" then
					if legacyThreat then
						indicator:Show()
						indicator.cd:Hide()
						
						indicator.texture:SetTexture([[Interface\Buttons\WHITE8X8]])
						
						local color = oUF.colors.reaction[1]
						indicator.texture:SetVertexColor(unpack(color))
					else
						indicator:Hide()
					end
				elseif indicator.type == "aura" and indicator.nameID then
					local hasicon, count, Type, hasduration, hasexpirationTime = select(2, checkAura(unit, indicator.nameID))
					if hasicon then
						indicator:Show()
						if indicator.showTexture then
							indicator.texture:SetTexture(hasicon)
							indicator.texture:SetVertexColor(1,1,1)
						else
							local color = oUF.colors.debuff[Type]
							indicator.texture:SetTexture([[Interface\Buttons\WHITE8X8]])
							if color then
								indicator.texture:SetVertexColor(unpack(color))
							else
								indicator.texture:SetVertexColor(0,0,0)
							end
						end
						if indicator.timer then
							indicator.cd:Show()
							indicator.cd:SetCooldown(hasexpirationTime - hasduration, hasduration)
						else
							indicator.cd:Hide()
						end
						if indicator.count then
							indicator.count:Show()
							indicator.count:SetText(count > 1 and count)
						else
							indicator.count:Hide()
						end
					else
						indicator:Hide()
					end
				elseif indicator.type == "dispel" then
					if dispelType then
						indicator:Show()
						if indicator.showTexture then
							indicator.texture:SetTexture(icon)
							indicator.texture:SetVertexColor(1,1,1)
						else
							local color = oUF.colors.debuff[dispelType]
							indicator.texture:SetTexture([[Interface\Buttons\WHITE8X8]])
							indicator.texture:SetVertexColor(unpack(color))
						end
						if indicator.timer then
							indicator.cd:Show()
							indicator.cd:SetCooldown(expirationTime - duration, duration)
						else
							indicator.cd:Hide()
						end
					else
						indicator:Hide()
					end
				elseif indicator.type == "missing" and indicator.nameID then
					isMissing = checkMissingBuff(unit, indicator.nameID)
					if isMissing then
						indicator:Show()
						indicator.cd:Hide()
						if indicator.showTexture then
							indicator.texture:SetTexture(GetSpellTexture(isMissing))
							indicator.texture:SetVertexColor(1,1,1)
						else
							indicator.texture:SetTexture([[Interface\Buttons\WHITE8X8]])
							local color = oUF.colors.debuff["none"]
							if not color then
								indicator.texture:SetVertexColor(0,0,0)
							else
								indicator.texture:SetVertexColor(unpack(color))
							end
						end
					else
						indicator:Hide()
					end
				elseif indicator.type == "ownaura" and indicator.nameID then
					local ownicon, count, debuffType, ownduration, ownexpirationTime = select(2, checkAura(unit, indicator.nameID, true))
					if ownicon then
						indicator:Show()
						if indicator.showTexture then
							indicator.texture:SetTexture(ownicon)
							indicator.texture:SetVertexColor(1,1,1)
						else
							indicator.texture:SetTexture([[Interface\Buttons\WHITE8X8]])
							local color = oUF.colors.debuff[debuffType]
							if not color then
								indicator.texture:SetVertexColor(0,0,0)
							else
								indicator.texture:SetVertexColor(unpack(color))
							end
						end
						if indicator.timer then
							indicator.cd:Show()
							indicator.cd:SetCooldown(ownexpirationTime - ownduration, ownduration)
						else
							indicator.cd:Hide()
						end
						if indicator.count then
							indicator.count:Show()
							indicator.count:SetText(count > 1 and count)
						else
							indicator.count:Hide()
						end
					else
						indicator:Hide()
					end
				else
					indicator:Hide()
				end
			end
		end
	end

	--[[ Callback: RaidStatusIndicators:PostUpdate(unit, hasAggro, dispelType)
	Called after the element has been updated.

	* self          - the RaidStatusIndicators element
	* unit          - the unit for which the update has been triggered (string)
	* hasAggro      - the aggro status of the unit as according to "UnitDetailedThreatSituation" (number)
	* dispelType    - current affliction as returned by "UnitAura" (string)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, hasAggro, dispelType, hasAura, isMissing, hasOwn)
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
	--[[ Override: RaidStatusIndicators.Override(self, event, unit, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.RaidStatusIndicators.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.RaidStatusIndicators
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		for name,indicator in pairs(element) do
			if type(indicator) == "table" then
				if not indicator.cd then
					indicator.cd = CreateFrame("Cooldown", self:GetName()..name.."RaidStatusCD", indicator, "CooldownFrameTemplate")
					indicator.cd:SetDrawEdge(false)
					indicator.cd:SetDrawSwipe(true)
					indicator.cd:SetReverse(true)
					indicator.cd:SetSwipeColor(0, 0, 0, 0.8)
					indicator.cd:SetAllPoints(indicator)
				end

				if not indicator.count then
					local countFrame = CreateFrame('Frame', nil, indicator)
					countFrame:SetAllPoints(indicator)
					countFrame:SetFrameLevel(indicator.cd:GetFrameLevel() + 1)

					indicator.count = countFrame:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
					local fontName = indicator.count:GetFont()
					indicator.count:SetFont(fontName, 10, "OUTLINE")
					indicator.count:SetPoint('BOTTOMRIGHT', countFrame, 'BOTTOMRIGHT', -1, 0)
				end
			end
		end

		local function LegacyThreatUpdate(event, guid)
			if guid == UnitGUID(self.unit) then
				Path(self, event, self.unit)
			end
		end

		if Vex then
			Vex.RegisterCallback(element, "Vexation_gained", LegacyThreatUpdate)
			Vex.RegisterCallback(element, "Vexation_lost", LegacyThreatUpdate)
		end

		self:RegisterEvent("UNIT_AURA", Path)
		self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path)
		self:RegisterEvent("LEARNED_SPELL_IN_TAB", checkCurableSpells, true)
		self:RegisterEvent("PLAYER_LOGIN", checkCurableSpells, true)
		self:RegisterEvent("UNIT_PET", checkCurableSpells, true)

		checkCurableSpells(self)

		return true
	end
end

local function Disable(self)
	local element = self.RaidStatusIndicators
	if(element) then

		if Vex then
			Vex.UnregisterCallback(element, "Vexation_gained")
			Vex.UnregisterCallback(element, "Vexation_lost")
		end

		self:UnregisterEvent("UNIT_AURA", Path)
		self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path)
		self:UnregisterEvent("LEARNED_SPELL_IN_TAB", checkCurableSpells)
		self:UnregisterEvent("PLAYER_LOGIN", checkCurableSpells)
		self:UnregisterEvent("UNIT_PET", checkCurableSpells)
		
	end
end

oUF:AddElement('RaidStatusIndicators', Path, Enable, Disable)
