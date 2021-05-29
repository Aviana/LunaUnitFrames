--[[
# Element: Simple Auras

Handles creation and updating of aura icons.

## Widget

SimpleAuras   - A frame that goes over the unitframe with "SetAllPoints".

## Notes

Yawt.

## Options

.buffs              - Show Buffs (boolean)
.debuffs            - Show Debuffs (boolean)
.weapons            - Show weapon buffs. Works on player only (boolean)
.buffAnchor         - Valid anchors are: "TOP", "BOTTOM", "LEFT", "RIGHT", "INSIDE", "INSIDECENTER"
.debuffAnchor       - Valid anchors are: "TOP", "BOTTOM", "LEFT", "RIGHT", "INSIDE", "INSIDECENTER"
.timer              - Show cooldown spiral (string)
                      "all"        - All auras have timers
                      "self"       - Only own auras have timers
                      nil, "none"  - Timers disabled
.disableOCC         - Disables the cooldown count of omnicc (boolean)
.disableBCC         - Disables the blizzard cooldown count (boolean)
.buffSize           - Buff icon size. Defaults to 16 (number)
.debuffSize         - Buff icon size. Defaults to 16 (number)
.largeBuffSize......- Make your own bigger by this amount (number)
.largeDebuffSize....- Make your own bigger by this amount (number)
.onlyShowPlayer     - Shows only auras created by player/vehicle (boolean)
.showType           - Colors the border in the magic type color (boolean)
.spacing            - Spacing between each icon. Defaults to 0 (number)
.Anchor             - Anchor point for the icons. Defaults to 'BOTTOMLEFT' (string)
                      ""
.buffFilter         - Filter for buffs to display. (string)
.debuffFilter       - Filter for debuffs to display. (string)
.wrapBuffSide       - This works on buffs/debuffs with the "TOP" or "BOTTOM" anchor.
                      "LEFT" or "RIGHT" (string)
.wrapBuff           - Percentage by how much to adjust the side (number, 1 = 100%)
.wrapDebuffSide     - This works on buffs/debuffs with the "TOP" or "BOTTOM" anchor.
                      "LEFT" or "RIGHT" (string)
.wrapDebuff         - Percentage by how much to adjust the side (number, 1 = 100%)
.forceShow          - Show dummy auras (boolean)
.overlay            - Texture for the overlay (string or number)
.maxBuffs           - Maximum number of positive effects to display (default = 32)
.maxDebuffs         - Maximum number of negative effects to display (default = 40)

## Attributes

button.caster   - the unit who cast the aura (string)
button.filter   - the filter list used to determine the visibility of the aura (string)
button.isDebuff - indicates if the button holds a debuff (boolean)
button.isPlayer - indicates if the aura caster is the player or their vehicle (boolean)

## Examples

	-- Position and size
	local SimpleAuras = CreateFrame('Frame', nil, self)
	SimpleAuras:SetAllPoints(self)

	-- Register with oUF
	self.SimpleAuras = SimpleAuras
--]]

local _, ns = ...
local oUF = ns.oUF

local weaponWatchTimer
local mainHandEnd, mainHandDuration, mainHandCharges, offHandEnd, offHandDuration, offHandCharges

