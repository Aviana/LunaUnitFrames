local Auras = {}
LunaUF:RegisterModule(Auras, "auras", LunaUF.L["Auras"])
local L = LunaUF.L

local lCD = LibStub("LibClassicDurations")
lCD:Register(LunaUF)

local mainEnchant, offEnchant, timeElapsed = {timeLeft = 0}, {timeLeft = 0}, 0

local magicColors = {
	["Magic"] = {0.2, 0.6, 1},
	["Curse"] = {0.6, 0, 1},
	["Disease"] = {0.6, 0.4, 0},
	["Poison"] = {0, 0.6, 0},
	["none"] = {1, 1, 1},
}

local function updateTooltip(self)
	if( not GameTooltip:IsForbidden() and GameTooltip:IsOwned(self) ) then
		if( self.filter == "TEMP" ) then
			GameTooltip:SetInventoryItem("player", self.auraID)
		else
			GameTooltip:SetUnitAura(self.unit, self.auraID, self.filter)
		end
	end
end

local function showTooltip(self)
	if( not LunaUF.db.profile.locked ) then return end
	if( GameTooltip:IsForbidden() ) then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	if( self.filter == "TEMP" ) then
		GameTooltip:SetInventoryItem("player", self.auraID)
		self:SetScript("OnUpdate", updateTooltip)
	else
		GameTooltip:SetUnitAura(self.unit, self.auraID, self.filter)
		self:SetScript("OnUpdate", updateTooltip)
	end
end

local function hideTooltip(self)
	self:SetScript("OnUpdate", nil)
	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end
end

local function cancelAura(self, button)
	if( button ~= "RightButton" or InCombatLockdown() or self.filter ~= "HELPFUL" or not UnitIsUnit("player", self.unit)) then
		return
	end

	CancelUnitBuff(self.unit, self.auraID, self.filter)
end

local function UpdateWeaponEnchants(self, elapsed)

	timeElapsed = timeElapsed + elapsed
	if( timeElapsed < 0.50 ) then return end
	timeElapsed = timeElapsed - 0.50

	local changed
	local hasMain, mainTimeLeft, mainCharges, mainEnchantId, hasOff, offTimeLeft, offCharges, offEnchantId = GetWeaponEnchantInfo()
	mainTimeLeft = mainTimeLeft or 0
	offTimeLeft = offTimeLeft or 0
	mainTimeLeft = mainTimeLeft / 1000
	offTimeLeft = offTimeLeft / 1000
	if hasMain ~= mainEnchant.exists or mainTimeLeft > mainEnchant.timeLeft or mainCharges ~= mainEnchant.charges then
		changed = true
		mainEnchant.exists = hasMain
		mainEnchant.timeLeft = mainTimeLeft
		mainEnchant.charges = mainCharges
		mainEnchant.id = mainEnchantId
		mainEnchant.startTime = GetTime()
	end
	if hasOff ~= offEnchant.exists or offTimeLeft > offEnchant.timeLeft or offCharges ~= offEnchant.charges then
		changed = true
		offEnchant.exists = hasOff
		offEnchant.timeLeft = offTimeLeft
		offEnchant.charges = offCharges
		offEnchant.id = offEnchantId
		offEnchant.startTime = GetTime()
	end
	if changed then
		for _,frame in pairs(LunaUF.Units.unitFrames) do
			if frame.unit and frame.unit == "player" then
				Auras:Update(frame)
			end
		end
	end
end

function Auras:OnEnable(frame)
	local isPlayer = frame.unitType == "player"
	if not frame.auras then
		frame.auras = CreateFrame("Frame", nil, frame)
		frame.auras.buffbuttons = CreateFrame("Frame", nil, frame)
