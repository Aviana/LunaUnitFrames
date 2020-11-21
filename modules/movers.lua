LUF = select(2, ...)

local oUF = LUF.oUF
local L = LUF.L
local ACR = LibStub("AceConfigRegistry-3.0", true)

local origEnvironment, testEnvironment = {}
local BlacklistAttributes = {
	["showraid"] = true,
	["showparty"] = true,
	["showsolo"] = true,
	["showplayer"] = true,
	["initial-unitwatch"] = true
}

local function OnDragStart(self)
	if( not self:IsMovable() ) then return end

<<<<<<< Updated upstream
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
		UnitThreatSituation = function(unit)
			return 3
		end,
	}, {
		__index = _G,
		__newindex = function(tbl, key, value) _G[key] = value end,
	})
=======
	if LUF.HeaderFrames[self:GetAttribute("oUF-guessUnit")] then
		self = self:GetParent()
	end

	self:StartMoving()
>>>>>>> Stashed changes
end

local function OnDragStop(self)
	if( not self:IsMovable() ) then return end

	if LUF.HeaderFrames[self:GetAttribute("oUF-guessUnit")] then
		self = self:GetParent()
	end

	self:StopMovingOrSizing()

	LUF:CorrectPosition(self)


	if( ACR ) then
		ACR:NotifyChange("LunaUnitFrames")
	end
end

local function enableFun(...)
	local maxUnits = ...
	maxUnits = maxUnits:GetParent():GetAttribute("unitsPerColumn") or 1
	for i=1, select("#", ...) do
		local frame = select(i, ...)
		if not frame.inConfigMode then
			frame.inConfigMode = true
			frame.originalUnit = frame:GetAttribute("unit")
			frame:SetAttribute("unit","player")
			frame.originalSuffix = frame:GetAttribute("unitsuffix")
			frame:SetAttribute("unitsuffix", nil)
			frame.originalOnEnter = frame.OnEnter
			frame.originalOnLeave = frame.OnLeave
			frame:SetMovable(true)
			frame:SetScript("OnDragStop", OnDragStop)
			frame:SetScript("OnDragStart", OnDragStart)
			frame.OnEnter = OnEnter
			frame.OnLeave = OnLeave
			frame:RegisterForDrag("LeftButton")
			UnregisterUnitWatch(frame)
			RegisterUnitWatch(frame, true)
		end
		if i <= maxUnits then
			frame:Show()
		else
			frame:Hide()
		end
	end
end

local function disableFun(...)
	for i=1, select("#", ...) do
		local frame = select(i, ...)
		if frame.inConfigMode then
			frame.inConfigMode = nil
			frame:SetAttribute("unit", frame.originalUnit)
			frame.originalUnit = nil
			frame:SetAttribute("unitsuffix", frame.originalSuffix)
			frame.originalSuffix = nil
			frame:SetMovable(false)
			frame:SetScript("OnDragStop", nil)
			frame:SetScript("OnDragStart", nil)
			frame.OnEnter = frame.originalOnEnter
			frame.OnLeave = frame.originalOnLeave
			frame.originalOnEnter = nil
			frame.originalOnLeave = nil
			frame:RegisterForDrag()
			UnregisterUnitWatch(frame)
			RegisterUnitWatch(frame)
		end
	end
end

local function EnableMovers()
	for unit, frame in pairs(LUF.frameIndex) do
		local config = LUF.db.profile.units[unit] or LUF.db.profile.units.raid
		if config.enabled then
			frame.configMode = true
			if frame:GetAttribute("oUF-headerType") then
				for key in pairs(BlacklistAttributes) do
					frame:SetAttribute(key, nil)
				end
				if strmatch(unit, "^party.*$") then
					frame:SetAttribute("unitsPerColumn", (LUF.db.profile.units.party.showPlayer or LUF.db.profile.units.party.showSolo) and 5 or 4)
				elseif not config.unitsPerColumn then
					frame:SetAttribute("unitsPerColumn", 5)
				end
				frame:SetAttribute("startingIndex", -(config.unitsPerColumn or 5)-1)
				enableFun(frame:GetChildren())
				frame:SetMovable(true)
			else
				enableFun(frame)
			end
		end
	end
end

local function DisableMovers()
	for unit, frame in pairs(LUF.frameIndex) do
		local config = LUF.db.profile.units[unit] or LUF.db.profile.units.raid
		if config.enabled then
			frame.configMode = nil
			if frame:GetAttribute("oUF-headerType") then
				disableFun(frame:GetChildren())
				frame:SetAttribute("startingIndex", 1)
				frame:SetMovable(false)
				frame:SetAttribute("initial-unitWatch", true)
				LUF:SetupHeader(unit)
			else
				disableFun(frame)
			end
		end
	end
end

function LUF:UpdateMovers()
	if( LUF.db.profile.locked ) then
		DisableMovers()
	else
		EnableMovers()
	end
	self:ReloadAll()
end

function LUF:CorrectPosition(frame)
	local scale, position
	local config = LUF.db.profile.units[frame:GetAttribute("headerType") or frame:GetAttribute("oUF-guessUnit")]
	if config.positions then
		position = config.positions[tonumber(strsub(frame:GetName(),14))]
	else
		position = config
	end
	
	local anchor = position.anchorTo and _G[position.anchorTo]
	local anchorConfig = LUF.db.profile.units[frame:GetAttribute("headerType") or anchor:GetAttribute("oUF-guessUnit")]
	
	local point, anchorTo, relativePoint, x, y = frame:GetPoint()

	if position.anchorTo ~= "UIParent" and not frame:GetAttribute("headerType") then
		if anchor:GetAttribute("headerType") then
			relativePoint = (anchorConfig.attribPoint == "TOP" or anchorConfig.attribPoint == "RIGHT") and "TOPRIGHT" or "BOTTOMLEFT"
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
	elseif position.anchorTo ~= "UIParent" and frame:GetAttribute("headerType") then
		if anchor:GetAttribute("headerType") then
			relativePoint = (anchorConfig.attribPoint == "TOP" or anchorConfig.attribPoint == "RIGHT") and "TOPRIGHT" or "BOTTOMLEFT"
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
	elseif position.anchorTo == "UIParent" and frame:GetAttribute("headerType") then
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
	else
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
	self:PlaceFrame(frame)
end