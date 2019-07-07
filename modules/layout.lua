local Layout = {}
local mediaRequired, anchoringQueued
	local backdrop = {
		bgFile = "Chat Frame",
		insets = { left = 0, right = 0, top = 0, bottom = 0 },
		backdropColor = {r = 0, g = 0, b = 0, a = 0.80},
	}
local _G = getfenv(0)
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")

LunaUF.Layout = Layout

local defaultMedia = {
	[SML.MediaType.STATUSBAR] = "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Minimalist",
	[SML.MediaType.FONT] = "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Myriad Condensed Web.ttf",
	[SML.MediaType.BACKGROUND] = "Interface\\ChatFrame\\ChatFrameBackground",
	[SML.MediaType.BORDER] = "Interface\\None",
}

-- Someone is using another mod that is forcing a media type for all mods using SML
function Layout:MediaForced(mediaType)
	self:Reload()
end

function Layout:LoadMedia(type, name)
	local mediaName = name or LunaUF.db.profile[type]
	if( not mediaName ) then return defaultMedia[type] end

	local media = SML:Fetch(type, mediaName, true)
	if( not media ) then
		mediaRequired = mediaRequired or {}
		mediaRequired[type] = mediaName
		return defaultMedia[type]
	end
	
	return media
end

-- We might not have had a media we required at initial load, wait for it to load and then update everything when it does
function Layout:MediaRegistered(event, mediaType, key)
	if( mediaRequired and mediaRequired[mediaType] and mediaRequired[mediaType] == key ) then
		mediaRequired[mediaType] = nil
		
		self:Reload()
	end
end

-- Helper functions
function Layout:ToggleVisibility(frame, visible)
	if not frame then return end
	if( visible ) then
		frame:Show()
	else
		frame:Hide()
	end
end	

function Layout:SetBarVisibility(frame, key, status)
	if( frame.secureLocked ) then return end

	-- Show the bar if it wasn't already
	if( status and not frame[key]:IsShown() ) then
		frame[key].visibilityManaged = true
		frame[key]:Show()
		LunaUF.Layout:PositionWidgets(frame, LunaUF.db.profile.units[frame.unitType])

	-- Hide the bar if it wasn't already
	elseif( not status and frame[key]:IsShown() ) then
		frame[key].visibilityManaged = nil
		frame[key]:Hide()
		LunaUF.Layout:PositionWidgets(frame, LunaUF.db.profile.units[frame.unitType])
	end
end

-- Frame changed somehow between when we first set it all up and now
function Layout:Reload(unit)

	-- Now update them
	for frame in pairs(LunaUF.Units.frameList) do
		if( frame.unit and ( not unit or frame.unitType == unit ) and not frame.isHeaderFrame ) then
			frame:CheckModules()
			self:Load(frame)
			frame:FullUpdate()
		end
	end

	for header in pairs(LunaUF.Units.headerFrames) do
		if( header.unitType and ( not unit or header.unitType == unit ) ) then
			local config = LunaUF.db.profile.units[header.unitType]
			header:SetAttribute("style-height", config.height)
			header:SetAttribute("style-width", config.width)
			header:SetAttribute("style-scale", config.scale)
		end
	end

	LunaUF:FireModuleEvent("OnLayoutReload", unit)
end

-- Do a full update
function Layout:Load(frame)
	local unitConfig = LunaUF.db.profile.units[frame.unitType]

	-- About to set layout
	LunaUF:FireModuleEvent("OnPreLayoutApply", frame, unitConfig)

	-- Figure out if we're secure locking
--	frame.secureLocked = nil
--	for _, module in pairs(LunaUF.moduleOrder) do
--		if( frame.visibility[module.moduleKey] and ShadowUF.db.profile.units[frame.unitType][module.moduleKey] and
--			ShadowUF.db.profile.units[frame.unitType][module.moduleKey].secure and module:SecureLockable() ) then
--			frame.secureLocked = true
--			break
--		end
--	end
	
	-- Load all of the layout things
	self:SetupFrame(frame, unitConfig)
	self:SetupBars(frame, unitConfig)
	self:PositionWidgets(frame, unitConfig)
	LunaUF.Tags:SetupText(frame, unitConfig)

	-- Layouts been fully set
	LunaUF:FireModuleEvent("OnLayoutApplied", frame, unitConfig)
