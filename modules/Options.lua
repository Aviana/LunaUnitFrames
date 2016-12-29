local L = LunaUF.L
local defaultFont = LunaUF.defaultFont
local OptionsPageNames = {L["General"],L["Player"],L["Pet"],L["Pet Target"],L["Target"],L["ToT"],L["ToToT"],L["Party"],L["Party Target"],L["Party Pet"],L["Raid"],L["Clickcasting"],L["Colors"],L["Profiles"],L["Config Mode"]}
local shownFrame = 1
local WithTags = {
	["healthBar"] = true,
	["powerBar"] = true,
	["druidBar"] = true,
}

local TagsDescs = {}

TagsDescs[L["INFO TAGS"]] = {
	["numtargeting"] = L["Number of people in your group targeting this unit"],
	["cnumtargeting"] = L["Colored version of numtargeting"],
	["br"] = L["Adds a line break"],
	["name"] = L["Returns plain name of the unit"],
	["shortname"] = L["Returns the first 3 letters of the name"],
	["abbrev:name"] = L["Returns shortened names (Marshall Williams = M. Williams)"],
	["guild"] = L["Guildname"],
	["level"] = L["Current level, returns ?? for bosses and players too high"],
	["smartlevel"] = L["Returns \"Boss\" for bosses and Level+10+ for players too high"],
	["class"] = L["Class of the unit"],
	["smartclass"] = L["Returns Class for players and Creaturetype for NPCs"],
	["rare"] = L["\"rare\" if the creature is rare or rareelite"],
	["elite"] = L["\"elite\" if the creature is elite or rareelite"],
	["classification"] = L["Shows elite, rare, boss, etc..."],
	["shortclassification"] = L["\"E\", \"R\", \"RE\" for the respective classification"],
	["race"] = L["Race if available"],
	["smartrace"] = L["Shows race when if player, creaturetype when npc"],
	["creature"] = L["Creature type (Bat, Wolf , etc..)"],
	["sex"] = L["Gender"],
	["druidform"] = L["Current druid form of friendly unit"],
	["civilian"] = L["Returns (civ) when civilian"],
	["pvp"] = L["Displays \"PvP\" if flagged for it"],
	["rank"] = L["PvP title"],
	["numrank"] = L["Numeric PvP rank"],
	["faction"] = L["Horde or Alliance"],
	["ignore"] = L["Returns (i) if the player is on your ignore list"],
	["server"] = L["Server name"],
	["status"] = L["\"Dead\", \"Ghost\" or \"Offline\""],
	["happiness"] = L["Pet happiness as 'unhappy','content' or 'happy'"],
	["group"] = L["Current subgroup of the raid"],
	["combat"] = L["(c) when in combat"],
}
TagsDescs[L["HEALTH AND POWER TAGS"]] = {
	["namehealerhealth"] = L["The same as \"healerhealth\" but displays name on full health"],
	["healerhealth"] = L["Returns the same as \"smart:healmishp\" on friendly units and hp/maxhp on enemies"],
	["smart:healmishp"] = L["Returns missing hp with healing factored in. Shows status when needed (\"Dead\", \"Offline\", \"Ghost\")"],
	["cpoints"] = L["Combo Points"],
	["smarthealth"] = L["The classic hp display (hp/maxhp and \"Dead\" if dead etc)"],
	["ssmarthealth"] = L["Like [smarthealth] but shortened when over 10K"],
	["healhp"] = L["Current hp and heal in one number (green when heal is incoming)"],
	["hp"] = L["Current hp"],
	["shp"] = L["Current hp shortened when over 10K"],
	["maxhp"] = L["Current maximum hp"],
	["smaxhp"] = L["Current maximum hp shortened when over 10K"],
	["missinghp"] = L["Current missing hp"],
	["healmishp"] = L["Missing hp after incoming heal (green when heal is incoming)"],
	["perhp"] = L["HP percent"],
	["pp"] = L["Current mana/rage/energy etc"],
	["spp"] = L["Current mana/rage/energy etc shortened when over 10K"],
	["maxpp"] = L["Maximum mana/rage/energy etc"],
	["smaxpp"] = L["Maximum mana/rage/energy etc shortened when over 10K"],
	["missingpp"] = L["Missing mana/rage/energy"],
	["perpp"] = L["Mana/rage/energy percent"],
	["druid:pp"] = L["Returns current mana even in druid form"],
	["druid:maxpp"] = L["Returns current maximum mana even in druid form"],
	["druid:missingpp"] = L["Returns missing mana even in druid form"],
	["druid:perpp"] = L["Returns mana percentage even in druid form"],
	["incheal"] = L["Value of incoming heal"],
	["numheals"] = L["Number of incoming heals"],
}
TagsDescs[L["COLOR TAGS"]] = {
	["color:combat"] = L["Red when in combat"],
	["pvpcolor"] = L["White for unflagged units, green for flagged friendlies and red for flagged enemies"],
	["reactcolor"] = L["Red for enemies, yellow for neutrals, and green for friendlies"],
	["levelcolor"] = L["Colors based on your level vs the level of the unit. (grey,green,yellow and red)"],
	["color:aggro"] = L["Red if the unit is targeted by an enemy"],
	["classcolor"] = L["Classcolor of the unit"],
	["healthcolor"] = L["Color based on health (red = dead)"],
	["color:xxxxxx"] = L["Custom color in hexadecimal (rrggbb)"],
	["nocolor"] = L["Resets the color to white"],
}

local function SetDropDownValue(dropdown,value)
	ToggleDropDownMenu(1,value,dropdown)
	UIDropDownMenu_SetSelectedValue(dropdown, value)
end

local function ShowColorPicker(r, g, b, Callback, options)
	ColorPickerFrame.hasOpacity = nil
	ColorPickerFrame.func = Callback
	ColorPickerFrame.options = options
	ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
	ColorPickerFrame:Show();
	ColorPickerFrame:SetColorRGB(r,g,b);
end

function CreateColorSelect(parent, options, name)
	local frame = CreateFrame("Button", name, parent)
	frame.options = options

	frame.colorSwatch = frame:CreateTexture(nil, "OVERLAY")
	frame.colorSwatch:SetWidth(19)
	frame.colorSwatch:SetHeight(19)
	frame.colorSwatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
	frame.colorSwatch:SetPoint("CENTER", frame)

	frame.Callback = function()
		if not ColorPickerFrame:IsVisible() then
			local options = this:GetParent().options
			local r, g, b = ColorPickerFrame:GetColorRGB()
			frame.colorSwatch:SetVertexColor(r, g, b)
			options.r = r
			options.g = g
			options.b = b
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame:IsVisible() then
					LunaUF.Units.FullUpdate(frame)
				end
				frame:SetBackdropColor(LunaUF.db.profile.bgcolor.r,LunaUF.db.profile.bgcolor.g,LunaUF.db.profile.bgcolor.b,LunaUF.db.profile.bgalpha)
			end
		end
	end

	frame.texture = frame:CreateTexture(nil, "BACKGROUND")
	frame.texture:SetWidth(16)
	frame.texture:SetHeight(16)
	frame.texture:SetTexture(1, 1, 1)
	frame.texture:SetPoint("CENTER", frame.colorSwatch)
	frame.texture:Show()

	frame.checkers = frame:CreateTexture(nil, "BACKGROUND")
	frame.checkers:SetWidth(14)
	frame.checkers:SetHeight(14)
	frame.checkers:SetTexture("Tileset\\Generic\\Checkers")
	frame.checkers:SetTexCoord(.25, 0, 0.5, .25)
	frame.checkers:SetDesaturated(true)
	frame.checkers:SetVertexColor(1, 1, 1, 0.75)
	frame.checkers:SetPoint("CENTER", frame.colorSwatch)
	frame.checkers:Show()

	frame.text = frame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
	frame.text:SetHeight(24)
	frame.text:SetJustifyH("LEFT")
	frame.text:SetTextColor(1, 1, 1)
	frame.text:SetPoint("LEFT", frame.colorSwatch, "RIGHT", 2, 0)

	frame:EnableMouse(true)
	frame:SetScript("OnClick", function ()
		local r,g,b = this.colorSwatch:GetVertexColor()
		ShowColorPicker(r, g, b, this.Callback, this.options)
	end)

	frame.load = function (frame, options)
		frame.options = options
		frame.colorSwatch:SetVertexColor(options.r, options.g, options.b)
	end

	return frame
end

local function CreateIndicatorOptionsFrame(parent, indicators)
	local frame = CreateFrame("Frame", nil, parent)
	frame.parent = parent
	local anchor = frame
	local count = 1
	frame:SetWidth(10)
	for name,config in pairs(indicators) do
		frame[name] = {}

		frame[name].enable = CreateFrame("CheckButton", "Enable"..parent.id..name, frame, "UICheckButtonTemplate")
		frame[name].enable.config = config
		frame[name].enable:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, -50)
		frame[name].enable:SetHeight(20)
		frame[name].enable:SetWidth(20)
		frame[name].enable:SetScript("OnClick", function()
			local config = this.config
			config.enabled = not config.enabled
			for _,v in pairs(LunaUF.Units.frameList) do
				if this:GetParent().parent.id == v.unitGroup then
					LunaUF.Units.FullUpdate(v)
				end
			end
		end)
		getglobal("Enable"..parent.id..name.."Text"):SetText(L["Enable"])
		anchor = frame[name].enable

		frame[name].title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		frame[name].title:SetPoint("BOTTOMLEFT", frame[name].enable, "TOPLEFT", 0, 0)
		frame[name].title:SetText(L[name])

		frame[name].sizeslider = CreateFrame("Slider", "SizeSlider"..parent.id..name, frame, "OptionsSliderTemplate")
		frame[name].sizeslider.config = config
		frame[name].sizeslider:SetMinMaxValues(1,80)
		frame[name].sizeslider:SetValueStep(1)
		frame[name].sizeslider:SetScript("OnValueChanged", function()
			local config = this.config
			config.size = math.floor(this:GetValue())
			getglobal(this:GetName().."Text"):SetText(L["Size"]..": "..config.size)
			for _,v in pairs(LunaUF.Units.frameList) do
				if this:GetParent().parent.id == v.unitGroup then
					LunaUF.Units.FullUpdate(v)
				end
			end
		end)
		frame[name].sizeslider:SetPoint("TOPLEFT", frame[name].enable, "TOPLEFT", 60, 0)
		frame[name].sizeslider:SetWidth(100)

		frame[name].anchor = CreateFrame("Button", "AnchorSelector"..parent.id..name, frame, "UIDropDownMenuTemplate")
		frame[name].anchor.config = config
		frame[name].anchor:SetPoint("TOPLEFT", frame[name].enable, "TOPLEFT", 145 , 0)
		UIDropDownMenu_SetWidth(80, frame[name].anchor)
		UIDropDownMenu_JustifyText("LEFT", frame[name].anchor)

		UIDropDownMenu_Initialize(frame[name].anchor, function()
			local info={}
			for _,v in ipairs({"TOPLEFT","TOP","TOPRIGHT","RIGHT","BOTTOMRIGHT","BOTTOM","BOTTOMLEFT","LEFT","CENTER"}) do
				info.text = LunaUF.L[v]
				info.value = v
				info.func= function ()
					local dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU)
					UIDropDownMenu_SetSelectedValue(dropdown, this.value)
					dropdown.config.anchorPoint = UIDropDownMenu_GetSelectedValue(dropdown)
					for _,v in pairs(LunaUF.Units.frameList) do
						if dropdown:GetParent().parent.id == v.unitGroup then
							LunaUF.Units.FullUpdate(v)
						end
					end
				end
				info.checked = nil
				info.checkable = nil
				UIDropDownMenu_AddButton(info, 1)
			end
		end)

		frame[name].xslider = CreateFrame("Slider", "XSlider"..parent.id..name, frame, "OptionsSliderTemplate")
		frame[name].xslider.config = config
		frame[name].xslider:SetMinMaxValues(-50,50)
		frame[name].xslider:SetValueStep(1)
		frame[name].xslider:SetScript("OnValueChanged", function()
			local config = this.config
			config.x = math.floor(this:GetValue())
			getglobal(this:GetName().."Text"):SetText("X: "..config.x)
			for _,v in pairs(LunaUF.Units.frameList) do
				if this:GetParent().parent.id == v.unitGroup then
					LunaUF.Units.FullUpdate(v)
				end
			end
		end)
		frame[name].xslider:SetPoint("TOPLEFT", frame[name].enable, "TOPLEFT", 260, 0)
		frame[name].xslider:SetWidth(100)

		frame[name].yslider = CreateFrame("Slider", "YSlider"..parent.id..name, frame, "OptionsSliderTemplate")
		frame[name].yslider.config = config
		frame[name].yslider:SetMinMaxValues(-50,50)
		frame[name].yslider:SetValueStep(1)
		frame[name].yslider:SetScript("OnValueChanged", function()
			local config = this.config
			config.y = math.floor(this:GetValue())
			getglobal(this:GetName().."Text"):SetText("Y: "..config.y)
			for _,v in pairs(LunaUF.Units.frameList) do
				if this:GetParent().parent.id == v.unitGroup then
					LunaUF.Units.FullUpdate(v)
				end
			end
		end)
		frame[name].yslider:SetPoint("TOPLEFT", frame[name].enable, "TOPLEFT", 370, 0)
		frame[name].yslider:SetWidth(100)

		count = count + 1

	end
	frame.load = function (frame, indicators)
		for name,config in pairs(indicators) do
			frame[name].enable:SetChecked(config.enabled)
			frame[name].enable.config = config
			frame[name].sizeslider:SetValue(config.size)
			frame[name].sizeslider.config = config
			SetDropDownValue(frame[name].anchor,config.anchorPoint)
			frame[name].anchor.config = config
			frame[name].xslider:SetValue(config.x)
			frame[name].xslider.config = config
			frame[name].yslider:SetValue(config.y)
			frame[name].yslider.config = config
		end
	end
	frame:SetHeight(50*count)
	return frame
end

local function CreateTagEditFrame(parent, tagconfig)
	local frame = CreateFrame("Frame", nil, parent)
	frame.config = tagconfig
	frame:SetWidth(10)
	frame.parent = parent
	local anchor = frame
	local count = 1
	for barname,tags in pairs(tagconfig) do
		if barname ~= "totemBar" then
			frame[barname] = {}

			frame[barname].size = CreateFrame("Slider", "Size"..parent.id..barname, frame, "OptionsSliderTemplate")
			frame[barname].size:SetMinMaxValues(5,24)
			frame[barname].size:SetValueStep(1)
			frame[barname].size.config = tags
			frame[barname].size:SetScript("OnValueChanged", function()
				this.config.size = math.floor(this:GetValue())
				getglobal(this:GetName().."Text"):SetText(L["Size"]..": "..this.config.size)
				for _,v in pairs(LunaUF.Units.frameList) do
					if this:GetParent().parent.id == v.unitGroup then
						LunaUF.Units.FullUpdate(v)
					end
				end
			end)
			frame[barname].size:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, -70)
			frame[barname].size:SetWidth(200)

			frame[barname].Desc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			frame[barname].Desc:SetPoint("BOTTOMLEFT", frame[barname].size, "TOPLEFT", 0, 20)
			frame[barname].Desc:SetText(L[barname])

			anchor = frame[barname].size
			if WithTags[barname] then
				frame[barname].middle = CreateFrame("Editbox", "MiddleTag"..parent.id..barname, frame, "InputBoxTemplate")
				frame[barname].middle:SetHeight(20)
				frame[barname].middle:SetWidth(200)
				frame[barname].middle:SetAutoFocus(nil)
				frame[barname].middle:SetPoint("TOPLEFT", frame[barname].size, "TOPRIGHT", 20, 0)
				frame[barname].middle.config = tags
				frame[barname].middle:SetScript("OnTextChanged" , function()
					this.config.center = this:GetText()
				end)
				frame[barname].middle:SetScript("OnEnterPressed", function()
					this:ClearFocus()
				end)

				frame[barname].MiddleDesc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				frame[barname].MiddleDesc:SetPoint("BOTTOM", frame[barname].middle, "TOP", 0, 0)
				frame[barname].MiddleDesc:SetText(L["Middle"])

				frame[barname].left = CreateFrame("Editbox", "LeftTag"..parent.id..barname, frame, "InputBoxTemplate")
				frame[barname].left:SetHeight(20)
				frame[barname].left:SetWidth(200)
				frame[barname].left:SetAutoFocus(nil)
				frame[barname].left:SetPoint("TOP", frame[barname].size, "BOTTOM", 0, -30)
				frame[barname].left.config = tags
				frame[barname].left:SetScript("OnTextChanged" , function()
					this.config.left = this:GetText()
				end)
				frame[barname].left:SetScript("OnEnterPressed", function()
					this:ClearFocus()
				end)

				frame[barname].LeftDesc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				frame[barname].LeftDesc:SetPoint("BOTTOM", frame[barname].left, "TOP", 0, 0)
				frame[barname].LeftDesc:SetText(L["LEFT"])

				frame[barname].right = CreateFrame("Editbox", "RightTag"..parent.id..barname, frame, "InputBoxTemplate")
				frame[barname].right:SetHeight(20)
				frame[barname].right:SetWidth(200)
				frame[barname].right:SetAutoFocus(nil)
				frame[barname].right:SetPoint("TOPLEFT", frame[barname].left, "TOPRIGHT", 20, 0)
				frame[barname].right.config = tags
				frame[barname].right:SetScript("OnTextChanged" , function()
					this.config.right = this:GetText()
				end)
				frame[barname].right:SetScript("OnEnterPressed", function()
					this:ClearFocus()
				end)

				frame[barname].RightDesc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				frame[barname].RightDesc:SetPoint("BOTTOM", frame[barname].right, "TOP", 0, 0)
				frame[barname].RightDesc:SetText(L["RIGHT"])

				anchor = frame[barname].left
			end
			count = count+1
		end
	end
	frame.load = function (frame, config)
		frame.config = config
		for barname,tags in pairs(config) do
			frame[barname].size:SetValue(tags.size)
			frame[barname].size.config = tags
			if WithTags[barname] then
				frame[barname].middle:SetText(tags.center or "")
				frame[barname].middle.config = tags
				frame[barname].left:SetText(tags.left or "")
				frame[barname].left.config = tags
				frame[barname].right:SetText(tags.right or "")
				frame[barname].right.config = tags
			end
		end
	end
	frame:SetHeight(80*count)
	return frame
end

local function CreateBarOrderWidget(parent, config)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(450)
	frame:SetHeight(200)
	frame.parent = parent
	frame.config = config
	frame.bars = {}
	frame:SetBackdrop(LunaUF.constants.backdrop)
	frame:SetBackdropColor(0,0,0)

	frame.numhBars = config.horizontal and getn(config.horizontal) or 0
	frame.numvBars = config.vertical and getn(config.vertical) or 0

	frame.upbutton = CreateFrame("Button", nil, frame)
	frame.upbutton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
	frame.upbutton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
	frame.upbutton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIcon-BlinkHilight", "ADD")
	frame.upbutton:SetHeight(20)
	frame.upbutton:SetWidth(20)
	frame.upbutton:SetPoint("BOTTOMLEFT", frame, "RIGHT")
	frame.upbutton:SetScript("OnClick", function ()
		local frame = this:GetParent()
		if not frame.selectedID then return end
		local config = frame.config
		if frame.selectedID == 1 or frame.selectedID > frame.numhBars then
			return
		end
		local temp = config.horizontal[frame.selectedID-1]
		config.horizontal[frame.selectedID-1] = config.horizontal[frame.selectedID]
		config.horizontal[frame.selectedID] = temp
		frame.selectedID = frame.selectedID - 1
		frame.load(frame, frame.config)
		local unit = frame:GetParent().id
		for _,v in pairs(LunaUF.Units.frameList) do
			if v.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(v)
			end
		end
	end)

	frame.downbutton = CreateFrame("Button", nil, frame)
	frame.downbutton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	frame.downbutton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	frame.downbutton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIcon-BlinkHilight", "ADD")
	frame.downbutton:SetHeight(20)
	frame.downbutton:SetWidth(20)
	frame.downbutton:SetPoint("TOPLEFT", frame, "RIGHT")
	frame.downbutton:SetScript("OnClick", function ()
		local frame = this:GetParent()
		if not frame.selectedID then return end
		local config = frame.config
		if frame.selectedID > frame.numhBars or frame.selectedID == frame.numhBars then
			return
		end
		local temp = config.horizontal[frame.selectedID+1]
		config.horizontal[frame.selectedID+1] = config.horizontal[frame.selectedID]
		config.horizontal[frame.selectedID] = temp
		frame.selectedID = frame.selectedID + 1
		frame.load(frame, frame.config)
		local unit = frame:GetParent().id
		for _,v in pairs(LunaUF.Units.frameList) do
			if v.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(v)
			end
		end
	end)

	frame.leftbutton = CreateFrame("Button", nil, frame)
	frame.leftbutton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	frame.leftbutton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	frame.leftbutton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIcon-BlinkHilight", "ADD")
	frame.leftbutton:SetHeight(20)
	frame.leftbutton:SetWidth(20)
	frame.leftbutton:SetPoint("BOTTOMRIGHT", frame, "TOP")
	frame.leftbutton:SetScript("OnClick", function ()
		local frame = this:GetParent()
		if not frame.selectedID then return end
		local config = frame.config
		if frame.selectedID <= frame.numhBars then
			return
		else
			if frame.selectedID == frame.numhBars+1 then
				table.remove(config.vertical,(frame.selectedID-frame.numhBars))
				frame.numvBars = frame.numvBars - 1
				table.insert(config.horizontal, frame.selectedBar)
				frame.numhBars = frame.numhBars + 1
			else
				local current = frame.selectedID-frame.numhBars
				local temp = config.vertical[current-1]
				config.vertical[current-1] = config.vertical[current]
				config.vertical[current] = temp
				frame.selectedID = frame.selectedID - 1
			end
		end
		frame.load(frame, frame.config)
		local unit = frame:GetParent().id
		for _,v in pairs(LunaUF.Units.frameList) do
			if v.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(v)
			end
		end
	end)

	frame.rightbutton = CreateFrame("Button", nil, frame)
	frame.rightbutton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	frame.rightbutton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	frame.rightbutton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIcon-BlinkHilight", "ADD")
	frame.rightbutton:SetHeight(20)
	frame.rightbutton:SetWidth(20)
	frame.rightbutton:SetPoint("BOTTOMLEFT", frame, "TOP")
	frame.rightbutton:SetScript("OnClick", function ()
		local frame = this:GetParent()
		if not frame.selectedID then return end
		local config = frame.config
		if frame.selectedID <= frame.numhBars then
			table.remove(config.horizontal,frame.selectedID)
			frame.numhBars = frame.numhBars - 1
			table.insert(config.vertical, 1, frame.selectedBar)
			frame.numvBars = frame.numvBars + 1
			frame.selectedID = frame.numhBars + 1
		else
			if frame.selectedID == (frame.numhBars+frame.numvBars) then
				return
			else
				local current = frame.selectedID-frame.numhBars
				local temp = config.vertical[current+1]
				config.vertical[current+1] = config.vertical[current]
				config.vertical[current] = temp
				frame.selectedID = frame.selectedID + 1
			end
		end
		frame.load(frame, frame.config)
		local unit = frame:GetParent().id
		for _,v in pairs(LunaUF.Units.frameList) do
			if v.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(v)
			end
		end
	end)

	for i=1, (frame.numhBars + frame.numvBars) do
		local bar = CreateFrame("Button", nil, frame)
		bar.texture = bar:CreateTexture(nil, "BACKGROUND")
		bar.texture:SetTexture(0,1,0)
		bar.texture:SetAllPoints(bar)
		bar.text = bar:CreateFontString(nil,"OVERLAY","GameFontHighlight")
		bar.text:SetTextColor(1, 1, 1)
		bar.text:SetPoint("CENTER", bar, "CENTER")
		bar.id = i
		bar:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
		bar:SetScript("OnClick", function ()
			local frame = this:GetParent()
			if frame.selectedID == this.id then
				frame.selectedID = nil
				frame.selectedBar = nil
			else
				frame.selectedID = this.id
				frame.selectedBar = this.barname
			end
			frame.load(frame, frame.config)
		end)
		table.insert(frame.bars, bar)
	end
	frame.load = function (frame, config)
		frame.config = config
		frame.numhBars = config.horizontal and getn(config.horizontal) or 0
		frame.numvBars = config.vertical and getn(config.vertical) or 0
		local heightV = frame:GetHeight()
		local heightH = (heightV-(frame.numhBars-1))/frame.numhBars
		local widthH = frame.numhBars > 0 and ((frame:GetWidth()-1)/ (frame.numvBars > 0 and 2 or 1)) or 0
		local widthV = frame.numhBars > 0 and (widthH/frame.numvBars) or (frame:GetWidth()/frame.numvBars)
		local numBar = 1
		for i=1, frame.numhBars do
			frame.bars[numBar]:ClearAllPoints()
			frame.bars[numBar]:SetHeight(heightH)
			frame.bars[numBar]:SetWidth(widthH)
			frame.bars[numBar]:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, (heightH+1)*-(i-1))
			frame.bars[numBar].text:SetText(L[config.horizontal[i]])
			frame.bars[numBar].barname = config.horizontal[i]
			if frame.selectedBar and config.horizontal[i] == frame.selectedBar then
				frame.bars[numBar].texture:SetTexture(1,0,0)
			else
				frame.bars[numBar].texture:SetTexture(0,1,0)
			end
			numBar = numBar + 1
		end
		for i=1, frame.numvBars do
			frame.bars[numBar]:ClearAllPoints()
			frame.bars[numBar]:SetHeight(heightV)
			frame.bars[numBar]:SetWidth(widthV)
			frame.bars[numBar]:SetPoint("TOPLEFT", frame, "TOPLEFT", widthH + (widthV+1)*(i-1)+1, 0)
			frame.bars[numBar].text:SetText(L[config.vertical[i]])
			frame.bars[numBar].barname = config.vertical[i]
			if frame.selectedBar and config.vertical[i] == frame.selectedBar then
				frame.bars[numBar].texture:SetTexture(1,0,0)
			else
				frame.bars[numBar].texture:SetTexture(0,0,1)
			end
			numBar = numBar + 1
		end
	end
	return frame
