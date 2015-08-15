function LunaUnitFrames:CreateRepBar()
	LunaUnitFrames.frames.ReputationBar = CreateFrame("Frame", "LunaRepBar", LunaPlayerFrame)
	LunaUnitFrames.frames.ReputationBar:SetHeight(10)
	LunaUnitFrames.frames.ReputationBar:SetWidth(LunaPlayerFrame:GetWidth())
	LunaUnitFrames.frames.ReputationBar:SetBackdrop(LunaOptions.backdrop)
	LunaUnitFrames.frames.ReputationBar:SetBackdropColor(0,0,0,1)
	LunaUnitFrames.frames.ReputationBar:SetPoint("TOP", LunaPlayerFrame, "BOTTOM", 0, -3)
	
	LunaUnitFrames.frames.ReputationBar.RepBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.ReputationBar)
	LunaUnitFrames.frames.ReputationBar.RepBar:SetAllPoints(LunaUnitFrames.frames.ReputationBar)
	LunaUnitFrames.frames.ReputationBar.RepBar:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaUnitFrames.frames.ReputationBar.RepBar:SetStatusBarColor(0,1,0)
	
	LunaUnitFrames.frames.ReputationBar.RepBar.xptext = LunaUnitFrames.frames.ReputationBar.RepBar:CreateFontString(nil, "OVERLAY")
	LunaUnitFrames.frames.ReputationBar.RepBar.xptext:SetPoint("CENTER", LunaUnitFrames.frames.ReputationBar.RepBar, "CENTER")
	LunaUnitFrames.frames.ReputationBar.RepBar.xptext:SetFont(LunaOptions.font, 10)
	LunaUnitFrames.frames.ReputationBar.RepBar.xptext:SetShadowColor(0, 0, 0)
	LunaUnitFrames.frames.ReputationBar.RepBar.xptext:SetShadowOffset(0.8, -0.8)

	LunaUnitFrames.frames.ReputationBar.onEvent = function () LunaUnitFrames:UpdateRepBar() end
	LunaUnitFrames.frames.ReputationBar:RegisterEvent("UPDATE_FACTION")
	LunaUnitFrames.frames.ReputationBar:SetScript("OnEvent", LunaUnitFrames.frames.ReputationBar.onEvent)
	LunaUnitFrames:UpdateRepBar()
end
	
function LunaUnitFrames:ResizeRepBar()
	LunaUnitFrames.frames.ReputationBar:SetHeight(10)
	LunaUnitFrames.frames.ReputationBar:SetWidth(LunaPlayerFrame:GetWidth())
end

function LunaUnitFrames:UpdateRepBar()
	local name, standing, minV, maxV, value = GetWatchedFactionInfo()
	local color = FACTION_BAR_COLORS[standing]
	if not name or not LunaOptions.RepBar then
		LunaUnitFrames.frames.ReputationBar:Hide()
		if LunaUnitFrames.frames.ExperienceBar then
			LunaUnitFrames.frames.ExperienceBar:SetPoint("TOP", LunaPlayerFrame, "BOTTOM", 0, -3)
		end
		LunaPlayerFrame.UpdateBuffSize()
		return
	else
		LunaUnitFrames.frames.ReputationBar:Show()
		if LunaUnitFrames.frames.ExperienceBar then
			LunaUnitFrames.frames.ExperienceBar:SetPoint("TOP", LunaPlayerFrame, "BOTTOM", 0, -15)
		end
		LunaPlayerFrame.UpdateBuffSize()
	end
	LunaUnitFrames.frames.ReputationBar.RepBar.xptext:SetText(name.." - "..(value-minV).."/"..(maxV-minV).."  ("..((math.floor(((value-minV)/(maxV-minV))*10000))/100).."%)")
	LunaUnitFrames.frames.ReputationBar.RepBar:SetMinMaxValues(minV,maxV)
	LunaUnitFrames.frames.ReputationBar.RepBar:SetValue(value)
	LunaUnitFrames.frames.ReputationBar.RepBar:SetStatusBarColor(color.r, color.g, color.b)
end

