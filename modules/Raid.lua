local HealComm = AceLibrary("HealComm-1.0")
local AceEvent = AceLibrary("AceEvent-2.0")
local banzai = AceLibrary("Banzai-1.0")
local roster = AceLibrary("RosterLib-2.0")
local ScanTip = CreateFrame("GameTooltip", "ScanTip", nil, "GameTooltipTemplate")
local _, PlayerClass = UnitClass("player")
local HotTexture = (PlayerClass == "PRIEST" and "Interface\\Icons\\Spell_Holy_Renew" or PlayerClass == "DRUID" and "Interface\\Icons\\Spell_Nature_Rejuvenation" or "")
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
local PetRoster = {}
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
		for i=1,9 do
			LunaUnitFrames.frames.RaidFrames[i]:SetScript("OnDragStart", StartMoving)
			LunaUnitFrames.frames.RaidFrames[i]:SetMovable(1)
		end
	elseif LunaOptions.raidinterlock and not LunaUnitFrames.frames.RaidFrames[1]:IsMovable() then
		LunaUnitFrames.frames.RaidFrames[1]:SetScript("OnDragStart", StartMoving)
		LunaUnitFrames.frames.RaidFrames[1]:SetMovable(1)
	else
		for i=1,9 do
			LunaUnitFrames.frames.RaidFrames[i]:SetScript("OnDragStart", nil)
			LunaUnitFrames.frames.RaidFrames[i]:SetMovable(0)
		end
	end
end

local function RaidEventhandler()
	if event == "UNIT_AURA" then
		LunaUnitFrames.Raid_Aura(arg1)
	elseif event == "UNIT_DISPLAYPOWER" then
		LunaUnitFrames.Raid_Displaypower(arg1)
	end
end

local function AdjustHealBar(frame)
	if not frame.HealBar then
		return
	end
	local healed = HealComm:getHeal(UnitName(frame.unit))
	local health, maxHealth = UnitHealth(frame.unit), UnitHealthMax(frame.unit)
	local frameHeight, frameWidth = frame.HealthBar:GetHeight(), frame.HealthBar:GetWidth()
	local healthHeight = frameHeight * (health / maxHealth)
	local healthWidth = frameWidth * (health / maxHealth)
	if( healed > 0 and health < maxHealth) then
		frame.HealBar:Show()
		if LunaOptions.frames["LunaRaidFrames"].verticalHealth then
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
end

