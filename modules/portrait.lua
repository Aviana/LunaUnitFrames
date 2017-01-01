local Portrait = {}
LunaUF:RegisterModule(Portrait, "portrait", LunaUF.L["Portrait"])

local validunits = {
	["party1"] = true,
	["party2"] = true,
	["party3"] = true,
	["party4"] = true,
	["partypet1"] = true,
	["partypet2"] = true,
	["partypet3"] = true,
	["partypet4"] = true,
	["player"] = true,
	["pet"] = true,
	["target"] = true,
}
for i=1, 40 do
	validunits["raid"..i] = true
	validunits["raidpet"..i] = true
end

local function OnEvent()
	if (validunits[arg1] and UnitIsUnit(arg1,this:GetParent().unit)) or (event == "PLAYER_TARGET_CHANGED" and this:GetParent().unit == "target") then
		Portrait:Update(this:GetParent())
	end
end

local function resetCamera()
	this:SetCamera(0)
end

local function resetGUID()
	this.unitname = nil
	this.isPlayer = nil
end

function Portrait:OnEnable(frame)
	local config = LunaUF.db.profile.units[frame.unitGroup]
	if( config.portrait.type == "3D" ) then
		if( not frame.portraitModel ) then
			frame.portraitModel = CreateFrame("PlayerModel", nil, frame)
			frame.portraitModel:SetScript("OnShow", resetCamera)
			frame.portraitModel:SetScript("OnHide", resetGUID)
		end

		frame.portrait = frame.portraitModel
		frame.portrait:Show()
		if frame.portraitTexture then
			frame.portraitTexture:Hide()
		end
	else
		if not frame.portraitTexture then
			frame.portraitTexture = CreateFrame("Frame", nil, frame)
			frame.portraitTexture.texture = frame.portraitTexture:CreateTexture(nil, "ARTWORK")
			frame.portraitTexture.texture:SetAllPoints(frame.portraitTexture)
		end
		frame.portrait = frame.portraitTexture
		frame.portrait:Show()
		
		if frame.portraitModel then
			frame.portraitModel:Hide()
		end
	end
	frame.portrait:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	frame.portrait:RegisterEvent("UNIT_MODEL_CHANGED")
	frame.portrait:RegisterEvent("PLAYER_TARGET_CHANGED")
	frame.portrait:SetScript("OnEvent", OnEvent)
end

function Portrait:OnDisable(frame)
	if frame.portrait then
		frame.portrait:UnregisterAllEvents()
		frame.portrait:SetScript("OnEvent", nil)
		frame.portrait:Hide()
	end
end

function Portrait:FullUpdate(frame)
	-- Portrait models can't be updated unless the Name changed or else you have the animation jumping around
	if( LunaUF.db.profile.units[frame.unitGroup].portrait.type == "3D" ) then
		local unitname = UnitName(frame.unit)
		local isPlayer = UnitIsPlayer(frame.unit)
		if( frame.portrait.unitname ~= unitname or frame.portrait.isPlayer ~= isPlayer ) then
			self:Update(frame)
		end
		
		frame.portrait.isPlayer = isPlayer
		frame.portrait.unitname = unitname
	else
		self:Update(frame)
	end
end

function Portrait:Update(frame)
	local type = LunaUF.db.profile.units[frame.unitGroup].portrait.type
	local aspect = frame.portrait:GetHeight()/frame.portrait:GetWidth()
	-- Use class thingy
	if( type == "class" and UnitIsPlayer(frame.unit) ) then
		local _,classToken = UnitClass(frame.unit)
		if( classToken ) then
			frame.portrait.texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			frame.portrait.texture:SetTexCoord(unpack(LunaUF.constants.CLASS_ICON_TCOORDS[classToken]))
		else
			frame.portrait.texture:SetTexture("")
		end
	-- Use 2D character image
	elseif( type == "2D" or type == "class" ) then
		SetPortraitTexture(frame.portrait.texture, frame.unit)
--		frame.portrait.texture:SetTexCoord(0.10, 0.90, 0.10, 0.90)
		frame.portrait.texture:SetTexCoord(0.1, 0.9, .1+(0.4-0.4*aspect), .90-(0.4-0.4*aspect))
	-- Using 3D portrait, but the players not in range so swap to 2D
	elseif( not UnitIsVisible(frame.unit) or not UnitIsConnected(frame.unit) ) then
		frame.portrait:SetModelScale(4.25)
		frame.portrait:SetPosition(0, 0, -1.0)
		frame.portrait:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
	-- Use animated 3D portrait
	else
		frame.portrait:SetUnit(frame.unit)
		frame.portrait:SetCamera(0)
		frame.portrait:Show()
	end
end