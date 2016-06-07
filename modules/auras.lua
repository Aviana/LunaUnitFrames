local L = LunaUF.L
local Auras = {}
LunaUF:RegisterModule(Auras, "auras", L["Auras"])

LunaBuffDBPlayerString = UnitName("player") .. " of " .. GetCVar("realmName")
OldLunaBuffDB = {}

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
	local isPlayer = unit == "player"
	local config = LunaUF.db.profile.units[auraframe:GetParent().unitGroup].auras
	local numBuffs = 0
	while UnitBuff(unit, numBuffs+1) do
		numBuffs = numBuffs + 1
	end
	local rows = math.ceil(numBuffs/config.AurasPerRow)
	local height = rows*auraframe.buffbuttons[1]:GetHeight()+rows
	auraframe:SetHeight(height == 0 and 1 or height)
	local texture, stacks
	if isPlayer and not buildOnly then
		for k, v in pairs(LunaBuffDB[LunaBuffDBPlayerString]) do
			OldLunaBuffDB[k] = LunaBuffDB[LunaBuffDBPlayerString][k]
			LunaBuffDB[LunaBuffDBPlayerString][k] = nil
		end
	end
	for i,button in ipairs(auraframe.buffbuttons) do
		local buffIndex, untilCancelled
		if isPlayer then
			buffIndex, untilCancelled = GetPlayerBuff(i - 1, "HELPFUL");
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
				button.untilCancelled = untilCancelled
				button:SetScript("OnClick", BuffButtonClick)
				button.auraID = buffIndex
				if not buildOnly then
					local timeLeft = GetPlayerBuffTimeLeft(buffIndex)
					LunaUF.ScanTip:ClearLines()
					LunaUF.ScanTip:SetPlayerBuff(buffIndex)
					local buffName = LunaScanTipTextLeft1:GetText()
					if OldLunaBuffDB[buffName] then
						if timeLeft > OldLunaBuffDB[buffName] then
							LunaBuffDB[LunaBuffDBPlayerString][buffName] = math.ceil(timeLeft)
						else
							LunaBuffDB[LunaBuffDBPlayerString][buffName] = OldLunaBuffDB[buffName]
						end
					elseif timeLeft > 0 and buffName then
						LunaBuffDB[LunaBuffDBPlayerString][buffName] = math.ceil(timeLeft)
					end
					if (config.timerspinenabled) then
						if timeLeft > 0 then
							CooldownFrame_SetTimer(button.cooldown, GetTime() - (LunaBuffDB[LunaBuffDBPlayerString][buffName] - timeLeft), LunaBuffDB[LunaBuffDBPlayerString][buffName], 1)
						else
							CooldownFrame_SetTimer(button.cooldown, 0, timeLeft, 0)
						end
						button.cooldown:Show();
					else
						button.cooldown:Hide();
					end
				end
			else
				button:SetScript("OnClick", nil)
				button.auraID = i
			end
			button:Show()
		else
			if isPlayer then
				button:SetScript("OnClick", nil)
			end
			button:Hide()
		end
	end
	for i,button in ipairs(auraframe.debuffbuttons) do
		local buffIndex = GetPlayerBuff(i - 1, "HARMFUL");
		if isPlayer then
			texture = GetPlayerBuffTexture(buffIndex);
			stacks = GetPlayerBuffApplications(buffIndex);
		else
			texture,stacks = UnitDebuff(unit,i)
		end
		if texture then
			button.icon:SetTexture(texture)
			button.stack:SetText(stacks == 1 and "" or stacks)
			button.filter = "HARMFUL"
			if isPlayer then
				button.auraID = buffIndex
				if OldLunaBuffDB then
					local timeLeft = GetPlayerBuffTimeLeft(buffIndex)
					LunaUF.ScanTip:ClearLines()
					LunaUF.ScanTip:SetPlayerBuff(buffIndex)
					local buffName = LunaScanTipTextLeft1:GetText()
					if OldLunaBuffDB[buffName] then
						if timeLeft > OldLunaBuffDB[buffName] then
							LunaBuffDB[LunaBuffDBPlayerString][buffName] =  math.ceil(timeLeft)
						else
							LunaBuffDB[LunaBuffDBPlayerString][buffName] = OldLunaBuffDB[buffName]
						end
					elseif timeLeft > 0 and buffName then
						LunaBuffDB[LunaBuffDBPlayerString][buffName] =  math.ceil(timeLeft)
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
				end
			else
				button.auraID = i
			end
			button:Show()
		else
			button:Hide()
		end
	end
	for k, v in pairs(OldLunaBuffDB) do
		OldLunaBuffDB[k] = nil
	end
end

function BuffButtonClick()
	if (arg1 ~= "RightButton") then return; end
	this:SetScript("OnClick", nil)
	CancelPlayerBuff(this.auraID)