local function UpdateRaidMember()
	local now = GetTime()
	local loop = 5
	for i=1,9 do
		if i == 9 then
			loop = getn(PetRoster)
		end
		for z=1,loop do
			local frame = LunaUnitFrames.frames.RaidFrames[i].member[z]
			if frame:IsShown() then
				local _, time = LunaUnitFrames.proximity:GetUnitRange(frame.unit)
				local seen = now - (time or 100)
				if time and seen < 3 then
					frame:SetAlpha(1)
				else
					frame:SetAlpha(0.5)
				end
				local missinghp = (UnitHealth(frame.unit)-UnitHealthMax(frame.unit))
				local healamount = 0
				if i ~= 9 then
					healamount = HealComm:getHeal(UnitName(frame.unit))
				end
				local color
				if LunaOptions.hbarcolor then
					color = LunaOptions.ClassColors[frame.Class] or LunaOptions.MiscColors["friendly"]
				else
					color = LunaUnitFrames:GetHealthColor(frame.unit)
				end
				frame.HealthBar:SetMinMaxValues(0, UnitHealthMax(frame.unit))
				frame.PowerBar:SetMinMaxValues(0, UnitManaMax(frame.unit))
				if LunaOptions.frames["LunaRaidFrames"].inverthealth then
					if UnitIsConnected(frame.unit) then
						if UnitHealth(frame.unit) < 2 then
							frame.Healthtext:SetText("DEAD")
							frame.bg:SetVertexColor(unpack(color))
							frame.bg:Show()
							frame.HealthBar:SetValue(0)
							frame.PowerBar:SetValue(0)
						else
							frame.bg:Show()
							frame.bg:SetVertexColor(unpack(color))
							frame.HealthBar:SetStatusBarColor(0,0,0)
							frame.HealthBar:SetValue(UnitHealth(frame.unit))
							frame.PowerBar:SetValue(UnitMana(frame.unit))
							AdjustHealBar(frame)
							if healamount > 0 then
								frame.Healthtext:SetText("|cFF00FF00+"..healamount+missinghp)
							elseif missinghp == 0 then
								frame.Healthtext:SetText("")
							else
								frame.Healthtext:SetText("|cFFFFFFFF"..missinghp)
							end
						end
					else
						frame.Healthtext:SetText("OFFLINE")
						frame.bg:SetVertexColor(unpack(color))
						frame.bg:Show()
						frame.HealthBar:SetValue(0)
						frame.PowerBar:SetValue(0)
					end
				else
					frame.bg:Hide()
					if UnitIsConnected(frame.unit) then
						if UnitHealth(frame.unit) < 2 then
							frame.HealthBar:SetValue(0)
							frame.PowerBar:SetValue(0)
							frame.Healthtext:SetText("DEAD")
						else
							frame.HealthBar:SetValue(UnitHealth(frame.unit))
							frame.PowerBar:SetValue(UnitMana(frame.unit))
							frame.HealthBar:SetStatusBarColor(unpack(color))
							AdjustHealBar(frame)
							if healamount > 0 then
								if (healamount+missinghp) < 1 then
									frame.Healthtext:SetText("|cFF00FF00"..healamount+missinghp)
								else
									frame.Healthtext:SetText("|cFF00FF00+"..healamount+missinghp)
								end
							elseif missinghp == 0 then
								frame.Healthtext:SetText("")
							else
								frame.Healthtext:SetText("|cFFFFFFFF"..healamount+missinghp)
							end
						end
					else
						frame.HealthBar:SetValue(0)
						frame.PowerBar:SetValue(0)
						frame.Healthtext:SetText("OFFLINE")
					end
				end
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
			LunaUnitFrames.frames.RaidFrames[i].member[z].bg:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z], "TOPLEFT")
			
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
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot = CreateFrame("Frame", "HotFrame"..i..z, LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "CENTER")
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot.texture = LunaUnitFrames.frames.RaidFrames[i].member[z].Hot:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i].member[z].Hot)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot.texture:SetTexture(HotTexture)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot.texture:SetAllPoints(LunaUnitFrames.frames.RaidFrames[i].member[z].Hot)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot:Hide()
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot.cd = CreateFrame("Model", nil, LunaUnitFrames.frames.RaidFrames[i].member[z].Hot, "CooldownFrameTemplate")
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot.cd:ClearAllPoints()
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot.cd:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z].Hot, "TOPLEFT")
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot.cd:SetHeight(36)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot.cd:SetWidth(36)
	
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff = CreateFrame("Frame", nil, LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetBackdrop(LunaOptions.backdrop)
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetBackdropColor(0,0,0,1)
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetPoint("TOPRIGHT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "TOPRIGHT")
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff.texture = LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i].member[z].debuff)
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff.texture:SetTexture(LunaOptions.indicator)
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff.texture:SetAllPoints(LunaUnitFrames.frames.RaidFrames[i].member[z].debuff)
			LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:Hide()
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul = CreateFrame("Frame", nil, LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul:SetBackdrop(LunaOptions.backdrop)
			LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul:SetBackdropColor(0,0,0,1)
			LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul:SetPoint("BOTTOMRIGHT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "BOTTOMRIGHT")
			LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul.texture = LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul)
			LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul.texture:SetAllPoints(LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul)
			LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul.texture:SetTexture("Interface\\Icons\\Spell_Holy_AshesToAshes")
			LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul:Hide()
			
			LunaUnitFrames.frames.RaidFrames[i].member[z]:RegisterEvent("UNIT_AURA")
			LunaUnitFrames.frames.RaidFrames[i].member[z]:RegisterEvent("UNIT_DISPLAYPOWER")
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetScript("OnEvent", RaidEventhandler)
		end
	end
	
	LunaUnitFrames.frames.RaidFrames[9] = CreateFrame("Button", "RaidGroup9Header", UIParent)
	LunaUnitFrames.frames.RaidFrames[9]:Hide()
	LunaUnitFrames.frames.RaidFrames[9]:SetMovable(0)
	LunaUnitFrames.frames.RaidFrames[9]:RegisterForDrag("LeftButton")
	LunaUnitFrames.frames.RaidFrames[9]:SetScript("OnDragStop", StopMovingOrSizing)
	LunaUnitFrames.frames.RaidFrames[9].id = 9
	
	LunaUnitFrames.frames.RaidFrames[9].member = {}
	
	LunaUnitFrames.frames.RaidFrames[9].GrpName = LunaUnitFrames.frames.RaidFrames[9]:CreateFontString(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[9])
	LunaUnitFrames.frames.RaidFrames[9].GrpName:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[9])
	LunaUnitFrames.frames.RaidFrames[9].GrpName:SetJustifyH("CENTER")
	LunaUnitFrames.frames.RaidFrames[9].GrpName:SetJustifyV("MIDDLE")
	LunaUnitFrames.frames.RaidFrames[9].GrpName:SetShadowColor(0, 0, 0)
	LunaUnitFrames.frames.RaidFrames[9].GrpName:SetShadowOffset(0.8, -0.8)
	LunaUnitFrames.frames.RaidFrames[9].GrpName:SetTextColor(1,1,1)
	for i=1, 40 do
		LunaUnitFrames.frames.RaidFrames[9].member[i] = CreateFrame("Button", "RaidPet"..i, UIParent)
		LunaUnitFrames.frames.RaidFrames[9].member[i]:Hide()
		LunaUnitFrames.frames.RaidFrames[9].member[i]:SetBackdrop(LunaOptions.backdrop)
		LunaUnitFrames.frames.RaidFrames[9].member[i]:SetBackdropColor(0,0,0,1)
		LunaUnitFrames.frames.RaidFrames[9].member[i]:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
		LunaUnitFrames.frames.RaidFrames[9].member[i]:SetScript("OnClick", Luna_Raid_OnClick)
		LunaUnitFrames.frames.RaidFrames[9].member[i]:SetScript("OnEnter", UnitFrame_OnEnter)
		LunaUnitFrames.frames.RaidFrames[9].member[i]:SetScript("OnLeave", UnitFrame_OnLeave)
															
		LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.RaidFrames[9].member[i])
		LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:SetStatusBarTexture(LunaOptions.statusbartexture)													
		
		LunaUnitFrames.frames.RaidFrames[9].member[i].bg = LunaUnitFrames.frames.RaidFrames[9].member[i]:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[9].member[i])
		LunaUnitFrames.frames.RaidFrames[9].member[i].bg:SetTexture(LunaOptions.statusbartexture)
		LunaUnitFrames.frames.RaidFrames[9].member[i].bg:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[9].member[i], "TOPLEFT")
		
		LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.RaidFrames[9].member[i])
		LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar:SetStatusBarTexture(LunaOptions.statusbartexture)
		
		LunaUnitFrames.frames.RaidFrames[9].member[i].Name = LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:CreateFontString(nil, "ARTWORK", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Name:SetJustifyH("CENTER")
		LunaUnitFrames.frames.RaidFrames[9].member[i].Name:SetJustifyV("BOTTOM")
		LunaUnitFrames.frames.RaidFrames[9].member[i].Name:SetShadowColor(0, 0, 0)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Name:SetShadowOffset(0.8, -0.8)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Name:SetTextColor(1,1,1)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Name:SetPoint("BOTTOM", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar, "CENTER")
		
		LunaUnitFrames.frames.RaidFrames[9].member[i].Healthtext = LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:CreateFontString(nil, "ARTWORK", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Healthtext:SetJustifyH("CENTER")
		LunaUnitFrames.frames.RaidFrames[9].member[i].Healthtext:SetJustifyV("TOP")
		LunaUnitFrames.frames.RaidFrames[9].member[i].Healthtext:SetShadowColor(0, 0, 0)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Healthtext:SetShadowOffset(0.8, -0.8)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Healthtext:SetTextColor(1,1,1)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Healthtext:SetPoint("TOP", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar, "CENTER")
		
		LunaUnitFrames.frames.RaidFrames[9].member[i].aggro = CreateFrame("Frame", nil, LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar)
		LunaUnitFrames.frames.RaidFrames[9].member[i].aggro:SetBackdrop(LunaOptions.backdrop)
		LunaUnitFrames.frames.RaidFrames[9].member[i].aggro:SetBackdropColor(0,0,0,1)
		LunaUnitFrames.frames.RaidFrames[9].member[i].aggro:SetPoint("BOTTOMLEFT", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar, "BOTTOMLEFT")
		LunaUnitFrames.frames.RaidFrames[9].member[i].aggro.texture = LunaUnitFrames.frames.RaidFrames[9].member[i].aggro:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[9].member[i].aggro)
		LunaUnitFrames.frames.RaidFrames[9].member[i].aggro.texture:SetTexture(LunaOptions.indicator)
		LunaUnitFrames.frames.RaidFrames[9].member[i].aggro.texture:SetAllPoints(LunaUnitFrames.frames.RaidFrames[9].member[i].aggro)
		LunaUnitFrames.frames.RaidFrames[9].member[i].aggro.texture:SetTexture(1, 0, 0)
		LunaUnitFrames.frames.RaidFrames[9].member[i].aggro:Hide()
		
		LunaUnitFrames.frames.RaidFrames[9].member[i].buff = CreateFrame("Frame", nil, LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar)
		LunaUnitFrames.frames.RaidFrames[9].member[i].buff:SetBackdrop(LunaOptions.backdrop)
		LunaUnitFrames.frames.RaidFrames[9].member[i].buff:SetBackdropColor(0,0,0,1)
		LunaUnitFrames.frames.RaidFrames[9].member[i].buff:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar, "TOPLEFT")
		LunaUnitFrames.frames.RaidFrames[9].member[i].buff.texture = LunaUnitFrames.frames.RaidFrames[9].member[i].buff:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[9].member[i].buff)
		LunaUnitFrames.frames.RaidFrames[9].member[i].buff.texture:SetTexture(LunaOptions.indicator)
		LunaUnitFrames.frames.RaidFrames[9].member[i].buff.texture:SetTexture(0, 1, 0)
		LunaUnitFrames.frames.RaidFrames[9].member[i].buff.texture:SetAllPoints(LunaUnitFrames.frames.RaidFrames[9].member[i].buff)
		LunaUnitFrames.frames.RaidFrames[9].member[i].buff:Hide()
		
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot = CreateFrame("Frame", "HotFrame9"..i, LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar, "CENTER")
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot.texture = LunaUnitFrames.frames.RaidFrames[9].member[i].Hot:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[9].member[i].Hot)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot.texture:SetTexture(HotTexture)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot.texture:SetAllPoints(LunaUnitFrames.frames.RaidFrames[9].member[i].Hot)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot:Hide()
		
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot.cd = CreateFrame("Model", nil, LunaUnitFrames.frames.RaidFrames[9].member[i].Hot, "CooldownFrameTemplate")
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot.cd:ClearAllPoints()
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot.cd:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[9].member[i].Hot, "TOPLEFT")
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot.cd:SetHeight(36)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot.cd:SetWidth(36)

		LunaUnitFrames.frames.RaidFrames[9].member[i].debuff = CreateFrame("Frame", nil, LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar)
		LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:SetBackdrop(LunaOptions.backdrop)
		LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:SetBackdropColor(0,0,0,1)
		LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:SetPoint("TOPRIGHT", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar, "TOPRIGHT")
		LunaUnitFrames.frames.RaidFrames[9].member[i].debuff.texture = LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[9].member[i].debuff)
		LunaUnitFrames.frames.RaidFrames[9].member[i].debuff.texture:SetTexture(LunaOptions.indicator)
		LunaUnitFrames.frames.RaidFrames[9].member[i].debuff.texture:SetAllPoints(LunaUnitFrames.frames.RaidFrames[9].member[i].debuff)
		LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:Hide()

		LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul = CreateFrame("Frame", nil, LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar)
		LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul:SetBackdrop(LunaOptions.backdrop)
		LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul:SetBackdropColor(0,0,0,1)
		LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul:SetPoint("BOTTOMRIGHT", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar, "BOTTOMRIGHT")
		LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul.texture = LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul:CreateTexture(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul)
		LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul.texture:SetAllPoints(LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul)
		LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul.texture:SetTexture("Interface\\Icons\\Spell_Holy_AshesToAshes")
		LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul:Hide()
		
		LunaUnitFrames.frames.RaidFrames[9].member[i]:RegisterEvent("UNIT_AURA")
		LunaUnitFrames.frames.RaidFrames[9].member[i]:SetScript("OnEvent", RaidEventhandler)
	end
	
	LunaUnitFrames.frames.RaidFrames[10] = CreateFrame("Frame", "RaidUpdateFrame")
	LunaUnitFrames:UpdateRaidLayout()
	LunaUnitFrames.frames.RaidFrames[10]:SetScript("OnUpdate", UpdateRaidMember)
	AceEvent:RegisterEvent("UNIT_PET", LunaUnitFrames.QueuePetRosterUpdate)
	AceEvent:RegisterEvent("Banzai_UnitGainedAggro", LunaUnitFrames.Raid_Aggro)
	AceEvent:RegisterEvent("Banzai_UnitLostAggro", LunaUnitFrames.Raid_Aggro)
	AceEvent:RegisterEvent("HealComm_Ressupdate", LunaUnitFrames.Raid_Res)
	AceEvent:RegisterEvent("HealComm_Hotupdate", LunaUnitFrames.Raid_Hot)
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
			local frame = LunaUnitFrames.frames.RaidFrames[i].member[z]
			if RaidRoster[i][z] then
				frame.unit = roster:GetUnitIDFromName(RaidRoster[i][z]) or "player"
				_,frame.Class = UnitClass(frame.unit)
				local power = UnitPowerType(frame.unit)
				if power == 1 then
					frame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
				elseif power == 3 then
					frame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
				else
					frame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
				end
				LunaUnitFrames.Raid_Aura(frame.unit)
				frame.Name:SetText(UnitName(frame.unit))
				if LunaOptions.colornames then
					frame.Name:SetTextColor(unpack(LunaOptions.ClassColors[frame.Class]))
				else
					frame.Name:SetTextColor(1,1,1)
				end
				frame:Show()
				if HealComm:UnitisResurrecting(UnitName(frame.unit)) then
					frame.RezIcon:Show()
				else
					frame.RezIcon:Hide()
				end
				if banzai:GetUnitAggroByUnitId(frame.unit) and LunaOptions.aggro then
					frame.aggro:Show()
				else
					frame.aggro:Hide()
				end
			else
				frame:Hide()
			end
		end
	end
	LunaUnitFrames.UpdatePetRoster()
	LunaUnitFrames.Raid_Update()
