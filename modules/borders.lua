local LunaUF = LunaUF
local Borders = {}
LunaUF:RegisterModule(Borders, "borders", LunaUF.L["Borders"])
local L = LunaUF.L
local banzai = LunaUF.Banzai
local ScanTip = LunaUF.ScanTip
local positions = {"TOP","BOTTOM","LEFT","RIGHT"}

local function SetColor(frame, r, g, b, a)
	for _,pos in ipairs(positions) do
		frame.borders.parts[pos]:SetVertexColor(r,g,b,a)
	end
end

local function OnEvent()
	local frame = this:GetParent()
	Borders:OnAura(frame)
end

local function SetSize(parent)
	local frame = parent or this
	for _,pos in ipairs(positions) do
		if pos == "TOP" or pos == "BOTTOM" then
			frame.borders.parts[pos]:SetHeight(1)
			frame.borders.parts[pos]:SetWidth(frame:GetWidth())
		else
			frame.borders.parts[pos]:SetHeight(frame:GetHeight())
			frame.borders.parts[pos]:SetWidth(1)
		end
		frame.borders.parts[pos]:SetVertexColor(0,0,0,0)
	end
end

function Borders:OnEnable(frame)
	if not frame.borders then
		frame.borders = CreateFrame("Frame", nil, frame)
		frame.borders.parts = {}
		for _,pos in ipairs(positions) do
			frame.borders.parts[pos] = frame:CreateTexture(nil, "ARTWORK")
			frame.borders.parts[pos]:SetTexture(1,1,1)
			frame.borders.parts[pos]:SetPoint("CENTER", frame, pos)
		end
	end
	frame.borders:RegisterEvent("UNIT_AURA")
	frame.borders:SetScript("OnEvent", OnEvent)
	frame:SetScript("OnSizeChanged",SetSize)
	SetSize(frame)
end

function Borders:OnDisable(frame)
	if frame.borders then
		frame.borders:UnregisterAllEvents()
		frame.borders:SetScript("OnEvent", nil)
		SetColor(frame, 0, 0, 0, 0)
	end
end

function Borders:OnAggro(frame)
	local config = LunaUF.db.profile.units[frame.unitGroup].borders
	local aggro = banzai:GetUnitAggroByUnitId(frame.unit)
	if config.mode == "aggro" then
		if aggro then
			SetColor(frame, 1, 0, 0, 1)
		else
			SetColor(frame, 0, 0, 0, 0)
		end
	end
end

function Borders:OnAura(frame)
	local config = LunaUF.db.profile.units[frame.unitGroup].borders
	local SquareConfig = LunaUF.db.profile.units.raid.squares
	local debuffed = 4
	local buffname, disptype
	if config.mode == "track" then
		for i=1,16 do
			ScanTip:ClearLines()
			ScanTip:SetUnitDebuff(frame.unit,i)
			buffname = LunaScanTipTextLeft1:GetText() or ""
			buffname = string.lower(buffname)
			for key,debuff in pairs(SquareConfig.debuffs.names) do
				if debuff ~= "" and string.find(buffname, debuff) then
					if key < debuffed then
						debuffed = key
					end
				end
			end
		end
		if debuffed < 4 then
			SetColor(frame, SquareConfig.debuffs.colors[debuffed].r, SquareConfig.debuffs.colors[debuffed].g, SquareConfig.debuffs.colors[debuffed].b, 1)
		else
			SetColor(frame, 0, 0, 0, 0)
		end
	elseif config.mode == "dispel" then
		for i=1,16 do
			_,_,disptype = UnitDebuff(frame.unit,i,config.owndispdebuffs)
			if disptype then
				local r,g,b = unpack(LunaUF.db.profile.magicColors[disptype])
				SetColor(frame, r, g, b, 1)
				return
			end
		end
		SetColor(frame, 0, 0, 0, 0)
	end
end

function Borders:FullUpdate(frame)
	self:OnAggro(frame)
	self:OnAura(frame)
end