--		frame.auras.buffbuttons.texture = frame.auras.buffbuttons:CreateTexture(nil, "BACKGROUND")
--		frame.auras.buffbuttons.texture:SetAllPoints(frame.auras.buffbuttons)
--		frame.auras.buffbuttons.texture:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
		frame.auras.buffbuttons.buttons = {}
		frame.auras.debuffbuttons = CreateFrame("Frame", nil, frame)
		frame.auras.debuffbuttons.buttons = {}
		if isPlayer then
			frame.auras.buffbuttons:SetScript("OnUpdate", LunaUF.db.profile.units.player.auras.weaponbuffs and UpdateWeaponEnchants or nil)
		end
		for i=1, (isPlayer and 34 or 32) do
			local button = CreateFrame("Button", frame:GetName().."BuffFrame"..i, frame.auras.buffbuttons)
			button.unit = frame.unit
			button:SetScript("OnEnter", showTooltip)
			button:SetScript("OnLeave", hideTooltip)
			button:SetScript("OnClick", cancelAura)
			button:RegisterForClicks("RightButtonUp")
			button.cooldown = CreateFrame("Cooldown", button:GetName().."CD", button, "CooldownFrameTemplate")
			button.cooldown:ClearAllPoints()
			button.cooldown:SetAllPoints(button)
			button.cooldown:SetReverse(true)
			button.cooldown:SetDrawEdge(false)
			button.cooldown:SetDrawSwipe(true)
			button.cooldown:SetSwipeColor(0, 0, 0, 0.8)
			button.cooldown:Hide()
			--button.textFrame = CreateFrame("Frame", nil, button)
			--button.textFrame:SetAllPoints(button)
			--button.timeFontstring = button.textFrame:CreateFontString(nil, "OVERLAY")
			--button.timeFontstring:SetJustifyH("CENTER")
			--button.timeFontstring:SetPoint("CENTER", button.textFrame, "CENTER",0,0)

			button.stack = button:CreateFontString(nil, "OVERLAY")
			button.stack:SetShadowColor(0, 0, 0, 1.0)
			button.stack:SetShadowOffset(0.50, -0.50)
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Myriad Condensed Web.ttf", 10, "OUTLINE")
			button.stack:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT")
			button.stack:SetJustifyV("BOTTOM")
			button.stack:SetJustifyH("RIGHT")

			button.border = button:CreateTexture(nil, "OVERLAY")
			button.border:SetPoint("CENTER", button)

			button.icon = button:CreateTexture(nil, "BACKGROUND")
			button.icon:SetAllPoints(button)
			button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

			frame.auras.buffbuttons.buttons[i] = button
		end
		for i=1, 16 do
			local button = CreateFrame("Button", frame:GetName().."DebuffFrame"..i, frame.auras.debuffbuttons)
			button.unit = frame.unit
			button:SetScript("OnEnter", showTooltip)
			button:SetScript("OnLeave", hideTooltip)
			button.cooldown = CreateFrame("Cooldown", button:GetName().."CD", button, "CooldownFrameTemplate")
			button.cooldown:ClearAllPoints()
			button.cooldown:SetAllPoints(button)
			button.cooldown:SetReverse(true)
			button.cooldown:SetDrawEdge(false)
			button.cooldown:SetDrawSwipe(true)
			button.cooldown:SetSwipeColor(0, 0, 0, 0.8)
			button.cooldown:Hide()
			--button.textFrame = CreateFrame("Frame", nil, button)
			--button.textFrame:SetAllPoints(button)
			--button.timeFontstring = button.textFrame:CreateFontString(nil, "OVERLAY")
			--button.timeFontstring:SetJustifyH("CENTER")
			--button.timeFontstring:SetPoint("CENTER", button.textFrame, "CENTER",0,0)

			button.stack = button:CreateFontString(nil, "OVERLAY")
			button.stack:SetShadowColor(0, 0, 0, 1.0)
			button.stack:SetShadowOffset(0.50, -0.50)
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Myriad Condensed Web.ttf", 10, "OUTLINE")
			button.stack:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT")
			button.stack:SetJustifyV("BOTTOM")
			button.stack:SetJustifyH("RIGHT")

			button.border = button:CreateTexture(nil, "OVERLAY")
			button.border:SetPoint("CENTER", button)

			button.icon = button:CreateTexture(nil, "BACKGROUND")
			button.icon:SetAllPoints(button)
			button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

			frame.auras.debuffbuttons.buttons[i] = button
		end
	end

	frame:RegisterUnitEvent("UNIT_AURA", self, "Update")
	frame:RegisterUpdateFunc(self, "Update")
end

function Auras:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Auras:OnLayoutApplied(frame)
	if not frame.auras then return end
	for num,button in pairs(frame.auras.buffbuttons.buttons) do
		if( LunaUF.db.profile.auraborderType == "none" ) then
			button.border:Hide()
		elseif( LunaUF.db.profile.auraborderType == "blizzard" ) then
			button.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
			button.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
			button.border:Show()
		else
			button.border:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\borders\\border-" .. "dark")
			button.border:SetTexCoord(0, 1, 0, 1)
			button.border:Show()
		end
	end
	for num,button in pairs(frame.auras.debuffbuttons.buttons) do
		if( LunaUF.db.profile.auraborderType == "none" ) then
			button.border:Hide()
		elseif( LunaUF.db.profile.auraborderType == "blizzard" ) then
			button.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
			button.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
			button.border:Show()
		else
			button.border:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\borders\\border-" .. "dark")
			button.border:SetTexCoord(0, 1, 0, 1)
			button.border:Show()
		end
	end