-- Things in this table have a duration other than 30 min
local weaponEnchantData = {
	[2684] = 3600, -- +100 Attack Power vs Undead (60 min)
	[2685] = 3600, -- +60 Spell Power vs Undead (60 min)
	[2629] = 3600, -- Brilliant Mana Oil (60 min)
	[2625] = 3600, -- Lesser Mana Oil (60 min)
	[2624] = 3600, -- Minor Mana Oil (60 min)
	[2677] = 3600, -- Superior Mana Oil (60 min)
	[2626] = 3600, -- Lesser Wizard Oil (60 min)
	[2623] = 3600, -- Minor Wizard Oil (60 min)
	[2678] = 3600, -- Superior Wizard Oil (60 min)
	[2627] = 3600, -- Wizard Oil (60 min)
	[263] = 600,   -- Fishing +25 (10 min)
	[264] = 600,   -- Fishing +50 (10 min)
	[265] = 600,   -- Fishing +75 (10 min)
	[266] = 600,   -- Fishing +100 (10 min)
	[124] = 10,    -- Flametongue Totem 1 (10 sec)
	[285] = 10,    -- Flametongue Totem 2 (10 sec)
	[543] = 10,    -- Flametongue Totem 3 (10 sec)
	[1683] = 10,   -- Flametongue Totem 4 (10 sec)
	[2637] = 10,   -- Flametongue Totem 5 (10 sec)
	[1783] = 10,   -- Windfury Totem 1 (10 sec)
	[563] = 10,    -- Windfury Totem 2 (10 sec)
	[564] = 10,    -- Windfury Totem 3 (10 sec)
	[2638] = 10,   -- Windfury Totem 4 (10 sec)
	[2639] = 10,   -- Windfury Totem 5 (10 sec)
	[1003] = 300,  -- Venomhide Poison (5 min)
	[40] = 3600,   -- Rough Sharpening Stone (60 min)
	[13] = 3600,   -- Coarse Sharpening Stone (60 min)
	[14] = 3600,   -- Heavy Sharpening Stone (60 min)
	[483] = 3600,  -- Solid Sharpening Stone (60 min)
	[1643] = 3600, -- Dense Sharpening Stone (60 min)
	[2506] = 3600, -- Elemental Sharpening Stone (60 min)
	[2712] = 3600, -- Fel Sharpening Stone (60 min)
	[2713] = 3600, -- Adamantite Sharpening Stone (60 min)
	[19] = 3600,   -- Rough Weightstone (60 min)
	[20] = 3600,   -- Coarse Weightstone (60 min)
	[21] = 3600,   -- Heavy Weightstone (60 min)
	[484] = 3600,  -- Solid Weightstone (60 min)
	[1703] = 3600, -- Dense Weightstone (60 min)
	[2954] = 3600, -- Fel Weightstone (60 min)
	[2955] = 3600, -- Adamantite Weightstone (60 min)
	[3093] = 300,  -- Scourgebane (5 min)
}

local function UpdateTooltip(self)
	if GameTooltip:IsForbidden() then return end
	if self.filter == "TEMP" then
		GameTooltip:SetInventoryItem("player", self:GetID())
	else
		GameTooltip:SetUnitAura(self:GetParent():GetParent().__owner.unit, self:GetID(), self.filter)
	end
end

local function onEnter(self)
	if GameTooltip:IsForbidden() or not self:IsVisible() then return end
	GameTooltip:SetOwner(self, self:GetParent():GetParent().tooltipAnchor)
	self:UpdateTooltip()
end

local function onLeave()
	if GameTooltip:IsForbidden() then return end
	GameTooltip:Hide()
end

local function cancelAura(self, button)
	local unit = self:GetParent():GetParent().__owner.unit
	if button ~= "RightButton" or InCombatLockdown() or self.filter ~= "HELPFUL" or not UnitIsUnit("player", unit) then
		return
	end
	CancelUnitBuff(unit, self:GetID(), self.filter)
end

local function createAuraIcon(element, index)
	local button = CreateFrame("Button", element:GetName() .. "Button" .. index, element)
	button:RegisterForClicks("RightButtonUp")

	local cd = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
	cd:SetDrawEdge(false)
	cd:SetDrawSwipe(true)
	cd:SetReverse(true)
	cd:SetSwipeColor(0, 0, 0, 0.8)
	cd:SetAllPoints()

	local icon = button:CreateTexture(nil, 'BORDER')
	icon:SetAllPoints()

	local countFrame = CreateFrame('Frame', nil, button)
	countFrame:SetAllPoints(button)
	countFrame:SetFrameLevel(cd:GetFrameLevel() + 1)

	local count = countFrame:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	local fontName = count:GetFont()
	count:SetFont(fontName, 10, "OUTLINE")
	count:SetPoint('BOTTOMRIGHT', countFrame, 'BOTTOMRIGHT', -1, 0)

	local overlay = button:CreateTexture(nil, 'OVERLAY')
	overlay:SetAllPoints()
	button.overlay = overlay

	button.UpdateTooltip = UpdateTooltip
	button:SetScript('OnEnter', onEnter)
	button:SetScript('OnLeave', onLeave)

	button.icon = icon
	button.count = count
	button.cd = cd

	--[[ Callback: SimpleAuras:PostCreateIcon(button)
	Called after a new aura button has been created.

	* self   - the widget holding the aura buttons
	* button - the newly created aura button (Button)
	--]]
	if(element:GetParent().PostCreateIcon) then element:GetParent():PostCreateIcon(button) end

	return button
