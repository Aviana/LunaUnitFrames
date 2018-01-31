local LunaUF = LunaUF
local Squares = {}
local HealComm = LunaUF.HealComm
local banzai = LunaUF.Banzai
local ScanTip = LunaUF.ScanTip
local BS = LunaUF.BS
local buffs = {}
local debuffs = {}
local _,playerclass = UnitClass("player")
LunaUF:RegisterModule(Squares, "squares", LunaUF.L["Status tracker"])

local function OnEvent()
	local frame = this:GetParent()
	if arg1 ~= frame.unit then return end
	Squares:UpdateAuras(frame)
end

local function OnTimer(unit)
	if not unit then return end
	for _,frame in pairs(LunaUF.Units.frameList) do
		if frame.squares and frame.unit and UnitIsUnit(frame.unit,unit) then
			Squares:UpdateTimers(frame)
		end
	end
end

local function OnAggro(unit)
	for _,frame in pairs(LunaUF.Units.frameList) do
		if frame.unit and UnitIsUnit(frame.unit,unit) then
			Squares:UpdateAggro(frame)
			LunaUF.modules.borders:OnAggro(frame)
		end
	end
end

function Squares:OnEnable(frame)
	if( not frame.squares ) then
		frame.squares = CreateFrame("Frame", frame:GetName().."SquareModule", frame)
		frame.squares:SetAllPoints(frame)
		frame.squares:SetFrameLevel(6)
		
		frame.squares.buffs = {}
		frame.squares.debuffs = {}
		frame.squares.trackdebuffs = {}
		frame.squares.centericons = {}
		
		for i = 1, 3 do
			frame.squares.buffs[i] = CreateFrame("Frame", nil, frame.squares)
			frame.squares.buffs[i]:SetBackdrop(LunaUF.constants.backdrop)
			frame.squares.buffs[i]:SetBackdropColor(0,0,0)
			frame.squares.buffs[i].texture = frame.squares.buffs[i]:CreateTexture(nil, "ARTWORK")
			frame.squares.buffs[i].texture:SetAllPoints(frame.squares.buffs[i])

			frame.squares.debuffs[i] = CreateFrame("Frame", nil, frame.squares)
			frame.squares.debuffs[i]:SetBackdrop(LunaUF.constants.backdrop)
			frame.squares.debuffs[i]:SetBackdropColor(0,0,0)
			frame.squares.debuffs[i].texture = frame.squares.debuffs[i]:CreateTexture(nil, "ARTWORK")
			frame.squares.debuffs[i].texture:SetAllPoints(frame.squares.debuffs[i])
			
			frame.squares.trackdebuffs[i] = CreateFrame("Frame", nil, frame.squares)
			frame.squares.trackdebuffs[i]:SetBackdrop(LunaUF.constants.backdrop)
			frame.squares.trackdebuffs[i]:SetBackdropColor(0,0,0)
			frame.squares.trackdebuffs[i].texture = frame.squares.trackdebuffs[i]:CreateTexture(nil, "ARTWORK")
			frame.squares.trackdebuffs[i].texture:SetAllPoints(frame.squares.trackdebuffs[i])
			
			frame.squares.centericons[i] = frame.squares:CreateTexture(nil, "ARTWORK")
			frame.squares.centericons[i]:ClearAllPoints()
			frame.squares.centericons[i].cd = CreateFrame("Model", frame:GetName().."CD"..i, frame.squares , "CooldownFrameTemplate")
			frame.squares.centericons[i].cd:ClearAllPoints()
			frame.squares.centericons[i].cd:SetPoint("TOPLEFT", frame.squares.centericons[i], "TOPLEFT")
			frame.squares.centericons[i].cd:SetHeight(36)
			frame.squares.centericons[i].cd:SetWidth(36)
		end
		
		frame.squares.buffs[1]:SetPoint("TOPRIGHT", frame.squares, "TOPRIGHT")
		frame.squares.buffs[2]:SetPoint("RIGHT", frame.squares.buffs[1], "LEFT")
		frame.squares.buffs[3]:SetPoint("TOP", frame.squares.buffs[1], "BOTTOM")
		
		frame.squares.debuffs[1]:SetPoint("TOPLEFT", frame.squares, "TOPLEFT")
		frame.squares.debuffs[2]:SetPoint("LEFT", frame.squares.debuffs[1], "RIGHT")
		frame.squares.debuffs[3]:SetPoint("TOP", frame.squares.debuffs[1], "BOTTOM")
		
		frame.squares.trackdebuffs[1]:SetPoint("BOTTOMRIGHT", frame.squares, "BOTTOMRIGHT")
		frame.squares.trackdebuffs[2]:SetPoint("RIGHT", frame.squares.trackdebuffs[1], "LEFT")
		frame.squares.trackdebuffs[3]:SetPoint("BOTTOM", frame.squares.trackdebuffs[1], "TOP")
		
		frame.squares.centericons[1]:SetPoint("CENTER", frame.squares, "CENTER")
		frame.squares.centericons[1]:SetTexture("Interface\\Icons\\Spell_Nature_Rejuvenation")
		frame.squares.centericons[2]:SetPoint("RIGHT", frame.squares.centericons[1], "LEFT")
		frame.squares.centericons[2]:SetTexture("Interface\\Icons\\Spell_Holy_Renew")
		frame.squares.centericons[3]:SetPoint("LEFT", frame.squares.centericons[1], "RIGHT")
		frame.squares.centericons[3]:SetTexture("Interface\\Icons\\Spell_Nature_ResistNature")
		
		frame.squares.aggro = CreateFrame("Frame", nil, frame.squares)
		frame.squares.aggro:SetBackdrop(LunaUF.constants.backdrop)
		frame.squares.aggro:SetBackdropColor(0,0,0)
		frame.squares.aggro.texture = frame.squares.aggro:CreateTexture(nil, "ARTWORK")
		frame.squares.aggro.texture:SetAllPoints(frame.squares.aggro)
		frame.squares.aggro:SetPoint("BOTTOMLEFT", frame.squares, "BOTTOMLEFT")
	end
	frame.squares:Show()
	frame.squares:RegisterEvent("UNIT_AURA")
	frame.squares:SetScript("OnEvent", OnEvent)
	if not LunaUF:IsEventRegistered("HealComm_Hotupdate") then
		LunaUF:RegisterEvent("HealComm_Hotupdate", OnTimer)
	end
	if not LunaUF:IsEventRegistered("Banzai_UnitGainedAggro") then
		LunaUF:RegisterEvent("Banzai_UnitGainedAggro", OnAggro)
	end
	if not LunaUF:IsEventRegistered("Banzai_UnitLostAggro") then
		LunaUF:RegisterEvent("Banzai_UnitLostAggro", OnAggro)
	end
