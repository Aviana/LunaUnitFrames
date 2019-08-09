local Totems = {}
LunaUF:RegisterModule(Totems, "totemBar", LunaUF.L["Totem bar"], true, "SHAMAN")

local SML = LibStub:GetLibrary("LibSharedMedia-3.0")

local colors = {
	[1] = {
		r = 1,
		g = 0,
		b = 0,
	},
	[2] = {
		r = 0,
		g = 0,
		b = 1,
	},
	[3] = {
		r = 0.78,
		g = 0.61,
		b = 0.43,
	},
	[4] = {
		r = 0.41,
		g = 0.80,
		b = 0.94,
	},
}
local TotemDB = {
	[3599] = { --Searing Totem1
		["type"] = 1,
		["dur"] = 30,
	},
	[6363] = { --Searing Totem2
		["type"] = 1,
		["dur"] = 35,
	},
	[6364] = { --Searing Totem3
		["type"] = 1,
		["dur"] = 40,
	},
	[6365] = { --Searing Totem4
		["type"] = 1,
		["dur"] = 45,
	},
	[10437] = { --Searing Totem5
		["type"] = 1,
		["dur"] = 50,
	},
	[10438] = { --Searing Totem6
		["type"] = 1,
		["dur"] = 55,
	},
	[8835] = { --Grace of Air Totem1
		["type"] = 4,
		["dur"] = 120,
	},
	[10627] = { --Grace of Air Totem2
		["type"] = 4,
		["dur"] = 120,
	},
	[25359] = { --Grace of Air Totem3
		["type"] = 4,
		["dur"] = 120,
	},
	[10595] = { --Nature Resistance Totem1
		["type"] = 4,
		["dur"] = 120,
	},
	[10600] = { --Nature Resistance Totem2
		["type"] = 4,
		["dur"] = 120,
	},
	[10601] = { --Nature Resistance Totem3
		["type"] = 4,
		["dur"] = 120,
	},
	[5394] = { --Healing Stream Totem1
		["type"] = 2,
		["dur"] = 60,
	},
	[6375] = { --Healing Stream Totem2
		["type"] = 2,
		["dur"] = 60,
	},
	[6377] = { --Healing Stream Totem3
		["type"] = 2,
		["dur"] = 60,
	},
	[10462] = { --Healing Stream Totem4
		["type"] = 2,
		["dur"] = 60,
	},
	[10463] = { --Healing Stream Totem5
		["type"] = 2,
		["dur"] = 60,
	},
	[8075] = { --Strength of Earth Totem1
		["type"] = 3,
		["dur"] = 120,
	},
	[8160] = { --Strength of Earth Totem2
		["type"] = 3,
		["dur"] = 120,
	},
	[8161] = { --Strength of Earth Totem3
		["type"] = 3,
		["dur"] = 120,
	},
	[10442] = { --Strength of Earth Totem4
		["type"] = 3,
		["dur"] = 120,
	},
	[25361] = { --Strength of Earth Totem5
		["type"] = 3,
		["dur"] = 120,
	},
	[8184] = { --Fire Resistance Totem1
		["type"] = 2,
		["dur"] = 120,
	},
	[10537] = { --Fire Resistance Totem2
		["type"] = 2,
		["dur"] = 120,
	},
	[10538] = { --Fire Resistance Totem3
		["type"] = 2,
		["dur"] = 120,
	},
	[8227] = { --Flametongue Totem1
		["type"] = 1,
		["dur"] = 120,
	},
	[8249] = { --Flametongue Totem2
		["type"] = 1,
		["dur"] = 120,
	},
	[10526] = { --Flametongue Totem3
		["type"] = 1,
		["dur"] = 120,
	},
	[16387] = { --Flametongue Totem4
		["type"] = 1,
		["dur"] = 120,
	},
	[16190] = { --Mana Tide Totem1
		["type"] = 2,
		["dur"] = 12,
	},
	[17354] = { --Mana Tide Totem2
		["type"] = 2,
		["dur"] = 12,
	},
	[17359] = { --Mana Tide Totem3
		["type"] = 2,
		["dur"] = 12,
	},
	[5730] = { --Stoneclaw Totem1
		["type"] = 3,
		["dur"] = 15,
	},
	[6390] = { --Stoneclaw Totem2
		["type"] = 3,
		["dur"] = 15,
	},
	[6391] = { --Stoneclaw Totem3
		["type"] = 3,
		["dur"] = 15,
	},
	[6392] = { --Stoneclaw Totem4
		["type"] = 3,
		["dur"] = 15,
	},
	[10427] = { --Stoneclaw Totem5
		["type"] = 3,
		["dur"] = 15,
	},
	[10428] = { --Stoneclaw Totem6
		["type"] = 3,
		["dur"] = 15,
	},
	[8190] = { --Magma Totem1
		["type"] = 1,
		["dur"] = 20,
	},
	[10585] = { --Magma Totem2
		["type"] = 1,
		["dur"] = 20,
	},
	[10586] = { --Magma Totem3
		["type"] = 1,
		["dur"] = 20,
	},
	[10587] = { --Magma Totem4
		["type"] = 1,
		["dur"] = 20,
	},
	[5675] = { --Mana Spring Totem1
		["type"] = 2,
		["dur"] = 60,
	},
	[10495] = { --Mana Spring Totem2
		["type"] = 2,
		["dur"] = 60,
	},
	[10496] = { --Mana Spring Totem3
		["type"] = 2,
		["dur"] = 60,
	},
	[10497] = { --Mana Spring Totem4
		["type"] = 2,
		["dur"] = 60,
	},
	[15107] = { --Windwall Totem1
		["type"] = 4,
		["dur"] = 120,
	},
	[15111] = { --Windwall Totem2
		["type"] = 4,
		["dur"] = 120,
	},
	[15112] = { --Windwall Totem3
		["type"] = 4,
		["dur"] = 120,
	},
	[8181] = { --Frost Resistance Totem1
		["type"] = 1,
		["dur"] = 120,
	},
	[10478] = { --Frost Resistance Totem2
		["type"] = 1,
		["dur"] = 120,
	},
	[10479] = { --Frost Resistance Totem3
		["type"] = 1,
		["dur"] = 120,
	},
	[8071] = { --Stoneskin Totem1
		["type"] = 3,
		["dur"] = 120,
	},
	[8154] = { --Stoneskin Totem2
		["type"] = 3,
		["dur"] = 120,
	},
	[8155] = { --Stoneskin Totem3
		["type"] = 3,
		["dur"] = 120,
	},
	[10406] = { --Stoneskin Totem4
		["type"] = 3,
		["dur"] = 120,
	},
	[10407] = { --Stoneskin Totem5
		["type"] = 3,
		["dur"] = 120,
	},
	[10408] = { --Stoneskin Totem6
		["type"] = 3,
		["dur"] = 120,
	},
	[1535] = { --Fire Nova Totem1
		["type"] = 1,
		["dur"] = 4,
	},
	[8498] = { --Fire Nova Totem2
		["type"] = 1,
		["dur"] = 4,
	},
	[8499] = { --Fire Nova Totem3
		["type"] = 1,
		["dur"] = 4,
	},
	[11314] = { --Fire Nova Totem4
		["type"] = 1,
		["dur"] = 4,
	},
	[11315] = { --Fire Nova Totem5
		["type"] = 1,
		["dur"] = 4,
	},
	[8512] = { --Windfury Totem1
		["type"] = 4,
		["dur"] = 120,
	},
	[10613] = { --Windfury Totem2
		["type"] = 4,
		["dur"] = 120,
	},
	[10614] = { --Windfury Totem3
		["type"] = 4,
		["dur"] = 120,
	},
	[8170] = { --Disease Cleansing Totem
		["type"] = 2,
		["dur"] = 120,
	},
	[6495] = { --Sentry Totem
		["type"] = 4,
		["dur"] = 300,
	},
	[8177] = { --Grounding Totem
		["type"] = 4,
		["dur"] = 45,
	},
	[8166] = { --Poison Cleansing Totem
		["type"] = 2,
		["dur"] = 120,
	},
	[2484] = { --Earthbind Totem
		["type"] = 3,
		["dur"] = 45,
	},
	[8143] = { --Tremor Totem
		["type"] = 3,
		["dur"] = 120,
	},
	[25908] = { --Tranquil Air Totem
		["type"] = 4,
		["dur"] = 120,
	},
}
local totemsAlive = {
	[1] = false,
	[2] = false,
	[3] = false,
	[4] = false,
}

