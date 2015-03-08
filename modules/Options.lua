LunaOptionsModule = {}

local OptionsPageNames = {{title = "Player Frame", frame = "LunaPlayerFrame"},
						{title = "Pet Frame", frame = "LunaPetFrame"},
						{title = "Target Frame", frame = "LunaTargetFrame"},
						{title = "Target Target Frame", frame = "LunaTargetTargetFrame"},
						{title = "Party Frames", frame = "LunaPartyFrames"},
						{title = "Party Pets Frame", frame = "LunaPartyPetFrames"},
						{title = "Raid Frames", frame = "LunaUnitFrames.frames.RaidFrames"},
						{title = "General", frame = "LunaUnitFrames"}
						}
						
local function ResetSettings()
	LunaOptions = {}
	LunaOptions.PowerColors = {
		["Mana"] = { 48/255, 113/255, 191/255}, -- Mana
		["Rage"] = { 226/255, 45/255, 75/255}, -- Rage
		["Focus"] = { 255/255, 178/255, 0}, -- Focus
		["Energy"] = { 1, 1, 34/255}, -- Energy
		["Happiness"] = { 0, 1, 1} -- Happiness
	}
	LunaOptions.DebuffTypeColor = {
		["Magic"]    = {0.2, 0.6, 1},
		["Curse"]    = {0.6, 0, 1},
		["Disease"]  = {0.6, 0.4, 0},
		["Poison"]   = {0, 0.6, 0}
	}
	LunaOptions.MiscColors = {
		["tapped"] = {0.5, 0.5, 0.5},
		["red"] = {0.90, 0.0, 0.0},
		["green"] = {0.20, 0.90, 0.20},
		["static"] = {0.70, 0.20, 0.90},
		["yellow"] = {0.93, 0.93, 0.0},
		["inc"] = {0, 0.35, 0.23},
		["enemyUnattack"] = {0.60, 0.20, 0.20},
		["hostile"] = {0.90, 0.0, 0.0},
		["friendly"] = {0.20, 0.90, b = 0.20},
		["neutral"] = {0.93, 0.93, b = 0.0},
		["offline"] = {0.50, 0.50, b = 0.50}
	}
	LunaOptions.backdrop = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		insets = {left = -1.5, right = -1.5, top = -1.5, bottom = -1.5},
	}
	LunaOptions.fontHeight = 11
	LunaOptions.font = "Interface\\AddOns\\LunaUnitFrames\\media\\barframes.ttf"
	LunaOptions.statusbartexture = "Interface\\AddOns\\LunaUnitFrames\\media\\statusbar"
	LunaOptions.bordertexture = "Interface\\AddOns\\LunaUnitFrames\\media\\border"
	LunaOptions.icontexture = "Interface\\AddOns\\LunaUnitFrames\\media\\icon"
	LunaOptions.resIcon = "Interface\\AddOns\\LunaUnitFrames\\media\\Raid-Icon-Rez"
	LunaOptions.indicator = "Interface\\AddOns\\LunaUnitFrames\\media\\indicator"
		
	LunaOptions.frames = {	["LunaPlayerFrame"] = {position = {x = 10, y = -20}, size = {x = 240, y = 40}, scale = 1, enabled = 1, ShowBuffs = 1, portrait = 2, bars = {{"Healthbar", 6}, {"Powerbar", 4}, {"Castbar", 3}}},
							["LunaTargetFrame"] = {position = {x = 280, y = -20}, size = {x = 240, y = 40}, scale = 1, enabled = 1, ShowBuffs = 3, portrait = 2, bars = {{"Healthbar", 6}, {"Powerbar", 4}, {"Castbar", 3}, {"Combo Bar", 2}}},
							["LunaTargetTargetFrame"] = {position = {x = 550, y = -20}, size = {x = 150, y = 40}, scale = 1, enabled = 1, ShowBuffs = 1, bars = {{"Healthbar", 6}, {"Powerbar", 4}}},
							["LunaTargetTargetTargetFrame"] = {position = {x = 730, y = -20}, size = {x = 150, y = 40}, scale = 1, enabled = 1, ShowBuffs = 1, bars = {{"Healthbar", 6}, {"Powerbar", 4}}},
							["LunaPartyFrames"] = {position = {x = 10, y = -140}, size = {x = 200, y = 40}, scale = 1, enabled = 1, ShowBuffs = 3, portrait = 2, bars = {{"Healthbar", 6}, {"Powerbar", 4}}},
							["LunaPartyPetFrames"] = {position = {x = 0, y = 0}, size = {x = 110, y = 20}, scale = 1, enabled = 1, bars = {{"Healthbar", 6}, {"Powerbar", 4}}},
							["LunaPetFrame"] = {position = {x = 10, y = -70}, size = {x = 240, y = 30}, scale = 1, enabled = 1, ShowBuffs = 3, portrait = 2, bars = {{"Healthbar", 6}, {"Powerbar", 4}}},
							["LunaRaidFrames"] = {
								["pBars"] = 1,
								["scale"] = 1,
								["padding"] = 4,
								["height"] = 35,
								["width"] = 80,
								["positions"] = {
									[1] = {
										["x"] = 400,
										["y"] = -400,
									},
									[2] = {
										["x"] = 400,
										["y"] = -400,
									},
									[3] = {
										["x"] = 400,
										["y"] = -400,
									},
									[4] = {
										["x"] = 400,
										["y"] = -400,
									},
									[5] = {
										["x"] = 400,
										["y"] = -400,
									},
									[6] = {
										["x"] = 400,
										["y"] = -400,
									},
									[7] = {
										["x"] = 400,
										["y"] = -400,
									},
									[8] = {
										["x"] = 400,
										["y"] = -400,
									},
								},
							},
						}
	LunaOptions.enableRaid = 1
	LunaOptions.PartyinRaids = 0
	LunaOptions.Rangefreq = 0.2
	LunaOptions.Raidlayout = "GRID"
	LunaOptions.EnergyTicker = 1
	LunaOptions.hideCastbar = 0
	LunaOptions.hideBlizzCastbar = 1
	LunaOptions.PartyRange = 1
	LunaOptions.RaidRange = 1
	LunaOptions.XPBar = 1
	LunaOptions.PartySpace = 40
	LunaOptions.VerticalParty = 1
	LunaOptions.Raidbuff = ""
end

if LunaOptions == nil then
	ResetSettings()
end

if not LunaOptions.frames["LunaRaidFrames"] then
	LunaOptions.frames["LunaRaidFrames"] = {}
end

local OptionFunctions = {}

function OptionFunctions.StartMoving()
	LunaOptionsFrame:StartMoving()
end

function OptionFunctions.StopMovingOrSizing()
	LunaOptionsFrame:StopMovingOrSizing()
end

function OptionFunctions.ToggleFrame()
	for i, page in pairs(LunaOptionsFrame.pages) do
		if (i-1) == this.id then
			page:Show()
		else
			page:Hide()
		end
	end
end

function OptionFunctions.RaidHeightAdjust()
	if LunaUnitFrames.frames.RaidFrames[1] then
		LunaOptions.frames["LunaRaidFrames"].height = this:GetValue()
		getglobal("RaidHeightSliderText"):SetText("Height: "..LunaOptions.frames["LunaRaidFrames"].height)
		LunaUnitFrames:SetRaidFrameSize()
	end
end

function OptionFunctions.RaidWidthAdjust()
	if LunaUnitFrames.frames.RaidFrames[1] then
		LunaOptions.frames["LunaRaidFrames"].width = this:GetValue()
		getglobal("RaidWidthSliderText"):SetText("Width: "..LunaOptions.frames["LunaRaidFrames"].width)
		LunaUnitFrames:SetRaidFrameSize()
	end
end

function OptionFunctions.RaidScaleAdjust()
	if LunaUnitFrames.frames.RaidFrames[1] then
		LunaOptions.frames["LunaRaidFrames"].scale = math.floor((this:GetValue()+0.05)*10)/10
		getglobal("RaidScaleSliderText"):SetText("Scale: "..LunaOptions.frames["LunaRaidFrames"].scale)
		LunaUnitFrames:SetRaidFrameSize()
	end
end

function OptionFunctions.RaidPaddingAdjust()
	if LunaUnitFrames.frames.RaidFrames[1] then
		LunaOptions.frames["LunaRaidFrames"].padding = this:GetValue()
		getglobal("RaidPaddingSliderText"):SetText("Padding: "..LunaOptions.frames["LunaRaidFrames"].padding)
		LunaUnitFrames:UpdateRaidLayout()
	end
end	

function OptionFunctions.ToggleRaidGroupNames()
	if this:GetChecked() == 1 then
		LunaOptions.frames["LunaRaidFrames"].ShowRaidGroupTitles = 1
	else
		LunaOptions.frames["LunaRaidFrames"].ShowRaidGroupTitles = 0
	end
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.ToggleDispelableDebuffs()
	if not LunaOptions.showdispelable then
		LunaOptions.showdispelable = 1
	else
		LunaOptions.showdispelable = nil
	end
	LunaUnitFrames.Raid_Update()
end

function OptionFunctions.ToggleAggro()
	if not LunaOptions.aggro then
		LunaOptions.aggro = 1
	else
		LunaOptions.aggro = nil
	end
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.ToggleInterlock()
	if not LunaOptions.raidinterlock then
		LunaOptions.raidinterlock = 1
	else
		LunaOptions.raidinterlock = nil
	end
	LunaUnitFrames:UpdateRaidLayout()
end

function OptionFunctions.ScaleAdjust()
	local amount = (math.floor(this:GetValue()*10 + 0.5)/10)
	frame = getglobal(this.frame)
	if frame then
		if this.frame == "LunaPartyFrames" then
			for i=1,4 do
				frame[i]:SetScale(amount)
			end
		elseif this.frame == "LunaPartyPetFrames" then
			for i=1,4 do
				frame[i]:SetScale(amount)
			end
		else
			frame:SetScale(amount)
			LunaUnitFrames:ResizeXPBar()
		end
		LunaOptions.frames[this.frame].scale = amount
		getglobal(this.frame.."ScaleSliderText"):SetText("Scale: "..amount)
	end
end

function OptionFunctions.HeightAdjust()
	local frame = getglobal(this.frame)
	local amount = this:GetValue()
	if frame then
		if this.frame == "LunaPartyFrames" then
			for i=1,4 do
				frame[i]:SetHeight(amount)
			end
			LunaUnitFrames:UpdatePartyUnitFrameSize()
			LunaUnitFrames:UpdatePartyBuffSize()
		elseif this.frame == "LunaPartyPetFrames" then
			for i=1,4 do
				frame[i]:SetHeight(amount)
			end
		else
			frame:SetHeight(amount)
			frame:AdjustBars()
			if frame.UpdateBuffSize then
				frame:UpdateBuffSize()
			end
		end
		LunaOptions.frames[this.frame].size.y = amount
		getglobal(this.frame.."HeightSliderText"):SetText("Height: "..amount)
	end
end

function OptionFunctions.WidthAdjust()
	local frame = getglobal(this.frame)
	local amount = this:GetValue()
	if frame then
		if this.frame == "LunaPartyFrames" then
			for i=1,4 do
				frame[i]:SetWidth(amount)
			end
			LunaUnitFrames:UpdatePartyUnitFrameSize()
			LunaUnitFrames:UpdatePartyBuffSize()
		elseif this.frame == "LunaPartyPetFrames" then
			for i=1,4 do
				frame[i]:SetWidth(amount)
			end
		elseif this.frame == "LunaPlayerFrame" and LunaUnitFrames.frames.ExperienceBar and LunaUnitFrames.frames.ExperienceBar:IsShown() then
			frame:SetWidth(amount)
			frame:AdjustBars()
			frame:UpdateBuffSize()
			LunaUnitFrames:ResizeXPBar()
		else
			frame:SetWidth(amount)
			frame:AdjustBars()
			if frame.UpdateBuffSize then
				frame:UpdateBuffSize()
			end
		end
		LunaOptions.frames[this.frame].size.x = amount
		getglobal(this.frame.."WidthSliderText"):SetText("Width: "..amount)
	end
end

function OptionFunctions.RegisterCastbar(frame)
	getglobal(frame):RegisterEvent("SPELLCAST_START")
	getglobal(frame):RegisterEvent("SPELLCAST_STOP")
	getglobal(frame):RegisterEvent("SPELLCAST_FAILED")
	getglobal(frame):RegisterEvent("SPELLCAST_INTERRUPTED")
	getglobal(frame):RegisterEvent("SPELLCAST_DELAYED")
	getglobal(frame):RegisterEvent("SPELLCAST_CHANNEL_START")
	getglobal(frame):RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
	getglobal(frame):RegisterEvent("SPELLCAST_CHANNEL_STOP")
end

