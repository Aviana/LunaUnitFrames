LUF = select(2, ...)

local oUF = LUF.oUF

LUF.overrides = {}

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
		elseif select(2,UnitClass("player")) == "WARRIOR" and IsSpellInRange(355, unit) == 1 then
			return true
		end
	end
	local inRange, checkedRange = UnitInRange(unit)
	if inRange and checkedRange then
		return true
	end
end

local function measureDistance(unit)
	if CheckInteractDistance(unit, 3) then
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

LUF.overrides["Range"] = {}
LUF.overrides["Range"].Update = function(self, event)
	if self.pauseRange then return end
	
	local element = self.Range
	local unit = self.unit

	--[[ Callback: BetterRange:PreUpdate()
	Called before the element has been updated.

	* self - the BetterRange element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local range
	local connected = UnitIsConnected(unit)
	if(connected) then
		range = measureDistance(unit)
		element.__owner.currRange = range
		if(range > element.range) then
			self:SetAlpha(element.outsideAlpha)
		else
			self:SetAlpha(element.insideAlpha)
		end
	else
		self:SetAlpha(element.insideAlpha)
	end

	--[[ Callback: BetterRange:PostUpdate(object, inRange, checkedRange, isConnected)
	Called after the element has been updated.

	* self         - the BetterRange element
	* object       - the parent object
	* inRange      - indicates if the unit was within 40 yards of the player (boolean)
	* checkedRange - indicates if the range check was actually performed (boolean)
	* isConnected  - indicates if the unit is online (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(self, range, connected)
	end
end

LUF.overrides["LeaderIcon"] = {}
LUF.overrides["LeaderIcon"].Update = function(self, event)
	local element = self.LeaderIndicator
	local unit = self.unit

	--[[ Callback: LeaderIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the LeaderIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local isLeader = UnitLeadsAnyGroup(unit)
	if IsInInstance() then
		isLeader = UnitIsGroupLeader(unit)
	end

	local isAssistant = UnitInRaid(unit) and UnitIsGroupAssistant(unit) and not UnitIsGroupLeader(unit)

	if(isLeader) then
		element:Show()
		if(element:IsObjectType("Texture")) then
			element:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
		end
	elseif(isAssistant) then
		element:Show()
		if(element:IsObjectType("Texture")) then
			element:SetTexture([[Interface\GroupFrame\UI-Group-AssistantIcon]])
		end
	else
		element:Hide()
	end

	--[[ Callback: LeaderIndicator:PostUpdate(isLeader, isAssistant)
	Called after the element has been updated.

	* self     - the LeaderIndicator element
	* isLeader - indicates whether the element is shown (boolean)
	* isAssistant - indicates whether the element is shown (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(isLeader, isAssistant)
	end
end

LUF.overrides["Health"] = {}
LUF.overrides["Health"].UpdateColor = function(self, event, unit)
	if(not unit or self.unit ~= unit) then return end
	local element = self.Health

	local r, g, b, t
	if(element.colorDisconnected and not UnitIsConnected(unit)) then
		t = self.colors.disconnected
	elseif(element.colorCivilian and UnitIsCivilian(unit) and UnitCanAttack("player", unit)) then
		t = self.colors.civilian
	elseif(element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		t = self.colors.tapped
	elseif(element.colorHappiness and UnitIsUnit(unit, "pet") and GetPetHappiness()) then
		t = self.colors.happiness[GetPetHappiness()]
	elseif(element.colorClass and UnitIsPlayer(unit)) or
		(element.colorClassNPC and not UnitIsPlayer(unit)) or
		((element.colorClassPet or element.colorPetByUnitClass) and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		if element.colorPetByUnitClass then unit = unit == 'pet' and 'player' or gsub(unit, 'pet', '') end
		local class = select(2, UnitClass(unit))
		t = self.colors.class[class]
	elseif(UnitReaction(unit, 'player') and (element.colorReaction == "both" or element.colorReaction == "player" and UnitIsPlayer(unit) or element.colorReaction == "npc" and not UnitIsPlayer(unit))) then
		t = self.colors.reaction[UnitReaction(unit, 'player')]
	elseif(element.colorSmooth) then
		r, g, b = self:ColorGradient(element.cur or 1, element.max or 1, unpack(element.smoothGradient or self.colors.smooth))
	elseif(element.colorHealth) then
		t = self.colors.health
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	local bg = element.bg
	if(b) then
		if element.colorInvert and UnitIsConnected(unit) then
			element:SetStatusBarColor(0, 0, 0, 1)
			
			if(bg) then
				local mu = bg.multiplier or 1
				bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		else
			element:SetStatusBarColor(r, g, b)

			if(bg) then
				local mu = bg.multiplier or 1
				bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	end

	if(element.PostUpdateColor) then
		element:PostUpdateColor(unit, r, g, b)
	end
end

LUF.overrides["CastBar"] = {}
LUF.overrides["CastBar"].PostCastStart = function(self, unit)
	if UnitCastingInfo(unit) then
		local castColor = LUF.db.profile.colors.cast
		self:SetStatusBarColor(castColor.r, castColor.g, castColor.b)
	else
		local chanColor = LUF.db.profile.colors.channel
		self:SetStatusBarColor(chanColor.r, chanColor.g, chanColor.b)
	end
end

LUF.overrides["Totems"] = {}
LUF.overrides["Totems"].Update = function(self)
	local Totems = self.Totems
	local x, y = (self:GetWidth() - 3) / 4 , self:GetHeight()
	for i=1, 4 do
		Totems[i]:SetSize(x, y)
		Totems[i]:ClearAllPoints()
		Totems[i]:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", ((i - 1) * (x + 1)), 0)
	end
end

LUF.overrides["Totems"].PostUpdate = function(self, slot, haveTotem, name, start, duration, icon)
	local mod = self[1]:GetParent()
	mod:Show()
	for i=1,4 do
		if select(3,GetTotemInfo(i)) ~= 0 then
			break
		end
		if i == 4 and mod.autoHide then
			mod:Hide()
		end
	end
	LUF.PlaceModules(mod:GetParent())
end

LUF.overrides["AdditionalPower"] = {}
LUF.overrides["AdditionalPower"].PostUpdateVisibility = function(self, visible, isEnabled)
	LUF.PlaceModules(self:GetParent())
end

LUF.overrides["ComboPoints"] = {}
LUF.overrides["ComboPoints"].Update = function(self)
	local ComboPoints = self.ComboPoints
	local x, y = (self:GetWidth() - 4) / 5 , self:GetHeight()
	for i=1, 5 do
		ComboPoints[i]:SetSize(x, y)
		ComboPoints[i]:ClearAllPoints()
		if self.growth == "RIGHT" then
			ComboPoints[i]:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", ((i - 1) * (x + 1)), 0)
		else
			ComboPoints[i]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -((i - 1) * (x + 1)), 0)
		end
	end
end

LUF.overrides["ComboPoints"].PostUpdate = function(self, cur, max, hasMaxChanged, powerType)
	local mod = self[1]:GetParent()
	local cp = GetComboPoints("player", "target")
	mod.isDisabled = not self.isEnabled
	if (not cp or cp ==0) and mod.autoHide or mod.isDisabled then
		mod:Hide()
	else
		mod:Show()
	end
	LUF.PlaceModules(mod:GetParent())
end

LUF.overrides["Reckoning"] = {}
LUF.overrides["Reckoning"].Update = function(self)
	local Reckoning = self.Reckoning
	local x, y = (self:GetWidth() - 3) / 4 , self:GetHeight()
	for i=1, 4 do
		Reckoning[i]:SetSize(x, y)
		Reckoning[i]:ClearAllPoints()
		if self.growth == "RIGHT" then
			Reckoning[i]:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", ((i - 1) * (x + 1)), 0)
		else
			Reckoning[i]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -((i - 1) * (x + 1)), 0)
		end
	end
end

LUF.overrides["Reckoning"].PostUpdate = function(self, currentStacks)
	local mod = self[1]:GetParent()
	if (not currentStacks or currentStacks ==0) and mod.autoHide then
		mod:Hide()
	else
		mod:Show()
	end
	LUF.PlaceModules(mod:GetParent())
end

LUF.overrides["XPBar"] = {}
LUF.overrides["XPBar"].PostUpdate = function(self, minXP, maxXP, currentXP, minRep, maxRep, currentRep)
	local mod = self.xpBar:GetParent()
	if self.xpBar:IsShown() or self.repBar and self.repBar:IsShown() then
		mod:Show()
	else
		mod:Hide()
	end
	LUF.PlaceModules(mod:GetParent())
	mod:GetScript("OnSizeChanged")(mod)
end

local currentTargetGUID
LUF.overrides["Target"] = {}
LUF.overrides["Target"].PostUpdate = function(self, event)
	if currentTargetGUID ~= UnitGUID("target") and LUF.db.profile.units.target.sound then
		currentTargetGUID = UnitGUID("target")
		if currentTargetGUID then
			if ( UnitIsEnemy("target", "player") ) then
				PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
			elseif ( UnitIsFriend("player", "target") ) then
				PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT)
			else
				PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT)
			end
		else
			PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
		end
	else
		currentTargetGUID = nil
	end
end