local L = LunaUF.L
local OptionsPageNames = {L["General"],L["Player"],L["Pet"],L["Target"],L["ToT"],L["ToToT"],L["Party"],L["Party Target"],L["Party Pet"],L["Raid"],L["Clickcasting"],L["Config Mode"],L["Reset Settings"]}
local shownFrame = 1
local WithTags = {
	["healthBar"] = true,
	["powerBar"] = true,
	["druidBar"] = true,
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
		frame[name].sizeslider:SetMinMaxValues(1,50)
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
				frame[barname].middle:SetScript("OnEnterPressed", function()
					this:ClearFocus()
					this.config.center = this:GetText()
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
				frame[barname].left:SetScript("OnEnterPressed", function()
					this:ClearFocus()
					this.config.left = this:GetText()
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
				frame[barname].right:SetScript("OnEnterPressed", function()
					this:ClearFocus()
					this.config.right = this:GetText()
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
		if frame.selectedID < frame.numhBars then
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
	for i,unit in pairs({[2]="player",[3]="pet",[4]="target",[5]="targettarget",[6]="targettargettarget",[7]="party",[8]="partytarget",[9]="partypet",[10]="raid"}) do
		LunaOptionsFrame.pages[i].enable:SetChecked(LunaUF.db.profile.units[unit].enabled)
		LunaOptionsFrame.pages[i].heightslider:SetValue(LunaUF.db.profile.units[unit].size.y)
		LunaOptionsFrame.pages[i].widthslider:SetValue(LunaUF.db.profile.units[unit].size.x)
		LunaOptionsFrame.pages[i].scaleslider:SetValue(LunaUF.db.profile.units[unit].scale)
		LunaOptionsFrame.pages[i].indicators.load(LunaOptionsFrame.pages[i].indicators,LunaUF.db.profile.units[unit].indicators.icons)
		LunaOptionsFrame.pages[i].enableFader:SetChecked(LunaUF.db.profile.units[unit].fader.enabled)
		LunaOptionsFrame.pages[i].FaderCombatslider:SetValue(LunaUF.db.profile.units[unit].fader.combatAlpha)
		LunaOptionsFrame.pages[i].FaderNonCombatslider:SetValue(LunaUF.db.profile.units[unit].fader.inactiveAlpha)
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
		LunaOptionsFrame.pages[i].powersizeslider:SetValue(LunaUF.db.profile.units[unit].powerBar.size)
		LunaOptionsFrame.pages[i].invertPower:SetChecked(LunaUF.db.profile.units[unit].powerBar.invert)
		LunaOptionsFrame.pages[i].vertPower:SetChecked(LunaUF.db.profile.units[unit].powerBar.vertical)
		LunaOptionsFrame.pages[i].enablecast:SetChecked(LunaUF.db.profile.units[unit].castBar.enabled)
		LunaOptionsFrame.pages[i].casthide:SetChecked(LunaUF.db.profile.units[unit].castBar.hide)
		LunaOptionsFrame.pages[i].castsizeslider:SetValue(LunaUF.db.profile.units[unit].castBar.size)
		LunaOptionsFrame.pages[i].enableheal:SetChecked(LunaUF.db.profile.units[unit].incheal.enabled)
		LunaOptionsFrame.pages[i].healsizeslider:SetValue(LunaUF.db.profile.units[unit].incheal.cap*100)
		LunaOptionsFrame.pages[i].enableauras:SetChecked(LunaUF.db.profile.units[unit].auras.enabled)
		SetDropDownValue(LunaOptionsFrame.pages[i].auraposition,LunaUF.db.profile.units[unit].auras.position)
		LunaOptionsFrame.pages[i].aurasizeslider:SetValue(17-LunaUF.db.profile.units[unit].auras.AurasPerRow)
		LunaOptionsFrame.pages[i].enabletags:SetChecked(LunaUF.db.profile.units[unit].tags.enabled)
		LunaOptionsFrame.pages[i].tags.load(LunaOptionsFrame.pages[i].tags,LunaUF.db.profile.units[unit].tags.bartags)
		LunaOptionsFrame.pages[i].barorder.load(LunaOptionsFrame.pages[i].barorder,LunaUF.db.profile.units[unit].barorder)
	end
	
	for i,class in ipairs({"PRIEST","PALADIN","SHAMAN","WARRIOR","ROGUE","MAGE","WARLOCK","DRUID","HUNTER"}) do
		LunaOptionsFrame.pages[1][class].load(LunaOptionsFrame.pages[1][class],LunaUF.db.profile.classColors[class])
	end
	for name,_ in pairs(LunaUF.db.profile.healthColors) do
		LunaOptionsFrame.pages[1][name].load(LunaOptionsFrame.pages[1][name],LunaUF.db.profile.healthColors[name])
	end
	for name,_ in pairs(LunaUF.db.profile.powerColors) do
		LunaOptionsFrame.pages[1][name].load(LunaOptionsFrame.pages[1][name],LunaUF.db.profile.powerColors[name])
	end
	for name,_ in pairs(LunaUF.db.profile.castColors) do
		LunaOptionsFrame.pages[1][name].load(LunaOptionsFrame.pages[1][name],LunaUF.db.profile.castColors[name])
	end
	for name,_ in pairs(LunaUF.db.profile.xpColors) do
		LunaOptionsFrame.pages[1][name].load(LunaOptionsFrame.pages[1][name],LunaUF.db.profile.xpColors[name])
	end
	SetDropDownValue(LunaOptionsFrame.pages[1].FontSelect,LunaUF.db.profile.font)
	SetDropDownValue(LunaOptionsFrame.pages[1].TextureSelect,LunaUF.db.profile.texture)
	SetDropDownValue(LunaOptionsFrame.pages[1].AuraBorderSelect,LunaUF.db.profile.auraborderType)
	LunaOptionsFrame.pages[1].enableTTips:SetChecked(LunaUF.db.profile.tooltipCombat)
	LunaOptionsFrame.pages[1].alphaslider:SetValue(LunaUF.db.profile.bars.alpha)
	LunaOptionsFrame.pages[1].bgalphaslider:SetValue(LunaUF.db.profile.bars.backgroundAlpha)
	LunaOptionsFrame.pages[1].castbar:SetChecked(LunaUF.db.profile.blizzard.castbar)
	LunaOptionsFrame.pages[1].buffs:SetChecked(LunaUF.db.profile.blizzard.buffs)
	LunaOptionsFrame.pages[1].weaponbuffs:SetChecked(LunaUF.db.profile.blizzard.weaponbuffs)
	LunaOptionsFrame.pages[1].player:SetChecked(LunaUF.db.profile.blizzard.player)
	LunaOptionsFrame.pages[1].pet:SetChecked(LunaUF.db.profile.blizzard.pet)
	LunaOptionsFrame.pages[1].party:SetChecked(LunaUF.db.profile.blizzard.party)
	LunaOptionsFrame.pages[1].target:SetChecked(LunaUF.db.profile.blizzard.target)
	LunaOptionsFrame.pages[2].ticker:SetChecked(LunaUF.db.profile.units.player.powerBar.ticker)
	LunaOptionsFrame.pages[2].enabletotem:SetChecked(LunaUF.db.profile.units.player.totemBar.enabled)
	LunaOptionsFrame.pages[2].totemhide:SetChecked(LunaUF.db.profile.units.player.totemBar.hide)
	LunaOptionsFrame.pages[2].totemsizeslider:SetValue(LunaUF.db.profile.units.player.totemBar.size)
	LunaOptionsFrame.pages[2].enabledruid:SetChecked(LunaUF.db.profile.units.player.druidBar.enabled)
	LunaOptionsFrame.pages[2].druidsizeslider:SetValue(LunaUF.db.profile.units.player.druidBar.size)
	LunaOptionsFrame.pages[2].enablexp:SetChecked(LunaUF.db.profile.units.player.xpBar.enabled)
	LunaOptionsFrame.pages[2].xpsizeslider:SetValue(LunaUF.db.profile.units.player.xpBar.size)
	LunaOptionsFrame.pages[3].enablexp:SetChecked(LunaUF.db.profile.units.pet.xpBar.enabled)
	LunaOptionsFrame.pages[3].xpsizeslider:SetValue(LunaUF.db.profile.units.pet.xpBar.size)
	LunaOptionsFrame.pages[4].enablecombo:SetChecked(LunaUF.db.profile.units.target.comboPoints.enabled)
	SetDropDownValue(LunaOptionsFrame.pages[4].combogrowth,LunaUF.db.profile.units.target.comboPoints.growth)
	LunaOptionsFrame.pages[4].combosizeslider:SetValue(LunaUF.db.profile.units.target.comboPoints.size)
	LunaOptionsFrame.pages[7].enablerange:SetChecked(LunaUF.db.profile.units.party.range.enabled)
	LunaOptionsFrame.pages[7].partyrangealpha:SetValue(LunaUF.db.profile.units.party.range.alpha)
	LunaOptionsFrame.pages[7].inraid:SetChecked(LunaUF.db.profile.units.party.inraid)
	LunaOptionsFrame.pages[7].playerparty:SetChecked(LunaUF.db.profile.units.party.player)
	LunaOptionsFrame.pages[7].partypadding:SetValue(LunaUF.db.profile.units.party.padding)
	SetDropDownValue(LunaOptionsFrame.pages[7].sortby,LunaUF.db.profile.units.party.sortby)
	SetDropDownValue(LunaOptionsFrame.pages[7].orderby,LunaUF.db.profile.units.party.order)
	SetDropDownValue(LunaOptionsFrame.pages[7].growth,LunaUF.db.profile.units.party.growth)
	LunaOptionsFrame.pages[10].enablerange:SetChecked(LunaUF.db.profile.units.raid.range.enabled)
	LunaOptionsFrame.pages[10].raidrangealpha:SetValue(LunaUF.db.profile.units.raid.range.alpha)
	LunaOptionsFrame.pages[10].enabletracker:SetChecked(LunaUF.db.profile.units.raid.squares.enabled)
	LunaOptionsFrame.pages[10].outersizeslider:SetValue(LunaUF.db.profile.units.raid.squares.outersize)
	LunaOptionsFrame.pages[10].enabledebuffs:SetChecked(LunaUF.db.profile.units.raid.squares.enabledebuffs)
	LunaOptionsFrame.pages[10].owndebuffs:SetChecked(LunaUF.db.profile.units.raid.squares.dispellabledebuffs)
	LunaOptionsFrame.pages[10].aggro:SetChecked(LunaUF.db.profile.units.raid.squares.aggro)
	LunaOptionsFrame.pages[10].aggrocolor.load(LunaOptionsFrame.pages[10].aggrocolor,LunaUF.db.profile.units.raid.squares.aggrocolor)
	LunaOptionsFrame.pages[10].hottracker:SetChecked(LunaUF.db.profile.units.raid.squares.hottracker)
	LunaOptionsFrame.pages[10].innersizeslider:SetValue(LunaUF.db.profile.units.raid.squares.innersize)
	LunaOptionsFrame.pages[10].colors:SetChecked(LunaUF.db.profile.units.raid.squares.colors)
	LunaOptionsFrame.pages[10].firstbuff:SetText(LunaUF.db.profile.units.raid.squares.buffs.names[1])
	LunaOptionsFrame.pages[10].firstbuffcolor.load(LunaOptionsFrame.pages[10].firstbuffcolor,LunaUF.db.profile.units.raid.squares.buffs.colors[1])
	LunaOptionsFrame.pages[10].secondbuff:SetText(LunaUF.db.profile.units.raid.squares.buffs.names[2])
	LunaOptionsFrame.pages[10].secondbuffcolor.load(LunaOptionsFrame.pages[10].secondbuffcolor,LunaUF.db.profile.units.raid.squares.buffs.colors[2])
	LunaOptionsFrame.pages[10].thirdbuff:SetText(LunaUF.db.profile.units.raid.squares.buffs.names[3])
	LunaOptionsFrame.pages[10].thirdbuffcolor.load(LunaOptionsFrame.pages[10].thirdbuffcolor,LunaUF.db.profile.units.raid.squares.buffs.colors[3])
	LunaOptionsFrame.pages[10].firstdebuff:SetText(LunaUF.db.profile.units.raid.squares.debuffs.names[1])
	LunaOptionsFrame.pages[10].firstdebuffcolor.load(LunaOptionsFrame.pages[10].firstdebuffcolor,LunaUF.db.profile.units.raid.squares.debuffs.colors[1])
	LunaOptionsFrame.pages[10].seconddebuff:SetText(LunaUF.db.profile.units.raid.squares.debuffs.names[2])
	LunaOptionsFrame.pages[10].seconddebuffcolor.load(LunaOptionsFrame.pages[10].seconddebuffcolor,LunaUF.db.profile.units.raid.squares.debuffs.colors[2])
	LunaOptionsFrame.pages[10].thirddebuff:SetText(LunaUF.db.profile.units.raid.squares.debuffs.names[3])
	LunaOptionsFrame.pages[10].thirddebuffcolor.load(LunaOptionsFrame.pages[10].thirddebuffcolor,LunaUF.db.profile.units.raid.squares.debuffs.colors[3])
	LunaOptionsFrame.pages[10].showparty:SetChecked(LunaUF.db.profile.units.raid.showparty)
	LunaOptionsFrame.pages[10].showalways:SetChecked(LunaUF.db.profile.units.raid.showalways)
	LunaOptionsFrame.pages[10].raidpadding:SetValue(LunaUF.db.profile.units.raid.padding)
	LunaOptionsFrame.pages[10].petgrp:SetChecked(LunaUF.db.profile.units.raid.petgrp)
	LunaOptionsFrame.pages[10].interlock:SetChecked(LunaUF.db.profile.units.raid.interlock)
	SetDropDownValue(LunaOptionsFrame.pages[10].interlockgrowth,LunaUF.db.profile.units.raid.interlockgrowth)
	SetDropDownValue(LunaOptionsFrame.pages[10].sortby,LunaUF.db.profile.units.raid.sortby)
	SetDropDownValue(LunaOptionsFrame.pages[10].orderby,LunaUF.db.profile.units.raid.order)
	SetDropDownValue(LunaOptionsFrame.pages[10].growth,LunaUF.db.profile.units.raid.growth)
	SetDropDownValue(LunaOptionsFrame.pages[10].mode,LunaUF.db.profile.units.raid.mode)
	ToggleDropDownMenu(1,nil,LunaOptionsFrame.pages[10].mode)
	LunaOptionsFrame.pages[11].Load()
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

	LunaOptionsFrame.Button0 = CreateFrame("Button", "LunaGeneralButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button0:SetPoint("TOPLEFT", LunaOptionsFrame, "TOPLEFT", 20, -70)
	LunaOptionsFrame.Button0:SetHeight(20)
	LunaOptionsFrame.Button0:SetWidth(140)
	LunaOptionsFrame.Button0:SetText(L["General"])
	LunaOptionsFrame.Button0:SetScript("OnClick", OnPageSwitch)
	LunaOptionsFrame.Button0.id = 1

	LunaOptionsFrame.Button1 = CreateFrame("Button", "LunaPlayerButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button1:SetPoint("TOPLEFT", LunaOptionsFrame.Button0, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button1:SetHeight(20)
	LunaOptionsFrame.Button1:SetWidth(140)
	LunaOptionsFrame.Button1:SetText(L["Player"])
	LunaOptionsFrame.Button1:SetScript("OnClick", OnPageSwitch)
	LunaOptionsFrame.Button1.id = 2

	LunaOptionsFrame.Button2 = CreateFrame("Button", "LunaPetButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button2:SetPoint("TOPLEFT", LunaOptionsFrame.Button1, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button2:SetHeight(20)
	LunaOptionsFrame.Button2:SetWidth(140)
	LunaOptionsFrame.Button2:SetText(L["Pet"])
	LunaOptionsFrame.Button2:SetScript("OnClick", OnPageSwitch)
	LunaOptionsFrame.Button2.id = 3

	LunaOptionsFrame.Button3 = CreateFrame("Button", "LunaTargetButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button3:SetPoint("TOPLEFT", LunaOptionsFrame.Button2, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button3:SetHeight(20)
	LunaOptionsFrame.Button3:SetWidth(140)
	LunaOptionsFrame.Button3:SetText(L["Target"])
	LunaOptionsFrame.Button3:SetScript("OnClick", OnPageSwitch)
	LunaOptionsFrame.Button3.id = 4

	LunaOptionsFrame.Button4 = CreateFrame("Button", "LunaToTButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button4:SetPoint("TOPLEFT", LunaOptionsFrame.Button3, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button4:SetHeight(20)
	LunaOptionsFrame.Button4:SetWidth(140)
	LunaOptionsFrame.Button4:SetText(L["ToT"])
	LunaOptionsFrame.Button4:SetScript("OnClick", OnPageSwitch)
	LunaOptionsFrame.Button4.id = 5

	LunaOptionsFrame.Button5 = CreateFrame("Button", "LunaToToTButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button5:SetPoint("TOPLEFT", LunaOptionsFrame.Button4, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button5:SetHeight(20)
	LunaOptionsFrame.Button5:SetWidth(140)
	LunaOptionsFrame.Button5:SetText(L["ToToT"])
	LunaOptionsFrame.Button5:SetScript("OnClick", OnPageSwitch)
	LunaOptionsFrame.Button5.id = 6

	LunaOptionsFrame.Button6 = CreateFrame("Button", "LunaPartyButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button6:SetPoint("TOPLEFT", LunaOptionsFrame.Button5, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button6:SetHeight(20)
	LunaOptionsFrame.Button6:SetWidth(140)
	LunaOptionsFrame.Button6:SetText(L["Party"])
	LunaOptionsFrame.Button6:SetScript("OnClick", OnPageSwitch)
	LunaOptionsFrame.Button6.id = 7

	LunaOptionsFrame.Button7 = CreateFrame("Button", "LunaPartyTargetButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button7:SetPoint("TOPLEFT", LunaOptionsFrame.Button6, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button7:SetHeight(20)
	LunaOptionsFrame.Button7:SetWidth(140)
	LunaOptionsFrame.Button7:SetText(L["Party Target"])
	LunaOptionsFrame.Button7:SetScript("OnClick", OnPageSwitch)
	LunaOptionsFrame.Button7.id = 8

	LunaOptionsFrame.Button8 = CreateFrame("Button", "LunaPartyPetButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button8:SetPoint("TOPLEFT", LunaOptionsFrame.Button7, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button8:SetHeight(20)
	LunaOptionsFrame.Button8:SetWidth(140)
	LunaOptionsFrame.Button8:SetText(L["Party Pet"])
	LunaOptionsFrame.Button8:SetScript("OnClick", OnPageSwitch)
	LunaOptionsFrame.Button8.id = 9

	LunaOptionsFrame.Button9 = CreateFrame("Button", "LunaRaidButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button9:SetPoint("TOPLEFT", LunaOptionsFrame.Button8, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button9:SetHeight(20)
	LunaOptionsFrame.Button9:SetWidth(140)
	LunaOptionsFrame.Button9:SetText(L["Raid"])
	LunaOptionsFrame.Button9:SetScript("OnClick", OnPageSwitch)
	LunaOptionsFrame.Button9.id = 10

	LunaOptionsFrame.Button10 = CreateFrame("Button", "LunaClickcastingButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button10:SetPoint("TOPLEFT", LunaOptionsFrame.Button9, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button10:SetHeight(20)
	LunaOptionsFrame.Button10:SetWidth(140)
	LunaOptionsFrame.Button10:SetText(L["Clickcasting"])
	LunaOptionsFrame.Button10:SetScript("OnClick", OnPageSwitch)
	LunaOptionsFrame.Button10.id = 11

	LunaOptionsFrame.Button11 = CreateFrame("Button", "LunaConfigModeButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button11:SetPoint("TOPLEFT", LunaOptionsFrame.Button10, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.Button11:SetHeight(20)
	LunaOptionsFrame.Button11:SetWidth(140)
	LunaOptionsFrame.Button11:SetText(L["Config Mode"])
	LunaOptionsFrame.Button11:SetScript("OnClick", function () 
		if LunaUF.db.profile.locked then
			LunaUF:SystemMessage(L["LunaUF: Entering config mode."])
			LunaUF.db.profile.locked = false
		else
			LunaUF:SystemMessage(L["LunaUF: Exiting config mode."])
			LunaUF.db.profile.locked = true
		end
		LunaUF:LoadUnits()
	end	)
	LunaOptionsFrame.Button11.id = 12

	LunaOptionsFrame.Button12 = CreateFrame("Button", "LunaResetSettingsButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button12:SetPoint("TOPLEFT", LunaOptionsFrame.Button11, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button12:SetHeight(20)
	LunaOptionsFrame.Button12:SetWidth(140)
	LunaOptionsFrame.Button12:SetText(L["Reset Settings"])
	LunaOptionsFrame.Button12:SetScript("OnClick", function ()
		StaticPopup_Show("RESET_LUNA")
	end )
	LunaOptionsFrame.Button12.id = 13

	LunaOptionsFrame.pages[1].cColorHeader = LunaOptionsFrame.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[1].cColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -40)
	LunaOptionsFrame.pages[1].cColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[1].cColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[1].cColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[1].cColorHeader:SetText(L["Classcolors"])
	
	for i,class in ipairs({"PRIEST","PALADIN","SHAMAN","WARRIOR","ROGUE","MAGE","WARLOCK","DRUID","HUNTER"}) do
		LunaOptionsFrame.pages[1][class] = CreateColorSelect(LunaOptionsFrame.pages[1], LunaUF.db.profile.classColors[class])
		LunaOptionsFrame.pages[1][class]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20+(((i-(3*math.floor((i-1)/3)))-1)*120), -70-(math.floor((i-1)/3)*30))
		LunaOptionsFrame.pages[1][class]:SetHeight(19)
		LunaOptionsFrame.pages[1][class]:SetWidth(19)
		LunaOptionsFrame.pages[1][class].text:SetText(L[class])
		LunaOptionsFrame.pages[1][class].colorSwatch:SetVertexColor(LunaUF.db.profile.classColors[class].r, LunaUF.db.profile.classColors[class].g, LunaUF.db.profile.classColors[class].b)
	end
	
	LunaOptionsFrame.pages[1].hColorHeader = LunaOptionsFrame.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[1].hColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -170)
	LunaOptionsFrame.pages[1].hColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[1].hColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[1].hColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[1].hColorHeader:SetText(L["Healthcolors"])
	
	local num = 1
	for name,options in pairs(LunaUF.db.profile.healthColors) do
		LunaOptionsFrame.pages[1][name] = CreateColorSelect(LunaOptionsFrame.pages[1], options)
		LunaOptionsFrame.pages[1][name]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20+(((num-(4*math.floor((num-1)/4)))-1)*120), -200-(math.floor((num-1)/4)*30))
		LunaOptionsFrame.pages[1][name]:SetHeight(19)
		LunaOptionsFrame.pages[1][name]:SetWidth(19)
		LunaOptionsFrame.pages[1][name].text:SetText(L[name])
		LunaOptionsFrame.pages[1][name].colorSwatch:SetVertexColor(options.r, options.g, options.b)
		num = num+1
	end
	
	LunaOptionsFrame.pages[1].pColorHeader = LunaOptionsFrame.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[1].pColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -300)
	LunaOptionsFrame.pages[1].pColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[1].pColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[1].pColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[1].pColorHeader:SetText(L["Powercolors"])
	
	local num = 1
	for name,options in pairs(LunaUF.db.profile.powerColors) do
		LunaOptionsFrame.pages[1][name] = CreateColorSelect(LunaOptionsFrame.pages[1], options)
		LunaOptionsFrame.pages[1][name]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20+(((num-(3*math.floor((num-1)/3)))-1)*120), -330-(math.floor((num-1)/3)*30))
		LunaOptionsFrame.pages[1][name]:SetHeight(19)
		LunaOptionsFrame.pages[1][name]:SetWidth(19)
		LunaOptionsFrame.pages[1][name].text:SetText(L[name])
		LunaOptionsFrame.pages[1][name].colorSwatch:SetVertexColor(options.r, options.g, options.b)
		num = num+1
	end
	
	LunaOptionsFrame.pages[1].castColorHeader = LunaOptionsFrame.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[1].castColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -400)
	LunaOptionsFrame.pages[1].castColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[1].castColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[1].castColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[1].castColorHeader:SetText(L["Castcolors"])
	
	local num = 1
	for name,options in pairs(LunaUF.db.profile.castColors) do
		LunaOptionsFrame.pages[1][name] = CreateColorSelect(LunaOptionsFrame.pages[1], options)
		LunaOptionsFrame.pages[1][name]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20+(((num-(3*math.floor((num-1)/3)))-1)*120), -430-(math.floor((num-1)/3)*30))
		LunaOptionsFrame.pages[1][name]:SetHeight(19)
		LunaOptionsFrame.pages[1][name]:SetWidth(19)
		LunaOptionsFrame.pages[1][name].text:SetText(L[name])
		LunaOptionsFrame.pages[1][name].colorSwatch:SetVertexColor(options.r, options.g, options.b)
		num = num+1
	end
	
	LunaOptionsFrame.pages[1].xpColorHeader = LunaOptionsFrame.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[1].xpColorHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -450)
	LunaOptionsFrame.pages[1].xpColorHeader:SetHeight(24)
	LunaOptionsFrame.pages[1].xpColorHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[1].xpColorHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[1].xpColorHeader:SetText(L["Xpcolors"])
	
	local num = 1
	for name,options in pairs(LunaUF.db.profile.xpColors) do
		LunaOptionsFrame.pages[1][name] = CreateColorSelect(LunaOptionsFrame.pages[1], options)
		LunaOptionsFrame.pages[1][name]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20+(((num-(3*math.floor((num-1)/3)))-1)*120), -480-(math.floor((num-1)/3)*30))
		LunaOptionsFrame.pages[1][name]:SetHeight(19)
		LunaOptionsFrame.pages[1][name]:SetWidth(19)
		LunaOptionsFrame.pages[1][name].text:SetText(L[name])
		LunaOptionsFrame.pages[1][name].colorSwatch:SetVertexColor(options.r, options.g, options.b)
		num = num+1
	end

	LunaOptionsFrame.pages[1].fontHeader = LunaOptionsFrame.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[1].fontHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -510)
	LunaOptionsFrame.pages[1].fontHeader:SetHeight(24)
	LunaOptionsFrame.pages[1].fontHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[1].fontHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[1].fontHeader:SetText(L["Font"])
	
	LunaOptionsFrame.pages[1].FontSelect = CreateFrame("Button", "FontSelector", LunaOptionsFrame.pages[1], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[1].FontSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 0 , -540)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[1].FontSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[1].FontSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[1].FontSelect, function()
		local info={}
		for k,v in ipairs({"Aldrich","Bangers","Celestia","DorisPP","Enigmatic","FasterOne","Fitzgerald","Gentium","Iceland","Inconsolata","LiberationSans","Luna","MetalLord","Optimus","TradeWinds","VeraSerif","Yellowjacket"}) do
			info.text=v
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[1].FontSelect, this:GetID())
				LunaUF.db.profile.font = UIDropDownMenu_GetText(LunaOptionsFrame.pages[1].FontSelect)
				for _,frame in pairs(LunaUF.Units.frameList) do
					LunaUF.Units.FullUpdate(frame)
				end
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	LunaOptionsFrame.pages[1].textureHeader = LunaOptionsFrame.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[1].textureHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -570)
	LunaOptionsFrame.pages[1].textureHeader:SetHeight(24)
	LunaOptionsFrame.pages[1].textureHeader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[1].textureHeader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[1].textureHeader:SetText(L["Textures"])
	
	LunaOptionsFrame.pages[1].textureDesc = LunaOptionsFrame.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[1].textureDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -600)
	LunaOptionsFrame.pages[1].textureDesc:SetText(L["Bar Texture"])
	
	LunaOptionsFrame.pages[1].TextureSelect = CreateFrame("Button", "TextureSelector", LunaOptionsFrame.pages[1], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[1].TextureSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 0 , -615)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[1].TextureSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[1].TextureSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[1].TextureSelect, function()
		local info={}
		for k,v in ipairs({"Aluminium","Armory","BantoBar","Bars","Button","Charcoal","Cilo","Dabs","Diagonal","Fifths","Fourths","Glamour","Glamour2","Glamour3","Glamour4","Glamour5","Glamour6","Glamour7","Glaze","Gloss","Healbot","Luna","Lyfe","Otravi","Perl2","Ruben","Skewed","Smooth","Striped","Wisps"}) do
			info.text=v
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[1].TextureSelect, this:GetID())
				LunaUF.db.profile.texture = UIDropDownMenu_GetText(LunaOptionsFrame.pages[1].TextureSelect)
				for _,frame in pairs(LunaUF.Units.frameList) do
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	LunaOptionsFrame.pages[1].AuraDesc = LunaOptionsFrame.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[1].AuraDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 150, -600)
	LunaOptionsFrame.pages[1].AuraDesc:SetText(L["Aura Border"])
	
	LunaOptionsFrame.pages[1].AuraBorderSelect = CreateFrame("Button", "AuraBorderSelector", LunaOptionsFrame.pages[1], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[1].AuraBorderSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 130 , -615)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[1].AuraBorderSelect)
	UIDropDownMenu_JustifyText("RIGHT", LunaOptionsFrame.pages[1].AuraBorderSelect)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[1].AuraBorderSelect, function()
		local info={}
		for k,v in ipairs({L["none"],"dark","light","blizzard"}) do
			info.text=v
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[1].AuraBorderSelect, this:GetID())
				LunaUF.db.profile.auraborderType = UIDropDownMenu_GetText(LunaOptionsFrame.pages[1].AuraBorderSelect)
				for _,frame in pairs(LunaUF.Units.frameList) do
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	LunaOptionsFrame.pages[1].Tooltips = LunaOptionsFrame.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[1].Tooltips:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -650)
	LunaOptionsFrame.pages[1].Tooltips:SetHeight(24)
	LunaOptionsFrame.pages[1].Tooltips:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[1].Tooltips:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[1].Tooltips:SetText(L["Tooltips"])
	
	LunaOptionsFrame.pages[1].enableTTips = CreateFrame("CheckButton", "EnableTTips", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].enableTTips:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -670)
	LunaOptionsFrame.pages[1].enableTTips:SetHeight(30)
	LunaOptionsFrame.pages[1].enableTTips:SetWidth(30)
	LunaOptionsFrame.pages[1].enableTTips:SetScript("OnClick", function()
		LunaUF.db.profile.tooltipCombat = not LunaUF.db.profile.tooltipCombat
	end)
	getglobal("EnableTTipsText"):SetText(L["Tooltips hidden in combat"])
	
	LunaOptionsFrame.pages[1].BarTrans = LunaOptionsFrame.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[1].BarTrans:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -700)
	LunaOptionsFrame.pages[1].BarTrans:SetHeight(24)
	LunaOptionsFrame.pages[1].BarTrans:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[1].BarTrans:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[1].BarTrans:SetText(L["Bar transparency"])
	
	LunaOptionsFrame.pages[1].alphaslider = CreateFrame("Slider", "BarAlphaSlider", LunaOptionsFrame.pages[1], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[1].alphaslider:SetMinMaxValues(0.01,1)
	LunaOptionsFrame.pages[1].alphaslider:SetValueStep(0.01)
	LunaOptionsFrame.pages[1].alphaslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.bars.alpha = math.floor((this:GetValue()+0.005)*100)/100
		getglobal("BarAlphaSliderText"):SetText(L["Alpha"]..": "..LunaUF.db.profile.bars.alpha)
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame:IsVisible() then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[1].alphaslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "BOTTOMLEFT", 20, -740)
	LunaOptionsFrame.pages[1].alphaslider:SetWidth(220)
	LunaOptionsFrame.pages[1].alphaslider:SetValue(LunaUF.db.profile.bars.alpha)
	
	LunaOptionsFrame.pages[1].bgalphaslider = CreateFrame("Slider", "BgBarAlphaSlider", LunaOptionsFrame.pages[1], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[1].bgalphaslider:SetMinMaxValues(0.01,1)
	LunaOptionsFrame.pages[1].bgalphaslider:SetValueStep(0.01)
	LunaOptionsFrame.pages[1].bgalphaslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.bars.backgroundAlpha = math.floor((this:GetValue()+0.005)*100)/100
		getglobal("BgBarAlphaSliderText"):SetText(L["Background alpha"]..": "..LunaUF.db.profile.bars.backgroundAlpha)
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame:IsVisible() then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[1].bgalphaslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "BOTTOMLEFT", 260, -740)
	LunaOptionsFrame.pages[1].bgalphaslider:SetWidth(220)
	LunaOptionsFrame.pages[1].bgalphaslider:SetValue(LunaUF.db.profile.bars.backgroundAlpha)
	
	LunaOptionsFrame.pages[1].blizzheader = LunaOptionsFrame.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[1].blizzheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -780)
	LunaOptionsFrame.pages[1].blizzheader:SetHeight(24)
	LunaOptionsFrame.pages[1].blizzheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[1].blizzheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[1].blizzheader:SetText(L["Blizzard frames"])
	
	LunaOptionsFrame.pages[1].castbar = CreateFrame("CheckButton", "BlizzCastbar", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].castbar:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -810)
	LunaOptionsFrame.pages[1].castbar:SetHeight(30)
	LunaOptionsFrame.pages[1].castbar:SetWidth(30)
	LunaOptionsFrame.pages[1].castbar:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.castbar = not LunaUF.db.profile.blizzard.castbar
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzCastbarText"):SetText(L["Cast bar"])
	
	LunaOptionsFrame.pages[1].buffs = CreateFrame("CheckButton", "BlizzBuffs", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].buffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 100, -810)
	LunaOptionsFrame.pages[1].buffs:SetHeight(30)
	LunaOptionsFrame.pages[1].buffs:SetWidth(30)
	LunaOptionsFrame.pages[1].buffs:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.buffs = not LunaUF.db.profile.blizzard.buffs
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzBuffsText"):SetText(L["Buffs"])
	
	LunaOptionsFrame.pages[1].weaponbuffs = CreateFrame("CheckButton", "BlizzWeaponbuffs", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].weaponbuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 180, -810)
	LunaOptionsFrame.pages[1].weaponbuffs:SetHeight(30)
	LunaOptionsFrame.pages[1].weaponbuffs:SetWidth(30)
	LunaOptionsFrame.pages[1].weaponbuffs:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.weaponbuffs = not LunaUF.db.profile.blizzard.weaponbuffs
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzWeaponbuffsText"):SetText(L["Weaponbuffs"])
	
	LunaOptionsFrame.pages[1].player = CreateFrame("CheckButton", "BlizzPlayer", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].player:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 20, -850)
	LunaOptionsFrame.pages[1].player:SetHeight(30)
	LunaOptionsFrame.pages[1].player:SetWidth(30)
	LunaOptionsFrame.pages[1].player:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.player = not LunaUF.db.profile.blizzard.player
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzPlayerText"):SetText(L["Player"])
	
	LunaOptionsFrame.pages[1].pet = CreateFrame("CheckButton", "BlizzPet", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].pet:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 100, -850)
	LunaOptionsFrame.pages[1].pet:SetHeight(30)
	LunaOptionsFrame.pages[1].pet:SetWidth(30)
	LunaOptionsFrame.pages[1].pet:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.pet = not LunaUF.db.profile.blizzard.pet
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzPetText"):SetText(L["Pet"])
	
	LunaOptionsFrame.pages[1].party = CreateFrame("CheckButton", "BlizzParty", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].party:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 180, -850)
	LunaOptionsFrame.pages[1].party:SetHeight(30)
	LunaOptionsFrame.pages[1].party:SetWidth(30)
	LunaOptionsFrame.pages[1].party:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.party = not LunaUF.db.profile.blizzard.party
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzPartyText"):SetText(L["Party"])
	
	LunaOptionsFrame.pages[1].target = CreateFrame("CheckButton", "BlizzTarget", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].target:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1], "TOPLEFT", 260, -850)
	LunaOptionsFrame.pages[1].target:SetHeight(30)
	LunaOptionsFrame.pages[1].target:SetWidth(30)
	LunaOptionsFrame.pages[1].target:SetScript("OnClick", function()
		LunaUF.db.profile.blizzard.target = not LunaUF.db.profile.blizzard.target
		LunaUF:HideBlizzard()
	end)
	getglobal("BlizzTargetText"):SetText(L["Target"])
	
	for i=2, 10 do
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
			getglobal("HeightSlider"..unit.."Text"):SetText("Height: "..LunaUF.db.profile.units[unit].size.y)
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
			getglobal("WidthSlider"..unit.."Text"):SetText("Width: "..LunaUF.db.profile.units[unit].size.x)
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
			getglobal("ScaleSlider"..unit.."Text"):SetText("Scale: "..LunaUF.db.profile.units[unit].scale)
			LunaUF.Units:InitializeFrame(unit)
		end)
		LunaOptionsFrame.pages[i].scaleslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].widthslider, "BOTTOMLEFT", 0, -30)
		LunaOptionsFrame.pages[i].scaleslider:SetWidth(460)
		
		LunaOptionsFrame.pages[i].indicatorsHeader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].indicatorsHeader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].scaleslider, "BOTTOMLEFT", 0, -30)
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
			LunaUF.db.profile.units[unit].fader.combatAlpha = math.floor(this:GetValue()*10)/10
			getglobal("FaderCombatSlider"..unit.."Text"):SetText("Combat alpha: "..LunaUF.db.profile.units[unit].fader.combatAlpha)
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
			getglobal("FaderNonCombatSlider"..unit.."Text"):SetText("Non combat alpha: "..LunaUF.db.profile.units[unit].fader.inactiveAlpha)
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unitGroup == unit then
					LunaUF.Units:SetupFrameModules(frame)
				end
			end
		end)
		LunaOptionsFrame.pages[i].FaderNonCombatslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].faderheader, "BOTTOMLEFT", 220, -50)
		LunaOptionsFrame.pages[i].FaderNonCombatslider:SetWidth(200)
		
		----
		
		LunaOptionsFrame.pages[i].ctextheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].ctextheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].faderheader, "BOTTOMLEFT", 0, -100)
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
			getglobal("CtextScale"..unit.."Text"):SetText("Size: "..LunaUF.db.profile.units[unit].combatText.size)
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
		LunaOptionsFrame.pages[i].vertHealth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].healthheader, "BOTTOMLEFT", 80, -50)
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
		getglobal("Enable"..LunaUF.unitList[i-1].."Power".."Text"):SetText(L["Enable"])
		
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
		LunaOptionsFrame.pages[i].vertPower:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].powerheader, "BOTTOMLEFT", 80, -50)
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
		LunaOptionsFrame.pages[i].healheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].castheader, "BOTTOMLEFT", 0, -60)
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
		
		LunaOptionsFrame.pages[i].tagheader = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[i].tagheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].auraheader, "BOTTOMLEFT", 0, -60)
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
	
	LunaOptionsFrame.pages[2].ticker = CreateFrame("CheckButton", "TickerplayerPower", LunaOptionsFrame.pages[2], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[2].ticker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].powerheader, "BOTTOMLEFT", 160, -50)
	LunaOptionsFrame.pages[2].ticker:SetHeight(30)
	LunaOptionsFrame.pages[2].ticker:SetWidth(30)
	LunaOptionsFrame.pages[2].ticker:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].powerBar.ticker = not LunaUF.db.profile.units[unit].powerBar.ticker
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("TickerplayerPowerText"):SetText(L["Energy / mp5 ticker"])
	
	LunaOptionsFrame.pages[2].totemheader = LunaOptionsFrame.pages[2]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[2].totemheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].barorder, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[2].totemheader:SetHeight(24)
	LunaOptionsFrame.pages[2].totemheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[2].totemheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[2].totemheader:SetText(L["Totem Bar"])
	
	LunaOptionsFrame.pages[2].enabletotem = CreateFrame("CheckButton", "EnableplayerTotems", LunaOptionsFrame.pages[2], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[2].enabletotem:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].totemheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[2].enabletotem:SetHeight(30)
	LunaOptionsFrame.pages[2].enabletotem:SetWidth(30)
	LunaOptionsFrame.pages[2].enabletotem:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].totemBar.enabled = not LunaUF.db.profile.units[unit].totemBar.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableplayerTotemsText"):SetText(L["Enable"])
	
	LunaOptionsFrame.pages[2].totemhide = CreateFrame("CheckButton", "TotemsplayerHide", LunaOptionsFrame.pages[2], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[2].totemhide:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].totemheader, "BOTTOMLEFT", 80, -10)
	LunaOptionsFrame.pages[2].totemhide:SetHeight(30)
	LunaOptionsFrame.pages[2].totemhide:SetWidth(30)
	LunaOptionsFrame.pages[2].totemhide:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].totemBar.hide = not LunaUF.db.profile.units[unit].totemBar.hide
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("TotemsplayerHideText"):SetText(L["hide"])
	
	LunaOptionsFrame.pages[2].totemsizeslider = CreateFrame("Slider", "TotemsSizeSlidertarget", LunaOptionsFrame.pages[2], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[2].totemsizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[2].totemsizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[2].totemsizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.player.totemBar.size = math.floor(this:GetValue())
		getglobal("TotemsSizeSlidertargetText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.player.totemBar.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.player)
	end)
	LunaOptionsFrame.pages[2].totemsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].totemheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[2].totemsizeslider:SetWidth(190)
	
	LunaOptionsFrame.pages[2].druidheader = LunaOptionsFrame.pages[2]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[2].druidheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].totemheader, "BOTTOMLEFT", 0, -60)
	LunaOptionsFrame.pages[2].druidheader:SetHeight(24)
	LunaOptionsFrame.pages[2].druidheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[2].druidheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[2].druidheader:SetText(L["Druid Bar"])
	
	LunaOptionsFrame.pages[2].enabledruid = CreateFrame("CheckButton", "EnableplayerDruid", LunaOptionsFrame.pages[2], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[2].enabledruid:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].druidheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[2].enabledruid:SetHeight(30)
	LunaOptionsFrame.pages[2].enabledruid:SetWidth(30)
	LunaOptionsFrame.pages[2].enabledruid:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].druidBar.enabled = not LunaUF.db.profile.units[unit].druidBar.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableplayerDruidText"):SetText(L["Enable"])
	
	LunaOptionsFrame.pages[2].druidsizeslider = CreateFrame("Slider", "DruidSizeSlidertarget", LunaOptionsFrame.pages[2], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[2].druidsizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[2].druidsizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[2].druidsizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.player.druidBar.size = math.floor(this:GetValue())
		getglobal("DruidSizeSlidertargetText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.player.druidBar.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.player)
	end)
	LunaOptionsFrame.pages[2].druidsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].druidheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[2].druidsizeslider:SetWidth(190)

	LunaOptionsFrame.pages[2].xpheader = LunaOptionsFrame.pages[2]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[2].xpheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].druidheader, "BOTTOMLEFT", 0, -60)
	LunaOptionsFrame.pages[2].xpheader:SetHeight(24)
	LunaOptionsFrame.pages[2].xpheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[2].xpheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[2].xpheader:SetText(L["XP Bar"])
	
	LunaOptionsFrame.pages[2].enablexp = CreateFrame("CheckButton", "EnableplayerXP", LunaOptionsFrame.pages[2], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[2].enablexp:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].xpheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[2].enablexp:SetHeight(30)
	LunaOptionsFrame.pages[2].enablexp:SetWidth(30)
	LunaOptionsFrame.pages[2].enablexp:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units.player.xpBar.enabled = not LunaUF.db.profile.units.player.xpBar.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableplayerXPText"):SetText(L["Enable"])
	
	LunaOptionsFrame.pages[2].xpsizeslider = CreateFrame("Slider", "XPSizeSliderplayer", LunaOptionsFrame.pages[2], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[2].xpsizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[2].xpsizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[2].xpsizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.player.xpBar.size = math.floor(this:GetValue())
		getglobal("XPSizeSliderplayerText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.player.xpBar.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.player)
	end)
	LunaOptionsFrame.pages[2].xpsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].xpheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[2].xpsizeslider:SetWidth(190)
	
	LunaOptionsFrame.pages[3].xpheader = LunaOptionsFrame.pages[3]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[3].xpheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[3].barorder, "BOTTOMLEFT", 0, -60)
	LunaOptionsFrame.pages[3].xpheader:SetHeight(24)
	LunaOptionsFrame.pages[3].xpheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[3].xpheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[3].xpheader:SetText(L["XP Bar"])
	
	LunaOptionsFrame.pages[3].enablexp = CreateFrame("CheckButton", "EnablepetXP", LunaOptionsFrame.pages[3], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[3].enablexp:SetPoint("TOPLEFT", LunaOptionsFrame.pages[3].xpheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[3].enablexp:SetHeight(30)
	LunaOptionsFrame.pages[3].enablexp:SetWidth(30)
	LunaOptionsFrame.pages[3].enablexp:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units.pet.xpBar.enabled = not LunaUF.db.profile.units.pet.xpBar.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnablepetXPText"):SetText(L["Enable"])
	
	LunaOptionsFrame.pages[3].xpsizeslider = CreateFrame("Slider", "XPSizeSliderpet", LunaOptionsFrame.pages[3], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[3].xpsizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[3].xpsizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[3].xpsizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.pet.xpBar.size = math.floor(this:GetValue())
		getglobal("XPSizeSliderpetText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.pet.xpBar.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.pet)
	end)
	LunaOptionsFrame.pages[3].xpsizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[3].xpheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[3].xpsizeslider:SetWidth(190)
	
	LunaOptionsFrame.pages[4].comboheader = LunaOptionsFrame.pages[4]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[4].comboheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[4].barorder, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[4].comboheader:SetHeight(24)
	LunaOptionsFrame.pages[4].comboheader:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[4].comboheader:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[4].comboheader:SetText(L["Combo points"])
	
	LunaOptionsFrame.pages[4].enablecombo = CreateFrame("CheckButton", "EnabletargetCombo", LunaOptionsFrame.pages[4], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[4].enablecombo:SetPoint("TOPLEFT", LunaOptionsFrame.pages[4].comboheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[4].enablecombo:SetHeight(30)
	LunaOptionsFrame.pages[4].enablecombo:SetWidth(30)
	LunaOptionsFrame.pages[4].enablecombo:SetScript("OnClick", function()
		local unit = this:GetParent().id
		LunaUF.db.profile.units[unit].comboPoints.enabled = not LunaUF.db.profile.units[unit].comboPoints.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == unit then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnabletargetCombo".."Text"):SetText(L["Enable"])
	
	LunaOptionsFrame.pages[4].combogrowth = CreateFrame("Button", "ComboGrowth", LunaOptionsFrame.pages[4], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[4].combogrowth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[4].comboheader, "BOTTOMLEFT", 60 , -10)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[4].combogrowth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[4].combogrowth)
	
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[4].combogrowth, function()
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
	
	LunaOptionsFrame.pages[4].combogrDesc = LunaOptionsFrame.pages[4]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[4].combogrDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[4].combogrowth, "TOP", 0, 0)
	LunaOptionsFrame.pages[4].combogrDesc:SetText(L["Growth"])
	
	LunaOptionsFrame.pages[4].combosizeslider = CreateFrame("Slider", "ComboSizeSlidertarget", LunaOptionsFrame.pages[4], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[4].combosizeslider:SetMinMaxValues(1,10)
	LunaOptionsFrame.pages[4].combosizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[4].combosizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.target.comboPoints.size = math.floor(this:GetValue())
		getglobal("ComboSizeSlidertargetText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.target.comboPoints.size)
		LunaUF.Units:SetupFrameModules(LunaUF.Units.unitFrames.target)
	end)
	LunaOptionsFrame.pages[4].combosizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[4].comboheader, "BOTTOMLEFT", 280, -10)
	LunaOptionsFrame.pages[4].combosizeslider:SetWidth(190)
	
	LunaOptionsFrame.pages[7].rangedesc = LunaOptionsFrame.pages[7]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[7].rangedesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].barorder, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[7].rangedesc:SetHeight(24)
	LunaOptionsFrame.pages[7].rangedesc:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[7].rangedesc:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[7].rangedesc:SetText(L["Range"])
	
	LunaOptionsFrame.pages[7].enablerange = CreateFrame("CheckButton", "EnablepartyRange", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].enablerange:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].rangedesc, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[7].enablerange:SetHeight(30)
	LunaOptionsFrame.pages[7].enablerange:SetWidth(30)
	LunaOptionsFrame.pages[7].enablerange:SetScript("OnClick", function()
		LunaUF.db.profile.units.party.range.enabled = not LunaUF.db.profile.units.party.range.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "party" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnablepartyRangeText"):SetText(L["Enable"])
	
	LunaOptionsFrame.pages[7].partyrangealpha = CreateFrame("Slider", "AlphaSliderpartyRange", LunaOptionsFrame.pages[7], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[7].partyrangealpha:SetMinMaxValues(0.1,1)
	LunaOptionsFrame.pages[7].partyrangealpha:SetValueStep(0.1)
	LunaOptionsFrame.pages[7].partyrangealpha:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.party.range.alpha = math.floor(this:GetValue()*10)/10
		getglobal("AlphaSliderpartyRangeText"):SetText(L["Alpha"]..": "..LunaUF.db.profile.units.party.range.alpha)
	end)
	LunaOptionsFrame.pages[7].partyrangealpha:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].enablerange, "TOPLEFT", 200, 0)
	LunaOptionsFrame.pages[7].partyrangealpha:SetWidth(190)
	
	LunaOptionsFrame.pages[7].partyoptions = LunaOptionsFrame.pages[7]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[7].partyoptions:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].enablerange, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[7].partyoptions:SetHeight(24)
	LunaOptionsFrame.pages[7].partyoptions:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[7].partyoptions:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[7].partyoptions:SetText(L["Partyoptions"])
	
	LunaOptionsFrame.pages[7].inraid = CreateFrame("CheckButton", "EnablepartyInRaid", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].inraid:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].partyoptions, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[7].inraid:SetHeight(30)
	LunaOptionsFrame.pages[7].inraid:SetWidth(30)
	LunaOptionsFrame.pages[7].inraid:SetScript("OnClick", function()
		LunaUF.db.profile.units.party.inraid = not LunaUF.db.profile.units.party.inraid
		LunaUF.Units:InitializeFrame("party")
	end)
	getglobal("EnablepartyInRaidText"):SetText(L["Show party in raid"])
	
	LunaOptionsFrame.pages[7].playerparty = CreateFrame("CheckButton", "EnablePlayerparty", LunaOptionsFrame.pages[7], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[7].playerparty:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].partyoptions, "BOTTOMLEFT", 150, -10)
	LunaOptionsFrame.pages[7].playerparty:SetHeight(30)
	LunaOptionsFrame.pages[7].playerparty:SetWidth(30)
	LunaOptionsFrame.pages[7].playerparty:SetScript("OnClick", function()
		LunaUF.db.profile.units.party.player = not LunaUF.db.profile.units.party.player
		LunaUF.Units:LoadGroupHeader("party")
	end)
	getglobal("EnablePlayerpartyText"):SetText(L["Player in party"])
	
	LunaOptionsFrame.pages[7].partypadding = CreateFrame("Slider", "PartyPaddingSlider", LunaOptionsFrame.pages[7], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[7].partypadding:SetMinMaxValues(1,100)
	LunaOptionsFrame.pages[7].partypadding:SetValueStep(1)
	LunaOptionsFrame.pages[7].partypadding:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.party.padding = math.floor(this:GetValue())
		getglobal("PartyPaddingSliderText"):SetText(L["Padding"]..": "..LunaUF.db.profile.units.party.padding)
		LunaUF.Units:LoadGroupHeader("party")
	end)
	LunaOptionsFrame.pages[7].partypadding:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].partyoptions, "BOTTOMLEFT", 270, -10)
	LunaOptionsFrame.pages[7].partypadding:SetWidth(200)
	
	LunaOptionsFrame.pages[7].sortby = CreateFrame("Button", "PartySortBy", LunaOptionsFrame.pages[7], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[7].sortby:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].inraid, "BOTTOMLEFT", -10 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[7].sortby)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[7].sortby)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[7].sortby, function()
		local info={}
		for k,v in pairs({[L["Name"]] = "NAME",[L["Group"]] = "GROUP"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[7].sortby, this.value)
				LunaUF.db.profile.units.party.sortby = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[7].sortby)
				LunaUF.Units:LoadGroupHeader("party")
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	LunaOptionsFrame.pages[7].sortDesc = LunaOptionsFrame.pages[7]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[7].sortDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[7].sortby, "TOP")
	LunaOptionsFrame.pages[7].sortDesc:SetText(L["Sort by"])
	
	LunaOptionsFrame.pages[7].orderby = CreateFrame("Button", "PartyOrderBy", LunaOptionsFrame.pages[7], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[7].orderby:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].inraid, "BOTTOMLEFT", 140 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[7].orderby)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[7].orderby)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[7].orderby, function()
		local info={}
		for k,v in pairs({[L["Ascending"]] = "ASC",[L["Descending"]] = "DESC"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[7].orderby, this.value)
				LunaUF.db.profile.units.party.order = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[7].orderby)
				LunaUF.Units:LoadGroupHeader("party")
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	LunaOptionsFrame.pages[7].orderDesc = LunaOptionsFrame.pages[7]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[7].orderDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[7].orderby, "TOP")
	LunaOptionsFrame.pages[7].orderDesc:SetText(L["Sort direction"])
	
	LunaOptionsFrame.pages[7].growth = CreateFrame("Button", "PartyGrowth", LunaOptionsFrame.pages[7], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[7].growth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].inraid, "BOTTOMLEFT", 300 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[7].growth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[7].growth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[7].growth, function()
		local info={}
		for k,v in pairs({[L["LEFT"]] = "LEFT",[L["RIGHT"]] = "RIGHT",[L["UP"]] = "UP",[L["DOWN"]] = "DOWN"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[7].growth, this.value)
				LunaUF.db.profile.units.party.growth = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[7].growth)
				LunaUF.Units:LoadGroupHeader("party")
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	LunaOptionsFrame.pages[7].growthDesc = LunaOptionsFrame.pages[7]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[7].growthDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[7].growth, "TOP")
	LunaOptionsFrame.pages[7].growthDesc:SetText(L["Growth direction"])
	
	LunaOptionsFrame.pages[10].rangedesc = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[10].rangedesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].barorder, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[10].rangedesc:SetHeight(24)
	LunaOptionsFrame.pages[10].rangedesc:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[10].rangedesc:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[10].rangedesc:SetText(L["Range"])
	
	LunaOptionsFrame.pages[10].enablerange = CreateFrame("CheckButton", "EnableraidRange", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].enablerange:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].rangedesc, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].enablerange:SetHeight(30)
	LunaOptionsFrame.pages[10].enablerange:SetWidth(30)
	LunaOptionsFrame.pages[10].enablerange:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.range.enabled = not LunaUF.db.profile.units.raid.range.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableraidRangeText"):SetText(L["Enable"])
	
	LunaOptionsFrame.pages[10].raidrangealpha = CreateFrame("Slider", "AlphaSliderraidRange", LunaOptionsFrame.pages[10], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[10].raidrangealpha:SetMinMaxValues(0.1,1)
	LunaOptionsFrame.pages[10].raidrangealpha:SetValueStep(0.1)
	LunaOptionsFrame.pages[10].raidrangealpha:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.range.alpha = math.floor(this:GetValue()*10)/10
		getglobal("AlphaSliderraidRangeText"):SetText(L["Alpha"]..": "..LunaUF.db.profile.units.raid.range.alpha)
	end)
	LunaOptionsFrame.pages[10].raidrangealpha:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].enablerange, "TOPLEFT", 200, 0)
	LunaOptionsFrame.pages[10].raidrangealpha:SetWidth(190)
	
	LunaOptionsFrame.pages[10].trackerDesc = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[10].trackerDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].enablerange, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[10].trackerDesc:SetHeight(24)
	LunaOptionsFrame.pages[10].trackerDesc:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[10].trackerDesc:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[10].trackerDesc:SetText(L["Auratracker"])
	
	LunaOptionsFrame.pages[10].enabletracker = CreateFrame("CheckButton", "EnableSquares", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].enabletracker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].trackerDesc, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].enabletracker:SetHeight(30)
	LunaOptionsFrame.pages[10].enabletracker:SetWidth(30)
	LunaOptionsFrame.pages[10].enabletracker:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.enabled = not LunaUF.db.profile.units.raid.squares.enabled
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	getglobal("EnableSquaresText"):SetText(L["Enable"])
	
	LunaOptionsFrame.pages[10].outersizeslider = CreateFrame("Slider", "OuterSizeSliderTracker", LunaOptionsFrame.pages[10], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[10].outersizeslider:SetMinMaxValues(1,20)
	LunaOptionsFrame.pages[10].outersizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[10].outersizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.squares.outersize = math.floor(this:GetValue())
		getglobal("OuterSizeSliderTrackerText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.raid.squares.outersize)
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[10].outersizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].trackerDesc, "BOTTOMLEFT", 200, -10)
	LunaOptionsFrame.pages[10].outersizeslider:SetWidth(230)
	
	LunaOptionsFrame.pages[10].enabledebuffs = CreateFrame("CheckButton", "EnableDebuffs", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].enabledebuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].enabletracker, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].enabledebuffs:SetHeight(30)
	LunaOptionsFrame.pages[10].enabledebuffs:SetWidth(30)
	LunaOptionsFrame.pages[10].enabledebuffs:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.enabledebuffs = not LunaUF.db.profile.units.raid.squares.enabledebuffs
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableDebuffsText"):SetText(L["Show dispellable debuffs"])
	
	LunaOptionsFrame.pages[10].owndebuffs = CreateFrame("CheckButton", "EnableOwnDebuffs", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].owndebuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].enabletracker, "BOTTOMLEFT", 200, -10)
	LunaOptionsFrame.pages[10].owndebuffs:SetHeight(30)
	LunaOptionsFrame.pages[10].owndebuffs:SetWidth(30)
	LunaOptionsFrame.pages[10].owndebuffs:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.dispellabledebuffs = not LunaUF.db.profile.units.raid.squares.dispellabledebuffs
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableOwnDebuffsText"):SetText(L["Only debuffs you can dispel"])
	
	LunaOptionsFrame.pages[10].aggro = CreateFrame("CheckButton", "EnableAggro", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].aggro:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].enabledebuffs, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].aggro:SetHeight(30)
	LunaOptionsFrame.pages[10].aggro:SetWidth(30)
	LunaOptionsFrame.pages[10].aggro:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.aggro = not LunaUF.db.profile.units.raid.squares.aggro
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableAggroText"):SetText(L["Show aggro"])
	
	LunaOptionsFrame.pages[10].aggrocolor = CreateColorSelect(LunaOptionsFrame.pages[10], LunaUF.db.profile.units.raid.squares.aggrocolor, "AggroColorSelect")
	LunaOptionsFrame.pages[10].aggrocolor:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].aggro, "TOPLEFT", 205, -5)
	LunaOptionsFrame.pages[10].aggrocolor:SetHeight(19)
	LunaOptionsFrame.pages[10].aggrocolor:SetWidth(19)
	LunaOptionsFrame.pages[10].aggrocolor.text:SetText(L["Aggrocolor"])
	LunaOptionsFrame.pages[10].aggrocolor.colorSwatch:SetVertexColor(LunaUF.db.profile.units.raid.squares.aggrocolor.r, LunaUF.db.profile.units.raid.squares.aggrocolor.g, LunaUF.db.profile.units.raid.squares.aggrocolor.b)
	
	LunaOptionsFrame.pages[10].hottracker = CreateFrame("CheckButton", "EnableHotTracker", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].hottracker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].aggro, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].hottracker:SetHeight(30)
	LunaOptionsFrame.pages[10].hottracker:SetWidth(30)
	LunaOptionsFrame.pages[10].hottracker:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.hottracker = not LunaUF.db.profile.units.raid.squares.hottracker
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableHotTrackerText"):SetText(L["Track heal over time"])
	
	LunaOptionsFrame.pages[10].innersizeslider = CreateFrame("Slider", "InnerSizeSliderTracker", LunaOptionsFrame.pages[10], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[10].innersizeslider:SetMinMaxValues(1,30)
	LunaOptionsFrame.pages[10].innersizeslider:SetValueStep(1)
	LunaOptionsFrame.pages[10].innersizeslider:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.squares.innersize = math.floor(this:GetValue())
		getglobal("InnerSizeSliderTrackerText"):SetText(L["Size"]..": "..LunaUF.db.profile.units.raid.squares.innersize)
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units:SetupFrameModules(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[10].innersizeslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].hottracker, "TOPLEFT", 200, 0)
	LunaOptionsFrame.pages[10].innersizeslider:SetWidth(230)
	
	LunaOptionsFrame.pages[10].colors = CreateFrame("CheckButton", "EnableColorsTracker", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].colors:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].hottracker, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].colors:SetHeight(30)
	LunaOptionsFrame.pages[10].colors:SetWidth(30)
	LunaOptionsFrame.pages[10].colors:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.squares.colors = not LunaUF.db.profile.units.raid.squares.colors
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	getglobal("EnableColorsTrackerText"):SetText(L["Use colors instead of icons"])
	
	LunaOptionsFrame.pages[10].buffheader = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[10].buffheader:SetPoint("TOP", LunaOptionsFrame.pages[10].colors, "BOTTOM", 20, -10)
	LunaOptionsFrame.pages[10].buffheader:SetText(L["Buffs to track"])
	
	local function Exit()
		this:ClearFocus()
	end
	
	LunaOptionsFrame.pages[10].firstbuff = CreateFrame("Editbox", "FirstBuffInput", LunaOptionsFrame.pages[10], "InputBoxTemplate")
	LunaOptionsFrame.pages[10].firstbuff:SetHeight(20)
	LunaOptionsFrame.pages[10].firstbuff:SetWidth(200)
	LunaOptionsFrame.pages[10].firstbuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[10].firstbuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].buffheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].firstbuff.config = LunaUF.db.profile.units.raid.squares.buffs.names
	LunaOptionsFrame.pages[10].firstbuff:SetScript("OnTextChanged", function()
		this.config[1] = string.lower(this:GetText())
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[10].firstbuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[10].firstbuff:SetScript("OnEnterPressed", Exit)
	
	LunaOptionsFrame.pages[10].firstbuffcolor = CreateColorSelect(LunaOptionsFrame.pages[10], LunaUF.db.profile.units.raid.squares.buffs.colors[1])
	LunaOptionsFrame.pages[10].firstbuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[10].firstbuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[10].firstbuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[10].firstbuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[10].firstbuffcolor.text:SetText(L["Buffcolor"])
	LunaOptionsFrame.pages[10].firstbuffcolor.colorSwatch:SetVertexColor(LunaUF.db.profile.units.raid.squares.buffs.colors[1].r, LunaUF.db.profile.units.raid.squares.buffs.colors[1].g, LunaUF.db.profile.units.raid.squares.buffs.colors[1].b)
	
	LunaOptionsFrame.pages[10].secondbuff = CreateFrame("Editbox", "SecondBuffInput", LunaOptionsFrame.pages[10], "InputBoxTemplate")
	LunaOptionsFrame.pages[10].secondbuff:SetHeight(20)
	LunaOptionsFrame.pages[10].secondbuff:SetWidth(200)
	LunaOptionsFrame.pages[10].secondbuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[10].secondbuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].firstbuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].secondbuff.config = LunaUF.db.profile.units.raid.squares.buffs.names
	LunaOptionsFrame.pages[10].secondbuff:SetScript("OnTextChanged", function()
		this.config[2] = string.lower(this:GetText())
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[10].secondbuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[10].secondbuff:SetScript("OnEnterPressed", Exit)
	
	LunaOptionsFrame.pages[10].secondbuffcolor = CreateColorSelect(LunaOptionsFrame.pages[10], LunaUF.db.profile.units.raid.squares.buffs.colors[2])
	LunaOptionsFrame.pages[10].secondbuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[10].secondbuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[10].secondbuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[10].secondbuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[10].secondbuffcolor.text:SetText(L["Buffcolor"])
	LunaOptionsFrame.pages[10].secondbuffcolor.colorSwatch:SetVertexColor(LunaUF.db.profile.units.raid.squares.buffs.colors[2].r, LunaUF.db.profile.units.raid.squares.buffs.colors[2].g, LunaUF.db.profile.units.raid.squares.buffs.colors[2].b)
	
	LunaOptionsFrame.pages[10].thirdbuff = CreateFrame("Editbox", "ThirdBuffInput", LunaOptionsFrame.pages[10], "InputBoxTemplate")
	LunaOptionsFrame.pages[10].thirdbuff:SetHeight(20)
	LunaOptionsFrame.pages[10].thirdbuff:SetWidth(200)
	LunaOptionsFrame.pages[10].thirdbuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[10].thirdbuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].secondbuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].thirdbuff.config = LunaUF.db.profile.units.raid.squares.buffs.names
	LunaOptionsFrame.pages[10].thirdbuff:SetScript("OnTextChanged", function()
		this.config[3] = string.lower(this:GetText())
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[10].thirdbuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[10].thirdbuff:SetScript("OnEnterPressed", Exit)
	
	LunaOptionsFrame.pages[10].thirdbuffcolor = CreateColorSelect(LunaOptionsFrame.pages[10], LunaUF.db.profile.units.raid.squares.buffs.colors[3])
	LunaOptionsFrame.pages[10].thirdbuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[10].thirdbuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[10].thirdbuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[10].thirdbuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[10].thirdbuffcolor.text:SetText(L["Buffcolor"])
	LunaOptionsFrame.pages[10].thirdbuffcolor.colorSwatch:SetVertexColor(LunaUF.db.profile.units.raid.squares.buffs.colors[3].r, LunaUF.db.profile.units.raid.squares.buffs.colors[3].g, LunaUF.db.profile.units.raid.squares.buffs.colors[3].b)
	
	LunaOptionsFrame.pages[10].debuffheader = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[10].debuffheader:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].thirdbuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].debuffheader:SetText(L["Debuffs to track"])
	
	LunaOptionsFrame.pages[10].firstdebuff = CreateFrame("Editbox", "FirstDebuffInput", LunaOptionsFrame.pages[10], "InputBoxTemplate")
	LunaOptionsFrame.pages[10].firstdebuff:SetHeight(20)
	LunaOptionsFrame.pages[10].firstdebuff:SetWidth(200)
	LunaOptionsFrame.pages[10].firstdebuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[10].firstdebuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].debuffheader, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].firstdebuff.config = LunaUF.db.profile.units.raid.squares.debuffs.names
	LunaOptionsFrame.pages[10].firstdebuff:SetScript("OnTextChanged", function()
		this.config[1] = string.lower(this:GetText())
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[10].firstdebuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[10].firstdebuff:SetScript("OnEnterPressed", Exit)
	
	LunaOptionsFrame.pages[10].firstdebuffcolor = CreateColorSelect(LunaOptionsFrame.pages[10], LunaUF.db.profile.units.raid.squares.debuffs.colors[1])
	LunaOptionsFrame.pages[10].firstdebuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[10].firstdebuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[10].firstdebuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[10].firstdebuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[10].firstdebuffcolor.text:SetText(L["Debuffcolor"])
	LunaOptionsFrame.pages[10].firstdebuffcolor.colorSwatch:SetVertexColor(LunaUF.db.profile.units.raid.squares.debuffs.colors[1].r, LunaUF.db.profile.units.raid.squares.debuffs.colors[1].g, LunaUF.db.profile.units.raid.squares.debuffs.colors[1].b)
	
	LunaOptionsFrame.pages[10].seconddebuff = CreateFrame("Editbox", "SecondDebuffInput", LunaOptionsFrame.pages[10], "InputBoxTemplate")
	LunaOptionsFrame.pages[10].seconddebuff:SetHeight(20)
	LunaOptionsFrame.pages[10].seconddebuff:SetWidth(200)
	LunaOptionsFrame.pages[10].seconddebuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[10].seconddebuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].firstdebuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].seconddebuff.config = LunaUF.db.profile.units.raid.squares.debuffs.names
	LunaOptionsFrame.pages[10].seconddebuff:SetScript("OnTextChanged", function()
		this.config[2] = string.lower(this:GetText())
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[10].seconddebuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[10].seconddebuff:SetScript("OnEnterPressed", Exit)
	
	LunaOptionsFrame.pages[10].seconddebuffcolor = CreateColorSelect(LunaOptionsFrame.pages[10], LunaUF.db.profile.units.raid.squares.debuffs.colors[2])
	LunaOptionsFrame.pages[10].seconddebuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[10].seconddebuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[10].seconddebuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[10].seconddebuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[10].seconddebuffcolor.text:SetText(L["Debuffcolor"])
	LunaOptionsFrame.pages[10].seconddebuffcolor.colorSwatch:SetVertexColor(LunaUF.db.profile.units.raid.squares.debuffs.colors[2].r, LunaUF.db.profile.units.raid.squares.debuffs.colors[2].g, LunaUF.db.profile.units.raid.squares.debuffs.colors[2].b)
	
	LunaOptionsFrame.pages[10].thirddebuff = CreateFrame("Editbox", "ThirdDebuffInput", LunaOptionsFrame.pages[10], "InputBoxTemplate")
	LunaOptionsFrame.pages[10].thirddebuff:SetHeight(20)
	LunaOptionsFrame.pages[10].thirddebuff:SetWidth(200)
	LunaOptionsFrame.pages[10].thirddebuff:SetAutoFocus(nil)
	LunaOptionsFrame.pages[10].thirddebuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].seconddebuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].thirddebuff.config = LunaUF.db.profile.units.raid.squares.debuffs.names
	LunaOptionsFrame.pages[10].thirddebuff:SetScript("OnTextChanged", function()
		this.config[3] = string.lower(this:GetText())
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.unitGroup == "raid" then
				LunaUF.Units.FullUpdate(frame)
			end
		end
	end)
	LunaOptionsFrame.pages[10].thirddebuff:SetScript("OnEscapePressed", Exit)
	LunaOptionsFrame.pages[10].thirddebuff:SetScript("OnEnterPressed", Exit)
	
	LunaOptionsFrame.pages[10].thirddebuffcolor = CreateColorSelect(LunaOptionsFrame.pages[10], LunaUF.db.profile.units.raid.squares.debuffs.colors[3])
	LunaOptionsFrame.pages[10].thirddebuffcolor:SetPoint("LEFT", LunaOptionsFrame.pages[10].thirddebuff, "RIGHT", 10, 0)
	LunaOptionsFrame.pages[10].thirddebuffcolor:SetHeight(19)
	LunaOptionsFrame.pages[10].thirddebuffcolor:SetWidth(19)
	LunaOptionsFrame.pages[10].thirddebuffcolor.text:SetText(L["Debuffcolor"])
	LunaOptionsFrame.pages[10].thirddebuffcolor.colorSwatch:SetVertexColor(LunaUF.db.profile.units.raid.squares.debuffs.colors[3].r, LunaUF.db.profile.units.raid.squares.debuffs.colors[3].g, LunaUF.db.profile.units.raid.squares.debuffs.colors[3].b)

	LunaOptionsFrame.pages[10].raidoptions = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LunaOptionsFrame.pages[10].raidoptions:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].thirddebuff, "BOTTOMLEFT", 0, -30)
	LunaOptionsFrame.pages[10].raidoptions:SetHeight(24)
	LunaOptionsFrame.pages[10].raidoptions:SetJustifyH("LEFT")
	LunaOptionsFrame.pages[10].raidoptions:SetTextColor(1,1,0)
	LunaOptionsFrame.pages[10].raidoptions:SetText(L["Raidoptions"])
	
	LunaOptionsFrame.pages[10].showparty = CreateFrame("CheckButton", "PartyInRaidFrames", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].showparty:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].raidoptions, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].showparty:SetHeight(30)
	LunaOptionsFrame.pages[10].showparty:SetWidth(30)
	LunaOptionsFrame.pages[10].showparty:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.showparty = not LunaUF.db.profile.units.raid.showparty
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("PartyInRaidFramesText"):SetText(L["Party in raidframes"])
	
	LunaOptionsFrame.pages[10].showalways = CreateFrame("CheckButton", "AlwaysShowRaid", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].showalways:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].raidoptions, "BOTTOMLEFT", 150, -10)
	LunaOptionsFrame.pages[10].showalways:SetHeight(30)
	LunaOptionsFrame.pages[10].showalways:SetWidth(30)
	LunaOptionsFrame.pages[10].showalways:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.showalways = not LunaUF.db.profile.units.raid.showalways
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("AlwaysShowRaidText"):SetText(L["Always show"])
	
	LunaOptionsFrame.pages[10].raidpadding = CreateFrame("Slider", "RaidPaddingSlider", LunaOptionsFrame.pages[10], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[10].raidpadding:SetMinMaxValues(1,100)
	LunaOptionsFrame.pages[10].raidpadding:SetValueStep(1)
	LunaOptionsFrame.pages[10].raidpadding:SetScript("OnValueChanged", function()
		LunaUF.db.profile.units.raid.padding = math.floor(this:GetValue())
		getglobal("RaidPaddingSliderText"):SetText(L["Padding"]..": "..LunaUF.db.profile.units.raid.padding)
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	LunaOptionsFrame.pages[10].raidpadding:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].raidoptions, "BOTTOMLEFT", 270, -15)
	LunaOptionsFrame.pages[10].raidpadding:SetWidth(200)

	LunaOptionsFrame.pages[10].interlock = CreateFrame("CheckButton", "InterlockRaidFrames", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].interlock:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].showparty, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].interlock:SetHeight(30)
	LunaOptionsFrame.pages[10].interlock:SetWidth(30)
	LunaOptionsFrame.pages[10].interlock:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.interlock = not LunaUF.db.profile.units.raid.interlock
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("InterlockRaidFramesText"):SetText(L["Interlock raidframes"])
	
	LunaOptionsFrame.pages[10].interlockgrowth = CreateFrame("Button", "InterlockGrowthRaid", LunaOptionsFrame.pages[10], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[10].interlockgrowth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].showparty, "BOTTOMLEFT", 140 , -10)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[10].interlockgrowth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[10].interlockgrowth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[10].interlockgrowth, function()
		local info={}
		for k,v in pairs({[L["LEFT"]] = "LEFT",[L["RIGHT"]] = "RIGHT",[L["UP"]] = "UP",[L["DOWN"]] = "DOWN"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[10].interlockgrowth, this.value)
				LunaUF.db.profile.units.raid.interlockgrowth = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[10].interlockgrowth)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	LunaOptionsFrame.pages[10].intergrDesc = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[10].intergrDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[10].interlockgrowth, "TOP")
	LunaOptionsFrame.pages[10].intergrDesc:SetText(L["Growth direction"])
	
	LunaOptionsFrame.pages[10].petgrp = CreateFrame("CheckButton", "EnablePetGrp", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].petgrp:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].interlock, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[10].petgrp:SetHeight(30)
	LunaOptionsFrame.pages[10].petgrp:SetWidth(30)
	LunaOptionsFrame.pages[10].petgrp:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.petgrp = not LunaUF.db.profile.units.raid.petgrp
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("EnablePetGrpText"):SetText(L["Enable pet group"])
	
	LunaOptionsFrame.pages[10].titles = CreateFrame("CheckButton", "RaidGrpTitles", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].titles:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].interlock, "BOTTOMLEFT", 150, -10)
	LunaOptionsFrame.pages[10].titles:SetHeight(30)
	LunaOptionsFrame.pages[10].titles:SetWidth(30)
	LunaOptionsFrame.pages[10].titles:SetScript("OnClick", function()
		LunaUF.db.profile.units.raid.titles = not LunaUF.db.profile.units.raid.titles
		LunaUF.Units:LoadRaidGroupHeader()
	end)
	getglobal("RaidGrpTitlesText"):SetText(L["Enable raidgroup titles"])
	
	LunaOptionsFrame.pages[10].sortby = CreateFrame("Button", "RaidSortBy", LunaOptionsFrame.pages[10], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[10].sortby:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].petgrp, "BOTTOMLEFT", -10 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[10].sortby)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[10].sortby)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[10].sortby, function()
		local info={}
		for k,v in pairs({[L["Name"]] = "NAME",[L["Group"]] = "GROUP"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[10].sortby, this.value)
				LunaUF.db.profile.units.raid.sortby = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[10].sortby)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	LunaOptionsFrame.pages[10].sortDesc = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[10].sortDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[10].sortby, "TOP")
	LunaOptionsFrame.pages[10].sortDesc:SetText(L["Sort by"])
	
	LunaOptionsFrame.pages[10].orderby = CreateFrame("Button", "RaidOrderBy", LunaOptionsFrame.pages[10], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[10].orderby:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].petgrp, "BOTTOMLEFT", 100 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[10].orderby)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[10].orderby)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[10].orderby, function()
		local info={}
		for k,v in pairs({[L["Ascending"]] = "ASC",[L["Descending"]] = "DESC"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[10].orderby, this.value)
				LunaUF.db.profile.units.raid.order = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[10].orderby)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	LunaOptionsFrame.pages[10].orderDesc = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[10].orderDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[10].orderby, "TOP")
	LunaOptionsFrame.pages[10].orderDesc:SetText(L["Sort direction"])
	
	LunaOptionsFrame.pages[10].growth = CreateFrame("Button", "RaidGrowth", LunaOptionsFrame.pages[10], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[10].growth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].petgrp, "BOTTOMLEFT", 210 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[10].growth)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[10].growth)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[10].growth, function()
		local info={}
		for k,v in pairs({[L["LEFT"]] = "LEFT",[L["RIGHT"]] = "RIGHT",[L["UP"]] = "UP",[L["DOWN"]] = "DOWN"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[10].growth, this.value)
				LunaUF.db.profile.units.raid.growth = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[10].growth)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	LunaOptionsFrame.pages[10].growthDesc = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[10].growthDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[10].growth, "TOP")
	LunaOptionsFrame.pages[10].growthDesc:SetText(L["Growth direction"])
	
	LunaOptionsFrame.pages[10].mode = CreateFrame("Button", "RaidMode", LunaOptionsFrame.pages[10], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[10].mode:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].petgrp, "BOTTOMLEFT", 320 , -20)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[10].mode)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[10].mode)

	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[10].mode, function()
		local info={}
		for k,v in pairs({[L["Class"]] = "CLASS",[L["Group"]] = "GROUP"}) do
			info.text=k
			info.value=v
			info.func= function ()
				UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[10].mode, this.value)
				LunaUF.db.profile.units.raid.mode = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[10].mode)
				LunaUF.Units:LoadRaidGroupHeader()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	LunaOptionsFrame.pages[10].modeDesc = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	LunaOptionsFrame.pages[10].modeDesc:SetPoint("BOTTOM", LunaOptionsFrame.pages[10].mode, "TOP")
	LunaOptionsFrame.pages[10].modeDesc:SetText(L["Mode"])

