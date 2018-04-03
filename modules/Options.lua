local L = LunaUF.L
local defaultFont = LunaUF.defaultFont
local OptionsPageNames = {L["General"],L["Player"],L["Pet"],L["Pet Target"],L["Target"],L["ToT"],L["ToToT"],L["Party"],L["Party Target"],L["Party Pet"],L["Raid"],L["Clickcasting"],L["Colors"],L["Profiles"],L["Config Mode"]}
local shownFrame = 1

local TagsDescs = {}

TagsDescs[L["INFO TAGS"]] = {
	["numtargeting"] = L["Number of people in your group targeting this unit"],
	["cnumtargeting"] = L["Colored version of numtargeting"],
	["br"] = L["Adds a line break"],
	["name"] = L["Returns plain name of the unit"],
	["shortname:x"] = L["Returns the first x letters of the name (1-12)"],
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
	["loyalty"] = L["Loyalty level of your pet"],
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
			frame[name].enable.config = config
			frame[name].enable:SetChecked(config.enabled)
			frame[name].sizeslider.config = config
			frame[name].sizeslider:SetValue(config.size)
			frame[name].anchor.config = config
			SetDropDownValue(frame[name].anchor,config.anchorPoint)
			frame[name].xslider.config = config
			frame[name].xslider:SetValue(config.x)
			frame[name].yslider.config = config
			frame[name].yslider:SetValue(config.y)
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
	local count = 0
	for barname,tags in pairs(tagconfig) do
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
		frame[barname].Desc:SetTextColor(1,1,0)

		anchor = frame[barname].size
		if barname ~= "castBar" then
			frame[barname].left = CreateFrame("Editbox", "LeftTag"..parent.id..barname, frame, "InputBoxTemplate")
			frame[barname].left:SetHeight(20)
			frame[barname].left:SetWidth(200)
			frame[barname].left:SetAutoFocus(nil)
			frame[barname].left:SetPoint("TOP", frame[barname].size, "BOTTOM", 0, -30)
			frame[barname].left.config = tags
			frame[barname].left:SetScript("OnTextChanged" , function()
				this.config.left = this:GetText()
				for _,v in pairs(LunaUF.Units.frameList) do
					if this:GetParent().parent.id == v.unitGroup then
						LunaUF.Units.FullUpdate(v)
					end
				end
			end)
			frame[barname].left:SetScript("OnEnterPressed", function()
				this:ClearFocus()
			end)

			frame[barname].LeftDesc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			frame[barname].LeftDesc:SetPoint("BOTTOM", frame[barname].left, "TOP", 0, 0)
			frame[barname].LeftDesc:SetText(L["LEFT"])

			frame[barname].leftsize = CreateFrame("Slider", "LeftSize"..parent.id..barname.."Slider", frame, "OptionsSliderTemplate")
			frame[barname].leftsize:SetMinMaxValues(1,100)
			frame[barname].leftsize:SetValueStep(1)
			frame[barname].leftsize.config = tags
			frame[barname].leftsize:SetScript("OnValueChanged", function()
				this.config.leftsize = math.floor(this:GetValue())
				getglobal(this:GetName().."Text"):SetText(L["Limit"]..": "..this.config.leftsize.."%")
				for _,v in pairs(LunaUF.Units.frameList) do
					if this:GetParent().parent.id == v.unitGroup then
						LunaUF.Units.FullUpdate(v)
					end
				end
			end)
			frame[barname].leftsize:SetPoint("LEFT", frame[barname].left, "RIGHT", 20, 0)
			frame[barname].leftsize:SetWidth(200)

			frame[barname].right = CreateFrame("Editbox", "RightTag"..parent.id..barname, frame, "InputBoxTemplate")
			frame[barname].right:SetHeight(20)
			frame[barname].right:SetWidth(200)
			frame[barname].right:SetAutoFocus(nil)
			frame[barname].right:SetPoint("TOP", frame[barname].left, "BOTTOM", 0, -30)
			frame[barname].right.config = tags
			frame[barname].right:SetScript("OnTextChanged" , function()
				this.config.right = this:GetText()
				for _,v in pairs(LunaUF.Units.frameList) do
					if this:GetParent().parent.id == v.unitGroup then
						LunaUF.Units.FullUpdate(v)
					end
				end
			end)
			frame[barname].right:SetScript("OnEnterPressed", function()
				this:ClearFocus()
			end)

			frame[barname].RightDesc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			frame[barname].RightDesc:SetPoint("BOTTOM", frame[barname].right, "TOP", 0, 0)
			frame[barname].RightDesc:SetText(L["RIGHT"])

			frame[barname].rightsize = CreateFrame("Slider", "RightSize"..parent.id..barname.."Slider", frame, "OptionsSliderTemplate")
			frame[barname].rightsize:SetMinMaxValues(1,100)
			frame[barname].rightsize:SetValueStep(1)
			frame[barname].rightsize.config = tags
			frame[barname].rightsize:SetScript("OnValueChanged", function()
				this.config.rightsize = math.floor(this:GetValue())
				getglobal(this:GetName().."Text"):SetText(L["Limit"]..": "..this.config.rightsize.."%")
				for _,v in pairs(LunaUF.Units.frameList) do
					if this:GetParent().parent.id == v.unitGroup then
						LunaUF.Units.FullUpdate(v)
					end
				end
			end)
			frame[barname].rightsize:SetPoint("LEFT", frame[barname].right, "RIGHT", 20, 0)
			frame[barname].rightsize:SetWidth(200)

			frame[barname].middle = CreateFrame("Editbox", "MiddleTag"..parent.id..barname, frame, "InputBoxTemplate")
			frame[barname].middle:SetHeight(20)
			frame[barname].middle:SetWidth(200)
			frame[barname].middle:SetAutoFocus(nil)
			frame[barname].middle:SetPoint("TOP", frame[barname].right, "BOTTOM", 0, -30)
			frame[barname].middle.config = tags
			frame[barname].middle:SetScript("OnTextChanged" , function()
				this.config.center = this:GetText()
				for _,v in pairs(LunaUF.Units.frameList) do
					if this:GetParent().parent.id == v.unitGroup then
						LunaUF.Units.FullUpdate(v)
					end
				end
			end)
			frame[barname].middle:SetScript("OnEnterPressed", function()
				this:ClearFocus()
			end)

			frame[barname].MiddleDesc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			frame[barname].MiddleDesc:SetPoint("BOTTOM", frame[barname].middle, "TOP", 0, 0)
			frame[barname].MiddleDesc:SetText(L["Middle"])

			frame[barname].middlesize = CreateFrame("Slider", "MiddleSize"..parent.id..barname.."Slider", frame, "OptionsSliderTemplate")
			frame[barname].middlesize:SetMinMaxValues(1,100)
			frame[barname].middlesize:SetValueStep(1)
			frame[barname].middlesize.config = tags
			frame[barname].middlesize:SetScript("OnValueChanged", function()
				this.config.middlesize = math.floor(this:GetValue())
				getglobal(this:GetName().."Text"):SetText(L["Limit"]..": "..this.config.middlesize.."%")
				for _,v in pairs(LunaUF.Units.frameList) do
					if this:GetParent().parent.id == v.unitGroup then
						LunaUF.Units.FullUpdate(v)
					end
				end
			end)
			frame[barname].middlesize:SetPoint("LEFT", frame[barname].middle, "RIGHT", 20, 0)
			frame[barname].middlesize:SetWidth(200)

			anchor = frame[barname].middle
		end
		count = count+1
	end
	frame.load = function (frame, config)
		frame.config = config
		for barname,tags in pairs(config) do
			frame[barname].size.config = tags
			frame[barname].size:SetValue(tags.size)
			if barname ~= "castBar" then
				frame[barname].middle.config = tags
				frame[barname].middle:SetText(tags.center or "")
				frame[barname].middlesize:SetValue(tags.middlesize)
				frame[barname].left.config = tags
				frame[barname].left:SetText(tags.left or "")
				frame[barname].leftsize:SetValue(tags.leftsize)
				frame[barname].right.config = tags
				frame[barname].right:SetText(tags.right or "")
				frame[barname].rightsize:SetValue(tags.rightsize)
			end
		end
	end
	frame:SetHeight(182*count)
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

local function RefreshAuraWindow(controls, auras, start)
	local i, currSlot = 1, 1
	for k,v in pairs(auras) do
		if i == start then
			controls[currSlot][1]:SetText(k)
			controls[currSlot][2]:Show()
			currSlot = currSlot + 1
			start = start + 1
		end
		if currSlot == 4 then return end
		i = i + 1
	end
	for k = currSlot,3 do
		controls[k][1]:SetText("")
		controls[k][2]:Hide()
	end
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
		LunaOptionsFrame.pages[i].enableBorders:SetChecked(LunaUF.db.profile.units[unit].borders.enabled)
		SetDropDownValue(LunaOptionsFrame.pages[i].bordersMode,LunaUF.db.profile.units[unit].borders.mode)
		LunaOptionsFrame.pages[i].dispelOption:SetChecked(LunaUF.db.profile.units[unit].borders.owndispdebuffs)
		if LunaUF.db.profile.units[unit].borders.mode == "dispel" then
			LunaOptionsFrame.pages[i].dispelOption:Enable()
		else
			LunaOptionsFrame.pages[i].dispelOption:Disable()
		end
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
		LunaOptionsFrame.pages[i].highlightalphaslider:SetValue(LunaUF.db.profile.units[unit].highlight.alpha)
		LunaOptionsFrame.pages[i].ontarget:SetChecked(LunaUF.db.profile.units[unit].highlight.ontarget)
		LunaOptionsFrame.pages[i].onmouse:SetChecked(LunaUF.db.profile.units[unit].highlight.onmouse)
		LunaOptionsFrame.pages[i].ondebuff:SetChecked(LunaUF.db.profile.units[unit].highlight.ondebuff)
		LunaOptionsFrame.pages[i].enableHealth:SetChecked(LunaUF.db.profile.units[unit].healthBar.enabled)
		LunaOptionsFrame.pages[i].healthsizeslider:SetValue(LunaUF.db.profile.units[unit].healthBar.size)
		SetDropDownValue(LunaOptionsFrame.pages[i].healthcolor,LunaUF.db.profile.units[unit].healthBar.colorType)
		SetDropDownValue(LunaOptionsFrame.pages[i].healthreact,LunaUF.db.profile.units[unit].healthBar.reactionType)
		LunaOptionsFrame.pages[i].invertHealth:SetChecked(LunaUF.db.profile.units[unit].healthBar.invert)
		LunaOptionsFrame.pages[i].vertHealth:SetChecked(LunaUF.db.profile.units[unit].healthBar.vertical)
		LunaOptionsFrame.pages[i].reverseHealth:SetChecked(LunaUF.db.profile.units[unit].healthBar.reverse)
		-- Assert the classGradient setting
		LunaUF.db.profile.units[unit].healthBar.classGradient =
			LunaUF.db.profile.units[unit].healthBar.colorType == "class" and LunaUF.db.profile.units[unit].healthBar.classGradient
		LunaOptionsFrame.pages[i].classGradient:SetChecked(LunaUF.db.profile.units[unit].healthBar.classGradient)
		LunaOptionsFrame.pages[i].enablePower:SetChecked(LunaUF.db.profile.units[unit].powerBar.enabled)
		LunaOptionsFrame.pages[i].hidePower:SetChecked(LunaUF.db.profile.units[unit].powerBar.hide)
		LunaOptionsFrame.pages[i].powersizeslider:SetValue(LunaUF.db.profile.units[unit].powerBar.size)
		LunaOptionsFrame.pages[i].invertPower:SetChecked(LunaUF.db.profile.units[unit].powerBar.invert)
		LunaOptionsFrame.pages[i].vertPower:SetChecked(LunaUF.db.profile.units[unit].powerBar.vertical)
		LunaOptionsFrame.pages[i].reversePower:SetChecked(LunaUF.db.profile.units[unit].powerBar.reverse)
		LunaOptionsFrame.pages[i].enableempty:SetChecked(LunaUF.db.profile.units[unit].emptyBar.enabled)
		LunaOptionsFrame.pages[i].emptysizeslider:SetValue(LunaUF.db.profile.units[unit].emptyBar.size)
		LunaOptionsFrame.pages[i].enablecast:SetChecked(LunaUF.db.profile.units[unit].castBar.enabled)
		LunaOptionsFrame.pages[i].casthide:SetChecked(LunaUF.db.profile.units[unit].castBar.hide)
		LunaOptionsFrame.pages[i].casticon:SetChecked(LunaUF.db.profile.units[unit].castBar.icon)
		LunaOptionsFrame.pages[i].castvertical:SetChecked(LunaUF.db.profile.units[unit].castBar.vertical)
		LunaOptionsFrame.pages[i].reverseCast:SetChecked(LunaUF.db.profile.units[unit].castBar.reverse)
		LunaOptionsFrame.pages[i].castsizeslider:SetValue(LunaUF.db.profile.units[unit].castBar.size)
		if LunaOptionsFrame.pages[i].enableheal then
			LunaOptionsFrame.pages[i].enableheal:SetChecked(LunaUF.db.profile.units[unit].incheal.enabled)
			LunaOptionsFrame.pages[i].healsizeslider:SetValue(LunaUF.db.profile.units[unit].incheal.cap*100)
		end
		LunaOptionsFrame.pages[i].showbuffs:SetChecked(LunaUF.db.profile.units[unit].auras.buffs)
		LunaOptionsFrame.pages[i].buffsizeslider:SetValue(LunaUF.db.profile.units[unit].auras.buffsize)
		LunaOptionsFrame.pages[i].bigbuffsizeslider:SetValue(LunaUF.db.profile.units[unit].auras.enlargedbuffsize)
		SetDropDownValue(LunaOptionsFrame.pages[i].buffposition, LunaUF.db.profile.units[unit].auras.buffpos)
		LunaOptionsFrame.pages[i].showdebuffs:SetChecked(LunaUF.db.profile.units[unit].auras.debuffs)
		LunaOptionsFrame.pages[i].debuffsizeslider:SetValue(LunaUF.db.profile.units[unit].auras.debuffsize)
		LunaOptionsFrame.pages[i].bigdebuffsizeslider:SetValue(LunaUF.db.profile.units[unit].auras.enlargeddebuffsize)
		SetDropDownValue(LunaOptionsFrame.pages[i].debuffposition, LunaUF.db.profile.units[unit].auras.debuffpos)
		LunaOptionsFrame.pages[i].aurapaddingslider:SetValue(LunaUF.db.profile.units[unit].auras.padding)
		LunaOptionsFrame.pages[i].enablebordercolor:SetChecked(LunaUF.db.profile.units[unit].auras.bordercolor)
		SetDropDownValue(LunaOptionsFrame.pages[i].buffposition,LunaUF.db.profile.units[unit].auras.position)
		RefreshAuraWindow(LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls, LunaOptionsFrame.pages[i].EmphasizeBuffsBG.config, LunaOptionsFrame.pages[i].EmphasizeBuffsBG.slot)
		RefreshAuraWindow(LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls, LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.config, LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.slot)
		if (unit == "player") then
			LunaOptionsFrame.pages[i].enableaurastimertext:SetChecked(LunaUF.db.profile.units[unit].auras.timertextenabled)
			LunaOptionsFrame.pages[i].auratimertextbigfontsizeslider:SetValue(LunaUF.db.profile.units[unit].auras.timertextbigsize)
			LunaOptionsFrame.pages[i].auratimertextsmallfontsizeslider:SetValue(LunaUF.db.profile.units[unit].auras.timertextsmallsize)
			LunaOptionsFrame.pages[i].enableaurastimerspin:SetChecked(LunaUF.db.profile.units[unit].auras.timerspinenabled)
			LunaOptionsFrame.pages[i].wbuffs:SetChecked(LunaUF.db.profile.units[unit].auras.weaponbuffs)
		end
		LunaOptionsFrame.pages[i].enabletags:SetChecked(LunaUF.db.profile.units[unit].tags.enabled)
		LunaOptionsFrame.pages[i].tags.load(LunaOptionsFrame.pages[i].tags,LunaUF.db.profile.units[unit].tags.bartags)
		LunaOptionsFrame.pages[i].barorder.load(LunaOptionsFrame.pages[i].barorder,LunaUF.db.profile.units[unit].barorder)
	end

	local page = 1
	SetDropDownValue(LunaOptionsFrame.pages[page].FontSelect,LunaUF.db.profile.font)
	SetDropDownValue(LunaOptionsFrame.pages[page].TextureSelect,LunaUF.db.profile.texture)
	LunaOptionsFrame.pages[page].stretch:SetChecked(LunaUF.db.profile.stretchtex)
	SetDropDownValue(LunaOptionsFrame.pages[page].AuraBorderSelect,LunaUF.db.profile.auraborderType)
	LunaOptionsFrame.pages[page].enableTTips:SetChecked(LunaUF.db.profile.tooltips)
	LunaOptionsFrame.pages[page].enableTTipscombat:SetChecked(LunaUF.db.profile.tooltipCombat)
	LunaOptionsFrame.pages[page].baralphaslider:SetValue(LunaUF.db.profile.bars.alpha)
	LunaOptionsFrame.pages[page].bgbaralphaslider:SetValue(LunaUF.db.profile.bars.backgroundAlpha)
	LunaOptionsFrame.pages[page].bgcolor.load(LunaOptionsFrame.pages[page].bgcolor,LunaUF.db.profile.bgcolor)
	LunaOptionsFrame.pages[page].bgalphaslider:SetValue(LunaUF.db.profile.bgalpha)
	LunaOptionsFrame.pages[page].castbar:SetChecked(LunaUF.db.profile.blizzard.castbar)
	LunaOptionsFrame.pages[page].buffs:SetChecked(LunaUF.db.profile.blizzard.buffs)
	LunaOptionsFrame.pages[page].weaponbuffs:SetChecked(LunaUF.db.profile.blizzard.weaponbuffs)
	LunaOptionsFrame.pages[page].player:SetChecked(LunaUF.db.profile.blizzard.player)
	LunaOptionsFrame.pages[page].pet:SetChecked(LunaUF.db.profile.blizzard.pet)
	LunaOptionsFrame.pages[page].party:SetChecked(LunaUF.db.profile.blizzard.party)
	LunaOptionsFrame.pages[page].target:SetChecked(LunaUF.db.profile.blizzard.target)
	LunaOptionsFrame.pages[page].mouseovercheck:SetChecked(LunaUF.db.profile.mouseover)
	LunaOptionsFrame.pages[page].rangepolling:SetValue(LunaUF.db.profile.RangePolRate or 1.5)
	LunaOptionsFrame.pages[page].rangecl:SetChecked(LunaUF.db.profile.RangeCLparsing)
	LunaOptionsFrame.pages[page].ecast:SetChecked(LunaUF.db.profile.enemyCastbars)
	page = 2
	LunaOptionsFrame.pages[page].ticker:SetChecked(LunaUF.db.profile.units.player.powerBar.ticker)
	LunaOptionsFrame.pages[page].manausage:SetChecked(LunaUF.db.profile.units.player.powerBar.manaUsage)
	LunaOptionsFrame.pages[page].enabletotem:SetChecked(LunaUF.db.profile.units.player.totemBar.enabled)
	LunaOptionsFrame.pages[page].totemhide:SetChecked(LunaUF.db.profile.units.player.totemBar.hide)
	LunaOptionsFrame.pages[page].totemsizeslider:SetValue(LunaUF.db.profile.units.player.totemBar.size)
	LunaOptionsFrame.pages[page].enabledruid:SetChecked(LunaUF.db.profile.units.player.druidBar.enabled)
	LunaOptionsFrame.pages[page].druidsizeslider:SetValue(LunaUF.db.profile.units.player.druidBar.size)
	LunaOptionsFrame.pages[page].enablexp:SetChecked(LunaUF.db.profile.units.player.xpBar.enabled)
	LunaOptionsFrame.pages[page].xpsizeslider:SetValue(LunaUF.db.profile.units.player.xpBar.size)
	LunaOptionsFrame.pages[page].enablereck:SetChecked(LunaUF.db.profile.units.player.reckStacks.enabled)
	SetDropDownValue(LunaOptionsFrame.pages[page].reckgrowth,LunaUF.db.profile.units.player.reckStacks.growth)
	LunaOptionsFrame.pages[page].hidereck:SetChecked(LunaUF.db.profile.units.player.reckStacks.hide)
	LunaOptionsFrame.pages[page].recksizeslider:SetValue(LunaUF.db.profile.units.player.reckStacks.size)
	page = 3
	LunaOptionsFrame.pages[page].enablexp:SetChecked(LunaUF.db.profile.units.pet.xpBar.enabled)
	LunaOptionsFrame.pages[page].xpsizeslider:SetValue(LunaUF.db.profile.units.pet.xpBar.size)
	page = 5
	LunaOptionsFrame.pages[page].enablecombo:SetChecked(LunaUF.db.profile.units.target.comboPoints.enabled)
	SetDropDownValue(LunaOptionsFrame.pages[page].combogrowth,LunaUF.db.profile.units.target.comboPoints.growth)
	LunaOptionsFrame.pages[page].hidecombo:SetChecked(LunaUF.db.profile.units.target.comboPoints.hide)
	LunaOptionsFrame.pages[page].combosizeslider:SetValue(LunaUF.db.profile.units.target.comboPoints.size)
	page = 8
	LunaOptionsFrame.pages[page].enablerange:SetChecked(LunaUF.db.profile.units.party.range.enabled)
	LunaOptionsFrame.pages[page].partyrangealpha:SetValue(LunaUF.db.profile.units.party.range.alpha)
	LunaOptionsFrame.pages[page].inraid:SetChecked(LunaUF.db.profile.units.party.inraid)
	LunaOptionsFrame.pages[page].playerparty:SetChecked(LunaUF.db.profile.units.party.player)
	LunaOptionsFrame.pages[page].partypadding:SetValue(LunaUF.db.profile.units.party.padding)
	SetDropDownValue(LunaOptionsFrame.pages[page].sortby,LunaUF.db.profile.units.party.sortby)
	SetDropDownValue(LunaOptionsFrame.pages[page].orderby,LunaUF.db.profile.units.party.order)
	SetDropDownValue(LunaOptionsFrame.pages[page].growth,LunaUF.db.profile.units.party.growth)
	page = 11
	SetDropDownValue(LunaOptionsFrame.pages[page].GrpSelect, "1")
	LunaOptionsFrame.pages[page].xInput:SetText(LunaUF.db.profile.units["raid"][1].position.x)
	LunaOptionsFrame.pages[page].yInput:SetText(LunaUF.db.profile.units["raid"][1].position.y)
	LunaOptionsFrame.pages[page].enablerange:SetChecked(LunaUF.db.profile.units.raid.range.enabled)
	LunaOptionsFrame.pages[page].raidrangealpha:SetValue(LunaUF.db.profile.units.raid.range.alpha)

	--healthAlphas
	LunaOptionsFrame.pages[page].healthAlphas:SetChecked(LunaUF.db.profile.units.raid.healththreshold.enabled)
	LunaOptionsFrame.pages[page].healththresholdslider:SetValue(LunaUF.db.profile.units.raid.healththreshold.threshold)

	LunaOptionsFrame.pages[page].inrangebelowthresholdslider:SetValue(LunaUF.db.profile.units.raid.healththreshold.inRangeBelowAlpha)
	LunaOptionsFrame.pages[page].inrangeabovethresholdslider:SetValue(LunaUF.db.profile.units.raid.healththreshold.inRangeAboveAlpha)
	LunaOptionsFrame.pages[page].outrangebelowthresholdslider:SetValue(LunaUF.db.profile.units.raid.healththreshold.outOfRangeBelowAlpha)
	--
	LunaOptionsFrame.pages[page].enabletracker:SetChecked(LunaUF.db.profile.units.raid.squares.enabled)
	LunaOptionsFrame.pages[page].outersizeslider:SetValue(LunaUF.db.profile.units.raid.squares.outersize)
	LunaOptionsFrame.pages[page].enabledebuffs:SetChecked(LunaUF.db.profile.units.raid.squares.enabledebuffs)
	LunaOptionsFrame.pages[page].dispdebuffs:SetChecked(LunaUF.db.profile.units.raid.squares.dispellabledebuffs)
	LunaOptionsFrame.pages[page].owndebuffs:SetChecked(LunaUF.db.profile.units.raid.squares.owndispdebuffs)
	LunaOptionsFrame.pages[page].aggro:SetChecked(LunaUF.db.profile.units.raid.squares.aggro)
	LunaOptionsFrame.pages[page].aggrocolor.load(LunaOptionsFrame.pages[page].aggrocolor,LunaUF.db.profile.units.raid.squares.aggrocolor)
	LunaOptionsFrame.pages[page].hottracker:SetChecked(LunaUF.db.profile.units.raid.squares.hottracker)
	LunaOptionsFrame.pages[page].innersizeslider:SetValue(LunaUF.db.profile.units.raid.squares.innersize)
	LunaOptionsFrame.pages[page].buffcolors:SetChecked(LunaUF.db.profile.units.raid.squares.buffcolors)
	LunaOptionsFrame.pages[page].debuffcolors:SetChecked(LunaUF.db.profile.units.raid.squares.debuffcolors)
	LunaOptionsFrame.pages[page].firstbuffinvert:SetChecked(LunaUF.db.profile.units.raid.squares.invertfirstbuff)
	LunaOptionsFrame.pages[page].secondbuffinvert:SetChecked(LunaUF.db.profile.units.raid.squares.invertsecondbuff)
	LunaOptionsFrame.pages[page].thirdbuffinvert:SetChecked(LunaUF.db.profile.units.raid.squares.invertthirdbuff)
	LunaOptionsFrame.pages[page].firstbuff:SetText(LunaUF.db.profile.units.raid.squares.buffs.names[1])
	LunaOptionsFrame.pages[page].firstbuffcolor.load(LunaOptionsFrame.pages[page].firstbuffcolor,LunaUF.db.profile.units.raid.squares.buffs.colors[1])
	LunaOptionsFrame.pages[page].secondbuff:SetText(LunaUF.db.profile.units.raid.squares.buffs.names[2])
	LunaOptionsFrame.pages[page].secondbuffcolor.load(LunaOptionsFrame.pages[page].secondbuffcolor,LunaUF.db.profile.units.raid.squares.buffs.colors[2])
	LunaOptionsFrame.pages[page].thirdbuff:SetText(LunaUF.db.profile.units.raid.squares.buffs.names[3])
	LunaOptionsFrame.pages[page].thirdbuffcolor.load(LunaOptionsFrame.pages[page].thirdbuffcolor,LunaUF.db.profile.units.raid.squares.buffs.colors[3])
	LunaOptionsFrame.pages[page].firstdebuff:SetText(LunaUF.db.profile.units.raid.squares.debuffs.names[1])
	LunaOptionsFrame.pages[page].firstdebuffcolor.load(LunaOptionsFrame.pages[page].firstdebuffcolor,LunaUF.db.profile.units.raid.squares.debuffs.colors[1])
	LunaOptionsFrame.pages[page].seconddebuff:SetText(LunaUF.db.profile.units.raid.squares.debuffs.names[2])
	LunaOptionsFrame.pages[page].seconddebuffcolor.load(LunaOptionsFrame.pages[page].seconddebuffcolor,LunaUF.db.profile.units.raid.squares.debuffs.colors[2])
	LunaOptionsFrame.pages[page].thirddebuff:SetText(LunaUF.db.profile.units.raid.squares.debuffs.names[3])
	LunaOptionsFrame.pages[page].thirddebuffcolor.load(LunaOptionsFrame.pages[page].thirddebuffcolor,LunaUF.db.profile.units.raid.squares.debuffs.colors[3])
	LunaOptionsFrame.pages[page].showparty:SetChecked(LunaUF.db.profile.units.raid.showparty)
	LunaOptionsFrame.pages[page].showalways:SetChecked(LunaUF.db.profile.units.raid.showalways)
	LunaOptionsFrame.pages[page].raidpadding:SetValue(LunaUF.db.profile.units.raid.padding)
	LunaOptionsFrame.pages[page].interlock:SetChecked(LunaUF.db.profile.units.raid.interlock)
	SetDropDownValue(LunaOptionsFrame.pages[page].interlockgrowth,LunaUF.db.profile.units.raid.interlockgrowth)
	LunaOptionsFrame.pages[page].petgrp:SetChecked(LunaUF.db.profile.units.raid.petgrp)
	LunaOptionsFrame.pages[page].titles:SetChecked(LunaUF.db.profile.units.raid.titles)
	SetDropDownValue(LunaOptionsFrame.pages[page].sortby,LunaUF.db.profile.units.raid.sortby)
	SetDropDownValue(LunaOptionsFrame.pages[page].orderby,LunaUF.db.profile.units.raid.order)
	SetDropDownValue(LunaOptionsFrame.pages[page].growth,LunaUF.db.profile.units.raid.growth)
	SetDropDownValue(LunaOptionsFrame.pages[page].mode,LunaUF.db.profile.units.raid.mode)
	ToggleDropDownMenu(1,nil,LunaOptionsFrame.pages[page].mode)
	page = 12
	LunaOptionsFrame.pages[page].mouseDownClicks:SetChecked(LunaUF.db.profile.clickcasting.mouseDownClicks)
	LunaOptionsFrame.pages[page].Load()
	page = 13
	for i,class in ipairs({"PRIEST","PALADIN","SHAMAN","WARRIOR","ROGUE","MAGE","WARLOCK","DRUID","HUNTER"}) do
		LunaOptionsFrame.pages[page][class].load(LunaOptionsFrame.pages[page][class],LunaUF.db.profile.classColors[class])
	end
	for name,_ in pairs(LunaUF.db.profile.healthColors) do
		LunaOptionsFrame.pages[page][name].load(LunaOptionsFrame.pages[page][name],LunaUF.db.profile.healthColors[name])
	end
	for name,_ in pairs(LunaUF.db.profile.powerColors) do
		LunaOptionsFrame.pages[page][name].load(LunaOptionsFrame.pages[page][name],LunaUF.db.profile.powerColors[name])
	end
	for name,_ in pairs(LunaUF.db.profile.castColors) do
		LunaOptionsFrame.pages[page][name].load(LunaOptionsFrame.pages[page][name],LunaUF.db.profile.castColors[name])
	end
	for name,_ in pairs(LunaUF.db.profile.xpColors) do
		LunaOptionsFrame.pages[page][name].load(LunaOptionsFrame.pages[page][name],LunaUF.db.profile.xpColors[name])
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
	LunaOptionsFrame:SetScript("OnShow", function()
		LunaUF.db.profile.showOptions = true
	end)
	LunaOptionsFrame:SetScript("OnHide", function()
		LunaUF.db.profile.showOptions = false
	end)
	if not LunaUF.db.profile.showOptions then
		LunaOptionsFrame:Hide()
	end

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

	if LunaUF.db.profile.version or 0 > LunaUF.Version then
		LunaOptionsFrame.version:SetTextColor(1,0,0)
		LunaOptionsFrame.version:SetText("V."..LunaUF.Version.." (Outdated)")
	else
		LunaOptionsFrame.version:SetTextColor(1,1,1)
		LunaOptionsFrame.version:SetText("V."..LunaUF.Version)
	end

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

	local page = 1
	LunaOptionsFrame.pages[page].fontHeader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].fontHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -40)
	LunaOptionsFrame.pages[page].fontHeader:SetHeight(24)
	LunaOptionsFrame.pages[page].fontHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].fontHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].fontHeader:SetText(L["Font"])

	LunaOptionsFrame.pages[page].FontSelect = CreateFrame("Button", "FontSelector", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].FontSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 0 , -70)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].FontSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].FontSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].FontSelect, function()
		local info={}
		for k,v in ipairs(L["FONT_LIST"]) do
			info.text=v
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[page].FontSelect, this:GetID())
				LunaUF.db.profile.font = UIDropDownMenu_GetText(LunaOptionsFrame.pages[page].FontSelect)
				for _,frame in pairs(LunaUF.Units.frameList) do
					LunaUF.Units.FullUpdate(frame)
				end
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[page].textureHeader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].textureHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -100)
	LunaOptionsFrame.pages[page].textureHeader:SetHeight(24)
	LunaOptionsFrame.pages[page].textureHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].textureHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].textureHeader:SetText(L["Textures"])

	LunaOptionsFrame.pages[page].textureDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].textureDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -130)
	LunaOptionsFrame.pages[page].textureDesc:SetText(L["Bar Texture"])

	LunaOptionsFrame.pages[page].TextureSelect = CreateFrame("Button", "TextureSelector", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].TextureSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 0 , -145)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].TextureSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].TextureSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].TextureSelect, function()
		local info={}
		for k,v in ipairs({"Aluminium","Armory","BantoBar","Bars","Button","Charcoal","Cilo","Dabs","Diagonal","Fifths","Flat","Fourths","Glamour","Glamour2","Glamour3","Glamour4","Glamour5","Glamour6","Glamour7","Glaze","Gloss","Healbot","Luna","Lyfe","Otravi","Perl2","Ruben","Skewed","Smooth","Striped","Wisps"}) do
			info.text=v
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[page].TextureSelect, this:GetID())
				LunaUF.db.profile.texture = UIDropDownMenu_GetText(LunaOptionsFrame.pages[page].TextureSelect)
				for _,frame in pairs(LunaUF.Units.frameList) do
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[page].stretch = CreateFrame("CheckButton", "EnableStretch", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].stretch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 120, -145)
	LunaOptionsFrame.pages[page].stretch:SetHeight(30)
	LunaOptionsFrame.pages[page].stretch:SetWidth(30)
	LunaOptionsFrame.pages[page].stretch:SetScript("OnClick", function()
		LunaUF.db.profile.stretchtex = not LunaUF.db.profile.stretchtex
		for _,frame in pairs(LunaUF.Units.frameList) do
			LunaUF.Units:SetupFrameModules(frame)
		end
	end)
	getglobal("EnableStretchText"):SetText(L["Stretch Textures"])

	LunaOptionsFrame.pages[page].AuraDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].AuraDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 250, -130)
	LunaOptionsFrame.pages[page].AuraDesc:SetText(L["Aura Border"])

	LunaOptionsFrame.pages[page].AuraBorderSelect = CreateFrame("Button", "AuraBorderSelector", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].AuraBorderSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 230 , -145)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].AuraBorderSelect)
	UIDropDownMenu_JustifyText("RIGHT", LunaOptionsFrame.pages[page].AuraBorderSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].AuraBorderSelect, function()
		local info={}
		for k,v in ipairs({L["none"],"black","dark","light","blizzard"}) do
			info.text=v
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[page].AuraBorderSelect, this:GetID())
				LunaUF.db.profile.auraborderType = UIDropDownMenu_GetText(LunaOptionsFrame.pages[page].AuraBorderSelect)
				for _,frame in pairs(LunaUF.Units.frameList) do
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[page].Tooltips = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].Tooltips:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -180)
	LunaOptionsFrame.pages[page].Tooltips:SetHeight(24)
	LunaOptionsFrame.pages[page].Tooltips:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].Tooltips:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].Tooltips:SetText(L["Tooltips"])

	LunaOptionsFrame.pages[page].enableTTips = CreateFrame("CheckButton", "EnableTTips", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].enableTTips:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -200)
	LunaOptionsFrame.pages[page].enableTTips:SetHeight(30)
	LunaOptionsFrame.pages[page].enableTTips:SetWidth(30)
	LunaOptionsFrame.pages[page].enableTTips:SetScript("OnClick", function()
		LunaUF.db.profile.tooltips = not LunaUF.db.profile.tooltips
	end)
	getglobal("EnableTTipsText"):SetText(L["Enable Tooltips"])

	LunaOptionsFrame.pages[page].enableTTipscombat = CreateFrame("CheckButton", "EnableTTipsCombat", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].enableTTipscombat:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 200, -200)
	LunaOptionsFrame.pages[page].enableTTipscombat:SetHeight(30)
	LunaOptionsFrame.pages[page].enableTTipscombat:SetWidth(30)
	LunaOptionsFrame.pages[page].enableTTipscombat:SetScript("OnClick", function()
		LunaUF.db.profile.tooltipCombat = not LunaUF.db.profile.tooltipCombat
	end)
	getglobal("EnableTTipsCombatText"):SetText(L["Tooltips hidden in combat"])

	LunaOptionsFrame.pages[page].BarTrans = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].BarTrans:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -230)
	LunaOptionsFrame.pages[page].BarTrans:SetHeight(24)
	LunaOptionsFrame.pages[page].BarTrans:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].BarTrans:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].BarTrans:SetText(L["Bar transparency"])

	LunaOptionsFrame.pages[page].baralphaslider = CreateFrame("Slider", "BarAlphaSlider", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].baralphaslider:SetMinMaxValues(0.01,1)
	LunaOptionsFrame.pages[page].baralphaslider:SetValueStep(0.01)
	LunaOptionsFrame.pages[page].baralphaslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.bars.alpha = math.floor((this:GetValue()+0.005)*100)/100
		getglobal("BarAlphaSliderText"):SetText(L["Alpha"]..": "..LunaUF.db.profile.bars.alpha)
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame:IsVisible() then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[page].baralphaslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "BOTTOMLEFT", 20, -270)
	LunaOptionsFrame.pages[page].baralphaslider:SetWidth(220)

	LunaOptionsFrame.pages[page].bgbaralphaslider = CreateFrame("Slider", "BgBarAlphaSlider", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].bgbaralphaslider:SetMinMaxValues(0.01,1)
	LunaOptionsFrame.pages[page].bgbaralphaslider:SetValueStep(0.01)
	LunaOptionsFrame.pages[page].bgbaralphaslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.bars.backgroundAlpha = math.floor((this:GetValue()+0.005)*100)/100
		getglobal("BgBarAlphaSliderText"):SetText(L["Background alpha"]..": "..LunaUF.db.profile.bars.backgroundAlpha)
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame:IsVisible() then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[page].bgbaralphaslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "BOTTOMLEFT", 260, -270)
	LunaOptionsFrame.pages[page].bgbaralphaslider:SetWidth(220)

	LunaOptionsFrame.pages[page].framebgheader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].framebgheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -310)
	LunaOptionsFrame.pages[page].framebgheader:SetHeight(24)
	LunaOptionsFrame.pages[page].framebgheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].framebgheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].framebgheader:SetText(L["Frame background"])

	LunaOptionsFrame.pages[page].bgcolor = CreateColorSelect(LunaOptionsFrame.pages[page], LunaUF.db.profile.bgcolor, "BGColor")
	LunaOptionsFrame.pages[page].bgcolor:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].framebgheader, "TOPLEFT", 0, -40)
	LunaOptionsFrame.pages[page].bgcolor:SetHeight(19)
	LunaOptionsFrame.pages[page].bgcolor:SetWidth(19)
	LunaOptionsFrame.pages[page].bgcolor.text:SetText(L["Color"])

	LunaOptionsFrame.pages[page].bgalphaslider = CreateFrame("Slider", "BgAlphaSlider", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].bgalphaslider:SetMinMaxValues(0.01,1)
	LunaOptionsFrame.pages[page].bgalphaslider:SetValueStep(0.01)
	LunaOptionsFrame.pages[page].bgalphaslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.bgalpha = math.floor((this:GetValue()+0.005)*100)/100
		getglobal("BgAlphaSliderText"):SetText(L["Alpha"]..": "..LunaUF.db.profile.bgalpha)
		for _,frame in pairs(LunaUF.Units.frameList) do
			frame:SetBackdropColor(LunaUF.db.profile.bgcolor.r,LunaUF.db.profile.bgcolor.g,LunaUF.db.profile.bgcolor.b,LunaUF.db.profile.bgalpha)
		end
	end)
	LunaOptionsFrame.pages[page].bgalphaslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 200, -350)
	LunaOptionsFrame.pages[page].bgalphaslider:SetWidth(220)

	LunaOptionsFrame.pages[page].blizzheader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].blizzheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -390)
	LunaOptionsFrame.pages[page].blizzheader:SetHeight(24)
	LunaOptionsFrame.pages[page].blizzheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].blizzheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].blizzheader:SetText(L["Blizzard frames"])

	LunaOptionsFrame.pages[page].castbar = CreateFrame("CheckButton", "BlizzCastbar", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].castbar:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -420)
	LunaOptionsFrame.pages[page].castbar:SetHeight(30)
	LunaOptionsFrame.pages[page].castbar:SetWidth(30)
	LunaOptionsFrame.pages[page].castbar:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.castbar = not LunaUF.db.profile.blizzard.castbar
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzCastbarText"):SetText(L["Cast bar"])

	LunaOptionsFrame.pages[page].buffs = CreateFrame("CheckButton", "BlizzBuffs", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].buffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 100, -420)
	LunaOptionsFrame.pages[page].buffs:SetHeight(30)
	LunaOptionsFrame.pages[page].buffs:SetWidth(30)
	LunaOptionsFrame.pages[page].buffs:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.buffs = not LunaUF.db.profile.blizzard.buffs
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzBuffsText"):SetText(L["Buffs"])

	LunaOptionsFrame.pages[page].weaponbuffs = CreateFrame("CheckButton", "BlizzWeaponbuffs", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].weaponbuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 180, -420)
	LunaOptionsFrame.pages[page].weaponbuffs:SetHeight(30)
	LunaOptionsFrame.pages[page].weaponbuffs:SetWidth(30)
	LunaOptionsFrame.pages[page].weaponbuffs:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.weaponbuffs = not LunaUF.db.profile.blizzard.weaponbuffs
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzWeaponbuffsText"):SetText(L["Weaponbuffs"])

	LunaOptionsFrame.pages[page].player = CreateFrame("CheckButton", "BlizzPlayer", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].player:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -460)
	LunaOptionsFrame.pages[page].player:SetHeight(30)
	LunaOptionsFrame.pages[page].player:SetWidth(30)
	LunaOptionsFrame.pages[page].player:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.player = not LunaUF.db.profile.blizzard.player
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzPlayerText"):SetText(L["Player"])

	LunaOptionsFrame.pages[page].pet = CreateFrame("CheckButton", "BlizzPet", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].pet:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 100, -460)
	LunaOptionsFrame.pages[page].pet:SetHeight(30)
	LunaOptionsFrame.pages[page].pet:SetWidth(30)
	LunaOptionsFrame.pages[page].pet:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.pet = not LunaUF.db.profile.blizzard.pet
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzPetText"):SetText(L["Pet"])

	LunaOptionsFrame.pages[page].party = CreateFrame("CheckButton", "BlizzParty", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].party:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 180, -460)
	LunaOptionsFrame.pages[page].party:SetHeight(30)
	LunaOptionsFrame.pages[page].party:SetWidth(30)
	LunaOptionsFrame.pages[page].party:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.party = not LunaUF.db.profile.blizzard.party
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzPartyText"):SetText(L["Party"])

	LunaOptionsFrame.pages[page].target = CreateFrame("CheckButton", "BlizzTarget", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].target:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 260, -460)
	LunaOptionsFrame.pages[page].target:SetHeight(30)
	LunaOptionsFrame.pages[page].target:SetWidth(30)
	LunaOptionsFrame.pages[page].target:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.target = not LunaUF.db.profile.blizzard.target
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzTargetText"):SetText(L["Target"])

	LunaOptionsFrame.pages[page].mouseover = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].mouseover:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -490)
	LunaOptionsFrame.pages[page].mouseover:SetHeight(24)
	LunaOptionsFrame.pages[page].mouseover:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].mouseover:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].mouseover:SetText(L["Mouseover"])

	LunaOptionsFrame.pages[page].mouseovercheck = CreateFrame("CheckButton", "Mouseover3D", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].mouseovercheck:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -520)
	LunaOptionsFrame.pages[page].mouseovercheck:SetHeight(30)
	LunaOptionsFrame.pages[page].mouseovercheck:SetWidth(30)
	LunaOptionsFrame.pages[page].mouseovercheck:SetScript("OnClick", function()
		LunaUF.db.profile.mouseover = not LunaUF.db.profile.mouseover
	end)
	getglobal("Mouseover3DText"):SetText(L["Mouseover in 3D world"])

	LunaOptionsFrame.pages[page].RangeCheck = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].RangeCheck:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -550)
	LunaOptionsFrame.pages[page].RangeCheck:SetHeight(24)
	LunaOptionsFrame.pages[page].RangeCheck:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].RangeCheck:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].RangeCheck:SetText(L["Range"])

	LunaOptionsFrame.pages[page].rangepolling = CreateFrame("Slider", "RangePollingRate", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].rangepolling:SetMinMaxValues(0.5,5)
	LunaOptionsFrame.pages[page].rangepolling:SetValueStep(0.1)
	LunaOptionsFrame.pages[page].rangepolling:SetScript("OnValueChanged", function()
		LunaUF.db.profile.RangePolRate = math.floor((this:GetValue()+0.05)*10)/10
		getglobal("RangePollingRateText"):SetText(L["Polling Rate"]..": "..LunaUF.db.profile.RangePolRate.."s")
	end)
	LunaOptionsFrame.pages[page].rangepolling:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "BOTTOMLEFT", 30, -580)
	LunaOptionsFrame.pages[page].rangepolling:SetWidth(220)

	LunaOptionsFrame.pages[page].rangecl = CreateFrame("CheckButton", "RangeCombatLog", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].rangecl:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 280, -580)
	LunaOptionsFrame.pages[page].rangecl:SetHeight(30)
	LunaOptionsFrame.pages[page].rangecl:SetWidth(30)
	LunaOptionsFrame.pages[page].rangecl:SetScript("OnClick", function()
		LunaUF.db.profile.RangeCLparsing = not LunaUF.db.profile.RangeCLparsing
	end)
	getglobal("RangeCombatLogText"):SetText(L["Enable Combatlog based Range"])

	LunaOptionsFrame.pages[page].enemyCastbar = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].enemyCastbar:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -610)
	LunaOptionsFrame.pages[page].enemyCastbar:SetHeight(24)
	LunaOptionsFrame.pages[page].enemyCastbar:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].enemyCastbar:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].enemyCastbar:SetText(L["Cast bar"])

	LunaOptionsFrame.pages[page].ecast = CreateFrame("CheckButton", "LunaEnemyCastBars", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].ecast:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -640)
	LunaOptionsFrame.pages[page].ecast:SetHeight(30)
	LunaOptionsFrame.pages[page].ecast:SetWidth(30)
	LunaOptionsFrame.pages[page].ecast:SetScript("OnClick", function()
		LunaUF.db.profile.enemyCastbars = not LunaUF.db.profile.enemyCastbars
	end)
	getglobal("LunaEnemyCastBarsText"):SetText(L["Globally disable castbars of others"])

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
						val = LunaUF.db.profile.units["raid"][UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect)].position
						if UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect) ~= 1 and LunaUF.db.profile.units.raid.interlock then
							this:SetText(val.x)
							return
						end
						unit = unit..UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect)
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
						val = LunaUF.db.profile.units["raid"][UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect)].position
						if UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect) ~= 1 and LunaUF.db.profile.units.raid.interlock then
							this:SetText(val.y)
							return
						end
						unit = unit..UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect)
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
						if UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect) ~= 1 and LunaUF.db.profile.units.raid.interlock then
							return
						end
						val = LunaUF.db.profile.units["raid"][UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect)].position
						unit = unit..UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect)
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
						if UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect) ~= 1 and LunaUF.db.profile.units.raid.interlock then
							return
						end
						val = LunaUF.db.profile.units["raid"][UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect)].position
						unit = unit..UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect)
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
						if UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect) ~= 1 and LunaUF.db.profile.units.raid.interlock then
							return
						end
						val = LunaUF.db.profile.units["raid"][UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect)].position
						unit = unit..UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect)
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
						if UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect) ~= 1 and LunaUF.db.profile.units.raid.interlock then
							return
						end
						val = LunaUF.db.profile.units["raid"][UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect)].position
						unit = unit..UIDropDownMenu_GetSelectedID(this:GetParent().GrpSelect)
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

		LunaOptionsFrame.pages[i].bordersHeader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].bordersHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].indicators, "BOTTOMLEFT", 0, 0)
		LunaOptionsFrame.pages[i].bordersHeader:SetHeight(24)
		LunaOptionsFrame.pages[i].bordersHeader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].bordersHeader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].bordersHeader:SetText(L["Borders"])

		LunaOptionsFrame.pages[i].enableBorders = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."Borders", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enableBorders:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].bordersHeader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].enableBorders:SetHeight(30)
		LunaOptionsFrame.pages[i].enableBorders:SetWidth(30)
		LunaOptionsFrame.pages[i].enableBorders:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].borders.enabled = not LunaUF.db.profile.units[unit].borders.enabled
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."BordersText"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].bordersMode = CreateFrame("Button", "BordersMode"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "UIDropDownMenuTemplate")
		LunaOptionsFrame.pages[i].bordersMode:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].bordersHeader, "BOTTOMLEFT", 0 , -50)
		UIDropDownMenu_SetWidth(150, LunaOptionsFrame.pages[i].bordersMode)
		UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[i].bordersMode)

		UIDropDownMenu_Initialize(LunaOptionsFrame.pages[i].bordersMode, function()
			local info={}
			for k,v in pairs({["aggro"] = L["Show aggro"],["dispel"] = L["On dispellable debuff"],["track"] = L["Debuffs to track"]}) do
				info.text= v
				info.value= k
				info.func= function ()
					local dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU)
					local unit = dropdown:GetParent().id
					UIDropDownMenu_SetSelectedValue(dropdown, this.value)
					LunaUF.db.profile.units[unit].borders.mode = UIDropDownMenu_GetSelectedValue(dropdown)
					if this.value == "dispel" then
						dropdown:GetParent().dispelOption:Enable()
					else
						dropdown:GetParent().dispelOption:Disable()
					end
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

		LunaOptionsFrame.pages[i].dispelOption = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."BordersDisp", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].dispelOption:SetPoint("LEFT", LunaOptionsFrame.pages[i].bordersMode, "RIGHT", 20, 0)
		LunaOptionsFrame.pages[i].dispelOption:SetHeight(30)
		LunaOptionsFrame.pages[i].dispelOption:SetWidth(30)
		LunaOptionsFrame.pages[i].dispelOption:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].borders.owndispdebuffs = not LunaUF.db.profile.units[unit].borders.owndispdebuffs
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."BordersDispText"):SetText(L["Only debuffs you can dispel"])

		LunaOptionsFrame.pages[i].faderheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].faderheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].bordersHeader, "BOTTOMLEFT", 0, -90)
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
		LunaOptionsFrame.pages[i].ctextscaleslider:SetMinMaxValues(0.1,2)
		LunaOptionsFrame.pages[i].ctextscaleslider:SetValueStep(0.01)
		LunaOptionsFrame.pages[i].ctextscaleslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].combatText.size = math.floor(this:GetValue()*100)/100
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

		LunaOptionsFrame.pages[i].highlightalphaslider = CreateFrame("Slider", "HighlightAlphaSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].highlightalphaslider:SetMinMaxValues(0.1,0.8)
		LunaOptionsFrame.pages[i].highlightalphaslider:SetValueStep(0.1)
		LunaOptionsFrame.pages[i].highlightalphaslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].highlight.alpha = math.floor((this:GetValue()*10)+0.05)/10
			getglobal("HighlightAlphaSlider"..unit.."Text"):SetText(L["Alpha"]..": "..LunaUF.db.profile.units[unit].highlight.alpha)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].highlightalphaslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].highlightheader, "BOTTOMLEFT", 280, -10)
		LunaOptionsFrame.pages[i].highlightalphaslider:SetWidth(190)

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
					local page = dropdown:GetParent()
					local unit = page.id
					UIDropDownMenu_SetSelectedValue(dropdown, this.value)
					LunaUF.db.profile.units[unit].healthBar.colorType = UIDropDownMenu_GetSelectedValue(dropdown)

					if LunaUF.db.profile.units[unit].healthBar.colorType == "class" then
						page.classGradient:Enable()
					else
						LunaUF.db.profile.units[unit].healthBar.classGradient = false
						page.classGradient:SetChecked(false)
						page.classGradient:Disable()
					end

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

		LunaOptionsFrame.pages[i].reverseHealth = CreateFrame("CheckButton", "Reverse"..LunaUF.unitList[i-1].."Health", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].reverseHealth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healthheader, "BOTTOMLEFT", 180, -50)
		LunaOptionsFrame.pages[i].reverseHealth:SetHeight(30)
		LunaOptionsFrame.pages[i].reverseHealth:SetWidth(30)
		LunaOptionsFrame.pages[i].reverseHealth:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].healthBar.reverse = not LunaUF.db.profile.units[unit].healthBar.reverse
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		getglobal("Reverse"..LunaUF.unitList[i-1].."Health".."Text"):SetText(L["Reverse"])

		LunaOptionsFrame.pages[i].classGradient = CreateFrame("CheckButton", "ClassGradient"..LunaUF.unitList[i-1].."Health", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].classGradient:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healthheader, "BOTTOMLEFT", 270, -50)
		LunaOptionsFrame.pages[i].classGradient:SetHeight(30)
		LunaOptionsFrame.pages[i].classGradient:SetWidth(30)
		LunaOptionsFrame.pages[i].classGradient:SetScript("OnClick", function()
			local unit = this:GetParent().id
			if LunaUF.db.profile.units[unit].healthBar.colorType == "class" then
				LunaUF.db.profile.units[unit].healthBar.classGradient = not LunaUF.db.profile.units[unit].healthBar.classGradient
			end

			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		do
			local unit = LunaOptionsFrame.pages[i].id
			if LunaUF.db.profile.units[unit].healthBar.colorType == 'class' then
				LunaOptionsFrame.pages[i].classGradient:Enable()
			else
				LunaOptionsFrame.pages[i].classGradient:Disable()
			end
		end
		getglobal("ClassGradient"..LunaUF.unitList[i-1].."Health".."Text"):SetText(L["Class Gradient"])

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

		LunaOptionsFrame.pages[i].reversePower = CreateFrame("CheckButton", "Reverse"..LunaUF.unitList[i-1].."Power", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].reversePower:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].powerheader, "BOTTOMLEFT", 0, -90)
		LunaOptionsFrame.pages[i].reversePower:SetHeight(30)
		LunaOptionsFrame.pages[i].reversePower:SetWidth(30)
		LunaOptionsFrame.pages[i].reversePower:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].powerBar.reverse = not LunaUF.db.profile.units[unit].powerBar.reverse
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		getglobal("Reverse"..LunaUF.unitList[i-1].."Power".."Text"):SetText(L["Reverse"])

		LunaOptionsFrame.pages[i].emptyheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].emptyheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].powerheader, "BOTTOMLEFT", 0, -140)
		LunaOptionsFrame.pages[i].emptyheader:SetHeight(24)
		LunaOptionsFrame.pages[i].emptyheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].emptyheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].emptyheader:SetText(L["Empty Bar"])

		LunaOptionsFrame.pages[i].enableempty = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."Empty", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enableempty:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].emptyheader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].enableempty:SetHeight(30)
		LunaOptionsFrame.pages[i].enableempty:SetWidth(30)
		LunaOptionsFrame.pages[i].enableempty:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].emptyBar.enabled = not LunaUF.db.profile.units[unit].emptyBar.enabled
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Enable"..LunaUF.unitList[i-1].."EmptyText"):SetText(L["Enable"])

		LunaOptionsFrame.pages[i].emptysizeslider = CreateFrame("Slider", "EmptySizeSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].emptysizeslider:SetMinMaxValues(1,10)
		LunaOptionsFrame.pages[i].emptysizeslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].emptysizeslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].emptyBar.size = math.floor(this:GetValue())
			getglobal("EmptySizeSlider"..unit.."Text"):SetText(L["Size"]..": "..LunaUF.db.profile.units[unit].emptyBar.size)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:PositionWidgets(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].emptysizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].emptyheader, "BOTTOMLEFT", 280, -10)
		LunaOptionsFrame.pages[i].emptysizeslider:SetWidth(190)

		LunaOptionsFrame.pages[i].castheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].castheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].emptyheader, "BOTTOMLEFT", 0, -60)
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
		getglobal("Enable"..LunaUF.unitList[i-1].."CastText"):SetText(L["Enable"])

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

		LunaOptionsFrame.pages[i].reverseCast = CreateFrame("CheckButton", "Reverse"..LunaUF.unitList[i-1].."Cast", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].reverseCast:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].castheader, "BOTTOMLEFT", 170, -50)
		LunaOptionsFrame.pages[i].reverseCast:SetHeight(30)
		LunaOptionsFrame.pages[i].reverseCast:SetWidth(30)
		LunaOptionsFrame.pages[i].reverseCast:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].castBar.reverse = not LunaUF.db.profile.units[unit].castBar.reverse
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		getglobal("Reverse"..LunaUF.unitList[i-1].."Cast".."Text"):SetText(L["Reverse"])

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

		if LunaUF.unitList[i-1] ~= "pettarget" then
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
		end

		LunaOptionsFrame.pages[i].auraheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].auraheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healheader or LunaOptionsFrame.pages[i].castheader, "BOTTOMLEFT", 0, LunaOptionsFrame.pages[i].healheader and -60 or -90)
		LunaOptionsFrame.pages[i].auraheader:SetHeight(24)
		LunaOptionsFrame.pages[i].auraheader:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[i].auraheader:SetTextColor(1,1,0)
		LunaOptionsFrame.pages[i].auraheader:SetText(L["Auras"])

		LunaOptionsFrame.pages[i].showbuffs = CreateFrame("CheckButton", "Show"..LunaUF.unitList[i-1].."Buffs", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].showbuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].auraheader, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].showbuffs:SetHeight(30)
		LunaOptionsFrame.pages[i].showbuffs:SetWidth(30)
		LunaOptionsFrame.pages[i].showbuffs:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].auras.buffs = not LunaUF.db.profile.units[unit].auras.buffs
			if LunaUF.db.profile.units[unit].auras.buffs or LunaUF.db.profile.units[unit].auras.debuffs then
				LunaUF.db.profile.units[unit].auras.enabled = true
			else
				LunaUF.db.profile.units[unit].auras.enabled = nil
			end
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Show"..LunaUF.unitList[i-1].."Buffs".."Text"):SetText(L["Buffs"])

		LunaOptionsFrame.pages[i].buffposition = CreateFrame("Button", "BuffPosition"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "UIDropDownMenuTemplate")
		LunaOptionsFrame.pages[i].buffposition:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].showbuffs, "BOTTOMLEFT", 100 , 30)
		UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[i].buffposition)
		UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[i].buffposition)

		UIDropDownMenu_Initialize(LunaOptionsFrame.pages[i].buffposition, function()
			local info={}
			for k,v in pairs({["TOP"]=L["TOP"],["BOTTOM"]=L["BOTTOM"],["LEFT"]=L["LEFT"],["RIGHT"]=L["RIGHT"]}) do
				info.text=v
				info.value=k
				info.func= function ()
					local dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU)
					local unit = dropdown:GetParent().id
					UIDropDownMenu_SetSelectedValue(dropdown, this.value)
					LunaUF.db.profile.units[unit].auras.buffpos = UIDropDownMenu_GetSelectedValue(dropdown)
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

		LunaOptionsFrame.pages[i].BuffPosDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		LunaOptionsFrame.pages[i].BuffPosDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[i].buffposition, "TOP", 0, 0)
		LunaOptionsFrame.pages[i].BuffPosDesc:SetText(L["Side"])

		LunaOptionsFrame.pages[i].buffsizeslider = CreateFrame("Slider", "BuffSizeSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].buffsizeslider:SetMinMaxValues(10,50)
		LunaOptionsFrame.pages[i].buffsizeslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].buffsizeslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].auras.buffsize = math.floor(this:GetValue())
			getglobal("BuffSizeSlider"..unit.."Text"):SetText(L["Size"]..": "..LunaUF.db.profile.units[unit].auras.buffsize)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].buffsizeslider:SetPoint("LEFT", LunaOptionsFrame.pages[i].showbuffs, "RIGHT", 190, 0)
		LunaOptionsFrame.pages[i].buffsizeslider:SetWidth(120)

		LunaOptionsFrame.pages[i].bigbuffsizeslider = CreateFrame("Slider", "BigBuffSizeSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].bigbuffsizeslider:SetMinMaxValues(0,20)
		LunaOptionsFrame.pages[i].bigbuffsizeslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].bigbuffsizeslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].auras.enlargedbuffsize = math.floor(this:GetValue())
			getglobal("BigBuffSizeSlider"..unit.."Text"):SetText(L["Big Size"]..": "..LunaUF.db.profile.units[unit].auras.enlargedbuffsize)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].bigbuffsizeslider:SetPoint("LEFT", LunaOptionsFrame.pages[i].buffsizeslider, "RIGHT", 10, 0)
		LunaOptionsFrame.pages[i].bigbuffsizeslider:SetWidth(120)

		LunaOptionsFrame.pages[i].showdebuffs = CreateFrame("CheckButton", "Show"..LunaUF.unitList[i-1].."Debuffs", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].showdebuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].showbuffs, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].showdebuffs:SetHeight(30)
		LunaOptionsFrame.pages[i].showdebuffs:SetWidth(30)
		LunaOptionsFrame.pages[i].showdebuffs:SetScript("OnClick", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].auras.debuffs = not LunaUF.db.profile.units[unit].auras.debuffs
			if LunaUF.db.profile.units[unit].auras.buffs or LunaUF.db.profile.units[unit].auras.debuffs then
				LunaUF.db.profile.units[unit].auras.enabled = true
			else
				LunaUF.db.profile.units[unit].auras.enabled = nil
			end
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		getglobal("Show"..LunaUF.unitList[i-1].."Debuffs".."Text"):SetText(L["Enable debuffs"])

		LunaOptionsFrame.pages[i].debuffposition = CreateFrame("Button", "DebuffPosition"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "UIDropDownMenuTemplate")
		LunaOptionsFrame.pages[i].debuffposition:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].showdebuffs, "BOTTOMLEFT", 100 , 30)
		UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[i].debuffposition)
		UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[i].debuffposition)

		UIDropDownMenu_Initialize(LunaOptionsFrame.pages[i].debuffposition, function()
			local info={}
			for k,v in pairs({["TOP"]=L["TOP"],["BOTTOM"]=L["BOTTOM"],["LEFT"]=L["LEFT"],["RIGHT"]=L["RIGHT"]}) do
				info.text=v
				info.value=k
				info.func= function ()
					local dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU)
					local unit = dropdown:GetParent().id
					UIDropDownMenu_SetSelectedValue(dropdown, this.value)
					LunaUF.db.profile.units[unit].auras.debuffpos = UIDropDownMenu_GetSelectedValue(dropdown)
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

		LunaOptionsFrame.pages[i].DebuffPosDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		LunaOptionsFrame.pages[i].DebuffPosDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[i].debuffposition, "TOP", 0, 0)
		LunaOptionsFrame.pages[i].DebuffPosDesc:SetText(L["Side"])

		LunaOptionsFrame.pages[i].debuffsizeslider = CreateFrame("Slider", "DebuffSizeSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].debuffsizeslider:SetMinMaxValues(10,50)
		LunaOptionsFrame.pages[i].debuffsizeslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].debuffsizeslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].auras.debuffsize = math.floor(this:GetValue())
			getglobal("DebuffSizeSlider"..unit.."Text"):SetText(L["Size"]..": "..LunaUF.db.profile.units[unit].auras.debuffsize)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].debuffsizeslider:SetPoint("LEFT", LunaOptionsFrame.pages[i].showdebuffs, "RIGHT", 190, 0)
		LunaOptionsFrame.pages[i].debuffsizeslider:SetWidth(120)

		LunaOptionsFrame.pages[i].bigdebuffsizeslider = CreateFrame("Slider", "BigDebuffSizeSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].bigdebuffsizeslider:SetMinMaxValues(0,20)
		LunaOptionsFrame.pages[i].bigdebuffsizeslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].bigdebuffsizeslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].auras.enlargeddebuffsize = math.floor(this:GetValue())
			getglobal("BigDebuffSizeSlider"..unit.."Text"):SetText(L["Big Size"]..": "..LunaUF.db.profile.units[unit].auras.enlargeddebuffsize)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].bigdebuffsizeslider:SetPoint("LEFT", LunaOptionsFrame.pages[i].debuffsizeslider, "RIGHT", 10, 0)
		LunaOptionsFrame.pages[i].bigdebuffsizeslider:SetWidth(120)

		LunaOptionsFrame.pages[i].enablebordercolor = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."BorderColor", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
		LunaOptionsFrame.pages[i].enablebordercolor:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].showdebuffs, "BOTTOMLEFT", 0, -10)
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

		LunaOptionsFrame.pages[i].aurapaddingslider = CreateFrame("Slider", "AuraPaddingSlider"..LunaUF.unitList[i-1], LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].aurapaddingslider:SetMinMaxValues(0,10)
		LunaOptionsFrame.pages[i].aurapaddingslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].aurapaddingslider:SetScript("OnValueChanged", function()
			local unit = this:GetParent().id
			LunaUF.db.profile.units[unit].auras.padding = math.floor(this:GetValue())
			getglobal("AuraPaddingSlider"..unit.."Text"):SetText(L["Padding"]..": "..LunaUF.db.profile.units[unit].auras.padding)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units.FullUpdate(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].aurapaddingslider:SetPoint("LEFT", LunaOptionsFrame.pages[i].enablebordercolor, "RIGHT", 190, 0)
		LunaOptionsFrame.pages[i].aurapaddingslider:SetWidth(120)

		LunaOptionsFrame.pages[i].EmphasizeDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].EmphasizeDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].enablebordercolor, "BOTTOMLEFT", 200, -20)
		LunaOptionsFrame.pages[i].EmphasizeDesc:SetText(L["Emphasize"])

		LunaOptionsFrame.pages[i].EmphasizeBuffsInput = CreateFrame("Editbox", "EmphasizeBuffsInput"..i, LunaOptionsFrame.pages[i], "InputBoxTemplate")
		LunaOptionsFrame.pages[i].EmphasizeBuffsInput:SetHeight(20)
		LunaOptionsFrame.pages[i].EmphasizeBuffsInput:SetWidth(150)
		LunaOptionsFrame.pages[i].EmphasizeBuffsInput:SetAutoFocus(nil)
		LunaOptionsFrame.pages[i].EmphasizeBuffsInput:SetPoint("TOP", LunaOptionsFrame.pages[i].EmphasizeDesc, "BOTTOM", -125, -20)
		LunaOptionsFrame.pages[i].EmphasizeBuffsInput:SetScript("OnEnterPressed", function()
			this:ClearFocus()
		end)

		LunaOptionsFrame.pages[i].EmphasizeBuffsDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		LunaOptionsFrame.pages[i].EmphasizeBuffsDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[i].EmphasizeBuffsInput, "TOP", 0, 5)
		LunaOptionsFrame.pages[i].EmphasizeBuffsDesc:SetText(L["Buffs"])

		LunaOptionsFrame.pages[i].EmphasizeBuffsAdd = CreateFrame("Button", "EmphasizeBuffsAddButton"..i, LunaOptionsFrame.pages[i], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[i].EmphasizeBuffsAdd:SetPoint("LEFT", LunaOptionsFrame.pages[i].EmphasizeBuffsInput, "RIGHT", 0, 0)
		LunaOptionsFrame.pages[i].EmphasizeBuffsAdd:SetHeight(20)
		LunaOptionsFrame.pages[i].EmphasizeBuffsAdd:SetWidth(50)
		LunaOptionsFrame.pages[i].EmphasizeBuffsAdd:SetText(L["Add"])
		LunaOptionsFrame.pages[i].EmphasizeBuffsAdd:SetScript("OnClick", function ()
			local parent = this:GetParent()
			local buffname = parent.EmphasizeBuffsInput:GetText()
			if buffname and buffname ~= "" then
				parent.EmphasizeBuffsBG.config[buffname] = true
				parent.EmphasizeBuffsInput:SetText("")
				parent.EmphasizeBuffsInput:ClearFocus()
				RefreshAuraWindow(parent.EmphasizeBuffsBG.controls, parent.EmphasizeBuffsBG.config, parent.EmphasizeBuffsBG.slot)
				for _,frame in pairs(LunaUF.Units.frameList) do
					if frame.unitGroup == parent.id then
						LunaUF.Units.FullUpdate(frame)
					end
				end
			end
		end)

		LunaOptionsFrame.pages[i].EmphasizeBuffsBG = CreateFrame("Frame", "EmphasizeBuffsBG", LunaOptionsFrame.pages[i])
		LunaOptionsFrame.pages[i].EmphasizeBuffsBG:SetHeight(60)
		LunaOptionsFrame.pages[i].EmphasizeBuffsBG:SetWidth(175)
		LunaOptionsFrame.pages[i].EmphasizeBuffsBG:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].EmphasizeBuffsInput, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].EmphasizeBuffsBG:SetBackdrop(LunaUF.constants.backdrop)
		LunaOptionsFrame.pages[i].EmphasizeBuffsBG:SetBackdropColor(0,0,0,1)
		LunaOptionsFrame.pages[i].EmphasizeBuffsBG.config = LunaUF.db.profile.units[LunaUF.unitList[i-1]].auras.emphasizeAuras.buffs
		LunaOptionsFrame.pages[i].EmphasizeBuffsBG.slot = 1

		LunaOptionsFrame.pages[i].EmphasizeBuffsUp = CreateFrame("Button", "EmphasizeBuffsUpButton"..i, LunaOptionsFrame.pages[i], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[i].EmphasizeBuffsUp:SetPoint("BOTTOMLEFT", LunaOptionsFrame.pages[i].EmphasizeBuffsBG, "RIGHT", 2, 5)
		LunaOptionsFrame.pages[i].EmphasizeBuffsUp:SetHeight(20)
		LunaOptionsFrame.pages[i].EmphasizeBuffsUp:SetWidth(20)
		LunaOptionsFrame.pages[i].EmphasizeBuffsUp:SetText("^")
		LunaOptionsFrame.pages[i].EmphasizeBuffsUp.config = LunaUF.db.profile.units[LunaUF.unitList[i-1]].auras.emphasizeAuras.buffs
		LunaOptionsFrame.pages[i].EmphasizeBuffsUp:SetScript("OnClick", function ()
			local config = this:GetParent().EmphasizeBuffsBG
			if config.slot > 1 then
				config.slot = config.slot - 1
			end
			RefreshAuraWindow(config.controls, config.config, config.slot)
		end)

		LunaOptionsFrame.pages[i].EmphasizeBuffsDown = CreateFrame("Button", "EmphasizeBuffsDownButton"..i, LunaOptionsFrame.pages[i], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[i].EmphasizeBuffsDown:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].EmphasizeBuffsBG, "RIGHT", 2, -5)
		LunaOptionsFrame.pages[i].EmphasizeBuffsDown:SetHeight(20)
		LunaOptionsFrame.pages[i].EmphasizeBuffsDown:SetWidth(20)
		LunaOptionsFrame.pages[i].EmphasizeBuffsDown:SetText("v")
		LunaOptionsFrame.pages[i].EmphasizeBuffsDown.config = LunaUF.db.profile.units[LunaUF.unitList[i-1]].auras.emphasizeAuras.buffs
		LunaOptionsFrame.pages[i].EmphasizeBuffsDown:SetScript("OnClick", function ()
			local config, k = this:GetParent().EmphasizeBuffsBG, 0
			for _ in pairs(config.config) do
				k = k + 1
			end
			if k >= (config.slot+3) then
				config.slot = config.slot + 1
			end
			RefreshAuraWindow(config.controls, config.config, config.slot)
		end)

		LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls = {}
		for k=1,3 do
			LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[k] = {}
			LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[k][1] = LunaOptionsFrame.pages[i].EmphasizeBuffsBG:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[k][1]:SetText("<TESTVALUE>")
			LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[k][2] = CreateFrame("Button", "EmphasizeBuffsDeleteButton"..i..k, LunaOptionsFrame.pages[i].EmphasizeBuffsBG, "UIPanelButtonTemplate")
			LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[k][2]:SetHeight(20)
			LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[k][2]:SetWidth(20)
			LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[k][2]:SetText("-")
			LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[k][2].config = LunaOptionsFrame.pages[i].EmphasizeBuffsBG
			LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[k][2].id = k
			LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[k][2]:SetScript("OnClick", function ()
				local buffname = this.config.controls[this.id][1]:GetText()
				local parent = this:GetParent():GetParent()
				this.config.config[buffname] = nil
				this.config.slot = 1
				RefreshAuraWindow(this.config.controls, this.config.config, 1)
				for _,frame in pairs(LunaUF.Units.frameList) do
					if frame.unitGroup == parent.id then
						LunaUF.Units.FullUpdate(frame)
					end
				end
			end)
		end

		LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[1][1]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].EmphasizeBuffsBG, "TOPLEFT", 5, -5)
		LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[1][2]:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[i].EmphasizeBuffsBG, "TOPRIGHT", 0, 0)
		LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[2][1]:SetPoint("LEFT", LunaOptionsFrame.pages[i].EmphasizeBuffsBG, "LEFT", 5, 0)
		LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[2][2]:SetPoint("RIGHT", LunaOptionsFrame.pages[i].EmphasizeBuffsBG, "RIGHT", 0, 0)
		LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[3][1]:SetPoint("BOTTOMLEFT", LunaOptionsFrame.pages[i].EmphasizeBuffsBG, "BOTTOMLEFT", 5, 5)
		LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls[3][2]:SetPoint("BOTTOMRIGHT", LunaOptionsFrame.pages[i].EmphasizeBuffsBG, "BOTTOMRIGHT", 0, 0)

		LunaOptionsFrame.pages[i].EmphasizeDebuffsInput = CreateFrame("Editbox", "EmphasizeDebuffsInput"..i, LunaOptionsFrame.pages[i], "InputBoxTemplate")
		LunaOptionsFrame.pages[i].EmphasizeDebuffsInput:SetHeight(20)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsInput:SetWidth(150)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsInput:SetAutoFocus(nil)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsInput:SetPoint("TOP", LunaOptionsFrame.pages[i].EmphasizeDesc, "BOTTOM", 100, -20)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsInput:SetScript("OnEnterPressed", function()
			this:ClearFocus()
		end)

		LunaOptionsFrame.pages[i].EmphasizeDebuffsDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		LunaOptionsFrame.pages[i].EmphasizeDebuffsDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[i].EmphasizeDebuffsInput, "TOP", 0, 5)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsDesc:SetText(L["Debuffs"])

		LunaOptionsFrame.pages[i].EmphasizeDebuffsAdd = CreateFrame("Button", "EmphasizeDebuffsAddButton"..i, LunaOptionsFrame.pages[i], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[i].EmphasizeDebuffsAdd:SetPoint("LEFT", LunaOptionsFrame.pages[i].EmphasizeDebuffsInput, "RIGHT", 0, 0)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsAdd:SetHeight(20)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsAdd:SetWidth(50)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsAdd:SetText(L["Add"])
		LunaOptionsFrame.pages[i].EmphasizeDebuffsAdd.config = LunaUF.db.profile.units[LunaUF.unitList[i-1]].auras.emphasizeAuras.debuffs
		LunaOptionsFrame.pages[i].EmphasizeDebuffsAdd:SetScript("OnClick", function ()
			local parent = this:GetParent()
			local debuffname = parent.EmphasizeDebuffsInput:GetText()
			if debuffname and debuffname ~= "" then
				this.config[debuffname] = true
				parent.EmphasizeDebuffsInput:SetText("")
				parent.EmphasizeDebuffsInput:ClearFocus()
				RefreshAuraWindow(parent.EmphasizeDebuffsBG.controls, parent.EmphasizeDebuffsBG.config, parent.EmphasizeDebuffsBG.slot)
				for _,frame in pairs(LunaUF.Units.frameList) do
					if frame.unitGroup == parent.id then
						LunaUF.Units.FullUpdate(frame)
					end
				end
			end
		end)

		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG = CreateFrame("Frame", "EmphasizeDebuffsBG", LunaOptionsFrame.pages[i])
		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG:SetHeight(60)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG:SetWidth(175)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].EmphasizeDebuffsInput, "BOTTOMLEFT", 0, -10)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG:SetBackdrop(LunaUF.constants.backdrop)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG:SetBackdropColor(0,0,0,1)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.config = LunaUF.db.profile.units[LunaUF.unitList[i-1]].auras.emphasizeAuras.debuffs
		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.slot = 1

		LunaOptionsFrame.pages[i].EmphasizeDebuffsUp = CreateFrame("Button", "EmphasizeDebuffsUpButton"..i, LunaOptionsFrame.pages[i], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[i].EmphasizeDebuffsUp:SetPoint("BOTTOMLEFT", LunaOptionsFrame.pages[i].EmphasizeDebuffsBG, "RIGHT", 2, 5)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsUp:SetHeight(20)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsUp:SetWidth(20)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsUp:SetText("^")
		LunaOptionsFrame.pages[i].EmphasizeDebuffsUp.config = LunaUF.db.profile.units[LunaUF.unitList[i-1]].auras.emphasizeAuras.debuffs
		LunaOptionsFrame.pages[i].EmphasizeDebuffsUp:SetScript("OnClick", function ()
			local config = this:GetParent().EmphasizeDebuffsBG
			if config.slot > 1 then
				config.slot = config.slot - 1
			end
			RefreshAuraWindow(config.controls, config.config, config.slot)
		end)

		LunaOptionsFrame.pages[i].EmphasizeDebuffsDown = CreateFrame("Button", "EmphasizeDebuffsDownButton"..i, LunaOptionsFrame.pages[i], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[i].EmphasizeDebuffsDown:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].EmphasizeDebuffsBG, "RIGHT", 2, -5)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsDown:SetHeight(20)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsDown:SetWidth(20)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsDown:SetText("v")
		LunaOptionsFrame.pages[i].EmphasizeDebuffsDown.config = LunaUF.db.profile.units[LunaUF.unitList[i-1]].auras.emphasizeAuras.debuffs
		LunaOptionsFrame.pages[i].EmphasizeDebuffsDown:SetScript("OnClick", function ()
			local config, k = this:GetParent().EmphasizeDebuffsBG, 0
			for _ in pairs(config.config) do
				k = k + 1
			end
			if k >= (config.slot+3) then
				config.slot = config.slot + 1
			end
			RefreshAuraWindow(config.controls, config.config, config.slot)
		end)

		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls = {}
		for k=1,3 do
			LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[k] = {}
			LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[k][1] = LunaOptionsFrame.pages[i].EmphasizeDebuffsBG:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[k][1]:SetText("<TESTVALUE>")
			LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[k][2] = CreateFrame("Button", "EmphasizeDebuffsDeleteButton"..i..k, LunaOptionsFrame.pages[i].EmphasizeDebuffsBG, "UIPanelButtonTemplate")
			LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[k][2]:SetHeight(20)
			LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[k][2]:SetWidth(20)
			LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[k][2]:SetText("-")
			LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[k][2].config = LunaOptionsFrame.pages[i].EmphasizeDebuffsBG
			LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[k][2].id = k
			LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[k][2]:SetScript("OnClick", function ()
				local buffname = this.config.controls[this.id][1]:GetText()
				local parent = this:GetParent():GetParent()
				this.config.config[buffname] = nil
				this.config.slot = 1
				RefreshAuraWindow(this.config.controls, this.config.config, 1)
				for _,frame in pairs(LunaUF.Units.frameList) do
					if frame.unitGroup == parent.id then
						LunaUF.Units.FullUpdate(frame)
					end
				end
			end)
		end

		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[1][1]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].EmphasizeDebuffsBG, "TOPLEFT", 5, -5)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[1][2]:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[i].EmphasizeDebuffsBG, "TOPRIGHT", 0, 0)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[2][1]:SetPoint("LEFT", LunaOptionsFrame.pages[i].EmphasizeDebuffsBG, "LEFT", 5, 0)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[2][2]:SetPoint("RIGHT", LunaOptionsFrame.pages[i].EmphasizeDebuffsBG, "RIGHT", 0, 0)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[3][1]:SetPoint("BOTTOMLEFT", LunaOptionsFrame.pages[i].EmphasizeDebuffsBG, "BOTTOMLEFT", 5, 5)
		LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls[3][2]:SetPoint("BOTTOMRIGHT", LunaOptionsFrame.pages[i].EmphasizeDebuffsBG, "BOTTOMRIGHT", 0, 0)

		--RefreshAuraWindow(LunaOptionsFrame.pages[i].EmphasizeBuffsBG.controls, LunaOptionsFrame.pages[i].EmphasizeBuffsBG.config, LunaOptionsFrame.pages[i].EmphasizeBuffsBG.slot)
		--RefreshAuraWindow(LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.controls, LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.config, LunaOptionsFrame.pages[i].EmphasizeDebuffsBG.slot)

		if (LunaUF.unitList[i-1] == "player") then
			LunaOptionsFrame.pages[i].enableaurastimertext = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."AurasTimerText", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
			LunaOptionsFrame.pages[i].enableaurastimertext:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].EmphasizeBuffsBG, "BOTTOMLEFT", -30, -20)
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
			LunaOptionsFrame.pages[i].auratimertextbigfontsizeslider:SetMinMaxValues(1,18)
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
			LunaOptionsFrame.pages[i].auratimertextsmallfontsizeslider:SetMinMaxValues(1,18)
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

			LunaOptionsFrame.pages[i].wbuffs = CreateFrame("CheckButton", "Enable"..LunaUF.unitList[i-1].."WBuffs", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
			LunaOptionsFrame.pages[i].wbuffs:SetPoint("LEFT", LunaOptionsFrame.pages[i].enableaurastimerspin, "RIGHT", 100, 0)
			LunaOptionsFrame.pages[i].wbuffs:SetHeight(30)
			LunaOptionsFrame.pages[i].wbuffs:SetWidth(30)
			LunaOptionsFrame.pages[i].wbuffs:SetScript("OnClick", function()
				local unit = this:GetParent().id
				LunaUF.db.profile.units[unit].auras.weaponbuffs = not LunaUF.db.profile.units[unit].auras.weaponbuffs
				for _,frame in pairs(LunaUF.Units.frameList) do
					if frame.unitGroup == unit then
						LunaUF.Units.FullUpdate(frame)
					end
				end
			end)
			getglobal("Enable"..LunaUF.unitList[i-1].."WBuffs".."Text"):SetText(L["Weaponbuffs"])
		end

		LunaOptionsFrame.pages[i].tagheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].tagheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].enableaurastimertext or LunaOptionsFrame.pages[i].auraheader, "BOTTOMLEFT", 0, LunaOptionsFrame.pages[i].enableaurastimertext and -60 or -250)
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

	local page = 2
	LunaOptionsFrame.pages[page].ticker = CreateFrame("CheckButton", "TickerplayerPower", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].ticker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].powerheader, "BOTTOMLEFT", 180, -50)
	LunaOptionsFrame.pages[page].ticker:SetHeight(30)
	LunaOptionsFrame.pages[page].ticker:SetWidth(30)
	LunaOptionsFrame.pages[page].ticker:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].powerBar.ticker = not LunaUF.db.profile.units[unit].powerBar.ticker
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("TickerplayerPowerText"):SetText(L["Energy / mp5 ticker"])

	LunaOptionsFrame.pages[page].manausage = CreateFrame("CheckButton", "ManaUsage", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].manausage:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].powerheader, "BOTTOMLEFT", 320, -50)
	LunaOptionsFrame.pages[page].manausage:SetHeight(30)
	LunaOptionsFrame.pages[page].manausage:SetWidth(30)
	LunaOptionsFrame.pages[page].manausage:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units.player.powerBar.manaUsage = not LunaUF.db.profile.units.player.powerBar.manaUsage
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("ManaUsageText"):SetText(L["Show Mana Usage"])

	LunaOptionsFrame.pages[page].totemheader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].totemheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].barorder, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[page].totemheader:SetHeight(24)
	LunaOptionsFrame.pages[page].totemheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].totemheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].totemheader:SetText(L["Totem Bar"])

	LunaOptionsFrame.pages[page].enabletotem = CreateFrame("CheckButton", "EnableplayerTotems", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].enabletotem:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].totemheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].enabletotem:SetHeight(30)
	LunaOptionsFrame.pages[page].enabletotem:SetWidth(30)
	LunaOptionsFrame.pages[page].enabletotem:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].totemBar.enabled = not LunaUF.db.profile.units[unit].totemBar.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableplayerTotemsText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[page].totemhide = CreateFrame("CheckButton", "TotemsplayerHide", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].totemhide:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].totemheader, "BOTTOMLEFT", 80, -10)
	LunaOptionsFrame.pages[page].totemhide:SetHeight(30)
	LunaOptionsFrame.pages[page].totemhide:SetWidth(30)
	LunaOptionsFrame.pages[page].totemhide:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].totemBar.hide = not LunaUF.db.profile.units[unit].totemBar.hide
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("TotemsplayerHideText"):SetText(L["hide"])

	LunaOptionsFrame.pages[page].totemsizeslider = CreateFrame("Slider", "TotemsSizeSlidertarget", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].totemsizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[page].totemsizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[page].totemsizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.player.totemBar.size = math.floor(this:GetValue())
		getglobal("TotemsSizeSlidertargetText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.player.totemBar.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.player)
	end)
	LunaOptionsFrame.pages[page].totemsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].totemheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[page].totemsizeslider:SetWidth(190)

	LunaOptionsFrame.pages[page].druidheader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].druidheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].totemheader, "BOTTOMLEFT", 0, -60)
	LunaOptionsFrame.pages[page].druidheader:SetHeight(24)
	LunaOptionsFrame.pages[page].druidheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].druidheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].druidheader:SetText(L["Druid Bar"])

	LunaOptionsFrame.pages[page].enabledruid = CreateFrame("CheckButton", "EnableplayerDruid", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].enabledruid:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].druidheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].enabledruid:SetHeight(30)
	LunaOptionsFrame.pages[page].enabledruid:SetWidth(30)
	LunaOptionsFrame.pages[page].enabledruid:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].druidBar.enabled = not LunaUF.db.profile.units[unit].druidBar.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableplayerDruidText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[page].druidsizeslider = CreateFrame("Slider", "DruidSizeSlidertarget", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].druidsizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[page].druidsizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[page].druidsizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.player.druidBar.size = math.floor(this:GetValue())
		getglobal("DruidSizeSlidertargetText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.player.druidBar.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.player)
	end)
	LunaOptionsFrame.pages[page].druidsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].druidheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[page].druidsizeslider:SetWidth(190)

	LunaOptionsFrame.pages[page].xpheader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].xpheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].druidheader, "BOTTOMLEFT", 0, -60)
	LunaOptionsFrame.pages[page].xpheader:SetHeight(24)
	LunaOptionsFrame.pages[page].xpheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].xpheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].xpheader:SetText(L["XP Bar"])

	LunaOptionsFrame.pages[page].enablexp = CreateFrame("CheckButton", "EnableplayerXP", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].enablexp:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].xpheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].enablexp:SetHeight(30)
	LunaOptionsFrame.pages[page].enablexp:SetWidth(30)
	LunaOptionsFrame.pages[page].enablexp:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units.player.xpBar.enabled = not LunaUF.db.profile.units.player.xpBar.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableplayerXPText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[page].xpsizeslider = CreateFrame("Slider", "XPSizeSliderplayer", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].xpsizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[page].xpsizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[page].xpsizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.player.xpBar.size = math.floor(this:GetValue())
		getglobal("XPSizeSliderplayerText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.player.xpBar.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.player)
	end)
	LunaOptionsFrame.pages[page].xpsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].xpheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[page].xpsizeslider:SetWidth(190)

	LunaOptionsFrame.pages[page].reckheader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].reckheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].xpheader, "BOTTOMLEFT", 0, -60)
	LunaOptionsFrame.pages[page].reckheader:SetHeight(24)
	LunaOptionsFrame.pages[page].reckheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].reckheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].reckheader:SetText(L["Reckoning Stacks"])

	LunaOptionsFrame.pages[page].enablereck = CreateFrame("CheckButton", "EnableReckStacks", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].enablereck:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].reckheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].enablereck:SetHeight(30)
	LunaOptionsFrame.pages[page].enablereck:SetWidth(30)
	LunaOptionsFrame.pages[page].enablereck:SetScript("OnClick", function()
		LunaUF.db.profile.units.player.reckStacks.enabled = not LunaUF.db.profile.units.player.reckStacks.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "player" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableReckStacksText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[page].reckgrowth = CreateFrame("Button", "ReckGrowth", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].reckgrowth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].reckheader, "BOTTOMLEFT", 60 , -10)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].reckgrowth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].reckgrowth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].reckgrowth, function()
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

	LunaOptionsFrame.pages[page].reckgrDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].reckgrDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[page].reckgrowth, "TOP", 0, 0)
	LunaOptionsFrame.pages[page].reckgrDesc:SetText(L["Growth"])

	LunaOptionsFrame.pages[page].hidereck = CreateFrame("CheckButton", "HideReckStacks", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].hidereck:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].reckheader, "BOTTOMLEFT", 190, -10)
	LunaOptionsFrame.pages[page].hidereck:SetHeight(30)
	LunaOptionsFrame.pages[page].hidereck:SetWidth(30)
	LunaOptionsFrame.pages[page].hidereck:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].reckStacks.hide = not LunaUF.db.profile.units[unit].reckStacks.hide
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("HideReckStacksText"):SetText(L["hide"])

	LunaOptionsFrame.pages[page].recksizeslider = CreateFrame("Slider", "ReckSizeSliderplayer", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].recksizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[page].recksizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[page].recksizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.player.reckStacks.size = math.floor(this:GetValue())
		getglobal("ReckSizeSliderplayerText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.player.reckStacks.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.player)
	end)
	LunaOptionsFrame.pages[page].recksizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].reckheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[page].recksizeslider:SetWidth(190)

	local page = 3
	LunaOptionsFrame.pages[page].xpheader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].xpheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].barorder, "BOTTOMLEFT", 0, -60)
	LunaOptionsFrame.pages[page].xpheader:SetHeight(24)
	LunaOptionsFrame.pages[page].xpheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].xpheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].xpheader:SetText(L["XP Bar"])

	LunaOptionsFrame.pages[page].enablexp = CreateFrame("CheckButton", "EnablepetXP", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].enablexp:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].xpheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].enablexp:SetHeight(30)
	LunaOptionsFrame.pages[page].enablexp:SetWidth(30)
	LunaOptionsFrame.pages[page].enablexp:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units.pet.xpBar.enabled = not LunaUF.db.profile.units.pet.xpBar.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnablepetXPText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[page].xpsizeslider = CreateFrame("Slider", "XPSizeSliderpet", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].xpsizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[page].xpsizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[page].xpsizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.pet.xpBar.size = math.floor(this:GetValue())
		getglobal("XPSizeSliderpetText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.pet.xpBar.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.pet)
	end)
	LunaOptionsFrame.pages[page].xpsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].xpheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[page].xpsizeslider:SetWidth(190)

	local page = 5
	LunaOptionsFrame.pages[page].comboheader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].comboheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].barorder, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[page].comboheader:SetHeight(24)
	LunaOptionsFrame.pages[page].comboheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].comboheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].comboheader:SetText(L["Combo points"])

	LunaOptionsFrame.pages[page].enablecombo = CreateFrame("CheckButton", "EnabletargetCombo", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].enablecombo:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].comboheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].enablecombo:SetHeight(30)
	LunaOptionsFrame.pages[page].enablecombo:SetWidth(30)
	LunaOptionsFrame.pages[page].enablecombo:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].comboPoints.enabled = not LunaUF.db.profile.units[unit].comboPoints.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnabletargetCombo".."Text"):SetText(L["Enable"])

	LunaOptionsFrame.pages[page].combogrowth = CreateFrame("Button", "ComboGrowth", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].combogrowth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].comboheader, "BOTTOMLEFT", 60 , -10)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].combogrowth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].combogrowth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].combogrowth, function()
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

	LunaOptionsFrame.pages[page].combogrDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].combogrDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[page].combogrowth, "TOP", 0, 0)
	LunaOptionsFrame.pages[page].combogrDesc:SetText(L["Growth"])

	LunaOptionsFrame.pages[page].hidecombo = CreateFrame("CheckButton", "HidetargetCombo", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].hidecombo:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].comboheader, "BOTTOMLEFT", 190, -10)
	LunaOptionsFrame.pages[page].hidecombo:SetHeight(30)
	LunaOptionsFrame.pages[page].hidecombo:SetWidth(30)
	LunaOptionsFrame.pages[page].hidecombo:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].comboPoints.hide = not LunaUF.db.profile.units[unit].comboPoints.hide
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("HidetargetComboText"):SetText(L["hide"])

	LunaOptionsFrame.pages[page].combosizeslider = CreateFrame("Slider", "ComboSizeSlidertarget", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].combosizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[page].combosizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[page].combosizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.target.comboPoints.size = math.floor(this:GetValue())
		getglobal("ComboSizeSlidertargetText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.target.comboPoints.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.target)
	end)
	LunaOptionsFrame.pages[page].combosizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].comboheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[page].combosizeslider:SetWidth(190)

	local page = 8
	LunaOptionsFrame.pages[page].rangedesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].rangedesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].barorder, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[page].rangedesc:SetHeight(24)
	LunaOptionsFrame.pages[page].rangedesc:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].rangedesc:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].rangedesc:SetText(L["Range"])

	LunaOptionsFrame.pages[page].enablerange = CreateFrame("CheckButton", "EnablepartyRange", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].enablerange:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].rangedesc, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].enablerange:SetHeight(30)
	LunaOptionsFrame.pages[page].enablerange:SetWidth(30)
	LunaOptionsFrame.pages[page].enablerange:SetScript("OnClick", function()
		LunaUF.db.profile.units.party.range.enabled = not LunaUF.db.profile.units.party.range.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "party" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnablepartyRangeText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[page].partyrangealpha = CreateFrame("Slider", "AlphaSliderpartyRange", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].partyrangealpha:SetMinMaxValues(0.1,1)
	LunaOptionsFrame.pages[page].partyrangealpha:SetValueStep(0.1)
	LunaOptionsFrame.pages[page].partyrangealpha:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.party.range.alpha = math.floor(this:GetValue()*10)/10
		getglobal("AlphaSliderpartyRangeText"):SetText(L["Alpha"]..": "..LunaUF.db.profile.units.party.range.alpha)
	end)
	LunaOptionsFrame.pages[page].partyrangealpha:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].enablerange, "TOPLEFT", 200, 0)
	LunaOptionsFrame.pages[page].partyrangealpha:SetWidth(190)

	LunaOptionsFrame.pages[page].partyoptions = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].partyoptions:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].enablerange, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[page].partyoptions:SetHeight(24)
	LunaOptionsFrame.pages[page].partyoptions:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].partyoptions:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].partyoptions:SetText(L["Partyoptions"])

	LunaOptionsFrame.pages[page].inraid = CreateFrame("CheckButton", "EnablepartyInRaid", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].inraid:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].partyoptions, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].inraid:SetHeight(30)
	LunaOptionsFrame.pages[page].inraid:SetWidth(30)
	LunaOptionsFrame.pages[page].inraid:SetScript("OnClick", function()
		LunaUF.db.profile.units.party.inraid = not LunaUF.db.profile.units.party.inraid
		LunaUF.Units:InitializeFrame("party")
	end)
	getglobal("EnablepartyInRaidText"):SetText(L["Show party in raid"])

	LunaOptionsFrame.pages[page].playerparty = CreateFrame("CheckButton", "EnablePlayerparty", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].playerparty:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].inraid, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].playerparty:SetHeight(30)
	LunaOptionsFrame.pages[page].playerparty:SetWidth(30)
	LunaOptionsFrame.pages[page].playerparty:SetScript("OnClick", function()
		LunaUF.db.profile.units.party.player = not LunaUF.db.profile.units.party.player
		LunaUF.Units:LoadGroupHeader("party")
	end)
	getglobal("EnablePlayerpartyText"):SetText(L["Player in party"])

	LunaOptionsFrame.pages[page].auratracker = CreateFrame("CheckButton", "EnablePartyAuratracker", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].auratracker:SetPoint("LEFT", LunaOptionsFrame.pages[page].playerparty, "RIGHT", 120, 0)
	LunaOptionsFrame.pages[page].auratracker:SetHeight(30)
	LunaOptionsFrame.pages[page].auratracker:SetWidth(30)
	LunaOptionsFrame.pages[page].auratracker:SetScript("OnClick", function()
		LunaUF.db.profile.units.party.squares.enabled = not LunaUF.db.profile.units.party.squares.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "party" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnablePartyAuratrackerText"):SetText(L["Auratracker"])

	LunaOptionsFrame.pages[page].partypadding = CreateFrame("Slider", "PartyPaddingSlider", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].partypadding:SetMinMaxValues(1,100)
	LunaOptionsFrame.pages[page].partypadding:SetValueStep(1)
	LunaOptionsFrame.pages[page].partypadding:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.party.padding = math.floor(this:GetValue())
		getglobal("PartyPaddingSliderText"):SetText(L["Padding"]..": "..LunaUF.db.profile.units.party.padding)
		LunaUF.Units:LoadGroupHeader("party")
		LunaUF.Units:LoadGroupHeader("partytarget")
		LunaUF.Units:LoadGroupHeader("partypet")
	end)
	LunaOptionsFrame.pages[page].partypadding:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].partyoptions, "BOTTOMLEFT", 270, -10)
	LunaOptionsFrame.pages[page].partypadding:SetWidth(200)

	LunaOptionsFrame.pages[page].sortby = CreateFrame("Button", "PartySortBy", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].sortby:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].playerparty, "BOTTOMLEFT", -10 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].sortby)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].sortby)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].sortby, function()
		local info={}
		for k,v in pairs({[L["Name"]] = "NAME",[L["Group"]] = "GROUP"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].sortby, this.value)
				LunaUF.db.profile.units.party.sortby = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[page].sortby)
				LunaUF.Units:LoadGroupHeader("party")
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[page].sortDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].sortDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[page].sortby, "TOP")
	LunaOptionsFrame.pages[page].sortDesc:SetText(L["Sort by"])

	LunaOptionsFrame.pages[page].orderby = CreateFrame("Button", "PartyOrderBy", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].orderby:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].playerparty, "BOTTOMLEFT", 140 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].orderby)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].orderby)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].orderby, function()
		local info={}
		for k,v in pairs({[L["Ascending"]] = "ASC",[L["Descending"]] = "DESC"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].orderby, this.value)
				LunaUF.db.profile.units.party.order = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[page].orderby)
				LunaUF.Units:LoadGroupHeader("party")
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[page].orderDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].orderDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[page].orderby, "TOP")
	LunaOptionsFrame.pages[page].orderDesc:SetText(L["Sort direction"])

	LunaOptionsFrame.pages[page].growth = CreateFrame("Button", "PartyGrowth", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].growth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].playerparty, "BOTTOMLEFT", 300 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].growth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].growth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].growth, function()
		local info={}
		for k,v in pairs({[L["LEFT"]] = "LEFT",[L["RIGHT"]] = "RIGHT",[L["UP"]] = "UP",[L["DOWN"]] = "DOWN"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].growth, this.value)
				LunaUF.db.profile.units.party.growth = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[page].growth)
				LunaUF.Units:LoadGroupHeader("party")
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[page].growthDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].growthDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[page].growth, "TOP")
	LunaOptionsFrame.pages[page].growthDesc:SetText(L["Growth direction"])

	local page = 11
	LunaOptionsFrame.pages[page].GrpSelDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].GrpSelDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].positionsHeader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].GrpSelDesc:SetText("GRP")

	LunaOptionsFrame.pages[page].GrpSelect = CreateFrame("Button", "GrpSelector", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].GrpSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].GrpSelDesc, "TOPLEFT", 10 , 10)
	UIDropDownMenu_SetWidth(40, LunaOptionsFrame.pages[page].GrpSelect)
	UIDropDownMenu_JustifyText("RIGHT", LunaOptionsFrame.pages[page].GrpSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].GrpSelect, function()
		local info={}
		for i=1, 9 do
			info.text=tostring(i)
			info.value=tostring(i)
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[page].GrpSelect, this:GetID())
				LunaOptionsFrame.pages[page].xInput:SetText(LunaUF.db.profile.units["raid"][tonumber(this:GetText())].position.x)
				LunaOptionsFrame.pages[page].yInput:SetText(LunaUF.db.profile.units["raid"][tonumber(this:GetText())].position.y)
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[page].rangedesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].rangedesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].barorder, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[page].rangedesc:SetHeight(24)
	LunaOptionsFrame.pages[page].rangedesc:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].rangedesc:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].rangedesc:SetText(L["Range"])

	LunaOptionsFrame.pages[page].enablerange = CreateFrame("CheckButton", "EnableraidRange", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].enablerange:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].rangedesc, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].enablerange:SetHeight(30)
	LunaOptionsFrame.pages[page].enablerange:SetWidth(30)
	LunaOptionsFrame.pages[page].enablerange:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.range.enabled = not LunaUF.db.profile.units.raid.range.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableraidRangeText"):SetText(L["Enable"])


	LunaOptionsFrame.pages[page].raidrangealpha = CreateFrame("Slider", "AlphaSliderraidRange", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].raidrangealpha:SetMinMaxValues(0.1,1)
	LunaOptionsFrame.pages[page].raidrangealpha:SetValueStep(0.1)
	LunaOptionsFrame.pages[page].raidrangealpha:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.range.alpha = math.floor(this:GetValue()*10)/10
		getglobal("AlphaSliderraidRangeText"):SetText(L["Alpha"]..": "..LunaUF.db.profile.units.raid.range.alpha)
	end)
	LunaOptionsFrame.pages[page].raidrangealpha:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].enablerange, "TOPLEFT", 200, 0)
	LunaOptionsFrame.pages[page].raidrangealpha:SetWidth(190)

	LunaOptionsFrame.pages[page].healthAlphas = CreateFrame("CheckButton", "EnableHealthAlphas", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].healthAlphas:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].enablerange, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].healthAlphas:SetHeight(30)
	LunaOptionsFrame.pages[page].healthAlphas:SetWidth(30)
	LunaOptionsFrame.pages[page].healthAlphas:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.healththreshold.enabled = not LunaUF.db.profile.units.raid.healththreshold.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableHealthAlphasText"):SetText(L["Enable"].." "..L["Low Health Indicator"])

    --Health Threshold slider
	LunaOptionsFrame.pages[page].healththresholdslider = CreateFrame("Slider", "HealthThresholdTracker", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].healththresholdslider:SetMinMaxValues(0.1,1)
	LunaOptionsFrame.pages[page].healththresholdslider:SetValueStep(0.1)
	LunaOptionsFrame.pages[page].healththresholdslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.healththreshold.threshold = math.floor(this:GetValue()*10+.5)/10
		local lowhealthtext = LunaUF.db.profile.units.raid.healththreshold.threshold*100
		getglobal("HealthThresholdTrackerText"):SetText(L["Low Health Limit"]..": "..lowhealthtext.."%")
	end)
	LunaOptionsFrame.pages[page].healththresholdslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].healthAlphas, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].healththresholdslider:SetWidth(460)

    --In Range and Below Threshold Alpha slider
  	LunaOptionsFrame.pages[page].inrangebelowthresholdslider = CreateFrame("Slider", "InRangeBelowThreshold", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
  	LunaOptionsFrame.pages[page].inrangebelowthresholdslider:SetMinMaxValues(0.1,1)
  	LunaOptionsFrame.pages[page].inrangebelowthresholdslider:SetValueStep(0.1)
  	LunaOptionsFrame.pages[page].inrangebelowthresholdslider:SetScript("OnValueChanged", function()
  	  LunaUF.db.profile.units.raid.healththreshold.inRangeBelowAlpha = math.floor(this:GetValue()*10+.5)/10
  	  getglobal("InRangeBelowThresholdText"):SetText(L["In Range and Below Limit"].." "..L["Alpha"]..": "..LunaUF.db.profile.units.raid.healththreshold.inRangeBelowAlpha)
  	end)
  	LunaOptionsFrame.pages[page].inrangebelowthresholdslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].healththresholdslider, "BOTTOMLEFT", 0, -30)
  	LunaOptionsFrame.pages[page].inrangebelowthresholdslider:SetWidth(460)

	--In Range and Above Threshold Alpha slider
  	LunaOptionsFrame.pages[page].inrangeabovethresholdslider = CreateFrame("Slider", "InRangeAboveThreshold", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
  	LunaOptionsFrame.pages[page].inrangeabovethresholdslider:SetMinMaxValues(0.1,1)
  	LunaOptionsFrame.pages[page].inrangeabovethresholdslider:SetValueStep(0.1)
  	LunaOptionsFrame.pages[page].inrangeabovethresholdslider:SetScript("OnValueChanged", function()
  	  LunaUF.db.profile.units.raid.healththreshold.inRangeAboveAlpha = math.floor(this:GetValue()*10+.5)/10
  	  getglobal("InRangeAboveThresholdText"):SetText(L["In Range and Above Limit"].." "..L["Alpha"]..": "..LunaUF.db.profile.units.raid.healththreshold.inRangeAboveAlpha)
  	end)
  	LunaOptionsFrame.pages[page].inrangeabovethresholdslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].inrangebelowthresholdslider, "BOTTOMLEFT", 0, -30)
  	LunaOptionsFrame.pages[page].inrangeabovethresholdslider:SetWidth(460)


 	--Out of Range and below Threshold Alpha slider
  	LunaOptionsFrame.pages[page].outrangebelowthresholdslider = CreateFrame("Slider", "OutRangeBelowThreshold", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
  	LunaOptionsFrame.pages[page].outrangebelowthresholdslider:SetMinMaxValues(0.1,1)
  	LunaOptionsFrame.pages[page].outrangebelowthresholdslider:SetValueStep(0.1)
  	LunaOptionsFrame.pages[page].outrangebelowthresholdslider:SetScript("OnValueChanged", function()
  	  LunaUF.db.profile.units.raid.healththreshold.outOfRangeBelowAlpha = math.floor(this:GetValue()*10+.5)/10
  	  getglobal("OutRangeBelowThresholdText"):SetText(L["Out of Range and Below Limit"].." "..L["Alpha"]..": "..LunaUF.db.profile.units.raid.healththreshold.outOfRangeBelowAlpha)
  	end)
  	LunaOptionsFrame.pages[page].outrangebelowthresholdslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].inrangeabovethresholdslider, "BOTTOMLEFT", 0, -30)
  	LunaOptionsFrame.pages[page].outrangebelowthresholdslider:SetWidth(460)

	LunaOptionsFrame.pages[page].trackerDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].trackerDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].outrangebelowthresholdslider, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[page].trackerDesc:SetHeight(24)
	LunaOptionsFrame.pages[page].trackerDesc:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].trackerDesc:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].trackerDesc:SetText(L["Auratracker"])

	LunaOptionsFrame.pages[page].enabletracker = CreateFrame("CheckButton", "EnableSquares", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].enabletracker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].trackerDesc, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].enabletracker:SetHeight(30)
	LunaOptionsFrame.pages[page].enabletracker:SetWidth(30)
	LunaOptionsFrame.pages[page].enabletracker:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.enabled = not LunaUF.db.profile.units.raid.squares.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableSquaresText"):SetText(L["Enable"])

	LunaOptionsFrame.pages[page].outersizeslider = CreateFrame("Slider", "OuterSizeSliderTracker", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].outersizeslider:SetMinMaxValues(1,20)
	LunaOptionsFrame.pages[page].outersizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[page].outersizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.squares.outersize = math.floor(this:GetValue())
		getglobal("OuterSizeSliderTrackerText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.raid.squares.outersize)
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[page].outersizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].trackerDesc, "BOTTOMLEFT", 200, -10)
	LunaOptionsFrame.pages[page].outersizeslider:SetWidth(230)

	LunaOptionsFrame.pages[page].enabledebuffs = CreateFrame("CheckButton", "EnableDebuffs", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].enabledebuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].enabletracker, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].enabledebuffs:SetHeight(30)
	LunaOptionsFrame.pages[page].enabledebuffs:SetWidth(30)
	LunaOptionsFrame.pages[page].enabledebuffs:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.enabledebuffs = not LunaUF.db.profile.units.raid.squares.enabledebuffs
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableDebuffsText"):SetText(L["Enable debuffs"])

	LunaOptionsFrame.pages[page].dispdebuffs = CreateFrame("CheckButton", "EnableDispDebuffs", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].dispdebuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].enabletracker, "BOTTOMLEFT", 200, -10)
	LunaOptionsFrame.pages[page].dispdebuffs:SetHeight(30)
	LunaOptionsFrame.pages[page].dispdebuffs:SetWidth(30)
	LunaOptionsFrame.pages[page].dispdebuffs:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.dispellabledebuffs = not LunaUF.db.profile.units.raid.squares.dispellabledebuffs
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableDispDebuffsText"):SetText(L["Show dispellable debuffs"])

	LunaOptionsFrame.pages[page].owndebuffs = CreateFrame("CheckButton", "EnableOwnDebuffs", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].owndebuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].enabletracker, "BOTTOMLEFT", 200, -40)
	LunaOptionsFrame.pages[page].owndebuffs:SetHeight(30)
	LunaOptionsFrame.pages[page].owndebuffs:SetWidth(30)
	LunaOptionsFrame.pages[page].owndebuffs:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.owndispdebuffs = not LunaUF.db.profile.units.raid.squares.owndispdebuffs
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableOwnDebuffsText"):SetText(L["Only debuffs you can dispel"])

	LunaOptionsFrame.pages[page].aggro = CreateFrame("CheckButton", "EnableAggro", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].aggro:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].enabledebuffs, "BOTTOMLEFT", 0, -50)
	LunaOptionsFrame.pages[page].aggro:SetHeight(30)
	LunaOptionsFrame.pages[page].aggro:SetWidth(30)
	LunaOptionsFrame.pages[page].aggro:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.aggro = not LunaUF.db.profile.units.raid.squares.aggro
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableAggroText"):SetText(L["Show aggro"])

	LunaOptionsFrame.pages[page].aggrocolor = CreateColorSelect(LunaOptionsFrame.pages[page], LunaUF.db.profile.units.raid.squares.aggrocolor, "AggroColorSelect")
	LunaOptionsFrame.pages[page].aggrocolor:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].aggro, "TOPLEFT", 205, -5)
	LunaOptionsFrame.pages[page].aggrocolor:SetHeight(19)
	LunaOptionsFrame.pages[page].aggrocolor:SetWidth(19)
	LunaOptionsFrame.pages[page].aggrocolor.text:SetText(L["Aggrocolor"])

	LunaOptionsFrame.pages[page].hottracker = CreateFrame("CheckButton", "EnableHotTracker", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].hottracker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].aggro, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].hottracker:SetHeight(30)
	LunaOptionsFrame.pages[page].hottracker:SetWidth(30)
	LunaOptionsFrame.pages[page].hottracker:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.hottracker = not LunaUF.db.profile.units.raid.squares.hottracker
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableHotTrackerText"):SetText(L["Track heal over time"])

	LunaOptionsFrame.pages[page].innersizeslider = CreateFrame("Slider", "InnerSizeSliderTracker", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].innersizeslider:SetMinMaxValues(1,30)
	LunaOptionsFrame.pages[page].innersizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[page].innersizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.squares.innersize = math.floor(this:GetValue())
		getglobal("InnerSizeSliderTrackerText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.raid.squares.innersize)
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[page].innersizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].hottracker, "TOPLEFT", 200, 0)
	LunaOptionsFrame.pages[page].innersizeslider:SetWidth(230)

	LunaOptionsFrame.pages[page].buffcolors = CreateFrame("CheckButton", "EnableBuffColorsTracker", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].buffcolors:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].hottracker, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].buffcolors:SetHeight(30)
	LunaOptionsFrame.pages[page].buffcolors:SetWidth(30)
	LunaOptionsFrame.pages[page].buffcolors:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.buffcolors = not LunaUF.db.profile.units.raid.squares.buffcolors
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableBuffColorsTrackerText"):SetText(L["Colors instead of icons for buffs"])

	LunaOptionsFrame.pages[page].debuffcolors = CreateFrame("CheckButton", "EnableDebuffColorsTracker", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].debuffcolors:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].hottracker, "BOTTOMLEFT", 200, -10)
	LunaOptionsFrame.pages[page].debuffcolors:SetHeight(30)
	LunaOptionsFrame.pages[page].debuffcolors:SetWidth(30)
	LunaOptionsFrame.pages[page].debuffcolors:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.debuffcolors = not LunaUF.db.profile.units.raid.squares.debuffcolors
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableDebuffColorsTrackerText"):SetText(L["Colors instead of icons for debuffs"])

	LunaOptionsFrame.pages[page].buffheader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].buffheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].buffcolors, "BOTTOMLEFT", 0, -20)
	LunaOptionsFrame.pages[page].buffheader:SetText(L["Buffs to track"])

	local function Exit()
		this:ClearFocus()
	end

	LunaOptionsFrame.pages[page].firstbuff = CreateFrame("Editbox", "FirstBuffInput", LunaOptionsFrame.pages[page], "InputBoxTemplate")
	LunaOptionsFrame.pages[page].firstbuff:SetHeight(20)
	LunaOptionsFrame.pages[page].firstbuff:SetWidth(200)
	LunaOptionsFrame.pages[page].firstbuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[page].firstbuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].buffheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].firstbuff:SetScript("OnTextChanged", function()
		LunaUF.db.profile.units.raid.squares.buffs.names[1] = this:GetText()
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[page].firstbuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[page].firstbuff:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[page].firstbuffcolor = CreateColorSelect(LunaOptionsFrame.pages[page], LunaUF.db.profile.units.raid.squares.buffs.colors[1])
	LunaOptionsFrame.pages[page].firstbuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[page].firstbuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[page].firstbuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[page].firstbuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[page].firstbuffcolor.text:SetText(L["Buffcolor"])

	LunaOptionsFrame.pages[page].firstbuffinvert = CreateFrame("CheckButton", "FirstBuffInvert", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].firstbuffinvert:SetPoint("LEFT", LunaOptionsFrame.pages[page].firstbuffcolor, "RIGHT", 70, 0)
	LunaOptionsFrame.pages[page].firstbuffinvert:SetHeight(15)
	LunaOptionsFrame.pages[page].firstbuffinvert:SetWidth(15)
	LunaOptionsFrame.pages[page].firstbuffinvert:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.invertfirstbuff = not LunaUF.db.profile.units.raid.squares.invertfirstbuff
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("FirstBuffInvertText"):SetText(L["Invert display"])

	LunaOptionsFrame.pages[page].secondbuff = CreateFrame("Editbox", "SecondBuffInput", LunaOptionsFrame.pages[page], "InputBoxTemplate")
	LunaOptionsFrame.pages[page].secondbuff:SetHeight(20)
	LunaOptionsFrame.pages[page].secondbuff:SetWidth(200)
	LunaOptionsFrame.pages[page].secondbuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[page].secondbuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].firstbuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].secondbuff:SetScript("OnTextChanged", function()
		LunaUF.db.profile.units.raid.squares.buffs.names[2] = this:GetText()
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[page].secondbuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[page].secondbuff:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[page].secondbuffcolor = CreateColorSelect(LunaOptionsFrame.pages[page], LunaUF.db.profile.units.raid.squares.buffs.colors[2])
	LunaOptionsFrame.pages[page].secondbuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[page].secondbuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[page].secondbuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[page].secondbuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[page].secondbuffcolor.text:SetText(L["Buffcolor"])

	LunaOptionsFrame.pages[page].secondbuffinvert = CreateFrame("CheckButton", "SecondBuffInvert", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].secondbuffinvert:SetPoint("LEFT", LunaOptionsFrame.pages[page].secondbuffcolor, "RIGHT", 70, 0)
	LunaOptionsFrame.pages[page].secondbuffinvert:SetHeight(15)
	LunaOptionsFrame.pages[page].secondbuffinvert:SetWidth(15)
	LunaOptionsFrame.pages[page].secondbuffinvert:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.invertsecondbuff = not LunaUF.db.profile.units.raid.squares.invertsecondbuff
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("SecondBuffInvertText"):SetText(L["Invert display"])

	LunaOptionsFrame.pages[page].thirdbuff = CreateFrame("Editbox", "ThirdBuffInput", LunaOptionsFrame.pages[page], "InputBoxTemplate")
	LunaOptionsFrame.pages[page].thirdbuff:SetHeight(20)
	LunaOptionsFrame.pages[page].thirdbuff:SetWidth(200)
	LunaOptionsFrame.pages[page].thirdbuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[page].thirdbuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].secondbuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].thirdbuff:SetScript("OnTextChanged", function()
		LunaUF.db.profile.units.raid.squares.buffs.names[3] = this:GetText()
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[page].thirdbuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[page].thirdbuff:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[page].thirdbuffcolor = CreateColorSelect(LunaOptionsFrame.pages[page], LunaUF.db.profile.units.raid.squares.buffs.colors[3])
	LunaOptionsFrame.pages[page].thirdbuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[page].thirdbuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[page].thirdbuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[page].thirdbuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[page].thirdbuffcolor.text:SetText(L["Buffcolor"])

	LunaOptionsFrame.pages[page].thirdbuffinvert = CreateFrame("CheckButton", "ThirdBuffInvert", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].thirdbuffinvert:SetPoint("LEFT", LunaOptionsFrame.pages[page].thirdbuffcolor, "RIGHT", 70, 0)
	LunaOptionsFrame.pages[page].thirdbuffinvert:SetHeight(15)
	LunaOptionsFrame.pages[page].thirdbuffinvert:SetWidth(15)
	LunaOptionsFrame.pages[page].thirdbuffinvert:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.invertthirdbuff = not LunaUF.db.profile.units.raid.squares.invertthirdbuff
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("ThirdBuffInvertText"):SetText(L["Invert display"])

	LunaOptionsFrame.pages[page].debuffheader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].debuffheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].thirdbuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].debuffheader:SetText(L["Debuffs to track"])

	LunaOptionsFrame.pages[page].firstdebuff = CreateFrame("Editbox", "FirstDebuffInput", LunaOptionsFrame.pages[page], "InputBoxTemplate")
	LunaOptionsFrame.pages[page].firstdebuff:SetHeight(20)
	LunaOptionsFrame.pages[page].firstdebuff:SetWidth(200)
	LunaOptionsFrame.pages[page].firstdebuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[page].firstdebuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].debuffheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].firstdebuff:SetScript("OnTextChanged", function()
		LunaUF.db.profile.units.raid.squares.debuffs.names[1] = string.lower(this:GetText())
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[page].firstdebuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[page].firstdebuff:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[page].firstdebuffcolor = CreateColorSelect(LunaOptionsFrame.pages[page], LunaUF.db.profile.units.raid.squares.debuffs.colors[1])
	LunaOptionsFrame.pages[page].firstdebuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[page].firstdebuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[page].firstdebuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[page].firstdebuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[page].firstdebuffcolor.text:SetText(L["Debuffcolor"])

	LunaOptionsFrame.pages[page].seconddebuff = CreateFrame("Editbox", "SecondDebuffInput", LunaOptionsFrame.pages[page], "InputBoxTemplate")
	LunaOptionsFrame.pages[page].seconddebuff:SetHeight(20)
	LunaOptionsFrame.pages[page].seconddebuff:SetWidth(200)
	LunaOptionsFrame.pages[page].seconddebuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[page].seconddebuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].firstdebuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].seconddebuff:SetScript("OnTextChanged", function()
		LunaUF.db.profile.units.raid.squares.debuffs.names[2] = string.lower(this:GetText())
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[page].seconddebuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[page].seconddebuff:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[page].seconddebuffcolor = CreateColorSelect(LunaOptionsFrame.pages[page], LunaUF.db.profile.units.raid.squares.debuffs.colors[2])
	LunaOptionsFrame.pages[page].seconddebuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[page].seconddebuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[page].seconddebuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[page].seconddebuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[page].seconddebuffcolor.text:SetText(L["Debuffcolor"])

	LunaOptionsFrame.pages[page].thirddebuff = CreateFrame("Editbox", "ThirdDebuffInput", LunaOptionsFrame.pages[page], "InputBoxTemplate")
	LunaOptionsFrame.pages[page].thirddebuff:SetHeight(20)
	LunaOptionsFrame.pages[page].thirddebuff:SetWidth(200)
	LunaOptionsFrame.pages[page].thirddebuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[page].thirddebuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].seconddebuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].thirddebuff:SetScript("OnTextChanged", function()
		LunaUF.db.profile.units.raid.squares.debuffs.names[3] = string.lower(this:GetText())
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[page].thirddebuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[page].thirddebuff:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[page].thirddebuffcolor = CreateColorSelect(LunaOptionsFrame.pages[page], LunaUF.db.profile.units.raid.squares.debuffs.colors[3])
	LunaOptionsFrame.pages[page].thirddebuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[page].thirddebuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[page].thirddebuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[page].thirddebuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[page].thirddebuffcolor.text:SetText(L["Debuffcolor"])

	LunaOptionsFrame.pages[page].raidoptions = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].raidoptions:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].thirddebuff, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[page].raidoptions:SetHeight(24)
	LunaOptionsFrame.pages[page].raidoptions:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].raidoptions:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].raidoptions:SetText(L["Raidoptions"])

	LunaOptionsFrame.pages[page].showparty = CreateFrame("CheckButton", "PartyInRaidFrames", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].showparty:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].raidoptions, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].showparty:SetHeight(30)
	LunaOptionsFrame.pages[page].showparty:SetWidth(30)
	LunaOptionsFrame.pages[page].showparty:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.showparty = not LunaUF.db.profile.units.raid.showparty
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("PartyInRaidFramesText"):SetText(L["Party in raidframes"])

	LunaOptionsFrame.pages[page].showalways = CreateFrame("CheckButton", "AlwaysShowRaid", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].showalways:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].raidoptions, "BOTTOMLEFT", 150, -10)
	LunaOptionsFrame.pages[page].showalways:SetHeight(30)
	LunaOptionsFrame.pages[page].showalways:SetWidth(30)
	LunaOptionsFrame.pages[page].showalways:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.showalways = not LunaUF.db.profile.units.raid.showalways
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("AlwaysShowRaidText"):SetText(L["Always show"])

	LunaOptionsFrame.pages[page].raidpadding = CreateFrame("Slider", "RaidPaddingSlider", LunaOptionsFrame.pages[page], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[page].raidpadding:SetMinMaxValues(1,100)
	LunaOptionsFrame.pages[page].raidpadding:SetValueStep(1)
	LunaOptionsFrame.pages[page].raidpadding:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.padding = math.floor(this:GetValue())
		getglobal("RaidPaddingSliderText"):SetText(L["Padding"]..": "..LunaUF.db.profile.units.raid.padding)
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	LunaOptionsFrame.pages[page].raidpadding:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].raidoptions, "BOTTOMLEFT", 270, -15)
	LunaOptionsFrame.pages[page].raidpadding:SetWidth(200)

	LunaOptionsFrame.pages[page].interlock = CreateFrame("CheckButton", "InterlockRaidFrames", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].interlock:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].showparty, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].interlock:SetHeight(30)
	LunaOptionsFrame.pages[page].interlock:SetWidth(30)
	LunaOptionsFrame.pages[page].interlock:SetScript("OnClick", function()
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

	LunaOptionsFrame.pages[page].interlockgrowth = CreateFrame("Button", "InterlockGrowthRaid", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].interlockgrowth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].showparty, "BOTTOMLEFT", 140 , -10)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].interlockgrowth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].interlockgrowth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].interlockgrowth, function()
		local info={}
		for k,v in pairs({[L["LEFT"]] = "LEFT",[L["RIGHT"]] = "RIGHT",[L["UP"]] = "UP",[L["DOWN"]] = "DOWN"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].interlockgrowth, this.value)
				LunaUF.db.profile.units.raid.interlockgrowth = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[page].interlockgrowth)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[page].intergrDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].intergrDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[page].interlockgrowth, "TOP")
	LunaOptionsFrame.pages[page].intergrDesc:SetText(L["Growth direction"])

	LunaOptionsFrame.pages[page].petgrp = CreateFrame("CheckButton", "EnablePetGrp", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].petgrp:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].interlock, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].petgrp:SetHeight(30)
	LunaOptionsFrame.pages[page].petgrp:SetWidth(30)
	LunaOptionsFrame.pages[page].petgrp:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.petgrp = not LunaUF.db.profile.units.raid.petgrp
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("EnablePetGrpText"):SetText(L["Enable pet group"])

	LunaOptionsFrame.pages[page].titles = CreateFrame("CheckButton", "RaidGrpTitles", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].titles:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].interlock, "BOTTOMLEFT", 150, -10)
	LunaOptionsFrame.pages[page].titles:SetHeight(30)
	LunaOptionsFrame.pages[page].titles:SetWidth(30)
	LunaOptionsFrame.pages[page].titles:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.titles = not LunaUF.db.profile.units.raid.titles
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("RaidGrpTitlesText"):SetText(L["Enable raidgroup titles"])

	LunaOptionsFrame.pages[page].sortby = CreateFrame("Button", "RaidSortBy", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].sortby:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].petgrp, "BOTTOMLEFT", -10 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].sortby)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].sortby)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].sortby, function()
		local info={}
		for k,v in pairs({[L["Name"]] = "NAME",[L["Group"]] = "GROUP"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].sortby, this.value)
				LunaUF.db.profile.units.raid.sortby = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[page].sortby)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[page].sortDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].sortDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[page].sortby, "TOP")
	LunaOptionsFrame.pages[page].sortDesc:SetText(L["Sort by"])

	LunaOptionsFrame.pages[page].orderby = CreateFrame("Button", "RaidOrderBy", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].orderby:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].petgrp, "BOTTOMLEFT", 100 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].orderby)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].orderby)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].orderby, function()
		local info={}
		for k,v in pairs({[L["Ascending"]] = "ASC",[L["Descending"]] = "DESC"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].orderby, this.value)
				LunaUF.db.profile.units.raid.order = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[page].orderby)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[page].orderDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].orderDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[page].orderby, "TOP")
	LunaOptionsFrame.pages[page].orderDesc:SetText(L["Sort direction"])

	LunaOptionsFrame.pages[page].growth = CreateFrame("Button", "RaidGrowth", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].growth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].petgrp, "BOTTOMLEFT", 210 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].growth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].growth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].growth, function()
		local info={}
		for k,v in pairs({[L["LEFT"]] = "LEFT",[L["RIGHT"]] = "RIGHT",[L["UP"]] = "UP",[L["DOWN"]] = "DOWN"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].growth, this.value)
				LunaUF.db.profile.units.raid.growth = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[page].growth)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[page].growthDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].growthDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[page].growth, "TOP")
	LunaOptionsFrame.pages[page].growthDesc:SetText(L["Growth direction"])

	LunaOptionsFrame.pages[page].mode = CreateFrame("Button", "RaidMode", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].mode:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].petgrp, "BOTTOMLEFT", 320 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[page].mode)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].mode)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].mode, function()
		local info={}
		for k,v in pairs({[L["Class"]] = "CLASS",[L["Group"]] = "GROUP"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].mode, this.value)
				LunaUF.db.profile.units.raid.mode = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[page].mode)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)

	LunaOptionsFrame.pages[page].modeDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].modeDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[page].mode, "TOP")
	LunaOptionsFrame.pages[page].modeDesc:SetText(L["Mode"])

