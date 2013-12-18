local Luna_Party_Events = {}
LunaPartyFrames = {}

GrpRangeCheck = CreateFrame("Frame")
GrpRangeCheck.time = 0
GrpRangeCheck.onUpdate = function ()
	if LunaOptions.PartyRange == 1 then
		GrpRangeCheck.time = GrpRangeCheck.time + arg1
		if (GrpRangeCheck.time > 0.2) then
			GrpRangeCheck.time = 0
			local now = GetTime()
			for i=1, 4 do
				local _, time = LunaUnitFrames.proximity:GetUnitRange(LunaPartyFrames[i].unit)
				local seen = now - (time or 100)
				if time and seen < 3 then
					LunaPartyFrames[i]:SetAlpha(1)
				else
					LunaPartyFrames[i]:SetAlpha(0.5)
				end
			end
		end
	end
end

function Luna_Party_Tip()
	UnitFrame_OnEnter()
end

local function Luna_Party_OnEvent()
	local func = Luna_Party_Events[event]
	if (func) then
		func()
	else
		DEFAULT_CHAT_FRAME:AddMessage("Luna Unit Frames - Party: Report the following event error to the author: "..event)
	end
end

function Luna_Party_OnClick()
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

	if (not (IsAltKeyDown() or IsControlKeyDown() or IsShiftKeyDown())) then
		ToggleDropDownMenu(1, nil, this.dropdown, "cursor", 0, 0)
	end

end

function Luna_Party_SetBuffTooltip()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	if (this.id > 16) then
		GameTooltip:SetUnitDebuff(this:GetParent().unit, this.id-16)
	else
		GameTooltip:SetUnitBuff(this:GetParent().unit, this.id)
	end
end

function Luna_Party_SetBuffTooltipLeave()
	GameTooltip:Hide()
end

local function StartMoving()
	LunaPartyFrames[1]:StartMoving()
end

local function StopMovingOrSizing()
	LunaPartyFrames[1]:StopMovingOrSizing()
	_,_,_,LunaOptions.frames["LunaPartyFrames"].position.x, LunaOptions.frames["LunaPartyFrames"].position.y = LunaPartyFrames[1]:GetPoint()
end

function LunaUnitFrames:TogglePartyLock()
	if LunaPartyFrames[1]:IsMovable() then
		for i=1, 4 do
			LunaPartyFrames[i]:SetScript("OnDragStart", nil)
			LunaPartyFrames[i]:SetMovable(0)
		end
	else
		for i=1, 4 do
			LunaPartyFrames[i]:SetScript("OnDragStart", StartMoving)
			LunaPartyFrames[i]:SetMovable(1)
		end
	end
end

function LunaUnitFrames:UpdatePartyPosition()
	for i=1,4 do
		if i == 1 then
			LunaPartyFrames[i]:ClearAllPoints()
			LunaPartyFrames[i]:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["LunaPartyFrames"].position.x, LunaOptions.frames["LunaPartyFrames"].position.y)
		elseif LunaOptions.VerticalParty == 1 then
			LunaPartyFrames[i]:ClearAllPoints()
			LunaPartyFrames[i]:SetPoint("TOPLEFT", LunaPartyFrames[i-1], "BOTTOMLEFT", 0, -(LunaOptions.PartySpace))
		else
			LunaPartyFrames[i]:ClearAllPoints()
			LunaPartyFrames[i]:SetPoint("TOPLEFT", LunaPartyFrames[i-1], "TOPRIGHT", LunaOptions.PartySpace, 0)
		end
	end
end

