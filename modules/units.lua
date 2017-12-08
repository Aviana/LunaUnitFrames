local LunaUF = LunaUF
local L = LunaUF.L
local Units = {headerFrames = {}, unitFrames = {}, frameList = {}, childframeList = {}}
local unitFrames, headerFrames, frameList, childframeList = Units.unitFrames, Units.headerFrames, Units.frameList, Units.childframeList
local UnitWatch = CreateFrame("Frame")
UnitWatch.time = 0
local RaidRoster = {}
local GroupRoster = {}
local RaidPetRoster = {}
local PartyPetRoster = {}
local numPets = 0
local currPet
local PetRosterChanged
local PetExists
LunaUF.Units = Units
LunaUF.Units.UnitWatch = UnitWatch

-- Frame shown, do a full update
local function FullUpdate(frame)
	if Units.pauseUpdates and strsub(frame.unit,1,6) == "target" then return end
	local config = LunaUF.db.profile.units[frame.unitGroup]
	for key,_ in pairs(LunaUF.modules) do
		if config[key] and config[key].enabled and frame[key] then
			LunaUF.modules[key]:FullUpdate(frame)
		end
	end
end

LunaUF.Units.FullUpdate = FullUpdate

--UnitWatch
local function UnitWatchOnUpdate()
	this.time = this.time+arg1
	if this.time > 0.2 and not Units.pauseUpdates then
		this.time = 0
		for _,frame in pairs(childframeList) do
			if frame.parentunit and UnitExists(frame.parentunit) and frame.UnitExists(frame.unit) and LunaUF.db.profile.units[frame.unitGroup].enabled then
				if not frame:IsShown() then
					frame:Show()
				else
					FullUpdate(frame)
				end
			elseif frame:IsShown() and (LunaUF.db.profile.locked or not LunaUF.db.profile.units[frame.unitGroup].enabled) then
				frame:Hide()
			end
		end
		numPets = 0
		PetRosterChanged = nil
		if LunaUF.db.profile.units.raid.petgrp then
			if UnitInRaid("player") then
				for i=1, 40 do
					currPet = "raidpet"..i
					if UnitIsVisible(currPet) then
						if not RaidPetRoster[currPet] then
							RaidPetRoster[currPet] = true
							PetRosterChanged = true
						end
						numPets = numPets + 1
					else
						if RaidPetRoster[currPet] then
							RaidPetRoster[currPet] = nil
							PetRosterChanged = true
						end
					end
				end
			elseif GetNumPartyMembers() > 0 then
				for i=1, 4 do
					currPet = "partypet"..i
					if UnitIsVisible(currPet) then
						if not PartyPetRoster[currPet] then
							PartyPetRoster[currPet] = true
							PetRosterChanged = true
						end
						numPets = numPets + 1
					else
						if PartyPetRoster[currPet] then
							PartyPetRoster[currPet] = nil
							PetRosterChanged = true
						end
					end
				end
				if UnitExists("pet") then
					numPets = numPets + 1
					if not PartyPetRoster["pet"] then
						PartyPetRoster["pet"] = true
						PetRosterChanged = true
					end
				else
					if PartyPetRoster["pet"] then
						PartyPetRoster["pet"] = nil
						PetRosterChanged = true
					end
				end
			else
				if UnitExists("pet") then
					numPets = 1
					if not PetExists then
						PetExists = true
						PetRosterChanged = true
					end
				else
					if PetExists then
						PetExists = nil
						PetRosterChanged = true
					end
				end
			end
		end
		if PetRosterChanged and headerFrames["raid9"] then
			headerFrames["raid9"].Update(headerFrames["raid9"])
		end
	end
end

