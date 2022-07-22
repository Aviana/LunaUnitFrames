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

	if LUF.HeaderFrames[self:GetAttribute("oUF-guessUnit")] then
		self = self:GetParent()
	end

	self:StartMoving()
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
		if not ((unit == "raid9" or unit == "raid10") and LUF.db.profile.units.raid.groupBy == "GROUP") then
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
		else
			disableFun(frame:GetChildren())
			frame:SetAttribute("startingIndex", 1)
			frame:SetMovable(false)
			frame:SetAttribute("initial-unitWatch", true)
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
	local config = LUF.db.profile.units[frame:GetAttribute("oUF-headerType") or frame:GetAttribute("oUF-guessUnit")]
	if config.positions then
		position = config.positions[tonumber(strmatch(frame:GetName(),"%d+"))]
	else
		position = config
	end
	
	local anchor = position.anchorTo and _G[position.anchorTo]
	local anchorConfig = LUF.db.profile.units[frame:GetAttribute("oUF-headerType") or anchor:GetAttribute("oUF-guessUnit")]
	
	local point, anchorTo, relativePoint, x, y = frame:GetPoint()

	if position.anchorTo ~= "UIParent" and not frame:GetAttribute("oUF-headerType") then
		if anchor:GetAttribute("oUF-headerType") then
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
	elseif position.anchorTo ~= "UIParent" and frame:GetAttribute("oUF-headerType") then
		if anchor:GetAttribute("oUF-headerType") then
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
	elseif position.anchorTo == "UIParent" and frame:GetAttribute("oUF-headerType") then
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