function LunaUnitFrames:CreatePartyFrames()
	for i=1, 4 do
		LunaPartyFrames[i] = CreateFrame("Button", "LunaPartyFrame"..i, UIParent)
		LunaPartyFrames[i]:SetClampedToScreen(1)
		LunaPartyFrames[i]:SetMovable(0)
		LunaPartyFrames[i]:RegisterForDrag("LeftButton")
		LunaPartyFrames[i]:SetScript("OnDragStop", StopMovingOrSizing)
		LunaPartyFrames[i]:SetHeight(LunaOptions.frames["LunaPartyFrames"].size.y)
		LunaPartyFrames[i]:SetWidth(LunaOptions.frames["LunaPartyFrames"].size.x)
		LunaPartyFrames[i]:SetScale(LunaOptions.frames["LunaPartyFrames"].scale)
		LunaPartyFrames[i]:SetBackdrop(LunaOptions.backdrop)
		LunaPartyFrames[i]:SetBackdropColor(0,0,0,1)
		LunaPartyFrames[i]:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
		LunaPartyFrames[i].unit = "party"..i
		LunaPartyFrames[i]:RegisterEvent("UNIT_PORTRAIT_UPDATE")
		LunaPartyFrames[i]:RegisterEvent("UNIT_MODEL_CHANGED")
		LunaPartyFrames[i]:RegisterEvent("UNIT_HEALTH")
		LunaPartyFrames[i]:RegisterEvent("UNIT_MAXHEALTH")
		LunaPartyFrames[i]:RegisterEvent("UNIT_MAXMANA")
		LunaPartyFrames[i]:RegisterEvent("UNIT_MANA")
		LunaPartyFrames[i]:RegisterEvent("UNIT_RAGE")
		LunaPartyFrames[i]:RegisterEvent("UNIT_MAXRAGE")
		LunaPartyFrames[i]:RegisterEvent("UNIT_ENERGY")
		LunaPartyFrames[i]:RegisterEvent("UNIT_MAXENERGY")
		LunaPartyFrames[i]:RegisterEvent("UNIT_DISPLAYPOWER")
		LunaPartyFrames[i]:RegisterEvent("PARTY_LEADER_CHANGED")
		LunaPartyFrames[i]:RegisterEvent("RAID_TARGET_UPDATE")
		LunaPartyFrames[i]:RegisterEvent("PARTY_MEMBERS_CHANGED")
		LunaPartyFrames[i]:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
		LunaPartyFrames[i]:RegisterEvent("UNIT_AURA")
		LunaPartyFrames[i]:RegisterEvent("RAID_ROSTER_UPDATE")
		LunaPartyFrames[i]:RegisterEvent("UNIT_PET")
		LunaPartyFrames[i]:SetScript("OnEvent", Luna_Party_OnEvent)
		LunaPartyFrames[i]:SetScript("OnClick", Luna_Party_OnClick)
		LunaPartyFrames[i]:SetScript("OnEnter", Luna_Party_Tip)
		LunaPartyFrames[i]:SetScript("OnLeave", UnitFrame_OnLeave)
		LunaPartyFrames[i].dropdown = CreateFrame("Frame", "LunaUnitDropDownMenuParty"..i, LunaPartyFrames[i], "UIDropDownMenuTemplate")
		LunaPartyFrames[i].DropDown_Initialize = function ()
													if this.dropdown then 
														UnitPopup_ShowMenu(this.dropdown, "PARTY", this.unit)
													elseif UIDROPDOWNMENU_OPEN_MENU then 
														UnitPopup_ShowMenu(getglobal(UIDROPDOWNMENU_OPEN_MENU), "PARTY", getglobal(UIDROPDOWNMENU_OPEN_MENU):GetParent().unit)
													end
												end
		UIDropDownMenu_Initialize(LunaPartyFrames[i].dropdown, LunaPartyFrames[i].DropDown_Initialize, "MENU")

		LunaPartyFrames[i].Buffs = {}

		LunaPartyFrames[i].Buffs[1] = CreateFrame("Button", nil, LunaPartyFrames[i])
		LunaPartyFrames[i].Buffs[1].texturepath = UnitBuff(LunaPartyFrames[i].unit,1)
		LunaPartyFrames[i].Buffs[1].id = 1
		LunaPartyFrames[i].Buffs[1]:SetNormalTexture(LunaPartyFrames[i].Buffs[1].texturepath)
		LunaPartyFrames[i].Buffs[1]:SetPoint("TOPLEFT", LunaPartyFrames[i], "BOTTOMLEFT",-1.5, -3)
		LunaPartyFrames[i].Buffs[1]:SetScript("OnEnter", Luna_Party_SetBuffTooltip)
		LunaPartyFrames[i].Buffs[1]:SetScript("OnLeave", Luna_Party_SetBuffTooltipLeave)

		LunaPartyFrames[i].Buffs[1].stacks = LunaPartyFrames[i].Buffs[1]:CreateFontString(nil, "OVERLAY", LunaPartyFrames[i].Buffs[1])
		LunaPartyFrames[i].Buffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaPartyFrames[i].Buffs[1], 0, 0)
		LunaPartyFrames[i].Buffs[1].stacks:SetJustifyH("LEFT")
		LunaPartyFrames[i].Buffs[1].stacks:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].Buffs[1].stacks:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].Buffs[1].stacks:SetTextColor(1,1,1)

		for z=2, 16 do
			LunaPartyFrames[i].Buffs[z] = CreateFrame("Button", nil, LunaPartyFrames[i])
			LunaPartyFrames[i].Buffs[z].texturepath = UnitBuff(LunaPartyFrames[i].unit,z)
			LunaPartyFrames[i].Buffs[z].id = z
			LunaPartyFrames[i].Buffs[z]:SetNormalTexture(LunaPartyFrames[i].Buffs[z].texturepath)
			LunaPartyFrames[i].Buffs[z]:SetPoint("TOPLEFT", LunaPartyFrames[i].Buffs[z-1], "TOPRIGHT",1, 0)
			LunaPartyFrames[i].Buffs[z]:SetScript("OnEnter", Luna_Party_SetBuffTooltip)
			LunaPartyFrames[i].Buffs[z]:SetScript("OnLeave", Luna_Party_SetBuffTooltipLeave)
		
			LunaPartyFrames[i].Buffs[z].stacks = LunaPartyFrames[i].Buffs[z]:CreateFontString(nil, "OVERLAY", LunaPartyFrames[i].Buffs[z])
			LunaPartyFrames[i].Buffs[z].stacks:SetPoint("BOTTOMRIGHT", LunaPartyFrames[i].Buffs[z], 0, 0)
			LunaPartyFrames[i].Buffs[z].stacks:SetJustifyH("LEFT")
			LunaPartyFrames[i].Buffs[z].stacks:SetShadowColor(0, 0, 0)
			LunaPartyFrames[i].Buffs[z].stacks:SetShadowOffset(0.8, -0.8)
			LunaPartyFrames[i].Buffs[z].stacks:SetTextColor(1,1,1)
		end

		LunaPartyFrames[i].Debuffs = {}

		LunaPartyFrames[i].Debuffs[1] = CreateFrame("Button", nil, LunaPartyFrames[i])
		LunaPartyFrames[i].Debuffs[1].texturepath = UnitDebuff(LunaPartyFrames[i].unit,1)
		LunaPartyFrames[i].Debuffs[1].id = 17
		LunaPartyFrames[i].Debuffs[1]:SetNormalTexture(LunaPartyFrames[i].Debuffs[1].texturepath)
		LunaPartyFrames[i].Debuffs[1]:SetPoint("TOPLEFT", LunaPartyFrames[i].Buffs[1], "BOTTOMLEFT", 0, -3)
		LunaPartyFrames[i].Debuffs[1]:SetScript("OnEnter", Luna_Party_SetBuffTooltip)
		LunaPartyFrames[i].Debuffs[1]:SetScript("OnLeave", Luna_Party_SetBuffTooltipLeave)

		LunaPartyFrames[i].Debuffs[1].stacks = LunaPartyFrames[i].Debuffs[1]:CreateFontString(nil, "OVERLAY", LunaPartyFrames[i].Debuffs[1])
		LunaPartyFrames[i].Debuffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaPartyFrames[i].Debuffs[1], 0, 0)
		LunaPartyFrames[i].Debuffs[1].stacks:SetJustifyH("LEFT")
		LunaPartyFrames[i].Debuffs[1].stacks:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].Debuffs[1].stacks:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].Debuffs[1].stacks:SetTextColor(1,1,1)

		for z=2, 16 do
			LunaPartyFrames[i].Debuffs[z] = CreateFrame("Button", nil, LunaPartyFrames[i])
			LunaPartyFrames[i].Debuffs[z].texturepath = UnitDebuff(LunaPartyFrames[i].unit,z)
			LunaPartyFrames[i].Debuffs[z].id = z+16
			LunaPartyFrames[i].Debuffs[z]:SetNormalTexture(LunaPartyFrames[i].Debuffs[z].texturepath)
			LunaPartyFrames[i].Debuffs[z]:SetPoint("TOPLEFT", LunaPartyFrames[i].Debuffs[z-1], "TOPRIGHT",1, 0)
			LunaPartyFrames[i].Debuffs[z]:SetScript("OnEnter", Luna_Party_SetBuffTooltip)
			LunaPartyFrames[i].Debuffs[z]:SetScript("OnLeave", Luna_Party_SetBuffTooltipLeave)
		
			LunaPartyFrames[i].Debuffs[z].stacks = LunaPartyFrames[i].Debuffs[z]:CreateFontString(nil, "OVERLAY", LunaPartyFrames[i].Debuffs[z])
			LunaPartyFrames[i].Debuffs[z].stacks:SetPoint("BOTTOMRIGHT", LunaPartyFrames[i].Debuffs[z], 0, 0)
			LunaPartyFrames[i].Debuffs[z].stacks:SetJustifyH("LEFT")
			LunaPartyFrames[i].Debuffs[z].stacks:SetShadowColor(0, 0, 0)
			LunaPartyFrames[i].Debuffs[z].stacks:SetShadowOffset(0.8, -0.8)
			LunaPartyFrames[i].Debuffs[z].stacks:SetTextColor(1,1,1)
		end

		LunaPartyFrames[i].portrait = CreateFrame("PlayerModel", nil, LunaPartyFrames[i])
		LunaPartyFrames[i].portrait:SetScript("OnShow",function() this:SetCamera(0) end)
		LunaPartyFrames[i].portrait.type = "3D"
		LunaPartyFrames[i].portrait:SetPoint("TOPLEFT", LunaPartyFrames[i], "TOPLEFT")
		LunaPartyFrames[i].portrait.side = "left"

	-- Healthbar
		LunaPartyFrames[i].HealthBar = CreateFrame("StatusBar", nil, LunaPartyFrames[i])
		LunaPartyFrames[i].HealthBar:SetStatusBarTexture(LunaOptions.statusbartexture)
		LunaPartyFrames[i].HealthBar:SetPoint("TOPLEFT", LunaPartyFrames[i].portrait, "TOPRIGHT")

	-- Healthbar background
		LunaPartyFrames[i].HealthBar.hpbg = LunaPartyFrames[i].HealthBar:CreateTexture(nil, "BORDER")
		LunaPartyFrames[i].HealthBar.hpbg:SetAllPoints(LunaPartyFrames[i].HealthBar)
		LunaPartyFrames[i].HealthBar.hpbg:SetTexture(.25,.25,.25, 0.25)

	-- Healthbar text
		LunaPartyFrames[i].HealthBar.hpp = LunaPartyFrames[i].HealthBar:CreateFontString(nil, "OVERLAY", LunaPartyFrames[i].HealthBar)
		LunaPartyFrames[i].HealthBar.hpp:SetPoint("RIGHT", -2, -1)
		LunaPartyFrames[i].HealthBar.hpp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].HealthBar.hpp:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].HealthBar.hpp:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].HealthBar.hpp:SetTextColor(1,1,1)

		LunaPartyFrames[i].name = LunaPartyFrames[i].HealthBar:CreateFontString(nil, "OVERLAY", LunaPartyFrames[i].HealthBar)
		LunaPartyFrames[i].name:SetPoint("LEFT", 2, -1)
		LunaPartyFrames[i].name:SetJustifyH("LEFT")
		LunaPartyFrames[i].name:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].name:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].name:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].name:SetTextColor(1,1,1)
		LunaPartyFrames[i].name:SetText(UnitName("party"..i))

	-- Manabar
		LunaPartyFrames[i].PowerBar = CreateFrame("StatusBar", nil, LunaPartyFrames[i])
		LunaPartyFrames[i].PowerBar:SetStatusBarTexture(LunaOptions.statusbartexture)
		LunaPartyFrames[i].PowerBar:SetPoint("TOPLEFT", LunaPartyFrames[i].HealthBar, "BOTTOMLEFT", 0, -1)

	-- Manabar background
		LunaPartyFrames[i].PowerBar.ppbg = LunaPartyFrames[i].PowerBar:CreateTexture(nil, "BORDER")
		LunaPartyFrames[i].PowerBar.ppbg:SetAllPoints(LunaPartyFrames[i].PowerBar)
		LunaPartyFrames[i].PowerBar.ppbg:SetTexture(.25,.25,.25)

		LunaPartyFrames[i].PowerBar.ppp = LunaPartyFrames[i].PowerBar:CreateFontString(nil, "OVERLAY", LunaPartyFrames[i].PowerBar)
		LunaPartyFrames[i].PowerBar.ppp:SetPoint("RIGHT", -2, -1)
		LunaPartyFrames[i].PowerBar.ppp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].PowerBar.ppp:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].PowerBar.ppp:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].PowerBar.ppp:SetTextColor(1,1,1)

		LunaPartyFrames[i].lvl = LunaPartyFrames[i].PowerBar:CreateFontString(nil, "OVERLAY")
		LunaPartyFrames[i].lvl:SetPoint("LEFT", LunaPartyFrames[i].PowerBar, "LEFT", 2, -1)
		LunaPartyFrames[i].lvl:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].lvl:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].lvl:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].lvl:SetText(UnitLevel("party"..i))

		LunaPartyFrames[i].class = LunaPartyFrames[i].PowerBar:CreateFontString(nil, "OVERLAY")
		LunaPartyFrames[i].class:SetPoint("LEFT", LunaPartyFrames[i].lvl, "RIGHT",  1, 0)
		LunaPartyFrames[i].class:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].class:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].class:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].class:SetText(UnitClass("party"..i))

		LunaPartyFrames[i].icon = LunaPartyFrames[i].portrait:CreateTexture(nil, "OVERLAY")
		LunaPartyFrames[i].icon:SetHeight(20)
		LunaPartyFrames[i].icon:SetWidth(20)
		LunaPartyFrames[i].icon:SetPoint("CENTER", LunaPartyFrames[i].portrait, "TOPRIGHT", 0, 0)
		LunaPartyFrames[i].icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")

		LunaPartyFrames[i].PVPRank = LunaPartyFrames[i].portrait:CreateTexture(nil, "OVERLAY")
		LunaPartyFrames[i].PVPRank:SetHeight(10)
		LunaPartyFrames[i].PVPRank:SetWidth(10)
		LunaPartyFrames[i].PVPRank:SetPoint("CENTER", LunaPartyFrames[i].portrait, "BOTTOMLEFT", 2, 2)

		LunaPartyFrames[i].Leader = LunaPartyFrames[i].portrait:CreateTexture(nil, "OVERLAY")
		LunaPartyFrames[i].Leader:SetHeight(10)
		LunaPartyFrames[i].Leader:SetWidth(10)
		LunaPartyFrames[i].Leader:SetPoint("CENTER", LunaPartyFrames[i].portrait, "TOPLEFT", 2, -2)
		LunaPartyFrames[i].Leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")

		LunaPartyFrames[i].Loot = LunaPartyFrames[i].portrait:CreateTexture(nil, "OVERLAY")
		LunaPartyFrames[i].Loot:SetHeight(10)
		LunaPartyFrames[i].Loot:SetWidth(10)
		LunaPartyFrames[i].Loot:SetPoint("CENTER", LunaPartyFrames[i].portrait, "TOPLEFT", 2, -12)
		LunaPartyFrames[i].Loot:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")
		
		local frameHeight = LunaPartyFrames[i]:GetHeight()
		local frameWidth = (LunaPartyFrames[i]:GetWidth()-frameHeight)
		LunaPartyFrames[i].portrait:SetHeight(frameHeight+1)
		LunaPartyFrames[i].portrait:SetWidth(frameHeight) --square it
		LunaPartyFrames[i].HealthBar:SetWidth(frameWidth)
		LunaPartyFrames[i].PowerBar:SetWidth(frameWidth)
		LunaPartyFrames[i].HealthBar:SetHeight(frameHeight*0.58)
		LunaPartyFrames[i].PowerBar:SetHeight(frameHeight-(frameHeight*0.58)-1)
	end
	local frame
	for num = 1, 4 do
		frame = getglobal("PartyMemberFrame"..num)
		frame:Hide()
		frame:UnregisterAllEvents()
		getglobal("PartyMemberFrame"..num.."HealthBar"):UnregisterAllEvents()
		getglobal("PartyMemberFrame"..num.."ManaBar"):UnregisterAllEvents()
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", 0, 50)
	end
	LunaUnitFrames:UpdatePartyPosition()
	LunaUnitFrames:UpdatePartyFrames()
	LunaUnitFrames:UpdatePartyBuffLayout()
	GrpRangeCheck:SetScript("OnUpdate", GrpRangeCheck.onUpdate)