function OptionFunctions.UnRegisterCastbar(frame)
	getglobal(frame):UnregisterEvent("SPELLCAST_START")
	getglobal(frame):UnregisterEvent("SPELLCAST_STOP")
	getglobal(frame):UnregisterEvent("SPELLCAST_FAILED")
	getglobal(frame):UnregisterEvent("SPELLCAST_INTERRUPTED")
	getglobal(frame):UnregisterEvent("SPELLCAST_DELAYED")
	getglobal(frame):UnregisterEvent("SPELLCAST_CHANNEL_START")
	getglobal(frame):UnregisterEvent("SPELLCAST_CHANNEL_UPDATE")
	getglobal(frame):UnregisterEvent("SPELLCAST_CHANNEL_STOP")
end

function OptionFunctions.HideCastBarToggle()
	if LunaOptionsFrame.pages[1].HideCastbar:GetChecked() == 1 then
		OptionFunctions.UnRegisterCastbar("LunaPlayerFrame")
		LunaPlayerFrame.bars["Castbar"]:Hide()
		LunaPlayerFrame.bars["Castbar"].casting = nil
		LunaPlayerFrame.bars["Castbar"].channeling = nil
		LunaOptions.hideCastbar = 1
		LunaPlayerFrame.AdjustBars()
	else
		OptionFunctions.RegisterCastbar("LunaPlayerFrame")
		LunaOptions.hideCastbar = 0
	end
end

function OptionFunctions.HideBlizzardCastbarToggle()
	if LunaOptionsFrame.pages[1].HideBlizzCast:GetChecked() == 1 then
		OptionFunctions.UnRegisterCastbar("CastingBarFrame")
		CastingBarFrame:Hide()
		LunaOptions.hideBlizzCastbar = 1
	else
		OptionFunctions.RegisterCastbar("CastingBarFrame")
		LunaOptions.hideBlizzCastbar = 0
	end
end

function OptionFunctions.PortraitmodeToggle()
	if this:GetChecked() == 1 then
		LunaOptions.frames[this.frame].portrait = 1
	else
		LunaOptions.frames[this.frame].portrait = 2
		if this.frame == "LunaPartyFrames" then
			for i=1,4 do
				LunaPartyFrames[i].bars["Portrait"]:Show()
			end
		else
			getglobal(this.frame).bars["Portrait"]:Show()
		end
	end
	if this.frame == "LunaPlayerFrame" then
		LunaUnitFrames:ConvertPlayerPortrait()
	elseif this.frame == "LunaPetFrame" then
		LunaUnitFrames:ConvertPetPortrait()
	elseif this.frame == "LunaTargetFrame" then
		LunaUnitFrames:ConvertTargetPortrait()
	elseif this.frame == "LunaPartyFrames" then
		LunaUnitFrames:ConvertPartyPortraits()
	end
end

function OptionFunctions.XPBarToggle()
	if LunaOptionsFrame.pages[1].XPBar:GetChecked() == 1 then
		LunaOptions.XPBar = 1
	else
		LunaOptions.XPBar = 0
	end
	LunaUnitFrames:UpdateXPBar()
end

function OptionFunctions.PlayerBuffPosSelectChoice()
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[1].BuffPosition, this:GetID())
	LunaOptions.frames["LunaPlayerFrame"].ShowBuffs = this:GetID()
	LunaPlayerFrame.UpdateBuffSize()
end

function OptionFunctions.PlayerBuffPosSelect()
	local info={}
	for k,v in ipairs({"Hide","Top","Bottom","Left","Right"}) do
		info.text=v
		info.value=k
		info.func= OptionFunctions.PlayerBuffPosSelectChoice
		info.checked = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

function OptionFunctions.PlayerBarSelectorInit()
	local info={}
	for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
		info.text=v[1]
		info.value=k
		info.func= function () UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[1].BarSelect, this:GetID())
					for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
						if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[1].BarSelect) then
							LunaOptionsFrame.pages[1].barorder:SetValue(k)
							LunaOptionsFrame.pages[1].barheight:SetValue(v[2])
							break
						end
					end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

function OptionFunctions.BuffInRow()
	local frame = getglobal(this.frame)
	amount = this:GetValue()
	if frame then
		LunaOptions.frames[this.frame].BuffInRow = amount
		if this.frame == "LunaPartyFrames" then
			LunaUnitFrames:UpdatePartyBuffSize()
		else
			frame.UpdateBuffSize()
		end
		getglobal(this.frame.."BuffInRowText"):SetText("Auras per row: "..amount)
	end	
end

function OptionFunctions.PetBarSelectorInit()
	local info={}
	for k,v in pairs(LunaOptions.frames["LunaPetFrame"].bars) do
		info.text=v[1]
		info.value=k
		info.func= function () UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[2].BarSelect, this:GetID())
					for k,v in pairs(LunaOptions.frames["LunaPetFrame"].bars) do
						if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[2].BarSelect) then
							LunaOptionsFrame.pages[2].barorder:SetValue(k)
							LunaOptionsFrame.pages[2].barheight:SetValue(v[2])
							break
						end
					end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

function OptionFunctions.TargetBarSelectorInit()
	local info={}
	for k,v in pairs(LunaOptions.frames["LunaTargetFrame"].bars) do
		info.text=v[1]
		info.value=k
		info.func= function () UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[3].BarSelect, this:GetID())
					for k,v in pairs(LunaOptions.frames["LunaTargetFrame"].bars) do
						if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[3].BarSelect) then
							LunaOptionsFrame.pages[3].barorder:SetValue(k)
							LunaOptionsFrame.pages[3].barheight:SetValue(v[2])
							break
						end
					end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

function OptionFunctions.TargetTargetBarSelectorInit()
	local info={}
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetFrame"].bars) do
		info.text=v[1]
		info.value=k
		info.func= function () UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[4].BarSelect, this:GetID())
					for k,v in pairs(LunaOptions.frames["LunaTargetTargetFrame"].bars) do
						if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[4].BarSelect) then
							LunaOptionsFrame.pages[4].barorder:SetValue(k)
							LunaOptionsFrame.pages[4].barheight:SetValue(v[2])
							break
						end
					end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

function OptionFunctions.TargetTargetTargetBarSelectorInit()
	local info={}
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars) do
		info.text=v[1]
		info.value=k
		info.func= function () UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[4].BarSelect2, this:GetID())
					for k,v in pairs(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars) do
						if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[4].BarSelect2) then
							LunaOptionsFrame.pages[4].barorder2:SetValue(k)
							LunaOptionsFrame.pages[4].barheight2:SetValue(v[2])
							break
						end
					end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

function OptionFunctions.PartyBarSelectorInit()
	local info={}
	for k,v in pairs(LunaOptions.frames["LunaPartyFrames"].bars) do
		info.text=v[1]
		info.value=k
		info.func= function () UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[5].BarSelect, this:GetID())
					for k,v in pairs(LunaOptions.frames["LunaPartyFrames"].bars) do
						if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[5].BarSelect) then
							LunaOptionsFrame.pages[5].barorder:SetValue(k)
							LunaOptionsFrame.pages[5].barheight:SetValue(v[2])
							break
						end
					end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

function OptionFunctions.OnOrderSlider()
	local place = this:GetValue()
	local bar = UIDropDownMenu_GetText(this:GetParent().BarSelect)
	for k,v in pairs(LunaOptions.frames[this.frame].bars) do
		if v[1] == bar then
			table.remove(LunaOptions.frames[this.frame].bars, k)
			table.insert(LunaOptions.frames[this.frame].bars, place, v)
			break
		end
	end
	getglobal(this:GetName().."Text"):SetText("Bar Position: "..place)
	if this.frame == "LunaPartyFrames" then
		LunaUnitFrames:UpdatePartyUnitFrameSize()
	else
		getglobal(this.frame).AdjustBars()
	end
end

function OnBarHeight()
	local weight = this:GetValue()
	if this.frame == "LunaPartyFrames" then
		for i=1,4 do
			if weight == 0 then
				LunaPartyFrames[i].bars[UIDropDownMenu_GetText(this:GetParent().BarSelect)]:Hide()
				getglobal(this:GetName().."Text"):SetText("Bar height weight: BAR OFF")
			else
				LunaPartyFrames[i].bars[UIDropDownMenu_GetText(this:GetParent().BarSelect)]:Show()
				getglobal(this:GetName().."Text"):SetText("Bar height weight: "..weight)
			end
		end
		for k,v in pairs(LunaOptions.frames[this.frame].bars) do
			if v[1] == UIDropDownMenu_GetText(this:GetParent().BarSelect) then
				v[2] = weight
				break
			end
		end
		LunaUnitFrames:UpdatePartyUnitFrameSize()
	else
		if weight == 0 then
			getglobal(this.frame).bars[UIDropDownMenu_GetText(this:GetParent().BarSelect)]:Hide()
			getglobal(this:GetName().."Text"):SetText("Bar height weight: BAR OFF")
		else
			getglobal(this.frame).bars[UIDropDownMenu_GetText(this:GetParent().BarSelect)]:Show()
			getglobal(this:GetName().."Text"):SetText("Bar height weight: "..weight)
		end
		for k,v in pairs(LunaOptions.frames[this.frame].bars) do
			if v[1] == UIDropDownMenu_GetText(this:GetParent().BarSelect) then
				v[2] = weight
				break
			end
		end
		getglobal(this.frame).AdjustBars()
	end
end

function OptionFunctions.PetBuffPosSelectChoice()
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[2].BuffPosition, this:GetID())
	LunaOptions.frames["LunaPetFrame"].ShowBuffs = this:GetID()
	LunaPetFrame.UpdateBuffSize()
end

function OptionFunctions.PetBuffPosSelect()
	local info={}
	for k,v in ipairs({"Hide","Top","Bottom","Left","Right"}) do
		info.text=v
		info.value=k
		info.func= OptionFunctions.PetBuffPosSelectChoice
		info.checked = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

function OptionFunctions.TargetBuffPosSelectChoice()
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[3].BuffPosition, this:GetID())
	LunaOptions.frames["LunaTargetFrame"].ShowBuffs = this:GetID()
	LunaTargetFrame.UpdateBuffSize()
end

function OptionFunctions.TargetBuffPosSelect()
	local info={}
	for k,v in ipairs({"Hide","Top","Bottom","Left","Right"}) do
		info.text=v
		info.value=k
		info.func= OptionFunctions.TargetBuffPosSelectChoice
		info.checked = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

function OptionFunctions.TargetTargetBuffPosSelectChoice()
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[4].BuffPosition, this:GetID())
	LunaOptions.frames["LunaTargetTargetFrame"].ShowBuffs = this:GetID()
	LunaTargetTargetFrame.UpdateBuffSize()
end

function OptionFunctions.TargetTargetBuffPosSelect()
	local info={}
	for k,v in ipairs({"Hide","Top","Bottom","Left","Right"}) do
		info.text=v
		info.value=k
		info.func= OptionFunctions.TargetTargetBuffPosSelectChoice
		info.checked = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

function OptionFunctions.TargetTargetTargetBuffPosSelectChoice()
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[4].BuffPosition2, this:GetID())
	LunaOptions.frames["LunaTargetTargetTargetFrame"].ShowBuffs = this:GetID()
	LunaTargetTargetTargetFrame.UpdateBuffSize()
end

function OptionFunctions.TargetTargetTargetBuffPosSelect()
	local info={}
	for k,v in ipairs({"Hide","Top","Bottom","Left","Right"}) do
		info.text=v
		info.value=k
		info.func= OptionFunctions.TargetTargetTargetBuffPosSelectChoice
		info.checked = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

function OptionFunctions.PartyBuffPosSelectChoice()
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[5].BuffPosition, this:GetID())
	LunaOptions.frames["LunaPartyFrames"].ShowBuffs = this:GetID()
	LunaUnitFrames:UpdatePartyBuffSize()
end

function OptionFunctions.PartyBuffPosSelect()
	local info={}
	for k,v in ipairs({"Hide","Top","Bottom","Left","Right"}) do
		info.text=v
		info.value=k
		info.func= OptionFunctions.PartyBuffPosSelectChoice
		info.checked = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

function OptionFunctions.EnergyTickerToggle()
	if LunaOptions.EnergyTicker == 1 then
		LunaOptions.EnergyTicker = 0
		LunaPlayerFrame.bars["Powerbar"]:SetScript("OnUpdate", nil)
	else
		LunaOptions.EnergyTicker = 1
		LunaPlayerFrame.bars["Powerbar"]:SetScript("OnUpdate", LunaPlayerFrame.bars["Powerbar"].EnergyUpdate)
	end
	LunaUnitFrames:UpdatePlayerFrame()
end

function OptionFunctions.ToggleFlipTarget()
	if LunaOptions.fliptarget then
		LunaOptions.fliptarget = nil
	else
		LunaOptions.fliptarget = 1
	end
	LunaTargetFrame.AdjustBars()
end

function OptionFunctions.ToggleHideHealing()
	if LunaOptions.HideHealing then
		LunaOptions.HideHealing = nil
	else
		LunaOptions.HideHealing = 1
	end
	LunaTargetFrame.AdjustBars()
end

