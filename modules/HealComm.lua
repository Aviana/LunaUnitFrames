local roster = AceLibrary("RosterLib-2.0")
LunaUnitFrames.HealComm = CreateFrame("Frame")
LunaUnitFrames.HealComm.SpecialEventScheduler = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")
LunaUnitFrames.HealComm.pendingResurrections = {}
LunaUnitFrames.HealComm.Heals = {}
LunaUnitFrames.HealComm.Lookup = {}
LunaUnitFrames.HealComm.Spells = {
	["Holy Light"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (44*hlMod+(((2.5/3.5) * SpellPower)*0.1))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (88*hlMod+(((2.5/3.5) * SpellPower)*0.224))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (174*hlMod+(((2.5/3.5) * SpellPower)*0.476))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (334*hlMod+((2.5/3.5) * SpellPower))
		end;
		[5] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (522*hlMod+((2.5/3.5) * SpellPower))
		end;
		[6] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (740*hlMod+((2.5/3.5) * SpellPower))
		end;
		[7] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (1000*hlMod+((2.5/3.5) * SpellPower))
		end;
		[8] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (1318*hlMod+((2.5/3.5) * SpellPower))
		end;
		[9] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (1681*hlMod+((2.5/3.5) * SpellPower))
		end;
	};
	["Flash of Light"] = {
		[1] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (68*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
		[2] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (104*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
		[3] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (155*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
		[4] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (210*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
		[5] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (284*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
		[6] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (364*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
		[7] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (481*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
	};
	["Healing Wave"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (40*pMod+(((1.5/3.5) * SpellPower)*0.22))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (72*pMod+(((2/3.5) * SpellPower)*0.38))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (143*pMod+(((2.5/3.5) * SpellPower)*0.446))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (293*pMod+(((3/3.5) * SpellPower)*0.7))
		end;
		[5] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (409*pMod+((3/3.5) * SpellPower))
		end;
		[6] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (580*pMod+((3/3.5) * SpellPower))
		end;
		[7] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (798*pMod+((3/3.5) * SpellPower))
		end;
		[8] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (1093*pMod+((3/3.5) * SpellPower))
		end;
		[9] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (1465*pMod+((3/3.5) * SpellPower))
		end;
		[10] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (1736*pMod+((3/3.5) * SpellPower))
		end;
	};
	["Lesser Healing Wave"] = {
		[1] = function (SpellPower)
			local tp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Totem of Sustaining" then
					tp = 53
				elseif name == "Totem of Life" then
					tp = 80
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (175*pMod+tp+((1.5/3.5) * SpellPower))
		end;
		[2] = function (SpellPower)
			local tp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Totem of Sustaining" then
					tp = 53
				elseif name == "Totem of Life" then
					tp = 80
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (265*pMod+tp+((1.5/3.5) * SpellPower))
		end;
		[3] = function (SpellPower)
			local tp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Totem of Sustaining" then
					tp = 53
				elseif name == "Totem of Life" then
					tp = 80
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (360*pMod+tp+((1.5/3.5) * SpellPower))
		end;
		[4] = function (SpellPower)
			local tp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Totem of Sustaining" then
					tp = 53
				elseif name == "Totem of Life" then
					tp = 80
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (487*pMod+tp+((1.5/3.5) * SpellPower))
		end;
		[5] = function (SpellPower)
			local tp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Totem of Sustaining" then
					tp = 53
				elseif name == "Totem of Life" then
					tp = 80
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (669*pMod+tp+((1.5/3.5) * SpellPower))
		end;
		[6] = function (SpellPower)
			local tp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Totem of Sustaining" then
					tp = 53
				elseif name == "Totem of Life" then
					tp = 80
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (881*pMod+tp+((1.5/3.5) * SpellPower))
		end;
	};
	["Chain Heal"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (344*pMod+((2.5/3.5) * SpellPower))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (435*pMod+((2.5/3.5) * SpellPower))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (591*pMod+((2.5/3.5) * SpellPower))
		end;
	};
	["Lesser Heal"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (52*shMod+((1.5/3.5) * (SpellPower+sgMod))*0.19)
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (79*shMod+((2/3.5) * (SpellPower+sgMod))*0.34)
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (147*shMod+((2.5/3.5) * (SpellPower+sgMod))*0.6)
		end;
	};
	["Heal"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (319*shMod+((3/3.5) * (SpellPower+sgMod))*0.586)
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (471*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (610*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (759*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
	};
	["Greater Heal"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (957*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (1220*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (1524*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (1903*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
		[5] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (2081*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
	};
	["Prayer of Healing"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (311*shMod+((3/3.5/3) * (SpellPower+sgMod)))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (460*shMod+((3/3.5/3) * (SpellPower+sgMod)))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (676*shMod+((3/3.5/3) * (SpellPower+sgMod)))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (965*shMod+((3/3.5/3) * (SpellPower+sgMod)))
		end;
	};
	["Healing Touch"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return (43*gnMod+((1.5/3.5) * SpellPower)*0.246)
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return (101*gnMod+((2/3.5) * SpellPower)*0.487)
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return (220*gnMod+((2.5/3.5) * SpellPower)*0.568)
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return (435*gnMod+((3/3.5) * SpellPower))
		end;
		[5] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((634*gnMod)+SpellPower)
		end;
		[6] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((819*gnMod)+SpellPower)
		end;
		[7] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((1029*gnMod)+SpellPower)
		end;
		[8] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((1314*gnMod)+SpellPower)
		end;
		[9] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((1657*gnMod)+SpellPower)
		end;
		[10] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((2061*gnMod)+SpellPower)
		end;
		[11] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((2473*gnMod)+SpellPower)
		end;
	};
	["Regrowth"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((91*gnMod)+(((2/3.5)*SpellPower)*0.5*0.38))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((177*gnMod)+(((2/3.5)*SpellPower)*0.5*0.513))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((258*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((340*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
		[5] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((432*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
		[6] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((544*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
		[7] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((686*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
		[8] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((858*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
		[9] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((1062*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
	};
}

LunaUnitFrames.HealComm.Resurrections = {
	["Resurrection"] = true;
	["Rebirth"] = true;
	["Redemption"] = true;
	["Ancestral Spirit"] = true;
}

local function strsplit(pString, pPattern)
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = strfind(pString, fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = strfind(pString, fpat, last_end)
   end
   if last_end <= strlen(pString) then
      cap = strfind(pString, last_end)
      table.insert(Table, cap)
  end
 
   return Table
end

LunaUnitFrames.HealComm:RegisterEvent("SPELLCAST_START")
LunaUnitFrames.HealComm:RegisterEvent("SPELLCAST_INTERRUPTED")
LunaUnitFrames.HealComm:RegisterEvent("SPELLCAST_FAILED")
LunaUnitFrames.HealComm:RegisterEvent("SPELLCAST_DELAYED")
LunaUnitFrames.HealComm:RegisterEvent("CHAT_MSG_ADDON")

luna_SpellSpell = nil
luna_RankRank = nil
luna_SpellCast = nil

LunaTip = CreateFrame("GameTooltip", "LunaTip", nil, "GameTooltipTemplate")
LunaTip:SetOwner(WorldFrame, "ANCHOR_NONE")

local function startResurrection(caster, target)
	if not LunaUnitFrames.HealComm.pendingResurrections[target] then
		LunaUnitFrames.HealComm.pendingResurrections[target] = {}
	end
	LunaUnitFrames.HealComm.pendingResurrections[target][caster] = GetTime()+70
end

local function cancelResurrection(caster)
	for k,v in pairs(LunaUnitFrames.HealComm.pendingResurrections) do
		if v[caster] and (v[caster]-GetTime()) > 60 then
			LunaUnitFrames.HealComm.pendingResurrections[k][caster] = nil
		end
	end
end

LunaUnitFrames.HealComm.OnEvent = function()
	if ( event == "SPELLCAST_START" ) then
		if ( luna_SpellCast and luna_SpellCast[1] == arg1 and LunaUnitFrames.HealComm.Spells[arg1] ) then
			local Bonus = tonumber(BonusScanner:GetBonus("HEAL"))
			local zone = GetRealZoneText()
			if zone == "Warsong Gulch" or zone == "Arathi Basin" or zone == "Alterac Valley" then
				SendAddonMessage( "LunaComm", "Heal/"..luna_SpellCast[3].."/"..math.floor(LunaUnitFrames.HealComm.Spells[luna_SpellCast[1]][tonumber(luna_SpellCast[2])](Bonus)).."/"..arg2.."/", "BATTLEGROUND" )
			else
				SendAddonMessage( "LunaComm", "Heal/"..luna_SpellCast[3].."/"..math.floor(LunaUnitFrames.HealComm.Spells[luna_SpellCast[1]][tonumber(luna_SpellCast[2])](Bonus)).."/"..arg2.."/", "RAID" )
			end
			luna_spellIsCasting = arg1
			LunaUnitFrames.HealComm.SpecialEventScheduler:startHeal(UnitName("player"), luna_SpellCast[3], math.floor(LunaUnitFrames.HealComm.Spells[luna_SpellCast[1]][tonumber(luna_SpellCast[2])](Bonus)), arg2)
		elseif ( luna_SpellCast and luna_SpellCast[1] == arg1 and LunaUnitFrames.HealComm.Resurrections[arg1] ) then
			local zone = GetRealZoneText()
			if zone == "Warsong Gulch" or zone == "Arathi Basin" or zone == "Alterac Valley" then
				SendAddonMessage( "LunaComm", "Resurrection/"..luna_SpellCast[3].."/start/", "BATTLEGROUND" )
			else
				SendAddonMessage( "LunaComm", "Resurrection/"..luna_SpellCast[3].."/start/", "RAID" )
			end
			luna_spellIsCasting = arg1
			startResurrection(UnitName("player"), luna_SpellCast[3])
		end
	elseif (event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED") and LunaUnitFrames.HealComm.Spells[luna_spellIsCasting] then
		local zone = GetRealZoneText()
		if zone == "Warsong Gulch" or zone == "Arathi Basin" or zone == "Alterac Valley" then
			SendAddonMessage( "LunaComm", "Healstop", "BATTLEGROUND" )
		else
			SendAddonMessage( "LunaComm", "Healstop", "RAID" )
		end
		luna_spellIsCasting = nil
		luna_SpellCast =  nil
		luna_RankRank = nil
		luna_SpellSpell =  nil
		LunaUnitFrames.HealComm.SpecialEventScheduler:stopHeal(UnitName("player"))
	elseif (event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED") and LunaUnitFrames.HealComm.Resurrections[luna_spellIsCasting] then
		local zone = GetRealZoneText()
		if zone == "Warsong Gulch" or zone == "Arathi Basin" or zone == "Alterac Valley" then
			SendAddonMessage( "LunaComm", "Resurrection/stop/", "BATTLEGROUND" )
		else
			SendAddonMessage( "LunaComm", "Resurrection/stop/", "RAID" )
		end
		luna_spellIsCasting = nil
		luna_SpellCast =  nil
		luna_RankRank = nil
		luna_SpellSpell =  nil
		cancelResurrection(UnitName("player"))
	elseif event == "SPELLCAST_DELAYED" then
		local zone = GetRealZoneText()
		if zone == "Warsong Gulch" or zone == "Arathi Basin" or zone == "Alterac Valley" then
			SendAddonMessage( "LunaComm", "Healdelay/"..arg1.."/", "BATTLEGROUND" )
		else
			SendAddonMessage( "LunaComm", "Healdelay/"..arg1.."/", "RAID" )
		end
		LunaUnitFrames.HealComm.SpecialEventScheduler:delayHeal(UnitName("player"), arg1)
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 ~= "LunaComm" or arg4 == UnitName("player") then
			return
		end
		local result = strsplit(arg2,"/")
		if result[1] == "Heal" then
			LunaUnitFrames.HealComm.SpecialEventScheduler:startHeal(arg4, result[2], result[3], result[4])
		elseif arg2 == "Healstop" then
			LunaUnitFrames.HealComm.SpecialEventScheduler:stopHeal(arg4)
		elseif result[1] == "Healdelay" then
			LunaUnitFrames.HealComm.SpecialEventScheduler:delayHeal(arg4, result[2])
		elseif result[1] == "Resurrection" and result[2] == "stop" then
			cancelResurrection(arg4)
		elseif result[1] == "Resurrection" and result[3] == "start" then
			startResurrection(arg4, result[2])
		end
	end
end

LunaUnitFrames.HealComm:SetScript("OnEvent", LunaUnitFrames.HealComm.OnEvent)

function LunaUnitFrames.HealComm.SpecialEventScheduler.stopHeal(self, caster)
	if LunaUnitFrames.HealComm.SpecialEventScheduler:IsEventScheduled(caster) then
		LunaUnitFrames.HealComm.SpecialEventScheduler:CancelScheduledEvent(caster)
	end
	if LunaUnitFrames.HealComm.Lookup[caster] then
		LunaUnitFrames.HealComm.Heals[LunaUnitFrames.HealComm.Lookup[caster]][caster] = nil
		LunaUnitFrames.HealComm.Lookup[caster] = nil
	end
	LunaUnitFrames:PlayerUpdateHeal()
	LunaUnitFrames:TargetUpdateHeal()
	LunaUnitFrames:PartyUpdateHeal()
end

function LunaUnitFrames.HealComm.SpecialEventScheduler:startHeal(caster, target, size, casttime)
	LunaUnitFrames.HealComm.SpecialEventScheduler:ScheduleEvent(caster, LunaUnitFrames.HealComm.SpecialEventScheduler.stopHeal, (casttime/1000), this, caster)
	if not LunaUnitFrames.HealComm.Heals[target] then
		LunaUnitFrames.HealComm.Heals[target] = {}
	end
	LunaUnitFrames.HealComm.Heals[target][caster] = {amount = size, ctime = (casttime/1000)+GetTime()}
	LunaUnitFrames.HealComm.Lookup[caster] = target
	LunaUnitFrames:PlayerUpdateHeal()
	LunaUnitFrames:TargetUpdateHeal()
	LunaUnitFrames:PartyUpdateHeal()
end

function LunaUnitFrames.HealComm.SpecialEventScheduler:delayHeal(caster, delay)
	LunaUnitFrames.HealComm.SpecialEventScheduler:CancelScheduledEvent(caster)
	if LunaUnitFrames.HealComm.Heals[LunaUnitFrames.HealComm.Lookup[caster]] then
		LunaUnitFrames.HealComm.Heals[LunaUnitFrames.HealComm.Lookup[caster]][caster].ctime = LunaUnitFrames.HealComm.Heals[LunaUnitFrames.HealComm.Lookup[caster]][caster].ctime + (delay/1000)
		LunaUnitFrames.HealComm.SpecialEventScheduler:ScheduleEvent(caster, LunaUnitFrames.HealComm.SpecialEventScheduler.stopHeal, (LunaUnitFrames.HealComm.Heals[LunaUnitFrames.HealComm.Lookup[caster]][caster].ctime-GetTime()), this, caster)
	end
end

luna_oldCastSpell = CastSpell
function luna_newCastSpell(spellId, spellbookTabNum)
	-- Call the original function so there's no delay while we process
	luna_oldCastSpell(spellId, spellbookTabNum)
	
	local spellName, rank = GetSpellName(spellId, spellbookTabNum)
	_,_,rank = string.find(rank,"(%d+)")
	if ( SpellIsTargeting() ) then 
       -- Spell is waiting for a target
       luna_SpellSpell = spellName
	   luna_RankRank = rank
	elseif ( UnitIsVisible("target") and UnitIsConnected("target") and UnitReaction("target", "player") > 4 ) then
       -- Spell is being cast on the current target.  
       -- If ClearTarget() had been called, we'd be waiting target
	   luna_ProcessSpellCast(spellName, rank, UnitName("target"))
	else
		luna_ProcessSpellCast(spellName, rank, UnitName("player"))
	end
end
CastSpell = luna_newCastSpell

luna_oldCastSpellByName = CastSpellByName
function luna_newCastSpellByName(spellName, onSelf)
	-- Call the original function
	luna_oldCastSpellByName(spellName, onSelf)
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
		_,_,rank = string.find(rank,"(%d+)")
	end
	if ( spellName ) then
		if ( SpellIsTargeting() ) then
			luna_SpellSpell = spellName
		else
			if UnitIsVisible("target") and UnitIsConnected("target") and UnitReaction("target", "player") > 4 then
				luna_ProcessSpellCast(spellName, rank, UnitName("target"))
			else
				luna_ProcessSpellCast(spellName, rank, UnitName("player"))
			end
		end
	end
end
CastSpellByName = luna_newCastSpellByName

luna_oldWorldFrameOnMouseDown = WorldFrame:GetScript("OnMouseDown")
WorldFrame:SetScript("OnMouseDown", function()
	-- If we're waiting to target
	local targetName
	
	if ( luna_SpellSpell and UnitName("mouseover") ) then
		targetName = UnitName("mouseover")
	elseif ( luna_SpellSpell and GameTooltipTextLeft1:IsVisible() ) then
		local _, _, name = string.find(GameTooltipTextLeft1:GetText(), "^Corpse of (.+)$")
		if ( name ) then
			targetName = name
		end
	end
	if ( luna_oldWorldFrameOnMouseDown ) then
		luna_oldWorldFrameOnMouseDown()
	end
	if ( luna_SpellSpell and targetName ) then
		luna_ProcessSpellCast(luna_SpellSpell, luna_RankRank, targetName)
	end
end)

luna_oldUseAction = UseAction
function luna_newUseAction(a1, a2, a3)
	
	LunaTip:SetAction(a1)
	local spellName = LunaTipTextLeft1:GetText()
	luna_SpellSpell = spellName
	
	-- Call the original function
	luna_oldUseAction(a1, a2, a3)
	
	-- Test to see if this is a macro
	if ( GetActionText(a1) or not luna_SpellSpell ) then
		return
	end
	local rank = LunaTipTextRight1:GetText()
	if rank then
		_,_,rank = string.find(rank,"(%d+)")
		luna_RankRank = rank
	end
	
	if ( SpellIsTargeting() ) then
		-- Spell is waiting for a target
		return
	elseif ( UnitIsVisible("target") and UnitIsConnected("target") and UnitReaction("target", "player") > 4 ) then
		-- Spell is being cast on the current target
		luna_ProcessSpellCast(spellName, rank, UnitName("target"))
	else
		-- Spell is being cast on the player
		luna_ProcessSpellCast(spellName, rank, UnitName("player"))
	end
end
UseAction = luna_newUseAction

luna_oldSpellTargetUnit = SpellTargetUnit
function luna_newSpellTargetUnit(unit)
	-- Call the original function
	local shallTargetUnit
	if ( SpellIsTargeting() ) then
		shallTargetUnit = true
	end
	luna_oldSpellTargetUnit(unit)
	if ( shallTargetUnit and luna_SpellSpell and not SpellIsTargeting() ) then
		luna_ProcessSpellCast(luna_SpellSpell, luna_RankRank, UnitName(unit))
		luna_SpellSpell = nil
		luna_RankRank = nil
	end
end
SpellTargetUnit = luna_newSpellTargetUnit

luna_oldSpellStopTargeting = SpellStopTargeting
function luna_newSpellStopTargeting()
	luna_oldSpellStopTargeting()
	luna_SpellSpell = nil
	luna_RankRank = nil
end
SpellStopTargeting = luna_newSpellStopTargeting

luna_oldTargetUnit = TargetUnit
function luna_newTargetUnit(unit)
	-- Call the original function
	luna_oldTargetUnit(unit)
	
	-- Look to see if we're currently waiting for a target internally
	-- If we are, then well glean the target info here.
	
	if ( luna_SpellSpell and UnitExists(unit) ) then
		luna_ProcessSpellCast(luna_SpellSpell, luna_RankRank, UnitName(unit))
	end
end
TargetUnit = luna_newTargetUnit

function luna_ProcessSpellCast(spellName, rank, targetName)
	if ( spellName and rank and targetName ) then
		luna_SpellCast = { spellName, rank, targetName }
	end
end