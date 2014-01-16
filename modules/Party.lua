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

local function SetIconPositions()
	if LunaOptions.frames["LunaPartyFrames"].portrait == 1 then
		for i=1,4 do
			LunaPartyFrames[i].icon:ClearAllPoints()
			LunaPartyFrames[i].icon:SetPoint("CENTER", LunaPartyFrames[i], "TOP")
			LunaPartyFrames[i].PVPRank:ClearAllPoints()
			LunaPartyFrames[i].PVPRank:SetPoint("CENTER", LunaPartyFrames[i], "BOTTOMLEFT", -2, 2)
			LunaPartyFrames[i].Leader:ClearAllPoints()
			LunaPartyFrames[i].Leader:SetPoint("CENTER", LunaPartyFrames[i], "TOPLEFT", -1, -2)
			LunaPartyFrames[i].Loot:ClearAllPoints()
			LunaPartyFrames[i].Loot:SetPoint("CENTER", LunaPartyFrames[i], "TOPLEFT", -2, -12)
		end
	else
		for i=1,4 do
			LunaPartyFrames[i].icon:ClearAllPoints()
			LunaPartyFrames[i].icon:SetPoint("CENTER", LunaPartyFrames[i].bars["Portrait"], "TOPRIGHT")
			LunaPartyFrames[i].PVPRank:ClearAllPoints()
			LunaPartyFrames[i].PVPRank:SetPoint("CENTER", LunaPartyFrames[i].bars["Portrait"], "BOTTOMLEFT", 2, 2)
			LunaPartyFrames[i].Leader:ClearAllPoints()
			LunaPartyFrames[i].Leader:SetPoint("CENTER", LunaPartyFrames[i].bars["Portrait"], "TOPLEFT", 2, -2)
			LunaPartyFrames[i].Loot:ClearAllPoints()
			LunaPartyFrames[i].Loot:SetPoint("CENTER", LunaPartyFrames[i].bars["Portrait"], "TOPLEFT", 2, -12)
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
		LunaPartyFrames[i]:SetFrameStrata("BACKGROUND")
		LunaPartyFrames[i]:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
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

		LunaPartyFrames[i].bars = {}
		
		LunaPartyFrames[i].bars["Portrait"] = CreateFrame("PlayerModel", nil, LunaPartyFrames[i])
		LunaPartyFrames[i].bars["Portrait"]:SetScript("OnShow",function() this:SetCamera(0) end)
		LunaPartyFrames[i].bars["Portrait"].type = "3D"
		LunaPartyFrames[i].bars["Portrait"]:SetPoint("TOPLEFT", LunaPartyFrames[i], "TOPLEFT")
		LunaPartyFrames[i].bars["Portrait"].side = "left"
		
	-- Healthbar
		LunaPartyFrames[i].bars["Healthbar"] = CreateFrame("StatusBar", nil, LunaPartyFrames[i])
		LunaPartyFrames[i].bars["Healthbar"]:SetStatusBarTexture(LunaOptions.statusbartexture)
		LunaPartyFrames[i].bars["Healthbar"]:SetFrameStrata("MEDIUM")
		
		LunaPartyFrames[i].incHeal = CreateFrame("StatusBar", nil, LunaPartyFrames[i])
		LunaPartyFrames[i].incHeal:SetFrameStrata("LOW")
		LunaPartyFrames[i].incHeal:SetStatusBarTexture(LunaOptions.statusbartexture)
		LunaPartyFrames[i].incHeal:SetPoint("TOPLEFT", LunaPartyFrames[i].bars["Healthbar"], "TOPLEFT")
		LunaPartyFrames[i].incHeal:SetValue(0)
		LunaPartyFrames[i].incHeal:SetStatusBarColor(0, 1, 0, 0.6)
		LunaPartyFrames[i].incHeal.healvalue = 0

	-- Healthbar background
		LunaPartyFrames[i].bars["Healthbar"].hpbg = LunaPartyFrames[i]:CreateTexture(nil, "BACKGROUND")
		LunaPartyFrames[i].bars["Healthbar"].hpbg:SetAllPoints(LunaPartyFrames[i].bars["Healthbar"])
		LunaPartyFrames[i].bars["Healthbar"].hpbg:SetTexture(.25,.25,.25,.25)

	-- Healthbar text
		LunaPartyFrames[i].bars["Healthbar"].hpp = LunaPartyFrames[i].bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaPartyFrames[i].bars["Healthbar"])
		LunaPartyFrames[i].bars["Healthbar"].hpp:SetPoint("RIGHT", -2, -1)
		LunaPartyFrames[i].bars["Healthbar"].hpp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].bars["Healthbar"].hpp:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].bars["Healthbar"].hpp:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].bars["Healthbar"].hpp:SetTextColor(1,1,1)

		LunaPartyFrames[i].name = LunaPartyFrames[i].bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaPartyFrames[i].bars["Healthbar"])
		LunaPartyFrames[i].name:SetPoint("LEFT", 2, -1)
		LunaPartyFrames[i].name:SetJustifyH("LEFT")
		LunaPartyFrames[i].name:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].name:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].name:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].name:SetTextColor(1,1,1)
		LunaPartyFrames[i].name:SetText(UnitName("party"..i))

	-- Manabar
		LunaPartyFrames[i].bars["Powerbar"] = CreateFrame("StatusBar", nil, LunaPartyFrames[i])
		LunaPartyFrames[i].bars["Powerbar"]:SetStatusBarTexture(LunaOptions.statusbartexture)

	-- Manabar background
		LunaPartyFrames[i].bars["Powerbar"].ppbg = LunaPartyFrames[i].bars["Powerbar"]:CreateTexture(nil, "BORDER")
		LunaPartyFrames[i].bars["Powerbar"].ppbg:SetAllPoints(LunaPartyFrames[i].bars["Powerbar"])
		LunaPartyFrames[i].bars["Powerbar"].ppbg:SetTexture(.25,.25,.25,.25)

		LunaPartyFrames[i].bars["Powerbar"].ppp = LunaPartyFrames[i].bars["Powerbar"]:CreateFontString(nil, "OVERLAY", LunaPartyFrames[i].bars["Powerbar"])
		LunaPartyFrames[i].bars["Powerbar"].ppp:SetPoint("RIGHT", -2, -1)
		LunaPartyFrames[i].bars["Powerbar"].ppp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].bars["Powerbar"].ppp:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].bars["Powerbar"].ppp:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].bars["Powerbar"].ppp:SetTextColor(1,1,1)

		LunaPartyFrames[i].lvl = LunaPartyFrames[i].bars["Powerbar"]:CreateFontString(nil, "OVERLAY")
		LunaPartyFrames[i].lvl:SetPoint("LEFT", LunaPartyFrames[i].bars["Powerbar"], "LEFT", 2, -1)
		LunaPartyFrames[i].lvl:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].lvl:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].lvl:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].lvl:SetText(UnitLevel("party"..i))

		LunaPartyFrames[i].class = LunaPartyFrames[i].bars["Powerbar"]:CreateFontString(nil, "OVERLAY")
		LunaPartyFrames[i].class:SetPoint("LEFT", LunaPartyFrames[i].lvl, "RIGHT",  1, 0)
		LunaPartyFrames[i].class:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].class:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].class:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].class:SetText(UnitClass("party"..i))

		LunaPartyFrames[i].iconholder = CreateFrame("Frame", nil, LunaPartyFrames[i])
		LunaPartyFrames[i].iconholder:SetFrameStrata("MEDIUM")
		
		LunaPartyFrames[i].icon = LunaPartyFrames[i].iconholder:CreateTexture(nil, "OVERLAY")
		LunaPartyFrames[i].icon:SetHeight(20)
		LunaPartyFrames[i].icon:SetWidth(20)
		LunaPartyFrames[i].icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")

		LunaPartyFrames[i].PVPRank = LunaPartyFrames[i].iconholder:CreateTexture(nil, "OVERLAY")
		LunaPartyFrames[i].PVPRank:SetHeight(10)
		LunaPartyFrames[i].PVPRank:SetWidth(10)

		LunaPartyFrames[i].Leader = LunaPartyFrames[i].iconholder:CreateTexture(nil, "OVERLAY")
		LunaPartyFrames[i].Leader:SetHeight(10)
		LunaPartyFrames[i].Leader:SetWidth(10)
		LunaPartyFrames[i].Leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")

		LunaPartyFrames[i].Loot = LunaPartyFrames[i].iconholder:CreateTexture(nil, "OVERLAY")
		LunaPartyFrames[i].Loot:SetHeight(10)
		LunaPartyFrames[i].Loot:SetWidth(10)
		LunaPartyFrames[i].Loot:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")
		
		for k,v in pairs(LunaOptions.frames["LunaPartyFrames"].bars) do
			if v[2] == 0 then
				LunaPartyFrames[i].bars[v[1]]:Hide()
			end
		end
	end
	
	ShowPartyFrame = function() end  -- Hide Blizz stuff
	HidePartyFrame = ShowPartyFrame
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
	
	
	SetIconPositions()
	LunaUnitFrames:UpdatePartyUnitFrameSize()
	LunaUnitFrames:UpdatePartyPosition()
	LunaUnitFrames:UpdatePartyFrames()
	LunaUnitFrames:UpdatePartyBuffLayout()
	GrpRangeCheck:SetScript("OnUpdate", GrpRangeCheck.onUpdate)
