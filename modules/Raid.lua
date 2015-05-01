local HealComm = AceLibrary("HealComm-1.0")
local AceEvent = AceLibrary("AceEvent-2.0")
local banzai = AceLibrary("Banzai-1.0")
local roster = AceLibrary("RosterLib-2.0")
local ScanTip = CreateFrame("GameTooltip", "ScanTip", nil, "GameTooltipTemplate")
ScanTip:SetOwner(WorldFrame, "ANCHOR_NONE")
LunaUnitFrames.frames.RaidFrames = {}
local RaidRoster = {
					[1] = {};
					[2] = {};
					[3] = {};
					[4] = {};
					[5] = {};
					[6] = {};
					[7] = {};
					[8] = {}
				}
local playername = UnitName("player")

local function Luna_Raid_OnClick()
	local button, modifier
	if arg1 == "LeftButton" then
		button = 1
	elseif arg1 == "RightButton" then
		button = 2
	elseif arg1 == "MiddleButton" then
		button = 3
	elseif arg1 == "Button4" then
		button = 4
	else
		button = 5
	end
	if IsShiftKeyDown() then
		modifier = 2
	elseif IsAltKeyDown() then
		modifier = 3
	elseif IsControlKeyDown() then
		modifier = 4
	else
		modifier = 1
	end
	local func = loadstring(LunaOptions.clickcast[playername][modifier][button])
	if LunaOptions.clickcast[playername][modifier][button] == "target" then
		if (SpellIsTargeting()) then
			SpellTargetUnit(this.unit)
		elseif (CursorHasItem()) then
			DropItemOnUnit(this.unit)
		else
			TargetUnit(this.unit)
		end
		return
	elseif LunaOptions.clickcast[playername][modifier][button] == "menu" then
		if (SpellIsTargeting()) then
			SpellStopTargeting()
			return;
		end
	elseif UnitIsUnit("target", this.unit) then
		if func then
			func()
		else
			CastSpellByName(LunaOptions.clickcast[playername][modifier][button])
		end
	else
		TargetUnit(this.unit)
		if func then
			func()
		else
			CastSpellByName(LunaOptions.clickcast[playername][modifier][button])
		end
		TargetLastTarget()
	end
end

local function StartMoving()
	this:StartMoving()
end

local function StopMovingOrSizing()
	this:StopMovingOrSizing()
	if not LunaOptions.frames["LunaRaidFrames"][this.id] then
		LunaOptions.frames["LunaRaidFrames"][this.id] = {}
	end
	_,_,_,LunaOptions.frames["LunaRaidFrames"]["positions"][this.id].x, LunaOptions.frames["LunaRaidFrames"]["positions"][this.id].y = this:GetPoint()
end

function LunaUnitFrames:ToggleRaidFrameLock()
	if not LunaUnitFrames.frames.RaidFrames[1]:IsMovable() and not LunaOptions.raidinterlock then
		for i=1,8 do
			LunaUnitFrames.frames.RaidFrames[i]:SetScript("OnDragStart", StartMoving)
			LunaUnitFrames.frames.RaidFrames[i]:SetMovable(1)
		end
	elseif LunaOptions.raidinterlock and not LunaUnitFrames.frames.RaidFrames[1]:IsMovable() then
		LunaUnitFrames.frames.RaidFrames[1]:SetScript("OnDragStart", StartMoving)
		LunaUnitFrames.frames.RaidFrames[1]:SetMovable(1)
	else
		for i=1,8 do
			LunaUnitFrames.frames.RaidFrames[i]:SetScript("OnDragStart", nil)
			LunaUnitFrames.frames.RaidFrames[i]:SetMovable(0)
		end
	end
end