local function createBlocks(pointsFrame)
	local pointsConfig = pointsFrame.Config

	-- Position bars, the 3 accounts for borders
	local blockWidth = (pointsFrame:GetWidth() - 3) / 4
	local texPath = LunaUF.Layout:LoadMedia(SML.MediaType.STATUSBAR, LunaUF.db.profile.units.player.totemBar.statusbar)
	for id=1, 4 do
		pointsFrame.blocks[id] = pointsFrame.blocks[id] or LunaUF.Units:CreateBar(pointsFrame)
		local bar = pointsFrame.blocks[id]
		bar:SetStatusBarColor(colors[id].r, colors[id].g, colors[id].b, 1)
		bar:SetHeight(pointsFrame:GetHeight())
		bar:SetWidth(blockWidth)
		bar:ClearAllPoints()
		bar:SetStatusBarTexture(texPath)
		
		if not bar.background and pointsConfig.background then
			bar.background = pointsFrame:CreateTexture(nil, "BORDER")
			bar.background:SetAllPoints(bar)
			bar.background:SetHorizTile(false)
			bar.background:SetVertexColor(colors[id].r, colors[id].g, colors[id].b, pointsConfig.backgroundAlpha)
			bar.background:SetTexture(texPath)
		end

		if bar.background then
			bar.background:SetShown(pointsConfig.background)
		end

		if( id > 1 ) then
			bar:SetPoint("TOPLEFT", pointsFrame.blocks[id - 1], "TOPRIGHT", 1, 0)
		else
			bar:SetPoint("TOPLEFT", pointsFrame, "TOPLEFT", 0, 0)
		end
	end
