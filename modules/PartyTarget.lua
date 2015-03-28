local Luna_PartyTarget_Events = {}
LunaPartyTargetFrames = {}

local pt = CreateFrame("Frame")
pt.time = 0

function Luna_PartyTarget_OnEvent()
	local func = Luna_PartyTarget_Events[event]
	if (func) then
		func()
	else
		DEFAULT_CHAT_FRAME:AddMessage("Luna Unit Frames - PartyTarget: Report the following event error to the author: "..event)
	end
end

function Luna_PartyTarget_OnUpdate()
	pt.time = pt.time + arg1;
	if (pt.time > 0.2) then
		pt.time = 0;
		LunaUnitFrames:UpdatePartyTargetFrames()
	end
end

function LunaUnitFrames:CreatePartyTargetFrames()
	for i=1, 4 do
		LunaPartyTargetFrames[i] = CreateFrame("Button", "LunaPartyTargetFrame"..i, LunaPartyFrames[i])
		LunaPartyTargetFrames[i]:RegisterEvent("PARTY_MEMBERS_CHANGED")
		LunaPartyTargetFrames[i]:SetScript("OnEvent", Luna_PartyTarget_OnEvent)
		LunaPartyTargetFrames[i]:SetHeight(LunaOptions.frames["LunaPartyTargetFrames"].size.y)
		LunaPartyTargetFrames[i]:SetWidth(LunaOptions.frames["LunaPartyTargetFrames"].size.x)
		LunaPartyTargetFrames[i]:SetScale(LunaOptions.frames["LunaPartyTargetFrames"].scale)
		LunaPartyTargetFrames[i]:SetBackdrop(LunaOptions.backdrop)
		LunaPartyTargetFrames[i]:SetBackdropColor(0,0,0,1)
		LunaPartyTargetFrames[i]:SetPoint("TOPLEFT", LunaPartyFrames[i], "TOPRIGHT", 5, 0)
		LunaPartyTargetFrames[i]:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
		LunaPartyTargetFrames[i].unit = "party"..i.."target"
		LunaPartyTargetFrames[i]:SetScript("OnEnter", UnitFrame_OnEnter)
		LunaPartyTargetFrames[i]:SetScript("OnLeave", UnitFrame_OnLeave)
		LunaPartyTargetFrames[i]:SetScript("OnClick", Luna_OnClick)
		LunaPartyTargetFrames[i].dropdown = CreateFrame("Frame", "LunaUnitDropDownMenuPartyTarget"..i, UIParent, "UIDropDownMenuTemplate")
		LunaPartyTargetFrames[i].initialize = function()
												if LunaPartyTargetFrames[i].dropdown then 
													UnitPopup_ShowMenu(LunaPartyTargetFrames[i].dropdown, "RAID_TARGET_ICON", LunaPartyTargetFrames[i].unit)
												end
											end
		UIDropDownMenu_Initialize(LunaPartyTargetFrames[i].dropdown, LunaPartyTargetFrames[i].initialize, "MENU")

		-- Healthbar
		LunaPartyTargetFrames[i].HealthBar = CreateFrame("StatusBar", nil, LunaPartyTargetFrames[i])
		LunaPartyTargetFrames[i].HealthBar:SetAllPoints(LunaPartyTargetFrames[i])
		LunaPartyTargetFrames[i].HealthBar:SetStatusBarTexture(LunaOptions.statusbartexture)
		LunaPartyTargetFrames[i].HealthBar:SetPoint("TOPLEFT", LunaPartyTargetFrames[i], "TOPLEFT", 0, 0)
		

		-- Healthbar background
		LunaPartyTargetFrames[i].HealthBar.hpbg = LunaPartyTargetFrames[i].HealthBar:CreateTexture(nil, "BORDER")
		LunaPartyTargetFrames[i].HealthBar.hpbg:SetAllPoints(LunaPartyTargetFrames[i].HealthBar)
		LunaPartyTargetFrames[i].HealthBar.hpbg:SetTexture(.25,.25,.25)
		LunaPartyTargetFrames[i].HealthBar.hpbg:SetVertexColor(LunaOptions.MiscColors["friendly"][1],LunaOptions.MiscColors["friendly"][2],LunaOptions.MiscColors["friendly"][3], 0.25)

		-- Healthbar text
		LunaPartyTargetFrames[i].HealthBar.hpp = LunaPartyTargetFrames[i].HealthBar:CreateFontString(nil, "OVERLAY", LunaPartyTargetFrames[i].HealthBar)
		LunaPartyTargetFrames[i].HealthBar.hpp:SetPoint("RIGHT", -2, 0)
		LunaPartyTargetFrames[i].HealthBar.hpp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyTargetFrames[i].HealthBar.hpp:SetShadowColor(0, 0, 0)
		LunaPartyTargetFrames[i].HealthBar.hpp:SetShadowOffset(0.8, -0.8)
		LunaPartyTargetFrames[i].HealthBar.hpp:SetTextColor(1,1,1)
		LunaPartyTargetFrames[i].HealthBar.hpp:SetWidth(LunaPartyTargetFrames[i]:GetWidth()/2)
		LunaPartyTargetFrames[i].HealthBar.hpp:SetHeight(LunaOptions.fontHeight)
		LunaPartyTargetFrames[i].HealthBar.hpp:SetJustifyH("RIGHT")
		
		LunaPartyTargetFrames[i].name = LunaPartyTargetFrames[i].HealthBar:CreateFontString(nil, "OVERLAY", LunaPartyTargetFrames[i].HealthBar)
		LunaPartyTargetFrames[i].name:SetPoint("LEFT", 2, 0)
		LunaPartyTargetFrames[i].name:SetJustifyH("LEFT")
		LunaPartyTargetFrames[i].name:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyTargetFrames[i].name:SetShadowColor(0, 0, 0)
		LunaPartyTargetFrames[i].name:SetShadowOffset(0.8, -0.8)
		LunaPartyTargetFrames[i].name:SetTextColor(1,1,1)
		LunaPartyTargetFrames[i].name:SetHeight(LunaOptions.fontHeight)
		LunaPartyTargetFrames[i].name:SetWidth(LunaPartyTargetFrames[i]:GetWidth()/2)
	end
	pt:SetScript("OnUpdate", Luna_PartyTarget_OnUpdate)
