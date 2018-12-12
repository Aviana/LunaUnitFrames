LunaUF = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "AceHook-2.1", "FuBarPlugin-2.0", "AceDebug-2.0")
LunaUF:RegisterDB("LunaDB")

-- Assets ----------------------------------------------------------------------------------
LunaUF.Version = 2225
LunaUF.BS = AceLibrary("Babble-Spell-2.2")
LunaUF.Banzai = AceLibrary("Banzai-1.0")
LunaUF.HealComm = AceLibrary("HealComm-1.0")
LunaUF.DruidManaLib = AceLibrary("DruidManaLib-1.0")
LunaUF.CL = AceLibrary("CastLib-1.0")
LunaUF.roster = AceLibrary("RosterLib-2.0")
LunaUF.unitList = {"player", "pet", "pettarget", "target", "targettarget", "targettargettarget", "party", "partytarget", "partypet", "raid"}
LunaUF.ScanTip = CreateFrame("GameTooltip", "LunaScanTip", nil, "GameTooltipTemplate")
LunaUF.ScanTip:SetOwner(WorldFrame, "ANCHOR_NONE")
LunaUF.modules = {}
_, LunaUF.playerRace = UnitRace("player")
LunaUF.AllianceCheck = {
	["Dwarf"] = true,
	["Human"] = true,
	["Gnome"] = true,
	["NightElf"] = true,
}

local function BarGetMinMaxValues(self)
	return self.minV, self.maxV
end

local function BarGetOrientation(self)
	return self.orientation
end

local function BarGetStatusBarColor(self)
	return self.texture:GetVertexColor()
end

local function BarGetStatusBarTexture(self)
	return self.texture
end

local function BarGetValue(self)
	return self.value
end

local function BarSetMinMaxValues(self, minV, maxV)
	self.minV = minV
	if self.value < minV then
		self.value = minV
	end
	self.maxV = maxV
	if self.value > maxV then
		self.value = maxV
	end
	self:Refresh()
end

local function BarSetOrientation(self, orientation)
	if string.upper(orientation) == "HORIZONTAL" or string.upper(orientation) == "VERTICAL" then
		if self.orientation ~= orientation then
			self.orientation = orientation
			self:Refresh()
		end
	end
end

local function BarSetStatusBarColor(self, r, g, b, alpha)
	if r and g and b then
		if type(r) == "number" and type(g) == "number" and type(b) == "number" then
			if r >= 0 and r <= 1 and g >= 0 and g <= 1 and b >= 0 and b <= 1 then
				if alpha and type(alpha) == "number" and alpha >= 0 and alpha <= 1 then
					self.texture:SetVertexColor(r, g, b, alpha)
				else
					self.texture:SetVertexColor(r, g, b)
				end
				self:Refresh()
			end
		end
	end
end

local function BarSetStatusBarTexture(self, texture, layer)
	local validLayers = {
		["BACKGROUND"] = true,
		["BORDER"] = true,
		["ARTWORK"] = true,
		["OVERLAY"] = true,
		["HIGHLIGHT"] = true,
	}
	if texture then
		local changed
		if type(texture) == "string" then
			self.texture:SetTexture(texture)
			changed = true
		elseif texture:GetTexture() then
			self.texture:SetTexture(texture:GetTexture())
			changed = true
		end
		if changed and layer and validLayers[string.upper(layer)] then
			self.texture:SetDrawLayer(layer)
		end
	end
end

local function BarSetValue(self, value)
	if value <= self.maxV and value >= self.minV then
		self.value = value
		self:Refresh()
	end
end

local function BarSetReverse(self, value)
	if value and not self.reverse then
		self.reverse = true
		self:Refresh()
	elseif not value and self.reverse then
		self.reverse = nil
		self:Refresh()
	end
end

local function BarSetStretchTexture(self, value)
	if value then
		self.stretch = true
	else
		self.stretch = nil
	end
	self:Refresh()
end