local function UnitWatchOnEvent()
	if event == "PLAYER_TARGET_CHANGED" and LunaUF.db.profile.units.target.enabled then
		local frame = unitFrames.target
		if UnitExists("target") and LunaUF.db.profile.units.target.enabled then
			if not frame:IsShown() then
				frame:Show()
			else
				FullUpdate(frame)
			end
		elseif frame:IsShown() and LunaUF.db.profile.locked then
			frame:Hide()
		end
	elseif event == "UNIT_PET" and arg1 == "player" then
		if unitFrames["pet"] then
			if UnitExists(unitFrames["pet"].unit) and not unitFrames["pet"]:IsShown() then
				unitFrames["pet"]:Show()
			elseif not UnitExists(unitFrames["pet"].unit) and unitFrames["pet"]:IsShown() and LunaUF.db.profile.locked then
				unitFrames["pet"]:Hide()
			end
			if unitFrames["pet"]:IsShown() then
				FullUpdate(unitFrames["pet"])
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		for _, type in pairs(LunaUF.unitList) do
			LunaUF.Units:InitializeFrame(type)
		end
		if (LunaUF.db.profile.version or 0 > LunaUF.Version) then
			SendAddonMessage("LUF", LunaUF.db.profile.version, "GUILD")
			SendAddonMessage("LUF", LunaUF.db.profile.version, "RAID")
		else
			SendAddonMessage("LUF", LunaUF.Version, "GUILD")
			SendAddonMessage("LUF", LunaUF.Version, "RAID")
		end
	elseif event == "CHAT_MSG_ADDON" and arg1 == "LUF" then
		if tonumber(arg2) > (LunaUF.db.profile.version or LunaUF.Version) then
			LunaUF.db.profile.version = tonumber(arg2)
			LunaOptionsFrame.version:SetTextColor(1,0,0)
			LunaOptionsFrame.version:SetText("V."..LunaUF.Version.." Beta (Outdated)")
		end
	end
end

UnitWatch:RegisterEvent("UNIT_PET")
UnitWatch:RegisterEvent("PLAYER_TARGET_CHANGED")
UnitWatch:RegisterEvent("PLAYER_ENTERING_WORLD") --???
UnitWatch:SetScript("OnEvent", UnitWatchOnEvent)
UnitWatch:SetScript("OnUpdate", UnitWatchOnUpdate)
--

-- Show tooltip
local function OnEnter()
	if this.unit and LunaUF.db.profile.tooltips then
		if not GameTooltip.orgSetUnit then
			if ( SpellIsTargeting() ) then
				if ( SpellCanTargetUnit(this.unit) ) then
					SetCursor("CAST_CURSOR")
				else
					SetCursor("CAST_ERROR_CURSOR")
				end
			end
			if( LunaUF.db.profile.tooltipCombat and UnitAffectingCombat("player") ) then return end
			GameTooltip_SetDefaultAnchor(GameTooltip, this)
			GameTooltip:SetUnit(this.unit)
			local r, g, b = GameTooltip_UnitColor(this.unit)
			GameTooltipTextLeft1:SetTextColor(r, g, b)
		else
			UnitFrame_OnEnter()
		end
	end
end

local function OnLeave()
	if not GameTooltip.orgSetUnit then
		if ( SpellIsTargeting() ) then
			SetCursor("CAST_ERROR_CURSOR")
		end
		GameTooltip:FadeOut()
	else
		UnitFrame_OnLeave()
	end
end

-- Event handling
local function OnEvent()
	if UnitExists(this.unit) and this:IsShown() then
		this.FullUpdate(this)
	end
end

Units.OnEvent = OnEvent

-- Do a full update OnShow, and stop watching for events when it's not visible
local function OnShow()
	-- Reset the event handler
	this:SetScript("OnEvent", OnEvent)
	this:FullUpdate(this)
end

local function OnHide()
	this:SetScript("OnEvent", nil)
end

local function initPlayerDrop()
	UnitPopup_ShowMenu(PlayerFrameDropDown, "SELF", "player")
	if not (UnitInRaid("player") or GetNumPartyMembers() > 0) or UnitIsPartyLeader("player") and PlayerFrameDropDown.init and not CanShowResetInstances() then
		UIDropDownMenu_AddButton({text = RESET_INSTANCES, func = ResetInstances, notCheckable = 1}, 1)
		PlayerFrameDropDown.init = nil
	end
end

local function ShowMenu()
	if( UnitIsUnit(this.unit, "player") ) then
		UIDropDownMenu_Initialize(PlayerFrameDropDown, initPlayerDrop, "MENU")
		PlayerFrameDropDown.init = true
		ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "cursor")
	elseif( this.unit == "pet" ) then
		ToggleDropDownMenu(1, nil, PetFrameDropDown, "cursor")
	elseif( this.unit == "target" ) then
		ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
	elseif( this.unitGroup == "party" ) then
		ToggleDropDownMenu(1, nil, getglobal("PartyMemberFrame" .. string.sub(this.unit,6) .. "DropDown"), "cursor")
	elseif( this.unitGroup == "raid" ) then
		HideDropDownMenu(1)
		local name = UnitName(this.unit)
		local id = string.sub(this.unit,5)
		local unit = this.unit
		local menuFrame = FriendsDropDown
		menuFrame.displayMode = "MENU"
		menuFrame.initialize = function() UnitPopup_ShowMenu(getglobal(UIDROPDOWNMENU_OPEN_MENU), "PARTY", unit, name, id) end
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
	end