function OptionFunctions.PartyGrowthToggle()
	if LunaOptions.VerticalParty == 1 then
		LunaOptions.VerticalParty = 0
	else
		LunaOptions.VerticalParty = 1
	end
	LunaUnitFrames:UpdatePartyPosition()
end

function OptionFunctions.PartySpaceAdjust()
	LunaOptions.PartySpace = this:GetValue()
	getglobal("SpaceSliderText"):SetText("Party Space between units: "..LunaOptions.PartySpace)
	LunaUnitFrames:UpdatePartyPosition()
end

function OptionFunctions.PartyRangeToggle()
	if LunaOptions.PartyRange == 1 then
		LunaOptions.PartyRange = 0
		for i=1, 4 do
			LunaPartyFrames[i]:SetAlpha(1)
		end
	else
		LunaOptions.PartyRange = 1
	end
end

function OptionFunctions.PartyinRaidToggle()
	if LunaOptions.PartyinRaid == 1 then
		LunaOptions.PartyinRaid = 0
	else
		LunaOptions.PartyinRaid = 1
	end
	LunaUnitFrames:UpdatePartyFrames()
end

function OptionFunctions.PartyInRaidFrame()
	if LunaOptions.partyraidframe == 1 then
		LunaOptions.partyraidframe = nil
	else
		LunaOptions.partyraidframe = 1
	end
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.LockFrames()
	LunaUnitFrames:TogglePlayerLock()
	LunaUnitFrames:ToggleTargetLock()
	LunaUnitFrames:ToggleTargetTargetLock()
	LunaUnitFrames:TogglePetLock()
	LunaUnitFrames:TogglePartyLock()
	LunaUnitFrames:ToggleRaidFrameLock()
end

function OptionFunctions.UpdateAll()
	LunaUnitFrames:UpdatePlayerFrame()
	LunaUnitFrames:UpdatePetFrame()
	LunaUnitFrames:UpdateTargetFrame()
	LunaUnitFrames:UpdateTargetTargetFrame()
	LunaUnitFrames:UpdateTargetTargetTargetFrame()
	LunaUnitFrames:UpdatePartyFrames()
	LunaUnitFrames:UpdatePartyPetFrames()
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.ToggleBlizzPlayer()
	if not LunaOptions.BlizzPlayer then
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
		PlayerFrame_Update()
		UnitFrameHealthBar_Update(PlayerFrame.healthhar, "player")
		UnitFrameManaBar_Update(PlayerFrame.manabar, "player")
		LunaOptions.BlizzPlayer = 1
	else
		PlayerFrame:UnregisterAllEvents()
		PlayerFrame:Hide()
		LunaOptions.BlizzPlayer = nil
	end
end

function OptionFunctions.ToggleBlizzTarget()
	ClearTarget()
	if not LunaOptions.BlizzTarget then
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
		LunaOptions.BlizzTarget = 1
	else
		TargetFrame:UnregisterAllEvents()
		TargetFrame:Hide()
		ComboFrame:UnregisterAllEvents()
		ComboFrame:Hide()
		LunaOptions.BlizzTarget = nil
	end
end

function OptionFunctions.ToggleBlizzParty()
	if not LunaOptions.BlizzParty then
		RaidOptionsFrame_UpdatePartyFrames = LunaUnitFrames.RaidOptionsFrame_UpdatePartyFrames
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

			UnitFrame_OnEvent("PARTY_MEMBERS_CHANGED")
			ShowPartyFrame()
		end
		LunaOptions.BlizzParty = 1
	else
		LunaUnitFrames.RaidOptionsFrame_UpdatePartyFrames = RaidOptionsFrame_UpdatePartyFrames
		RaidOptionsFrame_UpdatePartyFrames = function () end
		for i=1,4 do
			local frame = getglobal("PartyMemberFrame"..i)
			frame:UnregisterAllEvents()
			frame:Hide()
		end
		LunaOptions.BlizzParty = nil
	end
end

function OptionFunctions.enableFrame()
	if LunaOptions.frames[this.frame].enabled == 1 then
		LunaOptions.frames[this.frame].enabled = 0
	else
		LunaOptions.frames[this.frame].enabled = 1
	end
	OptionFunctions.UpdateAll()
end

function OptionFunctions.enableRaid()
	if LunaOptions.enableRaid == 1 then
		LunaOptions.enableRaid = 0
	else
		LunaOptions.enableRaid = 1
	end
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.ToggleVertRaidHealthBars()
	if not LunaOptions.frames["LunaRaidFrames"].verticalHealth then
		LunaOptions.frames["LunaRaidFrames"].verticalHealth = 1
	else
		LunaOptions.frames["LunaRaidFrames"].verticalHealth = nil
	end
	LunaUnitFrames:UpdateRaidLayout()
end
	
function OptionFunctions.ToggleRaidPowerBars()
	if not LunaOptions.frames["LunaRaidFrames"].pBars then
		LunaOptions.frames["LunaRaidFrames"].pBars = 1
		LunaOptionsFrame.pages[7].pBarvertswitch:Enable()
		LunaOptionsFrame.pages[7].pBarvertswitch:SetChecked(nil)
	else
		LunaOptions.frames["LunaRaidFrames"].pBars = nil
		LunaOptionsFrame.pages[7].pBarvertswitch:Disable()
	end
	LunaUnitFrames:UpdateRaidLayout()
end

function OptionFunctions.ToggleVertRaidPowerBars()
	if not (LunaOptions.frames["LunaRaidFrames"].pBars == 2) then
		LunaOptions.frames["LunaRaidFrames"].pBars = 2
	else
		LunaOptions.frames["LunaRaidFrames"].pBars = 1
	end
	LunaUnitFrames:UpdateRaidLayout()
end

function OptionFunctions.ToggleCenterIcon()
	if not LunaOptions.frames["LunaRaidFrames"].centerIcon then
		LunaOptions.frames["LunaRaidFrames"].centerIcon = 1
	else
		LunaOptions.frames["LunaRaidFrames"].centerIcon = nil
	end
	LunaUnitFrames:UpdateRaidLayout()
end
	
function OptionFunctions.ToggleHealerMode()
	if not LunaOptions.HealerModeHealth then
		LunaOptions.HealerModeHealth = 1
	else
		LunaOptions.HealerModeHealth = nil
	end
	OptionFunctions.UpdateAll()
end

function OptionFunctions.TogglePercents()
	if not LunaOptions.Percentages then
		LunaOptions.Percentages = 1
	else
		LunaOptions.Percentages = nil
	end
	LunaUnitFrames:UpdatePlayerFrame()
	LunaUnitFrames:UpdatePetFrame()
	LunaUnitFrames:UpdateTargetFrame()
	LunaUnitFrames:UpdatePartyFrames()
end

function OptionFunctions.OverhealAdjust()
	LunaOptions.overheal = this:GetValue()
	getglobal(this:GetName().."Text"):SetText("Overlap percent of healbar: "..LunaOptions.overheal)
	LunaUnitFrames:UpdatePlayerFrame()
	LunaUnitFrames:UpdateTargetFrame()
	LunaUnitFrames:UpdatePartyFrames()
end

function OptionFunctions.ToggleInvertHealthBars()
	if not LunaOptions.frames["LunaRaidFrames"].inverthealth then
		LunaOptions.frames["LunaRaidFrames"].inverthealth = 1
	else
		LunaOptions.frames["LunaRaidFrames"].inverthealth = nil
	end
	LunaUnitFrames:UpdateRaidRoster()
end