local function BarRefresh(self)
	self = self or this

	if self.value == self.minV then
		self.texture:Hide()
		return
	else
		self.texture:Show()
	end

	self.texture:ClearAllPoints()
	if self.reverse then
		if self.orientation == "HORIZONTAL" then
			self.texture:SetHeight(self:GetHeight())
			self.texture:SetWidth(self:GetWidth()*(self.value/self.maxV))
			self.texture:SetPoint("RIGHT", self, "RIGHT")
			if not self.stretch then
				self.texture:SetTexCoord(1-(self.value/self.maxV), 1, 0, 1)
			end
		else
			self.texture:SetHeight(self:GetHeight()*(self.value/self.maxV))
			self.texture:SetWidth(self:GetWidth())
			self.texture:SetPoint("TOP", self, "TOP")
			if not self.stretch then
				self.texture:SetTexCoord(0, 1, 0, (self.value/self.maxV))
			end
		end
	else
		if self.orientation == "HORIZONTAL" then
			self.texture:SetHeight(self:GetHeight())
			self.texture:SetWidth(self:GetWidth()*(self.value/self.maxV))
			self.texture:SetPoint("LEFT", self, "LEFT")
			if not self.stretch then
				self.texture:SetTexCoord(0, (self.value/self.maxV), 0, 1)
			end
		else
			self.texture:SetHeight(self:GetHeight()*(self.value/self.maxV))
			self.texture:SetWidth(self:GetWidth())
			self.texture:SetPoint("BOTTOM", self, "BOTTOM")
			if not self.stretch then
				self.texture:SetTexCoord(0, 1, 1-(self.value/self.maxV), 1)
			end
		end
	end
	if self.stretch then
		self.texture:SetTexCoord(0, 1, 0, 1)
	end
end

function LunaUF:CreateBar(name, parent)
	local frame = CreateFrame("Frame", name, parent)
	frame.texture = frame:CreateTexture()
	
	frame.minV = 0
	frame.maxV = 1
	frame.value = 1
	frame.orientation = "HORIZONTAL"
	
	frame.GetMinMaxValues = BarGetMinMaxValues
	frame.GetOrientation = BarGetOrientation
	frame.GetStatusBarColor = BarGetStatusBarColor
	frame.GetStatusBarTexture = BarGetStatusBarTexture
	frame.GetValue = BarGetValue
	frame.SetMinMaxValues = BarSetMinMaxValues
	frame.SetOrientation = BarSetOrientation
	frame.SetStatusBarColor = BarSetStatusBarColor
	frame.SetStatusBarTexture = BarSetStatusBarTexture
	frame.SetValue = BarSetValue
	frame.SetReverse = BarSetReverse
	frame.SetStretchTexture = BarSetStretchTexture
	frame.Refresh = BarRefresh
	
	frame:SetScript("OnSizeChanged", BarRefresh)
	--frame:SetScript("OnHide", function () this:SetValue(0) end)
	return frame
end

