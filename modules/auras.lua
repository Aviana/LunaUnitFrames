local L = LunaUF.L
local Auras = {}
local defaultFont = LunaUF.defaultFont
LunaUF:RegisterModule(Auras, "auras", L["Auras"])

local LunaBuffDBPlayerString = UnitName("player") .. " of " .. GetCVar("realmName")
local currentBuffTable = {}
local bufftimers = {}
local debufftimers = {}
local FrameUpdateNeeded
local mainEnchant, offEnchant, longMain, longOff

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

local function BuffFrameUpdate(frame, buildOnly)
	local auraframe = frame or this
	local unit = auraframe:GetParent().unit
	local isPlayer = auraframe:GetParent().unitGroup == "player"
	local config = LunaUF.db.profile.units[auraframe:GetParent().unitGroup].auras
	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
	if not isPlayer then
		hasMainHandEnchant = nil
		hasOffHandEnchant = nil
	end
	local numBuffs = 0
	if isPlayer then
		while GetPlayerBuff(numBuffs, "HELPFUL") ~= -1 do
			numBuffs = numBuffs + 1
		end
		if hasMainHandEnchant then
			numBuffs = numBuffs + 1
		end
		if hasOffHandEnchant then
			numBuffs = numBuffs + 1
		end
	else
		while UnitBuff(unit, numBuffs+1) do
			numBuffs = numBuffs + 1
		end
	end
	local rows = math.ceil(numBuffs/config.AurasPerRow)
	local height
	if config.buffs=="DEBUFFS" then		
		height = rows*auraframe.buffbuttons[1]:GetHeight()+rows		
	else
		height = rows*auraframe.debuffbuttons[1]:GetHeight()+rows
	end
	auraframe:SetHeight(height == 0 and 1 or height)
	local texture, stacks, dtype
	local currentEventTime = GetTime()
	if config.buffs=="BUFFS" or config.buffs=="BOTH" then
		for i,button in ipairs(auraframe.buffbuttons) do
			local buffIndex, untilCancelled
			if isPlayer then
				buffIndex, untilCancelled = GetPlayerBuff(i - 1, "HELPFUL");
				dtype = GetPlayerBuffDispelType(buffIndex);
				texture = GetPlayerBuffTexture(buffIndex);
				stacks = GetPlayerBuffApplications(buffIndex);
			else
				texture,stacks = UnitBuff(unit,i)
			end
			if texture then
				button.icon:SetTexture(texture)
				button.stack:SetText(stacks == 1 and "" or stacks)
				button.filter = "HELPFUL"
				if isPlayer then
					if config.bordercolor and dtype then
						button.border:SetVertexColor(unpack(LunaUF.db.profile.magicColors[dtype]))
					else
						button.border:SetVertexColor(1,1,1)
					end
					button.untilCancelled = untilCancelled
					button:SetScript("OnClick", BuffButtonClick)
					button.auraID = buffIndex
					if not buildOnly and untilCancelled == 0 then
						local timeLeft = GetPlayerBuffTimeLeft(buffIndex)
						LunaUF.ScanTip:ClearLines()
						LunaUF.ScanTip:SetPlayerBuff(buffIndex)
						local buffName = LunaScanTipTextLeft1:GetText()
						if timeLeft and timeLeft > 0 then
							currentBuffTable[buffName] = currentEventTime
							if not LunaBuffDB[LunaBuffDBPlayerString][buffName] or timeLeft > LunaBuffDB[LunaBuffDBPlayerString][buffName] then
								LunaBuffDB[LunaBuffDBPlayerString][buffName] = math.ceil(timeLeft)
							end
						end
						if config.timerspinenabled then
							if timeLeft > 0 then
								CooldownFrame_SetTimer(button.cooldown, GetTime() - (LunaBuffDB[LunaBuffDBPlayerString][buffName] - timeLeft), LunaBuffDB[LunaBuffDBPlayerString][buffName], 1)
							else
								CooldownFrame_SetTimer(button.cooldown, 0, timeLeft, 0)
							end
							button.cooldown:Show();
						else
							button.cooldown:Hide();
						end
					else
						button.cooldown:Hide();
					end
				else
					button:SetScript("OnClick", nil)
					button.auraID = i
				end
				button:Show()
			elseif hasMainHandEnchant then
				button.icon:SetTexture(GetInventoryItemTexture("player", 16))
				button.auraID = 16
				button.filter = "TEMP"
				if config.bordercolor then
					button.border:SetVertexColor(0.53,0.28,0.72)
				else
					button.border:SetVertexColor(1,1,1)
				end
				if config.timerspinenabled then
					CooldownFrame_SetTimer(button.cooldown, GetTime() - ((longMain and 3600 or 1800) - (mainHandExpiration/1000)), (longMain and 3600 or 1800), 1)
				else
					button.cooldown:Hide()
				end
				button:Show()
				hasMainHandEnchant = nil
			elseif hasOffHandEnchant then
				button.icon:SetTexture(GetInventoryItemTexture("player", 17))
				button.auraID = 17
				button.filter = "TEMP"
				if config.bordercolor then
					button.border:SetVertexColor(0.53,0.28,0.72)
				else
					button.border:SetVertexColor(1,1,1)
				end
				if config.timerspinenabled then
					CooldownFrame_SetTimer(button.cooldown, GetTime() - ((longOff and 3600 or 1800) - (offHandExpiration/1000)), (longOff and 3600 or 1800), 1)
				else
					button.cooldown:Hide()
				end
				button:Show()
				hasOffHandEnchant = nil
			else
				if isPlayer then
					button:SetScript("OnClick", nil)
				end
				button:Hide()
			end
		end
	end
	if config.buffs=="BOTH" or config.buffs=="DEBUFFS" then
		for i,button in ipairs(auraframe.debuffbuttons) do
			local buffIndex, untilCancelled
			if isPlayer then
				buffIndex, untilCancelled = GetPlayerBuff(i - 1, "HARMFUL");
				texture = GetPlayerBuffTexture(buffIndex);
				stacks = GetPlayerBuffApplications(buffIndex);
				dtype = GetPlayerBuffDispelType(buffIndex)
			else
				texture,stacks,dtype = UnitDebuff(unit,i)
			end
			if texture then
				button.icon:SetTexture(texture)
				button.stack:SetText(stacks == 1 and "" or stacks)
				button.filter = "HARMFUL"
				if dtype and config.bordercolor then
					button.border:SetVertexColor(unpack(LunaUF.db.profile.magicColors[dtype]))
				else
					button.border:SetVertexColor(1,1,1)
				end
				if isPlayer then
					button.untilCancelled = untilCancelled
					button.auraID = buffIndex
					if not buildOnly and untilCancelled == 0 then
						local timeLeft = GetPlayerBuffTimeLeft(buffIndex)
						LunaUF.ScanTip:ClearLines()
						LunaUF.ScanTip:SetPlayerBuff(buffIndex)
						local buffName = LunaScanTipTextLeft1:GetText()
						if timeLeft and timeLeft > 0 then
							currentBuffTable[buffName] = currentEventTime
							if not LunaBuffDB[LunaBuffDBPlayerString][buffName] or timeLeft > LunaBuffDB[LunaBuffDBPlayerString][buffName] then
								LunaBuffDB[LunaBuffDBPlayerString][buffName] = math.ceil(timeLeft)
								currentBuffTable[buffName] = currentEventTime
							end
						end
						if (config.timerspinenabled) then
							if timeLeft > 0 then
								CooldownFrame_SetTimer(button.cooldown, GetTime() - (LunaBuffDB[LunaBuffDBPlayerString][buffName] - timeLeft), LunaBuffDB[LunaBuffDBPlayerString][buffName] , 1)
							else
								CooldownFrame_SetTimer(button.cooldown, 0, timeLeft, 0)
							end
							button.cooldown:Show();
						else
							button.cooldown:Hide();
						end
					else
						button.cooldown:Hide();
					end
				else
					button.auraID = i
				end
				button:Show()
			else
				button:Hide()
			end
		end
	end
	if isPlayer and not buildOnly then
		for k, v in pairs(LunaBuffDB[LunaBuffDBPlayerString]) do
			if currentBuffTable[k] ~= currentEventTime then
				LunaBuffDB[LunaBuffDBPlayerString][k] = nil
			end
		end
	end
