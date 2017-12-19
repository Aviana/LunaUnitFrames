local Combat = {}
LunaUF:RegisterModule(Combat, "combatText", LunaUF.L["Combat text"])

local function OnEvent()
	if UnitIsUnit(arg1,this:GetParent().unit) then
		CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5)
	end
end

function Combat:OnEnable(frame)
	if not frame.combatText then
		frame.combatText = CreateFrame("Frame", nil, frame)
		frame.combatText:SetHeight(1)
		frame.combatText:SetWidth(1)
		frame.combatText:SetFrameStrata("HIGH")
		frame.combatText.feedbackText = frame.combatText:CreateFontString(nil, "ARTWORK")
		frame.combatText.feedbackText:SetPoint("CENTER", frame.combatText, "CENTER", 0, 0)
		frame.combatText:SetFrameLevel(frame.topFrameLevel)
		frame.combatText.feedbackFontHeight = 11
	end
	frame.combatText:Show()
	frame.combatText:SetScript("OnUpdate", CombatFeedback_OnUpdate)
	frame.combatText:SetScript("OnEvent", OnEvent)
	frame.combatText:RegisterEvent("UNIT_COMBAT")
	frame.combatText.feedbackStartTime = GetTime()
end

function Combat:OnDisable(frame)
	if frame.combatText then
		frame.combatText:UnregisterAllEvents()
		frame.combatText:SetScript("OnUpdate", nil)
		frame.combatText:SetScript("OnEvent", nil)
		frame.combatText:Hide()
	end
end

function Combat:FullUpdate(frame)
	local config = LunaUF.db.profile.units[frame.unitGroup].combatText
	frame.combatText.feedbackText:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\"..LunaUF.db.profile.font..".ttf", 11, "OUTLINE")
	frame.combatText:ClearAllPoints()
	frame.combatText:SetScale(config.size)
	frame.combatText:SetPoint("CENTER", frame, "CENTER", config.xoffset/config.size, config.yoffset/config.size)
	if not LunaUF.db.profile.locked then
		frame.combatText:SetScript("OnUpdate", nil)
		frame.combatText.feedbackText:Show()
		frame.combatText.feedbackText:SetAlpha(1)
		frame.combatText.feedbackText:SetText("1337")
	else
		frame.combatText:SetScript("OnUpdate", CombatFeedback_OnUpdate)
	end
end