end

function Squares:OnDisable(frame)
	if( frame.squares ) then
		frame.squares:Hide()
	end
end

function Squares:UpdateTimers(frame)
	if not LunaUF.db.profile.units.raid.squares.hottracker then	return end
	local start, dur = HealComm:getRejuTime(frame.unit)
	if start then
		LunaCooldownFrame_SetTimer(frame.squares.centericons[1].cd, tonumber(start), tonumber(dur), 1, 1)
	else
		frame.squares.centericons[1].cd:Hide()
	end
	start, dur = HealComm:getRenewTime(frame.unit)
	if start then
		LunaCooldownFrame_SetTimer(frame.squares.centericons[2].cd, tonumber(start), tonumber(dur), 1, 1)
	else
		frame.squares.centericons[2].cd:Hide()
	end
	start, dur = HealComm:getRegrTime(frame.unit)
	if start then
		LunaCooldownFrame_SetTimer(frame.squares.centericons[3].cd, tonumber(start), tonumber(dur), 1, 1)
	else
		frame.squares.centericons[3].cd:Hide()
	end
end

function Squares:UpdateAggro(frame)
	local aggro = banzai:GetUnitAggroByUnitId(frame.unit)
	if frame.squares then
		if aggro and LunaUF.db.profile.units.raid.squares.aggro then
			frame.squares.aggro:Show()
		else
			frame.squares.aggro:Hide()
		end
	end
end

