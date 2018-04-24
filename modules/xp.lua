local XP = {}
local L = LunaUF.L
local ttshown
LunaUF:RegisterModule(XP, "xpBar", L["XP/Rep bar"], true)

local function OnEvent()
	XP:Update(this:GetParent())
end

local function OnEnter()
	ttshown = true
	if( this.tooltip ) then
		GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
		GameTooltip:SetText(this.tooltip)
	end
end

local function OnLeave()
	ttshown = nil
	GameTooltip:Hide()
end

local function OnClick()
	LunaUF.clickedButton = arg1
	this:GetParent():Click(arg1)
end

-- Format 5000 into 5,000 Thanks Shadowed! :D
local function formatNumber(number)
	local found
	while( true ) do
		number, found = string.gsub(number, "^(-?%d+)(%d%d%d)", "%1,%2")
		if( found == 0 ) then break end
	end
	
	return number
end

function XP:OnEnable(frame)
	if( not frame.xpBar ) then
		frame.xpBar = CreateFrame("Button", nil, frame)
		frame.xpBar:SetScript("OnEnter", OnEnter)
		frame.xpBar:SetScript("OnLeave", OnLeave)
		frame.xpBar:SetScript("OnClick", OnClick)
		local click_action = LunaUF.db.profile.clickcasting.mouseDownClicks and "Down" or "Up"
		frame.xpBar:RegisterForClicks('LeftButton' .. click_action, 'RightButton' .. click_action, 'MiddleButton' .. click_action, 'Button4' .. click_action, 'Button5' .. click_action)
		frame.xpBar:EnableMouse(true)
		
		frame.xpBar.xp = LunaUF.Units:CreateBar(frame.xpBar)
		frame.xpBar.xp:SetPoint("TOP", frame.xpBar, "TOP")
				
		if( frame.unitGroup == "player" ) then
			frame.xpBar.unit = "player"
			frame.xpBar.rep = LunaUF.Units:CreateBar(frame.xpBar)
			frame.xpBar.rep:SetPoint("BOTTOM", frame.xpBar, "BOTTOM")
		else
			frame.xpBar.unit = "pet"
		end
		
		frame.xpBar.rested = CreateFrame("StatusBar", nil, frame.xpBar.xp)
		frame.xpBar.rested:SetFrameLevel(frame.xpBar.xp:GetFrameLevel() - 1)
		frame.xpBar.rested:SetAllPoints(frame.xpBar.xp)
	end

	if( frame.unitGroup == "player" ) then
		frame:RegisterEvent("PLAYER_XP_UPDATE")
		frame:RegisterEvent("UPDATE_EXHAUSTION")
		frame:RegisterEvent("PLAYER_LEVEL_UP")
		frame:RegisterEvent("UPDATE_FACTION")
	else
		frame:RegisterEvent("UNIT_PET_EXPERIENCE")
		frame:RegisterEvent("UNIT_LEVEL")
	end
	frame.xpBar:SetScript("OnEvent", OnEvent)
end

function XP:OnDisable(frame)
	if frame.xpBar then
		frame.xpBar:UnregisterAllEvents()
		frame.xpBar:SetScript("OnEvent", nil)
		frame.xpBar:Hide()
	end
end

function XP:UpdateRep(frame)
	if( not frame.xpBar.rep ) then return end
	local name, reaction, min, max, current = GetWatchedFactionInfo()
	if( not name ) then
		frame.xpBar.rep:Hide()
		return
	end
	
	-- Blizzard stores faction info related to Exalted, not your current level, so get more mathier to find the current reputation using the current standing tier
	current = math.abs(min - current)
	max = math.abs(min - max)
		
	local color = FACTION_BAR_COLORS[reaction]
	frame.xpBar.rep:SetMinMaxValues(0, max)
	frame.xpBar.rep:SetValue(reaction == 8 and max or current)
	frame.xpBar.rep.tooltip = string.format("%s (%s): %s/%s (%.2f%% "..L["done"]..")", name, GetText("FACTION_STANDING_LABEL" .. reaction, UnitSex("player")), formatNumber(current), formatNumber(max), reaction == 8 and 100 or (current / max) * 100)
	frame.xpBar.rep:SetStatusBarColor(color.r, color.g, color.b, LunaUF.db.profile.bars.alpha)
	frame.xpBar.rep.background:SetVertexColor(color.r, color.g, color.b, LunaUF.db.profile.bars.backgroundAlpha)
	frame.xpBar.rep:Show()
	if frame == GameTooltip.owner then
		GameTooltip:SetText(frame.xpBar.rep.tooltip)
	end
end