end

function BuffButtonClick()
	if (arg1 ~= "RightButton") then return; end
	this:SetScript("OnClick", nil)
	CancelPlayerBuff(this.auraID)
end

local function OnEvent()
	if (((this:GetParent().unitGroup == "player") and (event == "PLAYER_AURAS_CHANGED"))
	or ((this:GetParent().unitGroup ~= "player") and (arg1 == this:GetParent().unit))) then
		BuffFrameUpdate(this, false)
	end
end

local function getTimeString(timeLeft)
	local timeString = ""
	local expiring
	local timeL = timeLeft
	if (timeL and timeL > 0) then
		timeL = math.ceil(timeL);
		expiring = (timeL < 10)
		if (timeL > 3599) then
			timeString = math.ceil(timeL / 3600).." h"
		elseif (timeL > 59) then
			timeString = math.ceil(timeL / 60).." m"
		elseif not expiring then
			timeString = timeL.." s"
		else
			timeString = timeL
		end
	end
	return timeString, expiring
end

local function OnUpdate()
	if not (this:GetParent().unitGroup == "player") then return end
	local config = LunaUF.db.profile.units[this:GetParent().unitGroup].auras
	local changed
	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
	if hasMainHandEnchant ~= mainEnchant or hasOffHandEnchant ~= offEnchant then
		changed = 1
		mainEnchant = hasMainHandEnchant
		longMain = hasMainHandEnchant and mainHandExpiration > 1800000
		offEnchant = hasOffHandEnchant
		longOff = hasOffHandEnchant and offHandExpiration > 1800000
	end
	for i,button in ipairs(this.buffbuttons) do
		local timeLeft
		if (button:IsVisible() and button.untilCancelled == 0 and button.filter ~= "TEMP") then
			timeLeft = button.auraID and GetPlayerBuffTimeLeft(button.auraID) or 0
			if bufftimers[i] and timeLeft > bufftimers[i] then
				changed = 1
			end
			bufftimers[i] = timeLeft
			if (config.timertextenabled) then
				local timeString, expiring = getTimeString(timeLeft)
				button.timeFontstring:SetText(timeString)
				if expiring then
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
				else
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				end
			else
				button.timeFontstring:SetText("")
			end
		elseif button:IsVisible() and button.auraID == 16 and hasMainHandEnchant then
			if (config.timertextenabled) then
				local timeString, expiring = getTimeString(mainHandExpiration/1000)
				button.timeFontstring:SetText(timeString)
				if expiring then
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
				else
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				end
			end
			button.stack:SetText(mainHandCharges and mainHandCharges <= 1 and "" or mainHandCharges)
		elseif button:IsVisible() and button.auraID == 17 and hasOffHandEnchant then
			if (config.timertextenabled) then
				local timeString, expiring = getTimeString(offHandExpiration/1000)
				button.timeFontstring:SetText(timeString)
				if expiring then
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
				else
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				end
			end
			button.stack:SetText(offHandCharges and offHandCharges <= 1 and "" or offHandCharges)
		else
			button.timeFontstring:SetText("")
		end
	end
	for i,button in ipairs(this.debuffbuttons) do
		local timeLeft = button.auraID and GetPlayerBuffTimeLeft(button.auraID) or 0
		if debufftimers[i] and timeLeft > debufftimers[i] then
			changed = 1
		end
		debufftimers[i] = timeLeft
		if (button:IsVisible() and button.untilCancelled == 0) then
			if (config.timertextenabled) then
				local timeString, expiring = getTimeString(timeLeft)
				button.timeFontstring:SetText(timeString)
				if expiring then
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
				else
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				end
			else
				button.timeFontstring:SetText("")
			end
		else
			button.timeFontstring:SetText("")
		end
	end
	if changed or FrameUpdateNeeded then
		BuffFrameUpdate(this, false)
		FrameUpdateNeeded = false
	end