end

function LunaUnitFrames:UpdatePetRoster()
	PetRoster = {}
	local index = 1
	if not GetNumRaidMembers() or GetNumRaidMembers() < 2 then
		if UnitIsVisible("pet") then
			PetRoster[index] = {}
			PetRoster[index].unitid = "pet"
			PetRoster[index].name = UnitName("pet")
			index = index + 1
		end
		for i=1, 4 do
			if UnitIsVisible("partypet"..i) then
				PetRoster[index] = {}
				PetRoster[index].unitid = "partypet"..i
				PetRoster[index].name = UnitName("partypet"..i)
				index = index + 1
			end
		end
	else
		for i=1, 40 do
			if UnitIsVisible("raidpet"..i) then
				PetRoster[index] = {}
				PetRoster[index].unitid = "raidpet"..i
				PetRoster[index].name = UnitName("raidpet"..i)
				index = index + 1
			end
		end
	end
	table.sort(PetRoster, function(a,b) return a.name<b.name end)
	if (LunaOptions.frames["LunaRaidFrames"].ShowRaidGroupTitles or 1) == 1 and getn(PetRoster) > 0 and LunaOptions.frames["LunaRaidFrames"].petgroup then
		LunaUnitFrames.frames.RaidFrames[9]:Show()
	else
		LunaUnitFrames.frames.RaidFrames[9]:Hide()
	end
	for i=1, 40 do
		local frame = LunaUnitFrames.frames.RaidFrames[9].member[i]
		if PetRoster[i] and LunaOptions.frames["LunaRaidFrames"].petgroup then
			frame.unit = PetRoster[i].unitid
			frame.Name:SetText(PetRoster[i].name)
			local power = UnitPowerType(frame.unit)
			if power == 1 then
				frame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
			elseif power == 2 then
				frame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Focus"][1], LunaOptions.PowerColors["Focus"][2], LunaOptions.PowerColors["Focus"][3])
			elseif power == 3 then
				frame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
			else
				frame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
			end
			frame:Show()
		else
			frame.unit = "player"
			frame:Hide()
		end
	end
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
				LunaUnitFrames.frames.RaidFrames[i].member[z].bg:SetHeight(height)
				LunaUnitFrames.frames.RaidFrames[i].member[z].bg:SetWidth(width)
			elseif pBars == 1 then
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetHeight(math.floor(height*0.85))
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetWidth(width)
				LunaUnitFrames.frames.RaidFrames[i].member[z].bg:SetHeight(math.floor(height*0.85))
				LunaUnitFrames.frames.RaidFrames[i].member[z].bg:SetWidth(width)
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetHeight(height-LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:GetHeight())
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetWidth(width)
			else
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetHeight(height)
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetWidth(math.floor(width*0.85))
				LunaUnitFrames.frames.RaidFrames[i].member[z].bg:SetHeight(height)
				LunaUnitFrames.frames.RaidFrames[i].member[z].bg:SetWidth(math.floor(width*0.85))
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
			LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul:SetHeight(height*0.25)
			LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul:SetWidth(height*0.25)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot:SetWidth(height*0.6)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot:SetHeight(height*0.6)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Hot.cd:SetScale(height*0.6/36)
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
	LunaUnitFrames.frames.RaidFrames[9]:SetHeight(height*0.5)
	LunaUnitFrames.frames.RaidFrames[9]:SetWidth(width)
	LunaUnitFrames.frames.RaidFrames[9]:SetScale(scale)
	LunaUnitFrames.frames.RaidFrames[9].GrpName:SetFont(LunaOptions.font, height*0.4)
	LunaUnitFrames.frames.RaidFrames[9].GrpName:SetText("PETS")
	for i=1, 40 do
		LunaUnitFrames.frames.RaidFrames[9].member[i]:SetHeight(height)
		LunaUnitFrames.frames.RaidFrames[9].member[i]:SetWidth(width)
		LunaUnitFrames.frames.RaidFrames[9].member[i]:SetScale(scale)
		if not pBars then
			LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:SetHeight(height)
			LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:SetWidth(width)
			LunaUnitFrames.frames.RaidFrames[9].member[i].bg:SetHeight(height)
			LunaUnitFrames.frames.RaidFrames[9].member[i].bg:SetWidth(width)
		elseif pBars == 1 then
			LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:SetHeight(math.floor(height*0.85))
			LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:SetWidth(width)
			LunaUnitFrames.frames.RaidFrames[9].member[i].bg:SetHeight(math.floor(height*0.85))
			LunaUnitFrames.frames.RaidFrames[9].member[i].bg:SetWidth(width)
			LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar:SetHeight(height-LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:GetHeight())
			LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar:SetWidth(width)
		else
			LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:SetHeight(height)
			LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:SetWidth(math.floor(width*0.85))
			LunaUnitFrames.frames.RaidFrames[9].member[i].bg:SetHeight(height)
			LunaUnitFrames.frames.RaidFrames[9].member[i].bg:SetWidth(math.floor(width*0.85))
			LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar:SetHeight(height)
			LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar:SetWidth(width-LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:GetWidth())
		end
		LunaUnitFrames.frames.RaidFrames[9].member[i].Name:SetWidth(LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:GetWidth())
		LunaUnitFrames.frames.RaidFrames[9].member[i].Name:SetHeight(LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:GetHeight()/2)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Name:SetFont(LunaOptions.font, 0.14*(width+height))
		LunaUnitFrames.frames.RaidFrames[9].member[i].Healthtext:SetWidth(LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:GetWidth())
		LunaUnitFrames.frames.RaidFrames[9].member[i].Healthtext:SetHeight(LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:GetHeight()/2)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Healthtext:SetFont(LunaOptions.font, 0.14*(width+height))
		LunaUnitFrames.frames.RaidFrames[9].member[i].aggro:SetHeight(height*0.25)
		LunaUnitFrames.frames.RaidFrames[9].member[i].aggro:SetWidth(height*0.25)
		LunaUnitFrames.frames.RaidFrames[9].member[i].buff:SetHeight(height*0.25)
		LunaUnitFrames.frames.RaidFrames[9].member[i].buff:SetWidth(height*0.25)
		LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul:SetHeight(height*0.25)
		LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul:SetWidth(height*0.25)		
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot:SetWidth(height*0.6)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot:SetHeight(height*0.6)
		LunaUnitFrames.frames.RaidFrames[9].member[i].Hot.cd:SetScale(height*0.6/36)
		if LunaOptions.frames["LunaRaidFrames"].centerIcon then
			if height > width then
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:SetHeight(width*0.6)
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:SetWidth(width*0.6)
			else
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:SetHeight(height*0.6)
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:SetWidth(height*0.6)
			end
		else
			LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:SetHeight(height*0.25)
			LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:SetWidth(height*0.25)
		end
	end