end

-- Register it on file load because authors seem to do a bad job at registering the callbacks
SML:Register(SML.MediaType.FONT, "Aldrich", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Aldrich.ttf")
SML:Register(SML.MediaType.FONT, "Bangers", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Bangers.ttf")
SML:Register(SML.MediaType.FONT, "Celestia", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Celestia.ttf")
SML:Register(SML.MediaType.FONT, "DorisPP", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\DorisPP.ttf")
SML:Register(SML.MediaType.FONT, "Enigmatic", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Enigmatic.ttf")
SML:Register(SML.MediaType.FONT, "FasterOne", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\FasterOne.ttf")
SML:Register(SML.MediaType.FONT, "Fitzgerald", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Fitzgerald.ttf")
SML:Register(SML.MediaType.FONT, "Gentium", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Gentium.ttf")
SML:Register(SML.MediaType.FONT, "Iceland", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Iceland.ttf")
SML:Register(SML.MediaType.FONT, "Inconsolata", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Inconsolata.ttf")
SML:Register(SML.MediaType.FONT, "LiberationSans", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\LiberationSans.ttf")
SML:Register(SML.MediaType.FONT, "MetalLord", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\MetalLord.ttf")
SML:Register(SML.MediaType.FONT, "Myriad Condensed Web", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Myriad Condensed Web.ttf")
SML:Register(SML.MediaType.FONT, "Optimus", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Optimus.ttf")
SML:Register(SML.MediaType.FONT, "TradeWinds", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\TradeWinds.ttf")
SML:Register(SML.MediaType.FONT, "VeraSerif", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\VeraSerif.ttf")
SML:Register(SML.MediaType.FONT, "Yellowjacket", "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Yellowjacket.ttf")

SML:Register(SML.MediaType.BORDER, "Square Clean", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\borders\\ABFBorder")
SML:Register(SML.MediaType.BACKGROUND, "Chat Frame", "Interface\\ChatFrame\\ChatFrameBackground")
SML:Register(SML.MediaType.STATUSBAR, "BantoBar", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\banto")
SML:Register(SML.MediaType.STATUSBAR, "Smooth",   "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\smooth")
SML:Register(SML.MediaType.STATUSBAR, "Perl",     "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\perl")
SML:Register(SML.MediaType.STATUSBAR, "Glaze",    "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\glaze")
SML:Register(SML.MediaType.STATUSBAR, "Charcoal", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Charcoal")
SML:Register(SML.MediaType.STATUSBAR, "Otravi",   "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\otravi")
SML:Register(SML.MediaType.STATUSBAR, "Striped",  "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\striped")
SML:Register(SML.MediaType.STATUSBAR, "LiteStep", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\LiteStep")
SML:Register(SML.MediaType.STATUSBAR, "Aluminium", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Aluminium")
SML:Register(SML.MediaType.STATUSBAR, "Minimalist", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Minimalist")
SML:Register(SML.MediaType.STATUSBAR, "Armory", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Armory")
SML:Register(SML.MediaType.STATUSBAR, "Bars", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Bars")
SML:Register(SML.MediaType.STATUSBAR, "Button", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Button")
SML:Register(SML.MediaType.STATUSBAR, "Cilo", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Cilo")
SML:Register(SML.MediaType.STATUSBAR, "Dabs", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Dabs")
SML:Register(SML.MediaType.STATUSBAR, "Diagonal", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Diagonal")
SML:Register(SML.MediaType.STATUSBAR, "Fifths", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Fifths")
SML:Register(SML.MediaType.STATUSBAR, "Flat", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Flat")
SML:Register(SML.MediaType.STATUSBAR, "Fourths", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Fourths")
SML:Register(SML.MediaType.STATUSBAR, "Glamour", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Glamour")
SML:Register(SML.MediaType.STATUSBAR, "Glamour2", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Glamour2")
SML:Register(SML.MediaType.STATUSBAR, "Glamour3", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Glamour3")
SML:Register(SML.MediaType.STATUSBAR, "Glamour4", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Glamour4")
SML:Register(SML.MediaType.STATUSBAR, "Glamour5", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Glamour5")
SML:Register(SML.MediaType.STATUSBAR, "Glamour6", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Glamour6")
SML:Register(SML.MediaType.STATUSBAR, "Glamour7", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Glamour7")
SML:Register(SML.MediaType.STATUSBAR, "Gloss", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Gloss")
SML:Register(SML.MediaType.STATUSBAR, "Healbot", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Healbot")
SML:Register(SML.MediaType.STATUSBAR, "Lyfe", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Lyfe")
SML:Register(SML.MediaType.STATUSBAR, "Perl2", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Perl2")
SML:Register(SML.MediaType.STATUSBAR, "Ruben", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Ruben")
SML:Register(SML.MediaType.STATUSBAR, "Skewed", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Skewed")
SML:Register(SML.MediaType.STATUSBAR, "Wisps", "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\bars\\Wisps")


function Layout:LoadSML()
	SML.RegisterCallback(self, "LibSharedMedia_Registered", "MediaRegistered")
	SML.RegisterCallback(self, "LibSharedMedia_SetGlobal", "MediaForced")
end

function Layout:AnchorFrame(frame, config)

	local anchorTo = config.anchorTo or "UIParent"

	if( anchorTo ~= "UIParent" ) then
		-- The frame we wanted to anchor to doesn't exist yet, so will queue and wait for it to exist
		if( not _G[anchorTo] ) then
			frame.queuedConfig = config
			frame.queuedName = anchorTo

			anchoringQueued = anchoringQueued or {}
			anchoringQueued[frame] = true
			
			return
		end
	end

	local scale = 1
	if( anchorTo == "UIParent" and not self.isHeaderFrame ) then
		scale = frame:GetScale() * UIParent:GetScale()
	end
	
	frame:ClearAllPoints()
	frame:SetPoint(config.point, _G[anchorTo], config.relativePoint, (config.x / scale), (config.y / scale))

	if( anchoringQueued ) then
		for queued in pairs(anchoringQueued) do
			if( queued.queuedName == frame:GetName() ) then
				self:AnchorFrame(queued, queued.queuedConfig)

				queued.queuedConfig = nil
				queued.queuedName = nil
				anchoringQueued[queued] = nil
			end
		end
	end
end

-- Setup the main frame
function Layout:SetupFrame(frame, config)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(backdrop.backdropColor.r, backdrop.backdropColor.g, backdrop.backdropColor.b, backdrop.backdropColor.a)
--	frame:SetBackdropBorderColor(backdrop.borderColor.r, backdrop.borderColor.g, backdrop.borderColor.b, backdrop.borderColor.a)
	
	-- Prevent these from updating while in combat to prevent tainting
	if( not InCombatLockdown() ) then
		frame:SetHeight(config.height)
		frame:SetWidth(config.width)
		frame:SetScale(config.scale)

		-- Let the frame clip closer to the edge, not using inset + clip as that lets you move it too far in
		local clamp = 0.20
		frame:SetClampRectInsets(clamp, -clamp, -clamp, clamp)
		frame:SetClampedToScreen(true)

		-- This is wrong technically, I need to redo the backdrop stuff so it will accept insets and that will fit hitbox issues
		-- for the time being, this is a temporary fix to it
		local hit = backdrop.borderTexture == "None" and backdrop.inset or 0
		frame:SetHitRectInsets(hit, hit, hit, hit)
		
		if( not frame.ignoreAnchor ) then
			self:AnchorFrame(frame, LunaUF.db.profile.units[frame.unitType])
		end
	end
end

-- Setup bars
function Layout:SetupBars(frame, config)
	for _, module in pairs(LunaUF.modules) do
		local key = module.moduleKey
		local widget = frame[key]
		if( widget and ( module.moduleHasBar or config[key] and config[key].isBar ) ) then
			if( frame.visibility[key] and not frame[key].visibilityManaged and module.defaultVisibility == false ) then
				self:ToggleVisibility(widget, false)
			else
				self:ToggleVisibility(widget, frame.visibility[key])
			end
			
			if( ( widget:IsShown() or ( not frame[key].visibilityManaged and module.defaultVisibility == false ) ) and widget.SetStatusBarTexture ) then
				widget:SetStatusBarTexture(LunaUF.Layout:LoadMedia(SML.MediaType.STATUSBAR, LunaUF.db.profile.units[frame.unitType][key].statusbar))
				widget:GetStatusBarTexture():SetHorizTile(false)

				widget:SetOrientation(config[key].vertical and "VERTICAL" or "HORIZONTAL")
				widget:SetReverseFill(config[key].reverse and true or false)
			end

			if( widget.background ) then
				if( config[key].background or config[key].invert ) then
					widget.background:SetTexture(LunaUF.Layout:LoadMedia(SML.MediaType.STATUSBAR, LunaUF.db.profile.units[frame.unitType][key].statusbar))
					widget.background:SetHorizTile(false)
					widget.background:Show()

					widget.background.overrideColor = {r = 0, g = 0, b = 0, a = 0.80} --LunaUF.db.profile.bars.backgroundColor or config[key].backgroundColor

					if( widget.background.overrideColor ) then
						widget.background:SetVertexColor(widget.background.overrideColor.r, widget.background.overrideColor.g, widget.background.overrideColor.b, 0.20)
					end
				else
					widget.background:Hide()
				end
			end
		end
	end
end

-- Setup the bar barOrder/info
local currentConfig
local function sortOrder(a, b)
	return currentConfig[a].order < currentConfig[b].order
end

local barOrderH = {}
local barOrderV = {}
function Layout:PositionWidgets(frame, config)
	-- Deal with setting all of the bar heights
	local totalWeight, totalHBars, totalVBars, hasFullSize, vWeight, hWeight = 0, -1, -1, nil, 0, 0

	-- Figure out total weighting as well as what bars are full sized
	for i=#(barOrderH), 1, -1 do table.remove(barOrderH, i) end
	for i=#(barOrderV), 1, -1 do table.remove(barOrderV, i) end
	for key, module in pairs(LunaUF.modules) do
		if( config[key] and not config[key].height ) then config[key].height = 0.50 end

		if( ( module.moduleHasBar or config[key] and config[key].isBar ) and frame[key] and frame[key]:IsShown() and config[key].height > 0 ) then
		
			totalWeight = totalWeight + config[key].height
			if config[key].vertical then
				vWeight = vWeight + config[key].height
				totalVBars = totalVBars + 1

				table.insert(barOrderV, key)
			else
				hWeight = hWeight + config[key].height
				totalHBars = totalHBars + 1

				table.insert(barOrderH, key)
			end

			config[key].order = config[key].order or 99
			
			-- Decide whats full sized
			if( not frame.visibility.portrait or config.portrait.isBar or config[key].order < config.portrait.fullBefore or config[key].order > config.portrait.fullAfter ) then
				hasFullSize = true
				frame[key].fullSize = true
			else
				frame[key].fullSize = nil
			end
		end
	end

	-- Sort the barOrder so it's all nice and orderly (:>)
	currentConfig = config
	table.sort(barOrderH, sortOrder)
	table.sort(barOrderV, sortOrder)

	-- Now deal with setting the heights and figure out how large the portrait should be.
	local clip = 1 --ShadowUF.db.profile.backdrop.inset + ShadowUF.db.profile.backdrop.clip
	local clipDoubled = clip * 2
	
	local portraitOffset, portraitAlignment, portraitAnchor
	local portraitWidth = 0

	if( not config.portrait.isBar ) then
		self:ToggleVisibility(frame.portrait, frame.visibility.portrait)
		
		if( frame.visibility.portrait ) then
			-- Figure out portrait alignment
			portraitAlignment = config.portrait.alignment
			
			-- Set the portrait width so we can figure out the offset to use on bars, will do height and position later
			portraitWidth = math.floor(frame:GetWidth() * config.portrait.width) - 3--ShadowUF.db.profile.backdrop.inset
			frame.portrait:SetWidth(portraitWidth - (portraitAlignment == "RIGHT" and 1 or 0.5))
			
			-- Disable portrait if there isn't enough room
			if( portraitWidth <= 0 ) then
				frame.portrait:Hide()
			end

			-- As well as how much to offset bars by (if it's using a left alignment) to keep them all fancy looking
			portraitOffset = clip
			if( portraitAlignment == "LEFT" ) then
				portraitOffset = portraitOffset + portraitWidth
			end
		end
	end

	hWeight = math.max(hWeight, 1)
	totalWeight = math.max(totalWeight, 1)

	-- Position and size everything
	local portraitHeight, yOffset, hBarWidth = 0, -clip, ((frame:GetWidth() - portraitWidth) * (hWeight / totalWeight)) - clip - (#barOrderV > 0 and 0 or clip)
	local vBarWidth = vWeight > 0 and ((frame:GetWidth() - portraitWidth) * (vWeight / totalWeight)) - clip - (#barOrderH > 0 and 1.02 or clip) or 0
	local availableHeight = frame:GetHeight() - clipDoubled - (1.02 * totalHBars)
	for id, key in pairs(barOrderH) do
		local bar = frame[key]
		-- Position the actual bar based on it's type
		if( bar.fullSize ) then
			bar:SetWidth(frame:GetWidth() - clipDoubled)
			bar:SetHeight(availableHeight * (config[key].height / hWeight))

			bar:ClearAllPoints()
			bar:SetPoint("TOPLEFT", frame, "TOPLEFT", clip, yOffset)
		else
			bar:SetWidth(hBarWidth)
			bar:SetHeight(availableHeight * (config[key].height / hWeight))

			bar:ClearAllPoints()
			bar:SetPoint("TOPLEFT", frame, "TOPLEFT", portraitOffset, yOffset)

			portraitHeight = portraitHeight + bar:GetHeight() + 1
		end
		
		-- Figure out where the portrait is going to be anchored to
		if( not portraitAnchor and config[key].order >= config.portrait.fullBefore ) then
			portraitAnchor = bar
		end

		yOffset = yOffset - bar:GetHeight() + (-1.02)
	end

	local xOffset = portraitOffset and 0 or clip
	if portraitHeight == 0 then portraitHeight = availableHeight end
	for id, key in pairs(barOrderV) do
		local bar = frame[key]
		-- Position the actual bar based on it's type
		bar:SetWidth((vBarWidth * (config[key].height / vWeight)) - 0.2)
		bar:SetHeight(portraitHeight - 1.02)

		bar:ClearAllPoints()
		if #barOrderH > 0 then
			bar:SetPoint("TOPLEFT", portraitAnchor, "TOPRIGHT", 1.02 + xOffset, 0)
		else
			bar:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset + (portraitOffset or 0), -clip)
		end
		
		xOffset = xOffset + bar:GetWidth() + (1.02)
		
		-- Figure out where the portrait is going to be anchored to
		if( not portraitAnchor ) then
			portraitAnchor = bar
		end
		
	end

	if( not portraitAnchor ) then
		portraitAnchor = frame
	end

	if #barOrderV > 0 then vBarWidth = vBarWidth + 1.02 end

	-- Now position the portrait and set the height
	if( frame.portrait and frame.portrait:IsShown() and portraitAnchor and portraitHeight > 0 ) then
		if( portraitAlignment == "LEFT" ) then
			frame.portrait:ClearAllPoints()
			frame.portrait:SetPoint("TOPLEFT", portraitAnchor, "TOPLEFT", -frame.portrait:GetWidth() - 0.5, 0)
		elseif( portraitAlignment == "RIGHT" ) then
			frame.portrait:ClearAllPoints()
			frame.portrait:SetPoint("TOPRIGHT", portraitAnchor, "TOPRIGHT", frame.portrait:GetWidth() + 1 + (#barOrderH > 0 and vBarWidth or 0), 0)
		end
			
		if( hasFullSize ) then
			frame.portrait:SetHeight(portraitHeight - 1)
		else
			frame.portrait:SetHeight(frame:GetHeight() - clipDoubled)
		end
	end

	LunaUF:FireModuleEvent("OnLayoutWidgets", frame, config)
end