end

local function onUpdateTotem(self, elapsed)
	if self.dur <= 0 then
		self:Hide()
		totemsAlive[self.id] = false
		Totems:Update(LunaUF.Units.unitFrames.player)
		return
	end
	self:SetValue(self.dur)
	self.dur = self.dur - elapsed
end

function Totems:OnEnable(frame)
	if frame.unitType ~= "player" then return end
	frame.totemBar = frame.totemBar or CreateFrame("Frame", nil, frame)
	frame.totemBar.Config = LunaUF.db.profile.units.player.totemBar

	frame.totemBar.blocks = frame.totemBar.blocks or {}

	createBlocks(frame.totemBar)

	for i=1, 4 do
		frame.totemBar.blocks[i]:SetScript("OnUpdate", onUpdateTotem)
		frame.totemBar.blocks[i]:Hide()
		frame.totemBar.blocks[i].id = i
	end

	frame:RegisterNormalEvent("COMBAT_LOG_EVENT_UNFILTERED", self, "OnCombatLog")
	frame:RegisterUpdateFunc(self, "Update")
end

function Totems:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Totems:OnCombatLog(frame)
	local _, event, _, sourceID, _, _, _, targetID, _, _, _, _, spellName = CombatLogGetCurrentEventInfo()
	local overkill
	local spellID = select(7,GetSpellInfo(spellName))
	if event == "SPELL_SUMMON" and sourceID == UnitGUID("player") then
		local type = TotemDB[spellID].type
		totemsAlive[type] = targetID
		frame.totemBar.blocks[type].dur = TotemDB[spellID].dur
		frame.totemBar.blocks[type]:SetMinMaxValues(0,TotemDB[spellID].dur)
		self:Update(frame)
	else
		for i=1, 4 do
			if totemsAlive[i] == targetID then
				if event == "SWING_DAMAGE" then
					overkill = select(13,CombatLogGetCurrentEventInfo())
				else
					overkill = select(16,CombatLogGetCurrentEventInfo())
				end
				if overkill and overkill > 0 then
					totemsAlive[i] = false
					self:Update(frame)
				end
				return
			end
		end
	end
end

function Totems:Update(frame)
	if not (totemsAlive[1] or totemsAlive[2] or totemsAlive[3] or totemsAlive[4]) then
		if LunaUF.db.profile.units.player.totemBar.autoHide then
			LunaUF.Layout:SetBarVisibility(frame, "totemBar", false)
		else
			LunaUF.Layout:SetBarVisibility(frame, "totemBar", true)
		end
	else
		LunaUF.Layout:SetBarVisibility(frame, "totemBar", true)
	end
	
	for id, block in pairs(frame.totemBar.blocks) do
		if( totemsAlive[id] ) then
			block:Show()
		else
			block:Hide()
		end
	end
end

function Totems:OnLayoutApplied(frame)
	local pointsFrame = frame.totemBar
	if( not pointsFrame ) then return end

	pointsFrame:SetFrameLevel(frame.topFrameLevel + 1)

	if( not frame.visibility.totemBar ) then return end

	createBlocks(pointsFrame)
end

function Totems:OnLayoutWidgets(frame)
	local totemBar = frame.totemBar
	if( not frame.visibility.totemBar or not totemBar.blocks) then return end

	local height = totemBar:GetHeight()
	for _, block in pairs(totemBar.blocks) do
		block:SetHeight(height)
	end
end