end

local function OnClick()
	if arg1 == "UNKNOWN" then
		arg1 = LunaUF.clickedButton
	end
	if Luna_Custom_ClickFunction and Luna_Custom_ClickFunction(arg1, this.unit) then
		return;
	else
		local button = (IsControlKeyDown() and "Ctrl-" or "") .. (IsShiftKeyDown() and "Shift-" or "") .. (IsAltKeyDown() and "Alt-" or "") .. L[arg1]
		local action = LunaUF.db.profile.clickcasting.bindings[button]
		if not action then
			return
		elseif action == L["menu"] then
			if SpellIsTargeting() then
				SpellStopTargeting()
				return;
			else
				this:ShowMenu()
			end
		elseif action == L["target"] then
			if SpellIsTargeting() then
				SpellTargetUnit(this.unit)
			elseif CursorHasItem() then
				DropItemOnUnit(this.unit)
			else
				TargetUnit(this.unit)
			end
		else
			LunaUF:Mouseover(action)
		end
	end
end

local function StartMoving()
	this:StartMoving()
end

local function StopMovingOrSizing()
	local scale = this:GetScale() * UIParent:GetScale()
	local _, _, _, x, y = this:GetPoint()
	this:StopMovingOrSizing()
	LunaUF.db.profile.units[this.unitGroup].position.x = x * scale
	LunaUF.db.profile.units[this.unitGroup].position.y = y * scale
	for i=2,6 do
		if LunaOptionsFrame.pages[i].id == this.unitGroup then
			LunaOptionsFrame.pages[i].xInput:SetText(x * scale)
			LunaOptionsFrame.pages[i].yInput:SetText(y * scale)
		end
	end
end

local function HeaderStartMoving()
	if LunaUF.db.profile.units.raid.interlock and this.unitGroup == "raid" then
		headerFrames.raid1:StartMoving()
	else
		this:GetParent():StartMoving()
	end
end

local function GroupHeaderStopMovingOrSizing()
	this:GetParent():StopMovingOrSizing()
	local unit = this:GetParent().unitGroup
	local x,y
	x = this:GetParent():GetLeft()
	y = (UIParent:GetHeight()/UIParent:GetScale()-this:GetParent():GetTop()) * -1
	LunaUF.db.profile.units[this:GetParent().unitGroup].position.x = x
	LunaUF.db.profile.units[this:GetParent().unitGroup].position.y = y
	for i=7,9 do
		if LunaOptionsFrame.pages[i].id == unit then
			LunaOptionsFrame.pages[i].xInput:SetText(x)
			LunaOptionsFrame.pages[i].yInput:SetText(y)
		end
	end
end

local function RaidHeaderStopMovingOrSizing()
	local x,y
	if LunaUF.db.profile.units.raid.interlock then
		headerFrames.raid1:StopMovingOrSizing()
		for i=1,9 do
			x = headerFrames["raid"..i]:GetLeft()
			y = (UIParent:GetHeight()/UIParent:GetScale()-headerFrames["raid"..i]:GetTop()) * -1
			LunaUF.db.profile.units.raid[i].position.x = x
			LunaUF.db.profile.units.raid[i].position.y = y
			if UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect) == i then
				LunaOptionsFrame.pages[11].xInput:SetText(x)
				LunaOptionsFrame.pages[11].yInput:SetText(y)
			end
		end
	else
		this:GetParent():StopMovingOrSizing()
		x = this:GetParent():GetLeft()
		y = (UIParent:GetHeight()/UIParent:GetScale()-this:GetParent():GetTop()) * -1
		LunaUF.db.profile.units.raid[this:GetParent().id].position.x = x
		LunaUF.db.profile.units.raid[this:GetParent().id].position.y = y
		if UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect) == this:GetParent().id then
			LunaOptionsFrame.pages[11].xInput:SetText(x)
			LunaOptionsFrame.pages[11].yInput:SetText(y)
		end
	end
