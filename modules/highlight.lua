local Highlight = {}
LunaUF:RegisterModule(Highlight, "highlight", LunaUF.L["Highlight"])

local function OnEvent()
	local frame = this:GetParent()
	if event == "UNIT_AURA" and not UnitIsUnit(frame.unit, arg1) then
		return
	end
	Highlight:FullUpdate(frame)
end

local function OnEnter()
	if this.highlight then
		if this.highlight.onEnter then
			this.highlight.onEnter()
		end
		this.highlight.mouseover = true
		Highlight:FullUpdate(this)
	end
end

local function OnLeave()
	if this.highlight then
		if this.highlight.onLeave then
			this.highlight.onLeave()
		end
		this.highlight.mouseover = nil
		Highlight:FullUpdate(this)
	end
end

function Highlight:OnEnable(frame)
	if not frame.highlight then
		frame.highlight = CreateFrame("Frame", nil, frame)
		frame.highlight:SetFrameLevel(6)
		frame.highlight.texture = frame.highlight:CreateTexture(nil, "ARTWORK")
		frame.highlight.texture:ClearAllPoints()
		frame.highlight.texture:SetAllPoints(frame)
		frame.highlight.texture:SetBlendMode("ADD")
		frame.highlight.texture:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\highlight")
		frame.highlight.onEnter = frame:GetScript("OnEnter")
		frame:SetScript("OnEnter", OnEnter)
		frame.highlight.onLeave = frame:GetScript("OnLeave")
		frame:SetScript("OnLeave", OnLeave)
	end
	frame.highlight:Hide()
	frame.highlight:SetScript("OnEvent", OnEvent)
	frame.highlight:RegisterEvent("PLAYER_TARGET_CHANGED")
	frame.highlight:RegisterEvent("UNIT_AURA")
end

function Highlight:OnDisable(frame)
	if frame.highlight then
		frame.highlight:Hide()
		frame.highlight.mouseover = nil
		frame.highlight:SetScript("OnEvent", nil)
		frame.highlight:UnregisterAllEvents()
	end
end

function Highlight:FullUpdate(frame)
	if frame.highlight then
		local config = LunaUF.db.profile.units[frame.unitGroup].highlight
		local _,_,dtype = UnitDebuff(frame.unit,1,1)
		if not config.ondebuff or not UnitCanAssist("player", frame.unit) then
			dtype = nil
		end
		local targeted = UnitIsUnit("target",frame.unit) and config.ontarget
		if (frame.highlight.mouseover and config.onmouse) or targeted or dtype then
			local r,g,b
			if dtype then
				r,g,b = unpack(LunaUF.db.profile.magicColors[dtype])
			else
				r,g,b = 1,1,1
			end
			local alpha = (frame.highlight.mouseover and config.onmouse and targeted and 0.2 or 0) + config.alpha
			frame.highlight.texture:SetVertexColor(r,g,b,alpha)
			frame.highlight:Show()
		else
			frame.highlight:Hide()
		end
	end
end