end

local function CreateTrackerFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(10)
	frame:SetHeight(500)
	return frame
end

local function StartMoving()
	this:StartMoving()
end

local function StopMovingOrSizing()
	this:StopMovingOrSizing()
end

local function OnPageSwitch()
	LunaOptionsFrame.ScrollFrames[shownFrame]:Hide()
	LunaOptionsFrame.ScrollFrames[this.id]:Show()
	shownFrame = this.id
end

function LunaUF:LoadOptions()
	for i,unit in pairs({[2]="player",[3]="pet",[4]="pettarget",[5]="target",[6]="targettarget",[7]="targettargettarget",[8]="party",[9]="partytarget",[10]="partypet",[11]="raid"}) do
		LunaOptionsFrame.pages[i].enable:SetChecked(LunaUF.db.profile.units[unit].enabled)
		LunaOptionsFrame.pages[i].heightslider:SetValue(LunaUF.db.profile.units[unit].size.y)
		LunaOptionsFrame.pages[i].widthslider:SetValue(LunaUF.db.profile.units[unit].size.x)
		LunaOptionsFrame.pages[i].scaleslider:SetValue(LunaUF.db.profile.units[unit].scale)
		if unit ~= "raid" then
			LunaOptionsFrame.pages[i].xInput:SetText(LunaUF.db.profile.units[unit].position.x)
			LunaOptionsFrame.pages[i].yInput:SetText(LunaUF.db.profile.units[unit].position.y)
		end
		LunaOptionsFrame.pages[i].indicators.load(LunaOptionsFrame.pages[i].indicators,LunaUF.db.profile.units[unit].indicators.icons)
		LunaOptionsFrame.pages[i].enableFader:SetChecked(LunaUF.db.profile.units[unit].fader.enabled)
		LunaOptionsFrame.pages[i].FaderCombatslider:SetValue(LunaUF.db.profile.units[unit].fader.combatAlpha)
		LunaOptionsFrame.pages[i].FaderNonCombatslider:SetValue(LunaUF.db.profile.units[unit].fader.inactiveAlpha)
		LunaOptionsFrame.pages[i].speedyFade:SetChecked(LunaUF.db.profile.units[unit].fader.speedyFade)
		LunaOptionsFrame.pages[i].enableCtext:SetChecked(LunaUF.db.profile.units[unit].combatText.enabled)
		LunaOptionsFrame.pages[i].ctextscaleslider:SetValue(LunaUF.db.profile.units[unit].combatText.size)
		LunaOptionsFrame.pages[i].ctextXslider:SetValue(LunaUF.db.profile.units[unit].combatText.xoffset)
		LunaOptionsFrame.pages[i].ctextYslider:SetValue(LunaUF.db.profile.units[unit].combatText.yoffset)
		LunaOptionsFrame.pages[i].enablePortrait:SetChecked(LunaUF.db.profile.units[unit].portrait.enabled)
		SetDropDownValue(LunaOptionsFrame.pages[i].portraitType,LunaUF.db.profile.units[unit].portrait.type)
		SetDropDownValue(LunaOptionsFrame.pages[i].portraitSide,LunaUF.db.profile.units[unit].portrait.side)
		LunaOptionsFrame.pages[i].portraitsizeslider:SetValue(LunaUF.db.profile.units[unit].portrait.size)
		LunaOptionsFrame.pages[i].enableHighlight:SetChecked(LunaUF.db.profile.units[unit].highlight.enabled)
		LunaOptionsFrame.pages[i].ontarget:SetChecked(LunaUF.db.profile.units[unit].highlight.ontarget)
		LunaOptionsFrame.pages[i].onmouse:SetChecked(LunaUF.db.profile.units[unit].highlight.onmouse)
		LunaOptionsFrame.pages[i].ondebuff:SetChecked(LunaUF.db.profile.units[unit].highlight.ondebuff)
		LunaOptionsFrame.pages[i].enableHealth:SetChecked(LunaUF.db.profile.units[unit].healthBar.enabled)
		LunaOptionsFrame.pages[i].healthsizeslider:SetValue(LunaUF.db.profile.units[unit].healthBar.size)
		SetDropDownValue(LunaOptionsFrame.pages[i].healthcolor,LunaUF.db.profile.units[unit].healthBar.colorType)
		SetDropDownValue(LunaOptionsFrame.pages[i].healthreact,LunaUF.db.profile.units[unit].healthBar.reactionType)
		LunaOptionsFrame.pages[i].invertHealth:SetChecked(LunaUF.db.profile.units[unit].healthBar.invert)
		LunaOptionsFrame.pages[i].vertHealth:SetChecked(LunaUF.db.profile.units[unit].healthBar.vertical)
		LunaOptionsFrame.pages[i].enablePower:SetChecked(LunaUF.db.profile.units[unit].powerBar.enabled)
		LunaOptionsFrame.pages[i].hidePower:SetChecked(LunaUF.db.profile.units[unit].powerBar.hide)
		LunaOptionsFrame.pages[i].powersizeslider:SetValue(LunaUF.db.profile.units[unit].powerBar.size)
		LunaOptionsFrame.pages[i].invertPower:SetChecked(LunaUF.db.profile.units[unit].powerBar.invert)
		LunaOptionsFrame.pages[i].vertPower:SetChecked(LunaUF.db.profile.units[unit].powerBar.vertical)
		LunaOptionsFrame.pages[i].enablecast:SetChecked(LunaUF.db.profile.units[unit].castBar.enabled)
		LunaOptionsFrame.pages[i].casthide:SetChecked(LunaUF.db.profile.units[unit].castBar.hide)
		LunaOptionsFrame.pages[i].casticon:SetChecked(LunaUF.db.profile.units[unit].castBar.icon)
		LunaOptionsFrame.pages[i].castvertical:SetChecked(LunaUF.db.profile.units[unit].castBar.vertical)
		LunaOptionsFrame.pages[i].castsizeslider:SetValue(LunaUF.db.profile.units[unit].castBar.size)
		LunaOptionsFrame.pages[i].enableheal:SetChecked(LunaUF.db.profile.units[unit].incheal.enabled)
		LunaOptionsFrame.pages[i].healsizeslider:SetValue(LunaUF.db.profile.units[unit].incheal.cap*100)
		LunaOptionsFrame.pages[i].enableauras:SetChecked(LunaUF.db.profile.units[unit].auras.enabled)
		LunaOptionsFrame.pages[i].enablebordercolor:SetChecked(LunaUF.db.profile.units[unit].auras.bordercolor)
		SetDropDownValue(LunaOptionsFrame.pages[i].auraposition,LunaUF.db.profile.units[unit].auras.position)
		LunaOptionsFrame.pages[i].aurasizeslider:SetValue(17-LunaUF.db.profile.units[unit].auras.AurasPerRow)
		if (unit == "player") then
			LunaOptionsFrame.pages[i].enableaurastimertext:SetChecked(LunaUF.db.profile.units[unit].auras.timertextenabled)
			LunaOptionsFrame.pages[i].auratimertextbigfontsizeslider:SetValue(LunaUF.db.profile.units[unit].auras.timertextbigsize)
			LunaOptionsFrame.pages[i].auratimertextsmallfontsizeslider:SetValue(LunaUF.db.profile.units[unit].auras.timertextsmallsize)
			LunaOptionsFrame.pages[i].enableaurastimerspin:SetChecked(LunaUF.db.profile.units[unit].auras.timerspinenabled)
		end
		LunaOptionsFrame.pages[i].enabletags:SetChecked(LunaUF.db.profile.units[unit].tags.enabled)
		LunaOptionsFrame.pages[i].tags.load(LunaOptionsFrame.pages[i].tags,LunaUF.db.profile.units[unit].tags.bartags)
		LunaOptionsFrame.pages[i].barorder.load(LunaOptionsFrame.pages[i].barorder,LunaUF.db.profile.units[unit].barorder)
	end

	local II = 1
	SetDropDownValue(LunaOptionsFrame.pages[II].FontSelect,LunaUF.db.profile.font)
	SetDropDownValue(LunaOptionsFrame.pages[II].TextureSelect,LunaUF.db.profile.texture)
	SetDropDownValue(LunaOptionsFrame.pages[II].AuraBorderSelect,LunaUF.db.profile.auraborderType)
	LunaOptionsFrame.pages[II].enableTTips:SetChecked(LunaUF.db.profile.tooltips)
	LunaOptionsFrame.pages[II].enableTTipscombat:SetChecked(LunaUF.db.profile.tooltipCombat)
	LunaOptionsFrame.pages[II].baralphaslider:SetValue(LunaUF.db.profile.bars.alpha)
	LunaOptionsFrame.pages[II].bgbaralphaslider:SetValue(LunaUF.db.profile.bars.backgroundAlpha)
	LunaOptionsFrame.pages[II].bgcolor.load(LunaOptionsFrame.pages[II].bgcolor,LunaUF.db.profile.bgcolor)
	LunaOptionsFrame.pages[II].bgalphaslider:SetValue(LunaUF.db.profile.bgalpha)
	LunaOptionsFrame.pages[II].castbar:SetChecked(LunaUF.db.profile.blizzard.castbar)
	LunaOptionsFrame.pages[II].buffs:SetChecked(LunaUF.db.profile.blizzard.buffs)
	LunaOptionsFrame.pages[II].weaponbuffs:SetChecked(LunaUF.db.profile.blizzard.weaponbuffs)
	LunaOptionsFrame.pages[II].player:SetChecked(LunaUF.db.profile.blizzard.player)
	LunaOptionsFrame.pages[II].pet:SetChecked(LunaUF.db.profile.blizzard.pet)
	LunaOptionsFrame.pages[II].party:SetChecked(LunaUF.db.profile.blizzard.party)
	LunaOptionsFrame.pages[II].target:SetChecked(LunaUF.db.profile.blizzard.target)
	LunaOptionsFrame.pages[II].mouseovercheck:SetChecked(LunaUF.db.profile.mouseover)
	LunaOptionsFrame.pages[II].rangepolling:SetValue(LunaUF.db.profile.RangePolRate or 1.5)
	LunaOptionsFrame.pages[II].rangecl:SetChecked(LunaUF.db.profile.RangeCLparsing)
	local II = 2
	LunaOptionsFrame.pages[II].ticker:SetChecked(LunaUF.db.profile.units.player.powerBar.ticker)
	LunaOptionsFrame.pages[II].enabletotem:SetChecked(LunaUF.db.profile.units.player.totemBar.enabled)
	LunaOptionsFrame.pages[II].totemhide:SetChecked(LunaUF.db.profile.units.player.totemBar.hide)
	LunaOptionsFrame.pages[II].totemsizeslider:SetValue(LunaUF.db.profile.units.player.totemBar.size)
	LunaOptionsFrame.pages[II].enabledruid:SetChecked(LunaUF.db.profile.units.player.druidBar.enabled)
	LunaOptionsFrame.pages[II].druidsizeslider:SetValue(LunaUF.db.profile.units.player.druidBar.size)
	LunaOptionsFrame.pages[II].enablexp:SetChecked(LunaUF.db.profile.units.player.xpBar.enabled)
	LunaOptionsFrame.pages[II].xpsizeslider:SetValue(LunaUF.db.profile.units.player.xpBar.size)
	LunaOptionsFrame.pages[II].enablereck:SetChecked(LunaUF.db.profile.units.player.reckStacks.enabled)
	SetDropDownValue(LunaOptionsFrame.pages[II].reckgrowth,LunaUF.db.profile.units.player.reckStacks.growth)
	LunaOptionsFrame.pages[II].hidereck:SetChecked(LunaUF.db.profile.units.player.reckStacks.hide)
	LunaOptionsFrame.pages[II].recksizeslider:SetValue(LunaUF.db.profile.units.player.reckStacks.size)
	local II = 3
	LunaOptionsFrame.pages[II].enablexp:SetChecked(LunaUF.db.profile.units.pet.xpBar.enabled)
	LunaOptionsFrame.pages[II].xpsizeslider:SetValue(LunaUF.db.profile.units.pet.xpBar.size)
	local II = 5
	LunaOptionsFrame.pages[II].enablecombo:SetChecked(LunaUF.db.profile.units.target.comboPoints.enabled)
	SetDropDownValue(LunaOptionsFrame.pages[II].combogrowth,LunaUF.db.profile.units.target.comboPoints.growth)
	LunaOptionsFrame.pages[II].hidecombo:SetChecked(LunaUF.db.profile.units.target.comboPoints.hide)
	LunaOptionsFrame.pages[II].combosizeslider:SetValue(LunaUF.db.profile.units.target.comboPoints.size)
	local II = 8
	LunaOptionsFrame.pages[II].enablerange:SetChecked(LunaUF.db.profile.units.party.range.enabled)
	LunaOptionsFrame.pages[II].partyrangealpha:SetValue(LunaUF.db.profile.units.party.range.alpha)
	LunaOptionsFrame.pages[II].inraid:SetChecked(LunaUF.db.profile.units.party.inraid)
	LunaOptionsFrame.pages[II].playerparty:SetChecked(LunaUF.db.profile.units.party.player)
	LunaOptionsFrame.pages[II].partypadding:SetValue(LunaUF.db.profile.units.party.padding)
	SetDropDownValue(LunaOptionsFrame.pages[II].sortby,LunaUF.db.profile.units.party.sortby)
	SetDropDownValue(LunaOptionsFrame.pages[II].orderby,LunaUF.db.profile.units.party.order)
	SetDropDownValue(LunaOptionsFrame.pages[II].growth,LunaUF.db.profile.units.party.growth)
	local II = 11
	SetDropDownValue(LunaOptionsFrame.pages[II].GrpSelect, "1")
	LunaOptionsFrame.pages[II].xInput:SetText(LunaUF.db.profile.units["raid"][1].position.x)
	LunaOptionsFrame.pages[II].yInput:SetText(LunaUF.db.profile.units["raid"][1].position.y)
	LunaOptionsFrame.pages[II].enablerange:SetChecked(LunaUF.db.profile.units.raid.range.enabled)
	LunaOptionsFrame.pages[II].raidrangealpha:SetValue(LunaUF.db.profile.units.raid.range.alpha)
	LunaOptionsFrame.pages[II].enabletracker:SetChecked(LunaUF.db.profile.units.raid.squares.enabled)
	LunaOptionsFrame.pages[II].outersizeslider:SetValue(LunaUF.db.profile.units.raid.squares.outersize)
	LunaOptionsFrame.pages[II].enabledebuffs:SetChecked(LunaUF.db.profile.units.raid.squares.enabledebuffs)
	LunaOptionsFrame.pages[II].dispdebuffs:SetChecked(LunaUF.db.profile.units.raid.squares.dispellabledebuffs)
	LunaOptionsFrame.pages[II].owndebuffs:SetChecked(LunaUF.db.profile.units.raid.squares.owndispdebuffs)
	LunaOptionsFrame.pages[II].aggro:SetChecked(LunaUF.db.profile.units.raid.squares.aggro)
	LunaOptionsFrame.pages[II].aggrocolor.load(LunaOptionsFrame.pages[II].aggrocolor,LunaUF.db.profile.units.raid.squares.aggrocolor)
	LunaOptionsFrame.pages[II].hottracker:SetChecked(LunaUF.db.profile.units.raid.squares.hottracker)
	LunaOptionsFrame.pages[II].innersizeslider:SetValue(LunaUF.db.profile.units.raid.squares.innersize)
	LunaOptionsFrame.pages[II].colors:SetChecked(LunaUF.db.profile.units.raid.squares.colors)
	LunaOptionsFrame.pages[II].buffinvert:SetChecked(LunaUF.db.profile.units.raid.squares.invertbuffs)
	LunaOptionsFrame.pages[II].firstbuff:SetText(LunaUF.db.profile.units.raid.squares.buffs.names[1])
	LunaOptionsFrame.pages[II].firstbuffcolor.load(LunaOptionsFrame.pages[II].firstbuffcolor,LunaUF.db.profile.units.raid.squares.buffs.colors[1])
	LunaOptionsFrame.pages[II].secondbuff:SetText(LunaUF.db.profile.units.raid.squares.buffs.names[2])
	LunaOptionsFrame.pages[II].secondbuffcolor.load(LunaOptionsFrame.pages[II].secondbuffcolor,LunaUF.db.profile.units.raid.squares.buffs.colors[2])
	LunaOptionsFrame.pages[II].thirdbuff:SetText(LunaUF.db.profile.units.raid.squares.buffs.names[3])
	LunaOptionsFrame.pages[II].thirdbuffcolor.load(LunaOptionsFrame.pages[II].thirdbuffcolor,LunaUF.db.profile.units.raid.squares.buffs.colors[3])
	LunaOptionsFrame.pages[II].firstdebuff:SetText(LunaUF.db.profile.units.raid.squares.debuffs.names[1])
	LunaOptionsFrame.pages[II].firstdebuffcolor.load(LunaOptionsFrame.pages[II].firstdebuffcolor,LunaUF.db.profile.units.raid.squares.debuffs.colors[1])
	LunaOptionsFrame.pages[II].seconddebuff:SetText(LunaUF.db.profile.units.raid.squares.debuffs.names[2])
	LunaOptionsFrame.pages[II].seconddebuffcolor.load(LunaOptionsFrame.pages[II].seconddebuffcolor,LunaUF.db.profile.units.raid.squares.debuffs.colors[2])
	LunaOptionsFrame.pages[II].thirddebuff:SetText(LunaUF.db.profile.units.raid.squares.debuffs.names[3])
	LunaOptionsFrame.pages[II].thirddebuffcolor.load(LunaOptionsFrame.pages[II].thirddebuffcolor,LunaUF.db.profile.units.raid.squares.debuffs.colors[3])
	LunaOptionsFrame.pages[II].showparty:SetChecked(LunaUF.db.profile.units.raid.showparty)
	LunaOptionsFrame.pages[II].showalways:SetChecked(LunaUF.db.profile.units.raid.showalways)
	LunaOptionsFrame.pages[II].raidpadding:SetValue(LunaUF.db.profile.units.raid.padding)
	LunaOptionsFrame.pages[II].interlock:SetChecked(LunaUF.db.profile.units.raid.interlock)
	SetDropDownValue(LunaOptionsFrame.pages[II].interlockgrowth,LunaUF.db.profile.units.raid.interlockgrowth)
	LunaOptionsFrame.pages[II].petgrp:SetChecked(LunaUF.db.profile.units.raid.petgrp)
	LunaOptionsFrame.pages[II].titles:SetChecked(LunaUF.db.profile.units.raid.titles)
	SetDropDownValue(LunaOptionsFrame.pages[II].sortby,LunaUF.db.profile.units.raid.sortby)
	SetDropDownValue(LunaOptionsFrame.pages[II].orderby,LunaUF.db.profile.units.raid.order)
	SetDropDownValue(LunaOptionsFrame.pages[II].growth,LunaUF.db.profile.units.raid.growth)
	SetDropDownValue(LunaOptionsFrame.pages[II].mode,LunaUF.db.profile.units.raid.mode)
	ToggleDropDownMenu(1,nil,LunaOptionsFrame.pages[II].mode)
	local II = 12
	LunaOptionsFrame.pages[II].mouseDownClicks:SetChecked(LunaUF.db.profile.clickcasting.mouseDownClicks)
	LunaOptionsFrame.pages[II].Load()
	local II = 13
	for i,class in ipairs({"PRIEST","PALADIN","SHAMAN","WARRIOR","ROGUE","MAGE","WARLOCK","DRUID","HUNTER"}) do
		LunaOptionsFrame.pages[II][class].load(LunaOptionsFrame.pages[II][class],LunaUF.db.profile.classColors[class])
	end
	for name,_ in pairs(LunaUF.db.profile.healthColors) do
		LunaOptionsFrame.pages[II][name].load(LunaOptionsFrame.pages[II][name],LunaUF.db.profile.healthColors[name])
	end
	for name,_ in pairs(LunaUF.db.profile.powerColors) do
		LunaOptionsFrame.pages[II][name].load(LunaOptionsFrame.pages[II][name],LunaUF.db.profile.powerColors[name])
	end
	for name,_ in pairs(LunaUF.db.profile.castColors) do
		LunaOptionsFrame.pages[II][name].load(LunaOptionsFrame.pages[II][name],LunaUF.db.profile.castColors[name])
	end
	for name,_ in pairs(LunaUF.db.profile.xpColors) do
		LunaOptionsFrame.pages[II][name].load(LunaOptionsFrame.pages[II][name],LunaUF.db.profile.xpColors[name])
	end