end

function LunaUnitFrames:PartyUpdateHeal()
	for i=1,4 do
		local healamount = 0
		if LunaUnitFrames.HealComm.Heals[UnitName("party"..i)] then
			for k,v in LunaUnitFrames.HealComm.Heals[UnitName("party"..i)] do
				healamount = healamount+v.amount
			end
		end
		LunaPartyFrames[i].incHeal.healvalue = healamount
		LunaPartyFrames[i].incHeal:SetMinMaxValues(0, UnitHealthMax("party"..i)*1.2)
		if UnitIsDeadOrGhost(LunaPartyFrames[i].unit) or not UnitIsConnected(LunaPartyFrames[i].unit) then
			LunaPartyFrames[i].incHeal:SetValue(0)
		else
			LunaPartyFrames[i].incHeal:SetValue(UnitHealth("party"..i)+LunaPartyFrames[i].incHeal.healvalue)
		end
	end
end

function LunaUnitFrames:ConvertPartyPortraits()
	if LunaOptions.frames["LunaPartyFrames"].portrait == 1 then
		table.insert(LunaOptions.frames["LunaPartyFrames"].bars, 1, {"Portrait", 4})
	else
		for k,v in pairs(LunaOptions.frames["LunaPartyFrames"].bars) do
			if v[1] == "Portrait" then
				table.remove(LunaOptions.frames["LunaPartyFrames"].bars, k)
			end
		end
	end
	UIDropDownMenu_SetText("Healthbar", LunaOptionsFrame.pages[5].BarSelect)
	LunaOptionsFrame.pages[5].barorder:SetMinMaxValues(1,table.getn(LunaOptions.frames["LunaPartyFrames"].bars))
	for k,v in pairs(LunaOptions.frames["LunaPartyFrames"].bars) do
		if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[5].BarSelect) then
			LunaOptionsFrame.pages[5].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[5].barorder:SetValue(k)
			break
		end
	end
	SetIconPositions()
	LunaUnitFrames:UpdatePartyUnitFrameSize()
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