end

function Auras:UpdateFrames(frame)
	local config = LunaUF.db.profile.units[frame.unitType].auras
	local name, texture, count, auraType, duration, endTime, caster, spellID, main, off
	for i,button in ipairs(frame.auras.buffbuttons.buttons) do
		if i < 33 then
			name, texture, count, auraType, duration, endTime, caster, _, _, spellID = UnitAura(frame.unit, i, "HELPFUL")
			if (not duration or duration == 0) and spellID then
				local Newduration, NewendTime = lCD:GetAuraDurationByUnit(frame.unit, spellID, caster)
				duration = Newduration or duration
				endTime = NewendTime or endTime
			end
			if caster and UnitIsUnit("player", caster) and config.emphasizeBuffs then
				button.large = true
			else
				button.large = nil
			end
		else
			texture = nil
		end
		if not LunaUF.db.profile.locked then
			duration = 0
			endTime = 0
			if i < 33 and config.buffs then
				texture = "Interface\\Icons\\Spell_ChargePositive"
			elseif config.weaponbuffs and ((not config.buffs and i < 3) or (config.buffs and i > 32)) then
				texture = "Interface\\Icons\\Inv_Sword_27"
				button.large = true
			else
				texture = nil
			end
			count = i
		end
		if not config.buffs then
			texture = nil
		end
		if texture then
			button:Show()
			button.icon:SetTexture(texture)
			if count > 1 then
				button.stack:Show()
				button.stack:SetText(count)
			else
				button.stack:Hide()
			end
			button.auraID = i
			button.filter = "HELPFUL"
			if config.bordercolor and magicColors[auraType] then
				button.border:SetVertexColor(unpack(magicColors[auraType]))
			else
				button.border:SetVertexColor(1,1,1)
			end
			if config.timer == "self" and button.large or config.timer == "all" and duration ~= 0 then
				button.cooldown:Show()
				button.cooldown:SetCooldown(endTime - duration, duration)
			else
				button.cooldown:Hide()
			end
		elseif config.weaponbuffs and mainEnchant.exists and frame.unit == "player" and LunaUF.db.profile.locked and not main then
			main = true
			button:Show()
			button.large = config.emphasizeAuras
			button.filter = "TEMP"
			button.auraID = 16
			button.icon:SetTexture(GetInventoryItemTexture("player", 16))
			if config.bordercolor then
				button.border:SetVertexColor(0.5,0,0.5)
			else
				button.border:SetVertexColor(1,1,1)
			end
			if mainEnchant.charges and mainEnchant.charges > 1 then
				button.stack:Show()
				button.stack:SetText(mainEnchant.charges)
			else
				button.stack:Hide()
			end
			if config.timer then
				button.cooldown:Show()
				button.cooldown:SetCooldown(mainEnchant.startTime, mainEnchant.timeLeft)
			else
				button.cooldown:Hide()
			end
		elseif config.weaponbuffs and offEnchant.exists and frame.unit == "player" and LunaUF.db.profile.locked and not off then
			off = true
			button:Show()
			button.large = config.emphasizeAuras
			button.filter = "TEMP"
			button.auraID = 17
			button.icon:SetTexture(GetInventoryItemTexture("player", 17))
			if config.bordercolor then
				button.border:SetVertexColor(0.5,0,0.5)
			else
				button.border:SetVertexColor(1,1,1)
			end
			if offEnchant.charges and offEnchant.charges > 1 then
				button.stack:Show()
				button.stack:SetText(offEnchant.charges)
			else
				button.stack:Hide()
			end
			if config.timer then
				button.cooldown:Show()
				button.cooldown:SetCooldown(offEnchant.startTime, offEnchant.timeLeft)
			else
				button.cooldown:Hide()
			end
		else
			button:Hide()
		end
	end
	for i,button in ipairs(frame.auras.debuffbuttons.buttons) do
		name, texture, count, auraType, duration, endTime, caster, _, _, spellID = UnitAura(frame.unit, i, "HARMFUL")
		if (not duration or duration == 0) and spellID then
			local Newduration, NewendTime = lCD:GetAuraDurationByUnit(frame.unit, spellID, caster)
			duration = Newduration or duration
			endTime = NewendTime or endTime
		end
		if caster and UnitIsUnit("player", caster) and config.emphasizeDebuffs then
			button.large = true
		else
			button.large = nil
		end
		if not LunaUF.db.profile.locked then
			duration = 0
			endTime = 0
			texture = "Interface\\Icons\\Spell_ChargeNegative"
			count = i
		end
		if not config.debuffs then
			texture = nil
		end
		if texture then
			button:Show()
			button.icon:SetTexture(texture)
			if count > 1 then
				button.stack:Show()
				button.stack:SetText(count)
			else
				button.stack:Hide()
			end
			button.auraID = i
			button.filter = "HARMFUL"
			if config.bordercolor and magicColors[auraType] then
				button.border:SetVertexColor(unpack(magicColors[auraType]))
			else
				button.border:SetVertexColor(1,1,1)
			end
			if config.timer == "self" and button.large or config.timer == "all" and duration ~= 0 then
				button.cooldown:Show()
				button.cooldown:SetCooldown(endTime - duration, duration)
			else
				button.cooldown:Hide()
			end
		else
			button:Hide()
		end
	end