function LunaUnitFrames:CreateXPBar()
	LunaUnitFrames.frames.ExperienceBar = CreateFrame("Frame", "LunaXPBar", LunaPlayerFrame)
	LunaUnitFrames.frames.ExperienceBar:SetHeight(10)
	LunaUnitFrames.frames.ExperienceBar:SetWidth(LunaPlayerFrame:GetWidth())
	LunaUnitFrames.frames.ExperienceBar:SetBackdrop(LunaOptions.backdrop)
	LunaUnitFrames.frames.ExperienceBar:SetBackdropColor(0,0,0,1)
	
	LunaUnitFrames.frames.ExperienceBar.RestedBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.ExperienceBar)
	LunaUnitFrames.frames.ExperienceBar.RestedBar:SetAllPoints(LunaUnitFrames.frames.ExperienceBar)
	LunaUnitFrames.frames.ExperienceBar.RestedBar:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaUnitFrames.frames.ExperienceBar.RestedBar:SetStatusBarColor(0,0,1)
	
	LunaUnitFrames.frames.ExperienceBar.XPBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.ExperienceBar.RestedBar)
	LunaUnitFrames.frames.ExperienceBar.XPBar:SetAllPoints(LunaUnitFrames.frames.ExperienceBar)
	LunaUnitFrames.frames.ExperienceBar.XPBar:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaUnitFrames.frames.ExperienceBar.XPBar:SetStatusBarColor(0,1,0)
	
	LunaUnitFrames.frames.ExperienceBar.XPBar.xptext = LunaUnitFrames.frames.ExperienceBar.XPBar:CreateFontString(nil, "OVERLAY")
	LunaUnitFrames.frames.ExperienceBar.XPBar.xptext:SetPoint("CENTER", LunaUnitFrames.frames.ExperienceBar.XPBar, "CENTER")
	LunaUnitFrames.frames.ExperienceBar.XPBar.xptext:SetFont(LunaOptions.font, 10)
	LunaUnitFrames.frames.ExperienceBar.XPBar.xptext:SetShadowColor(0, 0, 0)
	LunaUnitFrames.frames.ExperienceBar.XPBar.xptext:SetShadowOffset(0.8, -0.8)

	LunaUnitFrames.frames.ExperienceBar.onEvent = function () LunaUnitFrames:UpdateXPBar() end
	LunaUnitFrames.frames.ExperienceBar:RegisterEvent("PLAYER_XP_UPDATE")
	LunaUnitFrames.frames.ExperienceBar:RegisterEvent("PLAYER_ALIVE")
	LunaUnitFrames.frames.ExperienceBar:SetScript("OnEvent", LunaUnitFrames.frames.ExperienceBar.onEvent)
	LunaUnitFrames:UpdateXPBar()
end

function LunaUnitFrames:ResizeXPBar()
	LunaUnitFrames.frames.ExperienceBar:SetHeight(10)
	LunaUnitFrames.frames.ExperienceBar:SetWidth(LunaPlayerFrame:GetWidth())
end

function LunaUnitFrames:UpdateXPBar()
	if UnitXPMax("player") == 0 or LunaOptions.XPBar == 0 then
		LunaUnitFrames.frames.ExperienceBar:Hide()
		LunaPlayerFrame.UpdateBuffSize()
		return
	else
		LunaUnitFrames.frames.ExperienceBar:Show()
		if LunaUnitFrames.frames.ReputationBar:IsShown() then
			LunaUnitFrames.frames.ExperienceBar:SetPoint("TOP", LunaPlayerFrame, "BOTTOM", 0, -15)
		else
			LunaUnitFrames.frames.ExperienceBar:SetPoint("TOP", LunaPlayerFrame, "BOTTOM", 0, -3)
		end
		LunaPlayerFrame.UpdateBuffSize()
	end
	LunaUnitFrames.frames.ExperienceBar.RestedBar:SetMinMaxValues(0,UnitXPMax("player"))
	if GetXPExhaustion() then
		LunaUnitFrames.frames.ExperienceBar.XPBar.xptext:SetText(UnitXP("player").."/"..UnitXPMax("player").."  ("..((math.floor((UnitXP("player")/UnitXPMax("player"))*10000))/100).."%)".." +"..GetXPExhaustion())
		LunaUnitFrames.frames.ExperienceBar.RestedBar:SetValue(UnitXP("player")+GetXPExhaustion())
	else
		LunaUnitFrames.frames.ExperienceBar.XPBar.xptext:SetText(UnitXP("player").."/"..UnitXPMax("player").."  ("..((math.floor((UnitXP("player")/UnitXPMax("player"))*10000))/100).."%)")
		LunaUnitFrames.frames.ExperienceBar.RestedBar:SetValue(UnitXP("player"))
	end
	LunaUnitFrames.frames.ExperienceBar.XPBar:SetMinMaxValues(0,UnitXPMax("player"))
	LunaUnitFrames.frames.ExperienceBar.XPBar:SetValue(UnitXP("player"))
end