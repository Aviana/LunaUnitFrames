local banzai = AceLibrary("Banzai-1.0")
local RangeTime = 0
LunaUnitFrames.frames.RaidFrames = {}

local function Luna_Raid_OnClick()
	local button = arg1
	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit(this.unit)
		elseif (CursorHasItem()) then
			DropItemOnUnit(this.unit)
		else
			TargetUnit(this.unit)
		end
		return
	end

	if (button == "RightButton") then
		if (SpellIsTargeting()) then
			SpellStopTargeting()
			return;
		end
	end
end

local function StartMoving()
	this:StartMoving()
end

local function StopMovingOrSizing()
	this:StopMovingOrSizing()
	if LunaOptions.Raidlayout == "GRID" then
		_,_,_,LunaOptions.frames["GRID"].position.x, LunaOptions.frames["GRID"].position.y = this:GetPoint()
	else
		_,_,_,LunaOptions.frames["LunaRaidFramesBars"..this.id].position.x, LunaOptions.frames["LunaRaidFramesBars"..this.id].position.y = this:GetPoint()
	end
end

local function getHeal(unit)
	local healamount = 0
	if LunaUnitFrames.HealComm.Heals[unit] then
		for k,v in LunaUnitFrames.HealComm.Heals[unit] do
			healamount = healamount+v.amount
		end
		return healamount
	else
		return 0
	end
end

local function UnitisResurrecting(unit)
	local resstime
	if LunaUnitFrames.HealComm.pendingResurrections[unit] then
		for k,v in pairs(LunaUnitFrames.HealComm.pendingResurrections[unit]) do
			if v < GetTime() then
				LunaUnitFrames.HealComm.pendingResurrections[unit][k] = nil
			elseif not resstime or resstime > v then
				resstime = v
			end
		end
	end
	return resstime
end

function LunaUnitFrames:ToggleRaidFrameLock()
	if LunaUnitFrames.frames.RaidFrames[1]:IsMovable() then
		for i=1,8 do
			LunaUnitFrames.frames.RaidFrames[i]:SetScript("OnDragStart", nil)
			LunaUnitFrames.frames.RaidFrames[i]:SetMovable(0)
		end
	else
		for i=1,8 do
			LunaUnitFrames.frames.RaidFrames[i]:SetScript("OnDragStart", StartMoving)
			LunaUnitFrames.frames.RaidFrames[i]:SetMovable(1)
			if LunaOptions.Raidlayout == "GRID" then
				return
			end
		end
	end
end

