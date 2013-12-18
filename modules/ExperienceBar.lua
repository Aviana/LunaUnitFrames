

function LunaUnitFrames:CreateXPBar()
	LunaUnitFrames.frames.ExperienceBar = CreateFrame("Frame", "LunaXPBar", LunaPlayerFrame)
	LunaUnitFrames.frames.ExperienceBar:SetHeight(10)
	LunaUnitFrames.frames.ExperienceBar:SetWidth(LunaPlayerFrame:GetWidth())
	LunaUnitFrames.frames.ExperienceBar:SetBackdrop(LunaOptions.backdrop)
	LunaUnitFrames.frames.ExperienceBar:SetBackdropColor(0,0,0,1)
	LunaUnitFrames.frames.ExperienceBar:SetPoint("TOP", LunaPlayerFrame, "BOTTOM", 0, -3)
	
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
		LunaUnitFrames:UpdatePlayerBuffLayout()
		return
	else
		LunaUnitFrames.frames.ExperienceBar:Show()
		LunaUnitFrames:UpdatePlayerBuffLayout()
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
	
	