local ReckStacks = {}
LunaUF:RegisterModule(ReckStacks, "reckStacks", LunaUF.L["Reckoning Stacks"])
local _,playerclass = UnitClass("player")
local currStacks = 0
local talentRank

local events

if ( GetLocale() == "deDE" ) then
	events = {
		CHAT_MSG_COMBAT_SELF_HITS = "Ihr trefft .+",
		CHAT_MSG_COMBAT_FRIENDLY_DEATH = "Ihr sterbt.",

		CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS = ".+ trifft (%a+) kritisch: %d+ Schaden%.",
		CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS = ".+ trifft (Euch) kritisch: %d+ Schaden%.",

		CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE = ".+s .+ trifft (%a+) kritisch: .+",
		CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE = ".+s .+ trifft (Euch) kritisch: .+",
	}
else
	events = {
		CHAT_MSG_COMBAT_SELF_HITS = "You c?[rh]it .+ for .+",
		CHAT_MSG_COMBAT_FRIENDLY_DEATH = "You die.",
		
		CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS = ".+ crits (%a+) for .+",
		CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS = ".+ crits (you) for .+",
		
		CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE = ".+'s .+ crits (%a+) for .+",
		CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE = ".+'s .+ crits (you) for .+",
	}
end

local function OnEvent()
	if event == "CHARACTER_POINTS_CHANGED" then
		_,_,_,_,talentRank = GetTalentInfo(2,13)
	elseif event == "CHAT_MSG_COMBAT_SELF_HITS" or (event == "CHAT_MSG_COMBAT_FRIENDLY_DEATH" and arg1 == events[event]) then
		if currStacks > 0 then
			currStacks = 0
			ReckStacks:Update(this:GetParent())
		else
			return
		end
	elseif talentRank == 5 and currStacks < 5 and string.find(arg1, events[event]) then
		currStacks = currStacks + 1
		ReckStacks:Update(this:GetParent())
	end
end

function ReckStacks:OnEnable(frame)
	if (playerclass ~= "PALADIN") or frame.unitGroup ~= "player" then return end
	if not frame.reckStacks then
		frame.reckStacks = CreateFrame("Frame", nil, frame)
		frame.reckStacks.blocks = {}
		for id=1, 5 do
			frame.reckStacks.blocks[id] = frame.reckStacks.blocks[id] or frame.reckStacks:CreateTexture(nil, "OVERLAY")
		end
	end
	_,_,_,_,talentRank = GetTalentInfo(2,13)
	for i in pairs(events) do frame.reckStacks:RegisterEvent(i) end
	frame.reckStacks:RegisterEvent("CHARACTER_POINTS_CHANGED")
	frame.reckStacks:SetScript("OnEvent", OnEvent)
end

function ReckStacks:OnDisable(frame)
	if frame.reckStacks then
		frame.reckStacks:UnregisterAllEvents()
		frame.reckStacks:SetScript("OnEvent", nil)
	end
end

function ReckStacks:Update(frame)
	if currStacks == 0 then
		if LunaUF.db.profile.units[frame.unitGroup].reckStacks.hide and not frame.reckStacks.hidden then
			frame.reckStacks.hidden = true
			LunaUF.Units:PositionWidgets(frame)
		elseif not LunaUF.db.profile.units[frame.unitGroup].reckStacks.hide and frame.reckStacks.hidden then
			frame.reckStacks.hidden = nil
			LunaUF.Units:PositionWidgets(frame)
		end
	else
		if frame.reckStacks.hidden then
			frame.reckStacks.hidden = false
			LunaUF.Units:PositionWidgets(frame)
		end
	end
	for id,block in ipairs(frame.reckStacks.blocks) do
		if id <= currStacks then
			block:Show()
		else
			block:Hide()
		end
	end
end

function ReckStacks:FullUpdate(frame)
	local blockWidth = (frame.reckStacks:GetWidth() - 4) / 5
	for id=1, 5 do
		local texture = frame.reckStacks.blocks[id]
		texture:SetHeight(frame.reckStacks:GetHeight())
		texture:SetWidth(blockWidth)
		texture:ClearAllPoints()
		if( LunaUF.db.profile.units[frame.unitGroup].reckStacks.growth == "LEFT" ) then
			if( id > 1 ) then
				texture:SetPoint("TOPRIGHT", frame.reckStacks.blocks[id - 1], "TOPLEFT", -1, 0)
			else
				texture:SetPoint("TOPRIGHT", frame.reckStacks, "TOPRIGHT", 0, 0)
			end
		else
			if( id > 1 ) then
				texture:SetPoint("TOPLEFT", frame.reckStacks.blocks[id - 1], "TOPRIGHT", 1, 0)
			else
				texture:SetPoint("TOPLEFT", frame.reckStacks, "TOPLEFT", 0, 0)
			end
		end
	end
	ReckStacks:Update(frame)
end

function ReckStacks:SetBarTexture(frame,texture)
	if frame.reckStacks then
		for _,block in pairs(frame.reckStacks.blocks) do
			block:SetTexture(texture)
			block:SetVertexColor(1, 0.80, 0)
		end
	end
end