-------- Clickcasting

	local page = 12
	LunaOptionsFrame.pages[page].mouseDownClicks = CreateFrame("CheckButton", "MouseDownClicks", LunaOptionsFrame.pages[page], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[page].mouseDownClicks:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -40)
	LunaOptionsFrame.pages[page].mouseDownClicks:SetHeight(30)
	LunaOptionsFrame.pages[page].mouseDownClicks:SetWidth(30)
	LunaOptionsFrame.pages[page].mouseDownClicks:SetScript("OnClick", function()
		LunaUF.db.profile.clickcasting.mouseDownClicks = not LunaUF.db.profile.clickcasting.mouseDownClicks
		local click_action = LunaUF.db.profile.clickcasting.mouseDownClicks and "Down" or "Up"
		for _,frame in pairs(LunaUF.Units.frameList) do
			frame:RegisterForClicks('LeftButton' .. click_action, 'RightButton' .. click_action, 'MiddleButton' .. click_action, 'Button4' .. click_action, 'Button5' .. click_action)
		end
	end)
	getglobal("MouseDownClicksText"):SetText(L["Cast on mouse down"])

	LunaOptionsFrame.pages[page].Button = CreateFrame("Button", "ClickCastBindButton", LunaOptionsFrame.pages[page], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[page].Button:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].mouseDownClicks, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[page].Button:SetHeight(20)
	LunaOptionsFrame.pages[page].Button:SetWidth(180)
	LunaOptionsFrame.pages[page].Button:SetText(L["Click me"])
	LunaOptionsFrame.pages[page].Button:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
	LunaOptionsFrame.pages[page].Button:SetScript("OnClick", function ()
		this:SetText((IsControlKeyDown() and "Ctrl-" or "") .. (IsShiftKeyDown() and "Shift-" or "") .. (IsAltKeyDown() and "Alt-" or "") .. L[arg1])
	end)

	LunaOptionsFrame.pages[page].input = CreateFrame("Editbox", "ClickCastInput", LunaOptionsFrame.pages[page], "InputBoxTemplate")
	LunaOptionsFrame.pages[page].input:SetHeight(20)
	LunaOptionsFrame.pages[page].input:SetWidth(250)
	LunaOptionsFrame.pages[page].input:SetAutoFocus(nil)
	LunaOptionsFrame.pages[page].input:SetPoint("LEFT", LunaOptionsFrame.pages[page].Button, "RIGHT", 20, 0)
	LunaOptionsFrame.pages[page].input.config = LunaUF.db.profile.clickcast
	LunaOptionsFrame.pages[page].input:SetScript("OnEnterPressed", function()
		this:ClearFocus()
	end)

	LunaOptionsFrame.pages[page].Add = CreateFrame("Button", "ClickCastAddButton", LunaOptionsFrame.pages[page], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[page].Add:SetPoint("CENTER", LunaOptionsFrame.pages[page], "TOP", 0, -140)
	LunaOptionsFrame.pages[page].Add:SetHeight(20)
	LunaOptionsFrame.pages[page].Add:SetWidth(90)
	LunaOptionsFrame.pages[page].Add:SetText(L["Add"])
	LunaOptionsFrame.pages[page].Add:SetScript("OnClick", function ()
		local binding = LunaOptionsFrame.pages[page].Button:GetText()
		if binding ~= L["Click me"] then
			LunaUF.db.profile.clickcasting.bindings[binding] = LunaOptionsFrame.pages[page].input:GetText()
			LunaOptionsFrame.pages[page].Load()
		end
	end)
	LunaOptionsFrame.pages[page].bindtexts = {}
	LunaOptionsFrame.pages[page].actiontexts = {}
	LunaOptionsFrame.pages[page].delbuttons = {}
	for i=1,40 do
		LunaOptionsFrame.pages[page].bindtexts[i] = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[page].bindtexts[i]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].Add, "BOTTOM", -220, -20*i)
		LunaOptionsFrame.pages[page].bindtexts[i]:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[page].bindtexts[i]:SetTextColor(1,1,0)

		LunaOptionsFrame.pages[page].actiontexts[i] = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[page].actiontexts[i]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].Add, "BOTTOM", -40, -20*i)
		LunaOptionsFrame.pages[page].actiontexts[i]:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[page].actiontexts[i]:SetTextColor(1,1,1)

		LunaOptionsFrame.pages[page].delbuttons[i] = CreateFrame("Button", "ClickCastDelButton"..i, LunaOptionsFrame.pages[page], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[page].delbuttons[i]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].Add, "BOTTOM", 220, -20*i)
		LunaOptionsFrame.pages[page].delbuttons[i]:SetHeight(20)
		LunaOptionsFrame.pages[page].delbuttons[i]:SetWidth(20)
		LunaOptionsFrame.pages[page].delbuttons[i]:SetText("X")
		LunaOptionsFrame.pages[page].delbuttons[i].bindtext = LunaOptionsFrame.pages[page].bindtexts[i]
		LunaOptionsFrame.pages[page].delbuttons[i]:SetScript("OnClick", function ()
			LunaUF.db.profile.clickcasting.bindings[this.bindtext:GetText()] = nil
			LunaOptionsFrame.pages[page].Load()
		end)
	end

	LunaOptionsFrame.pages[page].Load = function ()
		local button = 1
		for k,v in pairs(LunaUF.db.profile.clickcasting.bindings) do
			LunaOptionsFrame.pages[page].bindtexts[button]:SetText(k)
			LunaOptionsFrame.pages[page].bindtexts[button]:Show()
			LunaOptionsFrame.pages[page].actiontexts[button]:SetText(v)
			LunaOptionsFrame.pages[page].actiontexts[button]:Show()
			LunaOptionsFrame.pages[page].delbuttons[button]:Show()
			button = button + 1
		end
		for i=button, 40 do
			LunaOptionsFrame.pages[page].bindtexts[i]:Hide()
			LunaOptionsFrame.pages[page].actiontexts[i]:Hide()
			LunaOptionsFrame.pages[page].delbuttons[i]:Hide()
		end
		LunaOptionsFrame.ScrollFrames[page]:SetScrollChild(LunaOptionsFrame.pages[page])
	end

	-------- Colors

	local page = 13
	LunaOptionsFrame.pages[page].topHeader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].topHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -40)
	LunaOptionsFrame.pages[page].topHeader:SetHeight(24)
	LunaOptionsFrame.pages[page].topHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].topHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].topHeader:SetText(L["General"])

	LunaOptionsFrame.pages[page].resetAll = CreateFrame("Button", "LunaResetAllColors", LunaOptionsFrame.pages[page], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[page].resetAll:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "BOTTOMLEFT", 15, -70)
	LunaOptionsFrame.pages[page].resetAll:SetHeight(20)
	LunaOptionsFrame.pages[page].resetAll:SetWidth(180)
	LunaOptionsFrame.pages[page].resetAll:SetText(L["Reset All Colors"])
	LunaOptionsFrame.pages[page].resetAll:SetScript("OnClick", function()
		StaticPopup_Show("RESET_LUNA_COLORS")
	end)

	LunaOptionsFrame.pages[page].cColorHeader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].cColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -100)
	LunaOptionsFrame.pages[page].cColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[page].cColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].cColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].cColorHeader:SetText(L["Classcolors"])

	for i,class in ipairs({"PRIEST","PALADIN","SHAMAN","WARRIOR","ROGUE","MAGE","WARLOCK","DRUID","HUNTER"}) do
		LunaOptionsFrame.pages[page][class] = CreateColorSelect(LunaOptionsFrame.pages[page], LunaUF.db.profile.classColors[class])
		LunaOptionsFrame.pages[page][class]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20+(((i-(3*math.floor((i-1)/3)))-1)*120), -130-(math.floor((i-1)/3)*30))
		LunaOptionsFrame.pages[page][class]:SetHeight(19)
		LunaOptionsFrame.pages[page][class]:SetWidth(19)
		LunaOptionsFrame.pages[page][class].text:SetText(L[class])
	end

	LunaOptionsFrame.pages[page].hColorHeader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].hColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -230)
	LunaOptionsFrame.pages[page].hColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[page].hColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].hColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].hColorHeader:SetText(L["Healthcolors"])

	local num = 1
	for name,options in pairs(LunaUF.db.profile.healthColors) do
		LunaOptionsFrame.pages[page][name] = CreateColorSelect(LunaOptionsFrame.pages[page], options)
		LunaOptionsFrame.pages[page][name]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20+(((num-(4*math.floor((num-1)/4)))-1)*120), -260-(math.floor((num-1)/4)*30))
		LunaOptionsFrame.pages[page][name]:SetHeight(19)
		LunaOptionsFrame.pages[page][name]:SetWidth(19)
		LunaOptionsFrame.pages[page][name].text:SetText(L[name])
		num = num+1
	end

	LunaOptionsFrame.pages[page].pColorHeader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].pColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -360)
	LunaOptionsFrame.pages[page].pColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[page].pColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].pColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].pColorHeader:SetText(L["Powercolors"])

	local num = 1
	for name,options in pairs(LunaUF.db.profile.powerColors) do
		LunaOptionsFrame.pages[page][name] = CreateColorSelect(LunaOptionsFrame.pages[page], options)
		LunaOptionsFrame.pages[page][name]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20+(((num-(3*math.floor((num-1)/3)))-1)*120), -390-(math.floor((num-1)/3)*30))
		LunaOptionsFrame.pages[page][name]:SetHeight(19)
		LunaOptionsFrame.pages[page][name]:SetWidth(19)
		LunaOptionsFrame.pages[page][name].text:SetText(L[name])
		num = num+1
	end

	LunaOptionsFrame.pages[page].castColorHeader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].castColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -460)
	LunaOptionsFrame.pages[page].castColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[page].castColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].castColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].castColorHeader:SetText(L["Castcolors"])

	local num = 1
	for name,options in pairs(LunaUF.db.profile.castColors) do
		LunaOptionsFrame.pages[page][name] = CreateColorSelect(LunaOptionsFrame.pages[page], options)
		LunaOptionsFrame.pages[page][name]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20+(((num-(3*math.floor((num-1)/3)))-1)*120), -490-(math.floor((num-1)/3)*30))
		LunaOptionsFrame.pages[page][name]:SetHeight(19)
		LunaOptionsFrame.pages[page][name]:SetWidth(19)
		LunaOptionsFrame.pages[page][name].text:SetText(L[name])
		num = num+1
	end

	LunaOptionsFrame.pages[page].xpColorHeader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].xpColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -510)
	LunaOptionsFrame.pages[page].xpColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[page].xpColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].xpColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].xpColorHeader:SetText(L["Xpcolors"])

	local num = 1
	for name,options in pairs(LunaUF.db.profile.xpColors) do
		LunaOptionsFrame.pages[page][name] = CreateColorSelect(LunaOptionsFrame.pages[page], options)
		LunaOptionsFrame.pages[page][name]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20+(((num-(3*math.floor((num-1)/3)))-1)*120), -540-(math.floor((num-1)/3)*30))
		LunaOptionsFrame.pages[page][name]:SetHeight(19)
		LunaOptionsFrame.pages[page][name]:SetWidth(19)
		LunaOptionsFrame.pages[page][name].text:SetText(L[name])
		num = num+1
	end

	-------- Profiles

	local page = 14
	local nonDeletables = {}
	nonDeletables["Default"] = true
	nonDeletables["char"] = true
	nonDeletables["class"] = true
	nonDeletables["realm"] = true

	LunaOptionsFrame.pages[page].NewProfileHeader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].NewProfileHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page], "TOPLEFT", 20, -40)
	LunaOptionsFrame.pages[page].NewProfileHeader:SetHeight(24)
	LunaOptionsFrame.pages[page].NewProfileHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].NewProfileHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].NewProfileHeader:SetText(L["New Profile"])

	LunaOptionsFrame.pages[page].input = CreateFrame("Editbox", "NewProfileInput", LunaOptionsFrame.pages[page], "InputBoxTemplate")
	LunaOptionsFrame.pages[page].input:SetHeight(20)
	LunaOptionsFrame.pages[page].input:SetWidth(200)
	LunaOptionsFrame.pages[page].input:SetAutoFocus(nil)
	LunaOptionsFrame.pages[page].input:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].NewProfileHeader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[page].input:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[page].input:SetScript("OnEnterPressed", Exit)

	LunaOptionsFrame.pages[page].Add = CreateFrame("Button", "NewProfileAddButton", LunaOptionsFrame.pages[page], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[page].Add:SetPoint("LEFT", LunaOptionsFrame.pages[page].input, "RIGHT")
	LunaOptionsFrame.pages[page].Add:SetHeight(20)
	LunaOptionsFrame.pages[page].Add:SetWidth(20)
	LunaOptionsFrame.pages[page].Add:SetText("+")
	LunaOptionsFrame.pages[page].Add:SetScript("OnClick", function ()
		local ProfileName = LunaOptionsFrame.pages[page].input:GetText()
		if ProfileName == "" then return end
		LunaUF:SetProfile(ProfileName, UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[page].CopySelect) ~= "" and UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[page].CopySelect) or nil)
		UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].ProfileSelect, ProfileName)
		UIDropDownMenu_SetText(ProfileName, LunaOptionsFrame.pages[page].ProfileSelect)
		LunaOptionsFrame.pages[page].input:ClearFocus()
		LunaOptionsFrame.pages[page].input:SetText("")
	end)

	LunaOptionsFrame.pages[page].CopySelect = CreateFrame("Button", "CopySelect", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].CopySelect:SetPoint("LEFT", LunaOptionsFrame.pages[page].Add, "RIGHT", 0 , 0)
	UIDropDownMenu_SetWidth(210, LunaOptionsFrame.pages[page].CopySelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].CopySelect)

	LunaOptionsFrame.pages[page].growthDesc = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].growthDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[page].CopySelect, "TOP")
	LunaOptionsFrame.pages[page].growthDesc:SetText(L["Copy Settings for new Profile from *"])

	LunaOptionsFrame.pages[page].SelectProfileHeader = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[page].SelectProfileHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].NewProfileHeader, "TOPLEFT", 0, -80)
	LunaOptionsFrame.pages[page].SelectProfileHeader:SetHeight(24)
	LunaOptionsFrame.pages[page].SelectProfileHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[page].SelectProfileHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[page].SelectProfileHeader:SetText(L["Select Profile"])

	LunaOptionsFrame.pages[page].ProfileSelect = CreateFrame("Button", "ProfileSelect", LunaOptionsFrame.pages[page], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[page].ProfileSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].SelectProfileHeader, "BOTTOMLEFT", -22 , -10)
	UIDropDownMenu_SetWidth(210, LunaOptionsFrame.pages[page].ProfileSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[page].ProfileSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].ProfileSelect, function()
		local info={}
		for k,v in pairs(LunaDB.profiles) do
			if v then
				info.text=k
				info.value=k
				info.func= function ()
					UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].ProfileSelect, this.value)
					UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].CopySelect, "")
					UIDropDownMenu_SetText("\-\-\-", LunaOptionsFrame.pages[page].CopySelect)
					LunaUF:SetProfile(this.value)
					if nonDeletables[LunaUF:GetProfile()] then
						LunaOptionsFrame.pages[page].delete:Disable()
					else
						LunaOptionsFrame.pages[page].delete:Enable()
					end
				end
				info.checked = nil
				info.checkable = true
				UIDropDownMenu_AddButton(info, 1)
			end
		end
	end)
	local _,currentProfile = LunaUF:GetProfile()
	UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].ProfileSelect, currentProfile)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[page].CopySelect, function()
		local info={}
		for k,v in pairs(LunaDB.profiles) do
			if k ~= UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[page].ProfileSelect) then
				info.text=k
				info.value=k
				info.func= function ()
					UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].CopySelect, this.value)
				end
				info.checked = nil
				info.checkable = true
				UIDropDownMenu_AddButton(info, 1)
			end
		end
		info.text="\-\-\-"
		info.value=""
		info.func= function ()
			UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].CopySelect, this.value)
		end
		info.checked = nil
		info.checkable = true
		UIDropDownMenu_AddButton(info, 1)
	end)
	UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[page].CopySelect, "")

	LunaOptionsFrame.pages[page].reset = CreateFrame("Button", "ProfileResetButton", LunaOptionsFrame.pages[page], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[page].reset:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].SelectProfileHeader, "BOTTOMLEFT", -5, -40)
	LunaOptionsFrame.pages[page].reset:SetHeight(20)
	LunaOptionsFrame.pages[page].reset:SetWidth(160)
	LunaOptionsFrame.pages[page].reset:SetText(L["Reset current Profile"])
	LunaOptionsFrame.pages[page].reset:SetScript("OnClick", function ()
		StaticPopup_Show("RESET_LUNA_PROFILE")
	end )

	LunaOptionsFrame.pages[page].delete = CreateFrame("Button", "ProfileResetButton", LunaOptionsFrame.pages[page], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[page].delete:SetPoint("TOP", LunaOptionsFrame.pages[page].reset, "BOTTOM")
	LunaOptionsFrame.pages[page].delete:SetHeight(20)
	LunaOptionsFrame.pages[page].delete:SetWidth(160)
	LunaOptionsFrame.pages[page].delete:SetText(L["Delete current Profile"])
	LunaOptionsFrame.pages[page].delete:SetScript("OnClick", function ()
		StaticPopup_Show("DELETE_LUNA_PROFILE")
	end )
	if nonDeletables[LunaUF:GetProfile()] then
		LunaOptionsFrame.pages[page].delete:Disable()
	else
		LunaOptionsFrame.pages[page].delete:Enable()
	end

	LunaOptionsFrame.pages[page].hint = LunaOptionsFrame.pages[page]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[page].hint:SetPoint("TOPLEFT", LunaOptionsFrame.pages[page].delete, "BOTTOMLEFT", 0, -40)
	LunaOptionsFrame.pages[page].hint:SetText(L["* Copying from the active profile is not possible"])

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
-- 			if LunaOptionsFrame.helpframescrollchild.texts[count]:GetStringWidth() > 281 then
-- 				LunaOptionsFrame.helpframescrollchild.texts[count]:SetHeight(22)
-- 			else
-- 				LunaOptionsFrame.helpframescrollchild.texts[count]:SetHeight(11)
-- 			end
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