local function UpdateRaidMember()
	RangeTime = RangeTime + arg1
	if (RangeTime > LunaOptions.Rangefreq) then
		RangeTime = 0
		local now = GetTime()
		for i=1,8 do
			for z=1,5 do
				if LunaUnitFrames.frames.RaidFrames[i].member[z]:IsShown() then
					if banzai:GetUnitAggroByUnitId(LunaUnitFrames.frames.RaidFrames[i].member[z].unit) then
						LunaUnitFrames.frames.RaidFrames[i].member[z]:SetBackdropColor(1,0,0,1)
					else
						LunaUnitFrames.frames.RaidFrames[i].member[z]:SetBackdropColor(0,0,0,1)
					end
					if UnitIsConnected(LunaUnitFrames.frames.RaidFrames[i].member[z].unit) then
						local healamount = getHeal(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
						local missinghp = (UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)-UnitHealthMax(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
						if UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].unit) < 2 then
							LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetValue(0)
							LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetValue(0)
							LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetValue(0)
							if UnitisResurrecting(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)) then
								LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:Show()
							else
								LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:Hide()
							end
							if LunaOptions.Raidlayout == "GRID" then
								LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Hide()
								LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText("DEAD")
							else
								LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
								LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText("DEAD")
							end
						else
							LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetValue(UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
							LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetValue(UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)+healamount)
							LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetValue(UnitMana(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
							LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:Hide()
							if LunaOptions.Raidlayout == "GRID" then
								LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Hide()
								if missinghp == 0 then
									LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(string.sub(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit),1,3))
								else
									LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(missinghp)
								end
							else
								LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
								if missinghp == 0 and healamount == 0 then
									LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Hide()
								elseif healamount > 0 then
									LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Show()
									LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText(missinghp.." |cFF00FF00+"..healamount)
								else
									LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Show()
									LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText(missinghp)
								end
							end
						end
					else
						LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetValue(0)
						LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetValue(0)
						LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetValue(0)
						if LunaOptions.Raidlayout == "GRID" then
							LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText("OFF")
						else
							LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText("OFFLINE")
							LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Show()
							LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
						end
					end
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetMinMaxValues(0, UnitManaMax(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
					LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetMinMaxValues(0, UnitHealthMax(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
					LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetMinMaxValues(0, UnitHealthMax(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
					local _, time = LunaUnitFrames.proximity:GetUnitRange(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)
					local seen = now - (time or 100)
					if time and seen < 3 then
						LunaUnitFrames.frames.RaidFrames[i].member[z]:SetAlpha(1)
					else
						LunaUnitFrames.frames.RaidFrames[i].member[z]:SetAlpha(0.5)
					end
				end
			end
		end
	else
		for i=1,8 do
			for z=1,5 do
				if LunaUnitFrames.frames.RaidFrames[i].member[z]:IsShown() then
					if banzai:GetUnitAggroByUnitId(LunaUnitFrames.frames.RaidFrames[i].member[z].unit) then
						LunaUnitFrames.frames.RaidFrames[i].member[z]:SetBackdropColor(1,0,0,1)
					else
						LunaUnitFrames.frames.RaidFrames[i].member[z]:SetBackdropColor(0,0,0,1)
					end
					if UnitIsConnected(LunaUnitFrames.frames.RaidFrames[i].member[z].unit) then
						local healamount = getHeal(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
						local missinghp = (UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)-UnitHealthMax(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
						if UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].unit) < 2 then
							LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetValue(0)
							LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetValue(0)
							LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetValue(0)
							if LunaOptions.Raidlayout == "GRID" then
								LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Hide()
								LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText("DEAD")
							else
								LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
								LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText("DEAD")
							end
						else
							LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetValue(UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
							LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetValue(UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)+healamount)
							LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetValue(UnitMana(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
							LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:Hide()
							if LunaOptions.Raidlayout == "GRID" then
								LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Hide()
								if missinghp == 0 then
									LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(string.sub(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit),1,3))
								else
									LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(missinghp)
								end
							else
								LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
								if missinghp == 0 and healamount == 0 then
									LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Hide()
								elseif healamount > 0 then
									LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Show()
									LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText(missinghp.." |cFF00FF00+"..healamount)
								else
									LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Show()
									LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText(missinghp)
								end
							end
						end
					else
						LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetValue(0)
						LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetValue(0)
						LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetValue(0)
						if LunaOptions.Raidlayout == "GRID" then
							LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText("OFF")
						else
							LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetText("OFFLINE")
							LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Show()
							LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
						end
					end
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetMinMaxValues(0, UnitManaMax(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
					LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetMinMaxValues(0, UnitHealthMax(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
					LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetMinMaxValues(0, UnitHealthMax(LunaUnitFrames.frames.RaidFrames[i].member[z].unit))
				end
			end
		end
	end
end

function LunaUnitFrames:CreateRaidFrames()
	for i=1, 8 do
		LunaUnitFrames.frames.RaidFrames[i] = CreateFrame("Button", "RaidGroup"..i.."Header", UIParent)
		LunaUnitFrames.frames.RaidFrames[i]:SetMovable(0)
		LunaUnitFrames.frames.RaidFrames[i]:RegisterForDrag("LeftButton")
		LunaUnitFrames.frames.RaidFrames[i]:SetScript("OnDragStop", StopMovingOrSizing)
		LunaUnitFrames.frames.RaidFrames[i].id = i
		
		LunaUnitFrames.frames.RaidFrames[i].member = {}
		
		LunaUnitFrames.frames.RaidFrames[i].GrpName = LunaUnitFrames.frames.RaidFrames[i]:CreateFontString(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i])
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[i])
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetJustifyH("CENTER")
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetShadowColor(0, 0, 0)
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetShadowOffset(0.8, -0.8)
		LunaUnitFrames.frames.RaidFrames[i].GrpName:SetTextColor(1,1,1)
		
		for z=1,5 do
			LunaUnitFrames.frames.RaidFrames[i].member[z] = CreateFrame("Button", "RaidMember"..(z+(5*(i-1))), UIParent)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetBackdrop(LunaOptions.backdrop)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetBackdropColor(0,0,0,1)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetScript("OnClick", Luna_Raid_OnClick)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetScript("OnEnter", UnitFrame_OnEnter)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetScript("OnLeave", UnitFrame_OnLeave)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:RegisterEvent("UNIT_DISPLAYPOWER")
			LunaUnitFrames.frames.RaidFrames[i].member[z]:RegisterEvent("UNIT_AURA")
			LunaUnitFrames.frames.RaidFrames[i].member[z].onEvent = function ()
																	if this.unit == arg1 then
																		if event == "UNIT_DISPLAYPOWER" then
																			local power = UnitPowerType(this.unit)
																			if power == 1 then
																				this.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
																			elseif power == 3 then
																				this.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
																			else
																				this.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
																			end
																		else
																			this.Debuff:SetNormalTexture(nil)
																			for i=1,16 do
																				local texture, stacks = UnitDebuff(this.unit,i,1)
																				if texture then
																					this.Debuff:SetNormalTexture(texture)
																					break
																				end
																			end
																		end
																	end
																end
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetScript("OnEvent", LunaUnitFrames.frames.RaidFrames[i].member[z].onEvent)													
																
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.RaidFrames[i].member[z])
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetStatusBarTexture(LunaOptions.statusbartexture)
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetStatusBarColor(0, 1, 0, 0.6)
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetValue(0)
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetStatusBarTexture(LunaOptions.statusbartexture)
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetPoint("BOTTOMLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "BOTTOMLEFT")
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.RaidFrames[i].member[z])
			LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetStatusBarTexture(LunaOptions.statusbartexture)
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name = LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:CreateFontString(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetJustifyH("CENTER")
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetShadowColor(0, 0, 0)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetShadowOffset(0.8, -0.8)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetTextColor(1,1,1)
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext = LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:CreateFontString(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetJustifyH("CENTER")
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetShadowColor(0, 0, 0)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetShadowOffset(0.8, -0.8)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetTextColor(1,1,1)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetPoint("BOTTOM", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "BOTTOM")
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff = CreateFrame("Button", nil, LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:EnableMouse(0)
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon = CreateFrame("Button", nil, LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:EnableMouse(0)
			LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:SetNormalTexture("Interface\\Icons\\Spell_Holy_Resurrection")
			LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:SetAllPoints(LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff)
			LunaUnitFrames.frames.RaidFrames[i].member[z].RezIcon:Hide()
						
		end
	end
	LunaUnitFrames.frames.RaidFrames[9] = CreateFrame("Frame", "RaidUpdateFrame")
	LunaUnitFrames:UpdateRaidLayout()
	LunaUnitFrames:UpdateRaidRoster()
	LunaUnitFrames.frames.RaidFrames[9]:SetScript("OnUpdate", UpdateRaidMember)
end

function LunaUnitFrames:UpdateRaidRoster()
	if not RAID_SUBGROUP_LISTS or GetNumRaidMembers() == 0 or LunaOptions.enableRaid == 0 then
		for i=1,8 do
			LunaUnitFrames.frames.RaidFrames[i]:Hide()
			for z=1,5 do
				LunaUnitFrames.frames.RaidFrames[i].member[z]:Hide()
			end
		end
		return
	end
	for i=1,8 do
		if LunaOptions.frames[LunaOptions.Raidlayout].ShowRaidGroupTitles == 1 and getn(RAID_SUBGROUP_LISTS[i]) > 0 then
			LunaUnitFrames.frames.RaidFrames[i]:Show()
		else
			LunaUnitFrames.frames.RaidFrames[i]:Hide()
		end
		for z=1,5 do
			local num = RAID_SUBGROUP_LISTS[i][z]
			if num then
				LunaUnitFrames.frames.RaidFrames[i].member[z].unit = "raid"..num
				local class = UnitClass(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)
				local color = LunaOptions.ClassColors[class]
				if not color then
					LunaUnitFrames.frames.RaidFrames[i].member[z]:Hide()
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetStatusBarColor(color[1],color[2],color[3])
				end
				local power = UnitPowerType(LunaUnitFrames.frames.RaidFrames[i].member[z].unit)
				if power == 1 then
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
				elseif power == 3 then
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
				end
				LunaUnitFrames.frames.RaidFrames[i].member[z]:Show()
			else
				LunaUnitFrames.frames.RaidFrames[i].member[z]:Hide()
			end
		end
	end
end

function LunaUnitFrames:SetRaidFrameSize()
	local raidlayout = LunaOptions.Raidlayout
	local Size = LunaOptions.frames[raidlayout].size
	if raidlayout == "GRID" then
		for i=1,8 do
			LunaUnitFrames.frames.RaidFrames[i]:SetHeight(Size*0.375)
			LunaUnitFrames.frames.RaidFrames[i]:SetWidth(Size)
			LunaUnitFrames.frames.RaidFrames[i].GrpName:SetFont(LunaOptions.font, Size*0.4)
			LunaUnitFrames.frames.RaidFrames[i].GrpName:SetText("GRP "..i)
			for z=1,5 do
				LunaUnitFrames.frames.RaidFrames[i].member[z]:SetHeight(Size)
				LunaUnitFrames.frames.RaidFrames[i].member[z]:SetWidth(Size)
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetHeight(Size)
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetWidth(Size*0.875)
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetHeight(Size)
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetWidth(Size*0.875)
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetHeight(Size)
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetWidth(Size*0.125)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetFont(LunaOptions.font, Size*0.4)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:SetHeight(Size*0.6)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:SetWidth(Size*0.6)
			end
		end
	else
		for i=1,8 do
			LunaUnitFrames.frames.RaidFrames[i]:SetHeight(Size*0.375)
			LunaUnitFrames.frames.RaidFrames[i]:SetWidth(Size*3)
			LunaUnitFrames.frames.RaidFrames[i].GrpName:SetFont(LunaOptions.font, Size*0.4)
			LunaUnitFrames.frames.RaidFrames[i].GrpName:SetText("GRP "..i)
			for z=1,5 do
				LunaUnitFrames.frames.RaidFrames[i].member[z]:SetHeight(Size)
				LunaUnitFrames.frames.RaidFrames[i].member[z]:SetWidth(Size*3)
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetHeight(Size*0.875)
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetWidth(Size*3)
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetHeight(Size*0.875)
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetWidth(Size*3)
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetHeight(Size*0.125)
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetWidth(Size*3)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetFont(LunaOptions.font, Size*0.4)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:SetFont(LunaOptions.font, Size*0.4)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:SetHeight(Size*0.4)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:SetWidth(Size*0.4)
			end
		end
	end
end

function LunaUnitFrames:UpdateRaidLayout()
	local raidlayout = LunaOptions.Raidlayout
	local Size = LunaOptions.frames[raidlayout].size
	local Padding = LunaOptions.frames[raidlayout].padding
	if raidlayout == "GRID" then
		for i=1, 8 do
			if i == 1 then
				LunaUnitFrames.frames.RaidFrames[i]:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i]:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["GRID"].position.x, LunaOptions.frames["GRID"].position.y)
			else
				LunaUnitFrames.frames.RaidFrames[i]:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i]:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i-1], "TOPRIGHT", Padding, 0)
			end
			for z=1,5 do
				if z == 1 then
					LunaUnitFrames.frames.RaidFrames[i].member[z]:ClearAllPoints()
					LunaUnitFrames.frames.RaidFrames[i].member[z]:SetPoint("BOTTOM", LunaUnitFrames.frames.RaidFrames[i], "TOP", 0, 2)
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z]:ClearAllPoints()
					LunaUnitFrames.frames.RaidFrames[i].member[z]:SetPoint("BOTTOM", LunaUnitFrames.frames.RaidFrames[i].member[z-1], "TOP", 0, Padding)
				end
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetOrientation("VERTICAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetOrientation("VERTICAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z], "TOPLEFT")
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetOrientation("VERTICAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetPoint("BOTTOMRIGHT", LunaUnitFrames.frames.RaidFrames[i].member[z], "BOTTOMRIGHT")
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetFont(LunaOptions.font, Size*0.4)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Hide()
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[i].member[z], "CENTER")
			end
		end
	else
		for i=1, 8 do
			LunaUnitFrames.frames.RaidFrames[i]:ClearAllPoints()
			LunaUnitFrames.frames.RaidFrames[i]:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["LunaRaidFramesBars"..i].position.x, LunaOptions.frames["LunaRaidFramesBars"..i].position.y)
			for z=1,5 do
				if z == 1 then
					LunaUnitFrames.frames.RaidFrames[i].member[z]:ClearAllPoints()
					LunaUnitFrames.frames.RaidFrames[i].member[z]:SetPoint("BOTTOM", LunaUnitFrames.frames.RaidFrames[i], "TOP", 0, 2)
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z]:ClearAllPoints()
					LunaUnitFrames.frames.RaidFrames[i].member[z]:SetPoint("BOTTOM", LunaUnitFrames.frames.RaidFrames[i].member[z-1], "TOP", 0, Padding)
				end
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetOrientation("HORIZONTAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealBar:SetOrientation("HORIZONTAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z], "TOPLEFT")
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetOrientation("HORIZONTAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetPoint("BOTTOMLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z], "BOTTOMLEFT")
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "TOPLEFT", 1, 0)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetFont(LunaOptions.font, Size*0.4)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Healthtext:Show()
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:SetPoint("TOPRIGHT", LunaUnitFrames.frames.RaidFrames[i].member[z], "TOPRIGHT", 0, 0)
			end
		end
	end
	LunaUnitFrames:SetRaidFrameSize()
end