--------
	
	LunaOptionsFrame.pages[11].Button = CreateFrame("Button", "ClickCastBindButton", LunaOptionsFrame.pages[11], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[11].Button:SetPoint("TOPLEFT", LunaOptionsFrame.pages[11], "TOPLEFT", 20, -80)
	LunaOptionsFrame.pages[11].Button:SetHeight(20)
	LunaOptionsFrame.pages[11].Button:SetWidth(180)
	LunaOptionsFrame.pages[11].Button:SetText(L["Click me"])
	LunaOptionsFrame.pages[11].Button:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
	LunaOptionsFrame.pages[11].Button:SetScript("OnClick", function ()
		this:SetText((IsControlKeyDown() and "Ctrl-" or "") .. (IsShiftKeyDown() and "Shift-" or "") .. (IsAltKeyDown() and "Alt-" or "") .. arg1)
	end)
	
	LunaOptionsFrame.pages[11].input = CreateFrame("Editbox", "ClickCastInput", LunaOptionsFrame.pages[11], "InputBoxTemplate")
	LunaOptionsFrame.pages[11].input:SetHeight(20)
	LunaOptionsFrame.pages[11].input:SetWidth(250)
	LunaOptionsFrame.pages[11].input:SetAutoFocus(nil)
	LunaOptionsFrame.pages[11].input:SetPoint("LEFT", LunaOptionsFrame.pages[11].Button, "RIGHT", 20, 0)
	LunaOptionsFrame.pages[11].input.config = LunaUF.db.profile.clickcast
	LunaOptionsFrame.pages[11].input:SetScript("OnEnterPressed", function()
		this:ClearFocus()
	end)
	
	LunaOptionsFrame.pages[11].Add = CreateFrame("Button", "ClickCastAddButton", LunaOptionsFrame.pages[11], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[11].Add:SetPoint("CENTER", LunaOptionsFrame.pages[11], "TOP", 0, -120)
	LunaOptionsFrame.pages[11].Add:SetHeight(20)
	LunaOptionsFrame.pages[11].Add:SetWidth(90)
	LunaOptionsFrame.pages[11].Add:SetText(L["Add"])
	LunaOptionsFrame.pages[11].Add:SetScript("OnClick", function ()
		local binding = LunaOptionsFrame.pages[11].Button:GetText()
		if binding ~= L["Click me"] then
			LunaUF.db.profile.clickcasting.bindings[binding] = LunaOptionsFrame.pages[11].input:GetText()
			LunaOptionsFrame.pages[11].Load()
		end
	end)

	LunaOptionsFrame.pages[11].bindtexts = {}
	LunaOptionsFrame.pages[11].actiontexts = {}
	LunaOptionsFrame.pages[11].delbuttons = {}
	for i=1,40 do
		LunaOptionsFrame.pages[11].bindtexts[i] = LunaOptionsFrame.pages[11]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[11].bindtexts[i]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[11].Add, "BOTTOM", -220, -20*i)
		LunaOptionsFrame.pages[11].bindtexts[i]:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[11].bindtexts[i]:SetTextColor(1,1,0)

		LunaOptionsFrame.pages[11].actiontexts[i] = LunaOptionsFrame.pages[11]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		LunaOptionsFrame.pages[11].actiontexts[i]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[11].Add, "BOTTOM", -40, -20*i)
		LunaOptionsFrame.pages[11].actiontexts[i]:SetJustifyH("LEFT")
		LunaOptionsFrame.pages[11].actiontexts[i]:SetTextColor(1,1,1)
		
		LunaOptionsFrame.pages[11].delbuttons[i] = CreateFrame("Button", "ClickCastDelButton"..i, LunaOptionsFrame.pages[11], "UIPanelButtonTemplate")
		LunaOptionsFrame.pages[11].delbuttons[i]:SetPoint("TOPLEFT", LunaOptionsFrame.pages[11].Add, "BOTTOM", 220, -20*i)
		LunaOptionsFrame.pages[11].delbuttons[i]:SetHeight(20)
		LunaOptionsFrame.pages[11].delbuttons[i]:SetWidth(20)
		LunaOptionsFrame.pages[11].delbuttons[i]:SetText("X")
		LunaOptionsFrame.pages[11].delbuttons[i].bindtext = LunaOptionsFrame.pages[11].bindtexts[i]
		LunaOptionsFrame.pages[11].delbuttons[i]:SetScript("OnClick", function ()
			LunaUF.db.profile.clickcasting.bindings[this.bindtext:GetText()] = nil
			LunaOptionsFrame.pages[11].Load()
		end)
	end
	
	LunaOptionsFrame.pages[11].Load = function ()
		local button = 1
		for k,v in pairs(LunaUF.db.profile.clickcasting.bindings) do
			LunaOptionsFrame.pages[11].bindtexts[button]:SetText(k)
			LunaOptionsFrame.pages[11].bindtexts[button]:Show()
			LunaOptionsFrame.pages[11].actiontexts[button]:SetText(v)
			LunaOptionsFrame.pages[11].actiontexts[button]:Show()
			LunaOptionsFrame.pages[11].delbuttons[button]:Show()
			button = button + 1
		end
		for i=button, 40 do
			LunaOptionsFrame.pages[11].bindtexts[i]:Hide()
			LunaOptionsFrame.pages[11].actiontexts[i]:Hide()
			LunaOptionsFrame.pages[11].delbuttons[i]:Hide()
		end
		LunaOptionsFrame.ScrollFrames[11]:SetScrollChild(LunaOptionsFrame.pages[11])
	end

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
	LunaOptionsFrame.helpframescrollchild.title:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", 20)
	LunaOptionsFrame.helpframescrollchild.title:SetText("Help is for the weak")
	LunaOptionsFrame.helpframescrollchild.title:SetJustifyH("CENTER")
	LunaOptionsFrame.helpframescrollchild.title:SetJustifyV("TOP")
	LunaOptionsFrame.helpframescrollchild.title:SetPoint("TOP", LunaOptionsFrame.helpframescrollchild, "TOP")
	LunaOptionsFrame.helpframescrollchild.title:SetHeight(20)
	LunaOptionsFrame.helpframescrollchild.title:SetWidth(300)

	LunaOptionsFrame.helpframescrollchild.texts = {}

	LunaOptionsFrame.HelpScrollFrame:SetScrollChild(LunaOptionsFrame.helpframescrollchild)
	LunaOptionsFrame.Helpframe:Hide()
	LunaOptionsFrame:SetScale(0.8)
end