function LunaUnitFrames:UpdatePartyUnitFrameSize()
	local frameWidth
	local anchor
	local frameHeight
	local totalWeight
	local gaps
	for i=1, 4 do
		frameHeight = LunaPartyFrames[i]:GetHeight()
		totalWeight = 0
		gaps = -1
		if LunaOptions.frames["LunaPartyFrames"].portrait > 1 then    -- We have a square portrait
			frameWidth = (LunaPartyFrames[i]:GetWidth()-frameHeight)
			LunaPartyFrames[i].bars["Portrait"]:SetPoint("TOPLEFT", LunaPartyFrames[i], "TOPLEFT")
			LunaPartyFrames[i].bars["Portrait"]:SetHeight(frameHeight+1)
			LunaPartyFrames[i].bars["Portrait"]:SetWidth(frameHeight)
			anchor = {"TOPLEFT", LunaPartyFrames[i].bars["Portrait"], "TOPRIGHT"}
		else
			frameWidth = LunaPartyFrames[i]:GetWidth()  -- We have a Bar-Portrait or no portrait
			anchor = {"TOPLEFT", LunaPartyFrames[i], "TOPLEFT"}
		end
		for k,v in pairs(LunaOptions.frames["LunaPartyFrames"].bars) do
			if LunaPartyFrames[i].bars[v[1]]:IsShown() then
				totalWeight = totalWeight + v[2]
				gaps = gaps + 1
			end
		end
		local firstbar = 1
		for k,v in pairs(LunaOptions.frames["LunaPartyFrames"].bars) do
			local bar = v[1]
			local weight = v[2]/totalWeight
			local height = (frameHeight-gaps)*weight
			LunaPartyFrames[i].bars[bar]:ClearAllPoints()
			LunaPartyFrames[i].bars[bar]:SetHeight(height)
			LunaPartyFrames[i].bars[bar]:SetWidth(frameWidth)
			LunaPartyFrames[i].bars[bar].rank = k
			LunaPartyFrames[i].bars[bar].weight = v[2]
			
			if not firstbar and LunaPartyFrames[i].bars[bar]:IsShown() then
				LunaPartyFrames[i].bars[bar]:SetPoint(anchor[1], anchor[2], anchor[3], 0, -1)
				anchor = {"TOPLEFT", LunaPartyFrames[i].bars[bar], "BOTTOMLEFT"}
			elseif LunaPartyFrames[i].bars[bar]:IsShown() then
				LunaPartyFrames[i].bars[bar]:SetPoint(anchor[1], anchor[2], anchor[3])
				firstbar = nil
				anchor = {"TOPLEFT", LunaPartyFrames[i].bars[bar], "BOTTOMLEFT"}
			end			
		end
		LunaPartyFrames[i].incHeal:SetHeight(LunaPartyFrames[i].bars["Healthbar"]:GetHeight())
		LunaPartyFrames[i].incHeal:SetWidth(LunaPartyFrames[i].bars["Healthbar"]:GetWidth()*1.2)
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
			
			if(LunaPartyFrames[i].bars["Portrait"].type == "3D") then
				if(not UnitExists(LunaPartyFrames[i].unit) or not UnitIsConnected(LunaPartyFrames[i].unit) or not UnitIsVisible(LunaPartyFrames[i].unit)) then
					LunaPartyFrames[i].bars["Portrait"]:SetModelScale(4.25)
					LunaPartyFrames[i].bars["Portrait"]:SetPosition(0, 0, -1)
					LunaPartyFrames[i].bars["Portrait"]:SetModel"Interface\\Buttons\\talktomequestionmark.mdx"
				else
					LunaPartyFrames[i].bars["Portrait"]:SetUnit(LunaPartyFrames[i].unit)
					LunaPartyFrames[i].bars["Portrait"]:SetCamera(0)
					LunaPartyFrames[i].bars["Portrait"]:Show()
				end
			else
				SetPortraitTexture(LunaPartyFrames[i].bars["Portrait"], LunaPartyFrames[i].unit)
			end
			

			if not UnitIsConnected(LunaPartyFrames[i].unit) then
				LunaPartyFrames[i].bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Healthbar"]:SetValue(0)
				LunaPartyFrames[i].bars["Healthbar"].hpp:SetText("OFFLINE")
			
				LunaPartyFrames[i].bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Powerbar"]:SetValue(0)
				LunaPartyFrames[i].bars["Powerbar"].ppp:SetText("0/"..UnitManaMax(LunaPartyFrames[i].unit))
			elseif UnitHealth(LunaPartyFrames[i].unit) < 2 then
				LunaPartyFrames[i].bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Healthbar"]:SetValue(0)
				LunaPartyFrames[i].bars["Healthbar"].hpp:SetText("DEAD")
			
				LunaPartyFrames[i].bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Powerbar"]:SetValue(0)
				LunaPartyFrames[i].bars["Powerbar"].ppp:SetText("0/"..UnitManaMax(LunaPartyFrames[i].unit))
			else
				LunaPartyFrames[i].bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Healthbar"]:SetValue(UnitHealth(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Healthbar"].hpp:SetText(UnitHealth(LunaPartyFrames[i].unit).."/"..UnitHealthMax(LunaPartyFrames[i].unit))
			
				LunaPartyFrames[i].bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Powerbar"]:SetValue(UnitMana(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Powerbar"].ppp:SetText(UnitMana(LunaPartyFrames[i].unit).."/"..UnitManaMax(LunaPartyFrames[i].unit))
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
			LunaPartyFrames[i].bars["Healthbar"]:SetStatusBarColor(color[1],color[2],color[3])
			LunaPartyFrames[i].bars["Healthbar"].hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
			
			local targetpower = UnitPowerType(LunaPartyFrames[i].unit)
			if targetpower == 1 then
				LunaPartyFrames[i].bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
				LunaPartyFrames[i].bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
			elseif targetpower == 3 then
				LunaPartyFrames[i].bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
				LunaPartyFrames[i].bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
			elseif not UnitIsDeadOrGhost("target") then
				LunaPartyFrames[i].bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
				LunaPartyFrames[i].bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
			else
				LunaPartyFrames[i].bars["Powerbar"]:SetStatusBarColor(0, 0, 0, .25)
				LunaPartyFrames[i].bars["Powerbar"].ppbg:SetVertexColor(0, 0, 0, .25)
				end
			
			LunaPartyFrames[i].name:SetText(UnitName(LunaPartyFrames[i].unit))
			LunaPartyFrames[i].class:SetText(UnitClass(LunaPartyFrames[i].unit))
			if UnitLevel(LunaPartyFrames[i].unit) > 0 then
				LunaPartyFrames[i].lvl:SetText(UnitLevel(LunaPartyFrames[i].unit))
			else
				LunaPartyFrames[i].lvl:SetText("??")
			end
			
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
	LunaUnitFrames:PartyUpdateHeal()
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
		this.incHeal:SetMinMaxValues(0, UnitHealthMax(this.unit)*1.2)
		if UnitIsDeadOrGhost(this.unit) or not UnitIsConnected(this.unit) then
			this.incHeal:SetValue(0)
		else
			this.incHeal:SetValue(UnitHealth(this.unit)+this.incHeal.healvalue)
		end
		this.bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(this.unit))
		this.bars["Healthbar"]:SetValue(UnitHealth(this.unit))
		this.bars["Healthbar"].hpp:SetText(UnitHealth(this.unit).."/"..UnitHealthMax(this.unit))
		if (UnitIsDead(this.unit) or UnitIsGhost(this.unit)) then			-- This prevents negative health
			this.bars["Healthbar"]:SetValue(0)
		end
		local color
		if not UnitIsConnected(this.unit) then
			color = LunaOptions.MiscColors["offline"]
			this.bars["Healthbar"].hpp:SetText("OFFLINE")
		elseif UnitHealth(this.unit) < 2 then
			color = LunaOptions.MiscColors["offline"]
			this.bars["Healthbar"].hpp:SetText("DEAD")
		else
			color = LunaOptions.ClassColors[UnitClass(this.unit)]
		end
		if color then
			this.bars["Healthbar"]:SetStatusBarColor(color[1],color[2],color[3])
			this.bars["Healthbar"].hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
		end
		Luna_Party_Events.UNIT_LEVEL()
	end