end

function LunaUF:CreateOptionsButton(id, name, text, anchorFrame, anchorLoc, x, y)
	local button = CreateFrame("Button", name, LunaOptionsFrame, "UIPanelButtonTemplate")
	button:SetPoint("TOPLEFT", anchorFrame, anchorLoc, x, y)
	button:SetHeight(20)
	button:SetWidth(140)
	button:SetText(text)
	button:SetScript("OnClick", OnPageSwitch)
	button.id = id
	return button
end

function LunaUF:CreateOptionsMenu()
	LunaOptionsFrame = CreateFrame("Frame", "LunaOptionsMenu")
	LunaOptionsFrame:SetHeight(400)
	LunaOptionsFrame:SetWidth(700)
	LunaOptionsFrame:SetBackdrop(LunaUF.constants.backdrop)
	LunaOptionsFrame:SetBackdropColor(0.18,0.27,0.5)
	LunaOptionsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	LunaOptionsFrame:SetFrameStrata("DIALOG")
	LunaOptionsFrame:EnableMouse(1)
	LunaOptionsFrame:SetMovable(1)
	LunaOptionsFrame:RegisterForDrag("LeftButton")
	LunaOptionsFrame:SetScript("OnDragStart", StartMoving)
	LunaOptionsFrame:SetScript("OnDragStop", StopMovingOrSizing)
	LunaOptionsFrame:Hide()

	LunaOptionsFrame.CloseButton = CreateFrame("Button", "LunaOptionsCloseButton", LunaOptionsFrame,"UIPanelCloseButton")
	LunaOptionsFrame.CloseButton:SetPoint("TOPRIGHT", LunaOptionsFrame, "TOPRIGHT", 0, 0)

	LunaOptionsFrame.icon = LunaOptionsFrame:CreateTexture(nil, "ARTWORK", LunaOptionsFrame)
	LunaOptionsFrame.icon:SetTexture(LunaUF.constants.icon)
	LunaOptionsFrame.icon:SetHeight(64)
	LunaOptionsFrame.icon:SetWidth(64)
	LunaOptionsFrame.icon:SetPoint("TOPLEFT", LunaOptionsFrame, "TOPLEFT", 0, 0)

	LunaOptionsFrame.name = LunaOptionsFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
	LunaOptionsFrame.name:SetPoint("TOP", LunaOptionsFrame, "TOP", 0, -10)
	LunaOptionsFrame.name:SetShadowColor(0, 0, 0)
	LunaOptionsFrame.name:SetShadowOffset(0.8, -0.8)
	LunaOptionsFrame.name:SetTextColor(1,1,1)
	LunaOptionsFrame.name:SetText("LUNA UNIT FRAMES")

	LunaOptionsFrame.version = LunaOptionsFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	LunaOptionsFrame.version:SetPoint("BOTTOMLEFT", LunaOptionsFrame.name, "BOTTOMRIGHT", 10, 5)
	LunaOptionsFrame.version:SetShadowColor(0, 0, 0)
	LunaOptionsFrame.version:SetShadowOffset(0.8, -0.8)

	LunaOptionsFrame.version:SetTextColor(1,1,1)
	LunaOptionsFrame.version:SetText("V."..LunaUF.Version.." Beta")

	LunaOptionsFrame.help = CreateFrame("Button", nil, LunaOptionsFrame)
	LunaOptionsFrame.help:SetHeight(14)
	LunaOptionsFrame.help:SetWidth(14)
	LunaOptionsFrame.help:SetPoint("RIGHT", LunaOptionsFrame.CloseButton, "LEFT", -5, 0)
	LunaOptionsFrame.help:SetScript("OnClick", function() if LunaOptionsFrame.Helpframe:IsShown() then LunaOptionsFrame.Helpframe:Hide() else LunaOptionsFrame.Helpframe:Show() end end)

	LunaOptionsFrame.help.text = LunaOptionsFrame.help:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	LunaOptionsFrame.help.text:SetPoint("CENTER", LunaOptionsFrame.help, "CENTER")
	LunaOptionsFrame.help.text:SetTextColor(1,1,1)
	LunaOptionsFrame.help.text:SetText("[?]")
	LunaOptionsFrame.help.text:SetJustifyH("CENTER")
	LunaOptionsFrame.help.text:SetJustifyV("MIDDLE")

	LunaOptionsFrame.pages = {}
	LunaOptionsFrame.ScrollFrames = {}
	LunaOptionsFrame.Sliders = {}

	for i,name in ipairs(OptionsPageNames) do
		LunaOptionsFrame.ScrollFrames[i] = CreateFrame("ScrollFrame", nil, LunaOptionsFrame)
		LunaOptionsFrame.ScrollFrames[i]:SetHeight(350)
		LunaOptionsFrame.ScrollFrames[i]:SetWidth(500)
		LunaOptionsFrame.ScrollFrames[i].id = i

		LunaOptionsFrame.ScrollFrames[i]:SetPoint("BOTTOMRIGHT", LunaOptionsFrame, "BOTTOMRIGHT", -30, 10)
		LunaOptionsFrame.ScrollFrames[i]:Hide()
		LunaOptionsFrame.ScrollFrames[i]:EnableMouseWheel(true)
		LunaOptionsFrame.ScrollFrames[i]:SetBackdrop(LunaUF.constants.backdrop)
		LunaOptionsFrame.ScrollFrames[i]:SetBackdropColor(0,0,0,1)
		LunaOptionsFrame.ScrollFrames[i]:SetScript("OnMouseWheel", function()
																		local maxScroll = this:GetVerticalScrollRange()
																		local Scroll = this:GetVerticalScroll()
																		local toScroll = (Scroll - (20*arg1))
																		if toScroll < 0 then
																			this:SetVerticalScroll(0)
																		elseif toScroll > maxScroll then
																			this:SetVerticalScroll(maxScroll)
																		else
																			this:SetVerticalScroll(toScroll)
																		end
																		local script = LunaOptionsFrame.Sliders[this.id]:GetScript("OnValueChanged")
																		LunaOptionsFrame.Sliders[this.id]:SetScript("OnValueChanged", nil)
																		LunaOptionsFrame.Sliders[this.id]:SetValue(toScroll/maxScroll)
																		LunaOptionsFrame.Sliders[this.id]:SetScript("OnValueChanged", script)
																	end)

		LunaOptionsFrame.Sliders[i] = CreateFrame("Slider", nil, LunaOptionsFrame.ScrollFrames[i])
		LunaOptionsFrame.Sliders[i]:SetOrientation("VERTICAL")
		LunaOptionsFrame.Sliders[i]:SetPoint("TOPLEFT", LunaOptionsFrame.ScrollFrames[i], "TOPRIGHT", 5, 0)
		LunaOptionsFrame.Sliders[i]:SetBackdrop(LunaUF.constants.backdrop)
		LunaOptionsFrame.Sliders[i]:SetBackdropColor(0,0,0,0.5)
		LunaOptionsFrame.Sliders[i].thumbtexture = LunaOptionsFrame.Sliders[i]:CreateTexture()
		LunaOptionsFrame.Sliders[i].thumbtexture:SetTexture(0.18,0.27,0.5,1)
		LunaOptionsFrame.Sliders[i]:SetThumbTexture(LunaOptionsFrame.Sliders[i].thumbtexture)
		LunaOptionsFrame.Sliders[i]:SetMinMaxValues(0,1)
		LunaOptionsFrame.Sliders[i]:SetHeight(348)
		LunaOptionsFrame.Sliders[i]:SetWidth(15)
		LunaOptionsFrame.Sliders[i]:SetValue(0)
		LunaOptionsFrame.Sliders[i].ScrollFrame = LunaOptionsFrame.ScrollFrames[i]
		LunaOptionsFrame.Sliders[i]:SetScript("OnValueChanged", function() this.ScrollFrame:SetVerticalScroll(this.ScrollFrame:GetVerticalScrollRange()*this:GetValue()) end  )

		LunaOptionsFrame.pages[i] = CreateFrame("Frame", name.." Page", LunaOptionsFrame.ScrollFrames[i])
		LunaOptionsFrame.pages[i]:SetHeight(1)
		LunaOptionsFrame.pages[i]:SetWidth(500)

		LunaOptionsFrame.pages[i].name = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].name:SetPoint("TOP", LunaOptionsFrame.pages[i], "TOP", 0, -10)
		LunaOptionsFrame.pages[i].name:SetHeight(30)
		LunaOptionsFrame.pages[i].name:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].name:SetTextColor(1,1,1)
		LunaOptionsFrame.pages[i].name:SetText(name)

		LunaOptionsFrame.ScrollFrames[i]:SetScrollChild(LunaOptionsFrame.pages[i])

	end
	LunaOptionsFrame.ScrollFrames[1]:Show()

	LunaOptionsFrame.Button0 = LunaUF:CreateOptionsButton(1, "LunaGeneralButton",			L["General"], LunaOptionsFrame, "TOPLEFT", 20, -60)
	LunaOptionsFrame.Button1 = LunaUF:CreateOptionsButton(2, "LunaPlayerButton",			L["Player"], LunaOptionsFrame.Button0, "BOTTOMLEFT", 0, -2)
	LunaOptionsFrame.Button2 = LunaUF:CreateOptionsButton(3, "LunaPetButton",				L["Pet"], LunaOptionsFrame.Button1, "BOTTOMLEFT", 0, -2)
	LunaOptionsFrame.Button3 = LunaUF:CreateOptionsButton(4, "LunaPetTargetButton",			L["Pet Target"], LunaOptionsFrame.Button2, "BOTTOMLEFT", 0, -2)
	LunaOptionsFrame.Button4 = LunaUF:CreateOptionsButton(5, "LunaTargetButton",			L["Target"], LunaOptionsFrame.Button3, "BOTTOMLEFT", 0, -2)
	LunaOptionsFrame.Button5 = LunaUF:CreateOptionsButton(6, "LunaToTButton",				L["ToT"], LunaOptionsFrame.Button4, "BOTTOMLEFT", 0, -2)
	LunaOptionsFrame.Button6 = LunaUF:CreateOptionsButton(7, "LunaToToTButton",				L["ToToT"], LunaOptionsFrame.Button5, "BOTTOMLEFT", 0, -2)
	LunaOptionsFrame.Button7 = LunaUF:CreateOptionsButton(8, "LunaPartyButton",				L["Party"], LunaOptionsFrame.Button6, "BOTTOMLEFT", 0, -2)
	LunaOptionsFrame.Button8 = LunaUF:CreateOptionsButton(9, "LunaPartyTargetButton",		L["Party Target"], LunaOptionsFrame.Button7, "BOTTOMLEFT", 0, -2)
	LunaOptionsFrame.Button9 = LunaUF:CreateOptionsButton(10, "LunaPartyPetButton",			L["Party Pet"], LunaOptionsFrame.Button8, "BOTTOMLEFT", 0, -2)
	LunaOptionsFrame.Button10 = LunaUF:CreateOptionsButton(11, "LunaRaidButton",			L["Raid"], LunaOptionsFrame.Button9, "BOTTOMLEFT", 0, -2)
	LunaOptionsFrame.Button11 = LunaUF:CreateOptionsButton(12, "LunaClickcastingButton",	L["Clickcasting"], LunaOptionsFrame.Button10, "BOTTOMLEFT", 0, -2)
	LunaOptionsFrame.Button12 = LunaUF:CreateOptionsButton(13, "LunaColorsButton",			L["Colors"], LunaOptionsFrame.Button11, "BOTTOMLEFT", 0, -2)

	LunaOptionsFrame.Button13 = CreateFrame("Button", "LunaConfigModeButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button13:SetPoint("TOPLEFT", LunaOptionsFrame.Button12, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.Button13:SetHeight(20)
	LunaOptionsFrame.Button13:SetWidth(140)
	LunaOptionsFrame.Button13:SetText(L["Config Mode"])
	LunaOptionsFrame.Button13:SetScript("OnClick", function ()
		if LunaUF.db.profile.locked then
			LunaUF:SystemMessage(L["Entering config mode."])
			LunaUF.db.profile.locked = false
		else
			LunaUF:SystemMessage(L["Exiting config mode."])
			LunaUF.db.profile.locked = true
		end
		LunaUF:LoadUnits()
	end	)
	LunaOptionsFrame.Button13.id = 15

	LunaOptionsFrame.Button14 = CreateFrame("Button", "LunaProfilesButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button14:SetPoint("TOPLEFT", LunaOptionsFrame.Button13, "BOTTOMLEFT", 0, -2)
	LunaOptionsFrame.Button14:SetHeight(20)
	LunaOptionsFrame.Button14:SetWidth(140)
	LunaOptionsFrame.Button14:SetText(L["Profiles"])
	LunaOptionsFrame.Button14:SetScript("OnClick", OnPageSwitch)
	LunaOptionsFrame.Button14.id = 14

	-------- General

	local II = 1
	LunaOptionsFrame.pages[II].fontHeader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].fontHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -40)
	LunaOptionsFrame.pages[II].fontHeader:SetHeight(24)
	LunaOptionsFrame.pages[II].fontHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].fontHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].fontHeader:SetText(L["Font"])

	LunaOptionsFrame.pages[II].FontSelect = CreateFrame("Button", "FontSelector", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].FontSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 0 , -70)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].FontSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].FontSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].FontSelect, function()
		local info={}
		for k,v in ipairs(L["FONT_LIST"]) do
			info.text=v
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[II].FontSelect, this:GetID())
				LunaUF.db.profile.font = UIDropDownMenu_GetText(LunaOptionsFrame.pages[II].FontSelect)
				for _,frame in pairs(LunaUF.Units.frameList) do
					LunaUF.Units.FullUpdate(frame)
				end
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].textureHeader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].textureHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -100)
	LunaOptionsFrame.pages[II].textureHeader:SetHeight(24)
	LunaOptionsFrame.pages[II].textureHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].textureHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].textureHeader:SetText(L["Textures"])

	LunaOptionsFrame.pages[II].textureDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].textureDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -130)
	LunaOptionsFrame.pages[II].textureDesc:SetText(L["Bar Texture"])

	LunaOptionsFrame.pages[II].TextureSelect = CreateFrame("Button", "TextureSelector", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].TextureSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 0 , -145)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].TextureSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].TextureSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].TextureSelect, function()
		local info={}
		for k,v in ipairs({"Aluminium","Armory","BantoBar","Bars","Button","Charcoal","Cilo","Dabs","Diagonal","Fifths","Fourths","Glamour","Glamour2","Glamour3","Glamour4","Glamour5","Glamour6","Glamour7","Glaze","Gloss","Healbot","Luna","Lyfe","Otravi","Perl2","Ruben","Skewed","Smooth","Striped","Wisps"}) do
			info.text=v
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[II].TextureSelect, this:GetID())
				LunaUF.db.profile.texture = UIDropDownMenu_GetText(LunaOptionsFrame.pages[II].TextureSelect)
				for _,frame in pairs(LunaUF.Units.frameList) do
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].AuraDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].AuraDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 150, -130)
	LunaOptionsFrame.pages[II].AuraDesc:SetText(L["Aura Border"])

	LunaOptionsFrame.pages[II].AuraBorderSelect = CreateFrame("Button", "AuraBorderSelector", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].AuraBorderSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 130 , -145)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].AuraBorderSelect)
	UIDropDownMenu_JustifyText("RIGHT", LunaOptionsFrame.pages[II].AuraBorderSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].AuraBorderSelect, function()
		local info={}
		for k,v in ipairs({L["none"],"black","dark","light","blizzard"}) do
			info.text=v
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[II].AuraBorderSelect, this:GetID())
				LunaUF.db.profile.auraborderType = UIDropDownMenu_GetText(LunaOptionsFrame.pages[II].AuraBorderSelect)
				for _,frame in pairs(LunaUF.Units.frameList) do
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].Tooltips = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].Tooltips:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -180)
	LunaOptionsFrame.pages[II].Tooltips:SetHeight(24)
	LunaOptionsFrame.pages[II].Tooltips:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].Tooltips:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].Tooltips:SetText(L["Tooltips"])

	LunaOptionsFrame.pages[II].enableTTips = CreateFrame("CheckButton", "EnableTTips", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].enableTTips:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -200)
	LunaOptionsFrame.pages[II].enableTTips:SetHeight(30)
	LunaOptionsFrame.pages[II].enableTTips:SetWidth(30)
	LunaOptionsFrame.pages[II].enableTTips:SetScript("OnClick", function()
		LunaUF.db.profile.tooltips = not LunaUF.db.profile.tooltips
	end)
	getglobal("EnableTTipsText"):SetText(L["Enable Tooltips"])

	LunaOptionsFrame.pages[II].enableTTipscombat = CreateFrame("CheckButton", "EnableTTipsCombat", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].enableTTipscombat:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 200, -200)
	LunaOptionsFrame.pages[II].enableTTipscombat:SetHeight(30)
	LunaOptionsFrame.pages[II].enableTTipscombat:SetWidth(30)
	LunaOptionsFrame.pages[II].enableTTipscombat:SetScript("OnClick", function()
		LunaUF.db.profile.tooltipCombat = not LunaUF.db.profile.tooltipCombat
	end)
	getglobal("EnableTTipsCombatText"):SetText(L["Tooltips hidden in combat"])

	LunaOptionsFrame.pages[II].BarTrans = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].BarTrans:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -230)
	LunaOptionsFrame.pages[II].BarTrans:SetHeight(24)
	LunaOptionsFrame.pages[II].BarTrans:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].BarTrans:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].BarTrans:SetText(L["Bar transparency"])

	LunaOptionsFrame.pages[II].baralphaslider = CreateFrame("Slider", "BarAlphaSlider", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].baralphaslider:SetMinMaxValues(0.01,1)
	LunaOptionsFrame.pages[II].baralphaslider:SetValueStep(0.01)
	LunaOptionsFrame.pages[II].baralphaslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.bars.alpha = math.floor((this:GetValue()+0.005)*100)/100
		getglobal("BarAlphaSliderText"):SetText(L["Alpha"]..": "..LunaUF.db.profile.bars.alpha)
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame:IsVisible() then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[II].baralphaslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "BOTTOMLEFT", 20, -270)
	LunaOptionsFrame.pages[II].baralphaslider:SetWidth(220)

	LunaOptionsFrame.pages[II].bgbaralphaslider = CreateFrame("Slider", "BgBarAlphaSlider", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].bgbaralphaslider:SetMinMaxValues(0.01,1)
	LunaOptionsFrame.pages[II].bgbaralphaslider:SetValueStep(0.01)
	LunaOptionsFrame.pages[II].bgbaralphaslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.bars.backgroundAlpha = math.floor((this:GetValue()+0.005)*100)/100
		getglobal("BgBarAlphaSliderText"):SetText(L["Background alpha"]..": "..LunaUF.db.profile.bars.backgroundAlpha)
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame:IsVisible() then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[II].bgbaralphaslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "BOTTOMLEFT", 260, -270)
	LunaOptionsFrame.pages[II].bgbaralphaslider:SetWidth(220)

	LunaOptionsFrame.pages[II].framebgheader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].framebgheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -310)
	LunaOptionsFrame.pages[II].framebgheader:SetHeight(24)
	LunaOptionsFrame.pages[II].framebgheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].framebgheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].framebgheader:SetText(L["Frame background"])

	LunaOptionsFrame.pages[II].bgcolor = CreateColorSelect(LunaOptionsFrame.pages[II], LunaUF.db.profile.bgcolor, "BGColor")
	LunaOptionsFrame.pages[II].bgcolor:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].framebgheader, "TOPLEFT", 0, -40)
	LunaOptionsFrame.pages[II].bgcolor:SetHeight(19)
	LunaOptionsFrame.pages[II].bgcolor:SetWidth(19)
	LunaOptionsFrame.pages[II].bgcolor.text:SetText(L["Color"])

	LunaOptionsFrame.pages[II].bgalphaslider = CreateFrame("Slider", "BgAlphaSlider", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].bgalphaslider:SetMinMaxValues(0.01,1)
	LunaOptionsFrame.pages[II].bgalphaslider:SetValueStep(0.01)
	LunaOptionsFrame.pages[II].bgalphaslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.bgalpha = math.floor((this:GetValue()+0.005)*100)/100
		getglobal("BgAlphaSliderText"):SetText(L["Alpha"]..": "..LunaUF.db.profile.bgalpha)
		for _,frame in pairs(LunaUF.Units.frameList) do
			frame:SetBackdropColor(LunaUF.db.profile.bgcolor.r,LunaUF.db.profile.bgcolor.g,LunaUF.db.profile.bgcolor.b,LunaUF.db.profile.bgalpha)
		end
	end)
	LunaOptionsFrame.pages[II].bgalphaslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 200, -350)
	LunaOptionsFrame.pages[II].bgalphaslider:SetWidth(220)

	LunaOptionsFrame.pages[II].blizzheader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].blizzheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -390)
	LunaOptionsFrame.pages[II].blizzheader:SetHeight(24)
	LunaOptionsFrame.pages[II].blizzheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].blizzheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].blizzheader:SetText(L["Blizzard frames"])

	LunaOptionsFrame.pages[II].castbar = CreateFrame("CheckButton", "BlizzCastbar", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].castbar:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -420)
	LunaOptionsFrame.pages[II].castbar:SetHeight(30)
	LunaOptionsFrame.pages[II].castbar:SetWidth(30)
	LunaOptionsFrame.pages[II].castbar:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.castbar = not LunaUF.db.profile.blizzard.castbar
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzCastbarText"):SetText(L["Cast bar"])

	LunaOptionsFrame.pages[II].buffs = CreateFrame("CheckButton", "BlizzBuffs", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].buffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 100, -420)
	LunaOptionsFrame.pages[II].buffs:SetHeight(30)
	LunaOptionsFrame.pages[II].buffs:SetWidth(30)
	LunaOptionsFrame.pages[II].buffs:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.buffs = not LunaUF.db.profile.blizzard.buffs
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzBuffsText"):SetText(L["Buffs"])

	LunaOptionsFrame.pages[II].weaponbuffs = CreateFrame("CheckButton", "BlizzWeaponbuffs", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].weaponbuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 180, -420)
	LunaOptionsFrame.pages[II].weaponbuffs:SetHeight(30)
	LunaOptionsFrame.pages[II].weaponbuffs:SetWidth(30)
	LunaOptionsFrame.pages[II].weaponbuffs:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.weaponbuffs = not LunaUF.db.profile.blizzard.weaponbuffs
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzWeaponbuffsText"):SetText(L["Weaponbuffs"])

	LunaOptionsFrame.pages[II].player = CreateFrame("CheckButton", "BlizzPlayer", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].player:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -460)
	LunaOptionsFrame.pages[II].player:SetHeight(30)
	LunaOptionsFrame.pages[II].player:SetWidth(30)
	LunaOptionsFrame.pages[II].player:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.player = not LunaUF.db.profile.blizzard.player
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzPlayerText"):SetText(L["Player"])

	LunaOptionsFrame.pages[II].pet = CreateFrame("CheckButton", "BlizzPet", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].pet:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 100, -460)
	LunaOptionsFrame.pages[II].pet:SetHeight(30)
	LunaOptionsFrame.pages[II].pet:SetWidth(30)
	LunaOptionsFrame.pages[II].pet:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.pet = not LunaUF.db.profile.blizzard.pet
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzPetText"):SetText(L["Pet"])

	LunaOptionsFrame.pages[II].party = CreateFrame("CheckButton", "BlizzParty", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].party:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 180, -460)
	LunaOptionsFrame.pages[II].party:SetHeight(30)
	LunaOptionsFrame.pages[II].party:SetWidth(30)
	LunaOptionsFrame.pages[II].party:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.party = not LunaUF.db.profile.blizzard.party
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzPartyText"):SetText(L["Party"])

	LunaOptionsFrame.pages[II].target = CreateFrame("CheckButton", "BlizzTarget", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].target:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 260, -460)
	LunaOptionsFrame.pages[II].target:SetHeight(30)
	LunaOptionsFrame.pages[II].target:SetWidth(30)
	LunaOptionsFrame.pages[II].target:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.target = not LunaUF.db.profile.blizzard.target
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzTargetText"):SetText(L["Target"])

	LunaOptionsFrame.pages[II].mouseover = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].mouseover:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -490)
	LunaOptionsFrame.pages[II].mouseover:SetHeight(24)
	LunaOptionsFrame.pages[II].mouseover:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].mouseover:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].mouseover:SetText(L["Mouseover"])

	LunaOptionsFrame.pages[II].mouseovercheck = CreateFrame("CheckButton", "Mouseover3D", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].mouseovercheck:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -520)
	LunaOptionsFrame.pages[II].mouseovercheck:SetHeight(30)
	LunaOptionsFrame.pages[II].mouseovercheck:SetWidth(30)
	LunaOptionsFrame.pages[II].mouseovercheck:SetScript("OnClick", function()
		LunaUF.db.profile.mouseover = not LunaUF.db.profile.mouseover
	end)
	getglobal("Mouseover3DText"):SetText(L["Mouseover in 3D world"])

	LunaOptionsFrame.pages[II].RangeCheck = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].RangeCheck:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -550)
	LunaOptionsFrame.pages[II].RangeCheck:SetHeight(24)
	LunaOptionsFrame.pages[II].RangeCheck:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].RangeCheck:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].RangeCheck:SetText(L["Range"])

	LunaOptionsFrame.pages[II].rangepolling = CreateFrame("Slider", "RangePollingRate", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].rangepolling:SetMinMaxValues(0.5,5)
	LunaOptionsFrame.pages[II].rangepolling:SetValueStep(0.1)
	LunaOptionsFrame.pages[II].rangepolling:SetScript("OnValueChanged", function()
		LunaUF.db.profile.RangePolRate = math.floor((this:GetValue()+0.05)*10)/10
		getglobal("RangePollingRateText"):SetText(L["Polling Rate"]..": "..LunaUF.db.profile.RangePolRate.."s")
	end)
	LunaOptionsFrame.pages[II].rangepolling:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "BOTTOMLEFT", 30, -580)
	LunaOptionsFrame.pages[II].rangepolling:SetWidth(220)

	LunaOptionsFrame.pages[II].rangecl = CreateFrame("CheckButton", "RangeCombatLog", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].rangecl:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 280, -580)
	LunaOptionsFrame.pages[II].rangecl:SetHeight(30)
	LunaOptionsFrame.pages[II].rangecl:SetWidth(30)
	LunaOptionsFrame.pages[II].rangecl:SetScript("OnClick", function()
		LunaUF.db.profile.RangeCLparsing = not LunaUF.db.profile.RangeCLparsing
	end)
	getglobal("RangeCombatLogText"):SetText(L["Enable Combatlog based Range"])

	for i=2, 11 do
		LunaOptionsFrame.pages[i].id = LunaUF.unitList[i-1]

		LunaOptionsFrame.pages[i].enable = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enable:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i], "TOPLEFT", 20, -40)
		LunaOptionsFrame.pages[i].enable:SetHeight(30)
		LunaOptionsFrame.pages[i].enable:SetWidth(30)
		LunaOptionsFrame.pages[i].enable:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].enabled = not LunaUF.db.profile.units[unit].enabled
			LunaUF.Units:InitializeFrame(unit)
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."Text"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].heightslider = CreateFrame("Slider", "HeightSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].heightslider:SetMinMaxValues(20,150)
		LunaOptionsFrame.pages[i].heightslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].heightslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].size.y = math.floor(this:GetValue())
			getglobal("HeightSlider"..unit.."Text"):SetText(L["Height"]..": "..LunaUF.db.profile.units[unit].size.y)
			LunaUF.Units:InitializeFrame(unit)
		end)
		LunaOptionsFrame.pages[i].heightslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].enable, "BOTTOMLEFT", 0, -30)
		LunaOptionsFrame.pages[i].heightslider:SetWidth(460)

		LunaOptionsFrame.pages[i].widthslider = CreateFrame("Slider", "WidthSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].widthslider:SetMinMaxValues(20,300)
		LunaOptionsFrame.pages[i].widthslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].widthslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].size.x = math.floor(this:GetValue())
			getglobal("WidthSlider"..unit.."Text"):SetText(L["Width"]..": "..LunaUF.db.profile.units[unit].size.x)
			LunaUF.Units:InitializeFrame(unit)
		end)
		LunaOptionsFrame.pages[i].widthslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].heightslider, "BOTTOMLEFT", 0, -30)
		LunaOptionsFrame.pages[i].widthslider:SetWidth(460)

		LunaOptionsFrame.pages[i].scaleslider = CreateFrame("Slider", "ScaleSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].scaleslider:SetMinMaxValues(0.5,2)
		LunaOptionsFrame.pages[i].scaleslider:SetValueStep(0.01)
		LunaOptionsFrame.pages[i].scaleslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].scale = math.floor((this:GetValue()+0.005)*100)/100
			getglobal("ScaleSlider"..unit.."Text"):SetText(L["Scale"]..": "..LunaUF.db.profile.units[unit].scale)
			LunaUF.Units:InitializeFrame(unit)
		end)
		LunaOptionsFrame.pages[i].scaleslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].widthslider, "BOTTOMLEFT", 0, -30)
		LunaOptionsFrame.pages[i].scaleslider:SetWidth(460)

		LunaOptionsFrame.pages[i].positionsHeader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].positionsHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].scaleslider, "BOTTOMLEFT", 0, -30)
		LunaOptionsFrame.pages[i].positionsHeader:SetHeight(24)
		LunaOptionsFrame.pages[i].positionsHeader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].positionsHeader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].positionsHeader:SetText(L["Position"])

		LunaOptionsFrame.pages[i].xInput = CreateFrame("Editbox", "xInput"..LunaOptionsFrame.pages[i].id, LunaOptionsFrame.pages[i], "InputBoxTemplate")
		LunaOptionsFrame.pages[i].xInput:SetHeight(20)
		LunaOptionsFrame.pages[i].xInput:SetWidth(150)
		LunaOptionsFrame.pages[i].xInput:SetAutoFocus(nil)
		LunaOptionsFrame.pages[i].xInput:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].positionsHeader, "BOTTOMLEFT", 50, -30)
		LunaOptionsFrame.pages[i].xInput:SetScript("OnEnterPressed", function()
					local unit = this:GetParent().id
					local value = tonumber(this:GetText())
					local diff
					this:ClearFocus()
					if unit == "raid" then
						val = LunaUF.db.profile.units["raid"][UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect)].position
						if UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect) ~= 1 and LunaUF.db.profile.units.raid.interlock then
							this:SetText(val.x)
							return
						end
						unit = unit..UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect)
					else
						val = LunaUF.db.profile.units[unit].position
					end
					if value then
						diff = val.x - value
						val.x = value
					else
						this:SetText(val.x)
						return
					end
					local frame, scale
					if LunaUF.Units.unitFrames[unit] then
						frame = LunaUF.Units.unitFrames[unit]
						scale = frame:GetScale() * UIParent:GetScale()
					else
						frame = LunaUF.Units.headerFrames[unit]
						scale = 1
					end
					frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", val.x / scale, val.y / scale)
					if unit == "raid1" and LunaUF.db.profile.units.raid.interlock then -- Group 2-9 moved because we move group 1 so save their position too
						for i=2,9 do
							LunaUF.db.profile.units.raid[i].position.x = LunaUF.db.profile.units.raid[i].position.x - diff
						end
					end
				end)

		LunaOptionsFrame.pages[i].yInput = CreateFrame("Editbox", "yInput"..LunaOptionsFrame.pages[i].id, LunaOptionsFrame.pages[i], "InputBoxTemplate")
		LunaOptionsFrame.pages[i].yInput:SetHeight(20)
		LunaOptionsFrame.pages[i].yInput:SetWidth(150)
		LunaOptionsFrame.pages[i].yInput:SetAutoFocus(nil)
		LunaOptionsFrame.pages[i].yInput:SetPoint("LEFT", LunaOptionsFrame.pages[i].xInput, "RIGHT", 10, 0)
		LunaOptionsFrame.pages[i].yInput:SetScript("OnEnterPressed", function()
					local unit = this:GetParent().id
					local value = tonumber(this:GetText())
					local val, diff
					this:ClearFocus()
					if unit == "raid" then
						val = LunaUF.db.profile.units["raid"][UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect)].position
						if UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect) ~= 1 and LunaUF.db.profile.units.raid.interlock then
							this:SetText(val.y)
							return
						end
						unit = unit..UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect)
					else
						val = LunaUF.db.profile.units[unit].position
					end
					if value then
						diff = val.y - value
						val.y = value
					else
						this:SetText(val.y)
						return
					end
					local frame, scale
					if LunaUF.Units.unitFrames[unit] then
						frame = LunaUF.Units.unitFrames[unit]
						scale = frame:GetScale() * UIParent:GetScale()
					else
						frame = LunaUF.Units.headerFrames[unit]
						scale = 1
					end
					frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", val.x / scale, val.y / scale)
					if unit == "raid1" and LunaUF.db.profile.units.raid.interlock then -- Group 2-9 moved because we move group 1 so save their position too
						for i=2,9 do
							LunaUF.db.profile.units.raid[i].position.y = LunaUF.db.profile.units.raid[i].position.y - diff
						end
					end
				end)

		LunaOptionsFrame.pages[i].ButtonUp = CreateFrame("Button", "ButtonUp"..LunaOptionsFrame.pages[i].id, LunaOptionsFrame.pages[i], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[i].ButtonUp:SetPoint("BOTTOM", LunaOptionsFrame.pages[i].xInput, "TOPRIGHT", 2, 2)
		LunaOptionsFrame.pages[i].ButtonUp:SetHeight(20)
		LunaOptionsFrame.pages[i].ButtonUp:SetWidth(20)
		LunaOptionsFrame.pages[i].ButtonUp:SetText("^")
		LunaOptionsFrame.pages[i].ButtonUp:SetScript("OnClick", function()
					local unit = this:GetParent().id
					local val
					if unit == "raid" then
						if UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect) ~= 1 and LunaUF.db.profile.units.raid.interlock then
							return
						end
						val = LunaUF.db.profile.units["raid"][UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect)].position
						unit = unit..UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect)
					else
						val = LunaUF.db.profile.units[unit].position
					end
					local frame, scale
					if LunaUF.Units.unitFrames[unit] then
						frame = LunaUF.Units.unitFrames[unit]
						scale = frame:GetScale() * UIParent:GetScale()
					else
						frame = LunaUF.Units.headerFrames[unit]
						scale = 1
					end
					val.y = val.y + 1
					this:GetParent().yInput:SetText(val.y)
					frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", val.x / scale, val.y / scale)
		end)

		LunaOptionsFrame.pages[i].ButtonDown = CreateFrame("Button", "ButtonDown"..LunaOptionsFrame.pages[i].id, LunaOptionsFrame.pages[i], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[i].ButtonDown:SetPoint("TOP", LunaOptionsFrame.pages[i].xInput, "BOTTOMRIGHT", 2, -2)
		LunaOptionsFrame.pages[i].ButtonDown:SetHeight(20)
		LunaOptionsFrame.pages[i].ButtonDown:SetWidth(20)
		LunaOptionsFrame.pages[i].ButtonDown:SetText("v")
		LunaOptionsFrame.pages[i].ButtonDown:SetScript("OnClick", function()
					local unit = this:GetParent().id
					local val
					if unit == "raid" then
						if UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect) ~= 1 and LunaUF.db.profile.units.raid.interlock then
							return
						end
						val = LunaUF.db.profile.units["raid"][UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect)].position
						unit = unit..UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect)
					else
						val = LunaUF.db.profile.units[unit].position
					end
					local frame, scale
					if LunaUF.Units.unitFrames[unit] then
						frame = LunaUF.Units.unitFrames[unit]
						scale = frame:GetScale() * UIParent:GetScale()
					else
						frame = LunaUF.Units.headerFrames[unit]
						scale = 1
					end
					val.y = val.y - 1
					this:GetParent().yInput:SetText(val.y)
					frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", val.x / scale, val.y / scale)
		end)

		LunaOptionsFrame.pages[i].ButtonLeft = CreateFrame("Button", "ButtonLeft"..LunaOptionsFrame.pages[i].id, LunaOptionsFrame.pages[i], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[i].ButtonLeft:SetPoint("RIGHT", LunaOptionsFrame.pages[i].xInput, "LEFT", -6, 0)
		LunaOptionsFrame.pages[i].ButtonLeft:SetHeight(20)
		LunaOptionsFrame.pages[i].ButtonLeft:SetWidth(20)
		LunaOptionsFrame.pages[i].ButtonLeft:SetText("<")
		LunaOptionsFrame.pages[i].ButtonLeft:SetScript("OnClick", function()
					local unit = this:GetParent().id
					local val
					if unit == "raid" then
						if UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect) ~= 1 and LunaUF.db.profile.units.raid.interlock then
							return
						end
						val = LunaUF.db.profile.units["raid"][UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect)].position
						unit = unit..UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect)
					else
						val = LunaUF.db.profile.units[unit].position
					end
					local frame, scale
					if LunaUF.Units.unitFrames[unit] then
						frame = LunaUF.Units.unitFrames[unit]
						scale = frame:GetScale() * UIParent:GetScale()
					else
						frame = LunaUF.Units.headerFrames[unit]
						scale = 1
					end
					val.x = val.x - 1
					this:GetParent().xInput:SetText(val.x)
					frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", val.x / scale, val.y / scale)
		end)

		LunaOptionsFrame.pages[i].ButtonRight = CreateFrame("Button", "ButtonRight"..LunaOptionsFrame.pages[i].id, LunaOptionsFrame.pages[i], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[i].ButtonRight:SetPoint("LEFT", LunaOptionsFrame.pages[i].yInput, "RIGHT", 2, 0)
		LunaOptionsFrame.pages[i].ButtonRight:SetHeight(20)
		LunaOptionsFrame.pages[i].ButtonRight:SetWidth(20)
		LunaOptionsFrame.pages[i].ButtonRight:SetText(">")
		LunaOptionsFrame.pages[i].ButtonRight:SetScript("OnClick", function()
					local unit = this:GetParent().id
					local val
					if unit == "raid" then
						if UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect) ~= 1 and LunaUF.db.profile.units.raid.interlock then
							return
						end
						val = LunaUF.db.profile.units["raid"][UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect)].position
						unit = unit..UIDropDownMenu_GetSelectedID(LunaOptionsFrame.pages[11].GrpSelect)
					else
						val = LunaUF.db.profile.units[unit].position
					end
					local frame, scale
					if LunaUF.Units.unitFrames[unit] then
						frame = LunaUF.Units.unitFrames[unit]
						scale = frame:GetScale() * UIParent:GetScale()
					else
						frame = LunaUF.Units.headerFrames[unit]
						scale = 1
					end
					val.x = val.x + 1
					this:GetParent().xInput:SetText(val.x)
					frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", val.x / scale, val.y / scale)
		end)

		LunaOptionsFrame.pages[i].indicatorsHeader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].indicatorsHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].positionsHeader, "BOTTOMLEFT", 0, -80)
		LunaOptionsFrame.pages[i].indicatorsHeader:SetHeight(24)
		LunaOptionsFrame.pages[i].indicatorsHeader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].indicatorsHeader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].indicatorsHeader:SetText(L["Indicators"])

		LunaOptionsFrame.pages[i].indicators = CreateIndicatorOptionsFrame(LunaOptionsFrame.pages[i], LunaUF.db.profile.units[LunaUF.unitList[i-1]].indicators.icons)
		LunaOptionsFrame.pages[i].indicators:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].indicatorsHeader, "BOTTOMLEFT", 0, 20)

		LunaOptionsFrame.pages[i].faderheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].faderheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].indicators, "BOTTOMLEFT", 0, 0)
		LunaOptionsFrame.pages[i].faderheader:SetHeight(24)
		LunaOptionsFrame.pages[i].faderheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].faderheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].faderheader:SetText(L["Combat fader"])

		LunaOptionsFrame.pages[i].enableFader = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."Fader", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enableFader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].faderheader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].enableFader:SetHeight(30)
		LunaOptionsFrame.pages[i].enableFader:SetWidth(30)
		LunaOptionsFrame.pages[i].enableFader:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].fader.enabled = not LunaUF.db.profile.units[unit].fader.enabled
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."FaderText"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].FaderCombatslider = CreateFrame("Slider", "FaderCombatSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].FaderCombatslider:SetMinMaxValues(0,1)
		LunaOptionsFrame.pages[i].FaderCombatslider:SetValueStep(0.1)
		LunaOptionsFrame.pages[i].FaderCombatslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].fader.combatAlpha = math.floor((this:GetValue()*10)+0.5)/10
			getglobal("FaderCombatSlider"..unit.."Text"):SetText(L["Combat alpha"]..": "..LunaUF.db.profile.units[unit].fader.combatAlpha)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].FaderCombatslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].faderheader, "BOTTOMLEFT", 0, -50)
		LunaOptionsFrame.pages[i].FaderCombatslider:SetWidth(200)

		LunaOptionsFrame.pages[i].FaderNonCombatslider = CreateFrame("Slider", "FaderNonCombatSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].FaderNonCombatslider:SetMinMaxValues(0,1)
		LunaOptionsFrame.pages[i].FaderNonCombatslider:SetValueStep(0.1)
		LunaOptionsFrame.pages[i].FaderNonCombatslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].fader.inactiveAlpha = math.floor(this:GetValue()*10)/10
			getglobal("FaderNonCombatSlider"..unit.."Text"):SetText(L["Non combat alpha"]..": "..LunaUF.db.profile.units[unit].fader.inactiveAlpha)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].FaderNonCombatslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].faderheader, "BOTTOMLEFT", 220, -50)
		LunaOptionsFrame.pages[i].FaderNonCombatslider:SetWidth(200)

		LunaOptionsFrame.pages[i].speedyFade = CreateFrame("CheckButton", "Speedy"..LunaUF.unitList[i-1].."Fade", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].speedyFade:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].FaderCombatslider, "BOTTOMLEFT", 0, -25)
		LunaOptionsFrame.pages[i].speedyFade:SetHeight(30)
		LunaOptionsFrame.pages[i].speedyFade:SetWidth(30)
		LunaOptionsFrame.pages[i].speedyFade:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].fader.speedyFade = not LunaUF.db.profile.units[unit].fader.speedyFade
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Speedy"..LunaUF.unitList[i-1].."FadeText"):SetText(L["Speedy Fade"])

		----

		LunaOptionsFrame.pages[i].ctextheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].ctextheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].faderheader, "BOTTOMLEFT", 0, -130)
		LunaOptionsFrame.pages[i].ctextheader:SetHeight(24)
		LunaOptionsFrame.pages[i].ctextheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].ctextheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].ctextheader:SetText(L["Combat text"])

		LunaOptionsFrame.pages[i].enableCtext = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."CombatText", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enableCtext:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].ctextheader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].enableCtext:SetHeight(30)
		LunaOptionsFrame.pages[i].enableCtext:SetWidth(30)
		LunaOptionsFrame.pages[i].enableCtext:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].combatText.enabled = not LunaUF.db.profile.units[unit].combatText.enabled
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."CombatTextText"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].ctextscaleslider = CreateFrame("Slider", "CtextScale"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].ctextscaleslider:SetMinMaxValues(1,5)
		LunaOptionsFrame.pages[i].ctextscaleslider:SetValueStep(0.1)
		LunaOptionsFrame.pages[i].ctextscaleslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].combatText.size = math.floor(this:GetValue()*10)/10
			getglobal("CtextScale"..unit.."Text"):SetText(L["Size"]..": "..LunaUF.db.profile.units[unit].combatText.size)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].ctextscaleslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].ctextheader, "BOTTOMLEFT", 220, -10)
		LunaOptionsFrame.pages[i].ctextscaleslider:SetWidth(200)

		LunaOptionsFrame.pages[i].ctextXslider = CreateFrame("Slider", "CtextXSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].ctextXslider:SetMinMaxValues(-200,200)
		LunaOptionsFrame.pages[i].ctextXslider:SetValueStep(2)
		LunaOptionsFrame.pages[i].ctextXslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].combatText.xoffset = math.floor(this:GetValue())
			getglobal("CtextXSlider"..unit.."Text"):SetText("X: "..LunaUF.db.profile.units[unit].combatText.xoffset)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].ctextXslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].ctextheader, "BOTTOMLEFT", 0, -50)
		LunaOptionsFrame.pages[i].ctextXslider:SetWidth(200)

		LunaOptionsFrame.pages[i].ctextYslider = CreateFrame("Slider", "CtextYSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].ctextYslider:SetMinMaxValues(-200,200)
		LunaOptionsFrame.pages[i].ctextYslider:SetValueStep(2)
		LunaOptionsFrame.pages[i].ctextYslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].combatText.yoffset = math.floor(this:GetValue())
			getglobal("CtextYSlider"..unit.."Text"):SetText("Y: "..LunaUF.db.profile.units[unit].combatText.yoffset)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].ctextYslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].ctextheader, "BOTTOMLEFT", 220, -50)
		LunaOptionsFrame.pages[i].ctextYslider:SetWidth(200)

		----

		LunaOptionsFrame.pages[i].portraitheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].portraitheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].ctextheader, "BOTTOMLEFT", 0, -100)
		LunaOptionsFrame.pages[i].portraitheader:SetHeight(24)
		LunaOptionsFrame.pages[i].portraitheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].portraitheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].portraitheader:SetText(L["Portrait"])

		LunaOptionsFrame.pages[i].enablePortrait = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."Portrait", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enablePortrait:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].portraitheader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].enablePortrait:SetHeight(30)
		LunaOptionsFrame.pages[i].enablePortrait:SetWidth(30)
		LunaOptionsFrame.pages[i].enablePortrait:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].portrait.enabled = not LunaUF.db.profile.units[unit].portrait.enabled
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."Portrait".."Text"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].portraitType = CreateFrame("Button", "PortraitType"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "UIDropDownMenuTemplate")
		LunaOptionsFrame.pages[i].portraitType:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].portraitheader, "BOTTOMLEFT", 60 , -10)
		UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[i].portraitType)
		UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[i].portraitType)

		UIDropDownMenu_Initialize(LunaOptionsFrame.pages[i].portraitType, function()
			local info={}
			for _,v in pairs({"3D","2D",L["class"]}) do
				info.text=v
				info.value=(v == L["class"] and "class") or v
				info.func= function ()
					local dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU)
					local unit = dropdown:GetParent().id
					UIDropDownMenu_SetSelectedValue(dropdown, this.value)
					LunaUF.db.profile.units[unit].portrait.type = UIDropDownMenu_GetSelectedValue(dropdown)
					for _,frame in pairs(LunaUF.Units.frameList) do
						if frame.unitGroup == unit then
							LunaUF.Units:SetupFrameModules(frame)
						end
					end
				end
				info.checked = nil
				info.checkable = nil
				UIDropDownMenu_AddButton(info, 1)
			end
		end)

		LunaOptionsFrame.pages[i].pTypeDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		LunaOptionsFrame.pages[i].pTypeDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[i].portraitType, "TOP", 0, 0)
		LunaOptionsFrame.pages[i].pTypeDesc:SetText(L["Type"])

		LunaOptionsFrame.pages[i].portraitSide = CreateFrame("Button", "PortraitSide"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "UIDropDownMenuTemplate")
		LunaOptionsFrame.pages[i].portraitSide:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].portraitheader, "BOTTOMLEFT", 160 , -10)
		UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[i].portraitSide)
		UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[i].portraitSide)

		UIDropDownMenu_Initialize(LunaOptionsFrame.pages[i].portraitSide, function()
			local info={}
			for k,v in pairs({["left"]=L["Left"],["right"]=L["Right"],["bar"]=L["Middle"]}) do
				info.text=v
				info.value=k
				info.func= function ()
					local dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU)
					local unit = dropdown:GetParent().id
					UIDropDownMenu_SetSelectedValue(dropdown, this.value)
					LunaUF.db.profile.units[unit].portrait.side = UIDropDownMenu_GetSelectedValue(dropdown)
					for _,frame in pairs(LunaUF.Units.frameList) do
						if frame.unitGroup == unit then
							LunaUF.Units:SetupFrameModules(frame)
						end
					end
				end
				info.checked = nil
				info.checkable = nil
				UIDropDownMenu_AddButton(info, 1)
			end
		end)

		LunaOptionsFrame.pages[i].pSideDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		LunaOptionsFrame.pages[i].pSideDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[i].portraitSide, "TOP", 0, 0)
		LunaOptionsFrame.pages[i].pSideDesc:SetText(L["Side"])

		LunaOptionsFrame.pages[i].portraitsizeslider = CreateFrame("Slider", "PortraitSizeSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].portraitsizeslider:SetMinMaxValues(1,10)
		LunaOptionsFrame.pages[i].portraitsizeslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].portraitsizeslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].portrait.size = math.floor(this:GetValue())
			getglobal("PortraitSizeSlider"..unit.."Text"):SetText(L["Size"]..": "..LunaUF.db.profile.units[unit].portrait.size)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].portraitsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].portraitheader, "BOTTOMLEFT", 280, -10)
		LunaOptionsFrame.pages[i].portraitsizeslider:SetWidth(190)

		LunaOptionsFrame.pages[i].highlightheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].highlightheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].portraitheader, "BOTTOMLEFT", 0, -60)
		LunaOptionsFrame.pages[i].highlightheader:SetHeight(24)
		LunaOptionsFrame.pages[i].highlightheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].highlightheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].highlightheader:SetText(L["Highlight"])

		LunaOptionsFrame.pages[i].enableHighlight = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."Highlight", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enableHighlight:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].highlightheader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].enableHighlight:SetHeight(30)
		LunaOptionsFrame.pages[i].enableHighlight:SetWidth(30)
		LunaOptionsFrame.pages[i].enableHighlight:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].highlight.enabled = not LunaUF.db.profile.units[unit].highlight.enabled
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."HighlightText"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].ontarget = CreateFrame("CheckButton", "OnTarget"..LunaUF.unitList[i-1].."Highlight", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].ontarget:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].highlightheader, "BOTTOMLEFT", 0, -50)
		LunaOptionsFrame.pages[i].ontarget:SetHeight(30)
		LunaOptionsFrame.pages[i].ontarget:SetWidth(30)
		LunaOptionsFrame.pages[i].ontarget:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].highlight.ontarget = not LunaUF.db.profile.units[unit].highlight.ontarget
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("OnTarget"..LunaUF.unitList[i-1].."HighlightText"):SetText(L["On targeting"])

		LunaOptionsFrame.pages[i].onmouse = CreateFrame("CheckButton", "OnMouse"..LunaUF.unitList[i-1].."Highlight", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].onmouse:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].highlightheader, "BOTTOMLEFT", 150, -50)
		LunaOptionsFrame.pages[i].onmouse:SetHeight(30)
		LunaOptionsFrame.pages[i].onmouse:SetWidth(30)
		LunaOptionsFrame.pages[i].onmouse:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].highlight.onmouse = not LunaUF.db.profile.units[unit].highlight.onmouse
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("OnMouse"..LunaUF.unitList[i-1].."HighlightText"):SetText(L["On mouseover"])

		LunaOptionsFrame.pages[i].ondebuff = CreateFrame("CheckButton", "OnDebuff"..LunaUF.unitList[i-1].."Highlight", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].ondebuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].highlightheader, "BOTTOMLEFT", 300, -50)
		LunaOptionsFrame.pages[i].ondebuff:SetHeight(30)
		LunaOptionsFrame.pages[i].ondebuff:SetWidth(30)
		LunaOptionsFrame.pages[i].ondebuff:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].highlight.ondebuff = not LunaUF.db.profile.units[unit].highlight.ondebuff
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("OnDebuff"..LunaUF.unitList[i-1].."HighlightText"):SetText(L["On dispellable debuff"])

		LunaOptionsFrame.pages[i].healthheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].healthheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].highlightheader, "BOTTOMLEFT", 0, -100)
		LunaOptionsFrame.pages[i].healthheader:SetHeight(24)
		LunaOptionsFrame.pages[i].healthheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].healthheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].healthheader:SetText(L["Health bar"])

		LunaOptionsFrame.pages[i].enableHealth = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."Health", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enableHealth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healthheader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].enableHealth:SetHeight(30)
		LunaOptionsFrame.pages[i].enableHealth:SetWidth(30)
		LunaOptionsFrame.pages[i].enableHealth:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].healthBar.enabled = not LunaUF.db.profile.units[unit].healthBar.enabled
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."HealthText"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].healthsizeslider = CreateFrame("Slider", "HealthSizeSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].healthsizeslider:SetMinMaxValues(1,10)
		LunaOptionsFrame.pages[i].healthsizeslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].healthsizeslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].healthBar.size = math.floor(this:GetValue())
			getglobal("HealthSizeSlider"..unit.."Text"):SetText(L["Size"]..": "..LunaUF.db.profile.units[unit].healthBar.size)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].healthsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healthheader, "BOTTOMLEFT", 280, -10)
		LunaOptionsFrame.pages[i].healthsizeslider:SetWidth(190)

		LunaOptionsFrame.pages[i].healthcolor = CreateFrame("Button", "HealthColor"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "UIDropDownMenuTemplate")
		LunaOptionsFrame.pages[i].healthcolor:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healthheader, "BOTTOMLEFT", 60 , -10)
		UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[i].healthcolor)
		UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[i].healthcolor)

		UIDropDownMenu_Initialize(LunaOptionsFrame.pages[i].healthcolor, function()
			local info={}
			for k,v in pairs({["class"]=L["class"],["static"]=L["static"],["none"]=L["none"]}) do
				info.text=v
				info.value=k
				info.func= function ()
					local dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU)
					local unit = dropdown:GetParent().id
					UIDropDownMenu_SetSelectedValue(dropdown, this.value)
					LunaUF.db.profile.units[unit].healthBar.colorType = UIDropDownMenu_GetSelectedValue(dropdown)
					for _,frame in pairs(LunaUF.Units.frameList) do
						if frame.unitGroup == unit then
							LunaUF.Units.FullUpdate(frame)
						end
					end
				end
				info.checked = nil
				info.checkable = nil
				UIDropDownMenu_AddButton(info, 1)
			end
		end)

		LunaOptionsFrame.pages[i].cTypeDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		LunaOptionsFrame.pages[i].cTypeDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[i].healthcolor, "TOP", 0, 0)
		LunaOptionsFrame.pages[i].cTypeDesc:SetText(L["colortype"])

		LunaOptionsFrame.pages[i].healthreact = CreateFrame("Button", "HealthReact"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "UIDropDownMenuTemplate")
		LunaOptionsFrame.pages[i].healthreact:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healthheader, "BOTTOMLEFT", 160 , -10)
		UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[i].healthreact)
		UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[i].healthreact)

		UIDropDownMenu_Initialize(LunaOptionsFrame.pages[i].healthreact, function()
			local info={}
			for k,v in pairs({["player"]=L["Player"],["npc"]=L["npc"],["both"]=L["both"],["happiness"]=L["happiness"],["never"]=L["never"]}) do
				info.text=v
				info.value=k
				info.func= function ()
					local dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU)
					local unit = dropdown:GetParent().id
					UIDropDownMenu_SetSelectedValue(dropdown, this.value)
					LunaUF.db.profile.units[unit].healthBar.reactionType = UIDropDownMenu_GetSelectedValue(dropdown)
					for _,frame in pairs(LunaUF.Units.frameList) do
						if frame.unitGroup == unit then
							LunaUF.Units.FullUpdate(frame)
						end
					end
				end
				info.checked = nil
				info.checkable = nil
				UIDropDownMenu_AddButton(info, 1)
			end
		end)

		LunaOptionsFrame.pages[i].cReactDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		LunaOptionsFrame.pages[i].cReactDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[i].healthreact, "TOP", 0, 0)
		LunaOptionsFrame.pages[i].cReactDesc:SetText(L["colorreaction"])

		LunaOptionsFrame.pages[i].invertHealth = CreateFrame("CheckButton", "Invert"..LunaUF.unitList[i-1].."Health", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].invertHealth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healthheader, "BOTTOMLEFT", 0, -50)
		LunaOptionsFrame.pages[i].invertHealth:SetHeight(30)
		LunaOptionsFrame.pages[i].invertHealth:SetWidth(30)
		LunaOptionsFrame.pages[i].invertHealth:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].healthBar.invert = not LunaUF.db.profile.units[unit].healthBar.invert
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		getglobal("Invert"..LunaUF.unitList[i-1].."HealthText"):SetText(L["Invert"])

		LunaOptionsFrame.pages[i].vertHealth = CreateFrame("CheckButton", "Vertical"..LunaUF.unitList[i-1].."Health", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].vertHealth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healthheader, "BOTTOMLEFT", 90, -50)
		LunaOptionsFrame.pages[i].vertHealth:SetHeight(30)
		LunaOptionsFrame.pages[i].vertHealth:SetWidth(30)
		LunaOptionsFrame.pages[i].vertHealth:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].healthBar.vertical = not LunaUF.db.profile.units[unit].healthBar.vertical
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		getglobal("Vertical"..LunaUF.unitList[i-1].."Health".."Text"):SetText(L["Vertical"])

		LunaOptionsFrame.pages[i].powerheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].powerheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healthheader, "BOTTOMLEFT", 0, -100)
		LunaOptionsFrame.pages[i].powerheader:SetHeight(24)
		LunaOptionsFrame.pages[i].powerheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].powerheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].powerheader:SetText(L["Power bar"])

		LunaOptionsFrame.pages[i].enablePower = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."Power", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enablePower:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].powerheader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].enablePower:SetHeight(30)
		LunaOptionsFrame.pages[i].enablePower:SetWidth(30)
		LunaOptionsFrame.pages[i].enablePower:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].powerBar.enabled = not LunaUF.db.profile.units[unit].powerBar.enabled
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."PowerText"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].hidePower = CreateFrame("CheckButton", "Hide"..LunaUF.unitList[i-1].."Power", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].hidePower:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].powerheader, "BOTTOMLEFT", 80, -10)
		LunaOptionsFrame.pages[i].hidePower:SetHeight(30)
		LunaOptionsFrame.pages[i].hidePower:SetWidth(30)
		LunaOptionsFrame.pages[i].hidePower:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].powerBar.hide = not LunaUF.db.profile.units[unit].powerBar.hide
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Hide"..LunaUF.unitList[i-1].."PowerText"):SetText(L["Hide when not Mana"])

		LunaOptionsFrame.pages[i].powersizeslider = CreateFrame("Slider", "PowerSizeSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].powersizeslider:SetMinMaxValues(1,10)
		LunaOptionsFrame.pages[i].powersizeslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].powersizeslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].powerBar.size = math.floor(this:GetValue())
			getglobal("PowerSizeSlider"..unit.."Text"):SetText(L["Size"]..": "..LunaUF.db.profile.units[unit].powerBar.size)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].powersizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].powerheader, "BOTTOMLEFT", 280, -10)
		LunaOptionsFrame.pages[i].powersizeslider:SetWidth(190)

		LunaOptionsFrame.pages[i].invertPower = CreateFrame("CheckButton", "Invert"..LunaUF.unitList[i-1].."Power", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].invertPower:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].powerheader, "BOTTOMLEFT", 0, -50)
		LunaOptionsFrame.pages[i].invertPower:SetHeight(30)
		LunaOptionsFrame.pages[i].invertPower:SetWidth(30)
		LunaOptionsFrame.pages[i].invertPower:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].powerBar.invert = not LunaUF.db.profile.units[unit].powerBar.invert
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		getglobal("Invert"..LunaUF.unitList[i-1].."Power".."Text"):SetText(L["Invert"])

		LunaOptionsFrame.pages[i].vertPower = CreateFrame("CheckButton", "Vertical"..LunaUF.unitList[i-1].."Power", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].vertPower:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].powerheader, "BOTTOMLEFT", 90, -50)
		LunaOptionsFrame.pages[i].vertPower:SetHeight(30)
		LunaOptionsFrame.pages[i].vertPower:SetWidth(30)
		LunaOptionsFrame.pages[i].vertPower:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].powerBar.vertical = not LunaUF.db.profile.units[unit].powerBar.vertical
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		getglobal("Vertical"..LunaUF.unitList[i-1].."PowerText"):SetText(L["Vertical"])

		LunaOptionsFrame.pages[i].castheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].castheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].powerheader, "BOTTOMLEFT", 0, -100)
		LunaOptionsFrame.pages[i].castheader:SetHeight(24)
		LunaOptionsFrame.pages[i].castheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].castheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].castheader:SetText(L["Cast bar"])

		LunaOptionsFrame.pages[i].enablecast = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."Cast", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enablecast:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].castheader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].enablecast:SetHeight(30)
		LunaOptionsFrame.pages[i].enablecast:SetWidth(30)
		LunaOptionsFrame.pages[i].enablecast:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].castBar.enabled = not LunaUF.db.profile.units[unit].castBar.enabled
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."Cast".."Text"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].casthide = CreateFrame("CheckButton", "Cast"..LunaUF.unitList[i-1].."Hide", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].casthide:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].castheader, "BOTTOMLEFT", 80, -10)
		LunaOptionsFrame.pages[i].casthide:SetHeight(30)
		LunaOptionsFrame.pages[i].casthide:SetWidth(30)
		LunaOptionsFrame.pages[i].casthide:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].castBar.hide = not LunaUF.db.profile.units[unit].castBar.hide
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Cast"..LunaUF.unitList[i-1].."Hide".."Text"):SetText(L["hide"])

		LunaOptionsFrame.pages[i].casticon = CreateFrame("CheckButton", "Cast"..LunaUF.unitList[i-1].."Icon", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].casticon:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].castheader, "BOTTOMLEFT", 160, -10)
		LunaOptionsFrame.pages[i].casticon:SetHeight(30)
		LunaOptionsFrame.pages[i].casticon:SetWidth(30)
		LunaOptionsFrame.pages[i].casticon:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].castBar.icon = not LunaUF.db.profile.units[unit].castBar.icon
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Cast"..LunaUF.unitList[i-1].."IconText"):SetText(L["Icon"])

		LunaOptionsFrame.pages[i].castvertical = CreateFrame("CheckButton", "Cast"..LunaUF.unitList[i-1].."Vertical", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].castvertical:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].castheader, "BOTTOMLEFT", 0, -50)
		LunaOptionsFrame.pages[i].castvertical:SetHeight(30)
		LunaOptionsFrame.pages[i].castvertical:SetWidth(30)
		LunaOptionsFrame.pages[i].castvertical:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].castBar.vertical = not LunaUF.db.profile.units[unit].castBar.vertical
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Cast"..LunaUF.unitList[i-1].."VerticalText"):SetText(L["Vertical"])

		LunaOptionsFrame.pages[i].castsizeslider = CreateFrame("Slider", "CastSizeSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].castsizeslider:SetMinMaxValues(1,10)
		LunaOptionsFrame.pages[i].castsizeslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].castsizeslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].castBar.size = math.floor(this:GetValue())
			getglobal("CastSizeSlider"..unit.."Text"):SetText(L["Size"]..": "..LunaUF.db.profile.units[unit].castBar.size)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:PositionWidgets(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].castsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].castheader, "BOTTOMLEFT", 280, -10)
		LunaOptionsFrame.pages[i].castsizeslider:SetWidth(190)

		LunaOptionsFrame.pages[i].healheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].healheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].castheader, "BOTTOMLEFT", 0, -90)
		LunaOptionsFrame.pages[i].healheader:SetHeight(24)
		LunaOptionsFrame.pages[i].healheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].healheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].healheader:SetText(L["Healing prediction"])

		LunaOptionsFrame.pages[i].enableheal = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."Heal", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enableheal:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healheader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].enableheal:SetHeight(30)
		LunaOptionsFrame.pages[i].enableheal:SetWidth(30)
		LunaOptionsFrame.pages[i].enableheal:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].incheal.enabled = not LunaUF.db.profile.units[unit].incheal.enabled
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."Heal".."Text"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].healsizeslider = CreateFrame("Slider", "HealSizeSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].healsizeslider:SetMinMaxValues(0,20)
		LunaOptionsFrame.pages[i].healsizeslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].healsizeslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].incheal.cap = math.floor(this:GetValue())/100
			getglobal("HealSizeSlider"..unit.."Text"):SetText(L["Size"]..": "..(LunaUF.db.profile.units[unit].incheal.cap*100))
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].healsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healheader, "BOTTOMLEFT", 280, -10)
		LunaOptionsFrame.pages[i].healsizeslider:SetWidth(190)

		LunaOptionsFrame.pages[i].auraheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].auraheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healheader, "BOTTOMLEFT", 0, -60)
		LunaOptionsFrame.pages[i].auraheader:SetHeight(24)
		LunaOptionsFrame.pages[i].auraheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].auraheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].auraheader:SetText(L["Auras"])

		LunaOptionsFrame.pages[i].enableauras = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."Auras", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enableauras:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].auraheader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].enableauras:SetHeight(30)
		LunaOptionsFrame.pages[i].enableauras:SetWidth(30)
		LunaOptionsFrame.pages[i].enableauras:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].auras.enabled = not LunaUF.db.profile.units[unit].auras.enabled
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."Auras".."Text"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].auraposition = CreateFrame("Button", "AuraPosition"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "UIDropDownMenuTemplate")
		LunaOptionsFrame.pages[i].auraposition:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].auraheader, "BOTTOMLEFT", 60 , -10)
		UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[i].auraposition)
		UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[i].auraposition)

		UIDropDownMenu_Initialize(LunaOptionsFrame.pages[i].auraposition, function()
			local info={}
			for k,v in pairs({["TOP"]=L["TOP"],["BOTTOM"]=L["BOTTOM"],["LEFT"]=L["LEFT"],["RIGHT"]=L["RIGHT"]}) do
				info.text=v
				info.value=k
				info.func= function ()
					local dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU)
					local unit = dropdown:GetParent().id
					UIDropDownMenu_SetSelectedValue(dropdown, this.value)
					LunaUF.db.profile.units[unit].auras.position = UIDropDownMenu_GetSelectedValue(dropdown)
					for _,frame in pairs(LunaUF.Units.frameList) do
						if frame.unitGroup == unit then
							LunaUF.Units.FullUpdate(frame)
						end
					end
				end
				info.checked = nil
				info.checkable = nil
				UIDropDownMenu_AddButton(info, 1)
			end
		end)

		LunaOptionsFrame.pages[i].aPosDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		LunaOptionsFrame.pages[i].aPosDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[i].auraposition, "TOP", 0, 0)
		LunaOptionsFrame.pages[i].aPosDesc:SetText(L["Side"])

		LunaOptionsFrame.pages[i].aurasizeslider = CreateFrame("Slider", "AuraSizeSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].aurasizeslider:SetMinMaxValues(1,16)
		LunaOptionsFrame.pages[i].aurasizeslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].aurasizeslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].auras.AurasPerRow = 17-math.floor(this:GetValue())
			getglobal("AuraSizeSlider"..unit.."Text"):SetText(L["Size"]..": "..(17-LunaUF.db.profile.units[unit].auras.AurasPerRow))
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].aurasizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].auraheader, "BOTTOMLEFT", 280, -10)
		LunaOptionsFrame.pages[i].aurasizeslider:SetWidth(190)

		LunaOptionsFrame.pages[i].enablebordercolor = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."BorderColor", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enablebordercolor:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].auraheader, "BOTTOMLEFT", 0, -50)
		LunaOptionsFrame.pages[i].enablebordercolor:SetHeight(30)
		LunaOptionsFrame.pages[i].enablebordercolor:SetWidth(30)
		LunaOptionsFrame.pages[i].enablebordercolor:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].auras.bordercolor = not LunaUF.db.profile.units[unit].auras.bordercolor
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."BorderColorText"):SetText(L["Enable Border Color"])

		if (LunaUF.unitList[i-1] == "player") then
			LunaOptionsFrame.pages[i].enableaurastimertext = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."AurasTimerText", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
			LunaOptionsFrame.pages[i].enableaurastimertext:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].enablebordercolor, "BOTTOMLEFT", 0, -10)
			LunaOptionsFrame.pages[i].enableaurastimertext:SetHeight(30)
			LunaOptionsFrame.pages[i].enableaurastimertext:SetWidth(30)
			LunaOptionsFrame.pages[i].enableaurastimertext:SetScript("OnClick", function()
				local unit = this:GetParent().id
				LunaUF.db.profile.units[unit].auras.timertextenabled = not LunaUF.db.profile.units[unit].auras.timertextenabled
				for _,frame in pairs(LunaUF.Units.frameList) do
					if frame.unitGroup == unit then
						LunaUF.Units.FullUpdate(frame)
					end
				end
			end)
			getglobal("Enable"..LunaUF.unitList[i-1].."AurasTimerText".."Text"):SetText(L["Enable Timer Text"])

			LunaOptionsFrame.pages[i].auratimertextbigfontsizeslider = CreateFrame("Slider", "AuraTimerBigFontSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
			LunaOptionsFrame.pages[i].auratimertextbigfontsizeslider:SetMinMaxValues(1,23)
			LunaOptionsFrame.pages[i].auratimertextbigfontsizeslider:SetValueStep(1)
			LunaOptionsFrame.pages[i].auratimertextbigfontsizeslider:SetScript("OnValueChanged", function()
				local unit = this:GetParent().id
				LunaUF.db.profile.units[unit].auras.timertextbigsize = this:GetValue()
				getglobal("AuraTimerBigFontSlider"..unit.."Text"):SetText(L["Big font size"]..": "..LunaUF.db.profile.units[unit].auras.timertextbigsize)
				for _,frame in pairs(LunaUF.Units.frameList) do
					if frame.unitGroup == unit then
						LunaUF.Units.FullUpdate(frame)
					end
				end
			end)
			LunaOptionsFrame.pages[i].auratimertextbigfontsizeslider:SetPoint("LEFT", LunaOptionsFrame.pages[i].enableaurastimertext, "RIGHT", 120, 0)
			LunaOptionsFrame.pages[i].auratimertextbigfontsizeslider:SetWidth(150)

			LunaOptionsFrame.pages[i].auratimertextsmallfontsizeslider = CreateFrame("Slider", "AuraTimerSmallFontSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
			LunaOptionsFrame.pages[i].auratimertextsmallfontsizeslider:SetMinMaxValues(1,23)
			LunaOptionsFrame.pages[i].auratimertextsmallfontsizeslider:SetValueStep(1)
			LunaOptionsFrame.pages[i].auratimertextsmallfontsizeslider:SetScript("OnValueChanged", function()
				local unit = this:GetParent().id
				LunaUF.db.profile.units[unit].auras.timertextsmallsize = this:GetValue()
				getglobal("AuraTimerSmallFontSlider"..unit.."Text"):SetText(L["Small font size"]..": "..LunaUF.db.profile.units[unit].auras.timertextsmallsize)
				for _,frame in pairs(LunaUF.Units.frameList) do
					if frame.unitGroup == unit then
						LunaUF.Units.FullUpdate(frame)
					end
				end
			end)
			LunaOptionsFrame.pages[i].auratimertextsmallfontsizeslider:SetPoint("LEFT", LunaOptionsFrame.pages[i].enableaurastimertext, "RIGHT", 290, 0)
			LunaOptionsFrame.pages[i].auratimertextsmallfontsizeslider:SetWidth(150)

			LunaOptionsFrame.pages[i].enableaurastimerspin = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."AurasTimerSpin", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
			LunaOptionsFrame.pages[i].enableaurastimerspin:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].enableaurastimertext, "BOTTOMLEFT", 0, -10)
			LunaOptionsFrame.pages[i].enableaurastimerspin:SetHeight(30)
			LunaOptionsFrame.pages[i].enableaurastimerspin:SetWidth(30)
			LunaOptionsFrame.pages[i].enableaurastimerspin:SetScript("OnClick", function()
				local unit = this:GetParent().id
				LunaUF.db.profile.units[unit].auras.timerspinenabled = not LunaUF.db.profile.units[unit].auras.timerspinenabled
				for _,frame in pairs(LunaUF.Units.frameList) do
					if frame.unitGroup == unit then
						LunaUF.Units.FullUpdate(frame)
					end
				end
			end)
			getglobal("Enable"..LunaUF.unitList[i-1].."AurasTimerSpin".."Text"):SetText(L["Enable Timer Spin"])
		end

		LunaOptionsFrame.pages[i].tagheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].tagheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].enableaurastimertext or LunaOptionsFrame.pages[i].auraheader, "BOTTOMLEFT", 0, LunaOptionsFrame.pages[i].enableaurastimertext and -60 or -90)
		LunaOptionsFrame.pages[i].tagheader:SetHeight(24)
		LunaOptionsFrame.pages[i].tagheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].tagheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].tagheader:SetText(L["Tags"])

		LunaOptionsFrame.pages[i].enabletags = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."Tags", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enabletags:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].tagheader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].enabletags:SetHeight(30)
		LunaOptionsFrame.pages[i].enabletags:SetWidth(30)
		LunaOptionsFrame.pages[i].enabletags:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].tags.enabled = not LunaUF.db.profile.units[unit].tags.enabled
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."Tags".."Text"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].tags = CreateTagEditFrame(LunaOptionsFrame.pages[i], LunaUF.db.profile.units[LunaUF.unitList[i-1]].tags.bartags)
		LunaOptionsFrame.pages[i].tags:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].tagheader, "BOTTOMLEFT", 0, -30)

		LunaOptionsFrame.pages[i].orderheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].orderheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].tags, "BOTTOMLEFT", 0, -60)
		LunaOptionsFrame.pages[i].orderheader:SetHeight(24)
		LunaOptionsFrame.pages[i].orderheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].orderheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].orderheader:SetText(L["Barorder"])

		LunaOptionsFrame.pages[i].barorder = CreateBarOrderWidget(LunaOptionsFrame.pages[i], LunaUF.db.profile.units[LunaUF.unitList[i-1]].barorder)
		LunaOptionsFrame.pages[i].barorder:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].orderheader, "BOTTOMLEFT", 0, -20)
	end

	local II = 2
	LunaOptionsFrame.pages[II].ticker = CreateFrame("CheckButton", "TickerplayerPower", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].ticker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].powerheader, "BOTTOMLEFT", 180, -50)
	LunaOptionsFrame.pages[II].ticker:SetHeight(30)
	LunaOptionsFrame.pages[II].ticker:SetWidth(30)
	LunaOptionsFrame.pages[II].ticker:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].powerBar.ticker = not LunaUF.db.profile.units[unit].powerBar.ticker
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("TickerplayerPowerText"):SetText(L["Energy / mp5 ticker"])

	LunaOptionsFrame.pages[II].totemheader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].totemheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].barorder, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[II].totemheader:SetHeight(24)
	LunaOptionsFrame.pages[II].totemheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].totemheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].totemheader:SetText(L["Totem Bar"])

	LunaOptionsFrame.pages[II].enabletotem = CreateFrame("CheckButton", "EnableplayerTotems", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].enabletotem:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].totemheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].enabletotem:SetHeight(30)
	LunaOptionsFrame.pages[II].enabletotem:SetWidth(30)
	LunaOptionsFrame.pages[II].enabletotem:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].totemBar.enabled = not LunaUF.db.profile.units[unit].totemBar.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableplayerTotemsText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[II].totemhide = CreateFrame("CheckButton", "TotemsplayerHide", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].totemhide:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].totemheader, "BOTTOMLEFT", 80, -10)
	LunaOptionsFrame.pages[II].totemhide:SetHeight(30)
	LunaOptionsFrame.pages[II].totemhide:SetWidth(30)
	LunaOptionsFrame.pages[II].totemhide:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].totemBar.hide = not LunaUF.db.profile.units[unit].totemBar.hide
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("TotemsplayerHideText"):SetText(L["hide"])

	LunaOptionsFrame.pages[II].totemsizeslider = CreateFrame("Slider", "TotemsSizeSlidertarget", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].totemsizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[II].totemsizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[II].totemsizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.player.totemBar.size = math.floor(this:GetValue())
		getglobal("TotemsSizeSlidertargetText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.player.totemBar.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.player)
	end)
	LunaOptionsFrame.pages[II].totemsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].totemheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[II].totemsizeslider:SetWidth(190)

	LunaOptionsFrame.pages[II].druidheader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].druidheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].totemheader, "BOTTOMLEFT", 0, -60)
	LunaOptionsFrame.pages[II].druidheader:SetHeight(24)
	LunaOptionsFrame.pages[II].druidheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].druidheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].druidheader:SetText(L["Druid Bar"])

	LunaOptionsFrame.pages[II].enabledruid = CreateFrame("CheckButton", "EnableplayerDruid", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].enabledruid:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].druidheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].enabledruid:SetHeight(30)
	LunaOptionsFrame.pages[II].enabledruid:SetWidth(30)
	LunaOptionsFrame.pages[II].enabledruid:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].druidBar.enabled = not LunaUF.db.profile.units[unit].druidBar.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableplayerDruidText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[II].druidsizeslider = CreateFrame("Slider", "DruidSizeSlidertarget", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].druidsizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[II].druidsizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[II].druidsizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.player.druidBar.size = math.floor(this:GetValue())
		getglobal("DruidSizeSlidertargetText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.player.druidBar.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.player)
	end)
	LunaOptionsFrame.pages[II].druidsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].druidheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[II].druidsizeslider:SetWidth(190)

	LunaOptionsFrame.pages[II].xpheader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].xpheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].druidheader, "BOTTOMLEFT", 0, -60)
	LunaOptionsFrame.pages[II].xpheader:SetHeight(24)
	LunaOptionsFrame.pages[II].xpheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].xpheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].xpheader:SetText(L["XP Bar"])

	LunaOptionsFrame.pages[II].enablexp = CreateFrame("CheckButton", "EnableplayerXP", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].enablexp:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].xpheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].enablexp:SetHeight(30)
	LunaOptionsFrame.pages[II].enablexp:SetWidth(30)
	LunaOptionsFrame.pages[II].enablexp:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units.player.xpBar.enabled = not LunaUF.db.profile.units.player.xpBar.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableplayerXPText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[II].xpsizeslider = CreateFrame("Slider", "XPSizeSliderplayer", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].xpsizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[II].xpsizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[II].xpsizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.player.xpBar.size = math.floor(this:GetValue())
		getglobal("XPSizeSliderplayerText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.player.xpBar.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.player)
	end)
	LunaOptionsFrame.pages[II].xpsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].xpheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[II].xpsizeslider:SetWidth(190)

	LunaOptionsFrame.pages[II].reckheader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].reckheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].xpheader, "BOTTOMLEFT", 0, -60)
	LunaOptionsFrame.pages[II].reckheader:SetHeight(24)
	LunaOptionsFrame.pages[II].reckheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].reckheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].reckheader:SetText(L["Reckoning Stacks"])

	LunaOptionsFrame.pages[II].enablereck = CreateFrame("CheckButton", "EnabletargetCombo", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].enablereck:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].reckheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].enablereck:SetHeight(30)
	LunaOptionsFrame.pages[II].enablereck:SetWidth(30)
	LunaOptionsFrame.pages[II].enablereck:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].reckStacks.enabled = not LunaUF.db.profile.units[unit].reckStacks.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnabletargetCombo".."Text"):SetText(L["Enable"])

	LunaOptionsFrame.pages[II].reckgrowth = CreateFrame("Button", "ReckGrowth", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].reckgrowth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].reckheader, "BOTTOMLEFT", 60 , -10)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].reckgrowth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].reckgrowth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].reckgrowth, function()
		local info={}
		for k,v in pairs({["LEFT"]=L["LEFT"],["RIGHT"]=L["RIGHT"]}) do
			info.text=v
			info.value=k
			info.func= function ()
				local dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU)
				local unit = dropdown:GetParent().id
				UIDropDownMenu_SetSelectedValue(dropdown, this.value)
				LunaUF.db.profile.units.player.reckStacks.growth = UIDropDownMenu_GetSelectedValue(dropdown)
				for _,frame in pairs(LunaUF.Units.frameList) do
					if frame.unitGroup == unit then
						LunaUF.Units.FullUpdate(frame)
					end
				end
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].reckgrDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].reckgrDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[II].reckgrowth, "TOP", 0, 0)
	LunaOptionsFrame.pages[II].reckgrDesc:SetText(L["Growth"])

	LunaOptionsFrame.pages[II].hidereck = CreateFrame("CheckButton", "HideReckStacks", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].hidereck:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].reckheader, "BOTTOMLEFT", 190, -10)
	LunaOptionsFrame.pages[II].hidereck:SetHeight(30)
	LunaOptionsFrame.pages[II].hidereck:SetWidth(30)
	LunaOptionsFrame.pages[II].hidereck:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].reckStacks.hide = not LunaUF.db.profile.units[unit].reckStacks.hide
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("HideReckStacksText"):SetText(L["hide"])

	LunaOptionsFrame.pages[II].recksizeslider = CreateFrame("Slider", "ReckSizeSliderplayer", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].recksizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[II].recksizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[II].recksizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.player.reckStacks.size = math.floor(this:GetValue())
		getglobal("ReckSizeSliderplayerText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.player.reckStacks.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.player)
	end)
	LunaOptionsFrame.pages[II].recksizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].reckheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[II].recksizeslider:SetWidth(190)

	local II = 3
	LunaOptionsFrame.pages[II].xpheader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].xpheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].barorder, "BOTTOMLEFT", 0, -60)
	LunaOptionsFrame.pages[II].xpheader:SetHeight(24)
	LunaOptionsFrame.pages[II].xpheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].xpheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].xpheader:SetText(L["XP Bar"])

	LunaOptionsFrame.pages[II].enablexp = CreateFrame("CheckButton", "EnablepetXP", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].enablexp:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].xpheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].enablexp:SetHeight(30)
	LunaOptionsFrame.pages[II].enablexp:SetWidth(30)
	LunaOptionsFrame.pages[II].enablexp:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units.pet.xpBar.enabled = not LunaUF.db.profile.units.pet.xpBar.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnablepetXPText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[II].xpsizeslider = CreateFrame("Slider", "XPSizeSliderpet", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].xpsizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[II].xpsizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[II].xpsizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.pet.xpBar.size = math.floor(this:GetValue())
		getglobal("XPSizeSliderpetText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.pet.xpBar.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.pet)
	end)
	LunaOptionsFrame.pages[II].xpsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].xpheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[II].xpsizeslider:SetWidth(190)

	local II = 5
	LunaOptionsFrame.pages[II].comboheader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].comboheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].barorder, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[II].comboheader:SetHeight(24)
	LunaOptionsFrame.pages[II].comboheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].comboheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].comboheader:SetText(L["Combo points"])

	LunaOptionsFrame.pages[II].enablecombo = CreateFrame("CheckButton", "EnabletargetCombo", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].enablecombo:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].comboheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].enablecombo:SetHeight(30)
	LunaOptionsFrame.pages[II].enablecombo:SetWidth(30)
	LunaOptionsFrame.pages[II].enablecombo:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].comboPoints.enabled = not LunaUF.db.profile.units[unit].comboPoints.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnabletargetCombo".."Text"):SetText(L["Enable"])

	LunaOptionsFrame.pages[II].combogrowth = CreateFrame("Button", "ComboGrowth", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].combogrowth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].comboheader, "BOTTOMLEFT", 60 , -10)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].combogrowth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].combogrowth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].combogrowth, function()
		local info={}
		for k,v in pairs({["LEFT"]=L["LEFT"],["RIGHT"]=L["RIGHT"]}) do
			info.text=v
			info.value=k
			info.func= function ()
				local dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU)
				local unit = dropdown:GetParent().id
				UIDropDownMenu_SetSelectedValue(dropdown, this.value)
				LunaUF.db.profile.units.target.comboPoints.growth = UIDropDownMenu_GetSelectedValue(dropdown)
				for _,frame in pairs(LunaUF.Units.frameList) do
					if frame.unitGroup == unit then
						LunaUF.Units.FullUpdate(frame)
					end
				end
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].combogrDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].combogrDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[II].combogrowth, "TOP", 0, 0)
	LunaOptionsFrame.pages[II].combogrDesc:SetText(L["Growth"])

	LunaOptionsFrame.pages[II].hidecombo = CreateFrame("CheckButton", "HidetargetCombo", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].hidecombo:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].comboheader, "BOTTOMLEFT", 190, -10)
	LunaOptionsFrame.pages[II].hidecombo:SetHeight(30)
	LunaOptionsFrame.pages[II].hidecombo:SetWidth(30)
	LunaOptionsFrame.pages[II].hidecombo:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].comboPoints.hide = not LunaUF.db.profile.units[unit].comboPoints.hide
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("HidetargetComboText"):SetText(L["hide"])

	LunaOptionsFrame.pages[II].combosizeslider = CreateFrame("Slider", "ComboSizeSlidertarget", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].combosizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[II].combosizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[II].combosizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.target.comboPoints.size = math.floor(this:GetValue())
		getglobal("ComboSizeSlidertargetText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.target.comboPoints.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.target)
	end)
	LunaOptionsFrame.pages[II].combosizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].comboheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[II].combosizeslider:SetWidth(190)

	local II = 8
	LunaOptionsFrame.pages[II].rangedesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].rangedesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].barorder, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[II].rangedesc:SetHeight(24)
	LunaOptionsFrame.pages[II].rangedesc:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].rangedesc:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].rangedesc:SetText(L["Range"])

	LunaOptionsFrame.pages[II].enablerange = CreateFrame("CheckButton", "EnablepartyRange", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].enablerange:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].rangedesc, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].enablerange:SetHeight(30)
	LunaOptionsFrame.pages[II].enablerange:SetWidth(30)
	LunaOptionsFrame.pages[II].enablerange:SetScript("OnClick", function()
		LunaUF.db.profile.units.party.range.enabled = not LunaUF.db.profile.units.party.range.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "party" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnablepartyRangeText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[II].partyrangealpha = CreateFrame("Slider", "AlphaSliderpartyRange", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].partyrangealpha:SetMinMaxValues(0.1,1)
	LunaOptionsFrame.pages[II].partyrangealpha:SetValueStep(0.1)
	LunaOptionsFrame.pages[II].partyrangealpha:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.party.range.alpha = math.floor(this:GetValue()*10)/10
		getglobal("AlphaSliderpartyRangeText"):SetText(L["Alpha"]..": "..LunaUF.db.profile.units.party.range.alpha)
	end)
	LunaOptionsFrame.pages[II].partyrangealpha:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].enablerange, "TOPLEFT", 200, 0)
	LunaOptionsFrame.pages[II].partyrangealpha:SetWidth(190)

	LunaOptionsFrame.pages[II].partyoptions = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].partyoptions:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].enablerange, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[II].partyoptions:SetHeight(24)
	LunaOptionsFrame.pages[II].partyoptions:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].partyoptions:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].partyoptions:SetText(L["Partyoptions"])

	LunaOptionsFrame.pages[II].inraid = CreateFrame("CheckButton", "EnablepartyInRaid", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].inraid:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].partyoptions, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].inraid:SetHeight(30)
	LunaOptionsFrame.pages[II].inraid:SetWidth(30)
	LunaOptionsFrame.pages[II].inraid:SetScript("OnClick", function()
		LunaUF.db.profile.units.party.inraid = not LunaUF.db.profile.units.party.inraid
		LunaUF.Units:InitializeFrame("party")
	end)
	getglobal("EnablepartyInRaidText"):SetText(L["Show party in raid"])

	LunaOptionsFrame.pages[II].playerparty = CreateFrame("CheckButton", "EnablePlayerparty", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].playerparty:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].inraid, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].playerparty:SetHeight(30)
	LunaOptionsFrame.pages[II].playerparty:SetWidth(30)
	LunaOptionsFrame.pages[II].playerparty:SetScript("OnClick", function()
		LunaUF.db.profile.units.party.player = not LunaUF.db.profile.units.party.player
		LunaUF.Units:LoadGroupHeader("party")
	end)
	getglobal("EnablePlayerpartyText"):SetText(L["Player in party"])

	LunaOptionsFrame.pages[II].partypadding = CreateFrame("Slider", "PartyPaddingSlider", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].partypadding:SetMinMaxValues(1,100)
	LunaOptionsFrame.pages[II].partypadding:SetValueStep(1)
	LunaOptionsFrame.pages[II].partypadding:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.party.padding = math.floor(this:GetValue())
		getglobal("PartyPaddingSliderText"):SetText(L["Padding"]..": "..LunaUF.db.profile.units.party.padding)
		LunaUF.Units:LoadGroupHeader("party")
		LunaUF.Units:LoadGroupHeader("partytarget")
		LunaUF.Units:LoadGroupHeader("partypet")
	end)
	LunaOptionsFrame.pages[II].partypadding:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].partyoptions, "BOTTOMLEFT", 270, -10)
	LunaOptionsFrame.pages[II].partypadding:SetWidth(200)

	LunaOptionsFrame.pages[II].sortby = CreateFrame("Button", "PartySortBy", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].sortby:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].playerparty, "BOTTOMLEFT", -10 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].sortby)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].sortby)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].sortby, function()
		local info={}
		for k,v in pairs({[L["Name"]] = "NAME",[L["Group"]] = "GROUP"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].sortby, this.value)
				LunaUF.db.profile.units.party.sortby = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[II].sortby)
				LunaUF.Units:LoadGroupHeader("party")
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].sortDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].sortDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[II].sortby, "TOP")
	LunaOptionsFrame.pages[II].sortDesc:SetText(L["Sort by"])

	LunaOptionsFrame.pages[II].orderby = CreateFrame("Button", "PartyOrderBy", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].orderby:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].playerparty, "BOTTOMLEFT", 140 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].orderby)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].orderby)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].orderby, function()
		local info={}
		for k,v in pairs({[L["Ascending"]] = "ASC",[L["Descending"]] = "DESC"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].orderby, this.value)
				LunaUF.db.profile.units.party.order = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[II].orderby)
				LunaUF.Units:LoadGroupHeader("party")
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].orderDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].orderDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[II].orderby, "TOP")
	LunaOptionsFrame.pages[II].orderDesc:SetText(L["Sort direction"])

	LunaOptionsFrame.pages[II].growth = CreateFrame("Button", "PartyGrowth", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].growth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].playerparty, "BOTTOMLEFT", 300 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].growth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].growth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].growth, function()
		local info={}
		for k,v in pairs({[L["LEFT"]] = "LEFT",[L["RIGHT"]] = "RIGHT",[L["UP"]] = "UP",[L["DOWN"]] = "DOWN"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].growth, this.value)
				LunaUF.db.profile.units.party.growth = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[II].growth)
				LunaUF.Units:LoadGroupHeader("party")
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].growthDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].growthDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[II].growth, "TOP")
	LunaOptionsFrame.pages[II].growthDesc:SetText(L["Growth direction"])

	local II = 11
	LunaOptionsFrame.pages[II].GrpSelDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].GrpSelDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].positionsHeader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].GrpSelDesc:SetText("GRP")

	LunaOptionsFrame.pages[II].GrpSelect = CreateFrame("Button", "GrpSelector", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].GrpSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].GrpSelDesc, "TOPLEFT", 10 , 10)
	UIDropDownMenu_SetWidth(40, LunaOptionsFrame.pages[II].GrpSelect)
	UIDropDownMenu_JustifyText("RIGHT", LunaOptionsFrame.pages[II].GrpSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].GrpSelect, function()
		local info={}
		for i=1, 9 do
			info.text=tostring(i)
			info.value=tostring(i)
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[II].GrpSelect, this:GetID())
				LunaOptionsFrame.pages[II].xInput:SetText(LunaUF.db.profile.units["raid"][tonumber(this:GetText())].position.x)
				LunaOptionsFrame.pages[II].yInput:SetText(LunaUF.db.profile.units["raid"][tonumber(this:GetText())].position.y)
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].rangedesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].rangedesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].barorder, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[II].rangedesc:SetHeight(24)
	LunaOptionsFrame.pages[II].rangedesc:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].rangedesc:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].rangedesc:SetText(L["Range"])

	LunaOptionsFrame.pages[II].enablerange = CreateFrame("CheckButton", "EnableraidRange", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].enablerange:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].rangedesc, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].enablerange:SetHeight(30)
	LunaOptionsFrame.pages[II].enablerange:SetWidth(30)
	LunaOptionsFrame.pages[II].enablerange:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.range.enabled = not LunaUF.db.profile.units.raid.range.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableraidRangeText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[II].raidrangealpha = CreateFrame("Slider", "AlphaSliderraidRange", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].raidrangealpha:SetMinMaxValues(0.1,1)
	LunaOptionsFrame.pages[II].raidrangealpha:SetValueStep(0.1)
	LunaOptionsFrame.pages[II].raidrangealpha:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.range.alpha = math.floor(this:GetValue()*10)/10
		getglobal("AlphaSliderraidRangeText"):SetText(L["Alpha"]..": "..LunaUF.db.profile.units.raid.range.alpha)
	end)
	LunaOptionsFrame.pages[II].raidrangealpha:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].enablerange, "TOPLEFT", 200, 0)
	LunaOptionsFrame.pages[II].raidrangealpha:SetWidth(190)

	LunaOptionsFrame.pages[II].trackerDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].trackerDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].enablerange, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[II].trackerDesc:SetHeight(24)
	LunaOptionsFrame.pages[II].trackerDesc:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].trackerDesc:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].trackerDesc:SetText(L["Auratracker"])

	LunaOptionsFrame.pages[II].enabletracker = CreateFrame("CheckButton", "EnableSquares", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].enabletracker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].trackerDesc, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].enabletracker:SetHeight(30)
	LunaOptionsFrame.pages[II].enabletracker:SetWidth(30)
	LunaOptionsFrame.pages[II].enabletracker:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.enabled = not LunaUF.db.profile.units.raid.squares.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableSquaresText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[II].outersizeslider = CreateFrame("Slider", "OuterSizeSliderTracker", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].outersizeslider:SetMinMaxValues(1,20)
	LunaOptionsFrame.pages[II].outersizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[II].outersizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.squares.outersize = math.floor(this:GetValue())
		getglobal("OuterSizeSliderTrackerText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.raid.squares.outersize)
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[II].outersizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].trackerDesc, "BOTTOMLEFT", 200, -10)
	LunaOptionsFrame.pages[II].outersizeslider:SetWidth(230)

	LunaOptionsFrame.pages[II].enabledebuffs = CreateFrame("CheckButton", "EnableDebuffs", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].enabledebuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].enabletracker, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].enabledebuffs:SetHeight(30)
	LunaOptionsFrame.pages[II].enabledebuffs:SetWidth(30)
	LunaOptionsFrame.pages[II].enabledebuffs:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.enabledebuffs = not LunaUF.db.profile.units.raid.squares.enabledebuffs
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableDebuffsText"):SetText(L["Enable debuffs"])

	LunaOptionsFrame.pages[II].dispdebuffs = CreateFrame("CheckButton", "EnableDispDebuffs", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].dispdebuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].enabletracker, "BOTTOMLEFT", 200, -10)
	LunaOptionsFrame.pages[II].dispdebuffs:SetHeight(30)
	LunaOptionsFrame.pages[II].dispdebuffs:SetWidth(30)
	LunaOptionsFrame.pages[II].dispdebuffs:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.dispellabledebuffs = not LunaUF.db.profile.units.raid.squares.dispellabledebuffs
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableDispDebuffsText"):SetText(L["Show dispellable debuffs"])

	LunaOptionsFrame.pages[II].owndebuffs = CreateFrame("CheckButton", "EnableOwnDebuffs", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].owndebuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].enabletracker, "BOTTOMLEFT", 200, -40)
	LunaOptionsFrame.pages[II].owndebuffs:SetHeight(30)
	LunaOptionsFrame.pages[II].owndebuffs:SetWidth(30)
	LunaOptionsFrame.pages[II].owndebuffs:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.owndispdebuffs = not LunaUF.db.profile.units.raid.squares.owndispdebuffs
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableOwnDebuffsText"):SetText(L["Only debuffs you can dispel"])

	LunaOptionsFrame.pages[II].aggro = CreateFrame("CheckButton", "EnableAggro", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].aggro:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].enabledebuffs, "BOTTOMLEFT", 0, -50)
	LunaOptionsFrame.pages[II].aggro:SetHeight(30)
	LunaOptionsFrame.pages[II].aggro:SetWidth(30)
	LunaOptionsFrame.pages[II].aggro:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.aggro = not LunaUF.db.profile.units.raid.squares.aggro
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableAggroText"):SetText(L["Show aggro"])

	LunaOptionsFrame.pages[II].aggrocolor = CreateColorSelect(LunaOptionsFrame.pages[II], LunaUF.db.profile.units.raid.squares.aggrocolor, "AggroColorSelect")
	LunaOptionsFrame.pages[II].aggrocolor:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].aggro, "TOPLEFT", 205, -5)
	LunaOptionsFrame.pages[II].aggrocolor:SetHeight(19)
	LunaOptionsFrame.pages[II].aggrocolor:SetWidth(19)
	LunaOptionsFrame.pages[II].aggrocolor.text:SetText(L["Aggrocolor"])

	LunaOptionsFrame.pages[II].hottracker = CreateFrame("CheckButton", "EnableHotTracker", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].hottracker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].aggro, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].hottracker:SetHeight(30)
	LunaOptionsFrame.pages[II].hottracker:SetWidth(30)
	LunaOptionsFrame.pages[II].hottracker:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.hottracker = not LunaUF.db.profile.units.raid.squares.hottracker
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableHotTrackerText"):SetText(L["Track heal over time"])

	LunaOptionsFrame.pages[II].innersizeslider = CreateFrame("Slider", "InnerSizeSliderTracker", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].innersizeslider:SetMinMaxValues(1,30)
	LunaOptionsFrame.pages[II].innersizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[II].innersizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.squares.innersize = math.floor(this:GetValue())
		getglobal("InnerSizeSliderTrackerText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.raid.squares.innersize)
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[II].innersizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].hottracker, "TOPLEFT", 200, 0)
	LunaOptionsFrame.pages[II].innersizeslider:SetWidth(230)

	LunaOptionsFrame.pages[II].colors = CreateFrame("CheckButton", "EnableColorsTracker", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].colors:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].hottracker, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].colors:SetHeight(30)
	LunaOptionsFrame.pages[II].colors:SetWidth(30)
	LunaOptionsFrame.pages[II].colors:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.colors = not LunaUF.db.profile.units.raid.squares.colors
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableColorsTrackerText"):SetText(L["Use colors instead of icons"])

	LunaOptionsFrame.pages[II].buffheader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].buffheader:SetPoint("TOP", LunaOptionsFrame.pages[II].colors, "BOTTOM", 20, -10)
	LunaOptionsFrame.pages[II].buffheader:SetText(L["Buffs to track"])

	LunaOptionsFrame.pages[II].buffinvert = CreateFrame("CheckButton", "BuffInvert", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].buffinvert:SetPoint("LEFT", LunaOptionsFrame.pages[II].buffheader, "RIGHT", 50, 0)
	LunaOptionsFrame.pages[II].buffinvert:SetHeight(15)
	LunaOptionsFrame.pages[II].buffinvert:SetWidth(15)
	LunaOptionsFrame.pages[II].buffinvert:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.invertbuffs = not LunaUF.db.profile.units.raid.squares.invertbuffs
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("BuffInvertText"):SetText(L["Invert display"])

	local function Exit()
		this:ClearFocus()
	end

	LunaOptionsFrame.pages[II].firstbuff = CreateFrame("Editbox", "FirstBuffInput", LunaOptionsFrame.pages[II], "InputBoxTemplate")
	LunaOptionsFrame.pages[II].firstbuff:SetHeight(20)
	LunaOptionsFrame.pages[II].firstbuff:SetWidth(200)
	LunaOptionsFrame.pages[II].firstbuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[II].firstbuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].buffheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].firstbuff:SetScript("OnTextChanged", function()
		LunaUF.db.profile.units.raid.squares.buffs.names[1] = this:GetText()
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[II].firstbuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[II].firstbuff:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[II].firstbuffcolor = CreateColorSelect(LunaOptionsFrame.pages[II], LunaUF.db.profile.units.raid.squares.buffs.colors[1])
	LunaOptionsFrame.pages[II].firstbuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[II].firstbuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[II].firstbuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[II].firstbuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[II].firstbuffcolor.text:SetText(L["Buffcolor"])

	LunaOptionsFrame.pages[II].secondbuff = CreateFrame("Editbox", "SecondBuffInput", LunaOptionsFrame.pages[II], "InputBoxTemplate")
	LunaOptionsFrame.pages[II].secondbuff:SetHeight(20)
	LunaOptionsFrame.pages[II].secondbuff:SetWidth(200)
	LunaOptionsFrame.pages[II].secondbuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[II].secondbuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].firstbuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].secondbuff:SetScript("OnTextChanged", function()
		LunaUF.db.profile.units.raid.squares.buffs.names[2] = this:GetText()
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[II].secondbuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[II].secondbuff:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[II].secondbuffcolor = CreateColorSelect(LunaOptionsFrame.pages[II], LunaUF.db.profile.units.raid.squares.buffs.colors[2])
	LunaOptionsFrame.pages[II].secondbuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[II].secondbuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[II].secondbuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[II].secondbuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[II].secondbuffcolor.text:SetText(L["Buffcolor"])

	LunaOptionsFrame.pages[II].thirdbuff = CreateFrame("Editbox", "ThirdBuffInput", LunaOptionsFrame.pages[II], "InputBoxTemplate")
	LunaOptionsFrame.pages[II].thirdbuff:SetHeight(20)
	LunaOptionsFrame.pages[II].thirdbuff:SetWidth(200)
	LunaOptionsFrame.pages[II].thirdbuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[II].thirdbuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].secondbuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].thirdbuff:SetScript("OnTextChanged", function()
		LunaUF.db.profile.units.raid.squares.buffs.names[3] = this:GetText()
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[II].thirdbuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[II].thirdbuff:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[II].thirdbuffcolor = CreateColorSelect(LunaOptionsFrame.pages[II], LunaUF.db.profile.units.raid.squares.buffs.colors[3])
	LunaOptionsFrame.pages[II].thirdbuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[II].thirdbuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[II].thirdbuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[II].thirdbuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[II].thirdbuffcolor.text:SetText(L["Buffcolor"])

	LunaOptionsFrame.pages[II].debuffheader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].debuffheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].thirdbuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].debuffheader:SetText(L["Debuffs to track"])

	LunaOptionsFrame.pages[II].firstdebuff = CreateFrame("Editbox", "FirstDebuffInput", LunaOptionsFrame.pages[II], "InputBoxTemplate")
	LunaOptionsFrame.pages[II].firstdebuff:SetHeight(20)
	LunaOptionsFrame.pages[II].firstdebuff:SetWidth(200)
	LunaOptionsFrame.pages[II].firstdebuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[II].firstdebuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].debuffheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].firstdebuff:SetScript("OnTextChanged", function()
		LunaUF.db.profile.units.raid.squares.debuffs.names[1] = string.lower(this:GetText())
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[II].firstdebuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[II].firstdebuff:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[II].firstdebuffcolor = CreateColorSelect(LunaOptionsFrame.pages[II], LunaUF.db.profile.units.raid.squares.debuffs.colors[1])
	LunaOptionsFrame.pages[II].firstdebuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[II].firstdebuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[II].firstdebuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[II].firstdebuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[II].firstdebuffcolor.text:SetText(L["Debuffcolor"])

	LunaOptionsFrame.pages[II].seconddebuff = CreateFrame("Editbox", "SecondDebuffInput", LunaOptionsFrame.pages[II], "InputBoxTemplate")
	LunaOptionsFrame.pages[II].seconddebuff:SetHeight(20)
	LunaOptionsFrame.pages[II].seconddebuff:SetWidth(200)
	LunaOptionsFrame.pages[II].seconddebuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[II].seconddebuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].firstdebuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].seconddebuff:SetScript("OnTextChanged", function()
		LunaUF.db.profile.units.raid.squares.debuffs.names[2] = string.lower(this:GetText())
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[II].seconddebuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[II].seconddebuff:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[II].seconddebuffcolor = CreateColorSelect(LunaOptionsFrame.pages[II], LunaUF.db.profile.units.raid.squares.debuffs.colors[2])
	LunaOptionsFrame.pages[II].seconddebuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[II].seconddebuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[II].seconddebuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[II].seconddebuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[II].seconddebuffcolor.text:SetText(L["Debuffcolor"])

	LunaOptionsFrame.pages[II].thirddebuff = CreateFrame("Editbox", "ThirdDebuffInput", LunaOptionsFrame.pages[II], "InputBoxTemplate")
	LunaOptionsFrame.pages[II].thirddebuff:SetHeight(20)
	LunaOptionsFrame.pages[II].thirddebuff:SetWidth(200)
	LunaOptionsFrame.pages[II].thirddebuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[II].thirddebuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].seconddebuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].thirddebuff:SetScript("OnTextChanged", function()
		LunaUF.db.profile.units.raid.squares.debuffs.names[3] = string.lower(this:GetText())
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[II].thirddebuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[II].thirddebuff:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[II].thirddebuffcolor = CreateColorSelect(LunaOptionsFrame.pages[II], LunaUF.db.profile.units.raid.squares.debuffs.colors[3])
	LunaOptionsFrame.pages[II].thirddebuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[II].thirddebuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[II].thirddebuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[II].thirddebuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[II].thirddebuffcolor.text:SetText(L["Debuffcolor"])

	LunaOptionsFrame.pages[II].raidoptions = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].raidoptions:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].thirddebuff, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[II].raidoptions:SetHeight(24)
	LunaOptionsFrame.pages[II].raidoptions:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].raidoptions:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].raidoptions:SetText(L["Raidoptions"])

	LunaOptionsFrame.pages[II].showparty = CreateFrame("CheckButton", "PartyInRaidFrames", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].showparty:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].raidoptions, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].showparty:SetHeight(30)
	LunaOptionsFrame.pages[II].showparty:SetWidth(30)
	LunaOptionsFrame.pages[II].showparty:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.showparty = not LunaUF.db.profile.units.raid.showparty
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("PartyInRaidFramesText"):SetText(L["Party in raidframes"])

	LunaOptionsFrame.pages[II].showalways = CreateFrame("CheckButton", "AlwaysShowRaid", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].showalways:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].raidoptions, "BOTTOMLEFT", 150, -10)
	LunaOptionsFrame.pages[II].showalways:SetHeight(30)
	LunaOptionsFrame.pages[II].showalways:SetWidth(30)
	LunaOptionsFrame.pages[II].showalways:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.showalways = not LunaUF.db.profile.units.raid.showalways
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("AlwaysShowRaidText"):SetText(L["Always show"])

	LunaOptionsFrame.pages[II].raidpadding = CreateFrame("Slider", "RaidPaddingSlider", LunaOptionsFrame.pages[II], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[II].raidpadding:SetMinMaxValues(1,100)
	LunaOptionsFrame.pages[II].raidpadding:SetValueStep(1)
	LunaOptionsFrame.pages[II].raidpadding:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.padding = math.floor(this:GetValue())
		getglobal("RaidPaddingSliderText"):SetText(L["Padding"]..": "..LunaUF.db.profile.units.raid.padding)
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	LunaOptionsFrame.pages[II].raidpadding:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].raidoptions, "BOTTOMLEFT", 270, -15)
	LunaOptionsFrame.pages[II].raidpadding:SetWidth(200)

	LunaOptionsFrame.pages[II].interlock = CreateFrame("CheckButton", "InterlockRaidFrames", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].interlock:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].showparty, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].interlock:SetHeight(30)
	LunaOptionsFrame.pages[II].interlock:SetWidth(30)
	LunaOptionsFrame.pages[II].interlock:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.interlock = not LunaUF.db.profile.units.raid.interlock
		LunaUF.Units:LoadRaidGroupHeader()
		if LunaUF.db.profile.units.raid.interlock then -- Frames 2-9 just snapped to frame 1 so save their new position
			for i=2,9 do
				LunaUF.db.profile.units.raid[i].position.x = LunaUF.Units.headerFrames["raid"..i]:GetLeft()
				LunaUF.db.profile.units.raid[i].position.y = (UIParent:GetHeight()/UIParent:GetScale()-LunaUF.Units.headerFrames["raid"..i]:GetTop()) * -1
			end
		end
	end)
	getglobal("InterlockRaidFramesText"):SetText(L["Interlock raidframes"])

	LunaOptionsFrame.pages[II].interlockgrowth = CreateFrame("Button", "InterlockGrowthRaid", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].interlockgrowth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].showparty, "BOTTOMLEFT", 140 , -10)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].interlockgrowth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].interlockgrowth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].interlockgrowth, function()
		local info={}
		for k,v in pairs({[L["LEFT"]] = "LEFT",[L["RIGHT"]] = "RIGHT",[L["UP"]] = "UP",[L["DOWN"]] = "DOWN"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].interlockgrowth, this.value)
				LunaUF.db.profile.units.raid.interlockgrowth = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[II].interlockgrowth)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].intergrDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].intergrDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[II].interlockgrowth, "TOP")
	LunaOptionsFrame.pages[II].intergrDesc:SetText(L["Growth direction"])

	LunaOptionsFrame.pages[II].petgrp = CreateFrame("CheckButton", "EnablePetGrp", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].petgrp:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].interlock, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].petgrp:SetHeight(30)
	LunaOptionsFrame.pages[II].petgrp:SetWidth(30)
	LunaOptionsFrame.pages[II].petgrp:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.petgrp = not LunaUF.db.profile.units.raid.petgrp
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("EnablePetGrpText"):SetText(L["Enable pet group"])

	LunaOptionsFrame.pages[II].titles = CreateFrame("CheckButton", "RaidGrpTitles", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].titles:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].interlock, "BOTTOMLEFT", 150, -10)
	LunaOptionsFrame.pages[II].titles:SetHeight(30)
	LunaOptionsFrame.pages[II].titles:SetWidth(30)
	LunaOptionsFrame.pages[II].titles:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.titles = not LunaUF.db.profile.units.raid.titles
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("RaidGrpTitlesText"):SetText(L["Enable raidgroup titles"])

	LunaOptionsFrame.pages[II].sortby = CreateFrame("Button", "RaidSortBy", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].sortby:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].petgrp, "BOTTOMLEFT", -10 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].sortby)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].sortby)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].sortby, function()
		local info={}
		for k,v in pairs({[L["Name"]] = "NAME",[L["Group"]] = "GROUP"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].sortby, this.value)
				LunaUF.db.profile.units.raid.sortby = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[II].sortby)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].sortDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].sortDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[II].sortby, "TOP")
	LunaOptionsFrame.pages[II].sortDesc:SetText(L["Sort by"])

	LunaOptionsFrame.pages[II].orderby = CreateFrame("Button", "RaidOrderBy", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].orderby:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].petgrp, "BOTTOMLEFT", 100 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].orderby)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].orderby)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].orderby, function()
		local info={}
		for k,v in pairs({[L["Ascending"]] = "ASC",[L["Descending"]] = "DESC"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].orderby, this.value)
				LunaUF.db.profile.units.raid.order = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[II].orderby)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].orderDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].orderDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[II].orderby, "TOP")
	LunaOptionsFrame.pages[II].orderDesc:SetText(L["Sort direction"])

	LunaOptionsFrame.pages[II].growth = CreateFrame("Button", "RaidGrowth", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].growth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].petgrp, "BOTTOMLEFT", 210 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].growth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].growth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].growth, function()
		local info={}
		for k,v in pairs({[L["LEFT"]] = "LEFT",[L["RIGHT"]] = "RIGHT",[L["UP"]] = "UP",[L["DOWN"]] = "DOWN"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].growth, this.value)
				LunaUF.db.profile.units.raid.growth = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[II].growth)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].growthDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].growthDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[II].growth, "TOP")
	LunaOptionsFrame.pages[II].growthDesc:SetText(L["Growth direction"])

	LunaOptionsFrame.pages[II].mode = CreateFrame("Button", "RaidMode", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].mode:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].petgrp, "BOTTOMLEFT", 320 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[II].mode)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].mode)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].mode, function()
		local info={}
		for k,v in pairs({[L["Class"]] = "CLASS",[L["Group"]] = "GROUP"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].mode, this.value)
				LunaUF.db.profile.units.raid.mode = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[II].mode)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[II].modeDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].modeDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[II].mode, "TOP")
	LunaOptionsFrame.pages[II].modeDesc:SetText(L["Mode"])