function LunaUF:deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[LunaUF:deepcopy(orig_key)] = LunaUF:deepcopy(orig_value)
        end
        setmetatable(copy, LunaUF:deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function LunaUF:CastSpellByName_IgnoreSelfCast(spell, onPlayer)
	if type(spell) == "function" then
		spell()
		return
	end
	local sc = GetCVar("AutoSelfCast")
	SetCVar("AutoSelfCast", "0")
	-- make sure that this call doesn't fail, otherwise the CVar may not be restored
	pcall(CastSpellByName, spell, onPlayer)
	SetCVar("AutoSelfCast", sc)
end

function LunaUF:isDualSpell(spell)
	return strfind(spell,self.BS["Holy Shock"]) or strfind(spell, self.BS["Mind Vision"]) or strfind(spell, self.BS["Dispel Magic"]) or strfind(spell, self.BS["Devour Magic"])
end

function LunaUF:Mouseover(action)
	local func = loadstring(action or "")
	SpellStopTargeting()
	local unit = (LunaUF.db.profile.mouseover and UnitExists("mouseover") and "mouseover") or (GetMouseFocus() and GetMouseFocus().unit)
	local rosterUnit = unit and self.roster:GetUnitIDFromUnit(unit)
	unit = rosterUnit or unit
	if unit then
		if UnitCanAttack("player", unit) or self:isDualSpell(action) then
			if UnitIsUnit("target", unit) then
				self:CastSpellByName_IgnoreSelfCast(func or action)
			else
				self.Units.pauseUpdates = true
				TargetUnit(unit)
				self:CastSpellByName_IgnoreSelfCast(func or action)
				TargetLastTarget()
				self.Units.pauseUpdates = nil
			end
		else
			if UnitExists("target") then
				if not UnitCanAssist("player", "target") and not func then
					self:CastSpellByName_IgnoreSelfCast(action)
					SpellTargetUnit(unit)
				elseif UnitIsUnit(unit, "target") then
					self:CastSpellByName_IgnoreSelfCast(func or action)
				elseif string.find(unit, "target.+") or func then
					self.Units.pauseUpdates = true
					TargetUnit(unit)
					self:CastSpellByName_IgnoreSelfCast(func or action)
					TargetLastTarget()
					self.Units.pauseUpdates = nil
				else
					self.Units.pauseUpdates = true
					ClearTarget()
					self:CastSpellByName_IgnoreSelfCast(action)
					SpellTargetUnit(unit)
					SpellStopTargeting()
					TargetLastTarget()
					self.Units.pauseUpdates = nil
				end
			else
				if func then
					self.Units.pauseUpdates = true
					TargetUnit(unit)
					func()
					ClearTarget()
					self.Units.pauseUpdates = nil
				else
					self:CastSpellByName_IgnoreSelfCast(action)
					SpellTargetUnit(unit)
				end
			end
		end
	else
		if func then
			func()
		else
			CastSpellByName(action)
		end
	end
end

SLASH_LUFMO1, SLASH_LUFMO2 = "/lunamo", "/lunamouseover"
function SlashCmdList.LUFMO(msg, editbox)
	LunaUF:Mouseover(msg)
end

function lufmo(msg)
	SlashCmdList.LUFMO(msg)
end

--------------------------------------------------------------------------------------------

-- Localization Stuff ----------------------------------------------------------------------
LunaUF.L = AceLibrary("AceLocale-2.2"):new("LunaUnitFrames")
local L = LunaUF.L
--------------------------------------------------------------------------------------------

-- FUBAR Stuff -----------------------------------------------------------------------------
LunaUF.name = "LunaUnitFrames"
LunaUF.hasNoColor = true
LunaUF.hasIcon = "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\icon"
LunaUF.defaultMinimapPosition = 180
LunaUF.cannotDetachTooltip = true
LunaUF.hideWithoutStandby = true

function LunaUF:OnClick()
	if IsControlKeyDown() then
		if LunaUF.db.profile.locked then
			LunaUF:SystemMessage(L["Entering config mode."])
			LunaUF.db.profile.locked = false
		else
			LunaUF:SystemMessage(L["Exiting config mode."])
			LunaUF.db.profile.locked = true
		end
		LunaUF:LoadUnits()
	else
		if LunaOptionsFrame:IsShown() then
			LunaOptionsFrame:Hide()
		else
			LunaOptionsFrame:Show()
		end
	end
end
--------------------------------------------------------------------------------------------

--Constant Values --------------------------------------------------------------------------
LunaUF.constants = {
	backdrop = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tile = true,
		tileSize = 16,
		insets = {left = -1.5, right = -1.5, top = -1.5, bottom = -1.5},
	},
	icon = "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\icon",
	AnchorPoint = {
	["UP"] = "BOTTOM",
	["DOWN"] = "TOP",
	["RIGHT"] = "LEFT",
	["LEFT"] = "RIGHT",
	},
	RaidClassMapping = {
		[1] = "WARRIOR",
		[2] = "DRUID",
		[3] = LunaUF.AllianceCheck[LunaUF.playerRace] and "PALADIN" or "SHAMAN",
		[4] = "WARLOCK",
		[5] = "PRIEST",
		[6] = "MAGE",
		[7] = "ROGUE",
		[8] = "HUNTER",
		[9] = "PET",
	},
	CLASS_ICON_TCOORDS = {
		["WARRIOR"]     = {0.0234375, 0.2265625, 0.0234375, 0.2265625},
		["MAGE"]        = {0.2734375, 0.4765625, 0.0234375, 0.2265625},
		["ROGUE"]       = {0.5234375, 0.7265625, 0.0234375, 0.2265625},
		["DRUID"]       = {0.7734375, 0.97265625, 0.0234375, 0.2265625},
		["HUNTER"]      = {0.0234375, 0.2265625, 0.2734375, 0.4765625},
		["SHAMAN"]      = {0.2734375, 0.4765625, 0.2734375, 0.4765625},
		["PRIEST"]      = {0.5234375, 0.7265625, 0.2734375, 0.4765625},
		["WARLOCK"]     = {0.7734375, 0.97265625, 0.2734375, 0.4765625},
		["PALADIN"]     = {0.0234375, 0.2265625, 0.5234375, 0.7265625}
	},
	barorder = {
		horizontal = {
			[1] = "portrait",
			[2] = "healthBar",
			[3] = "powerBar",
			[4] = "castBar",
			[5] = "emptyBar",
		},
		vertical = {
		},
	},
	specialbarorder = {
		["player"] = {
			horizontal = {
				[1] = "portrait",
				[2] = "healthBar",
				[3] = "powerBar",
				[4] = "castBar",
				[5] = "emptyBar",
				[6] = "druidBar",
				[7] = "totemBar",
				[8] = "reckStacks",
				[9] = "xpBar",
			},
			vertical = {
			},
		},
		["pet"] = {
			horizontal = {
				[1] = "portrait",
				[2] = "healthBar",
				[3] = "powerBar",
				[4] = "castBar",
				[5] = "xpBar",
				[6] = "emptyBar",
			},
			vertical = {
			},
		},
		["target"] = {
			horizontal = {
				[1] = "portrait",
				[2] = "healthBar",
				[3] = "powerBar",
				[4] = "castBar",
				[5] = "comboPoints",
				[6] = "emptyBar",
			},
			vertical = {
			},
		},
		["raid"] = {
			horizontal = {
				[1] = "portrait",
				[2] = "castBar",
				[3] = "emptyBar",
			},
			vertical = {
				[1] = "healthBar",
				[2] = "powerBar",
			},
		},
	},
}
--------------------------------------------------------------------------------------------