end

local function updateIcon(element, unit, index, position, filter, isDebuff)
	local auras = isDebuff and element.debuffFrame or element.buffFrame
	local name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3

	if filter == "TEMP" then
		if index == 16 then
			name, texture, count, debuffType, duration, expiration, caster = "MainHandEnchant", GetInventoryItemTexture("player", index), mainHandCharges, nil, mainHandDuration, mainHandEnd, "player"
		else
			name, texture, count, debuffType, duration, expiration, caster = "OffHandEnchant", GetInventoryItemTexture("player", index), offHandCharges, nil, offHandDuration, offHandEnd, "player"
		end
	else
		name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3 = UnitAura(unit, index, filter)
	end

	if element.forceShow or element.forceCreate then
		spellID = filter == "HELPFUL" and 28059 or filter == "TEMP" and 13852 or 28084
		name, _, texture = GetSpellInfo(spellID)
		if element.forceShow then
			count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, isBossDebuff = filter == "TEMP" and 1 or index, "Magic", 0, 60, (math.random(0,1) > 0) and "player", nil, nil, nil
		end
	end

	if(name) then
		local button = auras[position]
		if(not button) then
			--[[ Override: SimpleAuras:CreateIcon(position)
			Used to create the aura button at a given position.

			* self     - the widget holding the aura buttons
			* position - the position at which the aura button is to be created (number)

			## Returns

			* button - the button used to represent the aura (Button)
			--]]
			auras.createdIcons = auras.createdIcons + 1
			
			button = (element.CreateIcon or createAuraIcon) (auras, position)
			auras[auras.createdIcons] = button

		end

		button.caster = caster
		button.filter = filter
		button.isDebuff = isDebuff
		button.isPlayer = caster == "player" or caster == "vehicle"
		button:SetScript("OnClick", cancelAura)

		if(name) then
			if button.cd then
				if (expiration and expiration > 0) and (duration and duration > 0) and (element.timer == "all" or element.timer == "self" and button.isPlayer) then
					button.cd:SetHideCountdownNumbers(element.disableBCC)
					button.cd.noCooldownCount = element.disableOCC
					button.cd:SetCooldown(expiration - duration, duration)
					button.cd:Show()
				else
					button.cd:Hide()
				end
			end

			if(button.overlay) then
					local color = element.showType and oUF.colors.debuff[debuffType] or {1,1,1}
					button.overlay:SetVertexColor(color[1], color[2], color[3])
				if element.overlay then
					button.overlay:SetTexture(element.overlay)
					button.overlay:SetTexCoord(0,1,0,1)
				else
					button.overlay:SetTexture([[Interface\Buttons\UI-Debuff-Overlays]])
					button.overlay:SetTexCoord(0.306875, 0.5703125, 0, 0.515625)
				end
			end

			if(button.icon) then button.icon:SetTexture(texture) end
			if(button.count) then button.count:SetText(count > 1 and count) end

			local size
			local preventBuffGrowth, preventDebuffGrowth = (element.buffAnchor == "INFRAME" or element.buffAnchor == "INFRAMECENTER"), (element.debuffAnchor == "INFRAME" or element.debuffAnchor == "INFRAMECENTER")
			if isDebuff then
				if not preventDebuffGrowth and element.largeDebuffSize ~= 0 and button.isPlayer then
					size = element.debuffSize + element.largeDebuffSize
				else
					size = element.debuffSize or 16
				end
			else
				if not preventBuffGrowth and element.largeBuffSize ~= 0 and button.isPlayer then
					size = element.buffSize + element.largeBuffSize
				else
					size = element.buffSize or 16
				end
			end
			button:SetSize(size, size)

			button:SetID(index)
			button:Show()

			--[[ Callback: SimpleAuras:PostUpdateIcon(unit, button, index, position)
			Called after the aura button has been updated.

			* self        - the widget holding the aura buttons
			* unit        - the unit on which the aura is cast (string)
			* button      - the updated aura button (Button)
			* index       - the index of the aura (number)
			* position    - the actual position of the aura button (number)
			* duration    - the aura duration in seconds (number?)
			* expiration  - the point in time when the aura will expire. Comparable to GetTime() (number)
			* debuffType  - the debuff type of the aura (string?)['Curse', 'Disease', 'Magic', 'Poison']
			* isStealable - whether the aura can be stolen or purged (boolean)
			--]]
			if(element.PostUpdateIcon) then
				element:PostUpdateIcon(unit, button, index, position, duration, expiration, debuffType, isStealable)
			end

		elseif element.forceCreate then
			local size
			local preventBuffGrowth, preventDebuffGrowth = (element.buffAnchor == "INFRAME" or element.buffAnchor == "INFRAMECENTER"), (element.debuffAnchor == "INFRAME" or element.debuffAnchor == "INFRAMECENTER")
			if isDebuff then
				if not preventDebuffGrowth and element.largeDebuffSize ~= 0 and button.isPlayer then
					size = element.debuffSize + element.largeDebuffSize
				else
					size = element.debuffSize or 16
				end
			else
				if not preventBuffGrowth and element.largeBuffSize ~= 0 and button.isPlayer then
					size = element.buffSize + element.largeBuffSize
				else
					size = element.buffSize or 16
				end
			end
			button:SetSize(size, size)
			button:Hide()

			if element.PostUpdateIcon then
				element:PostUpdateIcon(unit, button, index, position, duration, expiration, debuffType, isStealable)
			end
		end
	end