end

local function SetupGroupHeader(groupType)
	local unitGroup = groupType or this.unitGroup
	local config = LunaUF.db.profile.units.party
	local header = headerFrames[unitGroup]
	if UnitInRaid("player") and not config.inraid then
		header:Hide()
		return
	else
		header:Show()
	end
	local point = LunaUF.constants.AnchorPoint[config.growth]
	local framesneeded = config.enabled and ((LunaUF.db.profile.locked and GetNumPartyMembers() or 4) + (config.player and 1 or 0)) or 0
	if framesneeded == 1 and config.player then
		framesneeded = 0
	end
	for i=getn(header.frames)+1, framesneeded do
		header.frames[i] = Units:CreateUnit("Button", "LUFUnit"..unitGroup..i, header)
		header.frames[i]:SetScript("OnDragStop", GroupHeaderStopMovingOrSizing)
		header.frames[i].unitGroup = unitGroup
		if unitGroup ~= "party" then
			table.insert(childframeList, header.frames[i])
		end
		if unitGroup ~= "partypet" then
			header.frames[i].UnitExists = UnitExists
		else
			header.frames[i].UnitExists = UnitIsVisible
		end
	end

	--Generate Group Table
	while getn(GroupRoster) > 0 do
		table.remove(GroupRoster)
	end
	for i=1, 4 do
		local unit = "party"..i
		if UnitExists(unit) then
			table.insert(GroupRoster,{UnitName(unit), unit})
		end
	end
	if config.sortby == "NAME" then
		if config.player then
			table.insert(GroupRoster,{UnitName("player"),"player"})
		end
		if config.order == "ASC" then
			table.sort(GroupRoster, function (a,b) return a[1]<b[1] end)
		else
			table.sort(GroupRoster, function (a,b) return a[1]>b[1] end)
		end
	else
		if config.order ~= "ASC" then
			table.sort(GroupRoster, function (a,b) return a[2]>b[2] end)
			if config.player then
				table.insert(GroupRoster,{UnitName("player"),"player"})
			end
		else
			if config.player then
				table.insert(GroupRoster,1,{UnitName("player"),"player"})
			end
		end
	end

	local anchor = header

	local xoffset
	if config.growth == "RIGHT" or config.growth == "LEFT" then
		xoffset = ((config.growth == "RIGHT" and 1 or -1) * (LunaUF.db.profile.units.party.size.x + LunaUF.db.profile.units.party.padding))
	else
		xoffset = 0
	end

	local yoffset
	if config.growth == "UP" or config.growth == "DOWN" then
		yoffset = ((config.growth == "UP" and 1 or -1) * (LunaUF.db.profile.units.party.size.y + LunaUF.db.profile.units.party.padding))
	else
		yoffset = 0
	end

	for i,frame in pairs(header.frames) do
		if i > framesneeded then
			frame.parentunit = nil
			frame:Hide()
		else
			if unitGroup == "party" then
				frame:Show()
			end
			frame:ClearAllPoints()
			frame:SetPoint(point, anchor, point, i>1 and xoffset, i>1 and yoffset)
			frame:SetWidth(LunaUF.db.profile.units[unitGroup].size.x)
			frame:SetHeight(LunaUF.db.profile.units[unitGroup].size.y)
			frame:SetScale(LunaUF.db.profile.units[unitGroup].scale)
			if not LunaUF.db.profile.locked then
				frame.unit = "player"
				frame.parentunit = "player"
				frame:SetScript("OnDragStart", HeaderStartMoving)
			else
				if unitGroup == "partytarget" then
					frame.unit = GroupRoster[i][2].."target"
					frame.parentunit = GroupRoster[i][2]
				elseif unitGroup == "partypet" and GroupRoster[i][2] ~= "player" then
					frame.unit = "partypet"..string.sub(GroupRoster[i][2],6)
					frame.parentunit = GroupRoster[i][2]
				elseif unitGroup == "partypet" then
					frame.unit = "pet"
					frame.parentunit = "player"
				else
					frame.unit = GroupRoster[i][2]
					frame.parentunit = GroupRoster[i][2]
				end
				frame:SetScript("OnDragStart", nil)
			end
			Units:SetupFrameModules(frame)
			anchor = frame
		end
	end
end

