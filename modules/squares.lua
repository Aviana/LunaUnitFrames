local Squares = {}

LunaUF:RegisterModule(Squares, "squares", LunaUF.L["Squares"])

local lCD = LibStub("LibClassicDurations")

local canCure = LunaUF.Units.canCure
local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	tile = true,
	tileSize = 16,
	insets = {left = -1, right = -1, top = -1, bottom = -1},
}
local positions = {
	topright = "TOPRIGHT",
	top = "TOP",
	topleft = "TOPLEFT",
	leftcenter = "LEFTCENTER",
	center = "CENTER",
	rightcenter = "RIGHTCENTER",
	bottomright = "BOTTOMRIGHT",
	bottom = "BOTTOM",
	bottomleft = "BOTTOMLEFT",
}
local indicator = "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\indicator"

local function checkAura(unit, spells, playeronly)
	local spells = {strsplit(";",spells)}
	for k,spell in ipairs(spells) do
		if tonumber(spell) then
			local i, casterunit,_,_,spellID = 1, select(7,UnitAura(unit, 1))
			while spellID do
				if spellID == tonumber(spell) and (not playeronly or playeronly and casterunit and UnitIsUnit(casterunit,"player")) then
					return UnitAura(unit, i)
				end
				i = i + 1
				casterunit,_,_,spellID = select(7, UnitAura(unit, i))
			end
			i, casterunit,_,_,spellID = 1, select(7,UnitAura(unit, 1, "HARMFUL"))
			while spellID do
				if spellID == tonumber(spell) and (not playeronly or playeronly and casterunit and UnitIsUnit(casterunit,"player")) then
					return UnitAura(unit, i, "HARMFUL")
				end
				i = i + 1
				casterunit,_,_,spellID = select(7, UnitAura(unit, i, "HARMFUL"))
			end
		elseif type(spell) == "string" then
			local i, spellName = 1, UnitAura(unit, 1)
			local casterunit = select(7,UnitAura(unit, 1))
			while spellName do
				if spellName == spell and (not playeronly or playeronly and casterunit and UnitIsUnit(casterunit,"player")) then
					return UnitAura(unit, i)
				end
				i = i + 1
				spellName = UnitAura(unit, i)
				casterunit = select(7,UnitAura(unit, i))
			end
			i, spellName = 1, UnitAura(unit, 1, "HARMFUL")
			casterunit = select(7,UnitAura(unit, 1, "HARMFUL"))
			while spellName do
				if spellName == spell and (not playeronly or playeronly and casterunit and UnitIsUnit(casterunit,"player")) then
					return UnitAura(unit, i, "HARMFUL")
				end
				i = i + 1
				spellName = UnitAura(unit, i, "HARMFUL")
				casterunit = select(7,UnitAura(unit, i, "HARMFUL"))
			end
		end
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
	local spellGroups = {strsplit(";",spells)}
	local found
	local j
	local spellGroup
	local spell = ""
	local missingSpell = ""
	for j,spellGroup in ipairs(spellGroups) do
		-- Allow "Arcane Intellect[mana]/Arcane Brilliance[mana]"
		-- Should only show as missing if both are missing.
		-- Should only check mana users.
		local localSpells = {strsplit("/",spellGroup)}
		local k
		for k,spell in ipairs(localSpells) do
			local f1 = spell:find("[mana]")
			if f1 ~= nil then
				spell = spell:gsub("%[mana%]", "")
				if not isManaUser(unit) then
					found = true
				end
			end
			if found == nil or found == false then
				missingSpell = spell
				if tonumber(spell) then
					local i, spellID = 1, select(10,UnitAura(unit, 1))
					while spellID do
						if spellID == tonumber(spell) then
							found = true
						end
						i = i + 1
						spellID = select(10, UnitAura(unit, i))
					end
				elseif type(spell) == "string" then
					local i, spellName = 1, UnitAura(unit, 1)
					while spellName do
						if spellName == spell then
							found = true
						end
						i = i + 1
						spellName = UnitAura(unit, i)
					end
				end
			end
		end
		if found or missingSpell == "" then
			found = nil
		else
			return missingSpell
		end
	end
end

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

function Squares:OnEnable(frame)
	if( not frame.squares ) then
		frame.squares = CreateFrame("Frame", nil, frame)
		frame.squares:SetAllPoints(frame)
		frame.squares:SetFrameLevel(7)
		
		frame.squares.square = {}
		
		for k,v in pairs(positions) do
			frame.squares.square[k] = CreateFrame("Frame", nil, frame.squares)
			frame.squares.square[k]:SetBackdrop(backdrop)
			frame.squares.square[k]:SetBackdropColor(0,0,0)
			frame.squares.square[k].texture = frame.squares.square[k]:CreateTexture(nil, "ARTWORK")
			frame.squares.square[k].texture:SetAllPoints(frame.squares.square[k])
			frame.squares.square[k].cd = CreateFrame("Cooldown", frame:GetName().."CD"..k, frame.squares.square[k] , "CooldownFrameTemplate")
			frame.squares.square[k].cd:ClearAllPoints()
			frame.squares.square[k].cd:SetPoint("TOPLEFT", frame.squares.square[k], "TOPLEFT")
			frame.squares.square[k].cd:SetAllPoints(frame.squares.square[k])
			frame.squares.square[k].cd:SetReverse(true)
			frame.squares.square[k].cd:SetDrawEdge(false)
			frame.squares.square[k].cd:SetDrawSwipe(true)
			frame.squares.square[k].cd:SetSwipeColor(0, 0, 0, 0.8)
			frame.squares.square[k].cd:Hide()
		end
		frame.squares.square["topright"]:SetPoint("TOPRIGHT", frame.squares, "TOPRIGHT", -1, -1)
		frame.squares.square["top"]:SetPoint("TOP", frame.squares, "TOP", 0, -1)
		frame.squares.square["topleft"]:SetPoint("TOPLEFT", frame.squares, "TOPLEFT", 1, -1)
		frame.squares.square["leftcenter"]:SetPoint("RIGHT", frame.squares.square["center"], "LEFT", 0, 0)
		frame.squares.square["center"]:SetPoint("CENTER", frame.squares, "CENTER", 0, 0)
		frame.squares.square["rightcenter"]:SetPoint("LEFT", frame.squares.square["center"], "RIGHT", 0, 0)
		frame.squares.square["bottomright"]:SetPoint("BOTTOMRIGHT", frame.squares, "BOTTOMRIGHT", -1, 1)
		frame.squares.square["bottom"]:SetPoint("BOTTOM", frame.squares, "BOTTOM", 0, 1)
		frame.squares.square["bottomleft"]:SetPoint("BOTTOMLEFT", frame.squares, "BOTTOMLEFT", 1, 1)
	end
	
	frame:RegisterUnitEvent("UNIT_AURA", self, "Update")
	frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", self, "Update")
	frame:RegisterUpdateFunc(self, "Update")
	
