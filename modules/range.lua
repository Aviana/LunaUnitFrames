local Range = {}
LunaUF:RegisterModule(Range, "range", LunaUF.L["Range"])

local Spells = {
	friendly = {
		["PRIEST"] = 2050, -- Lesser Heal
		["DRUID"] = 5185, -- Healing Touch
		["PALADIN"] = 635, -- Holy Light
		["SHAMAN"] = 331, -- Healing Wave
		["WARLOCK"] = 5697, -- Unending Breath
		["MAGE"] = 1459, -- Arcane Intellect
	},
	hostile = {
		["DRUID"] = 5176,  -- Wrath
		["HUNTER"] = 1978, -- Serpent Sting
		["MAGE"] = 116, -- Frostbolt
		["PALADIN"] = 879, -- Exorcism
		["PRIEST"] = 585, -- Smite
		["ROGUE"] = 2094, -- Blind
		["SHAMAN"] = 403, -- Lightning Bolt
		["WARLOCK"] = 686, -- Shadow Bolt
		["WARRIOR"] = 100, -- Taunt
	},
}

local friendlySpell = GetSpellInfo(Spells.friendly[select(2,UnitClass("player"))])
local hostileSpell = GetSpellInfo(Spells.hostile[select(2,UnitClass("player"))])

local function spellCheck(unit)
	if UnitCanAssist("player", unit) then
		if friendlySpell and IsSpellInRange(friendlySpell, unit) == 1 then
			return true
		end
	else
		if hostileSpell and IsSpellInRange(hostileSpell, unit) == 1 then
			return true
		end
	end
	local inRange, checkedRange = UnitInRange(unit)
	if inRange and checkedRange then
		return true
	end
end

local function measureDistance(unit)
	if CheckInteractDistance(unit, 1) then
		return 10
	elseif CheckInteractDistance(unit, 3) then
		return 10
	elseif CheckInteractDistance(unit, 4) then
		return 30
	elseif spellCheck(unit) then
		return 40
	elseif UnitIsVisible(unit) then
		return 100
	else
		return 1000
	end
end

local function CheckRange(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed > LunaUF.db.profile.range.frequency then
		self.elapsed = 0
		local frame = self:GetParent()
		if measureDistance(frame.unit) <= LunaUF.db.profile.range.dist then
			frame:SetRangeAlpha(1)
		else
			frame:SetRangeAlpha(LunaUF.db.profile.range.alpha)
		end
	end
end

function Range:OnEnable(frame)
	frame.range = frame.range or CreateFrame("Frame", nil, frame)
	frame.range.elapsed = 0
	frame.range:SetScript("OnUpdate", CheckRange)
end

function Range:OnDisable(frame)
	frame.range:SetScript("OnUpdate", nil)
	frame:SetRangeAlpha(1)
end

function Range:Update(frame)
	frame.range.elapsed = 1
end