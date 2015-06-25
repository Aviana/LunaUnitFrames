local Luna_Pet_Events = {}
	
local function Luna_Pet_SetBuffTooltip()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	if (this.id > 16) then
		GameTooltip:SetUnitDebuff("pet", this.id-16)
	else
		GameTooltip:SetUnitBuff("pet", this.id)
	end
end

local function Luna_Pet_SetBuffTooltipLeave()
	GameTooltip:Hide()
end

local function Luna_Pet_OnEvent()
	local func = Luna_Pet_Events[event]
	if (func) then
		func()
	else
		DEFAULT_CHAT_FRAME:AddMessage("Luna Unit Frames - Pet: Report the following event error to the author: "..event)
	end
end

local function StartMoving()
	LunaPetFrame:StartMoving()
end

local function StopMovingOrSizing()
	LunaPetFrame:StopMovingOrSizing()
	_,_,_,LunaOptions.frames["LunaPetFrame"].position.x, LunaOptions.frames["LunaPetFrame"].position.y = LunaPetFrame:GetPoint()
end

function LunaUnitFrames:TogglePetLock()
	if LunaPetFrame:IsMovable() then
		LunaPetFrame:SetScript("OnDragStart", nil)
		LunaPetFrame:SetMovable(0)
	else
		LunaPetFrame:SetScript("OnDragStart", StartMoving)
		LunaPetFrame:SetMovable(1)
	end
end