local function AdjustBars(frame)
	local healed = HealComm:getHeal(UnitName(frame.unit))
	local health, maxHealth = UnitHealth(frame.unit), UnitHealthMax(frame.unit)
	local frameHeight, frameWidth = frame.HealthBar:GetHeight(), frame.HealthBar:GetWidth()
	local healthHeight = frameHeight * (health / maxHealth)
	local healthWidth = frameWidth * (health / maxHealth)
	vertHealth = LunaOptions.frames["LunaRaidFrames"].verticalHealth
	if( healed > 0 and health < maxHealth) then
		frame.HealBar:Show()
		if vertHealth then
			local incHeight = frameHeight * (healed / maxHealth)
			if (healthHeight + incHeight) > frameHeight then
				incHeight = frameHeight - healthHeight
			end
			frame.HealBar:SetHeight(incHeight)
			frame.HealBar:SetWidth(frameWidth)
			frame.HealBar:ClearAllPoints()
			frame.HealBar:SetPoint("BOTTOMLEFT", frame.HealthBar, "BOTTOMLEFT", 0, healthHeight)
		else
			local incWidth = frameWidth * (healed / maxHealth)
			if (healthWidth + incWidth) > frameWidth then
				incWidth = frameWidth - healthWidth
			end
			frame.HealBar:SetWidth(incWidth)
			frame.HealBar:SetHeight(frameHeight)
			frame.HealBar:ClearAllPoints()
			frame.HealBar:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT", healthWidth, 0)
		end
	else
		frame.HealBar:Hide()
	end
	if vertHealth and health < maxHealth then
		if LunaOptions.frames["LunaRaidFrames"].inverthealth then
			frame.bg:Show()
		end
		frame.bg:SetHeight(frameHeight-healthHeight)
		frame.bg:SetWidth(frameWidth)
	elseif health < maxHealth then
		if LunaOptions.frames["LunaRaidFrames"].inverthealth then
			frame.bg:Show()
		end
		frame.bg:SetHeight(frameHeight)
		frame.bg:SetWidth(frameWidth - healthWidth)
	else
		frame.bg:Hide()
	end
end

local function RaidEventhandler()
	if event == "UNIT_AURA" then
		LunaUnitFrames.Raid_Aura(arg1)
	elseif event == "UNIT_DISPLAYPOWER" then
		LunaUnitFrames.Raid_Displaypower(arg1)
	end
end