function Squares:UpdateAuras(frame)
	local config = LunaUF.db.profile.units.raid.squares
	local i = 1
	local num = 1
	local disptype, texture
	local buffname
	
	for _,icon in pairs(frame.squares.centericons) do
		icon:Hide()
	end
	for _,icon in pairs(frame.squares.buffs) do
		icon:Hide()
	end
	for _,icon in pairs(frame.squares.debuffs) do
		icon:Hide()
	end
	for _,icon in pairs(frame.squares.trackdebuffs) do
		icon:Hide()
	end
	for k,_ in pairs(buffs) do
		buffs[k] = nil
	end
	for k,_ in pairs(debuffs) do
		debuffs[k] = nil
	end
	
	while UnitBuff(frame.unit,i) do
		ScanTip:ClearLines()
		ScanTip:SetUnitBuff(frame.unit,i)
		buffname = LunaScanTipTextLeft1:GetText() or ""
		if config.hottracker then
			if buffname == BS["Rejuvenation"] then
				frame.squares.centericons[1]:Show()
			elseif buffname == BS["Renew"] then
				frame.squares.centericons[2]:Show()
			elseif buffname == BS["Regrowth"] then
				frame.squares.centericons[3]:Show()
			end
		end
		buffname = string.lower(buffname)
		for key,buff in pairs(config.buffs.names) do
			if buff ~= "" and string.find(buffname, string.lower(buff)) then
				buffs[key] = UnitBuff(frame.unit, i)
				break
			end
		end
		
		i = i + 1
	end

	i = 1
	for k,v in pairs(config.buffs.names) do
		if v ~= "" then
			local invert = false
			if k == 1 and LunaUF.db.profile.units.raid.squares.invertfirstbuff then invert = true end
			if k == 2 and LunaUF.db.profile.units.raid.squares.invertsecondbuff then invert = true end
			if k == 3 and LunaUF.db.profile.units.raid.squares.invertthirdbuff then invert = true end

			if invert then
				if not buffs[k] then
					if config.buffcolors then
						frame.squares.buffs[i].texture:SetTexture(config.buffs.colors[k].r,config.buffs.colors[k].g,config.buffs.colors[k].b)
					else
						frame.squares.buffs[i].texture:SetTexture(BS:GetSpellIcon(v))
					end
					frame.squares.buffs[i]:Show()
					i = i + 1
				end
			else
				if buffs[k] then
					if config.buffcolors then
						frame.squares.buffs[i].texture:SetTexture(config.buffs.colors[k].r,config.buffs.colors[k].g,config.buffs.colors[k].b)
					else
						frame.squares.buffs[i].texture:SetTexture(buffs[k])
					end
					frame.squares.buffs[i]:Show()
					i = i + 1
				end
			end
		end
	end

	i = 1
	while UnitDebuff(frame.unit,i) do
		ScanTip:ClearLines()
		ScanTip:SetUnitDebuff(frame.unit,i)
		buffname = LunaScanTipTextLeft1:GetText() or ""

		texture,_,disptype = UnitDebuff(frame.unit,i,config.owndispdebuffs)
		if texture and config.enabledebuffs and (not config.dispellabledebuffs or disptype) and num <= 3 then
			if config.debuffcolors then
				if disptype then
					local r,g,b = unpack(LunaUF.db.profile.magicColors[disptype])
					frame.squares.debuffs[num].texture:SetTexture(r,g,b)
				else
					frame.squares.debuffs[num].texture:SetTexture(0,0,0)
				end
			else
				frame.squares.debuffs[num].texture:SetTexture(texture)
			end
			frame.squares.debuffs[num]:Show()
			num = num + 1
		end
		
		buffname = string.lower(buffname)
		for key,debuff in pairs(config.debuffs.names) do
			if debuff ~= "" and string.find(buffname, debuff) then
				debuffs[key] = UnitDebuff(frame.unit, i)
				break
			end
		end
		i = i + 1
	end
	i = 1
	for k,v in pairs(debuffs) do
		if config.debuffcolors then
			frame.squares.trackdebuffs[i].texture:SetTexture(config.debuffs.colors[k].r,config.debuffs.colors[k].g,config.debuffs.colors[k].b)
		else
			frame.squares.trackdebuffs[i].texture:SetTexture(v)
		end
		frame.squares.trackdebuffs[i]:Show()
		i = i + 1
	end
	
end

function Squares:FullUpdate(frame)
	if not frame.squares then return end
	local config = LunaUF.db.profile.units.raid.squares
	for i=1, 3 do
		frame.squares.buffs[i]:SetHeight(config.outersize)
		frame.squares.buffs[i]:SetWidth(config.outersize)
		
		frame.squares.debuffs[i]:SetHeight(config.outersize)
		frame.squares.debuffs[i]:SetWidth(config.outersize)
		
		frame.squares.trackdebuffs[i]:SetHeight(config.outersize)
		frame.squares.trackdebuffs[i]:SetWidth(config.outersize)
		
		frame.squares.centericons[i]:SetHeight(config.innersize)
		frame.squares.centericons[i]:SetWidth(config.innersize)
		frame.squares.centericons[i].cd:SetScale(config.innersize/36)
	end
	
	frame.squares.aggro:SetWidth(config.outersize)
	frame.squares.aggro:SetHeight(config.outersize)
	frame.squares.aggro.texture:SetTexture(config.aggrocolor.r,config.aggrocolor.g,config.aggrocolor.b)
	
	Squares:UpdateTimers(frame)
	Squares:UpdateAggro(frame)
	Squares:UpdateAuras(frame)
end