function XP:UpdateXP(frame)
	local current, max
	if( frame.unitGroup == "player" ) then
		current, max = UnitXP(frame.unit), UnitXPMax(frame.unit)
	else
		current, max = GetPetExperience()
	end

	-- At the level cap so swap to reputation bar (or hide it)
	if( UnitLevel(frame.unit) == MAX_PLAYER_LEVEL or max <= 0 ) then
		frame.xpBar.xp:Hide()
		return
	end
	
	local min = math.min(0, current)
	frame.xpBar.xp:SetMinMaxValues(min, max)
	frame.xpBar.xp:SetValue(current)
	frame.xpBar.xp:Show()
	
	if( frame.unitGroup == "player" and GetXPExhaustion() ) then
		frame.xpBar.rested:SetMinMaxValues(min, max)
		frame.xpBar.rested:SetValue(math.min(current + GetXPExhaustion(), max))
		frame.xpBar.rested:Show()
		frame.xpBar.xp.tooltip = string.format(L["Level"].." %s - %s: %s/%s (%.2f%% "..L["done"].."), %s "..L["rested"]..".", UnitLevel(frame.unit), UnitLevel(frame.unit) + 1, formatNumber(current), formatNumber(max), (current / max) * 100, formatNumber(GetXPExhaustion()))
	else
		frame.xpBar.rested:Hide()
		frame.xpBar.xp.tooltip = string.format(L["Level"].." %s - %s: %s/%s (%.2f%% "..L["done"]..")", UnitLevel(frame.unit), UnitLevel(frame.unit) + 1, formatNumber(current), formatNumber(max), (current / max) * 100)
	end
	if ttshown then
		GameTooltip:SetText(frame.xpBar.xp.tooltip)
	end
end

function XP:Update(frame)
	self:UpdateRep(frame)
	self:UpdateXP(frame)

	if( ( not frame.xpBar.rep or not frame.xpBar.rep:IsShown() ) and not frame.xpBar.xp:IsShown() ) then
		if not frame.xpBar.hidden then
			frame.xpBar.hidden = true
			LunaUF.Units:PositionWidgets(frame)
		end
		return
	end
	
	if frame.xpBar.hidden then
		frame.xpBar.hidden = nil
		LunaUF.Units:PositionWidgets(frame)
	end
	if( frame.xpBar.rep and frame.xpBar.rep:IsVisible() and frame.xpBar.xp:IsVisible() ) then
		frame.xpBar.rep:SetHeight(frame.xpBar:GetHeight() * 0.48)
		frame.xpBar.rep:SetWidth(frame.xpBar:GetWidth())
		frame.xpBar.xp:SetHeight(frame.xpBar:GetHeight() * 0.48)
		frame.xpBar.xp:SetWidth(frame.xpBar:GetWidth())
		frame.xpBar.tooltip = frame.xpBar.rep.tooltip .. "\n" .. frame.xpBar.xp.tooltip

	elseif( frame.xpBar.rep and frame.xpBar.rep:IsVisible() ) then
		frame.xpBar.rep:SetHeight(frame.xpBar:GetHeight())
		frame.xpBar.rep:SetWidth(frame.xpBar:GetWidth())
		frame.xpBar.tooltip = frame.xpBar.rep.tooltip

	elseif( frame.xpBar.xp:IsVisible() ) then
		frame.xpBar.xp:SetHeight(frame.xpBar:GetHeight())
		frame.xpBar.xp:SetWidth(frame.xpBar:GetWidth())
		frame.xpBar.tooltip = frame.xpBar.xp.tooltip
	end
end

function XP:FullUpdate(frame)
	XP:Update(frame)
end

function XP:SetBarTexture(frame,texture)
	frame.xpBar.xp:SetStatusBarTexture(texture)
	frame.xpBar.xp:SetStatusBarColor(LunaUF.db.profile.xpColors.normal.r, LunaUF.db.profile.xpColors.normal.g, LunaUF.db.profile.xpColors.normal.b, LunaUF.db.profile.bars.alpha)
	
	frame.xpBar.xp.background:SetVertexColor(LunaUF.db.profile.xpColors.normal.r, LunaUF.db.profile.xpColors.normal.g, LunaUF.db.profile.xpColors.normal.b, LunaUF.db.profile.bars.backgroundAlpha)
	frame.xpBar.xp.background:SetTexture(texture)
	
	frame.xpBar.rested:SetStatusBarTexture(texture)
	frame.xpBar.rested:SetStatusBarColor(LunaUF.db.profile.xpColors.rested.r, LunaUF.db.profile.xpColors.rested.g, LunaUF.db.profile.xpColors.rested.b, LunaUF.db.profile.bars.alpha)

	if( frame.xpBar.rep ) then
		frame.xpBar.rep:SetStatusBarTexture(texture)
		frame.xpBar.rep.background:SetTexture(texture)
	end
end