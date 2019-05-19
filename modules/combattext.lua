local Combat = {}
LunaUF:RegisterModule(Combat, "combatText", LunaUF.L["Combat text"])

local SML = LibStub:GetLibrary("LibSharedMedia-3.0")

function Combat:OnEnable(frame)
	if( not frame.combatText ) then
		frame.combatText = CreateFrame("Frame", nil, frame.highFrame)
		frame.combatText:SetFrameStrata("HIGH")
		frame.combatText.feedbackText = frame.combatText:CreateFontString(nil, "ARTWORK")
		frame.combatText.feedbackText:SetPoint("CENTER", frame.combatText, "CENTER", 0, 0)
		frame.combatText.feedbackText:SetShadowColor(0, 0, 0, 1.0)
		frame.combatText.feedbackText:SetShadowOffset(0.80, -0.80)
		frame.combatText:SetFrameLevel(frame.topFrameLevel)
		
		frame.combatText.feedbackStartTime = 0
		frame.combatText:SetScript("OnUpdate", CombatFeedback_OnUpdate)
		frame.combatText:SetHeight(1)
		frame.combatText:SetWidth(1)
	end
		
	frame:RegisterUnitEvent("UNIT_COMBAT", self, "Update")
end

function Combat:OnLayoutApplied(frame, config)
	-- Update feedback text
	LunaUF.Layout:ToggleVisibility(frame.combatText, frame.visibility.combatText)
	if( frame.visibility.combatText ) then
		frame.combatText.feedbackFontHeight = config.combatText.size
		frame.combatText.fontPath = LunaUF.Layout:LoadMedia(SML.MediaType.FONT, LunaUF.db.profile.units[frame.unitType].combatText.font)

		frame.combatText.feedbackText:SetFont(frame.combatText.fontPath, config.combatText.size, "OUTLINE")

		frame.combatText:ClearAllPoints()
		if config.portrait.enabled and config.portrait.alignment ~= "CENTER" then
			frame.combatText:SetPoint("CENTER", frame.portrait, "CENTER")
		else
			frame.combatText:SetPoint("CENTER", frame, "CENTER")
		end

	end
end

function Combat:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Combat:Update(frame, event, unit, type, ...)
	CombatFeedback_OnCombatEvent(frame.combatText, type, ...)
	if( type == "IMMUNE" ) then
		frame.combatText.feedbackText:SetTextHeight((frame.combatText.feedbackFontHeight + 1) * 0.75)
	end
	
	-- Increasing the font size will make the text look pixelated, however scaling it up will make it look smooth and awesome
	local scale = frame.combatText.feedbackText:GetStringHeight() / frame.combatText.feedbackFontHeight -- Font Size
	if( scale > 0 ) then
		frame.combatText:SetScale(scale)
		frame.combatText.feedbackText:SetFont(frame.combatText.fontPath, frame.combatText.feedbackFontHeight, "OUTLINE") -- Font Size
	end
end