local function SetupRaidHeader(passedHeader)
	local header
	local config = LunaUF.db.profile.units.raid
	if passedHeader then
		header = passedHeader
	else
		header = this
	end
	local point = LunaUF.constants.AnchorPoint[config.growth]
	local framesneeded = 0
	if header.id == 9 then
		if config.petgrp and (config.showalways or (config.showparty and GetNumPartyMembers() > 0) or UnitInRaid("player")) then
			framesneeded = not LunaUF.db.profile.locked and 5 or numPets
		else
			framesneeded = 0
		end
	elseif config.mode == "GROUP" then
		framesneeded = not LunaUF.db.profile.locked and 5 or RAID_SUBGROUP_LISTS and RAID_SUBGROUP_LISTS[header.id] and getn(RAID_SUBGROUP_LISTS[header.id]) or 0
	else
		framesneeded = not LunaUF.db.profile.locked and 5 or RAID_SUBGROUP_LISTS and RAID_SUBGROUP_LISTS[LunaUF.constants.RaidClassMapping[header.id]] and getn(RAID_SUBGROUP_LISTS[LunaUF.constants.RaidClassMapping[header.id]]) or 0
	end
	if not UnitInRaid("player") and header.id == 1 and LunaUF.db.profile.locked then
		if config.showalways or (config.showparty and GetNumPartyMembers() > 0) then
			framesneeded = GetNumPartyMembers() + 1
		end
	end
	for i=getn(header.frames)+1, framesneeded do
		header.frames[i] = Units:CreateUnit("Button", "LUFUnitraid"..header.id.."member"..i, header)
		header.frames[i]:SetScript("OnDragStop", RaidHeaderStopMovingOrSizing)
		header.frames[i].unitGroup = "raid"
	end

	--Generate RaidGroup Table
	while getn(RaidRoster) > 0 do
		table.remove(RaidRoster)
	end
	if header.id == 9 and framesneeded > 0 then
		if UnitInRaid("player") then
			for unitid,_ in pairs(RaidPetRoster) do
				if UnitName(unitid) then
					table.insert(RaidRoster,{UnitName(unitid),unitid})
				end
			end
		elseif GetNumPartyMembers() > 0 then
			for unitid,_ in pairs(PartyPetRoster) do
				if UnitName(unitid) then
					table.insert(RaidRoster,{UnitName(unitid),unitid})
				end
			end
		elseif PetExists and UnitName("pet") then
			table.insert(RaidRoster,{UnitName("pet"),"pet"})
		end
		if framesneeded > getn(RaidRoster) then
			framesneeded = getn(RaidRoster)
		end
	elseif LunaUF.db.profile.locked and framesneeded > 0 and UnitInRaid("player") then
		if config.mode == "GROUP" and RAID_SUBGROUP_LISTS[header.id] then
			for _,v in pairs(RAID_SUBGROUP_LISTS[header.id]) do
				table.insert(RaidRoster,{UnitName("raid"..v),"raid"..v})
			end
		elseif RAID_SUBGROUP_LISTS[LunaUF.constants.RaidClassMapping[header.id]] and framesneeded > 0 then
			for _,v in pairs(RAID_SUBGROUP_LISTS[LunaUF.constants.RaidClassMapping[header.id]]) do
				table.insert(RaidRoster,{UnitName("raid"..v),"raid"..v})
			end
		end
	elseif LunaUF.db.profile.locked and framesneeded > 0 then
		table.insert(RaidRoster,{UnitName("player"),"player"})
		for i=1, 4 do
			local unit = "party"..i
			if UnitExists(unit) then
				table.insert(RaidRoster,{UnitName(unit),unit})
			else
				break
			end
		end
	end

	local anchor = header
	local xoffset
	local yoffset

	if config.growth == "RIGHT" or config.growth == "LEFT" then
		xoffset = (config.growth == "LEFT" and 1 or -1)
	else
		xoffset = 0
	end

	if config.growth == "UP" or config.growth == "DOWN" then
		yoffset = (config.growth == "DOWN" and 1 or -1)
	else
		yoffset = 0
	end

	if framesneeded > 0 then
		if LunaUF.db.profile.units.raid.sortby == "NAME" then
			if LunaUF.db.profile.units.raid.order == "ASC" then
				table.sort(RaidRoster, function (a,b) return a[1]<b[1] end)
			else
				table.sort(RaidRoster, function (a,b) return a[1]>b[1] end)
			end
		else
			if LunaUF.db.profile.units.raid.order ~= "ASC" then
				table.sort(RaidRoster, function (a,b) return a[2]>b[2] end)
			else
				table.sort(RaidRoster, function (a,b) return a[2]<b[2] end)
			end
		end
		header.title:SetPoint("CENTER", header, "CENTER", 20*xoffset, 20*yoffset)
		local text = config.mode == "CLASS" and LunaUF.constants.RaidClassMapping[header.id] or ("GRP "..header.id)
		header.title:SetText(LunaUF.db.profile.units.raid.titles and text or "")
	else
		header.title:SetText("")
	end

	xoffset = xoffset * (config.size.x + config.padding) * -1
	yoffset = yoffset * (config.size.y + config.padding) * -1

	for i,frame in pairs(header.frames) do
		if i > framesneeded then
			frame:Hide()
		else
			frame:Show()
			frame:ClearAllPoints()
			frame:SetPoint(point, anchor, point, i>1 and xoffset, i>1 and yoffset)
			frame:SetWidth(config.size.x)
			frame:SetHeight(config.size.y)
			frame:SetScale(config.scale)
			if not LunaUF.db.profile.locked then
				frame.unit = "player"
				frame:SetScript("OnDragStart", HeaderStartMoving)
			else
				frame.unit = RaidRoster[i][2]
				frame:SetScript("OnDragStart", nil)
			end
			Units:SetupFrameModules(frame)
			anchor = frame
		end
	end