end

function Auras:OnEnable(frame)
	local isPlayer = frame.unitGroup == "player"
	local config = LunaUF.db.profile.units[frame.unitGroup].auras
	if not LunaBuffDB then
		LunaBuffDB = {}
	end
	if not LunaBuffDB[LunaBuffDBPlayerString] then
		LunaBuffDB[LunaBuffDBPlayerString] = {}
	end
	if not frame.auras then
		frame.auras = CreateFrame("Frame", nil, frame)
		frame.auras.buffbuttons = {}
		frame.auras.debuffbuttons = {}
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
				button.timeFontstring = button.textFrame:CreateFontString(nil, "OVERLAY");
				button.timeFontstring:SetJustifyH("CENTER")
				button.timeFontstring:SetPoint("CENTER", button.textFrame, "CENTER",0,0)
			end

			button.stack = button:CreateFontString(nil, "OVERLAY")
			button.stack:SetFont(defaultFont, 10, "OUTLINE")
			button.stack:SetShadowColor(0, 0, 0, 1.0)
			button.stack:SetShadowOffset(0.50, -0.50)
			button.stack:SetHeight(1)
			button.stack:SetWidth(1)
			button.stack:SetAllPoints(button)
			button.stack:SetJustifyV("BOTTOM")
			button.stack:SetJustifyH("RIGHT")

			button.border = button:CreateTexture(nil, "OVERLAY")
			button.border:SetPoint("CENTER", button)

			button.icon = button:CreateTexture(nil, "BACKGROUND")
			button.icon:SetAllPoints(button)
			button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

			frame.auras.buffbuttons[i] = button
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
				button.timeFontstring = button.textFrame:CreateFontString(nil, "OVERLAY");
				button.timeFontstring:SetJustifyH("CENTER")
				button.timeFontstring:SetPoint("CENTER", button.textFrame, "CENTER",0,0)
			end

			button.stack = button:CreateFontString(nil, "OVERLAY")
			button.stack:SetFont(defaultFont, 10, "OUTLINE")
			button.stack:SetShadowColor(0, 0, 0, 1.0)
			button.stack:SetShadowOffset(0.50, -0.50)
			button.stack:SetHeight(1)
			button.stack:SetWidth(1)
			button.stack:SetAllPoints(button)
			button.stack:SetJustifyV("BOTTOM")
			button.stack:SetJustifyH("RIGHT")

			button.border = button:CreateTexture(nil, "OVERLAY")
			button.border:SetPoint("CENTER", button)

			button.icon = button:CreateTexture(nil, "BACKGROUND")
			button.icon:SetAllPoints(button)
			button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

			frame.auras.debuffbuttons[i] = button
		end
	end
	for num,button in pairs(frame.auras.buffbuttons) do
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
	for num,button in pairs(frame.auras.debuffbuttons) do
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
	frame.auras:RegisterEvent("UNIT_AURA")
	frame.auras:RegisterEvent("PLAYER_AURAS_CHANGED")
	frame.auras:SetScript("OnEvent", OnEvent)
	frame.auras:SetScript("OnUpdate", OnUpdate)