end

local function OnEvent()
	if (((this:GetParent().unit == "player") and (event == "PLAYER_AURAS_CHANGED"))
	or ((this:GetParent().unit ~= "player") and (arg1 == this:GetParent().unit))) then
		BuffFrameUpdate(this, false)
	end
end

local function OnUpdate()
	if not (this:GetParent().unit == "player") then return end
	local config = LunaUF.db.profile.units[this:GetParent().unitGroup].auras
	for i,button in ipairs(this.buffbuttons) do
		if (button:IsVisible() and button.untilCancelled == 0) then
			local timeLeft = GetPlayerBuffTimeLeft(button.auraID)
			if (config.timertextenabled) then
				local timeString = ""
				local centered
				local timeL = timeLeft
				if (timeL and timeL > 0) then
					timeL = math.ceil(timeL);
					centered = (timeL < 10)
					if (timeL > 3599) then
						timeString = math.ceil(timeL / 3600).." h"
					elseif (timeL > 59) then
						timeString = math.ceil(timeL / 60).." m"
					elseif not centered then
						timeString = timeL.." s"
					else
						timeString = timeL
					end
				end
				if centered then
					button.timeFontstrings["CENTER"]:SetText(timeString)
					button.timeFontstrings["TOP"]:SetText("")
				else
					button.timeFontstrings["CENTER"]:SetText("")
					button.timeFontstrings["TOP"]:SetText(timeString)
				end
			else
				button.timeFontstrings["CENTER"]:SetText("")
				button.timeFontstrings["TOP"]:SetText("")
			end
		else
			button.cooldown:Hide()
			button.timeFontstrings["CENTER"]:SetText("")
			button.timeFontstrings["TOP"]:SetText("")
		end
	end
	for i,button in ipairs(this.debuffbuttons) do
		if (button:IsVisible()) then
			local timeLeft = GetPlayerBuffTimeLeft(button.auraID)
			if (config.timertextenabled) then
				local timeString = ""
				local centered
				local timeL = timeLeft
				if (timeL and timeL > 0) then
					timeL = math.ceil(timeL);
					centered = (timeL < 10)
					if (timeL > 3599) then
						timeString = math.ceil(timeL / 3600).." h"
					elseif (timeL > 59) then
						timeString = math.ceil(timeL / 60).." m"
					elseif not centered then
						timeString = timeL.." s"
					else
						timeString = timeL
					end
				end
				if centered then
					button.timeFontstrings["CENTER"]:SetText(timeString)
					button.timeFontstrings["TOP"]:SetText("")
				else
					button.timeFontstrings["CENTER"]:SetText("")
					button.timeFontstrings["TOP"]:SetText(timeString)
				end
			else
				button.timeFontstrings["CENTER"]:SetText("")
				button.timeFontstrings["TOP"]:SetText("")
			end
		else
			button.cooldown:Hide()
			button.timeFontstrings["CENTER"]:SetText("")
			button.timeFontstrings["TOP"]:SetText("")
		end
	end
end

