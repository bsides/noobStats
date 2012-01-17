local _, noobStats = ...

-- Localization Stuff
local function defaultFunc(L, key)
 -- If this function was called, we have no localization for this key.
 -- We could complain loudly to allow localizers to see the error of their ways, 
 -- but, for now, just return the key as its own localization. This allows you to 
 -- avoid writing the default localization out explicitly.
 return key;
end
noobStatsLocalizationTable = setmetatable({}, {__index=defaultFunc});
local L = noobStatsLocalizationTable;
if GetLocale() == "ptBR" then
	L["noobUI Hybrid Stats"] = "noobUI Atributos Híbridos";
end
--

local noobLDBHybrid = LibStub("LibDataBroker-1.1"):NewDataObject("noobCrit", {
	type = "data source", 
	text = "0", 
	label = "Crit" -- wonder why people don't use these tags... so useful!
})

local f = CreateFrame("Frame")
--f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
f:RegisterEvent("PLAYER_LOGIN")

local function CritOnUpdate()
	local meleeCrit 	= GetCritChance()
	local spellCrit 	= GetSpellCritChance(1)
	local rangedCrit 	= GetRangedCritChance()
	local StatCrit
	if spellCrit > meleeCrit then
		StatCrit = spellCrit
	elseif select(2, UnitClass("Player")) == "HUNTER" then    
		StatCrit = rangedCrit
	else
		StatCrit = meleeCrit
	end

	noobLDBHybrid.text = format("%.2f%%", StatCrit)
end

f:SetScript("OnUpdate", CritOnUpdate)

