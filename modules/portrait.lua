local Portrait = {}
LunaUF:RegisterModule(Portrait, "portrait", LunaUF.L["Portrait"])

-- If the camera isn't reset OnShow, it'll show the entire character instead of just the head, odd I know
local function resetCamera(self)
	self:SetPortraitZoom(1)
end

local function resetGUID(self)
	self.guid = nil
end

function Portrait:OnEnable(frame)
	frame:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", self, "UpdateFunc")
	frame:RegisterUnitEvent("UNIT_MODEL_CHANGED", self, "Update")
	
	frame:RegisterUpdateFunc(self, "UpdateFunc")
end

function Portrait:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Portrait:OnPreLayoutApply(frame, config)
	if( not frame.visibility.portrait ) then return end

	if config.portrait.alignment == "CENTER" then
		config.portrait.isBar = true
	else
		config.portrait.isBar = false
	end

	if( config.portrait.type == "3D" ) then
		if( not frame.portraitModel ) then
			frame.portraitModel = CreateFrame("PlayerModel", nil, frame)
			frame.portraitModel:SetScript("OnShow", resetCamera)
			frame.portraitModel:SetScript("OnHide", resetGUID)
			frame.portraitModel.parent = frame
		end
				
		frame.portrait = frame.portraitModel
		frame.portrait:Show()

		LunaUF.Layout:ToggleVisibility(frame.portraitTexture, false)
	else
		frame.portraitTexture = frame.portraitTexture or frame:CreateTexture(nil, "ARTWORK")
		frame.portrait = frame.portraitTexture
		frame.portrait:Show()

		LunaUF.Layout:ToggleVisibility(frame.portraitModel, false)
	end
end

function Portrait:UpdateFunc(frame)
	-- Portrait models can't be updated unless the GUID changed or else you have the animation jumping around
	if( LunaUF.db.profile.units[frame.unitType].portrait.type == "3D" ) then
		local guid = UnitGUID(frame.unit)
		if( frame.portrait.guid ~= guid ) then
			self:Update(frame)
		end
		
		frame.portrait.guid = guid
	else
		self:Update(frame)
	end
end

function Portrait:Update(frame, event)
	local type = LunaUF.db.profile.units[frame.unitType].portrait.type
	-- Use class thingy
	if( type == "class" ) then
		local classToken = frame:UnitClassToken()
		if( classToken ) then
			frame.portrait:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			frame.portrait:SetTexCoord(CLASS_ICON_TCOORDS[classToken][1], CLASS_ICON_TCOORDS[classToken][2], CLASS_ICON_TCOORDS[classToken][3], CLASS_ICON_TCOORDS[classToken][4])
		else
			frame.portrait:SetTexture("")
		end
	-- Use 2D character image
	elseif( type == "2D" ) then
		local height = frame.portrait:GetHeight()
		local width = frame.portrait:GetWidth()
		local cutoff
		if height < width then
			cutoff = ((width - height) / 2) / width * 0.9
			frame.portrait:SetTexCoord(0.1, 0.9, 0.1 + cutoff, 0.9 - cutoff)
		elseif height > width then
			cutoff = ((height - width) / 2) / height * 0.9
			frame.portrait:SetTexCoord(0.1 + cutoff, 0.9 - cutoff, 0.1, 0.9)
		else
			frame.portrait:SetTexCoord(0.10, 0.90, 0.10, 0.90)
		end
		SetPortraitTexture(frame.portrait, frame.unit)
	-- Using 3D portrait, but the players not in range so swap to question mark
	elseif( not UnitIsVisible(frame.unit) or not UnitIsConnected(frame.unit) ) then
		frame.portrait:ClearModel()
		frame.portrait:SetModel("Interface\\Buttons\\talktomequestionmark.m2")
		frame.portrait:SetModelScale(2)
		frame.portrait:SetPosition(0, 0, -0.08)

	-- Use animated 3D portrait
	else
		frame.portrait:ClearModel()
		frame.portrait:SetUnit(frame.unit)
		frame.portrait:SetPortraitZoom(1)
		frame.portrait:SetPosition(0, 0, 0)
		frame.portrait:Show()
	end
end