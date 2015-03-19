local SpellCast = nil
local totemTip = CreateFrame("GameTooltip", "totemTip", nil, "GameTooltipTemplate")
totemTip:SetOwner(WorldFrame, "ANCHOR_NONE")

TotemDB = {
		["Searing Totem"] = {
			["type"] = 1,
			["dur"] = {30,
			35,
			40,
			45,
			50,
			55}
		},
		["Grace of Air Totem"] = {
			["type"] = 4,
			["dur"] = {120,
			120,
			120}
		},
		["Nature Resistance Totem"] = {
			["type"] = 4,
			["dur"] = {120,
			120,
			120}
		};
		["Healing Stream Totem"] = {
			["type"] = 2,
			["dur"] = {60,
			60,
			60,
			60,
			60}
		},
		["Strength of Earth Totem"] = {
			["type"] = 3,
			["dur"] = {120,
			120,
			120,
			120,
			120}
		},
		["Fire Resistance Totem"] = {
			["type"] = 2,
			["dur"] = {120,
			120,
			120}
		},
		["Flametongue Totem"] = {
			["type"] = 1,
			["dur"] = {120,
			120,
			120,
			120}
		},
		["Mana Tide Totem"] = {
			["type"] = 2,
			["dur"] = {12,
			12,
			12}
		},
		["Stoneclaw Totem"] = {
			["type"] = 3,
			["dur"] = {15,
			15,
			15,
			15,
			15,
			15}
		},
		["Magma Totem"] = {
			["type"] = 1,
			["dur"] = {20,
			20,
			20,
			20}
		},
		["Mana Spring Totem"] = {
			["type"] = 2,
			["dur"] = {60,
			60,
			60,
			60}
		},
		["Windwall Totem"] = {
			["type"] = 4,
			["dur"] = {120,
			120,
			120}
		},
		["Frost Resistance Totem"] = {
			["type"] = 1,
			["dur"] = {120,
			120,
			120}
		},
		["Stoneskin Totem"] = {
			["type"] = 3,
			["dur"] = {120,
			120,
			120,
			120,
			120,
			120}
		},
		["Fire Nova Totem"] = {
			["type"] = 1,
			["dur"] = {4,
			4,
			4,
			4,
			4}
		},
		["Windfury Totem"] = {
			["type"] = 4,
			["dur"] = {120,
			120,
			120}
		},
		["Disease Cleansing Totem"] = {
			["type"] = 2,
			["dur"] = {120}
		},
		["Sentry Totem"] = {
			["type"] = 4,
			["dur"] = {300}
		},
		["Grounding Totem"] = {
			["type"] = 4,
			["dur"] = {45}
		},
		["Poison Cleansing Totem"] = {
			["type"] = 2,
			["dur"] = {120}
		},
		["Earthbind Totem"] = {
			["type"] = 3,
			["dur"] = {45}
		},
		["Tremor Totem"] = {
			["type"] = 3,
			["dur"] = {120}
		}
	}
		
local function ProcessSpellCast(spellName, rank)
	if (spellName and rank) then
		SpellCast = {spellName, rank}
		if TotemDB[spellName] then
			LunaUnitFrames.SetTotemTimer(TotemDB[spellName]["type"], TotemDB[spellName]["dur"][tonumber(rank)])
		end
	end
end	
		
oldCastSpell = CastSpell
function newCastSpell(spellId, spellbookTabNum)
	-- Call the original function so there's no delay while we process
	oldCastSpell(spellId, spellbookTabNum)
	local spellName, rank = GetSpellName(spellId, spellbookTabNum)
	_,_,rank = string.find(rank,"(%d+)")
	ProcessSpellCast(spellName, rank)
end
CastSpell = newCastSpell

oldCastSpellByName = CastSpellByName
function newCastSpellByName(spellName, onSelf)
	-- Call the original function
	oldCastSpellByName(spellName, onSelf)
	local _,_,rank = string.find(spellName,"(%d+)")
	local _, _, spellName = string.find(spellName, "^([^%(]+)")
	if not rank then
		local i = 1
		while GetSpellName(i, BOOKTYPE_SPELL) do
			local s, r = GetSpellName(i, BOOKTYPE_SPELL)
			if s == spellName then
				rank = r
			end
			i = i+1
		end
		if rank then
			_,_,rank = string.find(rank,"(%d+)")
		end
	end
	if (spellName) then
		ProcessSpellCast(spellName, rank)
	end
end
CastSpellByName = newCastSpellByName

oldUseAction = UseAction
function newUseAction(a1, a2, a3)
	totemTip:SetAction(a1)
	local spellName = totemTipTextLeft1:GetText()
	-- Call the original function
	oldUseAction(a1, a2, a3)
	-- Test to see if this is a macro
	if ( GetActionText(a1) or not spellName ) then
		return
	end
	local rank = totemTipTextRight1:GetText()
	if rank then
		_,_,rank = string.find(rank,"(%d+)")
	end
	ProcessSpellCast(spellName, rank)
end
UseAction = newUseAction