end
Luna_Party_Events.UNIT_MAXHEALTH = Luna_Party_Events.UNIT_HEALTH;


function Luna_Party_Events:UNIT_MANA()
	if this.unit == arg1 then
		if (UnitHealth(this.unit) < 2 or not UnitIsConnected(this.unit)) then
			this.bars["Powerbar"]:SetValue(0)
			this.bars["Powerbar"].ppp:SetText("0/"..UnitManaMax(this.unit))
		else
			this.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(this.unit))
			this.bars["Powerbar"]:SetValue(UnitMana(this.unit))
			this.bars["Powerbar"].ppp:SetText(UnitMana(this.unit).."/"..UnitManaMax(this.unit))
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
			this.bars["Powerbar"]:SetStatusBarColor(0, 0, 0, .25)
			this.bars["Powerbar"].ppbg:SetVertexColor(0, 0, 0, .25)
		elseif targetpower == 1 then
			this.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
			this.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
		elseif targetpower == 3 then
			this.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
			this.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
		elseif not UnitIsDeadOrGhost("target") then
			this.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
			this.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
		else
			this.bars["Powerbar"]:SetStatusBarColor(0, 0, 0, .25)
			this.bars["Powerbar"].ppbg:SetVertexColor(0, 0, 0, .25)
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
		if lvl < 1 then
			this.lvl:SetText("??")
		else
			this.lvl:SetText(lvl)
		end
	end
end

function Luna_Party_Events:UNIT_PORTRAIT_UPDATE()
	if arg1 == this.unit then
		local portrait = this.bars["Portrait"]
		if(portrait.type == "3D") then
			if(not UnitExists(arg1) or not UnitIsConnected(arg1) or not UnitIsVisible(arg1)) then
				portrait:SetModelScale(4.25)
				portrait:SetPosition(0, 0, -1)
				portrait:SetModel"Interface\\Buttons\\talktomequestionmark.mdx"
			else
				portrait:SetUnit(arg1)
				portrait:SetCamera(0)
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