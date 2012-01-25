local _, noobStats = ...

local f = CreateFrame("Frame")
--f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

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
	L["noobStats Specific Stats"] = "noobStats Atributos Específicos";
	L["Total Avoidance"] = "Total de Evasão" -- alguma tradução melhor para isso?
	L["CTC"] = "CTC" -- see below
	L["Combat Table Coverage"] = "Cobertura da Tabela de Combate (CTC)" -- alguma tradução melhor pra isso?
	L["Includes %d%% chance to be missed by level %d mob"] = "Inclui a chance de erro de %d%% do alvo de nível %d"
	L["Average Mitigation"] = "Média de Mitigação"
end
--

local noobLDBPower = LibStub("LibDataBroker-1.1"):NewDataObject("noobPower", {
	type = "data source", 
	text = "0", 
	label = "Power"
})

local function PowerOnUpdate()
	
	local displayStatLabel -- Label of LDB
	local displayStatText -- Text's Label of LDB

	if noobStats.whatRole() == 1 then -- Tank
		local statMiss				= 5 -- Miss Table (not really a stat)
		if select(2, UnitRace("player")) == "NightElf" then statMiss = 7 end -- Night elves' miss
		local statCTC				= format("%.2f%%", GetDodgeChance() + GetParryChance() + GetBlockChance() + statMiss) -- Combat Table Coverage
		
		displayStatText = statCTC.." / 102.4%"
		displayStatLabel = L["CTC"]
	elseif noobStats.whatRole() == 2 then -- Healer
		-- Caster stats
		-- spellpower
		local statSpellPower 				= GetSpellBonusDamage(7)	-- STAT_SPELLPOWER
		
		displayStatText = statSpellPower
		displayStatLabel = STAT_SPELLPOWER
	elseif noobStats.whatRole() == 3 then -- DPS Caster
		-- Caster stats
		-- spellpower
		local statSpellPower 				= GetSpellBonusDamage(7)	-- STAT_SPELLPOWER
		
		displayStatText = statSpellPower
		displayStatLabel = STAT_SPELLPOWER
	elseif noobStats.whatRole() == 4 then -- DPS Melee
		-- Melee stats
		-- attack power
		local statAttackPowerBase, statAttackPowerPosBuff, statAttackPowerNegBuff = UnitAttackPower("player"); -- STAT_ATTACK_POWER
		local statAttackPowerBonus = max((statAttackPowerBase + statAttackPowerPosBuff + statAttackPowerNegBuff), 0) / ATTACK_POWER_MAGIC_NUMBER; -- 14
		local statAttackPowerEffectiveAP = max(0, statAttackPowerBase + statAttackPowerPosBuff + statAttackPowerNegBuff);

		displayStatText = statAttackPowerEffectiveAP
		displayStatLabel = STAT_ATTACK_POWER	
	elseif noobStats.whatRole() == 5 then -- DPS Ranged
	end
	
	noobLDBPower.label = displayStatLabel
	noobLDBPower.text = displayStatText
end

f:SetScript("OnUpdate", PowerOnUpdate)