-------- Clickcasting

	local II = 12
	LunaOptionsFrame.pages[II].mouseDownClicks = CreateFrame("CheckButton", "MouseDownClicks", LunaOptionsFrame.pages[II], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[II].mouseDownClicks:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -40)
	LunaOptionsFrame.pages[II].mouseDownClicks:SetHeight(30)
	LunaOptionsFrame.pages[II].mouseDownClicks:SetWidth(30)
	LunaOptionsFrame.pages[II].mouseDownClicks:SetScript("OnClick", function()
		LunaUF.db.profile.clickcasting.mouseDownClicks = not LunaUF.db.profile.clickcasting.mouseDownClicks
		local click_action = LunaUF.db.profile.clickcasting.mouseDownClicks and "Down" or "Up"
		for _,frame in pairs(LunaUF.Units.frameList) do
			frame:RegisterForClicks('LeftButton' .. click_action, 'RightButton' .. click_action, 'MiddleButton' .. click_action, 'Button4' .. click_action, 'Button5' .. click_action)
		end
	end)
	getglobal("MouseDownClicksText"):SetText(L["Cast on mouse down"])

	LunaOptionsFrame.pages[II].Button = CreateFrame("Button", "ClickCastBindButton", LunaOptionsFrame.pages[II], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[II].Button:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].mouseDownClicks, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[II].Button:SetHeight(20)
	LunaOptionsFrame.pages[II].Button:SetWidth(180)
	LunaOptionsFrame.pages[II].Button:SetText(L["Click me"])
	LunaOptionsFrame.pages[II].Button:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
	LunaOptionsFrame.pages[II].Button:SetScript("OnClick", function ()
		this:SetText((IsControlKeyDown() and "Ctrl-" or "") .. (IsShiftKeyDown() and "Shift-" or "") .. (IsAltKeyDown() and "Alt-" or "") .. L[arg1])
	end)

	LunaOptionsFrame.pages[II].input = CreateFrame("Editbox", "ClickCastInput", LunaOptionsFrame.pages[II], "InputBoxTemplate")
	LunaOptionsFrame.pages[II].input:SetHeight(20)
	LunaOptionsFrame.pages[II].input:SetWidth(250)
	LunaOptionsFrame.pages[II].input:SetAutoFocus(nil)
	LunaOptionsFrame.pages[II].input:SetPoint("LEFT", LunaOptionsFrame.pages[II].Button, "RIGHT", 20, 0)
	LunaOptionsFrame.pages[II].input.config = LunaUF.db.profile.clickcast
	LunaOptionsFrame.pages[II].input:SetScript("OnEnterPressed", function()
		this:ClearFocus()
	end)

	LunaOptionsFrame.pages[II].Add = CreateFrame("Button", "ClickCastAddButton", LunaOptionsFrame.pages[II], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[II].Add:SetPoint("CENTER", LunaOptionsFrame.pages[II], "TOP", 0, -140)
	LunaOptionsFrame.pages[II].Add:SetHeight(20)
	LunaOptionsFrame.pages[II].Add:SetWidth(90)
	LunaOptionsFrame.pages[II].Add:SetText(L["Add"])
	LunaOptionsFrame.pages[II].Add:SetScript("OnClick", function ()
		local binding = LunaOptionsFrame.pages[II].Button:GetText()
		if binding ~= L["Click me"] then
			LunaUF.db.profile.clickcasting.bindings[binding] = LunaOptionsFrame.pages[II].input:GetText()
			LunaOptionsFrame.pages[II].Load()
		end
	end)
	LunaOptionsFrame.pages[II].bindtexts = {}
	LunaOptionsFrame.pages[II].actiontexts = {}
	LunaOptionsFrame.pages[II].delbuttons = {}
	for i=1,40 do
		LunaOptionsFrame.pages[II].bindtexts[i] = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[II].bindtexts[i]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].Add, "BOTTOM", -220, -20*i)
		LunaOptionsFrame.pages[II].bindtexts[i]:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[II].bindtexts[i]:SetTextColor(1,1,0)

		LunaOptionsFrame.pages[II].actiontexts[i] = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[II].actiontexts[i]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].Add, "BOTTOM", -40, -20*i)
		LunaOptionsFrame.pages[II].actiontexts[i]:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[II].actiontexts[i]:SetTextColor(1,1,1)

		LunaOptionsFrame.pages[II].delbuttons[i] = CreateFrame("Button", "ClickCastDelButton"..i, LunaOptionsFrame.pages[II], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[II].delbuttons[i]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].Add, "BOTTOM", 220, -20*i)
		LunaOptionsFrame.pages[II].delbuttons[i]:SetHeight(20)
		LunaOptionsFrame.pages[II].delbuttons[i]:SetWidth(20)
		LunaOptionsFrame.pages[II].delbuttons[i]:SetText("X")
		LunaOptionsFrame.pages[II].delbuttons[i].bindtext = LunaOptionsFrame.pages[II].bindtexts[i]
		LunaOptionsFrame.pages[II].delbuttons[i]:SetScript("OnClick", function ()
			LunaUF.db.profile.clickcasting.bindings[this.bindtext:GetText()] = nil
			LunaOptionsFrame.pages[II].Load()
		end)
	end

	LunaOptionsFrame.pages[II].Load = function ()
		local button = 1
		for k,v in pairs(LunaUF.db.profile.clickcasting.bindings) do
			LunaOptionsFrame.pages[II].bindtexts[button]:SetText(k)
			LunaOptionsFrame.pages[II].bindtexts[button]:Show()
			LunaOptionsFrame.pages[II].actiontexts[button]:SetText(v)
			LunaOptionsFrame.pages[II].actiontexts[button]:Show()
			LunaOptionsFrame.pages[II].delbuttons[button]:Show()
			button = button + 1
		end
		for i=button, 40 do
			LunaOptionsFrame.pages[II].bindtexts[i]:Hide()
			LunaOptionsFrame.pages[II].actiontexts[i]:Hide()
			LunaOptionsFrame.pages[II].delbuttons[i]:Hide()
		end
		LunaOptionsFrame.ScrollFrames[II]:SetScrollChild(LunaOptionsFrame.pages[II])
	end

	-------- Colors

	local II = 13
	LunaOptionsFrame.pages[II].topHeader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].topHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -40)
	LunaOptionsFrame.pages[II].topHeader:SetHeight(24)
	LunaOptionsFrame.pages[II].topHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].topHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].topHeader:SetText(L["General"])

	LunaOptionsFrame.pages[II].resetAll = CreateFrame("Button", "LunaResetAllColors", LunaOptionsFrame.pages[II], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[II].resetAll:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "BOTTOMLEFT", 15, -70)
	LunaOptionsFrame.pages[II].resetAll:SetHeight(20)
	LunaOptionsFrame.pages[II].resetAll:SetWidth(180)
	LunaOptionsFrame.pages[II].resetAll:SetText(L["Reset All Colors"])
	LunaOptionsFrame.pages[II].resetAll:SetScript("OnClick", function()
		StaticPopup_Show("RESET_LUNA_COLORS")
	end)

	LunaOptionsFrame.pages[II].cColorHeader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].cColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -100)
	LunaOptionsFrame.pages[II].cColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[II].cColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].cColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].cColorHeader:SetText(L["Classcolors"])

	for i,class in ipairs({"PRIEST","PALADIN","SHAMAN","WARRIOR","ROGUE","MAGE","WARLOCK","DRUID","HUNTER"}) do
		LunaOptionsFrame.pages[II][class] = CreateColorSelect(LunaOptionsFrame.pages[II], LunaUF.db.profile.classColors[class])
		LunaOptionsFrame.pages[II][class]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20+(((i-(3*math.floor((i-1)/3)))-1)*120), -130-(math.floor((i-1)/3)*30))
		LunaOptionsFrame.pages[II][class]:SetHeight(19)
		LunaOptionsFrame.pages[II][class]:SetWidth(19)
		LunaOptionsFrame.pages[II][class].text:SetText(L[class])
	end

	LunaOptionsFrame.pages[II].hColorHeader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].hColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -230)
	LunaOptionsFrame.pages[II].hColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[II].hColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].hColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].hColorHeader:SetText(L["Healthcolors"])

	local num = 1
	for name,options in pairs(LunaUF.db.profile.healthColors) do
		LunaOptionsFrame.pages[II][name] = CreateColorSelect(LunaOptionsFrame.pages[II], options)
		LunaOptionsFrame.pages[II][name]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20+(((num-(4*math.floor((num-1)/4)))-1)*120), -260-(math.floor((num-1)/4)*30))
		LunaOptionsFrame.pages[II][name]:SetHeight(19)
		LunaOptionsFrame.pages[II][name]:SetWidth(19)
		LunaOptionsFrame.pages[II][name].text:SetText(L[name])
		num = num+1
	end

	LunaOptionsFrame.pages[II].pColorHeader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].pColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -360)
	LunaOptionsFrame.pages[II].pColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[II].pColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].pColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].pColorHeader:SetText(L["Powercolors"])

	local num = 1
	for name,options in pairs(LunaUF.db.profile.powerColors) do
		LunaOptionsFrame.pages[II][name] = CreateColorSelect(LunaOptionsFrame.pages[II], options)
		LunaOptionsFrame.pages[II][name]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20+(((num-(3*math.floor((num-1)/3)))-1)*120), -390-(math.floor((num-1)/3)*30))
		LunaOptionsFrame.pages[II][name]:SetHeight(19)
		LunaOptionsFrame.pages[II][name]:SetWidth(19)
		LunaOptionsFrame.pages[II][name].text:SetText(L[name])
		num = num+1
	end

	LunaOptionsFrame.pages[II].castColorHeader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].castColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -460)
	LunaOptionsFrame.pages[II].castColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[II].castColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].castColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].castColorHeader:SetText(L["Castcolors"])

	local num = 1
	for name,options in pairs(LunaUF.db.profile.castColors) do
		LunaOptionsFrame.pages[II][name] = CreateColorSelect(LunaOptionsFrame.pages[II], options)
		LunaOptionsFrame.pages[II][name]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20+(((num-(3*math.floor((num-1)/3)))-1)*120), -490-(math.floor((num-1)/3)*30))
		LunaOptionsFrame.pages[II][name]:SetHeight(19)
		LunaOptionsFrame.pages[II][name]:SetWidth(19)
		LunaOptionsFrame.pages[II][name].text:SetText(L[name])
		num = num+1
	end

	LunaOptionsFrame.pages[II].xpColorHeader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].xpColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -510)
	LunaOptionsFrame.pages[II].xpColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[II].xpColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].xpColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].xpColorHeader:SetText(L["Xpcolors"])

	local num = 1
	for name,options in pairs(LunaUF.db.profile.xpColors) do
		LunaOptionsFrame.pages[II][name] = CreateColorSelect(LunaOptionsFrame.pages[II], options)
		LunaOptionsFrame.pages[II][name]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20+(((num-(3*math.floor((num-1)/3)))-1)*120), -540-(math.floor((num-1)/3)*30))
		LunaOptionsFrame.pages[II][name]:SetHeight(19)
		LunaOptionsFrame.pages[II][name]:SetWidth(19)
		LunaOptionsFrame.pages[II][name].text:SetText(L[name])
		num = num+1
	end

	-------- Profiles

	local II = 14
	local nonDeletables = {}
	nonDeletables["Default"] = true
	nonDeletables["char"] = true
	nonDeletables["class"] = true
	nonDeletables["realm"] = true

	LunaOptionsFrame.pages[II].NewProfileHeader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].NewProfileHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II], "TOPLEFT", 20, -40)
	LunaOptionsFrame.pages[II].NewProfileHeader:SetHeight(24)
	LunaOptionsFrame.pages[II].NewProfileHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].NewProfileHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].NewProfileHeader:SetText(L["New Profile"])

	LunaOptionsFrame.pages[II].input = CreateFrame("Editbox", "NewProfileInput", LunaOptionsFrame.pages[II], "InputBoxTemplate")
	LunaOptionsFrame.pages[II].input:SetHeight(20)
	LunaOptionsFrame.pages[II].input:SetWidth(200)
	LunaOptionsFrame.pages[II].input:SetAutoFocus(nil)
	LunaOptionsFrame.pages[II].input:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].NewProfileHeader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[II].input:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[II].input:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[II].Add = CreateFrame("Button", "NewProfileAddButton", LunaOptionsFrame.pages[II], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[II].Add:SetPoint("LEFT", LunaOptionsFrame.pages[II].input, "RIGHT")
	LunaOptionsFrame.pages[II].Add:SetHeight(20)
	LunaOptionsFrame.pages[II].Add:SetWidth(20)
	LunaOptionsFrame.pages[II].Add:SetText("+")
	LunaOptionsFrame.pages[II].Add:SetScript("OnClick", function ()
		local ProfileName = LunaOptionsFrame.pages[II].input:GetText()
		if ProfileName == "" then return end
		LunaUF:SetProfile(ProfileName, UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[II].CopySelect) ~= "" and UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[II].CopySelect) or nil)
		UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].ProfileSelect, ProfileName)
		UIDropDownMenu_SetText(ProfileName, LunaOptionsFrame.pages[II].ProfileSelect)
		LunaOptionsFrame.pages[II].input:ClearFocus()
		LunaOptionsFrame.pages[II].input:SetText("")
	end)

	LunaOptionsFrame.pages[II].CopySelect = CreateFrame("Button", "CopySelect", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].CopySelect:SetPoint("LEFT", LunaOptionsFrame.pages[II].Add, "RIGHT", 0 , 0)
	UIDropDownMenu_SetWidth(210, LunaOptionsFrame.pages[II].CopySelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].CopySelect)

	LunaOptionsFrame.pages[II].growthDesc = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].growthDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[II].CopySelect, "TOP")
	LunaOptionsFrame.pages[II].growthDesc:SetText(L["Copy Settings for new Profile from *"])

	LunaOptionsFrame.pages[II].SelectProfileHeader = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[II].SelectProfileHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].NewProfileHeader, "TOPLEFT", 0, -80)
	LunaOptionsFrame.pages[II].SelectProfileHeader:SetHeight(24)
	LunaOptionsFrame.pages[II].SelectProfileHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[II].SelectProfileHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[II].SelectProfileHeader:SetText(L["Select Profile"])

	LunaOptionsFrame.pages[II].ProfileSelect = CreateFrame("Button", "ProfileSelect", LunaOptionsFrame.pages[II], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[II].ProfileSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].SelectProfileHeader, "BOTTOMLEFT", -22 , -10)
	UIDropDownMenu_SetWidth(210, LunaOptionsFrame.pages[II].ProfileSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[II].ProfileSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].ProfileSelect, function()
		local info={}
		for k,v in pairs(LunaDB.profiles) do
			if v then
				info.text=k
				info.value=k
				info.func= function ()
					UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].ProfileSelect, this.value)
					UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].CopySelect, "")
					UIDropDownMenu_SetText("\-\-\-", LunaOptionsFrame.pages[II].CopySelect)
					LunaUF:SetProfile(this.value)
					if nonDeletables[LunaUF:GetProfile()] then
						LunaOptionsFrame.pages[II].delete:Disable()
					else
						LunaOptionsFrame.pages[II].delete:Enable()
					end
				end
				info.checked = nil
				info.checkable = true
				UIDropDownMenu_AddButton(info, 1)
			end
		end
	end)
	local _,currentProfile = LunaUF:GetProfile()
	UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].ProfileSelect, currentProfile)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[II].CopySelect, function()
		local info={}
		for k,v in pairs(LunaDB.profiles) do
			if k ~= UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[II].ProfileSelect) then
				info.text=k
				info.value=k
				info.func= function ()
					UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].CopySelect, this.value)
				end
				info.checked = nil
				info.checkable = true
				UIDropDownMenu_AddButton(info, 1)
			end
		end
		info.text="\-\-\-"
		info.value=""
		info.func= function ()
			UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].CopySelect, this.value)
		end
		info.checked = nil
		info.checkable = true
		UIDropDownMenu_AddButton(info, 1)
	end)
	UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[II].CopySelect, "")

	LunaOptionsFrame.pages[II].reset = CreateFrame("Button", "ProfileResetButton", LunaOptionsFrame.pages[II], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[II].reset:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].SelectProfileHeader, "BOTTOMLEFT", -5, -40)
	LunaOptionsFrame.pages[II].reset:SetHeight(20)
	LunaOptionsFrame.pages[II].reset:SetWidth(160)
	LunaOptionsFrame.pages[II].reset:SetText(L["Reset current Profile"])
	LunaOptionsFrame.pages[II].reset:SetScript("OnClick", function ()
		StaticPopup_Show("RESET_LUNA_PROFILE")
	end )

	LunaOptionsFrame.pages[II].delete = CreateFrame("Button", "ProfileResetButton", LunaOptionsFrame.pages[II], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[II].delete:SetPoint("TOP", LunaOptionsFrame.pages[II].reset, "BOTTOM")
	LunaOptionsFrame.pages[II].delete:SetHeight(20)
	LunaOptionsFrame.pages[II].delete:SetWidth(160)
	LunaOptionsFrame.pages[II].delete:SetText(L["Delete current Profile"])
	LunaOptionsFrame.pages[II].delete:SetScript("OnClick", function ()
		StaticPopup_Show("DELETE_LUNA_PROFILE")
	end )
	if nonDeletables[LunaUF:GetProfile()] then
		LunaOptionsFrame.pages[II].delete:Disable()
	else
		LunaOptionsFrame.pages[II].delete:Enable()
	end

	LunaOptionsFrame.pages[II].hint = LunaOptionsFrame.pages[II]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[II].hint:SetPoint("TOPLEFT", LunaOptionsFrame.pages[II].delete, "BOTTOMLEFT", 0, -40)
	LunaOptionsFrame.pages[II].hint:SetText(L["* Copying from the active profile is not possible"])

	-------- Help

	LunaOptionsFrame.Helpframe = CreateFrame("ScrollFrame", nil, LunaOptionsFrame)
	LunaOptionsFrame.Helpframe:SetHeight(400)
	LunaOptionsFrame.Helpframe:SetWidth(320)
	LunaOptionsFrame.Helpframe:SetPoint("TOPLEFT", LunaOptionsFrame, "TOPRIGHT", 5, 0)
	LunaOptionsFrame.Helpframe:SetBackdrop(LunaUF.constants.backdrop)
	LunaOptionsFrame.Helpframe:SetBackdropColor(0.18,0.27,0.5,1)

	LunaOptionsFrame.HelpScrollFrame = CreateFrame("ScrollFrame", nil, LunaOptionsFrame.Helpframe)
	LunaOptionsFrame.HelpScrollFrame:SetHeight(380)
	LunaOptionsFrame.HelpScrollFrame:SetWidth(280)
	LunaOptionsFrame.HelpScrollFrame:SetPoint("TOPLEFT", LunaOptionsFrame.Helpframe, "TOPLEFT", 10, -10)
	LunaOptionsFrame.HelpScrollFrame:EnableMouseWheel(true)
	LunaOptionsFrame.HelpScrollFrame:SetBackdrop(LunaUF.constants.backdrop)
	LunaOptionsFrame.HelpScrollFrame:SetBackdropColor(0,0,0,1)
	LunaOptionsFrame.HelpScrollFrame:SetScript("OnMouseWheel", function()
																	local maxScroll = this:GetVerticalScrollRange()
																	local Scroll = this:GetVerticalScroll()
																	local toScroll = (Scroll - (20*arg1))
																	if toScroll < 0 then
																		this:SetVerticalScroll(0)
																	elseif toScroll > maxScroll then
																		this:SetVerticalScroll(maxScroll)
																	else
																		this:SetVerticalScroll(toScroll)
																	end
																	local script = LunaOptionsFrame.HelpFrameSlider:GetScript("OnValueChanged")
																	LunaOptionsFrame.HelpFrameSlider:SetScript("OnValueChanged", nil)
																	LunaOptionsFrame.HelpFrameSlider:SetValue(toScroll/maxScroll)
																	LunaOptionsFrame.HelpFrameSlider:SetScript("OnValueChanged", script)
																end)

	LunaOptionsFrame.HelpFrameSlider = CreateFrame("Slider", nil, LunaOptionsFrame.HelpScrollFrame)
	LunaOptionsFrame.HelpFrameSlider:SetOrientation("VERTICAL")
	LunaOptionsFrame.HelpFrameSlider:SetPoint("TOPLEFT", LunaOptionsFrame.HelpScrollFrame, "TOPRIGHT", 5, 0)
	LunaOptionsFrame.HelpFrameSlider:SetBackdrop(LunaUF.constants.backdrop)
	LunaOptionsFrame.HelpFrameSlider:SetBackdropColor(0,0,0,0.5)
	LunaOptionsFrame.HelpFrameSlider.thumbtexture = LunaOptionsFrame.HelpFrameSlider:CreateTexture()
	LunaOptionsFrame.HelpFrameSlider.thumbtexture:SetTexture(0.18,0.27,0.5,1)
	LunaOptionsFrame.HelpFrameSlider:SetThumbTexture(LunaOptionsFrame.HelpFrameSlider.thumbtexture)
	LunaOptionsFrame.HelpFrameSlider:SetMinMaxValues(0,1)
	LunaOptionsFrame.HelpFrameSlider:SetHeight(380)
	LunaOptionsFrame.HelpFrameSlider:SetWidth(15)
	LunaOptionsFrame.HelpFrameSlider:SetValue(0)
	LunaOptionsFrame.HelpFrameSlider.ScrollFrame = LunaOptionsFrame.HelpScrollFrame
	LunaOptionsFrame.HelpFrameSlider:SetScript("OnValueChanged", function() this.ScrollFrame:SetVerticalScroll(this.ScrollFrame:GetVerticalScrollRange()*this:GetValue()) end  )

	LunaOptionsFrame.helpframescrollchild = CreateFrame("Frame", "helpframescrollchild", LunaOptionsFrame.HelpScrollFrame)
	LunaOptionsFrame.helpframescrollchild:SetHeight(1)
	LunaOptionsFrame.helpframescrollchild:SetWidth(300)

	LunaOptionsFrame.helpframescrollchild.title = LunaOptionsFrame.helpframescrollchild:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.helpframescrollchild)
	LunaOptionsFrame.helpframescrollchild.title:SetFont(defaultFont, 20)
	LunaOptionsFrame.helpframescrollchild.title:SetText(L["Tag listing"])
	LunaOptionsFrame.helpframescrollchild.title:SetJustifyH("CENTER")
	LunaOptionsFrame.helpframescrollchild.title:SetJustifyV("TOP")
	LunaOptionsFrame.helpframescrollchild.title:SetPoint("TOP", LunaOptionsFrame.helpframescrollchild, "TOP")
	LunaOptionsFrame.helpframescrollchild.title:SetHeight(20)
	LunaOptionsFrame.helpframescrollchild.title:SetWidth(300)

	LunaOptionsFrame.helpframescrollchild.texts = {}
	local first
	local count = 1
	local prevframe = LunaOptionsFrame.helpframescrollchild.title
	for _,l in pairs({"INFO TAGS","HEALTH AND POWER TAGS","COLOR TAGS"}) do
		l = L[l]
		LunaOptionsFrame.helpframescrollchild.texts[count] = LunaOptionsFrame.helpframescrollchild:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.helpframescrollchild)
		LunaOptionsFrame.helpframescrollchild.texts[count]:SetFont(defaultFont, 12)
		LunaOptionsFrame.helpframescrollchild.texts[count]:SetText("\n"..l)
		LunaOptionsFrame.helpframescrollchild.texts[count]:SetJustifyH("LEFT")
		LunaOptionsFrame.helpframescrollchild.texts[count]:SetJustifyV("TOP")
		if LunaOptionsFrame.helpframescrollchild.texts[count]:GetStringWidth() > 280 then
			LunaOptionsFrame.helpframescrollchild.texts[count]:SetHeight(22)
		else
			LunaOptionsFrame.helpframescrollchild.texts[count]:SetHeight(30)
		end
		LunaOptionsFrame.helpframescrollchild.texts[count]:SetWidth(300)
		if not first then
			LunaOptionsFrame.helpframescrollchild.texts[count]:SetPoint("TOP", prevframe, "BOTTOM")
		else
			LunaOptionsFrame.helpframescrollchild.texts[count]:SetPoint("TOPLEFT", prevframe, "BOTTOMLEFT")
		end
		prevframe = LunaOptionsFrame.helpframescrollchild.texts[count]
		first = true
		count = count + 1

		for k,v in pairs(TagsDescs[l]) do
			LunaOptionsFrame.helpframescrollchild.texts[count] = LunaOptionsFrame.helpframescrollchild:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.helpframescrollchild)
			LunaOptionsFrame.helpframescrollchild.texts[count]:SetFont(defaultFont, 9)
			LunaOptionsFrame.helpframescrollchild.texts[count]:SetText("\124cffffff00".."["..k.."]\124cffffffff: "..v)
			LunaOptionsFrame.helpframescrollchild.texts[count]:SetJustifyH("LEFT")
			LunaOptionsFrame.helpframescrollchild.texts[count]:SetJustifyV("TOP")
			if LunaOptionsFrame.helpframescrollchild.texts[count]:GetStringWidth() > 281 then
				LunaOptionsFrame.helpframescrollchild.texts[count]:SetHeight(22)
			else
				LunaOptionsFrame.helpframescrollchild.texts[count]:SetHeight(11)
			end
			LunaOptionsFrame.helpframescrollchild.texts[count]:SetWidth(280)
			if not first then
				LunaOptionsFrame.helpframescrollchild.texts[count]:SetPoint("TOP", prevframe, "BOTTOM")
			else
				LunaOptionsFrame.helpframescrollchild.texts[count]:SetPoint("TOPLEFT", prevframe, "BOTTOMLEFT")
			end
			prevframe = LunaOptionsFrame.helpframescrollchild.texts[count]
			first = true
			count = count + 1
		end
	end
	LunaOptionsFrame.HelpScrollFrame:SetScrollChild(LunaOptionsFrame.helpframescrollchild)
	LunaOptionsFrame.Helpframe:Hide()
	LunaOptionsFrame:SetScale(0.8)
end