end

-- Create the generic things that we want in every frame regardless if it's a button or a header
function Units:CreateUnit(a1, a2, a3, a4)
	local frame = a2 and CreateFrame(a1, a2, a3, a4) or a1
	frame.FullUpdate = FullUpdate
	frame.ShowMenu = ShowMenu
	frame.topFrameLevel = 5

	frame.fontstrings = {}

	frame:SetScript("OnEvent", OnEvent)
	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)
	frame:SetScript("OnShow", OnShow)
	frame:SetScript("OnHide", OnHide)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStop", StopMovingOrSizing)

	frame:SetFrameStrata("BACKGROUND")
	frame:SetClampedToScreen(1)
	local click_action = LunaUF.db.profile.clickcasting.mouseDownClicks and "Down" or "Up"
	frame:RegisterForClicks('LeftButton' .. click_action, 'RightButton' .. click_action, 'MiddleButton' .. click_action, 'Button4' .. click_action, 'Button5' .. click_action)
	frame:SetScript("OnClick", OnClick)
	frame:SetBackdrop(LunaUF.constants.backdrop)
	frame:SetBackdropColor(LunaUF.db.profile.bgcolor.r,LunaUF.db.profile.bgcolor.g,LunaUF.db.profile.bgcolor.b,LunaUF.db.profile.bgalpha)

	table.insert(frameList,frame)
	return frame
end

-- Load a single unit such as player, target, pet, etc
function Units:LoadUnit(unit)
	local frame

	if( unitFrames[unit] ) then
		frame = unitFrames[unit]
	else
		frame = self:CreateUnit("Button", "LUFUnit" .. unit, UIParent)
		frame.unitGroup = unit
		frame.parentunit = unit
		frame.UnitExists = UnitExists
		unitFrames[unit] = frame
		if unit == "pettarget" or unit == "targettarget" or unit == "targettargettarget" then
			table.insert(childframeList,frame)
		end
	end

	-- And lets get this going

	frame:ClearAllPoints()
	frame:SetWidth(LunaUF.db.profile.units[frame.unitGroup].size.x)
	frame:SetHeight(LunaUF.db.profile.units[frame.unitGroup].size.y)
	frame:SetScale(LunaUF.db.profile.units[frame.unitGroup].scale)
	local scale = frame:GetScale() * UIParent:GetScale()
	frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaUF.db.profile.units[frame.unitGroup].position.x / scale, LunaUF.db.profile.units[frame.unitGroup].position.y / scale)

	if not LunaUF.db.profile.units[unit].enabled then
		frame:Hide()
		frame:UnregisterAllEvents()
		return
	elseif not LunaUF.db.profile.locked then
		frame:Show()
		frame:UnregisterAllEvents()
		frame:SetScript("OnDragStart", StartMoving)
		frame:SetMovable(1)
		frame.unit = "player"
	else
		if unit ~= "player" and not UnitExists(unit) then
			frame:Hide()
		else
			frame:Show()
		end
		if string.find(frame.unitGroup,"(target)") then
			frame:RegisterEvent("PLAYER_TARGET_CHANGED")
		end

		frame:SetScript("OnDragStart", nil)
		frame:SetMovable(0)
		frame.unit = frame.unitGroup
	end
	self:SetupFrameModules(frame)