end

function LunaUnitFrames:QueuePetRosterUpdate()
	if AceEvent:IsEventScheduled("LunaUpdatePetRoster") then
		AceEvent:CancelScheduledEvent("LunaUpdatePetRoster")
		LunaUnitFrames.UpdatePetRoster()
	end
	AceEvent:ScheduleEvent("LunaUpdatePetRoster", LunaUnitFrames.UpdatePetRoster, 0.5)
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
--			LunaUnitFrames.frames.RaidFrames[i].member[z].bg:ClearAllPoints()
			if verticalHealth then
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetOrientation("VERTICAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetOrientation("VERTICAL")
			else
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetOrientation("HORIZONTAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetOrientation("HORIZONTAL")
			end
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z], "TOPLEFT")
--			LunaUnitFrames.frames.RaidFrames[i].member[z].bg:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z], "TOPLEFT")
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
				if PlayerClass == "PRIEST" or PlayerClass == "DRUID" then
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:ClearAllPoints()
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetPoint("LEFT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "CENTER", 1, 0)
					LunaUnitFrames.frames.RaidFrames[i].member[z].Hot:ClearAllPoints()
					LunaUnitFrames.frames.RaidFrames[i].member[z].Hot:SetPoint("RIGHT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "CENTER", -1, 0)
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:ClearAllPoints()
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "CENTER")
				end
			else
				LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:SetPoint("TOPRIGHT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "TOPRIGHT")
				LunaUnitFrames.frames.RaidFrames[i].member[z].Hot:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].Hot:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "CENTER")
			end
		end
	end
	if LunaOptions.raidinterlock then
		LunaUnitFrames.frames.RaidFrames[9]:SetScript("OnDragStart", nil)
		LunaUnitFrames.frames.RaidFrames[9]:SetMovable(0)
		LunaUnitFrames.frames.RaidFrames[9]:ClearAllPoints()
		LunaUnitFrames.frames.RaidFrames[9]:SetPoint("TOPRIGHT", LunaUnitFrames.frames.RaidFrames[1], "TOPLEFT", LunaOptions.frames["LunaRaidFrames"].invertgrowth and Padding or (Padding *(-1)), 0)
	else
		LunaUnitFrames.frames.RaidFrames[9]:ClearAllPoints()
		LunaUnitFrames.frames.RaidFrames[9]:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["LunaRaidFrames"]["positions"][9].x, LunaOptions.frames["LunaRaidFrames"]["positions"][9].y)
	end
	for i=1, 40 do
		if i == 1 then
			LunaUnitFrames.frames.RaidFrames[9].member[i]:ClearAllPoints()
			LunaUnitFrames.frames.RaidFrames[9].member[i]:SetPoint(sAnchor, LunaUnitFrames.frames.RaidFrames[9], tAnchor, 0, 2)
		else
			LunaUnitFrames.frames.RaidFrames[9].member[i]:ClearAllPoints()
			LunaUnitFrames.frames.RaidFrames[9].member[i]:SetPoint(sAnchor, LunaUnitFrames.frames.RaidFrames[9].member[i-1], tAnchor, 0, Padding)
		end
		LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:ClearAllPoints()