local function UpdateRaidMember()
	local now = GetTime()
	for i=1,8 do
		for z=1,5 do
			if LunaUnitFrames.frames.RaidFrames[i].member[z]:IsShown() then
					local _, time = LunaUnitFrames.proximity:GetUnitRange(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)
					local seen = now - (time or 100)
					if time and seen < 3 then
						LunaUnitFrames.frames.RaidFrames[i].member[z]:SetAlpha(1)
					else
						LunaUnitFrames.frames.RaidFrames[i].member[z]:SetAlpha(0.5)
					end
				if UnitIsConnected(LunaUnitFrames.frames.RaidFrames[i].member[z].unit) then
					local healamount = HealComm:getHeal(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
					local missinghp = (UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)-UnitHealthMax(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
					if UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].unit) < 2 then
						LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetValue(0)
						LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetValue(0)
						LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:Hide()
						LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText("DEAD")
					else
						AdjustBars(LunaUnitFrames.frames.RaidFrames[i].member[z])
						LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetValue(UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
						LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetValue(UnitMana(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
						if missinghp == 0 and healamount == 0 then
							LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText("")
						elseif healamount > 0 then
							LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText(missinghp.." |cFF00FF00+"..healamount)
						else
							LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText(missinghp)
						end
					end
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetValue(0)
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetValue(0)
					LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText("OFFLINE")
				end
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetMinMaxValues(0, UnitManaMax(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetMinMaxValues(0, UnitHealthMax(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
			end
		end
	end
end

function LunaUnitFrames:CreateRaidFrames()
	for i=1, 8 do
		LunaUnitFrames.frames.RaidFrames[i] = CreateFrame("Button", "RaidGroup"..i.."Header", UIParent)
		LunaUnitFrames.frames.RaidFrames[i]:Hide()
		LunaUnitFrames.frames.RaidFrames[i]:SetMovable(0)
		LunaUnitFrames.frames.RaidFrames[i]:RegisterForDrag("LeftButton")
		LunaUnitFrames.frames.RaidFrames[i]:SetScript("OnDragStop", StopMovingOrSizing)
		LunaUnitFrames.frames.RaidFrames[i].id = i
		
		LunaUnitFrames.frames.RaidFrames[i].member = {}
		
		LunaUnitFrames.frames.RaidFrames[i].GrpName = LunaUnitFrames.frames.RaidFrames[i]:CreateFontString(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i])
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[i])
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetJustifyH("CENTER")
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetJustifyV("MIDDLE")
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetShadowColor(0, 0, 0)
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetShadowOffset(0.8, -0.8)
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetTextColor(1,1,1)
		
		for z=1,5 do
			LunaUnitFrames.frames.RaidFrames[i].member[z] = CreateFrame("Button", "RaidMember"..(z+(5*(i-1))), UIParent)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:Hide()
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetBackdrop(LunaOptions.backdrop)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetBackdropColor(0,0,0,1)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetScript("OnClick", Luna_Raid_OnClick)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetScript("OnEnter", UnitFrame_OnEnter)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetScript("OnLeave", UnitFrame_OnLeave)
																
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.RaidFrames[i].member[z])
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetStatusBarTexture(LunaOptions.statusbartexture)													
																
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.RaidFrames[i].member[z])
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetStatusBarTexture(LunaOptions.statusbartexture)
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetStatusBarColor(0, 1, 0, 0.6)
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetMinMaxValues(0, 1)
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetValue(1)
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].bg = LunaUnitFrames.frames.RaidFrames[i].member[z]:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i].member[z])
			LunaUnitFrames.frames.RaidFrames[i].member[z].bg:SetTexture(LunaOptions.statusbartexture)
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.RaidFrames[i].member[z])
			LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetStatusBarTexture(LunaOptions.statusbartexture)
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name = LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:CreateFontString(nil, "ARTWORK", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetJustifyH("CENTER")
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetJustifyV("BOTTOM")
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetShadowColor(0, 0, 0)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetShadowOffset(0.8, -0.8)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetTextColor(1,1,1)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetPoint("BOTTOM", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "CENTER")
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext = LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:CreateFontString(nil, "ARTWORK", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetJustifyH("CENTER")
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetJustifyV("TOP")
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetShadowColor(0, 0, 0)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetShadowOffset(0.8, -0.8)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetTextColor(1,1,1)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetPoint("TOP", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "CENTER")
						
			LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon = LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:SetTexture(LunaOptions.resIcon)
			LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:SetPoint("TOPRIGHT", LunaUnitFrames.frames.RaidFrames[i].member[z], "TOPRIGHT")
			LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:Hide()
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].aggro = CreateFrame("Frame", nil, LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].aggro:SetBackdrop(LunaOptions.backdrop)
			LunaUnitFrames.frames.RaidFrames[i].member[z].aggro:SetBackdropColor(0,0,0,1)
			LunaUnitFrames.frames.RaidFrames[i].member[z].aggro:SetPoint("BOTTOMLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "BOTTOMLEFT")
			LunaUnitFrames.frames.RaidFrames[i].member[z].aggro.texture = LunaUnitFrames.frames.RaidFrames[i].member[z].aggro:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i].member[z].aggro)
			LunaUnitFrames.frames.RaidFrames[i].member[z].aggro.texture:SetTexture(LunaOptions.indicator)
			LunaUnitFrames.frames.RaidFrames[i].member[z].aggro.texture:SetAllPoints(LunaUnitFrames.frames.RaidFrames[i].member[z].aggro)
			LunaUnitFrames.frames.RaidFrames[i].member[z].aggro.texture:SetTexture(1, 0, 0)
			LunaUnitFrames.frames.RaidFrames[i].member[z].aggro:Hide()
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].buff = CreateFrame("Frame", nil, LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].buff:SetBackdrop(LunaOptions.backdrop)
			LunaUnitFrames.frames.RaidFrames[i].member[z].buff:SetBackdropColor(0,0,0,1)
			LunaUnitFrames.frames.RaidFrames[i].member[z].buff:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "TOPLEFT")
			LunaUnitFrames.frames.RaidFrames[i].member[z].buff.texture = LunaUnitFrames.frames.RaidFrames[i].member[z].buff:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i].member[z].buff)
			LunaUnitFrames.frames.RaidFrames[i].member[z].buff.texture:SetTexture(LunaOptions.indicator)
			LunaUnitFrames.frames.RaidFrames[i].member[z].buff.texture:SetTexture(0, 1, 0)
			LunaUnitFrames.frames.RaidFrames[i].member[z].buff.texture:SetAllPoints(LunaUnitFrames.frames.RaidFrames[i].member[z].buff)
			LunaUnitFrames.frames.RaidFrames[i].member[z].buff:Hide()
	
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff = CreateFrame("Frame", nil, LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetBackdrop(LunaOptions.backdrop)
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetBackdropColor(0,0,0,1)
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetPoint("TOPRIGHT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "TOPRIGHT")
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff.texture = LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i].member[z].debuff)
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff.texture:SetTexture(LunaOptions.indicator)
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff.texture:SetAllPoints(LunaUnitFrames.frames.RaidFrames[i].member[z].debuff)
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:Hide()
			
			LunaUnitFrames.frames.RaidFrames[i].member[z]:RegisterEvent("UNIT_AURA")
			LunaUnitFrames.frames.RaidFrames[i].member[z]:RegisterEvent("UNIT_DISPLAYPOWER")
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetScript("OnEvent", RaidEventhandler)
		end
	end																	
	LunaUnitFrames.frames.RaidFrames[9] = CreateFrame("Frame", "RaidUpdateFrame")
	LunaUnitFrames:UpdateRaidLayout()
	LunaUnitFrames.frames.RaidFrames[9]:SetScript("OnUpdate", UpdateRaidMember)
	AceEvent:RegisterEvent("Banzai_UnitGainedAggro", LunaUnitFrames.Raid_Aggro)
	AceEvent:RegisterEvent("Banzai_UnitLostAggro", LunaUnitFrames.Raid_Aggro)
	AceEvent:RegisterEvent("HealComm_Ressupdate", LunaUnitFrames.Raid_Res)