end

function Auras:UpdateLayout(frame)
	local config = LunaUF.db.profile.units[frame.unitType].auras
	local debuffanchor = config.buffpos == config.debuffpos and frame.auras.buffbuttons or frame
	frame.auras.buffbuttons:ClearAllPoints()
	frame.auras.debuffbuttons:ClearAllPoints()
	if config.buffpos == "BOTTOM" then
		frame.auras.buffbuttons:SetPoint("TOP", frame, "BOTTOM", 0, -3)
	elseif config.buffpos == "TOP" then
		frame.auras.buffbuttons:SetPoint("BOTTOM", frame, "TOP", 0, 3)
	elseif config.buffpos == "LEFT" then
		frame.auras.buffbuttons:SetPoint("BOTTOMRIGHT", frame, "LEFT", -3, 1)
	else
		frame.auras.buffbuttons:SetPoint("BOTTOMLEFT", frame, "RIGHT", 3, 1)
	end
	if config.debuffpos == "BOTTOM" then
		frame.auras.debuffbuttons:SetPoint("TOP", debuffanchor, "BOTTOM", 0, (config.buffs or config.weaponbuffs) and -3 or 0)
	elseif config.debuffpos == "TOP" then
		frame.auras.debuffbuttons:SetPoint("BOTTOM", debuffanchor, "TOP", 0, (config.buffs or config.weaponbuffs) and 3 or 0)
	elseif config.debuffpos == "LEFT" then
		frame.auras.debuffbuttons:SetPoint("TOPRIGHT", frame, "LEFT", -3, -1)
	else
		frame.auras.debuffbuttons:SetPoint("TOPLEFT", frame, "RIGHT", 3, -1)
	end
	
	local framelength = LunaUF.db.profile.units[frame.unitType].width - 8 --??? WTF is going on
	local frameheight = 1
	local buttonsize, lastButton, firstButton, rowlenght
	local rowheight = 0
	if config.buffpos == "BOTTOM" then
		for i,button in ipairs(frame.auras.buffbuttons.buttons) do
			if not button:IsVisible() then break end
			buttonsize = not button.large and config.buffsize or config.buffsize + config.enlargedbuffsize
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Myriad Condensed Web.ttf", (10*(buttonsize/18)), "OUTLINE")
			button.border:SetHeight(buttonsize+2)
			button.border:SetWidth(buttonsize+2)
			if i == 1 then
				button:SetPoint("TOPLEFT", frame.auras.buffbuttons, "TOPLEFT")
				rowlenght = buttonsize
				rowheight = buttonsize
				firstButton = button
			elseif (rowlenght + buttonsize + config.padding) > framelength then
				rowlenght = buttonsize
				button:SetPoint("TOPLEFT", firstButton, "TOPLEFT", 0, (-(config.padding)-rowheight))
				firstButton = button
				frameheight = frameheight + config.padding + rowheight
				rowheight = buttonsize
			else
				button:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", config.padding, 0)
				rowlenght = rowlenght + buttonsize + config.padding
				rowheight = math.max(rowheight, buttonsize)
			end
			lastButton = button
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
				button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
			end
		end
		frameheight = frameheight + rowheight
	elseif config.buffpos == "TOP" then
		for i,button in ipairs(frame.auras.buffbuttons.buttons) do
			if not button:IsVisible() then break end
			buttonsize = not button.large and config.buffsize or config.buffsize + config.enlargedbuffsize
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Myriad Condensed Web.ttf", (10*(buttonsize/18)), "OUTLINE")
			button.border:SetHeight(buttonsize+2)
			button.border:SetWidth(buttonsize+2)
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", frame.auras.buffbuttons, "BOTTOMLEFT")
				rowlenght = buttonsize
				rowheight = buttonsize
				firstButton = button
			elseif (rowlenght + buttonsize + config.padding) > framelength then
				rowlenght = buttonsize
				button:SetPoint("BOTTOMLEFT", firstButton, "BOTTOMLEFT", 0, (config.padding+rowheight))
				firstButton = button
				frameheight = frameheight + config.padding + rowheight
				rowheight = buttonsize
			else
				button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", config.padding, 0)
				rowlenght = rowlenght + buttonsize + config.padding
				rowheight = math.max(rowheight, buttonsize)
			end
			lastButton = button
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
				button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
			end
		end
		frameheight = frameheight + rowheight
	elseif config.buffpos == "LEFT" then
		for i,button in ipairs(frame.auras.buffbuttons.buttons) do
			if not button:IsVisible() then break end
			buttonsize = not button.large and config.buffsize or config.buffsize + config.enlargedbuffsize
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Myriad Condensed Web.ttf", (10*(buttonsize/18)), "OUTLINE")
			button.border:SetHeight(buttonsize+2)
			button.border:SetWidth(buttonsize+2)
			if i == 1 then
				button:SetPoint("BOTTOMRIGHT", frame.auras.buffbuttons, "BOTTOMRIGHT")
				rowlenght = buttonsize
				rowheight = buttonsize
				firstButton = button
			elseif (rowlenght + buttonsize + config.padding) > framelength then
				rowlenght = buttonsize
				button:SetPoint("BOTTOMRIGHT", firstButton, "BOTTOMRIGHT", 0, (config.padding+rowheight))
				firstButton = button
				frameheight = frameheight + config.padding + rowheight
				rowheight = buttonsize
			else
				button:SetPoint("BOTTOMRIGHT", lastButton, "BOTTOMLEFT", -(config.padding), 0)
				rowlenght = rowlenght + buttonsize + config.padding
				rowheight = math.max(rowheight, buttonsize)
			end
			lastButton = button
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
				button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
			end
		end
		frameheight = frameheight + rowheight
	else
		for i,button in ipairs(frame.auras.buffbuttons.buttons) do
			if not button:IsVisible() then break end
			buttonsize = not button.large and config.buffsize or config.buffsize + config.enlargedbuffsize
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Myriad Condensed Web.ttf", (10*(buttonsize/18)), "OUTLINE")
			button.border:SetHeight(buttonsize+2)
			button.border:SetWidth(buttonsize+2)
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", frame.auras.buffbuttons, "BOTTOMLEFT")
				rowlenght = buttonsize
				rowheight = buttonsize
				firstButton = button
			elseif (rowlenght + buttonsize + config.padding) > framelength then
				rowlenght = buttonsize
				button:SetPoint("BOTTOMLEFT", firstButton, "BOTTOMLEFT", 0, (config.padding+rowheight))
				firstButton = button
				frameheight = frameheight + config.padding + rowheight
				rowheight = buttonsize
			else
				button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", config.padding, 0)
				rowlenght = rowlenght + buttonsize + config.padding
				rowheight = math.max(rowheight, buttonsize)
			end
			lastButton = button
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
				button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
			end
		end
		frameheight = frameheight + rowheight
	end
	frame.auras.buffbuttons:SetHeight(frameheight)
	frame.auras.buffbuttons:SetWidth(framelength)
	frameheight = 1
	rowheight = 0
	if config.debuffpos == "BOTTOM" then
		for i,button in ipairs(frame.auras.debuffbuttons.buttons) do
			if not button:IsVisible() then break end
			buttonsize = not button.large and config.debuffsize or config.debuffsize + config.enlargeddebuffsize
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Myriad Condensed Web.ttf", (10*(buttonsize/18)), "OUTLINE")
			button.border:SetHeight(buttonsize+2)
			button.border:SetWidth(buttonsize+2)
			if i == 1 then
				button:SetPoint("TOPLEFT", frame.auras.debuffbuttons, "TOPLEFT")
				rowlenght = buttonsize
				rowheight = buttonsize
				firstButton = button
			elseif (rowlenght + buttonsize + config.padding) > framelength then
				rowlenght = buttonsize
				button:SetPoint("TOPLEFT", firstButton, "TOPLEFT", 0, (-(config.padding)-rowheight))
				firstButton = button
				frameheight = frameheight + config.padding + rowheight
				rowheight = buttonsize
			else
				button:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", config.padding, 0)
				rowlenght = rowlenght + buttonsize + config.padding
				rowheight = math.max(rowheight, buttonsize)
			end
			lastButton = button
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
				button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
			end
		end
		frameheight = frameheight + rowheight
	elseif config.debuffpos == "TOP" then
		for i,button in ipairs(frame.auras.debuffbuttons.buttons) do
			if not button:IsVisible() then break end
			buttonsize = not button.large and config.debuffsize or config.debuffsize + config.enlargeddebuffsize
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Myriad Condensed Web.ttf", (10*(buttonsize/18)), "OUTLINE")
			button.border:SetHeight(buttonsize+2)
			button.border:SetWidth(buttonsize+2)
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", frame.auras.debuffbuttons, "BOTTOMLEFT")
				rowlenght = buttonsize
				rowheight = buttonsize
				firstButton = button
			elseif (rowlenght + buttonsize + config.padding) > framelength then
				rowlenght = buttonsize
				button:SetPoint("BOTTOMLEFT", firstButton, "BOTTOMLEFT", 0, (config.padding+rowheight))
				firstButton = button
				frameheight = frameheight + config.padding + rowheight
				rowheight = buttonsize
			else
				button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", config.padding, 0)
				rowlenght = rowlenght + buttonsize + config.padding
				rowheight = math.max(rowheight, buttonsize)
			end
			lastButton = button
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
				button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
			end
		end
		frameheight = frameheight + rowheight
	elseif config.debuffpos == "LEFT" then
		for i,button in ipairs(frame.auras.debuffbuttons.buttons) do
			if not button:IsVisible() then break end
			buttonsize = not button.large and config.debuffsize or config.debuffsize + config.enlargeddebuffsize
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Myriad Condensed Web.ttf", (10*(buttonsize/18)), "OUTLINE")
			button.border:SetHeight(buttonsize+2)
			button.border:SetWidth(buttonsize+2)
			if i == 1 then
				button:SetPoint("TOPRIGHT", frame.auras.debuffbuttons, "TOPRIGHT")
				rowlenght = buttonsize
				rowheight = buttonsize
				firstButton = button
			elseif (rowlenght + buttonsize + config.padding) > framelength then
				rowlenght = buttonsize
				button:SetPoint("TOPRIGHT", firstButton, "TOPRIGHT", 0, (-(config.padding)-rowheight))
				firstButton = button
				frameheight = frameheight + config.padding + rowheight
				rowheight = buttonsize
			else
				button:SetPoint("TOPRIGHT", lastButton, "TOPLEFT", -(config.padding), 0)
				rowlenght = rowlenght + buttonsize + config.padding
				rowheight = math.max(rowheight, buttonsize)
			end
			lastButton = button
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
				button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
			end
		end
		frameheight = frameheight + rowheight
	else
		for i,button in ipairs(frame.auras.debuffbuttons.buttons) do
			if not button:IsVisible() then break end
			buttonsize = not button.large and config.debuffsize or config.debuffsize + config.enlargeddebuffsize
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Myriad Condensed Web.ttf", (10*(buttonsize/18)), "OUTLINE")
			button.border:SetHeight(buttonsize+2)
			button.border:SetWidth(buttonsize+2)
			if i == 1 then
				button:SetPoint("TOPLEFT", frame.auras.debuffbuttons, "TOPLEFT")
				rowlenght = buttonsize
				rowheight = buttonsize
				firstButton = button
			elseif (rowlenght + buttonsize + config.padding) > framelength then
				rowlenght = buttonsize
				button:SetPoint("TOPLEFT", firstButton, "TOPLEFT", 0, (-(config.padding)-rowheight))
				firstButton = button
				frameheight = frameheight + config.padding + rowheight
				rowheight = buttonsize
			else
				button:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", config.padding, 0)
				rowlenght = rowlenght + buttonsize + config.padding
				rowheight = math.max(rowheight, buttonsize)
			end
			lastButton = button
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
				button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
			end
		end
		frameheight = frameheight + rowheight
	end
	frame.auras.debuffbuttons:SetHeight(frameheight)
	frame.auras.debuffbuttons:SetWidth(framelength)
end

function Auras:Update(frame)
	if not frame then return end
	self:UpdateFrames(frame)
	self:UpdateLayout(frame)
end