end

function Units:LoadGroupHeader(unit)
	local header
	if not headerFrames[unit] then
		header = CreateFrame("Frame", "LUFHeader"..unit, UIParent)
		headerFrames[unit] = header
		header.frames = {}
		header.Update = SetupGroupHeader
		header.unitGroup = unit
		header:SetScript("OnEvent", SetupGroupHeader)
		header:RegisterEvent("PARTY_MEMBERS_CHANGED")
		header:RegisterEvent("RAID_ROSTER_UPDATE")
	else
		header = headerFrames[unit]
	end
	header:ClearAllPoints()
	header:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaUF.db.profile.units[unit].position.x, LunaUF.db.profile.units[unit].position.y)
	header:SetWidth(1)
	header:SetHeight(1)

	if not LunaUF.db.profile.units[unit].enabled then
		header:Hide()
	elseif not LunaUF.db.profile.locked then
		header:Show()
		header:SetMovable(1)
	else
		header:Show()
		header:SetMovable(0)
	end
	header.Update(unit)
end

function Units:LoadRaidGroupHeader()
	local header
	local config = LunaUF.db.profile.units.raid
	for i=1, 9 do
		if not headerFrames["raid"..i] then
			header = CreateFrame("Frame", "LUFHeaderraid"..i, UIParent)
			headerFrames["raid"..i] = header
			header:SetWidth(1)
			header:SetHeight(1)
			header.frames = {}
			header.Update = SetupRaidHeader
			header.id = i
			header.title = header:CreateFontString(nil, "ARTWORK")
			header.title:SetShadowColor(0, 0, 0, 1.0)
			header.title:SetShadowOffset(0.80, -0.80)
			header.title:SetFont(LunaUF.defaultFont, 14)
			header:SetScript("OnEvent", SetupRaidHeader)
			if header.id == 1 or header.id == 9 then
				header:RegisterEvent("PARTY_MEMBERS_CHANGED")
			end
			header:RegisterEvent("RAID_ROSTER_UPDATE")
		else
			header = headerFrames["raid"..i]
		end
		if not config.enabled then
			header:Hide()
		else
			header:Show()
		end
		header:ClearAllPoints()
		if config.interlock and header.id > 1 then
			if config.interlockgrowth == "RIGHT" then
				header:SetPoint("CENTER", headerFrames["raid"..(i-1)], "CENTER", (config.size.x + config.padding), 0)
			elseif config.interlockgrowth == "LEFT" then
				header:SetPoint("CENTER", headerFrames["raid"..(i-1)], "CENTER", -(config.size.x + config.padding), 0)
			elseif config.interlockgrowth == "UP" then
				header:SetPoint("CENTER", headerFrames["raid"..(i-1)], "CENTER", 0, (config.size.y + config.padding))
			else
				header:SetPoint("CENTER", headerFrames["raid"..(i-1)], "CENTER", 0, -(config.size.y + config.padding))
			end
		else
			header:SetPoint("TOPLEFT", UIParent, "TOPLEFT", config[header.id].position.x, config[header.id].position.y)
		end

		if not LunaUF.db.profile.locked then
			header:SetMovable(1)
		else
			header:SetMovable(0)
		end
		header.Update(header)
	end
end