--		LunaUnitFrames.frames.RaidFrames[9].member[i].bg:ClearAllPoints()
		if verticalHealth then
			LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:SetOrientation("VERTICAL")
		else
			LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:SetOrientation("HORIZONTAL")
		end
		LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[9].member[i], "TOPLEFT")
--		LunaUnitFrames.frames.RaidFrames[9].member[i].bg:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[9].member[i], "TOPLEFT")
		LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar:ClearAllPoints()
		if pBars == 1 then
			LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar:SetOrientation("HORIZONTAL")
			LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar:Show()
		elseif pBars == 2 then
			LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar:SetOrientation("VERTICAL")
			LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar:Show()
		else
			LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar:Hide()
		end
		LunaUnitFrames.frames.RaidFrames[9].member[i].PowerBar:SetPoint("BOTTOMRIGHT", LunaUnitFrames.frames.RaidFrames[9].member[i], "BOTTOMRIGHT")
		if LunaOptions.frames["LunaRaidFrames"].centerIcon then
			if PlayerClass == "PRIEST" or PlayerClass == "DRUID" then
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:SetPoint("LEFT", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar, "CENTER", 1, 0)
				LunaUnitFrames.frames.RaidFrames[9].member[i].Hot:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[9].member[i].Hot:SetPoint("RIGHT", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar, "CENTER", -1, 0)
			else
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar, "CENTER")
			end
		else
			LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:ClearAllPoints()
			LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:SetPoint("TOPRIGHT", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar, "TOPRIGHT")
			LunaUnitFrames.frames.RaidFrames[9].member[i].Hot:ClearAllPoints()
			LunaUnitFrames.frames.RaidFrames[9].member[i].Hot:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[9].member[i].HealthBar, "CENTER")
		end
	end
	LunaUnitFrames.Raid_Update()
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
	if not dispeltype and LunaOptions.frames["LunaRaidFrames"].centerIcon and not LunaOptions.showdispelable then
		texture = UnitDebuff(this.unit,1)
	end
	if LunaOptions.frames["LunaRaidFrames"].centerIcon and texture then
		this.debuff.texture:SetTexture(texture)
		this.debuff:Show()
	elseif texture then
		local r,g,b = unpack(LunaOptions.DebuffTypeColor[dispeltype])
		this.debuff.texture:SetTexture(r,g,b)
		this.debuff:Show()
	else
		this.debuff:Hide()
	end
	this.Hot:Hide()
	if LunaOptions.frames["LunaRaidFrames"].hottracker then
		for i=1,24 do
			texture = UnitBuff(this.unit,i)
			if texture == HotTexture then
				this.Hot:Show()
			end
		end
	end
	this.wsoul:Hide()
	for i=1,16 do
		if UnitDebuff(this.unit,i) == "Interface\\Icons\\Spell_Holy_AshesToAshes" and PlayerClass == "PRIEST" and LunaOptions.frames["LunaRaidFrames"].wsoul then
			this.wsoul:Show()
		end
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
	if not LunaOptions.aggro then
		return
	end
	if string.find(unitid, "pet") then
		for i=1, 40 do
			local frame = LunaUnitFrames.frames.RaidFrames[9].member[i]
			if frame.unit == unitid then
				if banzai:GetUnitAggroByUnitId(frame.unit) then
					frame.aggro:Show()
				else
					frame.aggro:Hide()
				end
			end
		end
	elseif string.sub(unitid, 1, 4) == "raid" then
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