end

function LunaUnitFrames:UpdateRaidRoster()
	roster:ScanFullRoster()
	if ((GetNumRaidMembers() == 0 or not RAID_SUBGROUP_LISTS) and ((GetNumPartyMembers() == 0 or not LunaOptions.partyraidframe) and not LunaOptions.AlwaysRaid)) or LunaOptions.enableRaid == 0 then
		for i=1,8 do
			LunaUnitFrames.frames.RaidFrames[i]:Hide()
			for z=1,5 do
				LunaUnitFrames.frames.RaidFrames[i].member[z].unit = "player"
				LunaUnitFrames.frames.RaidFrames[i].member[z]:Hide()
			end
		end
		return
	end
	if GetNumRaidMembers() == 0 then
		RaidRoster[1][1] = UnitName("player")
		for i=1,4 do
			RaidRoster[1][i+1] = UnitName("party"..i)
		end
		for i=2,8 do
			for z=1,5 do
				RaidRoster[i][z] = nil
			end
		end
		table.sort(RaidRoster[1], function(a,b) return a<b end)		
	elseif RAID_SUBGROUP_LISTS then
		for i=1,8 do
			for z=1,5 do
				if RAID_SUBGROUP_LISTS[i][z] then
					RaidRoster[i][z] = UnitName("raid"..RAID_SUBGROUP_LISTS[i][z])
				else
					RaidRoster[i][z] = nil
				end
			end
			table.sort(RaidRoster[i], function(a,b) return a<b end)
		end
	else
		return
	end
	for i=1,8 do
		if (LunaOptions.frames["LunaRaidFrames"].ShowRaidGroupTitles or 1) == 1 and getn(RaidRoster[i]) > 0 then
			LunaUnitFrames.frames.RaidFrames[i]:Show()
		else
			LunaUnitFrames.frames.RaidFrames[i]:Hide()
		end
		for z=1,5 do
			if RaidRoster[i][z] then
				LunaUnitFrames.frames.RaidFrames[i].member[z].unit = roster:GetUnitIDFromName(RaidRoster[i][z]) or "player"
				local _,class = UnitClass(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)
				local color
				if LunaOptions.hbarcolor then
					color = LunaOptions.ClassColors[class]
				else
					color = LunaOptions.MiscColors["friendly"]
				end
				if not color then
					LunaUnitFrames.frames.RaidFrames[i].member[z]:Hide()
				else
					if LunaOptions.frames["LunaRaidFrames"].inverthealth then
						LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetStatusBarColor(0,0,0,0)
						LunaUnitFrames.frames.RaidFrames[i].member[z].bg:SetVertexColor(color[1],color[2],color[3])
						LunaUnitFrames.frames.RaidFrames[i].member[z].bg:Show()
					else
						LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetStatusBarColor(color[1],color[2],color[3],1)
						LunaUnitFrames.frames.RaidFrames[i].member[z].bg:Hide()
					end
				end
				local power = UnitPowerType(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)
				if power == 1 then
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
				elseif power == 3 then
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
				end
				LunaUnitFrames.Raid_Aura(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
				LunaUnitFrames.frames.RaidFrames[i].member[z]:Show()
				if HealComm:UnitisResurrecting(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)) then
					LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:Show()
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:Hide()
				end
				if banzai:GetUnitAggroByUnitId(LunaUnitFrames.frames.RaidFrames[i].member[z].unit) and LunaOptions.aggro then
					LunaUnitFrames.frames.RaidFrames[i].member[z].aggro:Show()
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z].aggro:Hide()
				end
			else
				LunaUnitFrames.frames.RaidFrames[i].member[z]:Hide()
			end
		end
	end
	LunaUnitFrames.Raid_Update()
