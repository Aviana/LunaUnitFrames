local L = LunaUF.L
local Auras = {}
local defaultFont = LunaUF.defaultFont
local ScanTip = CreateFrame("GameTooltip", "LunaAuraScanTip", nil, "GameTooltipTemplate")
ScanTip:SetOwner(WorldFrame, "ANCHOR_TOP", 0,1000)
ScanTip:SetClampedToScreen(0)
LunaUF:RegisterModule(Auras, "auras", L["Auras"])

local mainEnchant, offEnchant, mainDur, offDur

local revTranslation = {}
if( GetLocale() == "deDE" ) then
	revTranslation["Magie"] = "Magic"
	revTranslation["Fluch"] = "Curse"
	revTranslation["Gift"] = "Poison"
	revTranslation["Krankheit"] = "Disease"
elseif ( GetLocale() == "frFR" ) then
	revTranslation["Magie"] = "Magic"
	revTranslation["Mal\195\169diction"] = "Curse"
	revTranslation["Poison"] = "Poison"
	revTranslation["Maladie"] = "Disease"
elseif GetLocale() == "zhCN" then
	revTranslation["魔法"] = "Magic"
	revTranslation["诅咒"] = "Curse"
	revTranslation["中毒"] = "Poison"
	revTranslation["疾病"] = "Disease"
else
	revTranslation["Magic"] = "Magic"
	revTranslation["Curse"] = "Curse"
	revTranslation["Poison"] = "Poison"
	revTranslation["Disease"] = "Disease"
end


-- Thanks schaka! :D
local function firstToUpper(str)
	if (str~=nil) then
		return (string.gsub(str, "^%l", string.upper));
	else
		return nil;
	end
end

local function showTooltip()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT")
	if( this.filter == "TEMP" ) then
		GameTooltip:SetInventoryItem("player", this.auraID)
	elseif this:GetParent():GetParent().unitGroup == "player" then
		GameTooltip:SetPlayerBuff(this.auraID);
	elseif this.filter == "HELPFUL" then
		GameTooltip:SetUnitBuff(this:GetParent():GetParent().unit, this.auraID)
	elseif this.filter == "HARMFUL" then
		GameTooltip:SetUnitDebuff(this:GetParent():GetParent().unit, this.auraID)
	end
end

local function hideTooltip()
	GameTooltip:Hide()
end

local function cancelBuff()
	if (arg1 ~= "RightButton") then return end
	if (this.filter == "TEMP") then return end
	CancelPlayerBuff(this.auraID)
end

local function GetTempBuffName(id)
	ScanTip:ClearLines()
	ScanTip:SetInventoryItem("player", id)
	for i=1,ScanTip:NumLines() do
		local toolTipText = getglobal("LunaAuraScanTipTextLeft" .. i)
		local _, _, buffname = string.find(toolTipText:GetText(), "^([^%(]+) %(%d+ [^%)]+%)")
		if buffname then
			return buffname
		end
	end
end

local function WeaponEnchantScan(frame)
	local hasMainHandEnchant, mainHandExpiration, _, hasOffHandEnchant, offHandExpiration = GetWeaponEnchantInfo()
	local offDur = math.max((offHandExpiration or 0)/1000, 0)
	local mainDur = math.max((mainHandExpiration or 0)/1000 , 0)
	hasMainHandEnchant = hasMainHandEnchant and (GetTempBuffName(16) or mainEnchant)
	hasOffHandEnchant = hasOffHandEnchant and (GetTempBuffName(17) or offEnchant)
	for _,button in ipairs(frame.auras.buffbuttons.buttons) do
		if button.filter == "TEMP" then
			button.icon:SetTexture(GetInventoryItemTexture("player", button.auraID))
		end
	end
	if hasMainHandEnchant ~= mainEnchant or hasOffHandEnchant ~= offEnchant then
		if hasMainHandEnchant then
			LunaBuffDB[hasMainHandEnchant] = math.max(mainDur, (LunaBuffDB[hasMainHandEnchant] or 0))
		end
		if hasOffHandEnchant then
			LunaBuffDB[hasOffHandEnchant] = math.max(offDur, (LunaBuffDB[hasOffHandEnchant] or 0))
		end
		mainEnchant = hasMainHandEnchant
		offEnchant = hasOffHandEnchant
		Auras:FullUpdate(frame)
	end