function LunaUnitFrames.Raid_Hot(unit)
	if not LunaOptions.frames["LunaRaidFrames"].hottracker then
		return
	end
	local unitObj = roster:GetUnitObjectFromUnit(unit)
	if not unitObj then
		return
	end
	local frame
	if not UnitIsPlayer(unit) then
		for i=1, 40 do
			if LunaUnitFrames.frames.RaidFrames[9].member[i].unit == unit then
				frame = LunaUnitFrames.frames.RaidFrames[9].member[i]
				break
			end
		end
	else
		for i=1, 5 do
			if LunaUnitFrames.frames.RaidFrames[unitObj.subgroup].member[i].unit == unitObj.unitid then
				frame = LunaUnitFrames.frames.RaidFrames[unitObj.subgroup].member[i]
			end
		end
	end
	local start, dur
	if PlayerClass == "PRIEST" then
		start, dur = HealComm:getRenewTime(unit)
	elseif PlayerClass == "DRUID" then
		start, dur = HealComm:getRejuTime(unit)
	else
		return
	end
	CooldownFrame_SetTimer(frame.Hot.cd,tonumber(start),tonumber(dur),1)
end

function LunaUnitFrames.Raid_Update()
	for i=1,8 do
		for z=1,5 do
			if LunaUnitFrames.frames.RaidFrames[i].member[z]:IsVisible() then
				local texture,_,dispeltype = UnitDebuff(LunaUnitFrames.frames.RaidFrames[i].member[z].unit,1,1)
				if not dispeltype and LunaOptions.frames["LunaRaidFrames"].centerIcon and not LunaOptions.showdispelable then
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
				elseif texture then
					local r,g,b = unpack(LunaOptions.DebuffTypeColor[dispeltype])
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff.texture:SetTexture(r,g,b)
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:Show()
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z].debuff:Hide()
				end
				LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul:Hide()
				for h=1,16 do
					if UnitDebuff(LunaUnitFrames.frames.RaidFrames[i].member[z].unit,h) == "Interface\\Icons\\Spell_Holy_AshesToAshes" and PlayerClass == "PRIEST" and LunaOptions.frames["LunaRaidFrames"].wsoul then
						LunaUnitFrames.frames.RaidFrames[i].member[z].wsoul:Show()
					end
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
	for i=1, getn(PetRoster) do
		if LunaUnitFrames.frames.RaidFrames[9].member[i]:IsVisible() then
			local texture,_,dispeltype = UnitDebuff(LunaUnitFrames.frames.RaidFrames[9].member[i].unit,1,1)
			if not dispeltype and LunaOptions.frames["LunaRaidFrames"].centerIcon and not LunaOptions.showdispelable then
				for h=1,16 do
					texture,_,dispeltype = UnitDebuff(LunaUnitFrames.frames.RaidFrames[9].member[i].unit,h)
					if dispeltype then
						break
					end
				end
			end
			if LunaOptions.frames["LunaRaidFrames"].centerIcon and texture then
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff.texture:SetTexture(texture)
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:Show()
			elseif texture then
				local r,g,b = unpack(LunaOptions.DebuffTypeColor[dispeltype])
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff.texture:SetTexture(r,g,b)
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:Show()
			else
				LunaUnitFrames.frames.RaidFrames[9].member[i].debuff:Hide()
			end
			LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul:Hide()
			for i=1,16 do
				if UnitDebuff(LunaUnitFrames.frames.RaidFrames[9].member[i].unit,i) == "Interface\\Icons\\Spell_Holy_AshesToAshes" and PlayerClass == "PRIEST" and LunaOptions.frames["LunaRaidFrames"].wsoul then
					LunaUnitFrames.frames.RaidFrames[9].member[i].wsoul:Show()
				end
			end
			if LunaOptions.Raidbuff ~= "" then
				for h=1,16 do
					ScanTip:SetUnitBuff(LunaUnitFrames.frames.RaidFrames[9].member[i].unit, h)
					if ScanTipTextLeft1:GetText() and string.find(ScanTipTextLeft1:GetText(), LunaOptions.Raidbuff) then
						LunaUnitFrames.frames.RaidFrames[9].member[i].buff:Show()
					end
					ScanTipTextLeft1:SetText("")
				end
			else
				LunaUnitFrames.frames.RaidFrames[9].member[i].buff:Hide()
			end
		end
	end
end