end

function Squares:OnDisable(frame)

end

function Squares:OnLayoutApplied(frame, config)
	if not frame.squares then return end
	for pos, frame in pairs(frame.squares.square) do
		frame:SetHeight(config.squares[pos].size)
		frame:SetWidth(config.squares[pos].size)
	end
end

function Squares:Update(frame)
	if not frame.squares or not UnitExists(frame.unit) then return end
	local aggro = (UnitThreatSituation(frame.unit) or 0) > 1
	local config = LunaUF.db.profile.units[frame.unitType].squares
	for pos, square in pairs(frame.squares.square) do
		if not config[pos].enabled then
			square:Hide()
		elseif config[pos].type == "aggro" then
			if aggro and not UnitIsDeadOrGhost(frame.unit) then
				square:Show()
				square.texture:SetTexture(indicator)
				local color = LunaUF.db.profile.colors.hostile
				square.texture:SetVertexColor(color.r, color.g, color.b,1)
				square.cd:Hide()
			else
				square:Hide()
			end
		elseif config[pos].type == "aura" and config[pos].value then
			local _, icon, _, debuffType, duration, expirationTime, caster, _, _, spellID = checkAura(frame.unit, config[pos].value)
			if (not duration or duration == 0) and spellID then
				local Newduration, NewendTime = lCD:GetAuraDurationByUnit(frame.unit, spellID, caster)
				duration = Newduration or duration
				expirationTime = NewendTime or expirationTime
			end
			if icon then
				square:Show()
				if config[pos].texture then
					square.texture:SetTexture(icon)
					square.texture:SetVertexColor(1,1,1,1)
				else
					local color = DebuffTypeColor[debuffType]
					if not color then
						color = {r = 0, g = 0, b = 0}
					end
					square.texture:SetTexture(indicator)
					square.texture:SetVertexColor(color.r, color.g, color.b, 1)
				end
				if duration and config[pos].timer then
					square.cd:Show()
					square.cd:SetCooldown(expirationTime - duration, duration)
				else
					square.cd:Hide()
				end
			else
				square:Hide()
			end
		elseif config[pos].type == "ownaura" and config[pos].value then
			local _, icon, _, debuffType, duration, expirationTime, caster, _, _, spellID = checkAura(frame.unit, config[pos].value, true)
			if (not duration or duration == 0) and spellID then
				local Newduration, NewendTime = lCD:GetAuraDurationByUnit(frame.unit, spellID, "player")
				duration = Newduration or duration
				expirationTime = NewendTime or expirationTime
			end
			if icon then
				square:Show()
				if config[pos].texture then
					square.texture:SetTexture(icon)
					square.texture:SetVertexColor(1,1,1,1)
				else
					local color = DebuffTypeColor[debuffType]
					if not color then
						color = {r = 0, g = 0, b = 0}
					end
					square.texture:SetTexture(indicator)
					square.texture:SetVertexColor(color.r, color.g, color.b, 1)
				end
				if duration and config[pos].timer then
					square.cd:Show()
					square.cd:SetCooldown(expirationTime - duration, duration)
				else
					square.cd:Hide()
				end
			else
				square:Hide()
			end
		elseif config[pos].type == "dispel" then
			local _, icon, _, debuffType, duration, expirationTime = checkDispel(frame.unit)
			if debuffType then
				square:Show()
				local color = DebuffTypeColor[debuffType]
				if config[pos].texture then
					square.texture:SetTexture(icon)
					square.texture:SetVertexColor(1,1,1,1)
				else
					square.texture:SetTexture(indicator)
					square.texture:SetVertexColor(color.r, color.g, color.b, 1)
				end
				if duration and config[pos].timer then
					square.cd:Show()
					square.cd:SetCooldown(expirationTime - duration, duration)
				else
					square.cd:Hide()
				end
			else
				square:Hide()
			end
		elseif config[pos].type == "missing" then
			local spell = checkMissingBuff(frame.unit, config[pos].value)
			if not spell then
				square:Hide()
			else
				local icon = GetSpellTexture(spell)
				square:Show()
				square.texture:SetTexture(icon)
				square.texture:SetVertexColor(1,1,1,1)
				square.cd:Hide()
			end
		else
			square:Hide()
		end
	end
end