local HealComm = AceLibrary("HealComm-1.0")
local AceEvent = AceLibrary("AceEvent-2.0")
local Luna_Party_Events = {}
LunaPartyFrames = {}

GrpRangeCheck = CreateFrame("Frame")
GrpRangeCheck.time = 0
GrpRangeCheck.pettime = 0
GrpRangeCheck.onUpdate = function ()
	GrpRangeCheck.pettime = GrpRangeCheck.pettime + arg1
	if (GrpRangeCheck.pettime > 2) then
		GrpRangeCheck.pettime = 0
		for i=1, 4 do
			if UnitIsVisible(LunaPartyPetFrames[i].unit) then
				LunaUnitFrames:UpdatePartyPetFrames()
			end
		end
	end
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

local function Luna_Party_OnEvent()
	local func = Luna_Party_Events[event]
	if (func) then
		func()
	else
		DEFAULT_CHAT_FRAME:AddMessage("Luna Unit Frames - Party: Report the following event error to the author: "..event)
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
		LunaPartyFrames[i]:SetScript("OnClick", Luna_OnClick)
		LunaPartyFrames[i]:SetScript("OnEnter", UnitFrame_OnEnter)
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

		LunaPartyFrames[i].AuraAnchor = CreateFrame("Frame", nil, LunaPartyFrames[i])
		
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
		LunaPartyFrames[i].Buffs[1].stacks:SetFont(LunaOptions.font, LunaOptions.fontHeight)
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
			LunaPartyFrames[i].Buffs[z].stacks:SetFont(LunaOptions.font, LunaOptions.fontHeight)
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
		LunaPartyFrames[i].Debuffs[1].stacks:SetFont(LunaOptions.font, LunaOptions.fontHeight)
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
			LunaPartyFrames[i].Debuffs[z].stacks:SetFont(LunaOptions.font, LunaOptions.fontHeight)
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
		LunaPartyFrames[i].incHeal:SetStatusBarTexture(LunaOptions.statusbartexture)
		LunaPartyFrames[i].incHeal:SetMinMaxValues(0, 1)
		LunaPartyFrames[i].incHeal:SetValue(1)
		LunaPartyFrames[i].incHeal:SetStatusBarColor(0, 1, 0, 0.6)

	-- Healthbar background
		LunaPartyFrames[i].bars["Healthbar"].hpbg = LunaPartyFrames[i]:CreateTexture(nil, "BACKGROUND")
		LunaPartyFrames[i].bars["Healthbar"].hpbg:SetAllPoints(LunaPartyFrames[i].bars["Healthbar"])
		LunaPartyFrames[i].bars["Healthbar"].hpbg:SetTexture(.25,.25,.25,.25)

	-- Healthbar text
		LunaPartyFrames[i].bars["Healthbar"].hpp = LunaPartyFrames[i].bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaPartyFrames[i].bars["Healthbar"])
		LunaPartyFrames[i].bars["Healthbar"].hpp:SetPoint("RIGHT", -2, 0)
		LunaPartyFrames[i].bars["Healthbar"].hpp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].bars["Healthbar"].hpp:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].bars["Healthbar"].hpp:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].bars["Healthbar"].hpp:SetTextColor(1,1,1)
		LunaPartyFrames[i].bars["Healthbar"].hpp:SetJustifyH("RIGHT")
		LunaPartyFrames[i].bars["Healthbar"].hpp:SetJustifyV("MIDDLE")

		LunaPartyFrames[i].name = LunaPartyFrames[i].bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaPartyFrames[i].bars["Healthbar"])
		LunaPartyFrames[i].name:SetPoint("LEFT", 2, 0)
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
		LunaPartyFrames[i].bars["Powerbar"].ppp:SetPoint("RIGHT", -2, 0)
		LunaPartyFrames[i].bars["Powerbar"].ppp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].bars["Powerbar"].ppp:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].bars["Powerbar"].ppp:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].bars["Powerbar"].ppp:SetTextColor(1,1,1)
		LunaPartyFrames[i].bars["Powerbar"].ppp:SetJustifyH("RIGHT")

		LunaPartyFrames[i].lvl = LunaPartyFrames[i].bars["Powerbar"]:CreateFontString(nil, "OVERLAY")
		LunaPartyFrames[i].lvl:SetPoint("LEFT", LunaPartyFrames[i].bars["Powerbar"], "LEFT", 2, 0)
		LunaPartyFrames[i].lvl:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPartyFrames[i].lvl:SetShadowColor(0, 0, 0)
		LunaPartyFrames[i].lvl:SetShadowOffset(0.8, -0.8)
		LunaPartyFrames[i].lvl:SetText(UnitLevel("party"..i))
		local color = GetDifficultyColor(UnitLevel("party"..i))
		LunaPartyFrames[i].lvl:SetVertexColor(color.r, color.g, color.b)

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
	if not LunaOptions.BlizzParty then
		LunaUnitFrames.RaidOptionsFrame_UpdatePartyFrames = RaidOptionsFrame_UpdatePartyFrames
		RaidOptionsFrame_UpdatePartyFrames = function () end
		for i=1,4 do
			local frame = getglobal("PartyMemberFrame"..i)
			frame:UnregisterAllEvents()
			frame:Hide()
		end
	end
	SetIconPositions()
	LunaUnitFrames:UpdatePartyUnitFrameSize()
	LunaUnitFrames:UpdatePartyPosition()
	LunaUnitFrames:UpdatePartyFrames()
	LunaUnitFrames:UpdatePartyBuffSize()
	GrpRangeCheck:SetScript("OnUpdate", GrpRangeCheck.onUpdate)
	AceEvent:RegisterEvent("HealComm_Healupdate" , LunaUnitFrames.PartyUpdateHeal)