local noobTip = nil
function noobLDBPower.OnTooltipShow(tip)
	if not tip or not tip.AddLine or not tip.AddDoubleLine then return end

	if not noobTip then noobTip = CreateFrame("GameTooltip", "noobTip") end

	local classColor = RAID_CLASS_COLORS[select(2, UnitClass("Player"))]
	--self:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b)
	
	-- Basic stats	
	local statStrength		= select(2, UnitStat("player", 1))		-- SPELL_STAT1_NAME
	local statAgility		= select(2, UnitStat("player", 2))		-- SPELL_STAT2_NAME
	local statStamina		= select(2, UnitStat("player", 3))		-- SPELL_STAT3_NAME
	local statIntelect		= select(2, UnitStat("player", 4))		-- SPELL_STAT4_NAME
	local statSpirit		= select(2, UnitStat("player", 5))		-- SPELL_STAT5_NAME	
	
	-- What Basic stats do?											-- DEFAULT_STATx_TOOLTIP
	local statStrengthGives 	= noobGetSubStat("player", 1)
	local statAgilityGives 		= noobGetSubStat("player", 2)		-- STAT_TOOLTIP_BONUS_AP
	local statStaminaGives 		= noobGetSubStat("player", 3)		
	local statIntelectGives	 	= noobGetSubStat("player", 4)		
	local statSpiritGives	 	= noobGetSubStat("player", 5)		

	-- Caster stats
	local statSpellPower 				= GetSpellBonusDamage(7)	-- STAT_SPELLPOWER
	local statHealPower					= GetSpellBonusHealing()	-- STAT_SPELLPOWER (STAT_SPELLHEALING but is there a differnece now?)
	local statRegenIn, statRegenOut		= GetManaRegen()			-- MANA_REGEN & MANA_REGEN_COMBAT
	statRegenIn 	= floor ( statRegenIn * 5.0 ) -- it returns as mp1, show as mp5, same below
	statRegenOut 	= floor ( statRegenOut * 5.0 )

	-- Tank stats
	local statHealth			= UnitHealthMax("player") -- HEALTH
	local statDodge				= format("%.2f%%", GetDodgeChance()) -- DODGE_CHANCE
	local statParry				= format("%.2f%%", GetParryChance()) -- PARRY_CHANCE
	local statBlock				= format("%.2f%%", GetBlockChance()) -- BLOCK_CHANCE
	local statArmor				= select(2, UnitArmor("player")) -- ARMOR
	local statDamageReduction	= PaperDollFrame_GetArmorReduction(statArmor, UnitLevel("player"))	-- DEFAULT_STATARMOR_TOOLTIP

	local statAvoidance			= format("%.2f%%",GetDodgeChance() + GetParryChance()) -- DODGE + PARRY
	local statMiss				= 5 -- Miss Table (not really a stat)
	if select(2, UnitRace("player")) == "NightElf" then statMiss = 7 end
	
	local statCTC				= format("%.2f%%", GetDodgeChance() + GetParryChance() + GetBlockChance() + statMiss) -- Combat Table Coverage
	local statCTCIncludes		= string.format(L["Includes %d%% chance to be missed by level %d mob"], statMiss, UnitLevel("player"))
	
	-- Tank stat disabled to check for truth
	--local statMitTemp			= "0."..statArmor
	--local statMitTemp			= tonumber(statMitTemp)
	--local statMitigationAverage
	--if statMitTemp ~= nil then
	--	statMitigationAverage	= string.format("%.2f%%",102.4-((102.4- (GetDodgeChance()+(GetBlockChance()*.30)+GetParryChance()+5)))*(1-statMitTemp)*.9)
	--end
	
	-- Melee stats
	-- attack power
	local statAttackPowerBase, statAttackPowerPosBuff, statAttackPowerNegBuff = UnitAttackPower("player"); -- STAT_ATTACK_POWER
	local statAttackPowerBonus = max((statAttackPowerBase + statAttackPowerPosBuff + statAttackPowerNegBuff), 0) / ATTACK_POWER_MAGIC_NUMBER; -- 14
	local statAttackPowerEffectiveAP = max(0, statAttackPowerBase + statAttackPowerPosBuff + statAttackPowerNegBuff);
	local statAttackPower = statAttackPowerEffectiveAP
	
	local statAttackPowerGives
	if (GetOverrideSpellPowerByAP() ~= nil) then
		statAttackPowerGives = format(MELEE_ATTACK_POWER_SPELL_POWER_TOOLTIP, statAttackPowerBonus, statAttackPowerEffectiveAP * GetOverrideSpellPowerByAP() + 0.5);
	else
		statAttackPowerGives = format(MELEE_ATTACK_POWER_TOOLTIP, statAttackPowerBonus);
	end	
	
	-- speed
	local statMainSpeed, statOffhandSpeed = UnitAttackSpeed("player")
	
	-- damage
	local statDamageMin, statDamageMax, statDamageMinOffhand, statDamageMaxOffhand, statDamageBonusPos, statDamageBonusNeg, statDamagePercent = UnitDamage("player")
	
	local statDamageMin = max(floor(statDamageMin),1)
	local statDamageMax = max(ceil(statDamageMax),1)
	local statDamageMinOffhand = max(floor(statDamageMinOffhand),1)	-- DAMAGE (max)
	local statDamageMaxOffhand = max(ceil(statDamageMaxOffhand),1)	-- DAMAGE (min)
	
	-- dps
	local statBaseDamage = (statDamageMin + statDamageMax) * 0.5;
	local statFullDamage = (statBaseDamage + statDamageBonusPos + statDamageBonusNeg) * statDamagePercent
	--local statTotalBonus = (statFullDamage - statBaseDamage)		-- not in use right now
	local statMainDPS = format("%.1F", (max(statFullDamage,1) / statMainSpeed))	-- DAMAGE_PER_SECOND
	
	local statOffhandBaseDamage
	local statOffhandFullDamage
	local statOffhandDPS
	
	if (IsDualWielding()) then
		statOffhandBaseDamage = (statDamageMinOffhand + statDamageMaxOffhand) * 0.5;
		statOffhandFullDamage = (statOffhandBaseDamage + statDamageBonusPos + statDamageBonusNeg) * statDamagePercent
		statOffhandDPS = format("%.1F", (max(statOffhandFullDamage,1) / statOffhandSpeed))	-- DAMAGE_PER_SECOND
	end
	
	-- expertise
	local statExpertise, statExpertiseOffhand = GetExpertise()	-- STAT_EXPERTISE
	local statExpertisePercent, statExpertisePercentOffhand = GetExpertisePercent()
	statExpertisePercent = format("%.2F", statExpertisePercent)
	statExpertisePercentOffhand = format("%.2F", statExpertisePercentOffhand)
	
	local expertiseDisplay, expertisePercentDisplay;
	if (IsDualWielding()) then
		expertiseDisplay = statExpertise.." / "..statExpertiseOffhand
		expertisePercentDisplay = statExpertisePercent.."% / "..statExpertisePercentOffhand.."%"
	else
		expertiseDisplay = statExpertise;
		expertisePercentDisplay = statExpertisePercent.."%"
	end
	
	-- Ranged stats
	--Agility
	--Dano (Arma)
    --DPS (Arma)
    --Poder de Ataque
    --Velocidade (Arma)
	
	-- Misc stats
	local PetHealth		= UnitHealthMax("pet")
	
	
	-- Tooltip!
	local whatClass = noobClassRoles(select(2, UnitClass("Player")))
	
	tip:AddLine(L["noobStats Specific Stats"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	if whatClass ~= "NENHUM" then
		if whatClass == "DPS Melee" or whatClass == "DPS Ranged" or whatClass == "DPS Caster" then
			tip:AddLine(select(1,UnitClass("player")).." "..INLINE_DAMAGER_ICON.." "..DAMAGER, classColor.r, classColor.g, classColor.b, true)
			--tip:AddDoubleLine(YOUR_ROLE.." / "..CLASS, INLINE_DAMAGER_ICON.." "..DAMAGER.." "..select(1,UnitClass("player")), classColor.r, classColor.g, classColor.b, classColor.r, classColor.g, classColor.b)
		elseif whatClass == "Tank" then
			tip:AddLine(select(1,UnitClass("player")).." "..INLINE_TANK_ICON.." "..TANK, classColor.r, classColor.g, classColor.b, true)
			--tip:AddDoubleLine(L["noobUI Specific Stats"], INLINE_TANK_ICON.." "..TANK.." "..select(1,UnitClass("player")), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, classColor.r, classColor.g, classColor.b)
			--tip:AddDoubleLine(YOUR_ROLE.." / "..CLASS, INLINE_TANK_ICON.." "..TANK.." "..select(1,UnitClass("player")), classColor.r, classColor.g, classColor.b, classColor.r, classColor.g, classColor.b)
		elseif whatClass == "Healer" then
			tip:AddLine(select(1,UnitClass("player")).." "..INLINE_HEALER_ICON.." "..HEALER, classColor.r, classColor.g, classColor.b, true)
			--tip:AddDoubleLine(L["noobUI Specific Stats"], INLINE_HEALER_ICON.." "..HEALER.." "..select(1,UnitClass("player")), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, classColor.r, classColor.g, classColor.b)
			--tip:AddDoubleLine(YOUR_ROLE.." / "..CLASS, INLINE_HEALER_ICON.." "..HEALER.." "..select(1,UnitClass("player")), classColor.r, classColor.g, classColor.b, classColor.r, classColor.g, classColor.b)
		end
	end
	
	tip:AddLine(" ")
	
	-- 1 = Tank
	if noobStats.whatRole() == 1 then
		-- Total Health
		tip:AddDoubleLine(format(STAT_FORMAT, HEALTH), statHealth)
		-- Stamina and what it gives
		tip:AddDoubleLine(format(STAT_FORMAT, SPELL_STAT3_NAME), statStamina)
		tip:AddLine(statStaminaGives, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
		
		tip:AddLine(" ")
		-- Armor and what it gives
		tip:AddDoubleLine(format(STAT_FORMAT, ARMOR), statArmor)
		tip:AddLine(format(DEFAULT_STATARMOR_TOOLTIP, statDamageReduction), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
		tip:AddLine(" ")
		
		-- Tank stat disabled to check for truth
		--tip:AddDoubleLine(format(STAT_FORMAT, L["Average Mitigation"]), statMitigationAverage)
		--tip:AddLine(" ")
		
		-- CTC and observation
		tip:AddDoubleLine(format(STAT_FORMAT, L["Combat Table Coverage"]), statCTC.." / 102.4%")
		tip:AddLine(statCTCIncludes, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
		tip:AddLine(" ")
		
		-- Avoidance, Dodge, Parry and Block
		tip:AddDoubleLine(format(STAT_FORMAT, L["Total Avoidance"]), statAvoidance.." ("..DODGE.." + "..PARRY..")")
		tip:AddDoubleLine(format(STAT_FORMAT, DODGE_CHANCE), statDodge, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		tip:AddDoubleLine(format(STAT_FORMAT, PARRY_CHANCE), statParry, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		tip:AddDoubleLine(format(STAT_FORMAT, BLOCK_CHANCE), statBlock, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		
	-- 2 = DPS Caster, 3 = Healer
	elseif noobStats.whatRole() == 2 or noobStats.whatRole() == 3 then
		-- Intelect and what it gives
		tip:AddDoubleLine(format(STAT_FORMAT, SPELL_STAT4_NAME), statIntelect)
		tip:AddLine(statIntelectGives, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
		-- Spirit and what it gives
		tip:AddDoubleLine(format(STAT_FORMAT, SPELL_STAT5_NAME), statSpirit)
		tip:AddLine(statSpiritGives, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
		tip:AddLine(" ")
		-- SpellPower
		tip:AddDoubleLine(format(STAT_FORMAT, STAT_SPELLPOWER), statHealPower)
		-- Mana Regen
		tip:AddDoubleLine(format(STAT_FORMAT, MANA_REGEN), statRegenOut)
		-- Manage Regen in Combat
		tip:AddDoubleLine(format(STAT_FORMAT, MANA_REGEN_COMBAT), statRegenIn)
		
	-- 4 = DPS Melee
	elseif noobStats.whatRole() == 4 then
		if unitClass == "WARRIOR" or unitClass == "PALADIN" or unitClass == "DEATHKNIGHT" then
			-- Strength and what it gives
			tip:AddDoubleLine(format(STAT_FORMAT, SPELL_STAT1_NAME), statStrength)
			tip:AddLine(statStrengthGives, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
		elseif unitClass == "ROGUE" or unitClass == "DRUID" or unitClass == "SHAMAN" then
			-- Agility and what it gives
			tip:AddDoubleLine(format(STAT_FORMAT, SPELL_STAT2_NAME), statAgility)
			tip:AddLine(statAgilityGives, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
		end
		-- Attack Power
		tip:AddDoubleLine(format(STAT_FORMAT, STAT_ATTACK_POWER), statAttackPower)
		tip:AddLine(statAttackPowerGives, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
		-- Expertise
		tip:AddDoubleLine(format(STAT_FORMAT, STAT_EXPERTISE), expertiseDisplay)
		tip:AddLine(format(CR_EXPERTISE_TOOLTIP, expertisePercentDisplay, GetCombatRating(CR_EXPERTISE), GetCombatRatingBonus(CR_EXPERTISE)), GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
		--
		tip:AddLine(" ")
		-- MainHand DPS
		tip:AddLine(INVTYPE_WEAPONMAINHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
		tip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", statMainSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		tip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), statDamageMin.." / "..statDamageMax, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		tip:AddDoubleLine(format(STAT_FORMAT, DAMAGE_PER_SECOND), statMainDPS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		--
		tip:AddLine(" ")
		-- Offhand DPS
		if (IsDualWielding()) then
			tip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
			tip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", statOffhandSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			tip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), statDamageMinOffhand.." / "..statDamageMaxOffhand, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			tip:AddDoubleLine(format(STAT_FORMAT, DAMAGE_PER_SECOND), statOffhandDPS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		end
	
	-- DPS Ranged
	elseif noobStats.whatRole() == 5 then
		tip:AddDoubleLine(SPELL_STAT2_NAME, statAgility)
	end
	
end

function noobGetSubStat(unit, statIndex)
	local context;
	local stat;
	local effectiveStat;
	local posBuff;
	local negBuff;
	stat, effectiveStat, posBuff, negBuff = UnitStat(unit, statIndex);
	
	if (unit == "player") then
		local _, unitClass = UnitClass("player");
		unitClass = strupper(unitClass);
		
		local whatever = _G["DEFAULT_STAT"..statIndex.."_TOOLTIP"]
		
		-- Strength
		if ( statIndex == 1 ) then
			local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
			context = format(whatever, attackPower);
		-- Agility
		elseif ( statIndex == 2 ) then
			local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
			if ( attackPower > 0 ) then
				context = format(STAT_TOOLTIP_BONUS_AP, attackPower) .. format(whatever, GetCritChanceFromAgility("player"));
			else
				context = format(whatever, GetCritChanceFromAgility("player"));
			end
		-- Stamina
		elseif ( statIndex == 3 ) then
			local baseStam = min(20, effectiveStat);
			local moreStam = effectiveStat - baseStam;
			context = format(whatever, (baseStam + (moreStam*UnitHPPerStamina("player")))*GetUnitMaxHealthModifier("player"));
		-- Intellect
		elseif ( statIndex == 4 ) then
			if ( UnitHasMana("player") ) then
				local baseInt = min(20, effectiveStat);
				local moreInt = effectiveStat - baseInt
				if (GetOverrideSpellPowerByAP() ~= nil) then
					context = format(STAT4_NOSPELLPOWER_TOOLTIP, baseInt + moreInt*MANA_PER_INTELLECT, GetSpellCritChanceFromIntellect("player"));
				else
					context = format(whatever, baseInt + moreInt*MANA_PER_INTELLECT, max(0, effectiveStat-10), GetSpellCritChanceFromIntellect("player"));
				end
			else
				context = STAT_USELESS_TOOLTIP;
			end
		-- Spirit
		elseif ( statIndex == 5 ) then
			-- All mana regen stats are displayed as mana/5 sec.
			if ( UnitHasMana("player") ) then
				local regen = GetUnitManaRegenRateFromSpirit("player");
				regen = floor( regen * 5.0 );
				context = format(MANA_REGEN_FROM_SPIRIT, regen);
			else
				context = STAT_USELESS_TOOLTIP;
			end
		end
	elseif (unit == "pet") then
		if ( statIndex == 1 ) then
			local attackPower = effectiveStat-20;
			context = attackPower;
		elseif ( statIndex == 2 ) then
			context = GetCritChanceFromAgility("pet");
		elseif ( statIndex == 3 ) then
			local expectedHealthGain = (((stat - posBuff - negBuff)-20)*10+20)*GetUnitHealthModifier("pet");
			local realHealthGain = ((effectiveStat-20)*10+20)*GetUnitHealthModifier("pet");
			local healthGain = (realHealthGain - expectedHealthGain)*GetUnitMaxHealthModifier("pet");
			context = healthGain;
		elseif ( statIndex == 4 ) then
			if ( UnitHasMana("pet") ) then
				local manaGain = ((effectiveStat-20)*15+20)*GetUnitPowerModifier("pet");
				context = format(manaGain, max(0, effectiveStat-10), GetSpellCritChanceFromIntellect("pet"));
			else
				context = nil;
			end
		elseif ( statIndex == 5 ) then
			context = "";
			if ( UnitHasMana("pet") ) then
				context = format(MANA_REGEN_FROM_SPIRIT, GetUnitManaRegenRateFromSpirit("pet"));
			end
		end
	end
	
	return context

end

local function noobClassRoles(class)
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
	if classType == "DEATHKNIGHT" then
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

function noobStats.whatRole()
	local unitClass = select(2, UnitClass("Player"))
	local checkRole = noobClassRoles(unitClass)
	local thisRole

	if checkRole == "Tank" then thisRole = 1 end
	if checkRole == "Healer" then thisRole = 2 end
	if checkRole == "DPS Caster" then thisRole = 3 end
	if checkRole == "DPS Melee" then thisRole = 4 end
	if checkRole == "DPS Ranged" then thisRole = 5 end
	
	return thisRole
end