end

local function OnEvent()
	if (event == "UNIT_INVENTORY_CHANGED" and arg1 == "player") then
		WeaponEnchantScan(this:GetParent())
	elseif event == "PLAYER_AURAS_CHANGED" or arg1 == this:GetParent().unit then
		Auras:FullUpdate(this:GetParent())
	end
end

local function getTimeString(timeleft)
	local timeString = ""
	if (timeleft and timeleft > 0) then
		timeleft = math.ceil(timeleft);
		if (timeleft > 3599) then
			timeString = math.ceil(timeleft / 3600).."h"
		elseif (timeleft > 59) then
			timeString = math.ceil(timeleft / 60).."m"
		elseif timeleft > 10 then
			timeString = timeleft.."s"
		elseif timeleft > 0 then
			return timeleft, true
		end
	end
	return timeString
end

function Auras:OnEnable(frame)
	local isPlayer = frame.unitGroup == "player"
	if not LunaBuffDB then
		LunaBuffDB = {}
	end
	if not frame.auras then
		frame.auras = CreateFrame("Frame", nil, frame)
		frame.auras.buffbuttons = CreateFrame("Frame", nil, frame)
		frame.auras.buffbuttons.buttons = {}
		frame.auras.debuffbuttons = CreateFrame("Frame", nil, frame)
		frame.auras.debuffbuttons.buttons = {}
		for i=1, (isPlayer and 34 or 32) do
			local button = CreateFrame("Button", "Luna"..firstToUpper(frame.trueunit or frame:GetName()).."BuffFrame"..i, frame.auras)
			button:SetScript("OnEnter", showTooltip)
			button:SetScript("OnLeave", hideTooltip)
			if isPlayer then
				button:SetScript("OnClick", cancelBuff)
				button:RegisterForClicks("RightButtonUp")
				button.cooldown = CreateFrame("Model", button:GetName().."CD", button, "CooldownFrameTemplate")
				button.cooldown:ClearAllPoints()
				button.cooldown:SetHeight(36)
				button.cooldown:SetWidth(36)
				button.cooldown.reverse = true
				button.cooldown:Hide()
				button.textFrame = CreateFrame("Frame", nil, button)
				button.textFrame:SetAllPoints(button)
				button.timeFontstring = button.textFrame:CreateFontString(nil, "OVERLAY")
				button.timeFontstring:SetJustifyH("CENTER")
				button.timeFontstring:SetPoint("CENTER", button.textFrame, "CENTER",0,0)
			end

			button.stack = button:CreateFontString(nil, "OVERLAY")
			button.stack:SetShadowColor(0, 0, 0, 1.0)
			button.stack:SetShadowOffset(0.50, -0.50)
			button.stack:SetFont(defaultFont, 10, "OUTLINE")
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
			local button = CreateFrame("Button", "Luna"..firstToUpper(frame.trueunit or frame:GetName()).."DebuffFrame"..i, frame.auras)
			button:SetScript("OnEnter", showTooltip)
			button:SetScript("OnLeave", hideTooltip)
			if isPlayer then
				button.cooldown = CreateFrame("Model", button:GetName().."CD", button, "CooldownFrameTemplate")
				button.cooldown:ClearAllPoints()
				button.cooldown:SetHeight(36)
				button.cooldown:SetWidth(36)
				button.cooldown.reverse = true
				button.cooldown:Hide()
				button.textFrame = CreateFrame("Frame", nil, button)
				button.textFrame:SetAllPoints(button)
				button.timeFontstring = button.textFrame:CreateFontString(nil, "OVERLAY")
				button.timeFontstring:SetJustifyH("CENTER")
				button.timeFontstring:SetPoint("CENTER", button.textFrame, "CENTER",0,0)
			end

			button.stack = button:CreateFontString(nil, "OVERLAY")
			button.stack:SetShadowColor(0, 0, 0, 1.0)
			button.stack:SetShadowOffset(0.50, -0.50)
			button.stack:SetFont(defaultFont, 10, "OUTLINE")
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
	for num,button in pairs(frame.auras.buffbuttons.buttons) do
		if( LunaUF.db.profile.auraborderType == L["none"] ) then
			button.border:Hide()
		elseif( LunaUF.db.profile.auraborderType == "blizzard" ) then
			button.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
			button.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
			button.border:Show()
		else
			button.border:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\borders\\border-" .. LunaUF.db.profile.auraborderType)
			button.border:SetTexCoord(0, 1, 0, 1)
			button.border:Show()
		end
	end
	for num,button in pairs(frame.auras.debuffbuttons.buttons) do
		if( LunaUF.db.profile.auraborderType == L["none"] ) then
			button.border:Hide()
		elseif( LunaUF.db.profile.auraborderType == "blizzard" ) then
			button.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
			button.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
			button.border:Show()
		else
			button.border:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\borders\\border-" .. LunaUF.db.profile.auraborderType)
			button.border:SetTexCoord(0, 1, 0, 1)
			button.border:Show()
		end
	end
	frame.auras:Show()
	if isPlayer then
		frame.auras:RegisterEvent("PLAYER_AURAS_CHANGED")
		frame.auras:RegisterEvent("UNIT_INVENTORY_CHANGED")
		WeaponEnchantScan(frame)
	else
		frame.auras:RegisterEvent("UNIT_AURA")
	end
	frame.auras:SetScript("OnEvent", OnEvent)