function Units:PositionWidgets(frame)
	local config = LunaUF.db.profile.units[frame.unitGroup]
	if not config.enabled then return end
	local vertical = config.barorder.vertical
	local horizontal = config.barorder.horizontal
	local framelength = frame:GetWidth()
	local frameheight = frame:GetHeight()
	local barweightH = 0
	local barweightV = 0
	local xoffset = 0
	local yoffset = 0
	if config.portrait.enabled then
		if config.portrait.side == "left" then
			frame.portrait:ClearAllPoints()
			frame.portrait:SetPoint("TOPLEFT", frame, "TOPLEFT")
			frame.portrait:SetWidth(frame:GetHeight())
			frame.portrait:SetHeight(frame:GetHeight() + (config.portrait.type == "3D" and 1 or 0))
			framelength = framelength - frameheight
			xoffset = frameheight
		elseif config.portrait.side == "right" then
			frame.portrait:ClearAllPoints()
			frame.portrait:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 1 , 0)
			frame.portrait:SetWidth(frame:GetHeight())
			frame.portrait:SetHeight(frame:GetHeight() + (config.portrait.type == "3D" and 1 or 0))
			framelength = framelength - frameheight
		end
	end
	local numhbars = 0
	if horizontal then
		for _,key in pairs(horizontal) do
			if config[key] and config[key].enabled and frame[key] then
				if (not config[key].side or config[key].side == "bar") and not frame[key].hidden then
					barweightH = barweightH + (config[key].size or 0)
					numhbars = numhbars + 1
				end
			end
		end
	end
	local numvbars = 0
	if vertical then
		for _,key in pairs(vertical) do
			if config[key] and config[key].enabled and frame[key] then
				if (not config[key].side or config[key].side == "bar") and not frame[key].hidden then
					barweightV = barweightV + (config[key].size or 0)
					numvbars = numvbars + 1
				end
			end
		end
	end

	local barunith = (frameheight-(numhbars > 0 and (numhbars-1) or 0))/barweightH --Size of one unit of horizontal bar
	local barunitv = (framelength-(numhbars > 0 and numvbars or numvbars > 0 and (numvbars-1) or 0 ))/(barweightH+barweightV) --Size of one unit of vertical bar
	if horizontal then
		for _,key in pairs(horizontal) do
			if config[key] and config[key].enabled and frame[key] then
				if not config[key].side or config[key].side == "bar" then
					frame[key]:ClearAllPoints()
					frame[key]:SetPoint("TOPLEFT", frame, "TOPLEFT", xoffset, yoffset)
					frame[key]:SetWidth(barunitv*barweightH)
					frame[key]:SetHeight((barunith*(config[key].size or 0)) + ((key == "portrait" and config.portrait.type == "3D") and 1 or 0))
					if frame[key].hidden then
						frame[key]:Hide()
					else
						yoffset = yoffset - (barunith*(config[key].size or 0)) - 1
						frame[key]:Show()
					end
				end
			end
		end
	end
	xoffset = xoffset + (barunitv*barweightH) + (numhbars > 0 and 1 or 0)
	if vertical then
		for _,key in pairs(vertical) do
			if config[key] and config[key].enabled and frame[key] then
				if not config[key].side or config[key].side == "bar" then
					frame[key]:ClearAllPoints()
					frame[key]:SetPoint("TOPLEFT", frame, "TOPLEFT", xoffset, 0)
					frame[key]:SetWidth(barunitv*(config[key].size or 0))
					frame[key]:SetHeight(frameheight + ((key == "portrait" and config.portrait.type == "3D") and 1 or 0))
					if frame[key].hidden then
						frame[key]:Hide()
					else
						xoffset = xoffset + barunitv*(config[key].size or 0) + 1
						frame[key]:Show()
					end
				end
			end
		end
	end

	FullUpdate(frame)
end

function Units:SetupFrameModules(frame)
	local config = LunaUF.db.profile.units[frame.unitGroup]
	for key,module in pairs(LunaUF.modules) do
		if config.enabled and config[key] and config[key].enabled then
			module:OnEnable(frame)
			if LunaUF.modules[key].SetBarTexture then
				LunaUF.modules[key]:SetBarTexture(frame,"Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bar\\"..LunaUF.db.profile.texture)
			end
		else
			module:OnDisable(frame)
		end
	end
	self:PositionWidgets(frame)
end

-- Small helper function for creating bars with
function Units:CreateBar(parent)
	local bar = LunaUF:CreateBar(nil, parent)
	bar:SetFrameLevel(parent.topFrameLevel or 5)
	bar.parent = parent

	bar.background = bar:CreateTexture(nil, "BORDER")
	bar.background:SetAllPoints(bar)

	return bar
end

-- Initialize units
function Units:InitializeFrame(type)
--	if not LunaUF.db.profile.units[type].enabled then return end
	if( type == "raid" ) then
		self:LoadRaidGroupHeader()
	elseif( type == "party" or type == "partytarget" or type == "partypet" ) then
		self:LoadGroupHeader(type)
	else
		self:LoadUnit(type)
	end
end