--Upon Loading
function LunaUF:OnInitialize()

	-- Slash Commands ----------------------------------------------------------------------
	LunaUF.cmdtable = {type = "group", handler = LunaUF, args = {
		[L["cmd_reset"]] = {
			type = "execute",
			name = L["cmd_reset"],
			desc = L["Resets your current settings."],
			func = function ()
					StaticPopup_Show ("RESET_LUNA_PROFILE")
				end,
		},
		[L["cmd_config"]] = {
			type = "execute",
			name = L["cmd_config"],
			desc = L["Toggle config mode on and off."],
			func = function ()
					if LunaUF.db.profile.locked then
						LunaUF:SystemMessage(L["Entering config mode."])
						LunaUF.db.profile.locked = false
					else
						LunaUF:SystemMessage(L["Exiting config mode."])
						LunaUF.db.profile.locked = true
					end
					LunaUF:LoadUnits()
				end,
		},
		[L["cmd_menu"]] = {
			type = "execute",
			name = L["cmd_menu"],
			desc = L["Show/hide the options menu."],
			func = function ()
					if LunaOptionsFrame:IsShown() then
						LunaOptionsFrame:Hide()
					else
						LunaOptionsFrame:Show()
					end
				end,
		},
	}}
	LunaUF:RegisterChatCommand({"/luna", "/luf", "/lunauf", "/lunaunitframes"}, LunaUF.cmdtable)
	----------------------------------------------------------------------------------------
	
	self:RegisterDefaults("profile", self.defaults.profile)
	self:InitBarorder()
	self:HideBlizzard()
	self:LoadUnits()
	self:CreateOptionsMenu()
	self:LoadOptions()
	LunaUF:SystemMessage(L["Loaded. The ride never ends!"])
	if not MobHealth3 and MobHealthFrame then
		LunaUF:SystemMessage(L["Mobhealth2/Mobinfo2 found. Please consider MobHealth3 for a better experience."])
	end
end

--System Message Output --------------------------------------------------------------------
function LunaUF:SystemMessage(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFF2150C2LunaUnitFrames|cFFFFFFFF: "..msg)
end
--------------------------------------------------------------------------------------------

--Profile Changer---------------------------------------------------------------------------
function LunaUF:ProfileSwitcher()
	if (not LunaDB.ProfileSwitcher) or (event == "PARTY_MEMBERS_CHANGED" and UnitInRaid("player")) then return end
	local GrpMode = 0
	local _,currentProfile = LunaUF:GetProfile()
	if UnitInRaid("player") then
		for i=1,8 do
			if (getn(RAID_SUBGROUP_LISTS[i]) or 0) > 0 then
				GrpMode = i
			end
		end
		if GrpMode == 1 then
			GrpMode = "5man"
		elseif GrpMode == 2 then
			GrpMode = "10man"
		elseif GrpMode <= 4 then
			GrpMode = "20man"
		else
			GrpMode = "40man"
		end
	else
		if GetNumPartyMembers() > 0 then
			GrpMode = "Party"
		else
			GrpMode = "Solo"
		end
	end
	local profile = LunaDB.ProfileSwitcherData[GrpMode] or "Default"
	UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[14].ProfileSelect, profile)
	LunaUF:SystemMessage(L["Switched to Profile: "]..profile)
	LunaUF:SetProfile(profile)