end

function LunaUnitFrames:SetRaidFrameSize()
	local pBars = LunaOptions.frames["LunaRaidFrames"].pBars
	local height = LunaOptions.frames["LunaRaidFrames"].height or 30
	local width = LunaOptions.frames["LunaRaidFrames"].width or 60
	local scale = LunaOptions.frames["LunaRaidFrames"].scale or 1
	
	for i=1,8 do
		LunaUnitFrames.frames.RaidFrames[i]:SetHeight(height*0.5)
		LunaUnitFrames.frames.RaidFrames[i]:SetWidth(width)
		LunaUnitFrames.frames.RaidFrames[i]:SetScale(scale)
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetFont(LunaOptions.font, height*0.4)
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetText("GRP "..i)
		for z=1,5 do
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetHeight(height)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetWidth(width)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetScale(scale)
			if not pBars then
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetHeight(height)
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetWidth(width)
			elseif pBars == 1 then
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetHeight(math.floor(height*0.85))
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetWidth(width)
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetHeight(height-LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:GetHeight())
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetWidth(width)
			else
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetHeight(height)
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetWidth(math.floor(width*0.85))
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetHeight(height)
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetWidth(width-LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:GetWidth())
			end
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetWidth(LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:GetWidth())
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetHeight(LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:GetHeight()/2)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetFont(LunaOptions.font, 0.14*(width+height))
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetWidth(LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:GetWidth())
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetHeight(LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:GetHeight()/2)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetFont(LunaOptions.font, 0.14*(width+height))
			LunaUnitFrames.frames.RaidFrames[i].member[z].aggro:SetHeight(height*0.25)
			LunaUnitFrames.frames.RaidFrames[i].member[z].aggro:SetWidth(height*0.25)
			LunaUnitFrames.frames.RaidFrames[i].member[z].buff:SetHeight(height*0.25)
			LunaUnitFrames.frames.RaidFrames[i].member[z].buff:SetWidth(height*0.25)
			LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:SetHeight(height/1.5)
			LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:SetWidth(height/1.5)
			if LunaOptions.frames["LunaRaidFrames"].centerIcon then
				if height > width then
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetHeight(width*0.6)
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetWidth(width*0.6)
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetHeight(height*0.6)
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetWidth(height*0.6)
				end
			else
				LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetHeight(height*0.25)
				LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetWidth(height*0.25)
			end
		end
	end
end