function LunaUnitFrames:CreatePetFrame()	
	LunaPetFrame = CreateFrame("Button", "LunaPetFrame", UIParent)

	LunaPetFrame:SetHeight(LunaOptions.frames["LunaPetFrame"].size.y)
	LunaPetFrame:SetWidth(LunaOptions.frames["LunaPetFrame"].size.x)
	LunaPetFrame:SetScale(LunaOptions.frames["LunaPetFrame"].scale)
	LunaPetFrame:SetBackdrop(LunaOptions.backdrop)
	LunaPetFrame:SetBackdropColor(0,0,0,1)
	LunaPetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["LunaPetFrame"].position.x, LunaOptions.frames["LunaPetFrame"].position.y)
	LunaPetFrame:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
	LunaPetFrame.unit = "pet"
	LunaPetFrame:SetScript("OnEnter", UnitFrame_OnEnter)
	LunaPetFrame:SetScript("OnLeave", UnitFrame_OnLeave)
	LunaPetFrame:SetMovable(0)
	LunaPetFrame:RegisterForDrag("LeftButton")
	LunaPetFrame:SetScript("OnDragStop", StopMovingOrSizing)
	LunaPetFrame:SetClampedToScreen(1)
	LunaPetFrame:SetFrameStrata("BACKGROUND")

	LunaPetFrame.AuraAnchor = CreateFrame("Frame", nil, LunaPetFrame)	
	
	local barsettings = {}
	for k,v in pairs(LunaOptions.frames["LunaPetFrame"].bars) do
		barsettings[v[1]] = {}
		barsettings[v[1]][1] = v[4]
		barsettings[v[1]][2] = v[5]
	end
	
	LunaPetFrame.Buffs = {}

	LunaPetFrame.Buffs[1] = CreateFrame("Button", "LunaPetFrameBuff1", LunaPetFrame.AuraAnchor)
	LunaPetFrame.Buffs[1].texturepath = UnitBuff(LunaPetFrame.unit,1)
	LunaPetFrame.Buffs[1].id = 1
	LunaPetFrame.Buffs[1]:SetNormalTexture(LunaPetFrame.Buffs[1].texturepath)
	LunaPetFrame.Buffs[1]:SetScript("OnEnter", Luna_Pet_SetBuffTooltip)
	LunaPetFrame.Buffs[1]:SetScript("OnLeave", Luna_Pet_SetBuffTooltipLeave)

	LunaPetFrame.Buffs[1].stacks = LunaPetFrame.Buffs[1]:CreateFontString(nil, "OVERLAY", LunaPetFrame.Buffs[1])
	LunaPetFrame.Buffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaPetFrame.Buffs[1], 0, 0)
	LunaPetFrame.Buffs[1].stacks:SetJustifyH("LEFT")
	LunaPetFrame.Buffs[1].stacks:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.Buffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaPetFrame.Buffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaPetFrame.Buffs[1].stacks:SetTextColor(1,1,1)
	LunaPetFrame.Buffs[1].stacks:SetText("8")

	for z=2, 16 do
		LunaPetFrame.Buffs[z] = CreateFrame("Button", "LunaPetFrameBuff"..z, LunaPetFrame.AuraAnchor)
		LunaPetFrame.Buffs[z].texturepath = UnitBuff(LunaPetFrame.unit,z)
		LunaPetFrame.Buffs[z].id = z
		LunaPetFrame.Buffs[z]:SetNormalTexture(LunaPetFrame.Buffs[z].texturepath)
		LunaPetFrame.Buffs[z]:SetScript("OnEnter", Luna_Pet_SetBuffTooltip)
		LunaPetFrame.Buffs[z]:SetScript("OnLeave", Luna_Pet_SetBuffTooltipLeave)
		
		LunaPetFrame.Buffs[z].stacks = LunaPetFrame.Buffs[z]:CreateFontString(nil, "OVERLAY", LunaPetFrame.Buffs[z])
		LunaPetFrame.Buffs[z].stacks:SetPoint("BOTTOMRIGHT", LunaPetFrame.Buffs[z], 0, 0)
		LunaPetFrame.Buffs[z].stacks:SetJustifyH("LEFT")
		LunaPetFrame.Buffs[z].stacks:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPetFrame.Buffs[z].stacks:SetShadowColor(0, 0, 0)
		LunaPetFrame.Buffs[z].stacks:SetShadowOffset(0.8, -0.8)
		LunaPetFrame.Buffs[z].stacks:SetTextColor(1,1,1)
		LunaPetFrame.Buffs[z].stacks:SetText("8")
	end

	LunaPetFrame.Debuffs = {}

	LunaPetFrame.Debuffs[1] = CreateFrame("Button", "LunaPetFrameDebuff1", LunaPetFrame.AuraAnchor)
	LunaPetFrame.Debuffs[1].texturepath = UnitDebuff(LunaPetFrame.unit,1)
	LunaPetFrame.Debuffs[1].id = 17
	LunaPetFrame.Debuffs[1]:SetNormalTexture(LunaPetFrame.Debuffs[1].texturepath)
	LunaPetFrame.Debuffs[1]:SetScript("OnEnter", Luna_Pet_SetBuffTooltip)
	LunaPetFrame.Debuffs[1]:SetScript("OnLeave", Luna_Pet_SetBuffTooltipLeave)

	LunaPetFrame.Debuffs[1].stacks = LunaPetFrame.Debuffs[1]:CreateFontString(nil, "OVERLAY", LunaPetFrame.Debuffs[1])
	LunaPetFrame.Debuffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaPetFrame.Debuffs[1], 0, 0)
	LunaPetFrame.Debuffs[1].stacks:SetJustifyH("LEFT")
	LunaPetFrame.Debuffs[1].stacks:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.Debuffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaPetFrame.Debuffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaPetFrame.Debuffs[1].stacks:SetTextColor(1,1,1)
	LunaPetFrame.Debuffs[1].stacks:SetText("8")

	for z=2, 16 do
		LunaPetFrame.Debuffs[z] = CreateFrame("Button", "LunaPetFrameDebuff"..z, LunaPetFrame.AuraAnchor)
		LunaPetFrame.Debuffs[z].texturepath = UnitDebuff(LunaPetFrame.unit,z)
		LunaPetFrame.Debuffs[z].id = z+16
		LunaPetFrame.Debuffs[z]:SetNormalTexture(LunaPetFrame.Debuffs[z].texturepath)
		LunaPetFrame.Debuffs[z]:SetScript("OnEnter", Luna_Pet_SetBuffTooltip)
		LunaPetFrame.Debuffs[z]:SetScript("OnLeave", Luna_Pet_SetBuffTooltipLeave)
		
		LunaPetFrame.Debuffs[z].stacks = LunaPetFrame.Debuffs[z]:CreateFontString(nil, "OVERLAY", LunaPetFrame.Debuffs[z])
		LunaPetFrame.Debuffs[z].stacks:SetPoint("BOTTOMRIGHT", LunaPetFrame.Debuffs[z], 0, 0)
		LunaPetFrame.Debuffs[z].stacks:SetJustifyH("LEFT")
		LunaPetFrame.Debuffs[z].stacks:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPetFrame.Debuffs[z].stacks:SetShadowColor(0, 0, 0)
		LunaPetFrame.Debuffs[z].stacks:SetShadowOffset(0.8, -0.8)
		LunaPetFrame.Debuffs[z].stacks:SetTextColor(1,1,1)
		LunaPetFrame.Debuffs[z].stacks:SetText("8")
	end

	LunaPetFrame.bars = {}
	
	LunaPetFrame.bars["Portrait"] = CreateFrame("Frame", nil, LunaPetFrame)
	
	LunaPetFrame.bars["Portrait"].texture = LunaPetFrame.bars["Portrait"]:CreateTexture("PetPortrait", "ARTWORK")
	LunaPetFrame.bars["Portrait"].texture:SetAllPoints(LunaPetFrame.bars["Portrait"])
	
	LunaPetFrame.bars["Portrait"].model = CreateFrame("PlayerModel", nil, LunaPetFrame)
	LunaPetFrame.bars["Portrait"].model:SetPoint("TOPLEFT", LunaPetFrame.bars["Portrait"], "TOPLEFT")
	LunaPetFrame.bars["Portrait"].model:SetScript("OnShow",function() this:SetCamera(0) end)

	-- Healthbar
	LunaPetFrame.bars["Healthbar"] = CreateFrame("StatusBar", nil, LunaPetFrame)
	LunaPetFrame.bars["Healthbar"]:SetStatusBarTexture(LunaOptions.statusbartexture)


	-- Healthbar background
	LunaPetFrame.bars["Healthbar"].hpbg = LunaPetFrame.bars["Healthbar"]:CreateTexture(nil, "BORDER")
	LunaPetFrame.bars["Healthbar"].hpbg:SetAllPoints(LunaPetFrame.bars["Healthbar"])
	LunaPetFrame.bars["Healthbar"].hpbg:SetTexture(.25,.25,.25,.25)

	-- Healthbar text
	LunaPetFrame.bars["Healthbar"].righttext = LunaPetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaPetFrame.bars["Healthbar"])
	LunaPetFrame.bars["Healthbar"].righttext:SetPoint("RIGHT", -2, 0)
	LunaPetFrame.bars["Healthbar"].righttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.bars["Healthbar"].righttext:SetShadowColor(0, 0, 0)
	LunaPetFrame.bars["Healthbar"].righttext:SetShadowOffset(0.8, -0.8)
	LunaPetFrame.bars["Healthbar"].righttext:SetJustifyH("RIGHT")
	LunaPetFrame.bars["Healthbar"].righttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaPetFrame.bars["Healthbar"].righttext, "pet", barsettings["Healthbar"][2] or LunaOptions.defaultTags["Healthbar"][2])

	LunaPetFrame.bars["Healthbar"].lefttext = LunaPetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaPetFrame.bars["Healthbar"])
	LunaPetFrame.bars["Healthbar"].lefttext:SetPoint("LEFT", 2, 0)
	LunaPetFrame.bars["Healthbar"].lefttext:SetJustifyH("LEFT")
	LunaPetFrame.bars["Healthbar"].lefttext:SetJustifyV("MIDDLE")
	LunaPetFrame.bars["Healthbar"].lefttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.bars["Healthbar"].lefttext:SetShadowColor(0, 0, 0)
	LunaPetFrame.bars["Healthbar"].lefttext:SetShadowOffset(0.8, -0.8)
	LunaUnitFrames:RegisterFontstring(LunaPetFrame.bars["Healthbar"].lefttext, "pet", barsettings["Healthbar"][1] or LunaOptions.defaultTags["Healthbar"][1])

	-- Manabar
	LunaPetFrame.bars["Powerbar"] = CreateFrame("StatusBar", nil, LunaPetFrame)
	LunaPetFrame.bars["Powerbar"]:SetStatusBarTexture(LunaOptions.statusbartexture)

	-- Manabar background
	LunaPetFrame.bars["Powerbar"].ppbg = LunaPetFrame.bars["Powerbar"]:CreateTexture(nil, "BORDER")
	LunaPetFrame.bars["Powerbar"].ppbg:SetAllPoints(LunaPetFrame.bars["Powerbar"])
	LunaPetFrame.bars["Powerbar"].ppbg:SetTexture(.25,.25,.25,.25)

	LunaPetFrame.bars["Powerbar"].righttext = LunaPetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY", LunaPetFrame.bars["Powerbar"])
	LunaPetFrame.bars["Powerbar"].righttext:SetPoint("RIGHT", -2, 0)
	LunaPetFrame.bars["Powerbar"].righttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.bars["Powerbar"].righttext:SetShadowColor(0, 0, 0)
	LunaPetFrame.bars["Powerbar"].righttext:SetShadowOffset(0.8, -0.8)
	LunaPetFrame.bars["Powerbar"].righttext:SetJustifyH("RIGHT")
	LunaPetFrame.bars["Powerbar"].righttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaPetFrame.bars["Powerbar"].righttext, "pet", barsettings["Powerbar"][2] or LunaOptions.defaultTags["Powerbar"][2])

	LunaPetFrame.bars["Powerbar"].lefttext = LunaPetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY", LunaPetFrame.bars["Powerbar"])
	LunaPetFrame.bars["Powerbar"].lefttext:SetPoint("LEFT", 2, 0)
	LunaPetFrame.bars["Powerbar"].lefttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.bars["Powerbar"].lefttext:SetShadowColor(0, 0, 0)
	LunaPetFrame.bars["Powerbar"].lefttext:SetShadowOffset(0.8, -0.8)
	LunaPetFrame.bars["Powerbar"].lefttext:SetJustifyH("LEFT")
	LunaPetFrame.bars["Powerbar"].lefttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaPetFrame.bars["Powerbar"].lefttext, "pet", barsettings["Powerbar"][1] or LunaOptions.defaultTags["Powerbar"][1])

	LunaPetFrame:RegisterEvent("UNIT_HEALTH")
	LunaPetFrame:RegisterEvent("UNIT_MAXHEALTH")
	LunaPetFrame:RegisterEvent("UNIT_MANA")
	LunaPetFrame:RegisterEvent("UNIT_MAXMANA")
	LunaPetFrame:RegisterEvent("UNIT_RAGE")
	LunaPetFrame:RegisterEvent("UNIT_MAXRAGE")
	LunaPetFrame:RegisterEvent("UNIT_ENERGY")
	LunaPetFrame:RegisterEvent("UNIT_MAXENERGY")
	LunaPetFrame:RegisterEvent("UNIT_FOCUS")
	LunaPetFrame:RegisterEvent("UNIT_MAXFOCUS")
	LunaPetFrame:RegisterEvent("UNIT_HAPPINESS")
	LunaPetFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	LunaPetFrame:RegisterEvent("UNIT_MODEL_CHANGED")
	LunaPetFrame:RegisterEvent("UNIT_PET")
	LunaPetFrame:SetScript("OnClick", Luna_OnClick)
	LunaPetFrame:SetScript("OnEvent", Luna_Pet_OnEvent)
	LunaPetFrame.dropdown = CreateFrame("Frame", "LunaPetDropDownMenu", UIParent, "UIDropDownMenuTemplate")
	LunaPetFrame.initialize = function() 	if LunaPetFrame.dropdown then 
												UnitPopup_ShowMenu(LunaPetFrame.dropdown, "PET", "pet")
											end
							end
	UIDropDownMenu_Initialize(LunaPetFrame.dropdown, LunaPetFrame.initialize, "MENU")
	LunaUnitFrames:UpdatePetFrame()
	
	LunaPetFrame.AdjustBars = function()
		local frameHeight = LunaPetFrame:GetHeight()
		local frameWidth
		local anchor
		local totalWeight = 0
		local gaps = -1
		local textheights = {}
		if LunaOptions.frames["LunaPetFrame"].portrait > 1 then    -- We have a square portrait
			frameWidth = (LunaPetFrame:GetWidth()-frameHeight)
			LunaPetFrame.bars["Portrait"]:SetPoint("TOPLEFT", LunaPetFrame, "TOPLEFT")
			LunaPetFrame.bars["Portrait"]:SetHeight(frameHeight)
			LunaPetFrame.bars["Portrait"]:SetWidth(frameHeight)
			anchor = {"TOPLEFT", LunaPetFrame.bars["Portrait"], "TOPRIGHT"}
		else
			frameWidth = LunaPetFrame:GetWidth()  -- We have a Bar-Portrait or no portrait
			anchor = {"TOPLEFT", LunaPetFrame, "TOPLEFT"}
		end
		for k,v in pairs(LunaOptions.frames["LunaPetFrame"].bars) do
			if LunaPetFrame.bars[v[1]]:IsShown() then
				totalWeight = totalWeight + v[2]
				gaps = gaps + 1
			end
		end
		local firstbar = 1
		for k,v in pairs(LunaOptions.frames["LunaPetFrame"].bars) do
			local bar = v[1]
			local weight = v[2]/totalWeight
			local height = (frameHeight-gaps)*weight
			textheights[v[1]] = v[3] or 0.45
			LunaPetFrame.bars[bar]:ClearAllPoints()
			LunaPetFrame.bars[bar]:SetHeight(height)
			LunaPetFrame.bars[bar]:SetWidth(frameWidth)
			LunaPetFrame.bars[bar].rank = k
			LunaPetFrame.bars[bar].weight = v[2]
			
			if not firstbar and LunaPetFrame.bars[bar]:IsShown() then
				LunaPetFrame.bars[bar]:SetPoint(anchor[1], anchor[2], anchor[3], 0, -1)
				anchor = {"TOPLEFT", LunaPetFrame.bars[bar], "BOTTOMLEFT"}
			elseif LunaPetFrame.bars[bar]:IsShown() then
				LunaPetFrame.bars[bar]:SetPoint(anchor[1], anchor[2], anchor[3])
				firstbar = nil
				anchor = {"TOPLEFT", LunaPetFrame.bars[bar], "BOTTOMLEFT"}
			end			
		end
		
		LunaPetFrame.bars["Portrait"].model:SetHeight(LunaPetFrame.bars["Portrait"]:GetHeight()+1)
		LunaPetFrame.bars["Portrait"].model:SetWidth(LunaPetFrame.bars["Portrait"]:GetWidth())
		
		local healthheight = (LunaPetFrame.bars["Healthbar"]:GetHeight()*textheights["Healthbar"])
		LunaPetFrame.bars["Healthbar"].righttext:SetFont(LunaOptions.font, healthheight)
		LunaPetFrame.bars["Healthbar"].righttext:SetHeight(LunaPetFrame.bars["Healthbar"]:GetHeight())
		LunaPetFrame.bars["Healthbar"].righttext:SetWidth(LunaPetFrame.bars["Healthbar"]:GetWidth()*0.45)
		LunaPetFrame.bars["Healthbar"].lefttext:SetFont(LunaOptions.font, healthheight)
		LunaPetFrame.bars["Healthbar"].lefttext:SetHeight(LunaPetFrame.bars["Healthbar"]:GetHeight())
		LunaPetFrame.bars["Healthbar"].lefttext:SetWidth(LunaPetFrame.bars["Healthbar"]:GetWidth()*0.55)

		local powerheight = (LunaPetFrame.bars["Powerbar"]:GetHeight()*textheights["Powerbar"])
		LunaPetFrame.bars["Powerbar"].righttext:SetFont(LunaOptions.font, powerheight)
		LunaPetFrame.bars["Powerbar"].righttext:SetHeight(LunaPetFrame.bars["Powerbar"]:GetHeight())
		LunaPetFrame.bars["Powerbar"].righttext:SetWidth(LunaPetFrame.bars["Powerbar"]:GetWidth()*0.5)
		LunaPetFrame.bars["Powerbar"].lefttext:SetFont(LunaOptions.font, powerheight)
		LunaPetFrame.bars["Powerbar"].lefttext:SetHeight(LunaPetFrame.bars["Powerbar"]:GetHeight())
		LunaPetFrame.bars["Powerbar"].lefttext:SetWidth(LunaPetFrame.bars["Powerbar"]:GetWidth()*0.5)
	end
	LunaPetFrame.UpdateBuffSize = function ()
		local buffcount = LunaOptions.frames["LunaPetFrame"].BuffInRow or 16
		if LunaOptions.frames["LunaPetFrame"].ShowBuffs == 1 then
			LunaPetFrame:UnregisterEvent("UNIT_AURA")
			for i=1, 16 do
				LunaPetFrame.Buffs[i]:Hide()
				LunaPetFrame.Debuffs[i]:Hide()
			end
		elseif LunaOptions.frames["LunaPetFrame"].ShowBuffs == 2 then
			local buffsize = ((LunaPetFrame:GetWidth()-(buffcount-1))/buffcount)
			LunaPetFrame:RegisterEvent("UNIT_AURA")
			LunaPetFrame.AuraAnchor:ClearAllPoints()
			LunaPetFrame.AuraAnchor:SetPoint("BOTTOMLEFT", LunaPetFrame, "TOPLEFT", -1, 3)
			LunaPetFrame.AuraAnchor:SetWidth(LunaPetFrame:GetWidth())
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaPetFrame.Buffs[buffid]:ClearAllPoints()
					LunaPetFrame.Buffs[buffid]:SetPoint("BOTTOMLEFT", LunaPetFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row)
					LunaPetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaPetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaPetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaPetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaPetFrame.Debuffs[buffid]:SetPoint("BOTTOMLEFT", LunaPetFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row)
					LunaPetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaPetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaPetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			Luna_Pet_Events:UNIT_AURA()
		elseif LunaOptions.frames["LunaPetFrame"].ShowBuffs == 3 then
			local buffsize = ((LunaPetFrame:GetWidth()-(buffcount-1))/buffcount)
			LunaPetFrame:RegisterEvent("UNIT_AURA")
			LunaPetFrame.AuraAnchor:ClearAllPoints()
			LunaPetFrame.AuraAnchor:SetWidth(LunaPetFrame:GetWidth())
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaPetFrame.Buffs[buffid]:ClearAllPoints()
					LunaPetFrame.Buffs[buffid]:SetPoint("TOPLEFT", LunaPetFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaPetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaPetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaPetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaPetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaPetFrame.Debuffs[buffid]:SetPoint("TOPLEFT", LunaPetFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaPetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaPetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaPetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaPetFrame.AuraAnchor:SetPoint("TOPLEFT", LunaPetFrame, "BOTTOMLEFT", -1, -3)
			Luna_Pet_Events:UNIT_AURA()
		elseif LunaOptions.frames["LunaPetFrame"].ShowBuffs == 4 then
			local buffsize = (((LunaPetFrame:GetHeight()/2)-(math.ceil(16/buffcount)-1))/math.ceil(16/buffcount))
			LunaPetFrame:RegisterEvent("UNIT_AURA")
			LunaPetFrame.AuraAnchor:ClearAllPoints()
			LunaPetFrame.AuraAnchor:SetWidth((buffsize*buffcount)+(buffcount-1))
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaPetFrame.Buffs[buffid]:ClearAllPoints()
					LunaPetFrame.Buffs[buffid]:SetPoint("TOPRIGHT", LunaPetFrame.AuraAnchor, "TOPRIGHT", ((z-1)*(buffsize+1))*(-1), (buffsize+1)*row*(-1))
					LunaPetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaPetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaPetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaPetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaPetFrame.Debuffs[buffid]:SetPoint("TOPRIGHT", LunaPetFrame.AuraAnchor, "BOTTOMRIGHT", ((z-1)*(buffsize+1))*(-1), (buffsize+1)*row*(-1))
					LunaPetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaPetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaPetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaPetFrame.AuraAnchor:SetPoint("TOPRIGHT", LunaPetFrame, "TOPLEFT", -3, 0)
			Luna_Pet_Events:UNIT_AURA()
		else
			local buffsize = (((LunaPetFrame:GetHeight()/2)-(math.ceil(16/buffcount)-1))/math.ceil(16/buffcount))
			LunaPetFrame:RegisterEvent("UNIT_AURA")
			LunaPetFrame.AuraAnchor:ClearAllPoints()
			LunaPetFrame.AuraAnchor:SetWidth((buffsize*buffcount)+(buffcount-1))
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaPetFrame.Buffs[buffid]:ClearAllPoints()
					LunaPetFrame.Buffs[buffid]:SetPoint("TOPLEFT", LunaPetFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaPetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaPetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaPetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaPetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaPetFrame.Debuffs[buffid]:SetPoint("TOPLEFT", LunaPetFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaPetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaPetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaPetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaPetFrame.AuraAnchor:SetPoint("TOPLEFT", LunaPetFrame, "TOPRIGHT", 3, 0)
			Luna_Pet_Events:UNIT_AURA()
		end
	end
	for k,v in pairs(LunaOptions.frames["LunaPetFrame"].bars) do
		if v[2] == 0 then
			LunaPetFrame.bars[v[1]]:Hide()
		end
	end
	LunaPetFrame.AdjustBars()
	LunaPetFrame.UpdateBuffSize()
end

function LunaUnitFrames:ConvertPetPortrait()
	if LunaOptions.frames["LunaPetFrame"].portrait == 1 then
		table.insert(LunaOptions.frames["LunaPetFrame"].bars, 1, {"Portrait", 4})
	else
		for k,v in pairs(LunaOptions.frames["LunaPetFrame"].bars) do
			if v[1] == "Portrait" then
				table.remove(LunaOptions.frames["LunaPetFrame"].bars, k)
			end
		end
	end
	UIDropDownMenu_SetText("Healthbar", LunaOptionsFrame.pages[2].BarSelect)
	LunaOptionsFrame.pages[2].barorder:SetMinMaxValues(1,table.getn(LunaOptions.frames["LunaPetFrame"].bars))
	for k,v in pairs(LunaOptions.frames["LunaPetFrame"].bars) do
		if v[1] == "Healthbar" then
			LunaOptionsFrame.pages[2].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[2].barorder:SetValue(k)
			LunaOptionsFrame.pages[2].lefttext:SetText(v[4] or LunaOptions.defaultTags["Healthbar"][1])
			LunaOptionsFrame.pages[2].righttext:SetText(v[5] or LunaOptions.defaultTags["Healthbar"][2])
			LunaOptionsFrame.pages[2].textsize:SetValue(v[3] or 0.45)
			break
		end
	end
	LunaPetFrame.AdjustBars()
end

function LunaUnitFrames:UpdatePetFrame()
	if not UnitExists("pet") or LunaOptions.frames["LunaPetFrame"].enabled == 0 then
		LunaPetFrame:Hide()
		return
	else
		LunaPetFrame:Show()
	end
	Luna_Pet_Events.UNIT_HAPPINESS()

	local petpower = UnitPowerType("pet")
	if UnitManaMax("pet") == 0 then
		LunaPetFrame.bars["Powerbar"]:SetStatusBarColor(0, 0, 0, .25)
		LunaPetFrame.bars["Powerbar"].ppbg:SetVertexColor(0, 0, 0, .25)
	elseif petpower == 1 then
		LunaPetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
		LunaPetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
	elseif petpower == 2 then
		LunaPetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Focus"][1],LunaOptions.PowerColors["Focus"][2],LunaOptions.PowerColors["Focus"][3])
		LunaPetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Focus"][1],LunaOptions.PowerColors["Focus"][2],LunaOptions.PowerColors["Focus"][3], 0.25)
	elseif petpower == 3 then
		LunaPetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
		LunaPetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
	else
		LunaPetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
		LunaPetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
	end
	
	for z=1, 16 do
		local path, stacks = UnitBuff(LunaPetFrame.unit,z)
		LunaPetFrame.Buffs[z].texturepath = path
		if LunaPetFrame.Buffs[z].texturepath then
			LunaPetFrame.Buffs[z]:EnableMouse(1)
			LunaPetFrame.Buffs[z]:Show()
			if stacks > 1 then
				LunaPetFrame.Buffs[z].stacks:SetText(stacks)
				LunaPetFrame.Buffs[z].stacks:Show()
			else
				LunaPetFrame.Buffs[z].stacks:Hide()
			end
		else
			LunaPetFrame.Buffs[z]:EnableMouse(0)
			LunaPetFrame.Buffs[z]:Hide()
		end
		LunaPetFrame.Buffs[z]:SetNormalTexture(LunaPetFrame.Buffs[z].texturepath)
	end

	for z=1, 16 do
		local path, stacks = UnitDebuff(LunaPetFrame.unit,z)
		LunaPetFrame.Debuffs[z].texturepath = path
		if LunaPetFrame.Debuffs[z].texturepath then
			LunaPetFrame.Debuffs[z]:EnableMouse(1)
			LunaPetFrame.Debuffs[z]:Show()
			if stacks > 1 then
				LunaPetFrame.Debuffs[z].stacks:SetText(stacks)
				LunaPetFrame.Debuffs[z].stacks:Show()
			else
				LunaPetFrame.Debuffs[z].stacks:Hide()
			end
		else
			LunaPetFrame.Debuffs[z]:EnableMouse(0)
			LunaPetFrame.Debuffs[z]:Hide()
		end
		LunaPetFrame.Debuffs[z]:SetNormalTexture(LunaPetFrame.Debuffs[z].texturepath)
	end
	Luna_Pet_Events.UNIT_PORTRAIT_UPDATE("pet")
	Luna_Pet_Events.UNIT_HEALTH()
	Luna_Pet_Events.UNIT_MANA()
end

function Luna_Pet_Events:UNIT_AURA()
	if arg1 == "pet" or arg1 == "LunaUnitFrames" or arg1 == "LeftButton" then
		local pos
		for i=1, 16 do
			local path, stacks = UnitBuff(LunaPetFrame.unit,i)
			LunaPetFrame.Buffs[i].texturepath = path
			if LunaPetFrame.Buffs[i].texturepath then
				LunaPetFrame.Buffs[i]:EnableMouse(1)
				LunaPetFrame.Buffs[i]:Show()
				if stacks > 1 then
					LunaPetFrame.Buffs[i].stacks:SetText(stacks)
					LunaPetFrame.Buffs[i].stacks:Show()
				else
					LunaPetFrame.Buffs[i].stacks:Hide()
				end
			else
				LunaPetFrame.Buffs[i]:EnableMouse(0)
				LunaPetFrame.Buffs[i]:Hide()
				if not pos then
					pos = i
				end
			end
			LunaPetFrame.Buffs[i]:SetNormalTexture(LunaPetFrame.Buffs[i].texturepath)
		end
		if not pos then
			pos = 17
		end
		LunaPetFrame.AuraAnchor:SetHeight((LunaPetFrame.Buffs[1]:GetHeight()*math.ceil((pos-1)/(LunaOptions.frames["LunaPetFrame"].BuffInRow or 16)))+(math.ceil((pos-1)/(LunaOptions.frames["LunaPetFrame"].BuffInRow or 16))-1)+1.1)
		for i=1, 16 do
			local path, stacks = UnitDebuff(LunaPetFrame.unit,i)
			LunaPetFrame.Debuffs[i].texturepath = path
			if LunaPetFrame.Debuffs[i].texturepath then
				LunaPetFrame.Debuffs[i]:EnableMouse(1)
				LunaPetFrame.Debuffs[i]:Show()
				if stacks > 1 then
					LunaPetFrame.Debuffs[i].stacks:SetText(stacks)
					LunaPetFrame.Debuffs[i].stacks:Show()
				else
					LunaPetFrame.Debuffs[i].stacks:Hide()
				end
			else
				LunaPetFrame.Debuffs[i]:EnableMouse(0)
				LunaPetFrame.Debuffs[i]:Hide()
			end
			LunaPetFrame.Debuffs[i]:SetNormalTexture(LunaPetFrame.Debuffs[i].texturepath)
		end
	end
end

function Luna_Pet_Events:UNIT_HEALTH()
	LunaPetFrame.bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax("pet"))
	LunaPetFrame.bars["Healthbar"]:SetValue(UnitHealth("pet"))
	if UnitIsDead("pet") then
		LunaPetFrame.bars["Healthbar"]:SetValue(0)
	end
end
Luna_Pet_Events.UNIT_MAXHEALTH = Luna_Pet_Events.UNIT_HEALTH

function Luna_Pet_Events:UNIT_MANA()
	LunaPetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax("pet"))
	LunaPetFrame.bars["Powerbar"]:SetValue(UnitMana("pet"))
end
Luna_Pet_Events.UNIT_MAXMANA = Luna_Pet_Events.UNIT_MANA
Luna_Pet_Events.UNIT_ENERGY = Luna_Pet_Events.UNIT_MANA
Luna_Pet_Events.UNIT_MAXENERGY = Luna_Pet_Events.UNIT_MANA
Luna_Pet_Events.UNIT_RAGE = Luna_Pet_Events.UNIT_MANA
Luna_Pet_Events.UNIT_MAXRAGE = Luna_Pet_Events.UNIT_MANA
Luna_Pet_Events.UNIT_FOCUS = Luna_Pet_Events.UNIT_MANA
Luna_Pet_Events.UNIT_MAXFOCUS = Luna_Pet_Events.UNIT_MANA

function Luna_Pet_Events:UNIT_HAPPINESS()
	local happiness = GetPetHappiness()
	if happiness == 1 then
		LunaPetFrame.bars["Healthbar"]:SetStatusBarColor(LunaOptions.MiscColors["hostile"][1],LunaOptions.MiscColors["hostile"][2],LunaOptions.MiscColors["hostile"][3])
		LunaPetFrame.bars["Healthbar"].hpbg:SetVertexColor(LunaOptions.MiscColors["hostile"][1],LunaOptions.MiscColors["hostile"][2],LunaOptions.MiscColors["hostile"][3], 0.25)
	elseif happiness == 2 then
		LunaPetFrame.bars["Healthbar"]:SetStatusBarColor(LunaOptions.MiscColors["neutral"][1],LunaOptions.MiscColors["neutral"][2],LunaOptions.MiscColors["neutral"][3])
		LunaPetFrame.bars["Healthbar"].hpbg:SetVertexColor(LunaOptions.MiscColors["neutral"][1],LunaOptions.MiscColors["neutral"][2],LunaOptions.MiscColors["neutral"][3], 0.25)
	else
		LunaPetFrame.bars["Healthbar"]:SetStatusBarColor(LunaOptions.MiscColors["friendly"][1],LunaOptions.MiscColors["friendly"][2],LunaOptions.MiscColors["friendly"][3])
		LunaPetFrame.bars["Healthbar"].hpbg:SetVertexColor(LunaOptions.MiscColors["friendly"][1],LunaOptions.MiscColors["friendly"][2],LunaOptions.MiscColors["friendly"][3], 0.25)
	end
end

function Luna_Pet_Events.UNIT_PORTRAIT_UPDATE(unit)
	if arg1 ~= "pet" and not unit then
		return
	end
	local portrait = LunaPetFrame.bars["Portrait"]
	if (LunaOptions.PortraitMode == 3 and (LunaOptions.PortraitFallback == 2 or LunaOptions.PortraitFallback == 3)) or LunaOptions.PortraitMode == 2 then
		portrait.model:Hide()
		portrait.texture:Show()
		SetPortraitTexture(portrait.texture, "pet")
		portrait.texture:SetTexCoord(.1, .90, .1, .90)
	else
		if(not UnitExists("pet") or not UnitIsConnected("pet") or not UnitIsVisible("pet")) then
			portrait.model:Show()
			portrait.texture:Hide()
			portrait.model:SetModelScale(4.25)
			portrait.model:SetPosition(0, 0, -1)
		else
			portrait.model:Show()
			portrait.texture:Hide()
			portrait.model:SetUnit("pet")
			portrait.model:SetCamera(0)
		end
	end
end
Luna_Pet_Events.UNIT_MODEL_CHANGED = Luna_Pet_Events.UNIT_PORTRAIT_UPDATE

function Luna_Pet_Events:UNIT_PET()
	LunaUnitFrames:UpdatePetFrame()
end