end

function Auras:OnDisable(frame)
	if frame.auras then
		frame.auras:UnregisterAllEvents()
		frame.auras:SetScript("OnEvent", nil)
		frame.auras:SetScript("OnUpdate", nil)
		frame.auras:Hide()
	end
end

local function TimerUpdate()
	local timeleft = GetPlayerBuffTimeLeft(this.auraID)
	if timeleft > this.timeleft then
		ScanTip:ClearLines()
		ScanTip:SetPlayerBuff(this.auraID)
		local buffName = LunaAuraScanTipTextLeft1:GetText()
		CooldownFrame_SetTimer(this.cooldown, GetTime() - (LunaBuffDB[buffName] - timeleft), LunaBuffDB[buffName], 1)
	end
	if timeleft > 9 then
		this.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
	else
		this.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
	end
	this.timeFontstring:SetText(getTimeString(timeleft))
	this.timeleft = timeleft
end

local function WTimerUpdate()
	local hasMainHandEnchant, mainHandExpiration, _, hasOffHandEnchant, offHandExpiration = GetWeaponEnchantInfo()
	if not mainEnchant and hasMainHandEnchant then
		mainEnchant = GetTempBuffName(16)
	end
	if not offEnchant and hasOffHandEnchant then
		offEnchant = GetTempBuffName(17)
	end
	if this.auraID == 16 and mainEnchant then
		mainHandExpiration = mainHandExpiration / 1000
		if this.cooldown:IsVisible() then
			CooldownFrame_SetTimer(this.cooldown, GetTime() - (LunaBuffDB[mainEnchant] - mainHandExpiration), LunaBuffDB[mainEnchant], 1)
		end
		if mainHandExpiration > 9 then
			this.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
		else
			this.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
		end
		this.timeFontstring:SetText(getTimeString(mainHandExpiration))
	elseif offEnchant then
		offHandExpiration = offHandExpiration / 1000
		if this.cooldown:IsVisible() then
			CooldownFrame_SetTimer(this.cooldown, GetTime() - (LunaBuffDB[offEnchant] - offHandExpiration), LunaBuffDB[offEnchant], 1)
		end
		if offHandExpiration > 9 then
			this.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
		else
			this.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
		end
		this.timeFontstring:SetText(getTimeString(offHandExpiration))
	end
end