function LunaUnitFrames:UpdateRaidLayout()
	local Padding = LunaOptions.frames["LunaRaidFrames"].padding or 4
	local pBars = LunaOptions.frames["LunaRaidFrames"].pBars
	local verticalHealth = LunaOptions.frames["LunaRaidFrames"].verticalHealth
	local sAnchor, tAnchor
	if LunaOptions.frames["LunaRaidFrames"].invertgrowth then
		sAnchor = "TOP"
		tAnchor = "BOTTOM"
		Padding = Padding*(-1)
	else
		sAnchor = "BOTTOM"
		tAnchor = "TOP"
	end
	for i=1, 8 do
		if LunaOptions.raidinterlock then
			if i == 1 then
				LunaUnitFrames.frames.RaidFrames[i]:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i]:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["LunaRaidFrames"]["positions"][i].x, LunaOptions.frames["LunaRaidFrames"]["positions"][i].y)
			else
				LunaUnitFrames.frames.RaidFrames[i]:SetScript("OnDragStart", nil)
				LunaUnitFrames.frames.RaidFrames[i]:SetMovable(0)
				LunaUnitFrames.frames.RaidFrames[i]:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i]:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i-1], "TOPRIGHT", LunaOptions.frames["LunaRaidFrames"].invertgrowth and (Padding *(-1)) or Padding, 0)
			end
		else
			LunaUnitFrames.frames.RaidFrames[i]:ClearAllPoints()
			LunaUnitFrames.frames.RaidFrames[i]:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["LunaRaidFrames"]["positions"][i].x, LunaOptions.frames["LunaRaidFrames"]["positions"][i].y)
		end
		for z=1,5 do
			if z == 1 then
				LunaUnitFrames.frames.RaidFrames[i].member[z]:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z]:SetPoint(sAnchor, LunaUnitFrames.frames.RaidFrames[i], tAnchor, 0, 2)
			else
				LunaUnitFrames.frames.RaidFrames[i].member[z]:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z]:SetPoint(sAnchor, LunaUnitFrames.frames.RaidFrames[i].member[z-1], tAnchor, 0, Padding)
			end
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:ClearAllPoints()
			LunaUnitFrames.frames.RaidFrames[i].member[z].bg:ClearAllPoints()
			if verticalHealth then
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetOrientation("VERTICAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetOrientation("VERTICAL")
			else
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetOrientation("HORIZONTAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetOrientation("HORIZONTAL")
			end
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z], "TOPLEFT")
			LunaUnitFrames.frames.RaidFrames[i].member[z].bg:SetPoint("TOPRIGHT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "TOPRIGHT")
			LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:ClearAllPoints()
			if pBars == 1 then
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetOrientation("HORIZONTAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:Show()
			elseif pBars == 2 then
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetOrientation("VERTICAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:Show()
			else
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:Hide()
			end
			LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetPoint("BOTTOMRIGHT", LunaUnitFrames.frames.RaidFrames[i].member[z], "BOTTOMRIGHT")
			if LunaOptions.frames["LunaRaidFrames"].centerIcon then
				LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "CENTER")
			else
				LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetPoint("TOPRIGHT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "TOPRIGHT")
			end
			LunaUnitFrames.Raid_Update()
		end
	end
	LunaUnitFrames:SetRaidFrameSize()
end

function LunaUnitFrames.Raid_Displaypower(unitid)
	if this.unit ~= unitid then
		return
	end
	local power = UnitPowerType(unitid)
	if power == 1 then
		this.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
	elseif power == 3 then
		this.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
	else
		this.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
	end
end

function LunaUnitFrames.Raid_Aura(unitid)
	if this.unit ~= unitid then
		return
	end
	local texture,_,dispeltype = UnitDebuff(this.unit,1,1)
	if not dispeltype and not LunaOptions.showdispelable then
		for i=1,16 do
			texture,_,dispeltype = UnitDebuff(this.unit,i)
			if dispeltype then
				break
			end
		end
	end
	if LunaOptions.frames["LunaRaidFrames"].centerIcon and texture then
		this.debuff.texture:SetTexture(texture)
		this.debuff:Show()
	elseif dispeltype then
		local r,g,b = unpack(LunaOptions.DebuffTypeColor[dispeltype])
		this.debuff.texture:SetTexture(r,g,b)
		this.debuff:Show()
	else
		this.debuff:Hide()
	end
	if LunaOptions.Raidbuff ~= "" then
		for i=1,16 do
			ScanTip:SetUnitBuff(this.unit, i)
			if ScanTipTextLeft1:GetText() and LunaOptions.Raidbuff and string.find(ScanTipTextLeft1:GetText(), LunaOptions.Raidbuff) then
				this.buff:Show()
				ScanTipTextLeft1:SetText("")
				return
			end
			ScanTipTextLeft1:SetText("")
		end
	end
	this.buff:Hide()
end

function LunaUnitFrames.Raid_Aggro(unitid)
	if not UnitIsPlayer(unitid) or not LunaOptions.aggro then
		return
	end
	if string.sub(unitid, 1, 4) == "raid" then
		local raidnumber = string.sub(unitid, 5)
		local _,_,subgroup = GetRaidRosterInfo(tonumber(raidnumber))
		for i=1, 5 do
			if tostring(RAID_SUBGROUP_LISTS[subgroup][i]) == raidnumber then
				local frame = LunaUnitFrames.frames.RaidFrames[subgroup].member[i]
				if banzai:GetUnitAggroByUnitId(frame.unit) then
					frame.aggro:Show()
				else
					frame.aggro:Hide()
				end
			end
		end
	elseif string.sub(unitid, 1, 5) == "party" then
		local partynumber = string.sub(unitid, 6)
		local frame = LunaUnitFrames.frames.RaidFrames[1].member[tonumber(partynumber)+1]
		if banzai:GetUnitAggroByUnitId(frame.unit) then
			frame.aggro:Show()
		else
			frame.aggro:Hide()
		end
	elseif unitid == "player" then
		local frame = LunaUnitFrames.frames.RaidFrames[1].member[1]
		if banzai:GetUnitAggroByUnitId(frame.unit) then
			frame.aggro:Show()
		else
			frame.aggro:Hide()
		end
	end
end

function LunaUnitFrames.Raid_Res(unitName)
	local unit = roster:GetUnitObjectFromName(unitName)
	if not unit then
		return
	end
	local frame
	for i=1, 5 do
		if LunaUnitFrames.frames.RaidFrames[unit.subgroup].member[i].unit == unit.unitid then
			frame = LunaUnitFrames.frames.RaidFrames[unit.subgroup].member[i]
		end
	end
	if not frame then
		return
	end
	if HealComm:UnitisResurrecting(unitName) then
		frame.RezIcon:Show()
	else
		frame.RezIcon:Hide()
	end
end

function LunaUnitFrames.Raid_Update()
	for i=1,8 do
		for z=1,5 do
			if LunaUnitFrames.frames.RaidFrames[i].member[z]:IsVisible() then
				local texture,_,dispeltype = UnitDebuff(LunaUnitFrames.frames.RaidFrames[i].member[z].unit,1,1)
				if not dispeltype and not LunaOptions.showdispelable then
					for h=1,16 do
						texture,_,dispeltype = UnitDebuff(LunaUnitFrames.frames.RaidFrames[i].member[z].unit,h)
						if dispeltype then
							break
						end
					end
				end
				if LunaOptions.frames["LunaRaidFrames"].centerIcon and texture then
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff.texture:SetTexture(texture)
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:Show()
				elseif dispeltype then
					local r,g,b = unpack(LunaOptions.DebuffTypeColor[dispeltype])
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff.texture:SetTexture(r,g,b)
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:Show()
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:Hide()
				end
				if LunaOptions.Raidbuff ~= "" then
					for h=1,16 do
						ScanTip:SetUnitBuff(LunaUnitFrames.frames.RaidFrames[i].member[z].unit, h)
						if ScanTipTextLeft1:GetText() and string.find(ScanTipTextLeft1:GetText(), LunaOptions.Raidbuff) then
							LunaUnitFrames.frames.RaidFrames[i].member[z].buff:Show()
						end
						ScanTipTextLeft1:SetText("")
					end
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z].buff:Hide()
				end
			end
		end
	end
end
