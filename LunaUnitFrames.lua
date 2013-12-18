LunaUnitFrames = CreateFrame("Frame")
LunaUnitFrames.frames = {}
LunaUnitFrames.proximity = ProximityLib:GetInstance("1")
LunaUnitFrames:RegisterEvent("ADDON_LOADED")
LunaUnitFrames:RegisterEvent("RAID_ROSTER_UPDATE")
LunaUnitFrames:RegisterEvent("PLAYER_ENTERING_WORLD")
function LunaUnitFrames:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "LunaUnitFrames" then
		--Load the Addon here
		ChatFrame1:AddMessage("Luna Unit Frames loaded. Enjoy the ride!")
		LunaUnitFrames:CreatePlayerFrame()
		LunaUnitFrames:CreatePetFrame()
		LunaUnitFrames:CreateTargetFrame()
		LunaUnitFrames:CreateTargetTargetFrame()
		LunaUnitFrames:CreateTargetTargetTargetFrame()
		LunaUnitFrames:CreatePartyFrames()
		LunaUnitFrames:CreatePartyPetFrames()
		LunaUnitFrames:CreateRaidFrames()
		LunaUnitFrames:CreateXPBar()
		LunaOptionsModule:CreateMenu()
	elseif event == "PLAYER_LOGIN" then	
		
	elseif event == "RAID_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
		LunaUnitFrames:UpdateRaidRoster()
	end
end
LunaUnitFrames:SetScript("OnEvent", LunaUnitFrames.OnEvent)

SLASH_LUF1, SLASH_LUF2, SLASH_LUF3 = "/luf", "/luna", "/lunaunitframes"
function SlashCmdList.LUF(msg, editbox)
	LunaOptionsFrame:Show()
end