function Auras:UpdateFrames(frame)
	local config = LunaUF.db.profile.units[frame.unitGroup].auras
	local buffIndex, untilCancelled, dtype, texture, stacks, timeleft, buffName
	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
	for i,button in ipairs(frame.auras.buffbuttons.buttons) do
		if i < 33 then
			if frame.unitGroup == "player" then
				buffIndex, untilCancelled = GetPlayerBuff(i - 1, "HELPFUL")
				dtype = GetPlayerBuffDispelType(buffIndex)
				texture = GetPlayerBuffTexture(buffIndex)
				stacks = GetPlayerBuffApplications(buffIndex)
				timeleft = GetPlayerBuffTimeLeft(buffIndex)
				ScanTip:ClearLines()
				ScanTip:SetPlayerBuff(buffIndex)
				buffName = LunaAuraScanTipTextLeft1:GetText()
			else
				texture,stacks = UnitBuff(frame.unit,i)
				ScanTip:ClearLines()
				ScanTip:SetUnitBuff(frame.unit,i)
				dtype = LunaAuraScanTipTextRight1:IsVisible() and LunaAuraScanTipTextRight1:GetText()
				dtype = dtype and revTranslation[dtype]
				buffName = LunaAuraScanTipTextLeft1:GetText()
			end
			if buffName and config.emphasizeAuras.buffs[buffName] then
				button.large = true
			else
				button.large = nil
			end
		else
			texture = nil
		end
		if not LunaUF.db.profile.locked then
			if i < 33 and config.buffs then
				texture = "Interface\\Icons\\Spell_ChargePositive"
			elseif config.weaponbuffs and ((not config.buffs and i < 3) or (config.buffs and i > 32)) then
				texture = "Interface\\Icons\\Inv_Sword_27"
			end
			stacks = i
		end
		if not config.buffs then
			texture = nil
		end
		if texture then
			button:Show()
			button.icon:SetTexture(texture)
			if stacks > 1 then
				button.stack:Show()
				button.stack:SetText(stacks)
			else
				button.stack:Hide()
			end
			button.auraID = buffIndex or i
			button.filter = "HELPFUL"
			if config.bordercolor and dtype then
				button.border:SetVertexColor(unpack(LunaUF.db.profile.magicColors[dtype]))
			else
				button.border:SetVertexColor(1,1,1)
			end
			if timeleft and timeleft > 0 and buffName then
				if (not LunaBuffDB[buffName] or LunaBuffDB[buffName] < timeleft) then
					LunaBuffDB[buffName] = timeleft
				end
				CooldownFrame_SetTimer(button.cooldown, GetTime() - (LunaBuffDB[buffName] - timeleft), LunaBuffDB[buffName], 1)
				button.timeleft = timeleft
				button:SetScript("OnUpdate", TimerUpdate)
				if config.timerspinenabled then
					button.cooldown:Show()
				else
					button.cooldown:Hide()
				end
				if config.timertextenabled then
					button.timeFontstring:Show()
				else
					button.timeFontstring:Hide()
				end
			elseif button.cooldown then
				button.cooldown:Hide()
				button:SetScript("OnUpdate", nil)
				button.timeFontstring:Hide()
			end
		elseif config.weaponbuffs and hasMainHandEnchant and frame.unitGroup == "player" and LunaUF.db.profile.locked then
			button:Show()
			--button.large = true
			button.filter = "TEMP"
			button.auraID = 16
			button.icon:SetTexture(GetInventoryItemTexture("player", 16))
			if config.bordercolor then
				button.border:SetVertexColor(0.53,0.28,0.72)
			else
				button.border:SetVertexColor(1,1,1)
			end
			if mainHandCharges and mainHandCharges > 1 then
				button.stack:Show()
				button.stack:SetText(mainHandCharges)
			else
				button.stack:Hide()
			end
			if config.timerspinenabled then
				button.cooldown:Show()
			else
				button.cooldown:Hide()
			end
			if config.timertextenabled then
				button.timeFontstring:Show()
			else
				button.timeFontstring:Hide()
			end
			button:SetScript("OnUpdate", WTimerUpdate)
			hasMainHandEnchant = nil
		elseif config.weaponbuffs and hasOffHandEnchant and frame.unitGroup == "player" and LunaUF.db.profile.locked then
			button:Show()
			--button.large = true
			button.filter = "TEMP"
			button.auraID = 17
			button.icon:SetTexture(GetInventoryItemTexture("player", 17))
			if config.bordercolor then
				button.border:SetVertexColor(0.53,0.28,0.72)
			else
				button.border:SetVertexColor(1,1,1)
			end
			if offHandCharges and offHandCharges > 1 then
				button.stack:Show()
				button.stack:SetText(offHandCharges)
			else
				button.stack:Hide()
			end
			if config.timerspinenabled then
				button.cooldown:Show()
			else
				button.cooldown:Hide()
			end
			if config.timertextenabled then
				button.timeFontstring:Show()
			else
				button.timeFontstring:Hide()
			end
			button:SetScript("OnUpdate", WTimerUpdate)
			hasOffHandEnchant = nil
		else
			button:Hide()
			button:SetScript("OnUpdate", nil)
		end
	end
	for i,button in ipairs(frame.auras.debuffbuttons.buttons) do
		if frame.unitGroup == "player" then
			buffIndex, untilCancelled = GetPlayerBuff(i - 1, "HARMFUL")
			dtype = GetPlayerBuffDispelType(buffIndex)
			texture = GetPlayerBuffTexture(buffIndex)
			stacks = GetPlayerBuffApplications(buffIndex)
			timeleft = GetPlayerBuffTimeLeft(buffIndex)
			ScanTip:ClearLines()
			ScanTip:SetPlayerBuff(buffIndex)
			buffName = LunaAuraScanTipTextLeft1:GetText()
		else
			texture, stacks, dtype = UnitDebuff(frame.unit,i)
			ScanTip:ClearLines()
			ScanTip:SetUnitDebuff(frame.unit,i)
			buffName = LunaAuraScanTipTextLeft1:GetText()
		end
		if buffName and config.emphasizeAuras.debuffs[buffName] then
			button.large = true
		else
			button.large = nil
		end
		if not LunaUF.db.profile.locked then
			texture = "Interface\\Icons\\Spell_ChargeNegative"
			stacks = i
		end
		if not config.debuffs then
			texture = nil
		end
		if texture then
			button:Show()
			button.icon:SetTexture(texture)
			if stacks > 1 then
				button.stack:Show()
				button.stack:SetText(stacks)
			else
				button.stack:Hide()
			end
			button.auraID = buffIndex or i
			button.filter = "HARMFUL"
			if config.bordercolor and dtype then
				button.border:SetVertexColor(unpack(LunaUF.db.profile.magicColors[dtype]))
			else
				button.border:SetVertexColor(1,1,1)
			end
			if timeleft and timeleft > 0 and buffName then
				if (not LunaBuffDB[buffName] or LunaBuffDB[buffName] < timeleft) then
					LunaBuffDB[buffName] = timeleft
				end
				CooldownFrame_SetTimer(button.cooldown, GetTime() - (LunaBuffDB[buffName] - timeleft), LunaBuffDB[buffName], 1)
				button.timeleft = timeleft
				button:SetScript("OnUpdate", TimerUpdate)
				if config.timerspinenabled then
					button.cooldown:Show()
				else
					button.cooldown:Hide()
				end
				if config.timertextenabled then
					button.timeFontstring:Show()
				else
					button.timeFontstring:Hide()
				end
			elseif button.cooldown then
				button.cooldown:Hide()
				button.timeFontstring:Hide()
				button:SetScript("OnUpdate", nil)
			end
		else
			button:Hide()
		end
	end
	--[[
	for i=1,32 do
		texture = UnitBuff(frame.unit,i,1)
		if not texture then break end
		for i,button in ipairs(frame.auras.buffbuttons.buttons) do
			if not button.large and button.icon:GetTexture() == texture then
				button.large = true
				break
			end
		end
	end
	for i=1,16 do
		texture = UnitDebuff(frame.unit,i,1)
		if not texture then break end
		for i,button in ipairs(frame.auras.debuffbuttons.buttons) do
			if not button.large and button.icon:GetTexture() == texture then
				button.large = true
				break
			end
		end
	end
	--]]
end

function Auras:UpdateLayout(frame)
	local config = LunaUF.db.profile.units[frame.unitGroup].auras
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
	
	local framelength = frame:GetWidth()
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
			button.stack:SetFont(defaultFont, (10*(buttonsize/18)), "OUTLINE")
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
			button.stack:SetFont(defaultFont, (10*(buttonsize/18)), "OUTLINE")
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
			button.stack:SetFont(defaultFont, (10*(buttonsize/18)), "OUTLINE")
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
			button.stack:SetFont(defaultFont, (10*(buttonsize/18)), "OUTLINE")
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
			button.stack:SetFont(defaultFont, (10*(buttonsize/18)), "OUTLINE")
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
			button.stack:SetFont(defaultFont, (10*(buttonsize/18)), "OUTLINE")
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
			button.stack:SetFont(defaultFont, (10*(buttonsize/18)), "OUTLINE")
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
			button.stack:SetFont(defaultFont, (10*(buttonsize/18)), "OUTLINE")
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

function Auras:FullUpdate(frame)
	self:UpdateFrames(frame)
	self:UpdateLayout(frame)
end