local noobTip = nil
function noobLDBHybrid.OnTooltipShow(tip)
	if not tip or not tip.AddLine or not tip.AddDoubleLine then return end

	if not noobTip then noobTip = CreateFrame("GameTooltip", "noobTip") end
	
	-- Get Crit values
	local meleeCrit 	= GetCritChance()
	local spellCrit 	= GetSpellCritChance(1)
	local rangedCrit 	= GetRangedCritChance()
	local StatCrit
	local StatCritLabel
	-- Get Haste values
	local meleeHaste	= GetMeleeHaste()
	local spellHaste	= UnitSpellHaste("player")
	local rangedHaste 	= GetRangedHaste()
	local StatHaste
	-- Get Hit Values
	local physicalHit	= GetHitModifier() or 0
	local spellHit		= GetSpellHitModifier() or 0
	local StatHit
	-- Get Mastery Values
	local StatMastery
	
	local classType = select(2, UnitClass("Player"))
	
	if spellCrit > meleeCrit then
		StatCrit = spellCrit
		StatCritLabel = _G["SPELL_CRIT_CHANCE"]
	elseif classType == "HUNTER" then    
		StatCrit = rangedCrit
		StatCritLabel = _G["RANGED_CRIT_CHANCE"]
	else
		StatCrit = meleeCrit
		StatCritLabel = _G["MELEE_CRIT_CHANCE"]
	end	
	
	--dump(noobClassRoles(classType))
	local classRole = noobClassRoles(classType)
	
	if classRole == "Tank" then
		StatHaste = meleeHaste
		StatHit = GetCombatRatingBonus(CR_HIT_MELEE) + physicalHit		-- CR_HIT_MELEE = 6
		classGroup = 1
	elseif classRole == "DPS Melee" then
		StatHaste = meleeHaste
		StatHit = GetCombatRatingBonus(CR_HIT_MELEE) + physicalHit		-- CR_HIT_MELEE = 6
		classGroup = 1
	elseif classRole == "DPS Ranged" then
		StatHaste = rangedHaste
		StatHit = GetCombatRatingBonus(CR_HIT_RANGED) + physicalHit		-- CR_HIT_RANGED = 7
		classGroup = 3
	elseif classRole == "DPS Caster" then
		StatHaste = spellHaste
		StatHit = GetCombatRatingBonus(CR_HIT_SPELL) + spellHit 		-- CR_HIT_SPELL = 8
		classGroup = 2
	elseif classRole == "Healer" then
		StatHaste = spellHaste
		StatHit = GetCombatRatingBonus(CR_HIT_SPELL) + spellHit 		-- CR_HIT_SPELL = 8
		classGroup = 2
	else
		classRole = "Nenhum"
	end
	
	if UnitLevel("player") >= 80 then
		StatMastery = GetMastery()
	end
		
	
	--[[
	if classType == "WARRIOR" 
		or classType == "PALADIN" 
		or classType == "DEATH KNIGHT"
		or classType == "ROGUE"
		or classType == "SHAMAN"
		or classType == "DRUID"
		then
		-- do stat if the class is melee
		StatHaste = meleeHaste
		StatHit = GetCombatRatingBonus(CR_HIT_MELEE) + physicalHit		-- CR_HIT_MELEE = 6
		classGroup = 1
	end
	if classType == "PRIEST"
		or classType == "MAGE"
		or classType == "WARLOCK"
		then
		-- do stat if the class is spellpower user
		StatHaste = spellHaste
		StatHit = GetCombatRatingBonus(CR_HIT_SPELL) + spellHit 		-- CR_HIT_SPELL = 8
		classGroup = 2
	end
	if classType == "HUNTER" then
		-- do stat if the class is... well, hunter
		StatHaste = rangedHaste
		StatHit = GetCombatRatingBonus(CR_HIT_RANGED) + physicalHit		-- CR_HIT_RANGED = 7
		classGroup = 3
	end
	]]
	--[[
	if attackpwr > spellpwr and select(2, UnitClass("Player")) ~= "HUNTER" then
		Text:SetText(format(Stat.Color2.."%.2f%%|r ", GetCombatRatingBonus(6)+cac)..Stat.Color1..HIT.."|r")
	elseif select(2, UnitClass("Player")) == "HUNTER" then
		Text:SetText(format(Stat.Color2.."%.2f%%|r ", GetCombatRatingBonus(7)+cac)..Stat.Color1..HIT.."|r")
	else
		Text:SetText(format(Stat.Color2.."%.2f%%|r ", GetCombatRatingBonus(8)+cast)..Stat.Color1..HIT.."|r")
	end
	]]
			
	tip:AddLine(L["noobUI Hybrid Stats"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	tip:AddLine(" ")
	--[[ Now @ statpower.lua, which makes more sense
	if classRole ~= "NENHUM" then
		if classRole == "DPS Melee" or classRole == "DPS Ranged" or classRole == "DPS Caster" then
			tip:AddDoubleLine(_G["YOUR_ROLE"], INLINE_DAMAGER_ICON.." "..DAMAGER)
		elseif classRole == "Tank" then
			tip:AddDoubleLine(_G["YOUR_ROLE"], INLINE_TANK_ICON.." "..TANK)
		elseif classRole == "Healer" then
			tip:AddDoubleLine(_G["YOUR_ROLE"], INLINE_HEALER_ICON.." "..HEALER)
		end
	end
	]]--
	tip:AddDoubleLine(format(STAT_FORMAT, StatCritLabel), format("%.2f%%", StatCrit))
	tip:AddDoubleLine(format(STAT_FORMAT, STAT_HASTE), format("%.2f%%", StatHaste))	-- Global Strings used for localization goodies
	if StatMastery ~= nil then
		tip:AddDoubleLine(format(STAT_FORMAT, STAT_MASTERY), format("%.2f%%", StatMastery))
	end
	tip:AddLine(" ")
	tip:AddDoubleLine(format(STAT_FORMAT, STAT_HIT_CHANCE), format("%.2f%%", StatHit))
	if classGroup then noobHitChanceDetails(classGroup, tip) end	-- Hit Details

end

function noobClassRoles(class)
	local classType = class
	local classQuery = GetPrimaryTalentTree()
	local classRole
	
	if classType == "WARRIOR" then
		if classQuery == 3 then
			classRole = "Tank"
		else
			classRole = "DPS Melee"
		end
	end
	if classType == "PALADIN" then
		if classQuery == 1 then
			classRole = "Healer"
		elseif classQuery == 2 then
			classRole = "Tank"
		else
			classRole = "DPS Melee"
		end
	end
	if classType == "DRUID" then
		if classQuery == 1 then
			classRole = "DPS Caster"
		elseif classQuery == 2 then
			-- TODO: check for stamina, agility or dodge to check if either tank or dps melee
			classRole = "Tank"
		else
			classRole = "Healer"
		end
	end
	if classType == "SHAMAN" then
		if classQuery == 1 then
			classRole = "DPS Caster"
		elseif classQuery == 2 then
			classRole = "DPS Melee"
		else
			classRole = "Healer"
		end
	end
	if classType == "DEATH KNIGHT" then
		if classQuery == 1 then
			classRole = "Tank"
		else
			classRole = "DPS Melee"
		end
	end
	if classType == "PRIEST" then
		if classQuery == 3 then
			classRole = "DPS Caster"
		else
			classRole = "Healer"
		end
	end
	if classType == "ROGUE" then
		classRole = "DPS Melee"
	end
	if classType == "HUNTER" then
		classRole = "DPS Ranged"
	end
	if classType == "WARLOCK" then
		classRole = "DPS Caster"
	end
	if classType == "MAGE" then
		classRole = "DPS Caster"
	end
	
	if not classRole then return end
	return classRole
end

function noobHitChanceDetails(class, tip)
	if not tip or not tip.AddLine or not tip.AddDoubleLine then return end
	
	local class = class
	
	if class == 1 then -- melee classes
		tip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		if (IsDualWielding()) then
			tip:AddLine(STAT_HIT_NORMAL_ATTACKS, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end
		local playerLevel = UnitLevel("player");
		for i=0, 3 do
			local missChance = format("%.2F%%", GetMeleeMissChance(i, false));
			local level = playerLevel + i;
				if (i == 3) then
					level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
				end
			tip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
		if (IsDualWielding()) then
			tip:AddLine(STAT_HIT_SPECIAL_ATTACKS, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			for i=0, 3 do
				local missChance = format("%.2F%%", GetMeleeMissChance(i, true));
				local level = playerLevel + i;
				if (i == 3) then
					level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
				end
				tip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			end
		end
	end
	
	if class == 2 then
		tip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		local playerLevel = UnitLevel("player");
		for i=0, 3 do
			local missChance = format("%.2F%%", GetSpellMissChance(i));
			local level = playerLevel + i;
				if (i == 3) then
					level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
				end
			tip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
	end
	
	if class == 3 then
		tip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		local playerLevel = UnitLevel("player");
		for i=0, 3 do
			local missChance = format("%.2F%%", GetRangedMissChance(i));
			local level = playerLevel + i;
				if (i == 3) then
					level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
				end
			tip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
	end
	
end