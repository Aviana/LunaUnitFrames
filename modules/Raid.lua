local RangeTime = 0
LunaUnitFrames.frames.RaidFrames = {}

local function Luna_Raid_OnClick()
	local button = arg1
	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit(this.id)
		elseif (CursorHasItem()) then
			DropItemOnUnit(this.id)
		else
			TargetUnit(this.id)
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
					LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetValue(UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
					LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetMinMaxValues(0, UnitHealthMax(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
					if UnitIsConnected(LunaUnitFrames.frames.RaidFrames[i].member[z].id) then
						local missinghp = (UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].id)-UnitHealthMax(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
						if UnitIsDeadOrGhost(LunaUnitFrames.frames.RaidFrames[i].member[z].id) then
							LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText("DEAD")
						elseif missinghp == 0 then
							if LunaOptions.Raidlayout == "GRID" then
								LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(string.sub(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].id),1,3))
							else
								LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
							end
						else
							LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(missinghp)
						end
					end
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetValue(UnitMana(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetMinMaxValues(0, UnitManaMax(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
					local _, time = LunaUnitFrames.proximity:GetUnitRange(LunaUnitFrames.frames.RaidFrames[i].member[z].id)
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
					LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetValue(UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
					LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetMinMaxValues(0, UnitHealthMax(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
					if UnitIsConnected(LunaUnitFrames.frames.RaidFrames[i].member[z].id) then
						local missinghp = (UnitHealth(LunaUnitFrames.frames.RaidFrames[i].member[z].id)-UnitHealthMax(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
						if UnitIsDeadOrGhost(LunaUnitFrames.frames.RaidFrames[i].member[z].id) then
							LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText("DEAD")
						elseif missinghp == 0 then
							if LunaOptions.Raidlayout == "GRID" then
								LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(string.sub(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].id),1,3))
							else
								LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
							end
						else
							LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(missinghp)
						end
					end
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetValue(UnitMana(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
					LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetMinMaxValues(0, UnitManaMax(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
				end
			end
		end
	end
end

local function ToggleMemberStatus(event)
	if event == "PARTY_MEMBER_ENABLE" then
		this.Name:SetText(UnitName(LunaUnitFrames.frames.RaidFrames[i].member[z].id))
	else
		this.Name:SetText("offline")
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
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetScript("OnClick", Luna_Raid_OnClick)
			LunaUnitFrames.frames.RaidFrames[i].member[z]:RegisterEvent("UNIT_DISPLAYPOWER")
			LunaUnitFrames.frames.RaidFrames[i].member[z]:RegisterEvent("UNIT_AURA")
			LunaUnitFrames.frames.RaidFrames[i].member[z]:RegisterEvent("PARTY_MEMBER_ENABLE")
			LunaUnitFrames.frames.RaidFrames[i].member[z].onEvent = function ()
																	if this.id == arg1 then
																		if event == "UNIT_DISPLAYPOWER" then
																			local power = UnitPowerType(this.id)
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
																				local texture, stacks = UnitDebuff(this.id,i,1)
																				if texture then
																					this.Debuff:SetNormalTexture(texture) -- LunaUnitFrames.frames.RaidFrames[1].member[1].Debuff:SetNormalTexture("Interface\CharacterFrame\Disconnect-Icon")
																					break
																				end
																			end
																		end
																		ToggleMemberStatus(event)
																	end
																end
			LunaUnitFrames.frames.RaidFrames[i].member[z]:SetScript("OnEvent", LunaUnitFrames.frames.RaidFrames[i].member[z].onEvent)
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.RaidFrames[i].member[z])
			LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetStatusBarTexture(LunaOptions.statusbartexture)
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar = CreateFrame("StatusBar", nil, LunaUnitFrames.frames.RaidFrames[i].member[z])
			LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetStatusBarTexture(LunaOptions.statusbartexture)
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name = LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:CreateFontString(nil, "OVERLAY", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetJustifyH("CENTER")
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetShadowColor(0, 0, 0)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetShadowOffset(0.8, -0.8)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetTextColor(1,1,1)
			
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff = CreateFrame("Button", nil, LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
			LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:EnableMouse(0)
			
			LunaUnitFrames.frames.RaidFrames[i].member[z].connect = LunaUnitFrames.frames.RaidFrames[i].member[z]:CreateTexture(nil, "OVERLAY")
			LunaUnitFrames.frames.RaidFrames[i].member[z].connect:SetHeight(64)
			LunaUnitFrames.frames.RaidFrames[i].member[z].connect:SetWidth(64)
			LunaUnitFrames.frames.RaidFrames[i].member[z].connect:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "CENTER", 0, 0)
			LunaUnitFrames.frames.RaidFrames[i].member[z].connect:SetTexture("Interface\CharacterFrame\Disconnect-Icon")
		--	LunaUnitFrames.frames.RaidFrames[i].member[z].connect:SetTexCoord(0, 1, 0, 1)
			
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
		if LunaOptions.frames[LunaOptions.Raidlayout].ShowRaidGroupTitles == 1 then
			LunaUnitFrames.frames.RaidFrames[i]:Show()
		else
			LunaUnitFrames.frames.RaidFrames[i]:Hide()
		end
		for z=1,5 do
			local num = RAID_SUBGROUP_LISTS[i][z]
			if num then
				local name,_,_,_, class,_,_, online = GetRaidRosterInfo(num)
				if online then
					LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText(string.sub(name,1,3))
				else
					LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetText("offline")
				end
				LunaUnitFrames.frames.RaidFrames[i].member[z].id = "raid"..RAID_SUBGROUP_LISTS[i][z]
				local color = LunaOptions.ClassColors[class]
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetStatusBarColor(color[1],color[2],color[3])
				local power = UnitPowerType(LunaUnitFrames.frames.RaidFrames[i].member[z].id)
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
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetHeight(Size*0.125)
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetWidth(Size*3)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetFont(LunaOptions.font, Size*0.4)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:SetHeight(Size*0.5)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:SetWidth(Size*0.5)
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
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z], "TOPLEFT")
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetOrientation("VERTICAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetPoint("BOTTOMRIGHT", LunaUnitFrames.frames.RaidFrames[i].member[z], "BOTTOMRIGHT")
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetFont(LunaOptions.font, Size*0.4)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:SetPoint("CENTER", LunaUnitFrames.frames.RaidFrames[i].member[z], "CENTER")
			end
		end
		LunaUnitFrames.Raidlayout = "Bars"
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
				LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z], "TOPLEFT")
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetOrientation("HORIZONTAL")
				LunaUnitFrames.frames.RaidFrames[i].member[z].PowerBar:SetPoint("BOTTOMLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z], "BOTTOMLEFT")
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetPoint("LEFT", LunaUnitFrames.frames.RaidFrames[i].member[z].HealthBar, "LEFT", 2, 0)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Name:SetFont(LunaOptions.font, Size*0.4)
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:ClearAllPoints()
				LunaUnitFrames.frames.RaidFrames[i].member[z].Debuff:SetPoint("TOPLEFT", LunaUnitFrames.frames.RaidFrames[i].member[z], "TOPRIGHT", 2, 0)
			end
		end
		LunaUnitFrames.Raidlayout = "BARS"
	end
	LunaUnitFrames:SetRaidFrameSize()
end