end

local function updateBuffs()
	for i=1,4 do
		for z=1, 16 do
			local path, stacks = UnitBuff(LunaPartyFrames[i].unit,z)
			LunaPartyFrames[i].Buffs[z].texturepath = path
			if LunaPartyFrames[i].Buffs[z].texturepath then
				LunaPartyFrames[i].Buffs[z]:EnableMouse(1)
				LunaPartyFrames[i].Buffs[z]:Show()
				if stacks > 1 then
					LunaPartyFrames[i].Buffs[z].stacks:SetText(stacks)
					LunaPartyFrames[i].Buffs[z].stacks:Show()
				else
					LunaPartyFrames[i].Buffs[z].stacks:Hide()
				end
			else
				LunaPartyFrames[i].Buffs[z]:EnableMouse(0)
				LunaPartyFrames[i].Buffs[z]:Hide()
			end
			LunaPartyFrames[i].Buffs[z]:SetNormalTexture(LunaPartyFrames[i].Buffs[z].texturepath)
		end

		for z=1, 16 do
			local path, stacks = UnitDebuff(LunaPartyFrames[i].unit,z)
			LunaPartyFrames[i].Debuffs[z].texturepath = path
			if LunaPartyFrames[i].Debuffs[z].texturepath then
				LunaPartyFrames[i].Debuffs[z]:EnableMouse(1)
				LunaPartyFrames[i].Debuffs[z]:Show()
				if stacks > 1 then
					LunaPartyFrames[i].Debuffs[z].stacks:SetText(stacks)
					LunaPartyFrames[i].Debuffs[z].stacks:Show()
				else
					LunaPartyFrames[i].Debuffs[z].stacks:Hide()
				end
			else
				LunaPartyFrames[i].Debuffs[z]:EnableMouse(0)
				LunaPartyFrames[i].Debuffs[z]:Hide()
			end
			LunaPartyFrames[i].Debuffs[z]:SetNormalTexture(LunaPartyFrames[i].Debuffs[z].texturepath)
		end
	end