end

function LunaUnitFrames:UpdatePartyTargetFrames()
	local class
	local color
	for i=1,4 do
		if UnitIsVisible(LunaPartyTargetFrames[i].unit) and LunaOptions.frames["LunaPartyTargetFrames"].enabled == 1 then
			_,class = UnitClass(LunaPartyTargetFrames[i].unit)
			if UnitIsPlayer(LunaPartyTargetFrames[i].unit) then
				color = LunaOptions.ClassColors[class]
				LunaPartyTargetFrames[i].HealthBar:SetStatusBarColor(color[1],color[2],color[3])
				LunaPartyTargetFrames[i].HealthBar.hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
			elseif UnitIsTapped("target") and not UnitIsTappedByPlayer("target") then
				LunaPartyTargetFrames[i].HealthBar:SetStatusBarColor(0.5, 0.5, 0.5)
				LunaPartyTargetFrames[i].HealthBar.hpbg:SetVertexColor(0.5, 0.5, 0.5, 0.25)
			else
				reaction = UnitReaction(LunaPartyTargetFrames[i].unit, "player")
				if reaction and reaction < 4 then
					LunaPartyTargetFrames[i].HealthBar:SetStatusBarColor(0.9, 0, 0)
					LunaPartyTargetFrames[i].HealthBar.hpbg:SetVertexColor(0.9, 0, 0, 0.25)
				elseif reaction and reaction > 4 then
					LunaPartyTargetFrames[i].HealthBar:SetStatusBarColor(0, 0.8, 0)
					LunaPartyTargetFrames[i].HealthBar.hpbg:SetVertexColor(0, 0.8, 0, 0.25)
				else
					LunaPartyTargetFrames[i].HealthBar:SetStatusBarColor(0.93, 0.93, 0)
					LunaPartyTargetFrames[i].HealthBar.hpbg:SetVertexColor(0.93, 0.93, 0, 0.25)
				end
			end
			LunaPartyTargetFrames[i].HealthBar.hpp:SetText(LunaUnitFrames:GetHealthString(LunaPartyTargetFrames[i].unit))
			LunaPartyTargetFrames[i].HealthBar.hpp:SetWidth(LunaPartyTargetFrames[i]:GetWidth()/2)
			LunaPartyTargetFrames[i].HealthBar:SetMinMaxValues(0, UnitHealthMax(LunaPartyTargetFrames[i].unit))
			if UnitIsDead(LunaPartyTargetFrames[i].unit) then			-- This prevents negative health
				LunaPartyTargetFrames[i].HealthBar:SetValue(0)
			else
				LunaPartyTargetFrames[i].HealthBar:SetValue(UnitHealth(LunaPartyTargetFrames[i].unit))
			end
			LunaPartyTargetFrames[i].name:SetText(UnitName(LunaPartyTargetFrames[i].unit))
			LunaPartyTargetFrames[i].name:SetWidth(LunaPartyTargetFrames[i]:GetWidth()/2)
			LunaPartyTargetFrames[i]:Show()
		else
			LunaPartyTargetFrames[i]:Hide()
		end
	end
end

function Luna_PartyTarget_Events:PARTY_MEMBERS_CHANGED()
	LunaUnitFrames:UpdatePartyTargetFrames()
end