end

local function UpdateAuras(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.SimpleAuras
	if(element) then
		--[[ Callback: SimpleAuras:PreUpdate(unit)
		Called before the element has been updated.

		* self - the widget holding the aura buttons
		* unit - the unit for which the update has been triggered (string)
		--]]
		if(element.PreUpdate) then element:PreUpdate(unit) end

		-- Update ze iconz here
		local buffs = element.buffFrame
		local currentSlot = 1
		local offset = 0
		local filter = "HELPFUL"..(element.buffFilter == 3 and "|RAID" or "")
		local button
		if element.buffs then
			for i=1,(element.maxBuffs or 32) do
				local name, _, _, _, _, _, caster = UnitAura(self.unit, i, filter)
				if name or element.forceShow then
					if element.buffFilter ~= 2 or caster == "player" then
						updateIcon(element, self.unit, i, currentSlot, filter, false)
						currentSlot = currentSlot + 1
					end
				else
					break
				end
			end
		end
		if element.weapons then
			if (mainHandDuration or element.forceShow) and element.weapons then
				updateIcon(element, "player", 16, currentSlot, "TEMP", false)
				currentSlot = currentSlot + 1
			end
			if (offHandDuration or element.forceShow) and element.weapons then
				updateIcon(element, "player", 17, currentSlot, "TEMP", false)
				currentSlot = currentSlot + 1
			end
		end
		while buffs[currentSlot] do
			buffs[currentSlot]:Hide()
			currentSlot = currentSlot + 1
		end
		
		local debuffs = element.debuffFrame
		currentSlot = 1
		offset = 0
		filter = "HARMFUL"..(element.debuffFilter == 3 and "|RAID" or "")
		if element.debuffs then
			for i=1,(element.maxDebuffs or 40) do
				local name, _, _, _, _, _, caster = UnitAura(self.unit, i, filter)
				if name or element.forceShow then
					if element.debuffFilter ~= 2 or caster == "player" then
						updateIcon(element, self.unit, i, currentSlot, filter, true)
						currentSlot = currentSlot + 1
					end
				else
					break
				end
			end
		end
		while debuffs[currentSlot] do
			debuffs[currentSlot]:Hide()
			currentSlot = currentSlot + 1
		end

		--[[ Callback: SimpleAuras:PostUpdate(unit)
		Called after the element has been updated.

		* self - the widget holding the aura buttons
		* unit - the unit for which the update has been triggered (string)
		--]]
		if(element.PostUpdate) then element:PostUpdate(unit) end
	end
end

local function Update(self, event, unit)
	if self.unit ~= unit then return end
	
	if self.SimpleAuras.forceShow and event == "OnUpdate" then return end
	
	UpdateAuras(self, event, unit)
	
	local element = self.SimpleAuras
	local frameWidth = self:GetWidth() - 2
	local frameHeight, rowHeight = 1, 0
	local button, firstButton, lastButton, rowLenght, buttonSize
	local buffOffset, debuffOffset = 0, 0
	
	if element.wrapBuffSide == "LEFT" then
		if element.wrapBuff > 1 then
			buffOffset = -((element.wrapBuff - 1) * frameWidth)
		else
			buffOffset = frameWidth * (1 - element.wrapBuff)
		end
	end
	if element.wrapDebuffSide == "LEFT" then
		if element.wrapDebuff > 1 then
			debuffOffset = -((element.wrapDebuff - 1) * frameWidth)
		else
			debuffOffset = frameWidth * (1 - element.wrapDebuff)
		end
	end
	
	local buffs = element.buffFrame
	
	buffs:ClearAllPoints()
	if element.buffs or element.weapons then
		if element.buffAnchor == "BOTTOM" then
			buffs:SetPoint("TOP", element, "BOTTOM", 1 + buffOffset, -1)
			for i=1, buffs.createdIcons do
				button = buffs[i]
				button:EnableMouse(true)
				buttonSize = button:GetWidth()
				if not button:IsVisible() then break end
				button:ClearAllPoints()
				if i == 1 then
					button:SetPoint("TOPLEFT", buffs, "TOPLEFT")
					rowLenght = buttonSize
					rowHeight = buttonSize
					firstButton = button
				elseif (rowLenght + buttonSize + element.spacing) > (frameWidth * element.wrapBuff) then
					rowLenght = buttonSize
					button:SetPoint("TOPLEFT", firstButton, "TOPLEFT", 0, (-(element.spacing)-rowHeight))
					firstButton = button
					frameHeight = frameHeight + element.spacing + rowHeight
					rowHeight = buttonSize
				else
					button:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", element.spacing, 0)
					rowLenght = rowLenght + buttonSize + element.spacing
					rowHeight = math.max(rowHeight, buttonSize)
				end
				lastButton = button
			end
			frameHeight = frameHeight + rowHeight
		elseif element.buffAnchor == "TOP" then
			buffs:SetPoint("BOTTOM", element, "TOP", 1 + buffOffset, 1)
			for i=1, buffs.createdIcons do
				button = buffs[i]
				button:EnableMouse(true)
				if not button:IsVisible() then break end
				buttonSize = button:GetWidth()
				button:ClearAllPoints()
				if i == 1 then
					button:SetPoint("BOTTOMLEFT", buffs, "BOTTOMLEFT")
					rowLenght = buttonSize
					rowHeight = buttonSize
					firstButton = button
				elseif (rowLenght + buttonSize + element.spacing) > (frameWidth * element.wrapBuff) then
					rowLenght = buttonSize
					button:SetPoint("BOTTOMLEFT", firstButton, "BOTTOMLEFT", 0, (element.spacing+rowHeight))
					firstButton = button
					frameHeight = frameHeight + element.spacing + rowHeight
					rowHeight = buttonSize
				else
					button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", element.spacing, 0)
					rowLenght = rowLenght + buttonSize + element.spacing
					rowHeight = math.max(rowHeight, buttonSize)
				end
				lastButton = button
			end
			frameHeight = frameHeight + rowHeight
		elseif element.buffAnchor == "LEFT" then
			buffs:SetPoint("BOTTOMRIGHT", element, "LEFT", -1, 0.5)
			for i=1, buffs.createdIcons do
				button = buffs[i]
				button:EnableMouse(true)
				if not button:IsVisible() then break end
				buttonSize = button:GetWidth()
				button:ClearAllPoints()
				if i == 1 then
					button:SetPoint("BOTTOMRIGHT", buffs, "BOTTOMRIGHT")
					rowLenght = buttonSize
					rowHeight = buttonSize
					firstButton = button
				elseif (rowLenght + buttonSize + element.spacing) > (frameWidth * element.wrapBuff) then
					rowLenght = buttonSize
					button:SetPoint("BOTTOMRIGHT", firstButton, "BOTTOMRIGHT", 0, (element.spacing+rowHeight))
					firstButton = button
					frameHeight = frameHeight + element.spacing + rowHeight
					rowHeight = buttonSize
				else
					button:SetPoint("BOTTOMRIGHT", lastButton, "BOTTOMLEFT", -(element.spacing), 0)
					rowLenght = rowLenght + buttonSize + element.spacing
					rowHeight = math.max(rowHeight, buttonSize)
				end
				lastButton = button
			end
			frameHeight = frameHeight + rowHeight
		elseif element.buffAnchor == "RIGHT" then
			buffs:SetPoint("BOTTOMLEFT", element, "RIGHT", 1, 0.5)
			for i=1, buffs.createdIcons do
				button = buffs[i]
				button:EnableMouse(true)
				if not button:IsVisible() then break end
				buttonSize = button:GetWidth()
				button:ClearAllPoints()
				if i == 1 then
					button:SetPoint("BOTTOMLEFT", buffs, "BOTTOMLEFT")
					rowLenght = buttonSize
					rowHeight = buttonSize
					firstButton = button
				elseif (rowLenght + buttonSize + element.spacing) > (frameWidth * element.wrapBuff) then
					rowLenght = buttonSize
					button:SetPoint("BOTTOMLEFT", firstButton, "BOTTOMLEFT", 0, (element.spacing+rowHeight))
					firstButton = button
					frameHeight = frameHeight + element.spacing + rowHeight
					rowHeight = buttonSize
				else
					button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", element.spacing, 0)
					rowLenght = rowLenght + buttonSize + element.spacing
					rowHeight = math.max(rowHeight, buttonSize)
				end
				lastButton = button
			end
			frameHeight = frameHeight + rowHeight
		elseif element.buffAnchor == "INFRAME" then
			frameHeight = self:GetHeight() / 2
			for i=1, buffs.createdIcons do
				button = buffs[i]
				button:EnableMouse(false)
				if not button:IsVisible() then break end
				button:ClearAllPoints()
				if i == 1 then
					button:SetPoint("TOPLEFT", element, "TOPLEFT", 1, -1)
					rowLenght = element.buffSize + element.spacing
					firstButton = button
				elseif (rowLenght + element.buffSize) <= frameWidth then
					rowLenght = rowLenght + element.buffSize + element.spacing
					button:SetPoint("LEFT", firstButton, "RIGHT", element.spacing, 0)
					firstButton = button
				else
					button:Hide()
				end
			end
		else
			frameHeight = self:GetHeight() / 2
			for i=1, buffs.createdIcons do
				button = buffs[i]
				button:EnableMouse(false)
				if not button:IsVisible() then break end
				button:ClearAllPoints()
				if i == 1 then
					button:SetPoint("BOTTOMLEFT", element, "LEFT", 1, 0)
					rowLenght = element.buffSize + element.spacing
					firstButton = button
				elseif (rowLenght + element.buffSize) <= frameWidth then
					rowLenght = rowLenght + element.buffSize + element.spacing
					button:SetPoint("BOTTOMLEFT", firstButton, "BOTTOMRIGHT", element.spacing, 0)
					firstButton = button
				else
					button:Hide()
				end
			end
		end
	end
	buffs:SetSize(frameWidth, frameHeight)
	
	local debuffs = element.debuffFrame
	local anchorFrame = (element.buffs or element.weapons) and element.buffAnchor == element.debuffAnchor and buffs or element
	offset = element.buffAnchor ~= element.debuffAnchor and 1 or 0
	frameHeight = 1
	rowHeight = 0
	
	debuffs:ClearAllPoints()
	if element.debuffs then
		if element.debuffAnchor == "BOTTOM" then
			debuffs:SetPoint("TOP", anchorFrame, "BOTTOM", offset + debuffOffset , -1)
			for i=1, debuffs.createdIcons do
				button = debuffs[i]
				button:EnableMouse(true)
				if not button:IsVisible() then break end
				buttonSize = button:GetWidth()
				button:ClearAllPoints()
				if i == 1 then
					button:SetPoint("TOPLEFT", debuffs, "TOPLEFT")
					rowLenght = buttonSize
					rowHeight = buttonSize
					firstButton = button
				elseif (rowLenght + buttonSize + element.spacing) > (frameWidth * element.wrapDebuff) then
					rowLenght = buttonSize
					button:SetPoint("TOPLEFT", firstButton, "TOPLEFT", 0, (-(element.spacing)-rowHeight))
					firstButton = button
					frameHeight = frameHeight + element.spacing + rowHeight
					rowHeight = buttonSize
				else
					button:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", element.spacing, 0)
					rowLenght = rowLenght + buttonSize + element.spacing
					rowHeight = math.max(rowHeight, buttonSize)
				end
				lastButton = button
			end
			frameHeight = frameHeight + rowHeight
		elseif element.debuffAnchor == "TOP" then
			debuffs:SetPoint("BOTTOM", anchorFrame, "TOP", offset + debuffOffset , 1)
			for i=1, debuffs.createdIcons do
				button = debuffs[i]
				button:EnableMouse(true)
				if not button:IsVisible() then break end
				buttonSize = button:GetWidth()
				button:ClearAllPoints()
				if i == 1 then
					button:SetPoint("BOTTOMLEFT", debuffs, "BOTTOMLEFT")
					rowLenght = buttonSize
					rowHeight = buttonSize
					firstButton = button
				elseif (rowLenght + buttonSize + element.spacing) > (frameWidth * element.wrapDebuff) then
					rowLenght = buttonSize
					button:SetPoint("BOTTOMLEFT", firstButton, "BOTTOMLEFT", 0, (element.spacing+rowHeight))
					firstButton = button
					frameHeight = frameHeight + element.spacing + rowHeight
					rowHeight = buttonSize
				else
					button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", element.spacing, 0)
					rowLenght = rowLenght + buttonSize + element.spacing
					rowHeight = math.max(rowHeight, buttonSize)
				end
				lastButton = button
			end
			frameHeight = frameHeight + rowHeight
		elseif element.debuffAnchor == "LEFT" then
			debuffs:SetPoint("TOPRIGHT", element, "LEFT", -1, -0.5)
			for i=1, debuffs.createdIcons do
				button = debuffs[i]
				button:EnableMouse(true)
				if not button:IsVisible() then break end
				buttonSize = button:GetWidth()
				button:ClearAllPoints()
				if i == 1 then
					button:SetPoint("TOPRIGHT", debuffs, "TOPRIGHT")
					rowLenght = buttonSize
					rowHeight = buttonSize
					firstButton = button
				elseif (rowLenght + buttonSize + element.spacing) > (frameWidth * element.wrapDebuff) then
					rowLenght = buttonSize
					button:SetPoint("TOPRIGHT", firstButton, "TOPRIGHT", 0, (-(element.spacing)-rowHeight))
					firstButton = button
					frameHeight = frameHeight + element.spacing + rowHeight
					rowHeight = buttonSize
				else
					button:SetPoint("TOPRIGHT", lastButton, "TOPLEFT", -(element.spacing), 0)
					rowLenght = rowLenght + buttonSize + element.spacing
					rowHeight = math.max(rowHeight, buttonSize)
				end
				lastButton = button
			end
			frameHeight = frameHeight + rowHeight
		elseif element.debuffAnchor == "RIGHT" then
			debuffs:SetPoint("TOPLEFT", element, "RIGHT", 1, -0.5)
			for i=1, debuffs.createdIcons do
				button = debuffs[i]
				button:EnableMouse(true)
				if not button:IsVisible() then break end
				buttonSize = button:GetWidth()
				button:ClearAllPoints()
				if i == 1 then
					button:SetPoint("TOPLEFT", debuffs, "TOPLEFT")
					rowLenght = buttonSize
					rowHeight = buttonSize
					firstButton = button
				elseif (rowLenght + buttonSize + element.spacing) > (frameWidth * element.wrapDebuff) then
					rowLenght = buttonSize
					button:SetPoint("TOPLEFT", firstButton, "TOPLEFT", 0, (-(element.spacing)-rowHeight))
					firstButton = button
					frameHeight = frameHeight + element.spacing + rowHeight
					rowHeight = buttonSize
				else
					button:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", element.spacing, 0)
					rowLenght = rowLenght + buttonSize + element.spacing
					rowHeight = math.max(rowHeight, buttonSize)
				end
				lastButton = button
			end
			frameHeight = frameHeight + rowHeight
		elseif element.debuffAnchor == "INFRAME" then
			for i=1, debuffs.createdIcons do
				button = debuffs[i]
				button:EnableMouse(false)
				if not button:IsVisible() then break end
				button:ClearAllPoints()
				if i == 1 then
					button:SetPoint("BOTTOMLEFT", element, "BOTTOMLEFT", 1, 1)
					rowLenght = element.debuffSize + element.spacing
					firstButton = button
				elseif (rowLenght + element.debuffSize) <= frameWidth then
					rowLenght = rowLenght + element.debuffSize + element.spacing
					button:SetPoint("LEFT", firstButton, "RIGHT", element.spacing, 0)
					firstButton = button
				else
					button:Hide()
				end
			end
		else
			for i=1, debuffs.createdIcons do
				button = debuffs[i]
				button:EnableMouse(false)
				if not button:IsVisible() then break end
				button:ClearAllPoints()
				if i == 1 then
					button:SetPoint("TOPLEFT", element, "LEFT", 1, 0)
					rowLenght = element.debuffSize + element.spacing
					firstButton = button
				elseif (rowLenght + element.debuffSize) <= frameWidth then
					rowLenght = rowLenght + element.debuffSize + element.spacing
					button:SetPoint("TOPLEFT", firstButton, "TOPRIGHT", element.spacing, 0)
					firstButton = button
				else
					button:Hide()
				end
			end
		end
	end
	debuffs:SetSize(frameWidth, frameHeight)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local playerFrames = {}
local function UpdateWeaponEnchants(self, silent)
	local hasMainHandEnchant, mainHandExpiration, mainHandChargeNum, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandChargeNum, offHandEnchantId = GetWeaponEnchantInfo()
	if hasMainHandEnchant then
		mainHandEnd = GetTime() + (mainHandExpiration / 1000)
		mainHandDuration = weaponEnchantData[mainHandEnchantID] or 1800
		mainHandCharges = mainHandChargeNum
	else
		mainHandEnd = nil
		mainHandDuration = nil
		mainHandCharges = nil
	end
	if hasOffHandEnchant then
		offHandEnd = GetTime() + (offHandExpiration / 1000)
		offHandDuration = weaponEnchantData[offHandEnchantId] or 1800
		offHandCharges = offHandChargeNum
	else
		offHandEnd = nil
		offHandDuration = nil
		offHandCharges = nil
	end
	
	if silent then return end
	for _, frame in pairs(playerFrames) do
		Update(frame, "UNIT_AURA", "player")
	end
end

local function SetWeaponUpdateTimer(self, event, unit)
	if weaponWatchTimer and not weaponWatchTimer:IsCancelled() then
		weaponWatchTimer:Cancel()
	end
	weaponWatchTimer = C_Timer.NewTimer(1, UpdateWeaponEnchants)
end

local function OnSizeChanged(self)
	local frame = self:GetParent()
	Update(frame, "OnSizeChanged", frame.unit)
end

local function Enable(self)

	if self.SimpleAuras then
		local element = self.SimpleAuras

		element.__owner = self
		element.ForceUpdate = ForceUpdate

		-- Avoid parenting GameTooltip to frames with anchoring restrictions,
		-- otherwise it'll inherit said restrictions which will cause issues
		-- with its further positioning, clamping, etc
		if(not pcall(self.GetCenter, self)) then
			element.tooltipAnchor = "ANCHOR_CURSOR"
		else
			element.tooltipAnchor = element.tooltipAnchor or 'ANCHOR_BOTTOMRIGHT'
		end

		self:RegisterEvent("UNIT_AURA", Update)
		
		if self.unit == "player" and not self.__eventless then
			playerFrames[self] = self
			self:RegisterEvent("UNIT_INVENTORY_CHANGED", SetWeaponUpdateTimer)
			UpdateWeaponEnchants(self, true)
		end

		element.buffFrame = element.buffFrame or CreateFrame("Frame", "$parentBuffFrame", element)
		element.buffFrame.createdIcons = element.buffFrame.createdIcons or 0
		element.debuffFrame = element.debuffFrame or CreateFrame("Frame", "$parentDebuffFrame", element)
		element.debuffFrame.createdIcons = element.debuffFrame.createdIcons or 0

		element:Show()

		element:SetScript("OnSizeChanged", OnSizeChanged)

		return true
	end
end

local function Disable(self)
	if(self.SimpleAuras) then
		self:UnregisterEvent("UNIT_AURA", Update)
		self:UnregisterEvent("UNIT_INVENTORY_CHANGED", SetWeaponUpdateTimer)
		playerFrames[self] = nil

		self.SimpleAuras:Hide()
	end
end

oUF:AddElement("SimpleAuras", Update, Enable, Disable)