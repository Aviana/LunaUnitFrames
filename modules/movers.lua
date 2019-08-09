local L = LunaUF.L
local Movers = {}
local originalEnvs = {}
local unitConfig = {}
local attributeBlacklist = {["showplayer"] = true, ["showraid"] = true, ["showparty"] = true, ["showsolo"] = true, ["initial-unitwatch"] = true}
local OnDragStop, OnDragStart, configEnv
LunaUF:RegisterModule(Movers, "movers")

local ACR = LibStub("AceConfigRegistry-3.0", true)

local function getValue(func, unit, value)
	unit = string.gsub(unit, "(%d+)", "")
	if( unitConfig[func .. unit] == nil ) then unitConfig[func .. unit] = value end
	return unitConfig[func .. unit]
end

local function createConfigEnv()
	if( configEnv ) then return end
	configEnv = setmetatable({
		GetRaidTargetIndex = function(unit) return getValue("GetRaidTargetIndex", unit, math.random(1, 8)) end,
		GetLootMethod = function(unit) return "master", 0, 0 end,
		GetComboPoints = function() return MAX_COMBO_POINTS end,
		GetPetHappiness = function() return 3 end,
		UnitInRaid = function() return true end,
		UnitInParty = function() return true end,
		UnitPlayerOrPetInParty = function() return true end,
--		UnitIsUnit = function(unitA, unitB) return true end,
		UnitIsDeadOrGhost = function(unit) return false end,
		UnitIsConnected = function(unit) return true end,
		UnitLevel = function(unit) return MAX_PLAYER_LEVEL end,
		UnitIsPlayer = function(unit) return unit ~= "pet" and not string.match(unit, "(%w+)pet") end,
		UnitHealth = function(unit) return getValue("UnitHealth", unit, math.random(2000, 4000)) end,
		UnitHealthMax = function(unit) return 5000 end,
		UnitPower = function(unit, powerType)
			return getValue("UnitPower", unit, math.random(2000, 5000))
		end,
		UnitPowerMax = function(unit, powerType)
			if powerType == Enum.PowerType.ComboPoints then
				return 5
			end

			return 5000
		end,
		UnitHasIncomingResurrection = function(unit) return true end,
		UnitPVPRank = function(unit) return 17 end,
		UnitClassification = function(unit) return "elite" end,
		UnitExists = function(unit) return true end,
		UnitIsGroupLeader = function() return true end,
		UnitIsPVP = function(unit) return true end,
		UnitIsDND = function(unit) return false end,
		UnitIsAFK = function(unit) return false end,
		UnitFactionGroup = function(unit) return _G.UnitFactionGroup("player") end,
		UnitAffectingCombat = function() return true end,
		CastingInfo = function()
			-- 1 -> 10: spell, displayName, icon, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID
			local data = unitConfig["CastingInfo"] or {}
			if( not data[5] or GetTime() < data[5] ) then
				data[1] = L["Test spell"]
				data[2] = L["Test spell"]
				data[3] = "Interface\\Icons\\Spell_Nature_Rejuvenation"
				data[4] = GetTime() * 1000
				data[5] = data[4] + 60000
				data[6] = false
				data[7] = math.floor(GetTime())
				data[8] = math.random(0, 100) < 25
				data[9] = 1000
				unitConfig["CastingInfo"] = data
			end
			
			return unpack(data)
		end,
		UnitIsFriend = function(unit) return true end,
		GetReadyCheckStatus = function(unit)
			local status = getValue("GetReadyCheckStatus", unit, math.random(1, 3))
			return status == 1 and "ready" or status == 2 and "notready" or "waiting"
		end,
		UnitPowerType = function(unit)
			return _G.UnitPowerType("player")
		end,
		UnitAura = function(unit, id, filter)
			if( type(id) ~= "number" or id > 32 ) then return end
			
			local texture = filter == "HELPFUL" and "Interface\\Icons\\Spell_ChargePositive" or "Interface\\Icons\\Spell_ChargeNegative"
			local mod = id % 5
			local auraType = mod == 0 and "Magic" or mod == 1 and "Curse" or mod == 2 and "Poison" or mod == 3 and "Disease" or "none"
			return L["Test Aura"], texture, id, auraType, 0, 0, (math.random(0,1) > 0) and "player", id % 6 == 0
		end,
		UnitName = function(unit)
			local unitID = string.match(unit, "(%d+)")
			if( unitID ) then
				return string.format("%s #%d", L[string.gsub(unit, "(%d+)", "")] or unit, unitID)
			end
			return L[unit]
		end,
		UnitClass = function(unit)
			local classToken = getValue("UnitClass", unit, CLASS_SORT_ORDER[math.random(1, #(CLASS_SORT_ORDER))])
			return LOCALIZED_CLASS_NAMES_MALE[classToken], classToken
		end,
	}, {
		__index = _G,
		__newindex = function(tbl, key, value) _G[key] = value end,
	})
end

local function prepareChildUnits(header, ...)
	for i=1, select("#", ...) do
		local frame = select(i, ...)
		if( frame.unitType and not frame.configUnitID ) then
			LunaUF.Units.frameList[frame] = true
			frame.configUnitID = header.groupID and (header.groupID * 5) - 5 + i or i
			frame:SetAttribute("unit", frame.unitType..frame.configUnitID)
		end
	end
end

local function OnEnter(self)
	local tooltip = self.tooltipText or self.configUnitID and string.format("%s #%d", L[self.unitType], self.configUnitID) or L[self.unitType] or self.unitType

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
	GameTooltip:SetText(tooltip, 1, 0.81, 0, 1, true)
	GameTooltip:Show()
end

local function OnLeave(self)
	GameTooltip:Hide()
end

local function setupUnits()
	for frame in pairs(LunaUF.Units.frameList) do
		if( frame.configMode ) then
			-- Units visible, but it's not supposed to be
			if( frame:IsVisible() and not LunaUF.db.profile.units[frame.unitType].enabled ) then
				RegisterUnitWatch(frame, frame.hasStateWatch)
				if( not UnitExists(frame.unit) ) then frame:Hide() end
				
			-- Unit's not visible and it's enabled so it should
			elseif( not frame:IsVisible() and LunaUF.db.profile.units[frame.unitType].enabled ) then
				UnregisterUnitWatch(frame)

				frame:SetAttribute("state-unitexists", true)
				frame:FullUpdate()
				frame:Show()
			end
		elseif( not frame.configMode and LunaUF.db.profile.units[frame.unitType].enabled ) then
			frame.originalUnit = frame:GetAttribute("unit")
			frame.originalOnEnter = frame.OnEnter
			frame.originalOnLeave = frame.OnLeave
			frame.originalOnUpdate = frame:GetScript("OnUpdate")
			frame:SetMovable(true)
			frame:SetScript("OnDragStop", OnDragStop)
			frame:SetScript("OnDragStart", OnDragStart)
			frame.OnEnter = OnEnter
			frame.OnLeave = OnLeave
			frame:SetScript("OnEvent", nil)
			frame:SetScript("OnUpdate", nil)
			frame:RegisterForDrag("LeftButton")
			frame.configMode = true
			frame.unitOwner = nil
			frame.originalMenu = frame.menu
			frame.menu = nil
			
			if LunaUF.Units.headerUnits[frame.unitType] then
				LunaUF.Units.OnAttributeChanged(frame, "unit", frame.unitType..frame.configUnitID)
			else
				LunaUF.Units.OnAttributeChanged(frame, "unit", frame.unitType)
			end

			if( frame.healthBar ) then frame.healthBar:SetScript("OnUpdate", nil) end
			if( frame.powerBar ) then frame.powerBar:SetScript("OnUpdate", nil) end
			if( frame.indicators ) then frame.indicators:SetScript("OnUpdate", nil) end
			
			UnregisterUnitWatch(frame)
			frame:FullUpdate()
			frame:Show()
		end
	end
end

function Movers:Enable()
	createConfigEnv()

	-- Setup the headers
	for _, header in pairs(LunaUF.Units.headerFrames) do
		for key in pairs(attributeBlacklist) do
			header:SetAttribute(key, nil)
		end
		
		local config = LunaUF.db.profile.units[header.unitType]
		if( config.maxColumns ) then
			local maxUnits = MAX_RAID_MEMBERS
			if( config.filters ) then
				for _, enabled in pairs(config.filters) do
					if( not enabled ) then
						maxUnits = maxUnits - 5
					end
				end
			end
					
			header:SetAttribute("startingIndex", -math.min(config.maxColumns * 5, maxUnits) + 1)
			header:SetAttribute("unitsPerColumn", 5)
		elseif( LunaUF[header.unitType .. "Units"] ) then
			header:SetAttribute("unitsPerColumn", 5)
			header:SetAttribute("startingIndex", -#(LunaUF[header.unitType .. "Units"]) + 1)
		end
		
		header.startingIndex = header:GetAttribute("startingIndex")
		header:SetMovable(true)
		prepareChildUnits(header, header:GetChildren())
	end

	-- Setup the test env
	if( not self.isEnabled ) then
		for _, func in pairs(LunaUF.Tags.defaultTags) do
			if( type(func) == "function" ) then
				originalEnvs[func] = getfenv(func)
				setfenv(func, configEnv)
			end
		end

		for _, module in pairs(LunaUF.modules) do
			if( module.moduleName ) then
				for key, func in pairs(module) do
					if( type(func) == "function" ) then
						originalEnvs[module[key]] = getfenv(module[key])
						setfenv(module[key], configEnv)
					end
				end
			end
		end
	end
	
	setupUnits()
	setupUnits(true)
	
	self.isEnabled = true
end

function Movers:Disable()
	if( not self.isEnabled ) then return nil end
	
	for func, env in pairs(originalEnvs) do
		setfenv(func, env)
		originalEnvs[func] = nil
	end
	
	for frame in pairs(LunaUF.Units.frameList) do
		if( frame.configMode ) then
			if( frame.isMoving ) then
				frame:GetScript("OnDragStop")(frame)
			end
			
			frame.configMode = nil
			frame.unitOwner = nil
			frame.unit = nil
			frame.configUnitID = nil
			frame.menu = frame.originalMenu
			frame.originalMenu = nil
			frame.Hide = frame.originalHide
			frame:SetAttribute("unit", frame.originalUnit)
			frame:SetScript("OnDragStop", nil)
			frame:SetScript("OnDragStart", nil)
			frame:SetScript("OnEvent", frame:IsVisible() and LunaUF.Units.OnEvent or nil)
			frame:SetScript("OnUpdate", frame.originalOnUpdate)
			frame.OnEnter = frame.originalOnEnter
			frame.OnLeave = frame.originalOnLeave
			frame:SetMovable(false)
			frame:RegisterForDrag()

			if LunaUF.db.profile.units[frame.unitType].enabled then
				RegisterUnitWatch(frame, frame.hasStateWatch)
			end
			if( not UnitExists(frame.unit) ) then frame:Hide() end
		end
	end
			
	for type, header in pairs(LunaUF.Units.headerFrames) do
		header:SetMovable(false)
		header:SetAttribute("startingIndex", 1)
		header:SetAttribute("unitsPerColumn", LunaUF.db.profile.units[header.unitType].unitsPerColumn or 5)
		header:SetAttribute("initial-unitWatch", true)
		LunaUF.Units:SetHeaderAttributes(header, header.unitType)
		if( header.unitType == type ) then
			LunaUF.Units:ReloadHeader(header.unitType)
		end
	end

	LunaUF.Layout:Reload()

	-- Don't store these so everything can be GCed
	unitConfig = {}

	self.isEnabled = nil
end

function Movers:SetFrame(frame)
	local scale
	local position = LunaUF.db.profile.units[frame.unitType]
	local config = LunaUF.db.profile.units[frame.unitType]
	if not position.x then
		position = LunaUF.db.profile.units[frame.unitType].positions[frame.groupID]
	end
	local anchor = position.anchorTo and _G[position.anchorTo]

	local point, anchorTo, relativePoint, x, y = frame:GetPoint()

	if position.anchorTo ~= "UIParent" and not frame.isHeaderFrame then -- Working
		if anchor.isHeaderFrame then
			relativePoint = (LunaUF.db.profile.units[anchor.unitType].attribPoint == "TOP" or LunaUF.db.profile.units[anchor.unitType].attribPoint == "RIGHT") and "TOPRIGHT" or "BOTTOMLEFT"
			point = "BOTTOMLEFT"
			if relativePoint == "BOTTOMLEFT" then
				x = ((frame:GetLeft()*frame:GetScale()) - anchor:GetLeft())/frame:GetScale()
				y = ((frame:GetBottom()*frame:GetScale()) - anchor:GetBottom())/frame:GetScale()
			else
				x = ((frame:GetLeft()*frame:GetScale()) - anchor:GetRight())/frame:GetScale()
				y = ((frame:GetBottom()*frame:GetScale()) - anchor:GetTop())/frame:GetScale()
			end
			scale = 1
		else
			x = (frame:GetLeft()*frame:GetScale()) - (anchor:GetLeft()*anchor:GetScale())
			y = (frame:GetTop()*frame:GetScale()) - (anchor:GetTop()*anchor:GetScale())
			x = x / frame:GetScale()
			y = y / frame:GetScale()
			point = "TOPLEFT"
			relativePoint = "TOPLEFT"
			scale = 1
		end
	elseif position.anchorTo ~= "UIParent" and frame.isHeaderFrame then --working Header to header, header to frame broken
		if anchor.isHeaderFrame then
			relativePoint = (LunaUF.db.profile.units[anchor.unitType].attribPoint == "TOP" or LunaUF.db.profile.units[anchor.unitType].attribPoint == "RIGHT") and "TOPRIGHT" or "BOTTOMLEFT"
		else
			relativePoint = "BOTTOMLEFT"
		end
		point = (config.attribPoint == "TOP" or config.attribPoint == "RIGHT") and "TOPRIGHT" or "BOTTOMLEFT"
		if relativePoint == "BOTTOMLEFT" then
			if point == "BOTTOMLEFT" then
				x = (frame:GetLeft() - anchor:GetLeft()*anchor:GetScale())
				y = (frame:GetBottom() - anchor:GetBottom()*anchor:GetScale())
			else
				x = (frame:GetRight() - anchor:GetLeft()*anchor:GetScale())
				y = (frame:GetTop() - anchor:GetBottom()*anchor:GetScale())
			end
		else
			if point == "BOTTOMLEFT" then
				x = frame:GetLeft() - anchor:GetRight()
				y = frame:GetBottom() - anchor:GetTop()
			else
				x = -(GetScreenWidth() - frame:GetRight()) + (GetScreenWidth() - anchor:GetRight())
				y = -((768 / UIParent:GetScale()) - frame:GetTop()) + ((768 / UIParent:GetScale()) - anchor:GetTop())
			end
		end
		scale = 1
	elseif position.anchorTo == "UIParent" and frame.isHeaderFrame then -- working
		if config.attribPoint == "BOTTOM" or config.attribPoint == "LEFT" then
			x = frame:GetLeft()
			y = frame:GetBottom()
			point = "BOTTOMLEFT"
			relativePoint = "BOTTOMLEFT"
		else
			x = -(GetScreenWidth() - frame:GetRight())
			y = -((768 / UIParent:GetScale()) - frame:GetTop())
			point = "TOPRIGHT"
			relativePoint = "TOPRIGHT"
		end
		scale = (frame:GetScale() * UIParent:GetScale())
	else --working
		x = frame:GetLeft()
		y = frame:GetBottom()
		point = "BOTTOMLEFT"
		relativePoint = "BOTTOMLEFT"
		scale = (frame:GetScale() * UIParent:GetScale())
	end


	position.x = x * scale
	position.y = y * scale
	position.point = point
	position.relativePoint = relativePoint
	--ChatFrame1:AddMessage("Anchoring "..frame:GetName().."'s "..point.." to "..position.anchorTo.."'s "..relativePoint.." with offset x: "..position.x.." y: "..position.y)
	LunaUF.Layout:AnchorFrame(frame, position)
end

OnDragStart = function(self)
	if( not self:IsMovable() ) then return end
	
	if( LunaUF.Units.headerUnits[self.unitType] ) then
		self = self:GetParent()
	end

	self.isMoving = true
	self:StartMoving()
end

OnDragStop = function(self)
	if( not self:IsMovable() ) then return end
	if( LunaUF.Units.headerUnits[self.unitType] ) then
		self = self:GetParent()
	end

	self.isMoving = nil
	self:StopMovingOrSizing()

	Movers:SetFrame(self)

	-- Notify the configuration it can update itself now
	if( ACR ) then
		ACR:NotifyChange("LunaUnitFrames")
	end
end

function Movers:Update()
	if( not LunaUF.db.profile.locked ) then
		self:Enable()
	elseif( LunaUF.db.profile.locked ) then
		self:Disable()
	end
end