function Auras:OnEnable(frame)
	local isPlayer = frame.unitGroup == "player"
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
				button.cooldown:SetFrameLevel(7)
				button.cooldown.reverse = true
				button.cooldown:Hide()
				button.textFrame = CreateFrame("Frame", nil, button)
				button.textFrame:SetAllPoints(button)
				button.textFrame:SetFrameLevel(button.cooldown:GetFrameLevel() + 1);
				button.timeFontstrings = {}
				button.timeFontstrings["TOP"] = button.textFrame:CreateFontString(nil, "OVERLAY");
				button.timeFontstrings["TOP"]:SetJustifyH("CENTER")
				button.timeFontstrings["TOP"]:SetPoint("TOP", button.textFrame, "TOP",0,0)
				button.timeFontstrings["CENTER"] = button.textFrame:CreateFontString(nil, "OVERLAY");
				button.timeFontstrings["CENTER"]:SetJustifyH("CENTER")
				button.timeFontstrings["CENTER"]:SetPoint("CENTER", button.textFrame, "CENTER",0,0)
			end

			button.stack = button:CreateFontString(nil, "OVERLAY")
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", 10, "OUTLINE")
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
				button.cooldown:SetFrameLevel(7)
				button.cooldown.reverse = true
				button.cooldown:Hide()
				button.textFrame = CreateFrame("Frame", nil, button)
				button.textFrame:SetAllPoints(button)
				button.textFrame:SetFrameLevel(button.cooldown:GetFrameLevel() + 1);
				button.timeFontstrings = {}
				button.timeFontstrings["TOP"] = button.textFrame:CreateFontString(nil, "OVERLAY");
				button.timeFontstrings["TOP"]:SetJustifyH("CENTER")
				button.timeFontstrings["TOP"]:SetPoint("TOP", button.textFrame, "TOP",0,0)
				button.timeFontstrings["CENTER"] = button.textFrame:CreateFontString(nil, "OVERLAY");
				button.timeFontstrings["CENTER"]:SetJustifyH("CENTER")
				button.timeFontstrings["CENTER"]:SetPoint("CENTER", button.textFrame, "CENTER",0,0)
			end

			button.stack = button:CreateFontString(nil, "OVERLAY")
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", 10, "OUTLINE")
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
	local row = 1
	frame.auras:ClearAllPoints()
	frame.auras:SetWidth(1)
	frame.auras:SetHeight(1)
	if config.position == "TOP" then
		frame.auras:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 3)
		for i,button in ipairs(frame.auras.buffbuttons) do
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.border:SetHeight(buttonsize+1)
			button.border:SetWidth(buttonsize+1)
			button.stack:SetText(i)
			button:SetPoint("BOTTOMLEFT", frame.auras, "BOTTOMLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), (math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button.border, "TOPLEFT",0,0)
				button.cooldown:SetScale((button.border:GetWidth()+1)/36)
			end
			if button.timeFontstrings then
				button.timeFontstrings["TOP"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				button.timeFontstrings["CENTER"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
			end
		end
		for i,button in ipairs(frame.auras.debuffbuttons) do
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.border:SetHeight(buttonsize+1)
			button.border:SetWidth(buttonsize+1)
			button.stack:SetText(i)
			button:SetPoint("BOTTOMLEFT", frame.auras, "TOPLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), (math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button.border, "TOPLEFT",0,0)
				button.cooldown:SetScale((button.border:GetWidth()+1)/36)
			end
			if button.timeFontstrings then
				button.timeFontstrings["TOP"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				button.timeFontstrings["CENTER"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
			end
		end
	elseif config.position == "LEFT" then
		frame.auras:SetPoint("TOPRIGHT", frame, "TOPLEFT", -3, 0)
		for i,button in ipairs(frame.auras.buffbuttons) do
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.border:SetHeight(buttonsize+1)
			button.border:SetWidth(buttonsize+1)
			button.stack:SetText(i)
			button:SetPoint("TOPRIGHT", frame.auras, "TOPRIGHT", -((i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1))), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button.border, "TOPLEFT",0,0)
				button.cooldown:SetScale((button.border:GetWidth()+1)/36)
			end
			if button.timeFontstrings then
				button.timeFontstrings["TOP"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				button.timeFontstrings["CENTER"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
			end
		end
		for i,button in ipairs(frame.auras.debuffbuttons) do
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.border:SetHeight(buttonsize+1)
			button.border:SetWidth(buttonsize+1)
			button.stack:SetText(i)
			button:SetPoint("TOPRIGHT", frame.auras, "BOTTOMRIGHT", -((i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1))), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button.border, "TOPLEFT",0,0)
				button.cooldown:SetScale((button.border:GetWidth()+1)/36)
			end
			if button.timeFontstrings then
				button.timeFontstrings["TOP"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				button.timeFontstrings["CENTER"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
			end
		end
	else
		if config.position == "BOTTOM" then
			frame.auras:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -3)
		else
			frame.auras:SetPoint("TOPLEFT", frame, "TOPRIGHT", 3, 0)
		end
		for i,button in ipairs(frame.auras.buffbuttons) do
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.border:SetHeight(buttonsize+1)
			button.border:SetWidth(buttonsize+1)
			button.stack:SetText(i)
			button:SetPoint("TOPLEFT", frame.auras, "TOPLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button.border, "TOPLEFT",0,0)
				button.cooldown:SetScale((button.border:GetWidth()+1)/36)
			end
			if button.timeFontstrings then
				button.timeFontstrings["TOP"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				button.timeFontstrings["CENTER"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
			end
		end
		for i,button in ipairs(frame.auras.debuffbuttons) do
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.border:SetHeight(buttonsize+1)
			button.border:SetWidth(buttonsize+1)
			button.stack:SetText(i)
			button:SetPoint("TOPLEFT", frame.auras, "BOTTOMLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
			if button.cooldown then
				button.cooldown:SetPoint("TOPLEFT", button.border, "TOPLEFT",0,0)
				button.cooldown:SetScale((button.border:GetWidth()+1)/36)
			end
			if button.timeFontstrings then
				button.timeFontstrings["TOP"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", LunaUF.db.profile.units["player"].auras.timertextsmallsize, "OUTLINE")
				button.timeFontstrings["CENTER"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", LunaUF.db.profile.units["player"].auras.timertextbigsize, "OUTLINE")
			end
		end
	end
	BuffFrameUpdate(frame.auras, true)
end