end

function Auras:OnDisable(frame)
	if frame.auras then
		frame.auras:UnregisterAllEvents()
		frame.auras:SetScript("OnEvent", nil)
		frame.auras:SetScript("OnUpdate", nil)
		frame.auras:Hide()
	end
end

function Auras:FullUpdate(frame)
	local config = LunaUF.db.profile.units[frame.unitGroup].auras
	local framelength = frame:GetWidth()
	local frameheight = frame:GetHeight()
	local buttonsize = ((framelength-config.AurasPerRow-1)/config.AurasPerRow)
	frame.auras:ClearAllPoints()
	frame.auras:SetWidth(1)
	frame.auras:SetHeight(1)
	if config.position == "TOP" then
		frame.auras:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 3)
		for i,button in ipairs(frame.auras.buffbuttons) do
			if config.buffs=="BUFFS" or config.buffs=="BOTH" then
				button:ClearAllPoints()
				button:SetHeight(buttonsize)
				button:SetWidth(buttonsize)
				button.border:SetHeight(buttonsize+1)
				button.border:SetWidth(buttonsize+1)
				button.stack:SetText(i)
				button:SetPoint("BOTTOMLEFT", frame.auras, "BOTTOMLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), (math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
				if button.cooldown then
					button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
					button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
				end
				if button.timeFontstring then
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				end
			else
				button:Hide()
			end
		end
		for i,button in ipairs(frame.auras.debuffbuttons) do
			if config.buffs=="BOTH" or config.buffs=="DEBUFFS" then
				button:ClearAllPoints()
				button:SetHeight(buttonsize)
				button:SetWidth(buttonsize)
				button.border:SetHeight(buttonsize+1)
				button.border:SetWidth(buttonsize+1)
				button.stack:SetText(i)
				if config.buffs=="DEBUFFS" then
					button:SetPoint("BOTTOMLEFT", frame.auras, "BOTTOMLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), (math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
				else
					button:SetPoint("BOTTOMLEFT", frame.auras, "TOPLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), (math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
				end
				if button.cooldown then
					button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
					button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
				end
				if button.timeFontstring then
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				end
			else
				button:Hide()
			end
		end
	elseif config.position == "LEFT" then
		frame.auras:SetPoint("TOPRIGHT", frame, "TOPLEFT", -3, 0)
		for i,button in ipairs(frame.auras.buffbuttons) do
			if config.buffs=="BUFFS" or config.buffs=="BOTH" then
				button:ClearAllPoints()
				button:SetHeight(buttonsize)
				button:SetWidth(buttonsize)
				button.border:SetHeight(buttonsize+1)
				button.border:SetWidth(buttonsize+1)
				button.stack:SetText(i)
				button:SetPoint("TOPRIGHT", frame.auras, "TOPRIGHT", -((i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1))), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
				if button.cooldown then
					button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
					button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
				end
				if button.timeFontstring then
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				end
			else
				button:Hide()
			end
		end
		for i,button in ipairs(frame.auras.debuffbuttons) do
			if config.buffs=="BOTH" or config.buffs=="DEBUFFS" then
				button:ClearAllPoints()
				button:SetHeight(buttonsize)
				button:SetWidth(buttonsize)
				button.border:SetHeight(buttonsize+1)
				button.border:SetWidth(buttonsize+1)
				button.stack:SetText(i)
				if config.buffs=="DEBUFFS" then
					button:SetPoint("TOPRIGHT", frame.auras, "TOPRIGHT", -((i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1))), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
				else
					button:SetPoint("TOPRIGHT", frame.auras, "BOTTOMRIGHT", -((i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1))), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
				end
				if button.cooldown then
					button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
					button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
				end
				if button.timeFontstring then
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				end
			else
				button:Hide()
			end
		end
	else
		if config.position == "BOTTOM" then
			frame.auras:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -3)
		else
			frame.auras:SetPoint("TOPLEFT", frame, "TOPRIGHT", 3, 0)
		end
		for i,button in ipairs(frame.auras.buffbuttons) do
			if config.buffs=="BUFFS" or config.buffs=="BOTH" then
				button:ClearAllPoints()
				button:SetHeight(buttonsize)
				button:SetWidth(buttonsize)
				button.border:SetHeight(buttonsize+1)
				button.border:SetWidth(buttonsize+1)
				button.stack:SetText(i)
				button:SetPoint("TOPLEFT", frame.auras, "TOPLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
				if button.cooldown then
					button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
					button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
				end
				if button.timeFontstring then
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				end
			else
				button:Hide()
			end
		end
		for i,button in ipairs(frame.auras.debuffbuttons) do
			if config.buffs=="BOTH" or config.buffs=="DEBUFFS" then
				button:ClearAllPoints()
				button:SetHeight(buttonsize)
				button:SetWidth(buttonsize)
				button.border:SetHeight(buttonsize+1)
				button.border:SetWidth(buttonsize+1)
				button.stack:SetText(i)
				if config.buffs=="DEBUFFS" then
					button:SetPoint("TOPLEFT", frame.auras, "TOPLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
				else
					button:SetPoint("TOPLEFT", frame.auras, "BOTTOMLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
				end
				
				if button.cooldown then
					button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
					button.cooldown:SetScale((button:GetWidth() + 0.7)/36)
				end
				if button.timeFontstring then
					button.timeFontstring:SetFont(defaultFont, LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				end
			else
				button:Hide()
			end
		end
	end
	BuffFrameUpdate(frame.auras, true)
	FrameUpdateNeeded = true
end