end
LunaUF:RegisterEvent("PARTY_MEMBERS_CHANGED", "ProfileSwitcher")
LunaUF:RegisterEvent("RAID_ROSTER_UPDATE", "ProfileSwitcher")
--------------------------------------------------------------------------------------------

--On Profile changed------------------------------------------------------------------------
function LunaUF:OnProfileEnable()
	self:InitBarorder()
	self:HideBlizzard()
	self:LoadUnits()
	self:LoadOptions()
end
--------------------------------------------------------------------------------------------

--Register Module --------------------------------------------------------------------------
function LunaUF:RegisterModule(module, key, name, isBar, class)
	self.modules[key] = module

	module.moduleKey = key
	module.moduleHasBar = isBar
	module.moduleName = name
	module.moduleClass = class
	
end
--------------------------------------------------------------------------------------------

--Hiding the Blizzard stuff ----------------------------------------------------------------
function LunaUF:HideBlizzard()
	-- Castbar
	local CastingBarFrame = getglobal("CastingBarFrame")
	if self.db.profile.blizzard.castbar then
		if CastingBarFrame.OldShow then
			CastingBarFrame.Show = CastingBarFrame.OldShow
		end
		if CastingBarFrame.OldHide then
			CastingBarFrame.Hide = CastingBarFrame.OldHide
		end
		if CastingBarFrame.OldIsShown then
			CastingBarFrame.IsShown = CastingBarFrame.OldIsShown
		end
		if CastingBarFrame.OldIsVisible then
			CastingBarFrame.IsVisible = CastingBarFrame.OldIsVisible
		end
		if CastingBarFrame.LUAFShown then
			CastingBarFrame.LUAFShown = nil
			CastingBarFrame:Show()
		end
	else
		CastingBarFrame.OldShow = CastingBarFrame.Show
		CastingBarFrame.OldHide = CastingBarFrame.Hide
		CastingBarFrame.OldIsShown = CastingBarFrame.IsShown
		CastingBarFrame.OldIsVisible = CastingBarFrame.IsVisible
		CastingBarFrame.Show = function(this)
				this.LUAFShown = true
			end
		CastingBarFrame.Hide = function(this)
				this.LUAFShown = nil
			end
		CastingBarFrame.IsShown = function(this)
				return this.LUAFShown
			end
		CastingBarFrame.IsVisible = function(this)
				return this.LUAFShown and this:GetParent():IsVisible()
			end
	end
	--Buffs
	if self.db.profile.blizzard.buffs then
		BuffFrame:Show()
	else
		BuffFrame:Hide()
	end
	--Weapon Enchants
	if self.db.profile.blizzard.weaponbuffs then
		TemporaryEnchantFrame:Show()
	else
		TemporaryEnchantFrame:Hide()
	end
	--Player
	if self.db.profile.blizzard.player then
		PlayerFrame:RegisterEvent("UNIT_LEVEL")
		PlayerFrame:RegisterEvent("UNIT_COMBAT")
		PlayerFrame:RegisterEvent("UNIT_FACTION")
		PlayerFrame:RegisterEvent("UNIT_MAXMANA")
		PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		PlayerFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
		PlayerFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
		PlayerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
		PlayerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		PlayerFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
		PlayerFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
		PlayerFrame:RegisterEvent("PARTY_LEADER_CHANGED")
		PlayerFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
		PlayerFrame:RegisterEvent("RAID_ROSTER_UPDATE")
		PlayerFrame:RegisterEvent("PLAYTIME_CHANGED")
		PlayerFrame:Show()