function LunaOptionsModule:CreateMenu()
	LunaOptionsFrame = CreateFrame("Frame", "LunaOptionsMenu", UIParent)
	LunaOptionsFrame:SetHeight(400)
	LunaOptionsFrame:SetWidth(700)
	LunaOptionsFrame:SetBackdrop(LunaOptions.backdrop)
	LunaOptionsFrame:SetBackdropColor(0.18,0.27,0.5)
	LunaOptionsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	LunaOptionsFrame:SetFrameStrata("DIALOG")
	LunaOptionsFrame:EnableMouse(1)
	LunaOptionsFrame:SetMovable(1)
	LunaOptionsFrame:RegisterForDrag("LeftButton")
	LunaOptionsFrame:SetScript("OnDragStart", OptionFunctions.StartMoving)
	LunaOptionsFrame:SetScript("OnDragStop", OptionFunctions.StopMovingOrSizing)
	LunaOptionsFrame:Hide()

	LunaOptionsFrame.CloseButton = CreateFrame("Button", "LunaOptionsCloseButton", LunaOptionsFrame,"UIPanelCloseButton")
	LunaOptionsFrame.CloseButton:SetPoint("TOPRIGHT", LunaOptionsFrame, "TOPRIGHT", 0, 0)

	LunaOptionsFrame.icon = LunaOptionsFrame:CreateTexture(nil, "ARTWORK", LunaOptionsFrame)
	LunaOptionsFrame.icon:SetTexture(LunaOptions.icontexture)
	LunaOptionsFrame.icon:SetHeight(64)
	LunaOptionsFrame.icon:SetWidth(64)
	LunaOptionsFrame.icon:SetPoint("TOPLEFT", LunaOptionsFrame, "TOPLEFT", 0, 0)

	LunaOptionsFrame.name = LunaOptionsFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
	LunaOptionsFrame.name:SetPoint("TOP", LunaOptionsFrame, "TOP", 0, -10)
	LunaOptionsFrame.name:SetShadowColor(0, 0, 0)
	LunaOptionsFrame.name:SetShadowOffset(0.8, -0.8)
	LunaOptionsFrame.name:SetTextColor(1,1,1)
	LunaOptionsFrame.name:SetText("LUNA UNIT FRAMES")

	LunaOptionsFrame.pages = {}

	for i, v in pairs(OptionsPageNames) do
		LunaOptionsFrame.pages[i] = CreateFrame("Frame", v.title.." Page", LunaOptionsFrame)
		LunaOptionsFrame.pages[i]:SetHeight(350)
		LunaOptionsFrame.pages[i]:SetWidth(500)
		LunaOptionsFrame.pages[i]:SetBackdrop(LunaOptions.backdrop)
		LunaOptionsFrame.pages[i]:SetBackdropColor(0,0,0,1)
		LunaOptionsFrame.pages[i]:SetPoint("BOTTOMRIGHT", LunaOptionsFrame, "BOTTOMRIGHT", -10, 10)
		LunaOptionsFrame.pages[i]:Hide()
		
		LunaOptionsFrame.pages[i].name = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[i])
		LunaOptionsFrame.pages[i].name:SetPoint("TOP", LunaOptionsFrame.pages[i], "TOP", 0, -10)
		LunaOptionsFrame.pages[i].name:SetFont(LunaOptions.font, 15)
		LunaOptionsFrame.pages[i].name:SetShadowColor(0, 0, 0)
		LunaOptionsFrame.pages[i].name:SetShadowOffset(0.8, -0.8)
		LunaOptionsFrame.pages[i].name:SetTextColor(1,1,1)
		LunaOptionsFrame.pages[i].name:SetText(v.title.." Configuration")
				
		if i < 7 then
			LunaOptionsFrame.pages[i].enablebutton = CreateFrame("CheckButton", v.title.."EnableButton", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
			LunaOptionsFrame.pages[i].enablebutton:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i], "TOPLEFT", 10, -10)
			LunaOptionsFrame.pages[i].enablebutton:SetHeight(20)
			LunaOptionsFrame.pages[i].enablebutton:SetWidth(20)
			LunaOptionsFrame.pages[i].enablebutton:SetScript("OnClick", OptionFunctions.enableFrame)
			LunaOptionsFrame.pages[i].enablebutton:SetChecked(LunaOptions.frames[v.frame].enabled)
			LunaOptionsFrame.pages[i].enablebutton.frame = v.frame
			getglobal(v.title.."EnableButtonText"):SetText("Enable")
			
			LunaOptionsFrame.pages[i].heightslider = CreateFrame("Slider", v.frame.."HeightSlider", LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
			LunaOptionsFrame.pages[i].heightslider:SetMinMaxValues(20,110)
			LunaOptionsFrame.pages[i].heightslider:SetValueStep(1)
			LunaOptionsFrame.pages[i].heightslider:SetScript("OnValueChanged", OptionFunctions.HeightAdjust)
			LunaOptionsFrame.pages[i].heightslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i], "TOPLEFT", 20, -40)
			LunaOptionsFrame.pages[i].heightslider:SetValue(LunaOptions.frames[v.frame].size.y)
			LunaOptionsFrame.pages[i].heightslider.frame = v.frame
			LunaOptionsFrame.pages[i].heightslider:SetWidth(460)
			getglobal(v.frame.."HeightSliderText"):SetText("Height: "..LunaOptions.frames[v.frame].size.y)

			LunaOptionsFrame.pages[i].widthslider = CreateFrame("Slider", v.frame.."WidthSlider", LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
			LunaOptionsFrame.pages[i].widthslider:SetMinMaxValues(100,400)
			LunaOptionsFrame.pages[i].widthslider:SetValueStep(1)
			LunaOptionsFrame.pages[i].widthslider:SetScript("OnValueChanged", OptionFunctions.WidthAdjust)
			LunaOptionsFrame.pages[i].widthslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].heightslider, "TOPLEFT", 0, -40)
			LunaOptionsFrame.pages[i].widthslider:SetValue(LunaOptions.frames[v.frame].size.x)
			LunaOptionsFrame.pages[i].widthslider.frame = v.frame
			LunaOptionsFrame.pages[i].widthslider:SetWidth(460)
			getglobal(v.frame.."WidthSliderText"):SetText("Width: "..LunaOptions.frames[v.frame].size.x)
			
			LunaOptionsFrame.pages[i].scaleslider = CreateFrame("Slider", v.frame.."ScaleSlider", LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
			LunaOptionsFrame.pages[i].scaleslider:SetMinMaxValues(0.5,2)
			LunaOptionsFrame.pages[i].scaleslider:SetValueStep(0.1)
			LunaOptionsFrame.pages[i].scaleslider:SetScript("OnValueChanged", OptionFunctions.ScaleAdjust)
			LunaOptionsFrame.pages[i].scaleslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].widthslider, "TOPLEFT", 0, -40)
			LunaOptionsFrame.pages[i].scaleslider:SetValue(LunaOptions.frames[v.frame].scale)
			LunaOptionsFrame.pages[i].scaleslider.frame = v.frame
			LunaOptionsFrame.pages[i].scaleslider:SetWidth(460)
			getglobal(v.frame.."ScaleSliderText"):SetText("Scale: "..LunaOptions.frames[v.frame].scale)
		end
	end	
	LunaOptionsFrame.pages[1]:Show()
		
	LunaOptionsFrame.Button0 = CreateFrame("Button", "LunaPlayerFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button0:SetPoint("TOPLEFT", LunaOptionsFrame, "TOPLEFT", 30, -80)
	LunaOptionsFrame.Button0:SetHeight(20)
	LunaOptionsFrame.Button0:SetWidth(140)
	LunaOptionsFrame.Button0:SetText("Player Frame")
	LunaOptionsFrame.Button0:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button0.id = 0
	
	LunaOptionsFrame.Button1 = CreateFrame("Button", "LunaPlayerFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button1:SetPoint("TOPLEFT", LunaOptionsFrame.Button0, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.Button1:SetHeight(20)
	LunaOptionsFrame.Button1:SetWidth(140)
	LunaOptionsFrame.Button1:SetText("Pet Frame")
	LunaOptionsFrame.Button1:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button1.id = 1

	LunaOptionsFrame.Button2 = CreateFrame("Button", "LunaTargetFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button2:SetPoint("TOPLEFT", LunaOptionsFrame.Button1, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.Button2:SetHeight(20)
	LunaOptionsFrame.Button2:SetWidth(140)
	LunaOptionsFrame.Button2:SetText("Target Frame")
	LunaOptionsFrame.Button2:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button2.id = 2

	LunaOptionsFrame.Button3 = CreateFrame("Button", "LunaTargetTargetFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button3:SetPoint("TOPLEFT", LunaOptionsFrame.Button2, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.Button3:SetHeight(20)
	LunaOptionsFrame.Button3:SetWidth(140)
	LunaOptionsFrame.Button3:SetText("TargetTarget Frame")
	LunaOptionsFrame.Button3:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button3.id = 3

	LunaOptionsFrame.Button4 = CreateFrame("Button", "LunaPartyFramesButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button4:SetPoint("TOPLEFT", LunaOptionsFrame.Button3, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.Button4:SetHeight(20)
	LunaOptionsFrame.Button4:SetWidth(140)
	LunaOptionsFrame.Button4:SetText("Party Frames")
	LunaOptionsFrame.Button4:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button4.id = 4

	LunaOptionsFrame.Button5 = CreateFrame("Button", "LunaPartyPetsFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button5:SetPoint("TOPLEFT", LunaOptionsFrame.Button4, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.Button5:SetHeight(20)
	LunaOptionsFrame.Button5:SetWidth(140)
	LunaOptionsFrame.Button5:SetText("Party Pet Frames")
	LunaOptionsFrame.Button5:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button5.id = 5
	
	LunaOptionsFrame.Button6 = CreateFrame("Button", "LunaRaidFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button6:SetPoint("TOPLEFT", LunaOptionsFrame.Button5, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.Button6:SetHeight(20)
	LunaOptionsFrame.Button6:SetWidth(140)
	LunaOptionsFrame.Button6:SetText("Raid Frames")
	LunaOptionsFrame.Button6:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button6.id = 6
	
	LunaOptionsFrame.Button7 = CreateFrame("Button", "LunaGeneralButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button7:SetPoint("TOPLEFT", LunaOptionsFrame.Button6, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.Button7:SetHeight(20)
	LunaOptionsFrame.Button7:SetWidth(140)
	LunaOptionsFrame.Button7:SetText("General Settings")
	LunaOptionsFrame.Button7:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button7.id = 7	

	LunaOptionsFrame.Button8 = CreateFrame("Button", "LunaLockFramesButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button8:SetPoint("TOPLEFT", LunaOptionsFrame.Button7, "BOTTOMLEFT", 0, -20)
	LunaOptionsFrame.Button8:SetHeight(20)
	LunaOptionsFrame.Button8:SetWidth(140)
	LunaOptionsFrame.Button8:SetText("Unlock Frames")
	LunaOptionsFrame.Button8:SetScript("OnClick", OptionFunctions.LockFrames)
	LunaOptionsFrame.Button8.id = 8	
	
	LunaOptionsFrame.Button9 = CreateFrame("Button", "LunaResetFramesButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button9:SetPoint("TOPLEFT", LunaOptionsFrame.Button8, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.Button9:SetHeight(20)
	LunaOptionsFrame.Button9:SetWidth(140)
	LunaOptionsFrame.Button9:SetText("Reset Settings")
	LunaOptionsFrame.Button9:SetScript("OnClick", OptionFunctions.ResetSettings)
	LunaOptionsFrame.Button9.id = 9
	
	LunaOptionsFrame.reset = LunaOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	LunaOptionsFrame.reset:SetPoint("TOP", LunaOptionsFrame.Button9, "BOTTOM", 0, -5)
	LunaOptionsFrame.reset:SetText("[BETA] Requires a UI reload")
	
	LunaOptionsFrame.pages[1].HideCastbar = CreateFrame("CheckButton", "HideCastbar", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].HideCastbar:SetHeight(20)
	LunaOptionsFrame.pages[1].HideCastbar:SetWidth(20)
	LunaOptionsFrame.pages[1].HideCastbar:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1].scaleslider, "TOPLEFT", 0, -40)
	LunaOptionsFrame.pages[1].HideCastbar:SetScript("OnClick", OptionFunctions.HideCastBarToggle)
	LunaOptionsFrame.pages[1].HideCastbar:SetChecked(LunaOptions.hideCastbar)
	getglobal("HideCastbarText"):SetText("Turn off the built-in Castbar")

	LunaOptionsFrame.pages[1].HideBlizzCast = CreateFrame("CheckButton", "HideBlizzCast", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].HideBlizzCast:SetHeight(20)
	LunaOptionsFrame.pages[1].HideBlizzCast:SetWidth(20)
	LunaOptionsFrame.pages[1].HideBlizzCast:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1].HideCastbar, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[1].HideBlizzCast:SetScript("OnClick", OptionFunctions.HideBlizzardCastbarToggle)
	LunaOptionsFrame.pages[1].HideBlizzCast:SetChecked(LunaOptions.hideBlizzCastbar)
	getglobal("HideBlizzCastText"):SetText("Hide original Blizzard Castbar")

	LunaOptionsFrame.pages[1].Portraitmode = CreateFrame("CheckButton", "PortraitmodePlayer", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].Portraitmode:SetHeight(20)
	LunaOptionsFrame.pages[1].Portraitmode:SetWidth(20)
	LunaOptionsFrame.pages[1].Portraitmode.frame = "LunaPlayerFrame"
	LunaOptionsFrame.pages[1].Portraitmode:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1].HideBlizzCast, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[1].Portraitmode:SetScript("OnClick", OptionFunctions.PortraitmodeToggle)
	LunaOptionsFrame.pages[1].Portraitmode:SetChecked((LunaOptions.frames["LunaPlayerFrame"].portrait == 1))
	getglobal("PortraitmodePlayerText"):SetText("Display Portrait as Bar")
	
	LunaOptionsFrame.pages[1].EnergyTicker = CreateFrame("CheckButton", "EnergyTicker", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].EnergyTicker:SetHeight(20)
	LunaOptionsFrame.pages[1].EnergyTicker:SetWidth(20)
	LunaOptionsFrame.pages[1].EnergyTicker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1].Portraitmode, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[1].EnergyTicker:SetScript("OnClick", OptionFunctions.EnergyTickerToggle)
	LunaOptionsFrame.pages[1].EnergyTicker:SetChecked(LunaOptions.EnergyTicker)
	getglobal("EnergyTickerText"):SetText("Enable Energy Ticker")
	
	LunaOptionsFrame.pages[1].XPBar = CreateFrame("CheckButton", "XPBarSwitch", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].XPBar:SetHeight(20)
	LunaOptionsFrame.pages[1].XPBar:SetWidth(20)
	LunaOptionsFrame.pages[1].XPBar:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[1].EnergyTicker, "TOPRIGHT", 0, -30)
	LunaOptionsFrame.pages[1].XPBar:SetScript("OnClick", OptionFunctions.XPBarToggle)
	LunaOptionsFrame.pages[1].XPBar:SetChecked(LunaOptions.XPBar)
	getglobal("XPBarSwitchText"):SetText("Enable XP Bar")
		
	for k,i in ipairs({1,2,3,5}) do
		LunaOptionsFrame.pages[i].BuffPosition = CreateFrame("Button", "BuffSwitch"..i, LunaOptionsFrame.pages[i], "UIDropDownMenuTemplate")
		LunaOptionsFrame.pages[i].BuffPosition:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[i].scaleslider, "BOTTOMRIGHT", -120 , -15)
		UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[i].BuffPosition)
		UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[i].BuffPosition)
		
		LunaOptionsFrame.pages[i].BuffSwitchDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[i])
		LunaOptionsFrame.pages[i].BuffSwitchDesc:SetPoint("LEFT", LunaOptionsFrame.pages[i].BuffPosition, "RIGHT", -10, 0)
		LunaOptionsFrame.pages[i].BuffSwitchDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
		LunaOptionsFrame.pages[i].BuffSwitchDesc:SetTextColor(1,0.82,0)
		LunaOptionsFrame.pages[i].BuffSwitchDesc:SetText("Aura Position")
	end
	
	LunaOptionsFrame.pages[4].BuffPosition = CreateFrame("Button", "BuffSwitch4", LunaOptionsFrame.pages[4], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[4].BuffPosition:SetPoint("TOPLEFT", LunaOptionsFrame.pages[4].scaleslider, "BOTTOMLEFT", -15 , -15)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[4].BuffPosition)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[4].BuffPosition)
	
	LunaOptionsFrame.pages[4].BuffSwitchDesc = LunaOptionsFrame.pages[4]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[4])
	LunaOptionsFrame.pages[4].BuffSwitchDesc:SetPoint("LEFT", LunaOptionsFrame.pages[4].BuffPosition, "RIGHT", -10, 0)
	LunaOptionsFrame.pages[4].BuffSwitchDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[4].BuffSwitchDesc:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[4].BuffSwitchDesc:SetText("Aura Position")
	
	LunaOptionsFrame.pages[4].BuffPosition2 = CreateFrame("Button", "BuffSwitch4.2", LunaOptionsFrame.pages[4], "UIDropDownMenuTemplate")
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[4].BuffPosition2)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[4].BuffPosition2)
	
	LunaOptionsFrame.pages[4].BuffSwitchDesc2 = LunaOptionsFrame.pages[4]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[4])
	LunaOptionsFrame.pages[4].BuffSwitchDesc2:SetPoint("LEFT", LunaOptionsFrame.pages[4].BuffPosition2, "RIGHT", -10, 0)
	LunaOptionsFrame.pages[4].BuffSwitchDesc2:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[4].BuffSwitchDesc2:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[4].BuffSwitchDesc2:SetText("Aura Position")
	
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[1].BuffPosition, OptionFunctions.PlayerBuffPosSelect)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[1].BuffPosition, LunaOptions.frames["LunaPlayerFrame"].ShowBuffs)
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[2].BuffPosition, OptionFunctions.PetBuffPosSelect)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[2].BuffPosition, LunaOptions.frames["LunaPetFrame"].ShowBuffs)
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[3].BuffPosition, OptionFunctions.TargetBuffPosSelect)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[3].BuffPosition, LunaOptions.frames["LunaTargetFrame"].ShowBuffs)
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[4].BuffPosition, OptionFunctions.TargetTargetBuffPosSelect)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[4].BuffPosition, LunaOptions.frames["LunaTargetTargetFrame"].ShowBuffs)
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[4].BuffPosition2, OptionFunctions.TargetTargetTargetBuffPosSelect)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[4].BuffPosition2, LunaOptions.frames["LunaTargetTargetTargetFrame"].ShowBuffs)
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[5].BuffPosition, OptionFunctions.PartyBuffPosSelect)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[5].BuffPosition, LunaOptions.frames["LunaPartyFrames"].ShowBuffs)
	
	LunaOptionsFrame.pages[1].BarSelect = CreateFrame("Button", "BarSelector", LunaOptionsFrame.pages[1], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[1].BarSelect:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[1].BuffPosition, "BOTTOMRIGHT", 0 , -40)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[1].BarSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[1].BarSelect)
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[1].BarSelect, OptionFunctions.PlayerBarSelectorInit)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[1].BarSelect, 1)

	LunaOptionsFrame.pages[1].BuffInRowslider = CreateFrame("Slider", "LunaPlayerFrameBuffInRow", LunaOptionsFrame.pages[1], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[1].BuffInRowslider:SetMinMaxValues(1,16)
	LunaOptionsFrame.pages[1].BuffInRowslider:SetValueStep(1)
	LunaOptionsFrame.pages[1].BuffInRowslider:SetScript("OnValueChanged", OptionFunctions.BuffInRow)
	LunaOptionsFrame.pages[1].BuffInRowslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1].BuffPosition, "BOTTOMLEFT", 20, -6)
	LunaOptionsFrame.pages[1].BuffInRowslider:SetValue(LunaOptions.frames["LunaPlayerFrame"].BuffInRow or 16)
	LunaOptionsFrame.pages[1].BuffInRowslider.frame = "LunaPlayerFrame"
	LunaOptionsFrame.pages[1].BuffInRowslider:SetWidth(230)
	getglobal("LunaPlayerFrameBuffInRowText"):SetText("Auras per row: "..(LunaOptions.frames["LunaPlayerFrame"].BuffInRow or 16))
	
	LunaOptionsFrame.pages[1].barheight = CreateFrame("Slider", "BarSizer", LunaOptionsFrame.pages[1], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[1].barheight.frame = "LunaPlayerFrame"
	LunaOptionsFrame.pages[1].barheight:SetMinMaxValues(0,10)
	LunaOptionsFrame.pages[1].barheight:SetValueStep(1)
	LunaOptionsFrame.pages[1].barheight:SetScript("OnValueChanged", OnBarHeight)
	LunaOptionsFrame.pages[1].barheight:SetPoint("TOP", LunaOptionsFrame.pages[1].BarSelect, "BOTTOM", 70, -20)
	LunaOptionsFrame.pages[1].barheight:SetValue(LunaOptions.frames[LunaOptionsFrame.pages[1].barheight.frame].bars[1][2])
	LunaOptionsFrame.pages[1].barheight:SetWidth(230)
	
	
	LunaOptionsFrame.pages[1].barorder = CreateFrame("Slider", "BarOrderSlider", LunaOptionsFrame.pages[1], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[1].barorder.frame = "LunaPlayerFrame"
	LunaOptionsFrame.pages[1].barorder:SetMinMaxValues(1,table.getn(LunaOptions.frames["LunaPlayerFrame"].bars))
	LunaOptionsFrame.pages[1].barorder:SetValueStep(1)
	LunaOptionsFrame.pages[1].barorder:SetScript("OnValueChanged", OptionFunctions.OnOrderSlider)
	LunaOptionsFrame.pages[1].barorder:SetPoint("TOP", LunaOptionsFrame.pages[1].barheight, "BOTTOM", 0, -20)
	LunaOptionsFrame.pages[1].barorder:SetWidth(230)
	
	for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
		if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[1].BarSelect) then
			LunaOptionsFrame.pages[1].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[1].barorder:SetValue(k)
			break
		end
	end

	getglobal("BarSizerText"):SetText("Bar height weight: "..LunaOptionsFrame.pages[1].barheight:GetValue())
	getglobal("BarOrderSliderText"):SetText("Bar Position: "..LunaOptionsFrame.pages[1].barorder:GetValue())
	
	LunaOptionsFrame.pages[2].Portraitmode = CreateFrame("CheckButton", "PortraitmodePet", LunaOptionsFrame.pages[2], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[2].Portraitmode:SetHeight(20)
	LunaOptionsFrame.pages[2].Portraitmode:SetWidth(20)
	LunaOptionsFrame.pages[2].Portraitmode.frame = "LunaPetFrame"
	LunaOptionsFrame.pages[2].Portraitmode:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].scaleslider, "TOPLEFT", 0, -40)
	LunaOptionsFrame.pages[2].Portraitmode:SetScript("OnClick", OptionFunctions.PortraitmodeToggle)
	LunaOptionsFrame.pages[2].Portraitmode:SetChecked((LunaOptions.frames["LunaPetFrame"].portrait == 1))
	getglobal("PortraitmodePetText"):SetText("Display Portrait as Bar")

	LunaOptionsFrame.pages[2].BuffInRowslider = CreateFrame("Slider", "LunaPetFrameBuffInRow", LunaOptionsFrame.pages[2], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[2].BuffInRowslider:SetMinMaxValues(1,16)
	LunaOptionsFrame.pages[2].BuffInRowslider:SetValueStep(1)
	LunaOptionsFrame.pages[2].BuffInRowslider:SetScript("OnValueChanged", OptionFunctions.BuffInRow)
	LunaOptionsFrame.pages[2].BuffInRowslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].BuffPosition, "BOTTOMLEFT", 20, -6)
	LunaOptionsFrame.pages[2].BuffInRowslider:SetValue(LunaOptions.frames["LunaPetFrame"].BuffInRow or 16)
	LunaOptionsFrame.pages[2].BuffInRowslider.frame = "LunaPetFrame"
	LunaOptionsFrame.pages[2].BuffInRowslider:SetWidth(230)
	getglobal("LunaPetFrameBuffInRowText"):SetText("Auras per row: "..(LunaOptions.frames["LunaPetFrame"].BuffInRow or 16))
	
	LunaOptionsFrame.pages[2].BarSelect = CreateFrame("Button", "BarSelector2", LunaOptionsFrame.pages[2], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[2].BarSelect:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[2].BuffPosition, "BOTTOMRIGHT", 0 , -40)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[2].BarSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[2].BarSelect)
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[2].BarSelect, OptionFunctions.PetBarSelectorInit)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[2].BarSelect, 1)
		
	LunaOptionsFrame.pages[2].barheight = CreateFrame("Slider", "BarSizer2", LunaOptionsFrame.pages[2], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[2].barheight.frame = "LunaPetFrame"
	LunaOptionsFrame.pages[2].barheight:SetMinMaxValues(0,10)
	LunaOptionsFrame.pages[2].barheight:SetValueStep(1)
	LunaOptionsFrame.pages[2].barheight:SetScript("OnValueChanged", OnBarHeight)
	LunaOptionsFrame.pages[2].barheight:SetPoint("TOP", LunaOptionsFrame.pages[2].BarSelect, "BOTTOM", 70, -20)
	LunaOptionsFrame.pages[2].barheight:SetValue(LunaOptions.frames[LunaOptionsFrame.pages[2].barheight.frame].bars[1][2])
	LunaOptionsFrame.pages[2].barheight:SetWidth(230)
	
	LunaOptionsFrame.pages[2].barorder = CreateFrame("Slider", "BarOrderSlider2", LunaOptionsFrame.pages[2], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[2].barorder.frame = "LunaPetFrame"
	LunaOptionsFrame.pages[2].barorder:SetMinMaxValues(1,table.getn(LunaOptions.frames["LunaPetFrame"].bars))
	LunaOptionsFrame.pages[2].barorder:SetValueStep(1)
	LunaOptionsFrame.pages[2].barorder:SetScript("OnValueChanged", OptionFunctions.OnOrderSlider)
	LunaOptionsFrame.pages[2].barorder:SetPoint("TOP", LunaOptionsFrame.pages[2].barheight, "BOTTOM", 0, -20)
	LunaOptionsFrame.pages[2].barorder:SetWidth(230)
	
	for k,v in pairs(LunaOptions.frames["LunaPetFrame"].bars) do
		if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[2].BarSelect) then
			LunaOptionsFrame.pages[2].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[2].barorder:SetValue(k)
			break
		end
	end
	
	getglobal("BarSizer2Text"):SetText("Bar height weight: "..LunaOptionsFrame.pages[2].barheight:GetValue())
	getglobal("BarOrderSlider2Text"):SetText("Bar Position: "..LunaOptionsFrame.pages[2].barorder:GetValue())
	
	LunaOptionsFrame.pages[3].Portraitmode = CreateFrame("CheckButton", "PortraitmodeTarget", LunaOptionsFrame.pages[3], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[3].Portraitmode:SetHeight(20)
	LunaOptionsFrame.pages[3].Portraitmode:SetWidth(20)
	LunaOptionsFrame.pages[3].Portraitmode.frame = "LunaTargetFrame"
	LunaOptionsFrame.pages[3].Portraitmode:SetPoint("TOPLEFT", LunaOptionsFrame.pages[3].scaleslider, "TOPLEFT", 0, -40)
	LunaOptionsFrame.pages[3].Portraitmode:SetScript("OnClick", OptionFunctions.PortraitmodeToggle)
	LunaOptionsFrame.pages[3].Portraitmode:SetChecked((LunaOptions.frames["LunaTargetFrame"].portrait == 1))
	getglobal("PortraitmodeTargetText"):SetText("Display Portrait as Bar")
	
	LunaOptionsFrame.pages[3].fliptarget = CreateFrame("CheckButton", "FlipTarget", LunaOptionsFrame.pages[3], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[3].fliptarget:SetHeight(20)
	LunaOptionsFrame.pages[3].fliptarget:SetWidth(20)
	LunaOptionsFrame.pages[3].fliptarget:SetPoint("TOPLEFT", LunaOptionsFrame.pages[3].Portraitmode, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[3].fliptarget:SetScript("OnClick", OptionFunctions.ToggleFlipTarget)
	LunaOptionsFrame.pages[3].fliptarget:SetChecked(LunaOptions.fliptarget)
	getglobal("FlipTargetText"):SetText("Flip Target Layout")

	LunaOptionsFrame.pages[3].HideHealing = CreateFrame("CheckButton", "HideHealing", LunaOptionsFrame.pages[3], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[3].HideHealing:SetHeight(20)
	LunaOptionsFrame.pages[3].HideHealing:SetWidth(20)
	LunaOptionsFrame.pages[3].HideHealing:SetPoint("TOPLEFT", LunaOptionsFrame.pages[3].fliptarget, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[3].HideHealing:SetScript("OnClick", OptionFunctions.ToggleHideHealing)
	LunaOptionsFrame.pages[3].HideHealing:SetChecked(LunaOptions.HideHealing or 0)
	getglobal("HideHealingText"):SetText("Hide Incoming Heals")
	
	LunaOptionsFrame.pages[3].BuffInRowslider = CreateFrame("Slider", "LunaTargetFrameBuffInRow", LunaOptionsFrame.pages[3], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[3].BuffInRowslider:SetMinMaxValues(1,16)
	LunaOptionsFrame.pages[3].BuffInRowslider:SetValueStep(1)
	LunaOptionsFrame.pages[3].BuffInRowslider:SetScript("OnValueChanged", OptionFunctions.BuffInRow)
	LunaOptionsFrame.pages[3].BuffInRowslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[3].BuffPosition, "BOTTOMLEFT", 20, -6)
	LunaOptionsFrame.pages[3].BuffInRowslider:SetValue(LunaOptions.frames["LunaTargetFrame"].BuffInRow or 16)
	LunaOptionsFrame.pages[3].BuffInRowslider.frame = "LunaTargetFrame"
	LunaOptionsFrame.pages[3].BuffInRowslider:SetWidth(230)
	getglobal("LunaTargetFrameBuffInRowText"):SetText("Auras per row: "..(LunaOptions.frames["LunaTargetFrame"].BuffInRow or 16))
	
	LunaOptionsFrame.pages[3].BarSelect = CreateFrame("Button", "BarSelector3", LunaOptionsFrame.pages[3], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[3].BarSelect:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[3].BuffPosition, "BOTTOMRIGHT", 0 , -40)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[3].BarSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[3].BarSelect)
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[3].BarSelect, OptionFunctions.TargetBarSelectorInit)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[3].BarSelect, 1)
	
	LunaOptionsFrame.pages[3].barheight = CreateFrame("Slider", "BarSizer3", LunaOptionsFrame.pages[3], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[3].barheight.frame = "LunaTargetFrame"
	LunaOptionsFrame.pages[3].barheight:SetMinMaxValues(0,10)
	LunaOptionsFrame.pages[3].barheight:SetValueStep(1)
	LunaOptionsFrame.pages[3].barheight:SetScript("OnValueChanged", OnBarHeight)
	LunaOptionsFrame.pages[3].barheight:SetPoint("TOP", LunaOptionsFrame.pages[3].BarSelect, "BOTTOM", 70, -20)
	LunaOptionsFrame.pages[3].barheight:SetWidth(230)
	
	LunaOptionsFrame.pages[3].barorder = CreateFrame("Slider", "BarOrderSlider3", LunaOptionsFrame.pages[3], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[3].barorder.frame = "LunaTargetFrame"
	LunaOptionsFrame.pages[3].barorder:SetMinMaxValues(1,table.getn(LunaOptions.frames["LunaTargetFrame"].bars))
	LunaOptionsFrame.pages[3].barorder:SetValueStep(1)
	LunaOptionsFrame.pages[3].barorder:SetScript("OnValueChanged", OptionFunctions.OnOrderSlider)
	LunaOptionsFrame.pages[3].barorder:SetPoint("TOP", LunaOptionsFrame.pages[3].barheight, "BOTTOM", 0, -20)
	LunaOptionsFrame.pages[3].barorder:SetWidth(230)
	
	for k,v in pairs(LunaOptions.frames["LunaTargetFrame"].bars) do
		if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[3].BarSelect) then
			LunaOptionsFrame.pages[3].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[3].barorder:SetValue(k)
			break
		end
	end	
	
	getglobal("BarSizer3Text"):SetText("Bar height weight: "..LunaOptionsFrame.pages[3].barheight:GetValue())
	getglobal("BarOrderSlider3Text"):SetText("Bar Position: "..LunaOptionsFrame.pages[3].barorder:GetValue())

	LunaOptionsFrame.pages[4].heightslider:SetWidth(250)	
	LunaOptionsFrame.pages[4].widthslider:SetWidth(250)
	LunaOptionsFrame.pages[4].scaleslider:SetWidth(250)
	
	LunaOptionsFrame.pages[4].BarSelect = CreateFrame("Button", "BarSelector4", LunaOptionsFrame.pages[4], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[4].BarSelect:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[4], "TOPRIGHT", -100 , -35)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[4].BarSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[4].BarSelect)
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[4].BarSelect, OptionFunctions.TargetTargetBarSelectorInit)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[4].BarSelect, 1)
	
	LunaOptionsFrame.pages[4].barheight = CreateFrame("Slider", "BarSizer4", LunaOptionsFrame.pages[4], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[4].barheight.frame = "LunaTargetTargetFrame"
	LunaOptionsFrame.pages[4].barheight:SetMinMaxValues(0,10)
	LunaOptionsFrame.pages[4].barheight:SetValueStep(1)
	LunaOptionsFrame.pages[4].barheight:SetScript("OnValueChanged", OnBarHeight)
	LunaOptionsFrame.pages[4].barheight:SetPoint("TOP", LunaOptionsFrame.pages[4].BarSelect, "BOTTOM", 55, -15)
	LunaOptionsFrame.pages[4].barheight:SetWidth(200)
	
	LunaOptionsFrame.pages[4].barorder = CreateFrame("Slider", "BarOrderSlider4", LunaOptionsFrame.pages[4], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[4].barorder.frame = "LunaTargetTargetFrame"
	LunaOptionsFrame.pages[4].barorder:SetMinMaxValues(1,table.getn(LunaOptions.frames["LunaTargetTargetFrame"].bars))
	LunaOptionsFrame.pages[4].barorder:SetValueStep(1)
	LunaOptionsFrame.pages[4].barorder:SetScript("OnValueChanged", OptionFunctions.OnOrderSlider)
	LunaOptionsFrame.pages[4].barorder:SetPoint("TOP", LunaOptionsFrame.pages[4].barheight, "BOTTOM", 0, -20)
	LunaOptionsFrame.pages[4].barorder:SetWidth(200)
	
	LunaOptionsFrame.pages[4].BuffInRowslider = CreateFrame("Slider", "LunaTargetTargetFrameBuffInRow", LunaOptionsFrame.pages[4], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[4].BuffInRowslider:SetMinMaxValues(1,16)
	LunaOptionsFrame.pages[4].BuffInRowslider:SetValueStep(1)
	LunaOptionsFrame.pages[4].BuffInRowslider:SetScript("OnValueChanged", OptionFunctions.BuffInRow)
	LunaOptionsFrame.pages[4].BuffInRowslider:SetPoint("TOP", LunaOptionsFrame.pages[4].barorder, "BOTTOM", 0, -20)
	LunaOptionsFrame.pages[4].BuffInRowslider:SetValue(LunaOptions.frames["LunaTargetTargetFrame"].BuffInRow or 16)
	LunaOptionsFrame.pages[4].BuffInRowslider.frame = "LunaTargetTargetFrame"
	LunaOptionsFrame.pages[4].BuffInRowslider:SetWidth(200)
	getglobal("LunaTargetTargetFrameBuffInRowText"):SetText("Auras per row: "..(LunaOptions.frames["LunaTargetTargetFrame"].BuffInRow or 16))
	
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetFrame"].bars) do
		if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[4].BarSelect) then
			LunaOptionsFrame.pages[4].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[4].barorder:SetValue(k)
			break
		end
	end	
	
	getglobal("BarSizer4Text"):SetText("Bar height weight: "..LunaOptionsFrame.pages[4].barheight:GetValue())
	getglobal("BarOrderSlider4Text"):SetText("Bar Position: "..LunaOptionsFrame.pages[4].barorder:GetValue())
	
	LunaOptionsFrame.pages[4].enable2 = CreateFrame("CheckButton", "LunaTargetTargetTargetFrameEnableButton", LunaOptionsFrame.pages[4], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[4].enable2:SetPoint("TOPLEFT", LunaOptionsFrame.pages[4], "TOPLEFT", 10, -190)
	LunaOptionsFrame.pages[4].enable2:SetHeight(20)
	LunaOptionsFrame.pages[4].enable2:SetWidth(20)
	LunaOptionsFrame.pages[4].enable2:SetScript("OnClick", OptionFunctions.enableFrame)
	LunaOptionsFrame.pages[4].enable2:SetChecked(LunaOptions.frames["LunaTargetTargetTargetFrame"].enabled)
	LunaOptionsFrame.pages[4].enable2.frame = "LunaTargetTargetTargetFrame"
	getglobal("LunaTargetTargetTargetFrameEnableButtonText"):SetText("Enable")
	
	LunaOptionsFrame.pages[4].name2 = LunaOptionsFrame.pages[4]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[4])
	LunaOptionsFrame.pages[4].name2:SetPoint("TOP", LunaOptionsFrame.pages[4].name, "BOTTOM", 0, -155)
	LunaOptionsFrame.pages[4].name2:SetFont(LunaOptions.font, 15)
	LunaOptionsFrame.pages[4].name2:SetShadowColor(0, 0, 0)
	LunaOptionsFrame.pages[4].name2:SetShadowOffset(0.8, -0.8)
	LunaOptionsFrame.pages[4].name2:SetTextColor(1,1,1)
	LunaOptionsFrame.pages[4].name2:SetText("Target Target Target Frame Configuration")
	
	LunaOptionsFrame.pages[4].heightslider2 = CreateFrame("Slider", "LunaTargetTargetTargetFrameHeightSlider", LunaOptionsFrame.pages[4], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[4].heightslider2:SetMinMaxValues(20,110)
	LunaOptionsFrame.pages[4].heightslider2:SetValueStep(1)
	LunaOptionsFrame.pages[4].heightslider2:SetScript("OnValueChanged", OptionFunctions.HeightAdjust)
	LunaOptionsFrame.pages[4].heightslider2:SetPoint("TOP", LunaOptionsFrame.pages[4].name2, "BOTTOM", -105, -15)
	LunaOptionsFrame.pages[4].heightslider2:SetValue(LunaOptions.frames["LunaTargetTargetTargetFrame"].size.y)
	LunaOptionsFrame.pages[4].heightslider2.frame = "LunaTargetTargetTargetFrame"
	LunaOptionsFrame.pages[4].heightslider2:SetWidth(250)
	getglobal("LunaTargetTargetTargetFrameHeightSliderText"):SetText("Height: "..LunaOptions.frames["LunaTargetTargetTargetFrame"].size.y)

	LunaOptionsFrame.pages[4].widthslider2 = CreateFrame("Slider", "LunaTargetTargetTargetFrameWidthSlider", LunaOptionsFrame.pages[4], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[4].widthslider2:SetMinMaxValues(100,400)
	LunaOptionsFrame.pages[4].widthslider2:SetValueStep(1)
	LunaOptionsFrame.pages[4].widthslider2:SetScript("OnValueChanged", OptionFunctions.WidthAdjust)
	LunaOptionsFrame.pages[4].widthslider2:SetPoint("TOPLEFT", LunaOptionsFrame.pages[4].heightslider2, "TOPLEFT", 0, -40)
	LunaOptionsFrame.pages[4].widthslider2:SetValue(LunaOptions.frames["LunaTargetTargetTargetFrame"].size.x)
	LunaOptionsFrame.pages[4].widthslider2.frame = "LunaTargetTargetTargetFrame"
	LunaOptionsFrame.pages[4].widthslider2:SetWidth(250)
	getglobal("LunaTargetTargetTargetFrameWidthSliderText"):SetText("Width: "..LunaOptions.frames["LunaTargetTargetTargetFrame"].size.x)
	
	LunaOptionsFrame.pages[4].scaleslider2 = CreateFrame("Slider", "LunaTargetTargetTargetFrameScaleSlider", LunaOptionsFrame.pages[4], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[4].scaleslider2:SetMinMaxValues(0.5,2)
	LunaOptionsFrame.pages[4].scaleslider2:SetValueStep(0.1)
	LunaOptionsFrame.pages[4].scaleslider2:SetScript("OnValueChanged", OptionFunctions.ScaleAdjust)
	LunaOptionsFrame.pages[4].scaleslider2:SetPoint("TOPLEFT", LunaOptionsFrame.pages[4].widthslider2, "TOPLEFT", 0, -40)
	LunaOptionsFrame.pages[4].scaleslider2:SetValue(LunaOptions.frames["LunaTargetTargetTargetFrame"].scale)
	LunaOptionsFrame.pages[4].scaleslider2.frame = "LunaTargetTargetTargetFrame"
	LunaOptionsFrame.pages[4].scaleslider2:SetWidth(250)
	getglobal("LunaTargetTargetTargetFrameScaleSliderText"):SetText("Scale: "..LunaOptions.frames["LunaTargetTargetTargetFrame"].scale)
	
	LunaOptionsFrame.pages[4].BuffPosition2:SetPoint("TOPLEFT", LunaOptionsFrame.pages[4].scaleslider2, "BOTTOMLEFT", -15 , -15)
	
	LunaOptionsFrame.pages[4].BarSelect2 = CreateFrame("Button", "BarSelector4.5", LunaOptionsFrame.pages[4], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[4].BarSelect2:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[4], "TOPRIGHT", -100 , -205)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[4].BarSelect2)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[4].BarSelect2)
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[4].BarSelect2, OptionFunctions.TargetTargetTargetBarSelectorInit)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[4].BarSelect2, 1)
	
	LunaOptionsFrame.pages[4].barheight2 = CreateFrame("Slider", "BarSizer4.5", LunaOptionsFrame.pages[4], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[4].barheight2.frame = "LunaTargetTargetTargetFrame"
	LunaOptionsFrame.pages[4].barheight2:SetMinMaxValues(0,10)
	LunaOptionsFrame.pages[4].barheight2:SetValueStep(1)
	LunaOptionsFrame.pages[4].barheight2:SetScript("OnValueChanged", OnBarHeight)
	LunaOptionsFrame.pages[4].barheight2:SetPoint("TOP", LunaOptionsFrame.pages[4].BarSelect2, "BOTTOM", 55, -15)
	LunaOptionsFrame.pages[4].barheight2:SetWidth(200)
	
	LunaOptionsFrame.pages[4].barorder2 = CreateFrame("Slider", "BarOrderSlider4.5", LunaOptionsFrame.pages[4], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[4].barorder2.frame = "LunaTargetTargetTargetFrame"
	LunaOptionsFrame.pages[4].barorder2:SetMinMaxValues(1,table.getn(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars))
	LunaOptionsFrame.pages[4].barorder2:SetValueStep(1)
	LunaOptionsFrame.pages[4].barorder2:SetScript("OnValueChanged", OptionFunctions.OnOrderSlider)
	LunaOptionsFrame.pages[4].barorder2:SetPoint("TOP", LunaOptionsFrame.pages[4].barheight2, "BOTTOM", 0, -20)
	LunaOptionsFrame.pages[4].barorder2:SetWidth(200)
	
	LunaOptionsFrame.pages[4].BuffInRowslider2 = CreateFrame("Slider", "LunaTargetTargetTargetFrameBuffInRow", LunaOptionsFrame.pages[4], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[4].BuffInRowslider2:SetMinMaxValues(1,16)
	LunaOptionsFrame.pages[4].BuffInRowslider2:SetValueStep(1)
	LunaOptionsFrame.pages[4].BuffInRowslider2:SetScript("OnValueChanged", OptionFunctions.BuffInRow)
	LunaOptionsFrame.pages[4].BuffInRowslider2:SetPoint("TOP", LunaOptionsFrame.pages[4].barorder2, "BOTTOM", 0, -20)
	LunaOptionsFrame.pages[4].BuffInRowslider2:SetValue(LunaOptions.frames["LunaTargetTargetFrame"].BuffInRow or 16)
	LunaOptionsFrame.pages[4].BuffInRowslider2.frame = "LunaTargetTargetTargetFrame"
	LunaOptionsFrame.pages[4].BuffInRowslider2:SetWidth(200)
	getglobal("LunaTargetTargetTargetFrameBuffInRowText"):SetText("Auras per row: "..(LunaOptions.frames["LunaTargetTargetTargetFrame"].BuffInRow or 16))
	
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars) do
		if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[4].BarSelect2) then
			LunaOptionsFrame.pages[4].barheight2:SetValue(v[2])
			LunaOptionsFrame.pages[4].barorder2:SetValue(k)
			break
		end
	end	
	
	getglobal("BarSizer4.5Text"):SetText("Bar height weight: "..LunaOptionsFrame.pages[4].barheight2:GetValue())
	getglobal("BarOrderSlider4.5Text"):SetText("Bar Position: "..LunaOptionsFrame.pages[4].barorder2:GetValue())
	
	LunaOptionsFrame.pages[5].BuffInRowslider = CreateFrame("Slider", "LunaPartyFramesBuffInRow", LunaOptionsFrame.pages[5], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[5].BuffInRowslider:SetMinMaxValues(1,16)
	LunaOptionsFrame.pages[5].BuffInRowslider:SetValueStep(1)
	LunaOptionsFrame.pages[5].BuffInRowslider:SetScript("OnValueChanged", OptionFunctions.BuffInRow)
	LunaOptionsFrame.pages[5].BuffInRowslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[5].BuffPosition, "BOTTOMLEFT", 20, -6)
	LunaOptionsFrame.pages[5].BuffInRowslider:SetValue(LunaOptions.frames["LunaPartyFrames"].BuffInRow or 16)
	LunaOptionsFrame.pages[5].BuffInRowslider.frame = "LunaPartyFrames"
	LunaOptionsFrame.pages[5].BuffInRowslider:SetWidth(230)
	getglobal("LunaPartyFramesBuffInRowText"):SetText("Auras per row: "..(LunaOptions.frames["LunaPartyFrames"].BuffInRow or 16))
	
	LunaOptionsFrame.pages[5].BarSelect = CreateFrame("Button", "BarSelector5", LunaOptionsFrame.pages[5], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[5].BarSelect:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[5].BuffPosition, "BOTTOMRIGHT", 0 , -40)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[5].BarSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[5].BarSelect)
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[5].BarSelect, OptionFunctions.PartyBarSelectorInit)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[5].BarSelect, 1)
	
	LunaOptionsFrame.pages[5].barheight = CreateFrame("Slider", "BarSizer5", LunaOptionsFrame.pages[5], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[5].barheight.frame = "LunaPartyFrames"
	LunaOptionsFrame.pages[5].barheight:SetMinMaxValues(0,10)
	LunaOptionsFrame.pages[5].barheight:SetValueStep(1)
	LunaOptionsFrame.pages[5].barheight:SetScript("OnValueChanged", OnBarHeight)
	LunaOptionsFrame.pages[5].barheight:SetPoint("TOP", LunaOptionsFrame.pages[5].BarSelect, "BOTTOM", 70, -20)
	LunaOptionsFrame.pages[5].barheight:SetWidth(230)
	
	LunaOptionsFrame.pages[5].barorder = CreateFrame("Slider", "BarOrderSlider5", LunaOptionsFrame.pages[5], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[5].barorder.frame = "LunaPartyFrames"
	LunaOptionsFrame.pages[5].barorder:SetMinMaxValues(1,table.getn(LunaOptions.frames["LunaPartyFrames"].bars))
	LunaOptionsFrame.pages[5].barorder:SetValueStep(1)
	LunaOptionsFrame.pages[5].barorder:SetScript("OnValueChanged", OptionFunctions.OnOrderSlider)
	LunaOptionsFrame.pages[5].barorder:SetPoint("TOP", LunaOptionsFrame.pages[5].barheight, "BOTTOM", 0, -20)
	LunaOptionsFrame.pages[5].barorder:SetWidth(230)
	
	local place
	for k,v in pairs(LunaOptions.frames["LunaPartyFrames"].bars) do
		if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[5].BarSelect) then
			LunaOptionsFrame.pages[5].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[5].barorder:SetValue(k)
			break
		end
	end	
	
	getglobal("BarSizer5Text"):SetText("Bar height weight: "..LunaOptionsFrame.pages[5].barheight:GetValue())
	getglobal("BarOrderSlider5Text"):SetText("Bar Position: "..LunaOptionsFrame.pages[5].barorder:GetValue())
	
	LunaOptionsFrame.pages[5].spaceslider = CreateFrame("Slider", "SpaceSlider", LunaOptionsFrame.pages[5], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[5].spaceslider:SetMinMaxValues(0,150)
	LunaOptionsFrame.pages[5].spaceslider:SetValueStep(1)
	LunaOptionsFrame.pages[5].spaceslider:SetScript("OnValueChanged", OptionFunctions.PartySpaceAdjust)
	LunaOptionsFrame.pages[5].spaceslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[5].scaleslider, "TOPLEFT", 0, -40)
	LunaOptionsFrame.pages[5].spaceslider:SetValue(LunaOptions.PartySpace)
	LunaOptionsFrame.pages[5].spaceslider:SetWidth(220)
	getglobal("SpaceSliderText"):SetText("Space between units: "..LunaOptions.PartySpace)
	
	LunaOptionsFrame.pages[5].RangeCheck = CreateFrame("CheckButton", "RangeCheck", LunaOptionsFrame.pages[5], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[5].RangeCheck:SetHeight(20)
	LunaOptionsFrame.pages[5].RangeCheck:SetWidth(20)
	LunaOptionsFrame.pages[5].RangeCheck:SetPoint("TOPLEFT", LunaOptionsFrame.pages[5].spaceslider, "TOPLEFT", 0, -40)
	LunaOptionsFrame.pages[5].RangeCheck:SetScript("OnClick", OptionFunctions.PartyRangeToggle)
	LunaOptionsFrame.pages[5].RangeCheck:SetChecked(LunaOptions.PartyRange)
	getglobal("RangeCheckText"):SetText("Enable Range Check")
	
	LunaOptionsFrame.pages[5].PartyinRaid = CreateFrame("CheckButton", "PartyinRaid", LunaOptionsFrame.pages[5], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[5].PartyinRaid:SetHeight(20)
	LunaOptionsFrame.pages[5].PartyinRaid:SetWidth(20)
	LunaOptionsFrame.pages[5].PartyinRaid:SetPoint("TOPLEFT", LunaOptionsFrame.pages[5].RangeCheck, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[5].PartyinRaid:SetScript("OnClick", OptionFunctions.PartyinRaidToggle)
	LunaOptionsFrame.pages[5].PartyinRaid:SetChecked(LunaOptions.PartyinRaid)
	getglobal("PartyinRaidText"):SetText("Show Party while in Raid")
	
	LunaOptionsFrame.pages[5].PartyGrowth = CreateFrame("CheckButton", "PartyGrowth", LunaOptionsFrame.pages[5], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[5].PartyGrowth:SetHeight(20)
	LunaOptionsFrame.pages[5].PartyGrowth:SetWidth(20)
	LunaOptionsFrame.pages[5].PartyGrowth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[5].PartyinRaid, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[5].PartyGrowth:SetScript("OnClick", OptionFunctions.PartyGrowthToggle)
	LunaOptionsFrame.pages[5].PartyGrowth:SetChecked(LunaOptions.VerticalParty)
	getglobal("PartyGrowthText"):SetText("Grow Party Frames vertically")
	
	LunaOptionsFrame.pages[5].Portraitmode = CreateFrame("CheckButton", "PortraitmodeParty", LunaOptionsFrame.pages[5], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[5].Portraitmode:SetHeight(20)
	LunaOptionsFrame.pages[5].Portraitmode:SetWidth(20)
	LunaOptionsFrame.pages[5].Portraitmode.frame = "LunaPartyFrames"
	LunaOptionsFrame.pages[5].Portraitmode:SetPoint("TOPLEFT", LunaOptionsFrame.pages[5].PartyGrowth, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[5].Portraitmode:SetScript("OnClick", OptionFunctions.PortraitmodeToggle)
	LunaOptionsFrame.pages[5].Portraitmode:SetChecked((LunaOptions.frames["LunaPartyFrames"].portrait == 1))
	getglobal("PortraitmodePartyText"):SetText("Display Portrait as Bar")
	
	LunaOptionsFrame.pages[5].inraidframe = CreateFrame("CheckButton", "PartyInRaidFrame", LunaOptionsFrame.pages[5], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[5].inraidframe:SetHeight(20)
	LunaOptionsFrame.pages[5].inraidframe:SetWidth(20)
	LunaOptionsFrame.pages[5].inraidframe:SetPoint("TOPLEFT", LunaOptionsFrame.pages[5].Portraitmode, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[5].inraidframe:SetScript("OnClick", OptionFunctions.PartyInRaidFrame)
	LunaOptionsFrame.pages[5].inraidframe:SetChecked(LunaOptions.partyraidframe)
	getglobal("PartyInRaidFrameText"):SetText("Display Party in Raidframe")

	LunaOptionsFrame.pages[7].enable = CreateFrame("CheckButton", "LunaRaidEnableButton", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].enable:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7], "TOPLEFT", 10, -10)
	LunaOptionsFrame.pages[7].enable:SetHeight(20)
	LunaOptionsFrame.pages[7].enable:SetWidth(20)
	LunaOptionsFrame.pages[7].enable:SetScript("OnClick", OptionFunctions.enableRaid)
	LunaOptionsFrame.pages[7].enable:SetChecked(LunaOptions.enableRaid)
	getglobal("LunaRaidEnableButtonText"):SetText("Enable")
	
	LunaOptionsFrame.pages[7].heightslider = CreateFrame("Slider", "RaidHeightSlider", LunaOptionsFrame.pages[7], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[7].heightslider:SetMinMaxValues(20,150)
	LunaOptionsFrame.pages[7].heightslider:SetValueStep(1)
	LunaOptionsFrame.pages[7].heightslider:SetScript("OnValueChanged", OptionFunctions.RaidHeightAdjust)
	LunaOptionsFrame.pages[7].heightslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7], "TOPLEFT", 20, -60)
	LunaOptionsFrame.pages[7].heightslider:SetValue(LunaOptions.frames["LunaRaidFrames"].height or 30)
	LunaOptionsFrame.pages[7].heightslider:SetWidth(460)
	getglobal("RaidHeightSliderText"):SetText("Height: "..(LunaOptions.frames["LunaRaidFrames"].height or 30))
	
	LunaOptionsFrame.pages[7].widthslider = CreateFrame("Slider", "RaidWidthSlider", LunaOptionsFrame.pages[7], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[7].widthslider:SetMinMaxValues(20,150)
	LunaOptionsFrame.pages[7].widthslider:SetValueStep(1)
	LunaOptionsFrame.pages[7].widthslider:SetScript("OnValueChanged", OptionFunctions.RaidWidthAdjust)
	LunaOptionsFrame.pages[7].widthslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].heightslider, "BOTTOMLEFT", 0, -20)
	LunaOptionsFrame.pages[7].widthslider:SetValue(LunaOptions.frames["LunaRaidFrames"].width or 60)
	LunaOptionsFrame.pages[7].widthslider:SetWidth(460)
	getglobal("RaidWidthSliderText"):SetText("Width: "..LunaOptions.frames["LunaRaidFrames"].width or 60)
	
	LunaOptionsFrame.pages[7].scaleslider = CreateFrame("Slider", "RaidScaleSlider", LunaOptionsFrame.pages[7], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[7].scaleslider:SetMinMaxValues(0.5,2)
	LunaOptionsFrame.pages[7].scaleslider:SetValueStep(0.1)
	LunaOptionsFrame.pages[7].scaleslider:SetScript("OnValueChanged", OptionFunctions.RaidScaleAdjust)
	LunaOptionsFrame.pages[7].scaleslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].widthslider, "BOTTOMLEFT", 0, -20)
	LunaOptionsFrame.pages[7].scaleslider:SetValue(LunaOptions.frames["LunaRaidFrames"].scale or 1)
	LunaOptionsFrame.pages[7].scaleslider:SetWidth(460)
	getglobal("RaidScaleSliderText"):SetText("Scale: "..(LunaOptions.frames["LunaRaidFrames"].scale or 1))
	
	LunaOptionsFrame.pages[7].paddingslider = CreateFrame("Slider", "RaidPaddingSlider", LunaOptionsFrame.pages[7], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[7].paddingslider:SetMinMaxValues(0,20)
	LunaOptionsFrame.pages[7].paddingslider:SetValueStep(1)
	LunaOptionsFrame.pages[7].paddingslider:SetScript("OnValueChanged", OptionFunctions.RaidPaddingAdjust)
	LunaOptionsFrame.pages[7].paddingslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].scaleslider, "BOTTOMLEFT", 0, -20)
	LunaOptionsFrame.pages[7].paddingslider:SetValue(LunaOptions.frames["LunaRaidFrames"].padding or 4)
	LunaOptionsFrame.pages[7].paddingslider:SetWidth(215)
	getglobal("RaidPaddingSliderText"):SetText("Padding: "..(LunaOptions.frames["LunaRaidFrames"].padding or 4))
	
	LunaOptionsFrame.pages[7].RaidGrpNameswitch = CreateFrame("CheckButton", "RaidGroupNamesSwitch", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].RaidGrpNameswitch:SetHeight(20)
	LunaOptionsFrame.pages[7].RaidGrpNameswitch:SetWidth(20)
	LunaOptionsFrame.pages[7].RaidGrpNameswitch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].paddingslider, "TOPLEFT", 0, -40)
	LunaOptionsFrame.pages[7].RaidGrpNameswitch:SetScript("OnClick", OptionFunctions.ToggleRaidGroupNames)
	LunaOptionsFrame.pages[7].RaidGrpNameswitch:SetChecked(LunaOptions.frames["LunaRaidFrames"].ShowRaidGroupTitles)
	getglobal("RaidGroupNamesSwitchText"):SetText("Show Group Names")
	
	LunaOptionsFrame.pages[7].RaidGrpHealthVertswitch = CreateFrame("CheckButton", "RaidGroupHealthVertSwitch", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].RaidGrpHealthVertswitch:SetHeight(20)
	LunaOptionsFrame.pages[7].RaidGrpHealthVertswitch:SetWidth(20)
	LunaOptionsFrame.pages[7].RaidGrpHealthVertswitch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].RaidGrpNameswitch, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[7].RaidGrpHealthVertswitch:SetScript("OnClick", OptionFunctions.ToggleVertRaidHealthBars)
	LunaOptionsFrame.pages[7].RaidGrpHealthVertswitch:SetChecked(LunaOptions.frames["LunaRaidFrames"].verticalHealth)
	getglobal("RaidGroupHealthVertSwitchText"):SetText("Vertical Health Bars")
	
	LunaOptionsFrame.pages[7].pBarswitch = CreateFrame("CheckButton", "RaidGroupPowerSwitch", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].pBarswitch:SetHeight(20)
	LunaOptionsFrame.pages[7].pBarswitch:SetWidth(20)
	LunaOptionsFrame.pages[7].pBarswitch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].RaidGrpHealthVertswitch, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[7].pBarswitch:SetScript("OnClick", OptionFunctions.ToggleRaidPowerBars)
	LunaOptionsFrame.pages[7].pBarswitch:SetChecked(LunaOptions.frames["LunaRaidFrames"].pBars)
	getglobal("RaidGroupPowerSwitchText"):SetText("Show Power Bars")
	
	LunaOptionsFrame.pages[7].pBarvertswitch = CreateFrame("CheckButton", "RaidGroupPowerVertSwitch", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].pBarvertswitch:SetHeight(20)
	LunaOptionsFrame.pages[7].pBarvertswitch:SetWidth(20)
	LunaOptionsFrame.pages[7].pBarvertswitch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].pBarswitch, "TOPLEFT", 10, -20)
	LunaOptionsFrame.pages[7].pBarvertswitch:SetScript("OnClick", OptionFunctions.ToggleVertRaidPowerBars)
	LunaOptionsFrame.pages[7].pBarvertswitch:SetChecked(LunaOptions.frames["LunaRaidFrames"].pBars == 2)
	getglobal("RaidGroupPowerVertSwitchText"):SetText("Vertical Power Bars")
	
	LunaOptionsFrame.pages[7].inverthealth = CreateFrame("CheckButton", "RaidGroupInvertHealthSwitch", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].inverthealth:SetHeight(20)
	LunaOptionsFrame.pages[7].inverthealth:SetWidth(20)
	LunaOptionsFrame.pages[7].inverthealth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].pBarvertswitch, "TOPLEFT", -10, -30)
	LunaOptionsFrame.pages[7].inverthealth:SetScript("OnClick", OptionFunctions.ToggleInvertHealthBars)
	LunaOptionsFrame.pages[7].inverthealth:SetChecked(LunaOptions.frames["LunaRaidFrames"].inverthealth)
	getglobal("RaidGroupInvertHealthSwitchText"):SetText("Invert Health Bars")
	
	LunaOptionsFrame.pages[7].BuffwatchDesc = LunaOptionsFrame.pages[7]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[7])
	LunaOptionsFrame.pages[7].BuffwatchDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].paddingslider, "TOPLEFT", 230, 10)
	LunaOptionsFrame.pages[7].BuffwatchDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[7].BuffwatchDesc:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[7].BuffwatchDesc:SetText("Track Buff (Can be part of name):")
	
	LunaOptionsFrame.pages[7].Buffwatch = CreateFrame("Editbox", BuffwatchInput, LunaOptionsFrame.pages[7], "InputBoxTemplate")
	LunaOptionsFrame.pages[7].Buffwatch:SetHeight(20)
	LunaOptionsFrame.pages[7].Buffwatch:SetWidth(215)
	LunaOptionsFrame.pages[7].Buffwatch:SetAutoFocus(nil)
	LunaOptionsFrame.pages[7].Buffwatch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].BuffwatchDesc, "TOPLEFT", 8, -12)
	LunaOptionsFrame.pages[7].Buffwatch:SetText(LunaOptions.Raidbuff or "")
	LunaOptionsFrame.pages[7].Buffwatch:SetScript("OnEnterPressed", function()
																		this:ClearFocus();
																		LunaOptions.Raidbuff = this:GetText()
																		LunaUnitFrames.Raid_Update()
																	end)
																	
	LunaOptionsFrame.pages[7].dispdebuffs = CreateFrame("CheckButton", "DispDebuffSwitch", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].dispdebuffs:SetHeight(20)
	LunaOptionsFrame.pages[7].dispdebuffs:SetWidth(20)
	LunaOptionsFrame.pages[7].dispdebuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].Buffwatch, "TOPLEFT", 0, -38)
	LunaOptionsFrame.pages[7].dispdebuffs:SetScript("OnClick", OptionFunctions.ToggleDispelableDebuffs)
	LunaOptionsFrame.pages[7].dispdebuffs:SetChecked(LunaOptions.showdispelable)
	getglobal("DispDebuffSwitchText"):SetText("Show only your dispelable Debuffs")

	LunaOptionsFrame.pages[7].aggro = CreateFrame("CheckButton", "AggroSwitch", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].aggro:SetHeight(20)
	LunaOptionsFrame.pages[7].aggro:SetWidth(20)
	LunaOptionsFrame.pages[7].aggro:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].dispdebuffs, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[7].aggro:SetScript("OnClick", OptionFunctions.ToggleAggro)
	LunaOptionsFrame.pages[7].aggro:SetChecked(LunaOptions.aggro)
	getglobal("AggroSwitchText"):SetText("Show aggro warning")
	
	LunaOptionsFrame.pages[7].interlock = CreateFrame("CheckButton", "InterlockSwitch", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].interlock:SetHeight(20)
	LunaOptionsFrame.pages[7].interlock:SetWidth(20)
	LunaOptionsFrame.pages[7].interlock:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].aggro, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[7].interlock:SetScript("OnClick", OptionFunctions.ToggleInterlock)
	LunaOptionsFrame.pages[7].interlock:SetChecked(LunaOptions.raidinterlock)
	getglobal("InterlockSwitchText"):SetText("Interlock Raid Frames")
	
	LunaOptionsFrame.pages[7].centericon = CreateFrame("CheckButton", "CenterIconSwitch", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].centericon:SetHeight(20)
	LunaOptionsFrame.pages[7].centericon:SetWidth(20)
	LunaOptionsFrame.pages[7].centericon:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].interlock, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[7].centericon:SetScript("OnClick", OptionFunctions.ToggleCenterIcon)
	LunaOptionsFrame.pages[7].centericon:SetChecked(LunaOptions.frames["LunaRaidFrames"].centerIcon)
	getglobal("CenterIconSwitchText"):SetText("Display Debuffs as a Center Icon")
	
	LunaOptionsFrame.pages[8].hmodeswitch = CreateFrame("CheckButton", "HealerModeSwitch", LunaOptionsFrame.pages[8], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[8].hmodeswitch:SetHeight(20)
	LunaOptionsFrame.pages[8].hmodeswitch:SetWidth(20)
	LunaOptionsFrame.pages[8].hmodeswitch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[8], "TOPLEFT", 20, -60)
	LunaOptionsFrame.pages[8].hmodeswitch:SetScript("OnClick", OptionFunctions.ToggleHealerMode)
	LunaOptionsFrame.pages[8].hmodeswitch:SetChecked(LunaOptions.HealerModeHealth or 0)
	getglobal("HealerModeSwitchText"):SetText("Healer-mode healthtext")
	
	LunaOptionsFrame.pages[8].percentswitch = CreateFrame("CheckButton", "PercentSwitch", LunaOptionsFrame.pages[8], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[8].percentswitch:SetHeight(20)
	LunaOptionsFrame.pages[8].percentswitch:SetWidth(20)
	LunaOptionsFrame.pages[8].percentswitch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[8].hmodeswitch, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[8].percentswitch:SetScript("OnClick", OptionFunctions.TogglePercents)
	LunaOptionsFrame.pages[8].percentswitch:SetChecked(LunaOptions.Percentages or 0)
	getglobal("PercentSwitchText"):SetText("Display percent after values")
	
	LunaOptionsFrame.pages[8].blizzplayer = CreateFrame("CheckButton", "BlizzPlayerSwitch", LunaOptionsFrame.pages[8], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[8].blizzplayer:SetHeight(20)
	LunaOptionsFrame.pages[8].blizzplayer:SetWidth(20)
	LunaOptionsFrame.pages[8].blizzplayer:SetPoint("TOPLEFT", LunaOptionsFrame.pages[8].percentswitch, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[8].blizzplayer:SetScript("OnClick", OptionFunctions.ToggleBlizzPlayer)
	LunaOptionsFrame.pages[8].blizzplayer:SetChecked(LunaOptions.BlizzPlayer)
	getglobal("BlizzPlayerSwitchText"):SetText("Display Blizzard Player Frame")
	
	LunaOptionsFrame.pages[8].blizztarget = CreateFrame("CheckButton", "BlizzTargetSwitch", LunaOptionsFrame.pages[8], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[8].blizztarget:SetHeight(20)
	LunaOptionsFrame.pages[8].blizztarget:SetWidth(20)
	LunaOptionsFrame.pages[8].blizztarget:SetPoint("TOPLEFT", LunaOptionsFrame.pages[8].blizzplayer, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[8].blizztarget:SetScript("OnClick", OptionFunctions.ToggleBlizzTarget)
	LunaOptionsFrame.pages[8].blizztarget:SetChecked(LunaOptions.BlizzTarget)
	getglobal("BlizzTargetSwitchText"):SetText("Display Blizzard Target Frame")
	
	LunaOptionsFrame.pages[8].blizzparty = CreateFrame("CheckButton", "BlizzPartySwitch", LunaOptionsFrame.pages[8], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[8].blizzparty:SetHeight(20)
	LunaOptionsFrame.pages[8].blizzparty:SetWidth(20)
	LunaOptionsFrame.pages[8].blizzparty:SetPoint("TOPLEFT", LunaOptionsFrame.pages[8].blizztarget, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[8].blizzparty:SetScript("OnClick", OptionFunctions.ToggleBlizzParty)
	LunaOptionsFrame.pages[8].blizzparty:SetChecked(LunaOptions.BlizzParty)
	getglobal("BlizzPartySwitchText"):SetText("Display Blizzard Party Frames")
	
	LunaOptionsFrame.pages[8].overhealslider = CreateFrame("Slider", "OverhealSlider", LunaOptionsFrame.pages[8], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[8].overhealslider:SetMinMaxValues(0,20)
	LunaOptionsFrame.pages[8].overhealslider:SetValueStep(1)
	LunaOptionsFrame.pages[8].overhealslider:SetScript("OnValueChanged", OptionFunctions.OverhealAdjust)
	LunaOptionsFrame.pages[8].overhealslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[8].blizzparty, "BOTTOMLEFT", 0, -20)
	LunaOptionsFrame.pages[8].overhealslider:SetValue(LunaOptions.overheal or 20)
	LunaOptionsFrame.pages[8].overhealslider:SetWidth(215)
	getglobal("OverhealSliderText"):SetText("Overlap percent of healbar: "..(LunaOptions.overheal or 20))
																	
	LunaOptionsFrame:SetScale(1.3)
end