end

local function updateBuffs()
	for i=1,4 do
		local pos
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
				if not pos then
					pos = z
				end
			end
			LunaPartyFrames[i].Buffs[z]:SetNormalTexture(LunaPartyFrames[i].Buffs[z].texturepath)
		end
		if not pos then
			pos = 17
		end
		LunaPartyFrames[i].AuraAnchor:SetHeight((LunaPartyFrames[i].Buffs[1]:GetHeight()*math.ceil((pos-1)/(LunaOptions.frames["LunaPartyFrames"].BuffInRow or 16)))+(math.ceil((pos-1)/(LunaOptions.frames["LunaPartyFrames"].BuffInRow or 16))-1)+1.1)
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

function LunaUnitFrames:UpdatePartyBuffSize()
	local buffcount = LunaOptions.frames["LunaPartyFrames"].BuffInRow or 16
	for id=1,4 do
		if LunaOptions.frames["LunaPartyFrames"].ShowBuffs == 1 then
			LunaPartyFrames[id]:UnregisterEvent("UNIT_AURA")
			for i=1, 16 do
				LunaPartyFrames[id].Buffs[i]:Hide()
				LunaPartyFrames[id].Debuffs[i]:Hide()
			end
		elseif LunaOptions.frames["LunaPartyFrames"].ShowBuffs == 2 then
			local buffsize = ((LunaPartyFrames[id]:GetWidth()-(buffcount-1))/buffcount)
			LunaPartyFrames[id]:RegisterEvent("UNIT_AURA")
			LunaPartyFrames[id].AuraAnchor:ClearAllPoints()
			LunaPartyFrames[id].AuraAnchor:SetPoint("BOTTOMLEFT", LunaPartyFrames[id], "TOPLEFT", -1, 3)
			LunaPartyFrames[id].AuraAnchor:SetWidth(LunaPartyFrames[id]:GetWidth())
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaPartyFrames[id].Buffs[buffid]:ClearAllPoints()
					LunaPartyFrames[id].Buffs[buffid]:SetPoint("BOTTOMLEFT", LunaPartyFrames[id].AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row)
					LunaPartyFrames[id].Buffs[buffid]:SetHeight(buffsize)
					LunaPartyFrames[id].Buffs[buffid]:SetWidth(buffsize)
					LunaPartyFrames[id].Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaPartyFrames[id].Debuffs[buffid]:ClearAllPoints()
					LunaPartyFrames[id].Debuffs[buffid]:SetPoint("BOTTOMLEFT", LunaPartyFrames[id].AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row)
					LunaPartyFrames[id].Debuffs[buffid]:SetHeight(buffsize)
					LunaPartyFrames[id].Debuffs[buffid]:SetWidth(buffsize)
					LunaPartyFrames[id].Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			updateBuffs()
		elseif LunaOptions.frames["LunaPartyFrames"].ShowBuffs == 3 then
			local buffsize = ((LunaPartyFrames[id]:GetWidth()-(buffcount-1))/buffcount)
			LunaPartyFrames[id]:RegisterEvent("UNIT_AURA")
			LunaPartyFrames[id].AuraAnchor:ClearAllPoints()
			LunaPartyFrames[id].AuraAnchor:SetWidth(LunaPartyFrames[id]:GetWidth())
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaPartyFrames[id].Buffs[buffid]:ClearAllPoints()
					LunaPartyFrames[id].Buffs[buffid]:SetPoint("TOPLEFT", LunaPartyFrames[id].AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaPartyFrames[id].Buffs[buffid]:SetHeight(buffsize)
					LunaPartyFrames[id].Buffs[buffid]:SetWidth(buffsize)
					LunaPartyFrames[id].Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaPartyFrames[id].Debuffs[buffid]:ClearAllPoints()
					LunaPartyFrames[id].Debuffs[buffid]:SetPoint("TOPLEFT", LunaPartyFrames[id].AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaPartyFrames[id].Debuffs[buffid]:SetHeight(buffsize)
					LunaPartyFrames[id].Debuffs[buffid]:SetWidth(buffsize)
					LunaPartyFrames[id].Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaPartyFrames[id].AuraAnchor:SetPoint("TOPLEFT", LunaPartyFrames[id], "BOTTOMLEFT", -1, -3)
			updateBuffs()
		elseif LunaOptions.frames["LunaPartyFrames"].ShowBuffs == 4 then
			local buffsize = (((LunaPartyFrames[id]:GetHeight()/2)-(math.ceil(16/buffcount)-1))/math.ceil(16/buffcount))
			LunaPartyFrames[id]:RegisterEvent("UNIT_AURA")
			LunaPartyFrames[id].AuraAnchor:ClearAllPoints()
			LunaPartyFrames[id].AuraAnchor:SetWidth((buffsize*buffcount)+(buffcount-1))
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaPartyFrames[id].Buffs[buffid]:ClearAllPoints()
					LunaPartyFrames[id].Buffs[buffid]:SetPoint("TOPRIGHT", LunaPartyFrames[id].AuraAnchor, "TOPRIGHT", ((z-1)*(buffsize+1))*(-1), (buffsize+1)*row*(-1))
					LunaPartyFrames[id].Buffs[buffid]:SetHeight(buffsize)
					LunaPartyFrames[id].Buffs[buffid]:SetWidth(buffsize)
					LunaPartyFrames[id].Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaPartyFrames[id].Debuffs[buffid]:ClearAllPoints()
					LunaPartyFrames[id].Debuffs[buffid]:SetPoint("TOPRIGHT", LunaPartyFrames[id].AuraAnchor, "BOTTOMRIGHT", ((z-1)*(buffsize+1))*(-1), (buffsize+1)*row*(-1))
					LunaPartyFrames[id].Debuffs[buffid]:SetHeight(buffsize)
					LunaPartyFrames[id].Debuffs[buffid]:SetWidth(buffsize)
					LunaPartyFrames[id].Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaPartyFrames[id].AuraAnchor:SetPoint("TOPRIGHT", LunaPartyFrames[id], "TOPLEFT", -3, 0)
			updateBuffs()
		else
			local buffsize = (((LunaPartyFrames[id]:GetHeight()/2)-(math.ceil(16/buffcount)-1))/math.ceil(16/buffcount))
			LunaPartyFrames[id]:RegisterEvent("UNIT_AURA")
			LunaPartyFrames[id].AuraAnchor:ClearAllPoints()
			LunaPartyFrames[id].AuraAnchor:SetWidth((buffsize*buffcount)+(buffcount-1))
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaPartyFrames[id].Buffs[buffid]:ClearAllPoints()
					LunaPartyFrames[id].Buffs[buffid]:SetPoint("TOPLEFT", LunaPartyFrames[id].AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaPartyFrames[id].Buffs[buffid]:SetHeight(buffsize)
					LunaPartyFrames[id].Buffs[buffid]:SetWidth(buffsize)
					LunaPartyFrames[id].Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaPartyFrames[id].Debuffs[buffid]:ClearAllPoints()
					LunaPartyFrames[id].Debuffs[buffid]:SetPoint("TOPLEFT", LunaPartyFrames[id].AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaPartyFrames[id].Debuffs[buffid]:SetHeight(buffsize)
					LunaPartyFrames[id].Debuffs[buffid]:SetWidth(buffsize)
					LunaPartyFrames[id].Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaPartyFrames[id].AuraAnchor:SetPoint("TOPLEFT", LunaPartyFrames[id], "TOPRIGHT", 3, 0)
			updateBuffs()
		end
	end
end

function LunaUnitFrames.PartyUpdateHeal(target)
	for i=1,4 do
		if UnitName("party"..i) == target or target == nil then
			local healed = HealComm:getHeal(UnitName("party"..i))
			local health, maxHealth = UnitHealth(LunaPartyFrames[i].unit), UnitHealthMax(LunaPartyFrames[i].unit)
			if( healed > 0 and (health < maxHealth or (LunaOptions.overheal or 20) > 0 )) then
				LunaPartyFrames[i].incHeal:Show()
				local healthWidth = LunaPartyFrames[i].bars["Healthbar"]:GetWidth() * (health / maxHealth)
				local incWidth = LunaPartyFrames[i].bars["Healthbar"]:GetWidth() * (healed / maxHealth)
				if( (healthWidth + incWidth) > (LunaPartyFrames[i].bars["Healthbar"]:GetWidth() * (1+((LunaOptions.overheal or 20)/100))) ) then
					incWidth = LunaPartyFrames[i].bars["Healthbar"]:GetWidth() * (1+((LunaOptions.overheal or 20)/100)) - healthWidth
				end
				LunaPartyFrames[i].incHeal:SetWidth(incWidth)
				LunaPartyFrames[i].incHeal:SetHeight(LunaPartyFrames[i].bars["Healthbar"]:GetHeight())
				LunaPartyFrames[i].incHeal:ClearAllPoints()
				LunaPartyFrames[i].incHeal:SetPoint("TOPLEFT", LunaPartyFrames[i].bars["Healthbar"], "TOPLEFT", healthWidth, 0)
			else
				LunaPartyFrames[i].incHeal:Hide()
			end
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
		LunaUnitFrames.PartyUpdateHeal(UnitName(LunaPartyFrames[i].unit))
		local healthheight = (LunaPartyFrames[i].bars["Healthbar"]:GetHeight()/23.4)*11
		if healthheight > 0 then
			LunaPartyFrames[i].bars["Healthbar"].hpp:SetFont(LunaOptions.font, healthheight)
			LunaPartyFrames[i].bars["Healthbar"].hpp:SetHeight(LunaPartyFrames[i].bars["Healthbar"]:GetHeight())
			LunaPartyFrames[i].bars["Healthbar"].hpp:SetWidth(LunaPartyFrames[i].bars["Healthbar"]:GetWidth()*0.45)
			LunaPartyFrames[i].name:SetFont(LunaOptions.font, healthheight)
			LunaPartyFrames[i].name:SetHeight(healthheight)
			LunaPartyFrames[i].name:SetWidth(LunaPartyFrames[i].bars["Healthbar"]:GetWidth()*0.55)
		end
		if LunaPartyFrames[i].bars["Healthbar"]:GetHeight() < 6 then
			LunaPartyFrames[i].bars["Healthbar"].hpp:Hide()
			LunaPartyFrames[i].name:Hide()
		else
			LunaPartyFrames[i].bars["Healthbar"].hpp:Show()
			LunaPartyFrames[i].name:Show()
		end
		local powerheight = (LunaPartyFrames[i].bars["Powerbar"]:GetHeight()/23.4)*11
		if powerheight > 0 then
			LunaPartyFrames[i].bars["Powerbar"].ppp:SetFont(LunaOptions.font, powerheight)
			LunaPartyFrames[i].lvl:SetFont(LunaOptions.font, powerheight)
			LunaPartyFrames[i].class:SetFont(LunaOptions.font, powerheight)
		end
		if LunaPartyFrames[i].bars["Powerbar"]:GetHeight() < 6 then
			LunaPartyFrames[i].bars["Powerbar"].ppp:Hide()
			LunaPartyFrames[i].lvl:Hide()
			LunaPartyFrames[i].class:Hide()
		else
			LunaPartyFrames[i].bars["Powerbar"].ppp:Show()
			LunaPartyFrames[i].lvl:Show()
			LunaPartyFrames[i].class:Show()
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
			
			if(LunaPartyFrames[i].bars["Portrait"].type == "3D") then
				if(not UnitExists(LunaPartyFrames[i].unit) or not UnitIsConnected(LunaPartyFrames[i].unit) or not UnitIsVisible(LunaPartyFrames[i].unit)) then
					LunaPartyFrames[i].bars["Portrait"]:SetModelScale(4.25)
					LunaPartyFrames[i].bars["Portrait"]:SetPosition(0, 0, -1)
					LunaPartyFrames[i].bars["Portrait"]:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
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
				LunaPartyFrames[i].bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaPartyFrames[i].unit))
			elseif UnitHealth(LunaPartyFrames[i].unit) < 2 then
				LunaPartyFrames[i].bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Healthbar"]:SetValue(0)
				LunaPartyFrames[i].bars["Healthbar"].hpp:SetText("DEAD")
			
				LunaPartyFrames[i].bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Powerbar"]:SetValue(0)
				LunaPartyFrames[i].bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaPartyFrames[i].unit))
			else
				LunaPartyFrames[i].bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Healthbar"]:SetValue(UnitHealth(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Healthbar"].hpp:SetText(LunaUnitFrames:GetHealthString(LunaPartyFrames[i].unit))
			
				LunaPartyFrames[i].bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Powerbar"]:SetValue(UnitMana(LunaPartyFrames[i].unit))
				LunaPartyFrames[i].bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaPartyFrames[i].unit))
			end
			

			local color
			local _,class = UnitClass(LunaPartyFrames[i].unit)
			if UnitIsConnected(LunaPartyFrames[i].unit) then
				color = LunaOptions.ClassColors[class]
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
			else
				LunaPartyFrames[i].bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
				LunaPartyFrames[i].bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
			end
			
			LunaPartyFrames[i].name:SetText(UnitName(LunaPartyFrames[i].unit))
			LunaPartyFrames[i].class:SetText(UnitClass(LunaPartyFrames[i].unit))
			local difcolor = GetDifficultyColor(UnitLevel(LunaPartyFrames[i].unit))
			LunaPartyFrames[i].lvl:SetVertexColor(difcolor.r, difcolor.g, difcolor.b)
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
			LunaUnitFrames.PartyUpdateHeal(UnitName("party"..i))
		else
			LunaPartyFrames[i]:Hide()
		end
	end
	updateBuffs()
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
		local pos
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
				if not pos then
					pos = i
				end
			end
			this.Buffs[i]:SetNormalTexture(this.Buffs[i].texturepath)
		end
		if not pos then
			pos = 17
		end
		this.AuraAnchor:SetHeight((this.Buffs[1]:GetHeight()*math.ceil((pos-1)/(LunaOptions.frames["LunaPartyFrames"].BuffInRow or 16)))+(math.ceil((pos-1)/(LunaOptions.frames["LunaPartyFrames"].BuffInRow or 16))-1)+1.1)
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
		LunaUnitFrames.PartyUpdateHeal(UnitName(arg1))
		this.bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(this.unit))
		this.bars["Healthbar"]:SetValue(UnitHealth(this.unit))
		this.bars["Healthbar"].hpp:SetText(LunaUnitFrames:GetHealthString(this.unit))
		if (UnitIsDead(this.unit) or UnitIsGhost(this.unit)) then			-- This prevents negative health
			this.bars["Healthbar"]:SetValue(0)
		end
		local color
		local _,class = UnitClass(this.unit)
		if not UnitIsConnected(this.unit) then
			color = LunaOptions.MiscColors["offline"]
			this.bars["Healthbar"].hpp:SetText("OFFLINE")
		elseif UnitHealth(this.unit) < 2 then
			color = LunaOptions.MiscColors["offline"]
			this.bars["Healthbar"].hpp:SetText("DEAD")
		else
			color = LunaOptions.ClassColors[class]
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
			this.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(this.unit))
		else
			this.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(this.unit))
			this.bars["Powerbar"]:SetValue(UnitMana(this.unit))
			this.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(this.unit))
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
		local power = UnitPowerType(arg1)
		
		if power == 1 then
			this.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
			this.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
		elseif power == 3 then
			this.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
			this.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
		else
			this.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
			this.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
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
		local color = GetDifficultyColor(lvl)
		this.lvl:SetVertexColor(color.r, color.g, color.b)
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
				portrait:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
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