--		PlayerFrame_Update()
		UnitFrameHealthBar_Update(PlayerFrame.healthhar, "player")
		UnitFrameManaBar_Update(PlayerFrame.manabar, "player")
	else
		PlayerFrame:UnregisterAllEvents()
		PlayerFrame:Hide()
	end
	--Pet
	if self.db.profile.blizzard.pet then
		PetFrame:RegisterEvent("UNIT_PET");
		PetFrame:RegisterEvent("UNIT_COMBAT");
		PetFrame:RegisterEvent("UNIT_AURA");
		PetFrame:RegisterEvent("PET_ATTACK_START");
		PetFrame:RegisterEvent("PET_ATTACK_STOP");
		PetFrame:RegisterEvent("UNIT_HAPPINESS");
--		PetFrame_Update()
	else
		PetFrame:UnregisterAllEvents()
		PetFrame:Hide()
	end
	--Target
	ClearTarget()
	if self.db.profile.blizzard.target then
		TargetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		TargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		TargetFrame:RegisterEvent("UNIT_HEALTH")
		TargetFrame:RegisterEvent("UNIT_LEVEL")
		TargetFrame:RegisterEvent("UNIT_FACTION")
		TargetFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
		TargetFrame:RegisterEvent("UNIT_AURA")
		TargetFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
		TargetFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
		TargetFrame:RegisterEvent("RAID_TARGET_UPDATE")
		ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		ComboFrame:RegisterEvent("PLAYER_COMBO_POINTS")
		ComboPointsFrame_OnEvent()
	else
		TargetFrame:UnregisterAllEvents()
		TargetFrame:Hide()
		ComboFrame:UnregisterAllEvents()
		ComboFrame:Hide()
	end
	--Party
	if self.db.profile.blizzard.party then
		if self.RaidOptionsFrame_UpdatePartyFrames then
			RaidOptionsFrame_UpdatePartyFrames = self.RaidOptionsFrame_UpdatePartyFrames
		end
		for i=1,4 do
			local frame = getglobal("PartyMemberFrame"..i)
			frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
			frame:RegisterEvent("PARTY_LEADER_CHANGED")
			frame:RegisterEvent("PARTY_MEMBER_ENABLE")
			frame:RegisterEvent("PARTY_MEMBER_DISABLE")
			frame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
			frame:RegisterEvent("UNIT_PVP_UPDATE")
			frame:RegisterEvent("UNIT_AURA")
			frame:RegisterEvent("UNIT_PET")
			frame:RegisterEvent("VARIABLES_LOADED")
			frame:RegisterEvent("UNIT_NAME_UPDATE")
			frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
			frame:RegisterEvent("UNIT_DISPLAYPOWER")
		end
		UnitFrame_OnEvent("PARTY_MEMBERS_CHANGED")
		ShowPartyFrame()
	else
		self.RaidOptionsFrame_UpdatePartyFrames = RaidOptionsFrame_UpdatePartyFrames
		RaidOptionsFrame_UpdatePartyFrames = function () end
		for i=1,4 do
			local frame = getglobal("PartyMemberFrame"..i)
			frame:UnregisterAllEvents()
			frame:Hide()
		end
	end
end

--------------------------------------------------------------------------------------------

function LunaUF:InitBarorder()
	if not LunaDB.ProfileSwitcherData then
		LunaDB.ProfileSwitcherData = {}
	end

	for key,unitGroup in pairs(LunaUF.db.profile.units) do
		if not unitGroup.barorder or (LunaUF.constants.specialbarorder[key] and (getn(unitGroup.barorder.horizontal) + getn(unitGroup.barorder.vertical)) < (getn(LunaUF.constants.specialbarorder[key].horizontal) + getn(LunaUF.constants.specialbarorder[key].vertical)) or (getn(unitGroup.barorder.horizontal) + getn(unitGroup.barorder.vertical)) < (getn(LunaUF.constants.barorder.horizontal) + getn(LunaUF.constants.barorder.vertical)) ) then
			if LunaUF.constants.specialbarorder[key] then
				unitGroup.barorder = LunaUF:deepcopy(LunaUF.constants.specialbarorder[key])
			else
				unitGroup.barorder = LunaUF:deepcopy(LunaUF.constants.barorder)
			end
		end
	end
end

--------------------------------------------------------------------------------------------

function LunaUF:LoadUnits()
	for _, type in pairs(self.unitList) do
		self.Units:InitializeFrame(type)
	end
end