end

function LunaUnitFrames:UpdatePartyFrames()
	local lootmaster
	_, lootmaster = GetLootMethod()
	for i=1, 4 do
		if LunaOptions.frames["LunaPartyFrames"].enabled == 1 and GetPartyMember(i) and (GetNumRaidMembers() == 0 or LunaOptions.PartyinRaid == 1) then
			LunaPartyFrames[i]:Show()
			local index = GetRaidTargetIndex(LunaPartyFrames[i].unit)
			if (index) then
				SetRaidTargetIconTexture(LunaPartyFrames[i].icon, index)
				LunaPartyFrames[i].icon:Show()
			else
				LunaPartyFrames[i].icon:Hide()
			end
			
			if lootmaster and ("party"..lootmaster) == LunaPartyFrames[i].unit then
				LunaPartyFrames[i].Loot:Show()
			else
				LunaPartyFrames[i].Loot:Hide()
			end
			
			if UnitIsPartyLeader(LunaPartyFrames[i].unit) then
				LunaPartyFrames[i].Leader:Show()
			else
				LunaPartyFrames[i].Leader:Hide()
			end
			
			if(LunaPartyFrames[i].portrait.type == "3D") then
				if(not UnitExists(LunaPartyFrames[i].unit) or not UnitIsConnected(LunaPartyFrames[i].unit) or not UnitIsVisible(LunaPartyFrames[i].unit)) then
					LunaPartyFrames[i].portrait:SetModelScale(4.25)
					LunaPartyFrames[i].portrait:SetPosition(0, 0, -1)
					LunaPartyFrames[i].portrait:SetModel"Interface\\Buttons\\talktomequestionmark.mdx"
				else
					LunaPartyFrames[i].portrait:SetUnit(LunaPartyFrames[i].unit)
					LunaPartyFrames[i].portrait:SetCamera(0)
					LunaPartyFrames[i].portrait:Show()
				end
			else
				SetPortraitTexture(LunaPartyFrames[i].portrait, LunaPartyFrames[i].unit)
			end
			

			
			if (UnitIsDead(LunaPartyFrames[i].unit) or UnitIsGhost(LunaPartyFrames[i].unit) or not UnitIsConnected(LunaPartyFrames[i].unit)) then
				LunaPartyFrames[i].HealthBar:SetMinMaxValues(0, UnitHealthMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].HealthBar:SetValue(0)
				LunaPartyFrames[i].HealthBar.hpp:SetText("0/"..UnitHealthMax(LunaPartyFrames[i].unit))
			
				LunaPartyFrames[i].PowerBar:SetMinMaxValues(0, UnitManaMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].PowerBar:SetValue(0)
				LunaPartyFrames[i].PowerBar.ppp:SetText("0/"..UnitManaMax(LunaPartyFrames[i].unit))
			else
				LunaPartyFrames[i].HealthBar:SetMinMaxValues(0, UnitHealthMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].HealthBar:SetValue(UnitHealth(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].HealthBar.hpp:SetText(UnitHealth(LunaPartyFrames[i].unit).."/"..UnitHealthMax(LunaPartyFrames[i].unit))
			
				LunaPartyFrames[i].PowerBar:SetMinMaxValues(0, UnitManaMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].PowerBar:SetValue(UnitMana(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].PowerBar.ppp:SetText(UnitMana(LunaPartyFrames[i].unit).."/"..UnitManaMax(LunaPartyFrames[i].unit))
			end
			
			local color
			if UnitIsConnected(LunaPartyFrames[i].unit) then
				color = LunaOptions.ClassColors[UnitClass(LunaPartyFrames[i].unit)]
			else
				color = LunaOptions.MiscColors["offline"]
			end
			if color == nil then
				color = LunaOptions.MiscColors["offline"]
			end
			LunaPartyFrames[i].HealthBar:SetStatusBarColor(color[1],color[2],color[3])
			LunaPartyFrames[i].HealthBar.hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
			
			local targetpower = UnitPowerType(LunaPartyFrames[i].unit)
			if targetpower == 1 then
				LunaPartyFrames[i].PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
				LunaPartyFrames[i].PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
			elseif targetpower == 3 then
				LunaPartyFrames[i].PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
				LunaPartyFrames[i].PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
			elseif not UnitIsDeadOrGhost("target") then
				LunaPartyFrames[i].PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
				LunaPartyFrames[i].PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
			else
				LunaPartyFrames[i].PowerBar:SetStatusBarColor(0, 0, 0, .25)
				LunaPartyFrames[i].PowerBar.ppbg:SetVertexColor(0, 0, 0, .25)
				end
			
			LunaPartyFrames[i].name:SetText(UnitName(LunaPartyFrames[i].unit))
			LunaPartyFrames[i].class:SetText(UnitClass(LunaPartyFrames[i].unit))
			LunaPartyFrames[i].lvl:SetText(UnitLevel(LunaPartyFrames[i].unit))
			
			local rankNumber = UnitPVPRank(LunaPartyFrames[i].unit);
			if (rankNumber == 0) then
				LunaPartyFrames[i].PVPRank:Hide();
			elseif (rankNumber < 14) then
				rankNumber = rankNumber - 4;
				LunaPartyFrames[i].PVPRank:SetTexture("Interface\\PvPRankBadges\\PvPRank0"..rankNumber);
				LunaPartyFrames[i].PVPRank:Show();
			else
				rankNumber = rankNumber - 4;
				LunaPartyFrames[i].PVPRank:SetTexture("Interface\\PvPRankBadges\\PvPRank"..rankNumber);
				LunaPartyFrames[i].PVPRank:Show();
			end
			updateBuffs()
		else
			LunaPartyFrames[i]:Hide()
		end
	end
end

function LunaUnitFrames:UpdatePartyBuffLayout()
	if LunaOptions.frames["LunaPartyFrames"].ShowBuffs == 1 then
		for i=1,4 do
			LunaPartyFrames[i]:UnregisterEvent("UNIT_AURA")
			for z=1, 16 do
				LunaPartyFrames[i].Buffs[z]:Hide()
				LunaPartyFrames[i].Debuffs[z]:Hide()
			end
		end
	elseif LunaOptions.frames["LunaPartyFrames"].ShowBuffs == 2 then
		for i=1,4 do
			LunaPartyFrames[i]:RegisterEvent("UNIT_AURA")
			LunaPartyFrames[i].Buffs[1]:ClearAllPoints()
			LunaPartyFrames[i].Buffs[1]:SetPoint("BOTTOMLEFT", LunaPartyFrames[i], "TOPLEFT", -1, 3)
			LunaPartyFrames[i].Debuffs[1]:ClearAllPoints()
			LunaPartyFrames[i].Debuffs[1]:SetPoint("BOTTOMLEFT", LunaPartyFrames[i].Buffs[1], "TOPLEFT", 0, 3)
			for z=2, 16 do
				LunaPartyFrames[i].Buffs[z]:ClearAllPoints()
				LunaPartyFrames[i].Buffs[z]:SetPoint("TOPLEFT", LunaPartyFrames[i].Buffs[z-1], "TOPRIGHT",1, 0)
				LunaPartyFrames[i].Debuffs[z]:ClearAllPoints()
				LunaPartyFrames[i].Debuffs[z]:SetPoint("TOPLEFT", LunaPartyFrames[i].Debuffs[z-1], "TOPRIGHT",1, 0)
			end
		end
		LunaUnitFrames:UpdatePartyBuffSize()
		updateBuffs()
	elseif LunaOptions.frames["LunaPartyFrames"].ShowBuffs == 3 then
		for i=1,4 do
			LunaPartyFrames[i]:RegisterEvent("UNIT_AURA")
			LunaPartyFrames[i].Buffs[1]:ClearAllPoints()
			LunaPartyFrames[i].Buffs[1]:SetPoint("TOPLEFT", LunaPartyFrames[i], "BOTTOMLEFT", -1, -3)
			LunaPartyFrames[i].Debuffs[1]:ClearAllPoints()
			LunaPartyFrames[i].Debuffs[1]:SetPoint("TOPLEFT", LunaPartyFrames[i].Buffs[1], "BOTTOMLEFT", 0, -3)
			for z=2, 16 do
				LunaPartyFrames[i].Buffs[z]:ClearAllPoints()
				LunaPartyFrames[i].Buffs[z]:SetPoint("TOPLEFT", LunaPartyFrames[i].Buffs[z-1], "TOPRIGHT", 1, 0)
				LunaPartyFrames[i].Debuffs[z]:ClearAllPoints()
				LunaPartyFrames[i].Debuffs[z]:SetPoint("TOPLEFT", LunaPartyFrames[i].Debuffs[z-1], "TOPRIGHT", 1, 0)
			end
		end
		LunaUnitFrames:UpdatePartyBuffSize()
		updateBuffs()
	elseif LunaOptions.frames["LunaPartyFrames"].ShowBuffs == 4 then
		for i=1,4 do
			LunaPartyFrames[i]:RegisterEvent("UNIT_AURA")
			LunaPartyFrames[i].Buffs[1]:ClearAllPoints()
			LunaPartyFrames[i].Buffs[1]:SetPoint("TOPRIGHT", LunaPartyFrames[i], "TOPLEFT", -3, 1)
			LunaPartyFrames[i].Debuffs[1]:ClearAllPoints()
			LunaPartyFrames[i].Debuffs[1]:SetPoint("TOPLEFT", LunaPartyFrames[i].Buffs[9], "BOTTOMLEFT", 0, -1)
			LunaPartyFrames[i].Buffs[9]:ClearAllPoints()
			LunaPartyFrames[i].Buffs[9]:SetPoint("TOPLEFT", LunaPartyFrames[i].Buffs[1], "BOTTOMLEFT", 0, -1)
			LunaPartyFrames[i].Debuffs[9]:ClearAllPoints()
			LunaPartyFrames[i].Debuffs[9]:SetPoint("TOPLEFT", LunaPartyFrames[i].Debuffs[1], "BOTTOMLEFT", 0, -1)
			for z=2, 8 do
				LunaPartyFrames[i].Buffs[z]:ClearAllPoints()
				LunaPartyFrames[i].Buffs[z]:SetPoint("TOPRIGHT", LunaPartyFrames[i].Buffs[z-1], "TOPLEFT",1, 0)
				LunaPartyFrames[i].Debuffs[z]:ClearAllPoints()
				LunaPartyFrames[i].Debuffs[z]:SetPoint("TOPRIGHT", LunaPartyFrames[i].Debuffs[z-1], "TOPLEFT",1, 0)
			end
			for z=10, 16 do
				LunaPartyFrames[i].Buffs[z]:ClearAllPoints()
				LunaPartyFrames[i].Buffs[z]:SetPoint("TOPRIGHT", LunaPartyFrames[i].Buffs[z-1], "TOPLEFT",1, 0)
				LunaPartyFrames[i].Debuffs[z]:ClearAllPoints()
				LunaPartyFrames[i].Debuffs[z]:SetPoint("TOPRIGHT", LunaPartyFrames[i].Debuffs[z-1], "TOPLEFT",1, 0)
			end
		end
		LunaUnitFrames:UpdatePartyBuffSize()
		updateBuffs()
	else
		for i=1,4 do
			LunaPartyFrames[i]:RegisterEvent("UNIT_AURA")
			LunaPartyFrames[i].Buffs[1]:ClearAllPoints()
			LunaPartyFrames[i].Buffs[1]:SetPoint("TOPLEFT", LunaPartyFrames[i], "TOPRIGHT", 3, 1)
			LunaPartyFrames[i].Debuffs[1]:ClearAllPoints()
			LunaPartyFrames[i].Debuffs[1]:SetPoint("TOPLEFT", LunaPartyFrames[i].Buffs[9], "BOTTOMLEFT", 0, -1)
			LunaPartyFrames[i].Buffs[9]:ClearAllPoints()
			LunaPartyFrames[i].Buffs[9]:SetPoint("TOPLEFT", LunaPartyFrames[i].Buffs[1], "BOTTOMLEFT", 0, -1)
			LunaPartyFrames[i].Debuffs[9]:ClearAllPoints()
			LunaPartyFrames[i].Debuffs[9]:SetPoint("TOPLEFT", LunaPartyFrames[i].Debuffs[1], "BOTTOMLEFT", 0, -1)
			for z=2, 8 do
				LunaPartyFrames[i].Buffs[z]:ClearAllPoints()
				LunaPartyFrames[i].Buffs[z]:SetPoint("TOPLEFT", LunaPartyFrames[i].Buffs[z-1], "TOPRIGHT",1, 0)
				LunaPartyFrames[i].Debuffs[z]:ClearAllPoints()
				LunaPartyFrames[i].Debuffs[z]:SetPoint("TOPLEFT", LunaPartyFrames[i].Debuffs[z-1], "TOPRIGHT",1, 0)
			end
			for z=10, 16 do
				LunaPartyFrames[i].Buffs[z]:ClearAllPoints()
				LunaPartyFrames[i].Buffs[z]:SetPoint("TOPLEFT", LunaPartyFrames[i].Buffs[z-1], "TOPRIGHT",1, 0)
				LunaPartyFrames[i].Debuffs[z]:ClearAllPoints()
				LunaPartyFrames[i].Debuffs[z]:SetPoint("TOPLEFT", LunaPartyFrames[i].Debuffs[z-1], "TOPRIGHT",1, 0)
			end
		end
		LunaUnitFrames:UpdatePartyBuffSize()
		updateBuffs()
	end
end

function LunaUnitFrames:UpdatePartyBuffSize()
	local size
	if LunaOptions.frames["LunaPartyFrames"].ShowBuffs == 2 or LunaOptions.frames["LunaPartyFrames"].ShowBuffs == 3 then
		size = (LunaPartyFrames[1]:GetWidth()-15)/16
	else
		size = (LunaPartyFrames[1]:GetHeight()-3)/4
	end
	for i=1,4 do
		for z=1, 16 do
			LunaPartyFrames[i].Buffs[z]:SetHeight(size)
			LunaPartyFrames[i].Buffs[z]:SetWidth(size)
			LunaPartyFrames[i].Buffs[z].stacks:SetFont(LunaOptions.font, size*0.75)
			LunaPartyFrames[i].Debuffs[z]:SetHeight(size)
			LunaPartyFrames[i].Debuffs[z]:SetWidth(size)
			LunaPartyFrames[i].Debuffs[z].stacks:SetFont(LunaOptions.font, size*0.75)
		end
	end
end

function Luna_Party_Events:RAID_TARGET_UPDATE()
	local index = GetRaidTargetIndex(this.unit)
	if (index) then
		SetRaidTargetIconTexture(this.icon, index)
		this.icon:Show()
	else
		this.icon:Hide()
	end
end

function Luna_Party_Events:UNIT_AURA()
	if this.unit == arg1 then
		for i=1, 16 do
			local path, stacks = UnitBuff(this.unit,i)
			this.Buffs[i].texturepath = path
			if this.Buffs[i].texturepath then
				this.Buffs[i]:EnableMouse(1)
				this.Buffs[i]:Show()
				if stacks > 1 then
					this.Buffs[i].stacks:SetText(stacks)
					this.Buffs[i].stacks:Show()
				else
					this.Buffs[i].stacks:Hide()
				end
			else
				this.Buffs[i]:EnableMouse(0)
				this.Buffs[i]:Hide()
			end
			this.Buffs[i]:SetNormalTexture(this.Buffs[i].texturepath)
		end

		for i=1, 16 do
			local path, stacks = UnitDebuff(this.unit,i)
			this.Debuffs[i].texturepath = path
			if this.Debuffs[i].texturepath then
				this.Debuffs[i]:EnableMouse(1)
				this.Debuffs[i]:Show()
				if stacks > 1 then
					this.Debuffs[i].stacks:SetText(stacks)
					this.Debuffs[i].stacks:Show()
				else
					this.Debuffs[i].stacks:Hide()
				end
			else
				this.Debuffs[i]:EnableMouse(0)
				this.Debuffs[i]:Hide()
			end
			this.Debuffs[i]:SetNormalTexture(this.Debuffs[i].texturepath)
		end
	end
end

function Luna_Party_Events:UNIT_HEALTH()
	if this.unit == arg1 then
		this.HealthBar:SetMinMaxValues(0, UnitHealthMax(this.unit))
		this.HealthBar:SetValue(UnitHealth(this.unit))
		this.HealthBar.hpp:SetText(UnitHealth(this.unit).."/"..UnitHealthMax(this.unit))
		if (UnitIsDead(this.unit) or UnitIsGhost(this.unit)) then			-- This prevents negative health
			this.HealthBar:SetValue(0)
		end
		local color
		if UnitIsConnected(this.unit) then
			color = LunaOptions.ClassColors[UnitClass(this.unit)]
		else
			color = LunaOptions.MiscColors["offline"]
		end
		if color then
			this.HealthBar:SetStatusBarColor(color[1],color[2],color[3])
			this.HealthBar.hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
		end
	end
end
Luna_Party_Events.UNIT_MAXHEALTH = Luna_Party_Events.UNIT_HEALTH;

function Luna_Party_Events:UNIT_MANA()
	if this.unit == arg1 then
		if (UnitIsDead(this.unit) or UnitIsGhost(this.unit)) then
			this.PowerBar:SetValue(0)
			this.PowerBar.ppp:SetText("0/"..UnitManaMax(this.unit))
		else
			this.PowerBar:SetMinMaxValues(0, UnitManaMax(this.unit))
			this.PowerBar:SetValue(UnitMana(this.unit))
			this.PowerBar.ppp:SetText(UnitMana(this.unit).."/"..UnitManaMax(this.unit))
		end
	end
end
Luna_Party_Events.UNIT_MAXMANA = Luna_Party_Events.UNIT_MANA;
Luna_Party_Events.UNIT_ENERGY = Luna_Party_Events.UNIT_MANA;
Luna_Party_Events.UNIT_MAXENERGY = Luna_Party_Events.UNIT_MANA;
Luna_Party_Events.UNIT_RAGE = Luna_Party_Events.UNIT_MANA;
Luna_Party_Events.UNIT_MAXRAGE = Luna_Party_Events.UNIT_MANA;

function Luna_Party_Events:PARTY_LEADER_CHANGED()
	if UnitIsPartyLeader(this.unit) then
		this.Leader:Show()
	else
		this.Leader:Hide()
	end
end

function Luna_Party_Events.PARTY_MEMBERS_CHANGED()
	LunaUnitFrames:UpdatePartyFrames()
	LunaUnitFrames:UpdatePartyPetFrames()
end

function Luna_Party_Events:UNIT_DISPLAYPOWER()
	if arg1 == this.unit then
		targetpower = UnitPowerType(arg1)
		
		if UnitManaMax(arg1) == 0 then
			this.PowerBar:SetStatusBarColor(0, 0, 0, .25)
			this.PowerBar.ppbg:SetVertexColor(0, 0, 0, .25)
		elseif targetpower == 1 then
			this.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
			this.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
		elseif targetpower == 3 then
			this.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
			this.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
		elseif not UnitIsDeadOrGhost("target") then
			this.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
			this.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
		else
			this.PowerBar:SetStatusBarColor(0, 0, 0, .25)
			this.PowerBar.ppbg:SetVertexColor(0, 0, 0, .25)
		end
		Luna_Party_Events.UNIT_MANA()
	end
end

function Luna_Party_Events:PARTY_LOOT_METHOD_CHANGED()
	local lootmaster;
	_, lootmaster = GetLootMethod()
	if lootmaster and ("party"..lootmaster) == this.unit then
		this.Loot:Show()
	else
		this.Loot:Hide()
	end
end

function Luna_Party_Events:UNIT_LEVEL()
	if arg1 == this.unit then
		local lvl = UnitLevel(this.unit)
		if lvl == -1 then
			this.Lvl:SetText("??")
		else
			this.Lvl:SetText(lvl)
		end
	end
end

function Luna_Party_Events:UNIT_PORTRAIT_UPDATE()
	if arg1 == this.unit then
		local portrait = this.portrait
		if(portrait.type == "3D") then
			if(not UnitExists(arg1) or not UnitIsConnected(arg1) or not UnitIsVisible(arg1)) then
				portrait:SetModelScale(4.25)
				portrait:SetPosition(0, 0, -1)
				portrait:SetModel"Interface\\Buttons\\talktomequestionmark.mdx"
			else
				portrait:SetUnit(arg1)
				portrait:SetCamera(0)
				portrait:Show()
			end
		else
			SetPortraitTexture(portrait, arg1)
		end
	end
end

function Luna_Party_Events:RAID_ROSTER_UPDATE()
	LunaUnitFrames:UpdatePartyFrames()
end
Luna_Party_Events.UNIT_MODEL_CHANGED = Luna_Party_Events.UNIT_PORTRAIT_UPDATE

function Luna_Party_Events:UNIT_PET()
	LunaUnitFrames:UpdatePartyPetFrames()
end