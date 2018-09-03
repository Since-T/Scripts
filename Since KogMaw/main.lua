local orb = module.internal("orb");
local evade = module.internal("evade");
local pred = module.internal("pred");
local ts = module.internal('TS');
local SincePrediction = module.load('SinceKogMaw', 'SincePrediction')

local killStealActive = false;
local passiveTriggered = false;
local passiveTarget
local passivePosition
local passivePositionTime
local isChangingPermashow = false;
local activePredID = 1;

----------------
-- Spell data --
----------------

local spells = {};

spells.auto = {
	type = 'atk';
	slot = -1;
	doAP = false;
	doAD = true;
	minrange = 0;
	minrangeKS = 0;
}

spells.q = {
	delay = 0.25;
	width = 60;
	speed = 1600;
	boundingRadiusMod = 1;
	collision = { hero = true, minion = true };
  predcollision = true;
	range = 1175;
	UseRange = 1000;
	doAP = true;
	doAD = false;
	islinear = true;
  isaoe = false;
	type = 'q';
	slot = 0;
	minrange = 0;
	minrangeKS = 0;
}

spells.w = {
	type = 'w';
	slot = 2;
	doAP = true;
	doAD = false;
	minrange = 0;
	minrangeKS = 0;
}

spells.e = {
	delay = 0.25;
	width = 115;
	speed = 1350;
	boundingRadiusMod = 1;
	collision = { hero = false, minion = false };
  predcollision = true;
	range = 1280;
	UseRange = 1025;
	doAP = true;
	doAD = false;
	islinear = true;
  isaoe = true;
	type = 'e';
	slot = 2;
	minrange = 0;
	minrangeKS = 0;
}
--[[
spells.r = {
	delay = 0.6;
	radius = 100;
	width = 100;
	speed = 1800;
	boundingRadiusMod = 1;
	collision = { hero = false, minion = false };
	doAP = true;
	doAD = false;
	type = 'r';
	slot = 3;
}
]]
spells.r = {
	delay = 1.1;
	--delay = 1.4;
	radius = 80;
	width = 80;
	speed = math.huge;
	boundingRadiusMod = 1;
	collision = { hero = false, minion = false };
  predcollision = true;
	doAP = true;
	doAD = false;
	islinear = false;
  isaoe = true;
	type = 'r';
	slot = 3;
	minrange = 0;
	minrangeKS = 0;
}

spells.r.range = {
	min = 1200;
	max = 1800;
}
spells.r.UseRange = {
	min = 600;
	max = 1800;
}

-------------------
-- Menu creation --
-------------------

local menu = menu("SinceKogMaw", "Since KogMaw");

menu:menu("combo", "Combo")
	menu.combo:boolean("q", "Use Q", true)
	menu.combo:boolean("w", "Use W", true)
	menu.combo:boolean("e", "Use E", true)
	menu.combo:boolean("r", "Use R", true)
menu:menu("harass", "Harass")
	menu.harass:boolean("q", "Use Q", true)
	menu.harass:boolean("w", "Use W", true)
	menu.harass:boolean("e", "Use E", true)
	menu.harass:boolean("r", "Use R", true)
	menu.harass:slider("manaq", "Mana Q", 45, 0, 100, 1)
	menu.harass:slider("manaw", "Mana W", 80, 0, 100, 1)
	menu.harass:slider("manae", "Mana E", 65, 0, 100, 1)
	menu.harass:slider("manar", "Mana R", 85, 0, 100, 1)
	--[[
menu:menu("lasthit", "LastHit")
	menu.lasthit:boolean("q", "Use Q", true)
	menu.lasthit:boolean("w", "Use W", true)
	menu.lasthit:boolean("e", "Use E", true)
	menu.lasthit:slider("manaq", "Mana Q", 50, 0, 100, 1)
	menu.lasthit:slider("manaw", "Mana W", 65, 0, 100, 1)
	menu.lasthit:slider("manae", "Mana E", 30, 0, 100, 1)
menu:menu("laneclear", "LaneClear")
	menu.laneclear:boolean("q", "Use Q", true)
	menu.laneclear:boolean("w", "Use W", true)
	menu.laneclear:boolean("e", "Use E", true)
	menu.laneclear:slider("manaq", "Mana Q", 50, 0, 100, 1)
	menu.laneclear:slider("manaw", "Mana W", 65, 0, 100, 1)
	menu.laneclear:slider("manae", "Mana E", 30, 0, 100, 1)
	]]
menu:menu("killsteal", "Killsteal")
	menu.killsteal:boolean("q", "Use Q", true)
	menu.killsteal:boolean("w", "Use W", true)
	menu.killsteal:boolean("e", "Use E", true)
	menu.killsteal:boolean("r", "Use R", true)
menu:menu("r", "R Settings")
	menu.r:keybind("ult", "Manual R", "U", nil);
	menu.r:slider("MaxUltStackCombo", "Max stacks Combo", 5, 1, 10, 1)
	menu.r:slider("MaxUltStackHarass", "Max stacks Harass", 2, 1, 10, 1)
	menu.r:boolean("useRange", "In C/H only use out of AA range", false)
	menu.r:boolean("useRangeKillsteal", "In KS only use out of AA range", false)
menu:menu("draws", "Draw Settings")
	menu.draws:boolean("killable", "DMG on enemy", true)
	menu.draws:slider("dmgx", "DMG bar X", 75, 0, 500, 5)
	menu.draws:slider("dmgy", "DMG bar Y", 140, 0, 500, 5)
	menu.draws:slider("dmgScale", "DMG bar scale", 3, 1, 3, 1)
	menu.draws:boolean("permashow", "Permashow", true)
	menu.draws:slider("permashow_x", "Permashow X", 600, 0, graphics.width, 5)
	menu.draws:slider("permashow_y", "Permashow Y", 1000, 0, graphics.height, 5)
	menu.draws:slider("permashow_scale", "Permashow scale", 3, 1, 5, 1)
	menu.draws:boolean("r_range", "R range", true)
-- menu:menu("pred", "Prediction Settings")
-- 	menu.pred:dropdown("predUse", "Use prediction", 1, {"SincePrediction", "Hanbot pred"})
menu:menu("auto", "Auto Settings")
	menu.auto:boolean("ult", "Auto ult if HitChance >90%", true)
	menu.auto:boolean("gapE", "Gapcloser E (HitChance 99%)", true)
	menu.auto:boolean("gapR", "Gapcloser Ult (HitChance 99%)", true)
	menu.auto:boolean("passive", "Passive", true)
	--[[
menu:menu("predset", "Prediction Settings")
	menu.predset:menu("Q", "Q settings")
		menu.predset.Q:slider("Qdelay", "Q Delay / 100 (25 = 0.25)", 25, 1, 250, 1)
		menu.predset.Q:slider("Qspeed", "Q Speed", 1600, 100, 2500, 50)
		menu.predset.Q:slider("Qwidth", "Q Width", 60, 10, 250, 5)
	menu.predset:menu("E", "E settings")
		menu.predset.E:slider("Edelay", "E Delay / 100 (25 = 0.25)", 25, 1, 250, 1)
		menu.predset.E:slider("Espeed", "E Speed", 1200, 100, 2500, 50)
		menu.predset.E:slider("Ewidth", "E Width", 100, 10, 250, 5)
	menu.predset:menu("R", "R settings")
		menu.predset.R:slider("Rdelay", "R Delay / 100 (25 = 0.25)", 110, 1, 250, 1)
		menu.predset.R:slider("Rspeed", "R Speed (0 = max)", 0, 0, 2500, 50)
		menu.predset.R:slider("Rradius", "R Radius", 100, 10, 250, 5)
	menu.predset:button("reload", "Set the settings", "Set", AddOnReloadCallBack(function()
			spells.q.delay = menu.predset.Q.delay:get()
			spells.q.speed = menu.predset.Q.speed:get()
			spells.q.width = menu.predset.Q.width:get()

			spells.e.delay = menu.predset.E.delay:get()
			spells.e.speed = menu.predset.E.speed:get()
			spells.e.width = menu.predset.E.width:get()

			spells.r.delay = menu.predset.R.delay:get()
			spells.r.speed = menu.predset.R.speed:get()
			spells.r.width = menu.predset.R.radius:get() return true end));
			]]

ts.load_to_menu();


local delayedActions, delayedActionsExecuter = {}, nil
function DelayAction(func, delay, args) --delay in seconds
  if not delayedActionsExecuter then
    function delayedActionsExecuter()
      for t, funcs in pairs(delayedActions) do
        if (t <= os.clock()) then
          for i = 1, #funcs do
            local f = funcs[i]
            if f and f.func then
              f.func(unpack(f.args or {}))
            end
          end
          delayedActions[t] = nil
        end
      end
    end
    cb.add(cb.tick, delayedActionsExecuter)
  end
  local t = os.clock() + (delay or 0)
  if delayedActions[t] then
    delayedActions[t][#delayedActions[t] + 1] = {func = func, args = args}
  else
    delayedActions[t] = {{func = func, args = args}}
  end
end

-----------------------
-- Calculation funcs --
-----------------------

-- Q Damage calculation

local q_ratio = {80, 130, 180, 230, 280};
local function q_damage()
	local base = q_ratio[player:spellSlot(0).level] or 0;
	local apmod = player.flatMagicDamageMod * 0.5;
	return math.ceil(base + apmod);
end

local w_ratio = {3, 3.75, 4.5, 5.25, 6};
local function w_damage(source)
	local base = w_ratio[player:spellSlot(2).level] or 0;
	local apmod = mathf.round(player.flatMagicDamageMod / 100, 1);
	local pMath = (base + apmod) / 100
	return math.ceil(source.maxHealth * pMath);
end

-- E Damage calculation

local e_ratio = {60, 105, 150, 195, 240};
local function e_damage()
	local base = e_ratio[player:spellSlot(2).level] or 0;
	local apmod = player.flatMagicDamageMod * 0.5;
	return math.ceil(base + apmod);
end

-- R Damage calculation

local r_ratio = {100, 140, 180};
local function r_damage(healthhp)
	local base = r_ratio[player:spellSlot(3).level] or 0;
	local admod = player.flatPhysicalDamageMod * 0.65;
	local apmod = player.flatMagicDamageMod * 0.25;
	local resultDMG = (base + admod + apmod)
	if healthhp < 40 then
		resultDMG = resultDMG + resultDMG
	else
		local dmgMulti = (math.floor(((100 - healthhp) / 6)) * 5)
		dmgMulti = ((dmgMulti / 100) + 1)
		resultDMG = resultDMG * dmgMulti
	end
	return math.ceil(resultDMG);
end
local function Cast(spell, target, log)
  if not target then return end
  if not target.networkID then
    return false;
  elseif target and target.networkID then
	--Use SincePrediction;
		--[[
		if (activePredID == 1) then
	    local collision = spell.predcollision
	    local CastPosition, hitChance, Position  = nil, 0, nil
	  	islinear = true;
	    isaoe = false;
			print(spell.type)
			print(target)
			print(spell.delay)
			print(spell.width)
			print(spell.range)
			print(spell.speed)
			print(player)
			print(collision)
	    if spell.islinear then
	      if spell.isaoe then
	        CastPosition, hitChance, Position = SincePrediction.GetLineAOECastPosition(target, spell.delay, spell.width, spell.range, spell.speed, player, collision)
	      else
	        CastPosition, hitChance, Position = SincePrediction.GetLineCastPosition(target, spell.delay, spell.width, spell.range, spell.speed, player, collision)
	      end
	    else
	      if spell.isaoe then
	        CastPosition, hitChance, Position = SincePrediction.GetCircularAOECastPosition(target, spell.delay, spell.width, spell.range, spell.speed, player, collision)
	      else
	        CastPosition, hitChance, Position = SincePrediction.GetCircularCastPosition(target, spell.delay, spell.width, spell.range, spell.speed, player, collision)
	      end
	    end
	    if hitChance >= 2 then
		    player:castSpell("pos", spell.slot, vec3(CastPosition.x, CastPosition.y, CastPosition.z))
			  return true;
			end
	--Use SincePrediction;
		elseif (activePredID == 2) then
		]]
			local spred;
			if spell.islinear then
				spred = pred.linear.get_prediction(spell, target, player)
			else
				spred = pred.circular.get_prediction(spell, target, player)
			end
			if not spred then return end
			if not spell.collision.minion or not pred.collision.get_prediction(spell, spred, target) then
				player:castSpell("pos", spell.slot, vec3(spred.endPos.x, target.pos.y, spred.endPos.y))
			  return true;
			end
		--end
	end
  return false;
end

local function has_buff(target, name)
	for i = 0, target.buffManager.count - 1 do
  	local buff = target.buffManager:get(i)
  	if buff and buff.valid and buff.name == name then
  		if game.time <= buff.endTime then
      	return true, buff.startTime
  		end
  	end
	end
	return false, 0
end

local function getRStackCount()
	for i = 0, player.buffManager.count - 1 do
  	local buff = player.buffManager:get(i)
  	if buff and buff.valid and buff.name == 'kogmawlivingartillerycost' then
  		if game.time <= buff.endTime then
				return (1 + buff.stacks)
  		end
  	end
	end
	return 1
end

local function PhysicalReduction(target, damageSource)
  local damageSource = damageSource or player
  local armor = ((target.bonusArmor * damageSource.percentBonusArmorPenetration) + (target.armor - target.bonusArmor)) * damageSource.percentArmorPenetration
  local lethality = (damageSource.physicalLethality * .4) + ((damageSource.physicalLethality * .6) * (damageSource.levelRef / 18))
  return armor >= 0 and (100 / (100 + (armor - lethality))) or (2 - (100 / (100 - (armor - lethality))))
end

local function MagicReduction(target, damageSource)
	local damageSource = damageSource or player
	local magicResist = (target.spellBlock * damageSource.percentMagicPenetration) - damageSource.flatMagicPenetration
	return magicResist >= 0 and (100 / (100 + magicResist)) or (2 - (100 / (100 - magicResist)))
end

local function CalcAD_DMG(target, spelldamage, damageSource)
	local damageSource = damageSource or player
	if target then
		return (spelldamage * PhysicalReduction(target, damageSource))
	end
	return 0
end

local function CalcAP_DMG(target, spelldamage, damageSource)
	local damageSource = damageSource or player
	if target then
		return (spelldamage * MagicReduction(target, damageSource))
	end
	return 0
end

local function GetRealHealth(unit, shieldType)
	if (shieldType == 1) then
		return unit.health + unit.allShield --Health EveryShield
	elseif (shieldType == 2) then
		return unit.health + unit.physicalShield + unit.allShield --Health AD Shield
	elseif (shieldType == 3) then
		return unit.health + unit.magicalShield + unit.allShield --Health AP Shield
	else
		return unit.health --Only Health
	end
end

local function GetDmg(spell, myHero, target, log)
	if not target then return 0 end
	if not target.maxHealth then return 0 end
	local log = log or false
	local spelldmg = 0;
	if spell.type == 'q' then
		spelldmg = q_damage();
	elseif spell.type == 'e' then
		spelldmg = e_damage();
	elseif spell.type == 'r' then
		spelldmg = r_damage(100*target.health/target.maxHealth);
	elseif spell.type == 'w' then
		spelldmg = w_damage(target);
	elseif spell.type == 'atk' then
		spelldmg = orb.utility.get_damage(myHero, target);
	end
	if log then
		print('--- Start ---');
		print(spelldmg);
	end

	if not spelldmg then return 0 end
	local resultDamage = 0;
	if spell.doAD then
		resultDamage = CalcAD_DMG(target, spelldmg, myHero);
	elseif spell.doAP then
		resultDamage = CalcAP_DMG(target, spelldmg, myHero);
	else
		resultDamage = spelldmg;
	end

	if log then
		print(spelldmg);
		print(resultDamage);
		print(spell.doAD);
		print(spell.doAP);
		print('--- END ---');
	end
	return resultDamage
end

---------------------
-- Combo functions --
---------------------


-- Target functions

local function select_target(res, obj, dist)
	if dist > 1000 then return end

	res.obj = obj
	return true
end

function ValidTarget(object, distance, enemyTeam)
    local enemyTeam = (enemyTeam ~= false)
    return object ~= nil and (object.team ~= player.team) == enemyTeam and object.isVisible and not object.isDead and object.isTargetable and (distance == nil or SincePrediction.GetDistanceSqr(object) <= distance * distance)
end

function IsValidTarget(target, range, minRange)
	if not target then return end
	if target.type ~= TYPE_HERO then return end
	if not target.isVisible then return end
	if not target.isTargetable then return end
	local dist = player.pos:dist(target);
	if (dist <= range) and (dist > minRange) then
		return true
	else
		return false
	end
end

local function get_target()
	return ts.get_result(select_target).obj
end

-- W range calculation

local function w_range()
	local w_range = {630, 650, 670, 690, 710};
	range = (w_range[player:spellSlot(spells.w.slot).level]) or 0;
  return range
end

-- R range calculation

local function r_rangeUpdate()
	local r_range = {1200, 1500, 1800};
	range = r_range[player:spellSlot(spells.r.slot).level] or 0;
	spells.r.range = range; -- update r range
	spells.r.UseRange = (range * 0.95); -- update r Userange
  return true
end

local function r_GetMaxRange()
	local r_range = {1200, 1500, 1800};
	range = r_range[player:spellSlot(spells.r.slot).level] or 0;
  return range
end

local function manual_ult(target)
  if not menu.r.ult:get() then return end
  if player:spellSlot(spells.r.slot).state ~= 0 then return end
  local target = game.selectedTarget or target;
  if not target then return end
  local dist = player.pos:dist(target);
	r_rangeUpdate() -- update r range
	if not target.isDead then
	  if dist <= spells.r.range then
			--if (activePredID == 1) then
				-- local CastPosition, HitChance, Position = SincePrediction.GetCircularAOECastPosition(target, spells.r.delay, spells.r.radius, spells.r.range, spells.r.speed, player, false)
	      -- if (HitChance >= 2) then
		    --    player:castSpell("pos", spells.r.slot, vec3(CastPosition.x, CastPosition.y, CastPosition.z))
	      -- end
			--elseif (activePredID == 2) then
		    local rpred = pred.circular.get_prediction(spells.r, target)
		    if not rpred then return end
		    player:castSpell("pos", spells.r.slot, vec3(rpred.endPos.x, target.pos.y, rpred.endPos.y))
			--end
	  end
	end
end

function combolocal(target)
	--local target = game.selectedTarget or target;
	if not target then return end
	if target.type ~= TYPE_HERO then return end
	if menu.combo.q:get() and player:spellSlot(0).state == 0 and IsValidTarget(target, spells.q.UseRange, spells.q.minrange) then
		Cast(spells.q, target)
	end
	if menu.combo.w:get() and player:spellSlot(1).state == 0 and IsValidTarget(target, w_range(), 0) then
		player:castSpell("self", 1)
	end
	if menu.combo.e:get() and player:spellSlot(2).state == 0 and IsValidTarget(target, spells.e.UseRange, spells.e.minrange) then
		Cast(spells.e, target)
	end
	if menu.combo.r:get() and player:spellSlot(3).state == 0 and menu.r.MaxUltStackCombo:get() >= getRStackCount() and IsValidTarget(target, spells.r.UseRange, spells.r.minrange) then
		r_rangeUpdate() -- update r range
		Cast(spells.r, target)
	end
end

function Harass(target)
	--local target = game.selectedTarget or target;
	if not target then return end
	if target.type ~= TYPE_HERO then return end
	if menu.harass.q:get() and player:spellSlot(0).state == 0 and menu.harass.manaq:get() <= 100*player.mana/player.maxMana and IsValidTarget(target, spells.q.UseRange, spells.q.minrange) then
		Cast(spells.q, target, true)
	end
	if menu.harass.w:get() and player:spellSlot(1).state == 0 and menu.harass.manaw:get() <= 100*player.mana/player.maxMana and IsValidTarget(target, w_range(), spells.w.minrange) then
		player:castSpell("self", 1)
	end
	if menu.harass.e:get() and player:spellSlot(2).state == 0 and menu.harass.manae:get() <= 100*player.mana/player.maxMana and IsValidTarget(target, spells.e.UseRange, spells.e.minrange) then
		Cast(spells.e, target)
	end
	if menu.harass.r:get() and player:spellSlot(3).state == 0 and menu.r.MaxUltStackHarass:get() >= getRStackCount() and menu.harass.manar:get() <= 100*player.mana/player.maxMana and IsValidTarget(target, spells.r.UseRange, spells.r.minrange) then
		r_rangeUpdate() -- update r range
		Cast(spells.r, target)
	end
end

local function setKillstealAcitve(delay)
	killStealActive = true;
	DelayAction(function() killStealActive = false; end, delay+0.1)
end

function Killsteal()
	if killStealActive then return end
	r_rangeUpdate() -- update r range
  local enemies = objManager.enemies;
  for k = 0, objManager.enemies_n - 1 do
    local enemy = enemies[k];
		if enemy.isTargetable and enemy ~= nil and not enemy.isDead and enemy.isVisible then
			if player:spellSlot(0).state == 0 and GetRealHealth(enemy) < GetDmg(spells.q, player, enemy) and menu.killsteal.q:get()	and IsValidTarget(enemy, spells.q.UseRange, spells.q.minrangeKS) then
				setKillstealAcitve(spells.q.delay)
				Cast(spells.q, enemy)
			elseif player:spellSlot(2).state == 0 and GetRealHealth(enemy) < GetDmg(spells.e, player, enemy) and menu.killsteal.e:get() and IsValidTarget(enemy, spells.e.UseRange, spells.e.minrangeKS) then
				setKillstealAcitve(spells.e.delay)
				Cast(spells.e, enemy)
			elseif player:spellSlot(3).state == 0	and GetRealHealth(enemy) < GetDmg(spells.r, player, enemy) and menu.killsteal.r:get() and IsValidTarget(enemy, spells.r.UseRange, spells.r.minrangeKS) then
				setKillstealAcitve(spells.r.delay)
				Cast(spells.r, enemy)
			elseif player:spellSlot(0).state == 0 and player:spellSlot(2).state == 0 and GetRealHealth(enemy) < GetDmg(spells.q, player, enemy)+GetDmg(spells.e, player, enemy) and menu.killsteal.q:get() and menu.killsteal.e:get() and IsValidTarget(enemy, spells.q.UseRange, spells.q.minrangeKS) then
				setKillstealAcitve(spells.q.delay + spells.e.delay)
				Cast(spells.e, enemy)
				DelayAction(function() Cast(spells.q, enemy) end, spells.e.delay)
			elseif player:spellSlot(3).state == 0 and player:spellSlot(2).state == 0 and GetRealHealth(enemy) < GetDmg(spells.e, player, enemy)+GetDmg(spells.r, player, enemy) and menu.killsteal.e:get() and menu.killsteal.r:get() and IsValidTarget(enemy, spells.e.UseRange, spells.e.minrangeKS) then
				setKillstealAcitve(spells.r.delay + spells.e.delay)
				Cast(spells.e, enemy)
				DelayAction(function() Cast(spells.r, enemy) end, spells.e.delay)
			elseif player:spellSlot(0).state == 0 and player:spellSlot(3).state == 0 and GetRealHealth(enemy) < GetDmg(spells.q, player, enemy)+GetDmg(spells.r, player, enemy) and menu.killsteal.q:get() and menu.killsteal.r:get() and IsValidTarget(enemy, spells.q.UseRange, spells.q.minrangeKS) then
				setKillstealAcitve(spells.r.delay + spells.q.delay)
				Cast(spells.q, enemy)
				DelayAction(function() Cast(spells.r, enemy) end, spells.q.delay)
			elseif player:spellSlot(0).state == 0 and player:spellSlot(3).state == 0 and player:spellSlot(2).state == 0 and GetRealHealth(enemy) < GetDmg(spells.q, player, enemy)+GetDmg(spells.e, player, enemy)+GetDmg(spells.r, player, enemy) and menu.killsteal.q:get() and menu.killsteal.e:get() and menu.killsteal.r:get() and IsValidTarget(enemy, spells.q.UseRange, spells.q.minrangeKS) then
				setKillstealAcitve(spells.r.delay + spells.e.delay + spells.q.delay)
				Cast(spells.e, enemy)
				DelayAction(function() Cast(spells.q, enemy) DelayAction(function() Cast(spells.r, enemy) end, spells.q.delay) end, spells.e.delay)
			end
		end
	end
end

local function CheckDashes()
  local enemies = objManager.enemies;
  for i = 0, objManager.enemies_n - 1 do
    local enemy = enemies[i];
		if menu.auto.gapE:get() then
			if not enemy.dead and ValidTarget(enemy) and SincePrediction.GetDistance(enemy) < spells.e.range then
				local IsDashing, CanHit, Position = SincePrediction.IsDashing(enemy, spells.e.delay, spells.e.width, spells.e.speed, player)
				if IsDashing and CanHit and SincePrediction.GetDistance(Position) < spells.e.range and player:spellSlot(2).state == 0 then
	  	    player:castSpell("pos", spells.e.slot, vec3(Position.x, Position.y, Position.z))
				end
			end
		end
		if menu.auto.gapR:get() then
			r_rangeUpdate()
			if not enemy.dead and ValidTarget(enemy) and SincePrediction.GetDistance(enemy) < spells.r.range then
				local IsDashing, CanHit, Position = SincePrediction.IsDashing(enemy, spells.r.delay, spells.r.width, spells.r.speed, player)
				if IsDashing and CanHit and SincePrediction.GetDistance(Position) < spells.r.range and player:spellSlot(3).state == 0 then
	  	    player:castSpell("pos", spells.r.slot, vec3(Position.x, Position.y, Position.z))
				end
			end
		end
  end
end

local function AutoUlt()
	if player:spellSlot(3).state == 0 then
	  local enemies = objManager.enemies;
	  for i = 0, objManager.enemies_n - 1 do
	    local enemy = enemies[i];
			 if ValidTarget(enemy, 1800) and not enemy.isDead and SincePrediction.GetDistance(enemy) < 1800 then
	 			r_rangeUpdate()
				local CastPosition, HitChance, Pos = SincePrediction.GetCircularCastPosition(enemy, spells.r.delay, spells.r.width, spells.r.range, spells.r.speed, player, false)
				if HitChance > 2 and SincePrediction.GetDistance(CastPosition) < spells.r.range then
	  	    player:castSpell("pos", spells.r.slot, vec3(CastPosition.x, CastPosition.y, CastPosition.z))
				end
			 end
	  end
	end
end

local DisabledMovement = false;
local function doPassive(target)
	local lisVisible = false
	if passiveTarget == nil then
		passiveTarget = game.selectedTarget or target
		if not passiveTarget then return end
		lisVisible = passiveTarget.isVisible
	end
	if target and (passiveTarget ~= target) and (passiveTarget ~= game.selectedTarget) then
		passiveTarget = game.selectedTarget or target
		lisVisible = passiveTarget.isVisible
	end
	lisVisible = passiveTarget.isVisible
	if has_buff(player, 'KogMawIcathianSurprise') then
		if not DisabledMovement then
			orb.core.set_pause_move(math.huge)
			orb.core.set_pause_attack(math.huge)
			evade.core.set_pause(math.huge)
			DisabledMovement = true;
			passivePositionTime = 0
		end
		if lisVisible then
			if (game.time - passivePositionTime) > 1 then
				--if activePredID == 1 then
					--passivePosition = SincePrediction.CalculateTargetPosition(passiveTarget, 1.1, 10, 3000, player, "line")
				--else
					passivePosition = pred.core.get_pos_after_time(passiveTarget, 0.1)
				--end
				passivePositionTime = game.time
			end

			player:move(passiveTarget.pos);
		else
			if not passivePosition then return end
			player:move(passivePosition);
		end
	else
		if DisabledMovement then
			orb.core.set_pause_move(0)
			orb.core.set_pause_attack(0)
			evade.core.set_pause(0)
			DisabledMovement = false;
		end
	end
end

local function doTick()
	--if activePredID == 1 then
		if menu.auto.ult:get() then
		  AutoUlt();
		end

		if menu.auto.gapE:get() or menu.auto.gapR:get() then
		  CheckDashes();
		end
	--end

	local target = get_target();
	if player.health < 2 then
		if menu.auto.passive:get() then
			doPassive(target)
		end
	end

	manual_ult(target);
	Killsteal(target)
	if keyboard.isKeyDown(keyboard.stringToKeyCode('C')) then
		Harass(target)
	end
	if orb.combat.is_active() then
		combolocal(target)
	end
end
-----------
-- Hooks --
-----------

-- Draw hook
local function ondraw()
	-- if (activePredID ~= 1) then
	-- 	if menu.auto.ult:get() or menu.auto.gapE:get() or menu.auto.gapR:get() then
	-- 		graphics.draw_text_2D("Auto ULT and Gapcloser only work with SincePrediction", 32, (graphics.width/2) - (graphics.width * 0.2), (graphics.height/2), graphics.argb(255,0,255,0))
	-- 		graphics.draw_text_2D("Please use SincePrediction or disable this features", 32, (graphics.width/2) - (graphics.width * 0.2), (graphics.height/2) + 25, graphics.argb(255,0,255,0))
	-- 	end
	-- end

		local permScale = menu.draws.permashow_scale:get()
		local permaX, permaY = menu.draws.permashow_x:get(), menu.draws.permashow_y:get()
		local textScale = 28

		if permScale == 4 then
			textScale = textScale - 4
		elseif permScale == 3 then
			textScale = textScale - 8
		elseif permScale == 2 then
			textScale = textScale - 12
		elseif permScale == 1 then
			textScale = textScale - 16
		end
			if menu.isopen() then
				if permScale == 5 then
					graphics.draw_rectangle_2D(permaX, permaY, 400, 150, 2, graphics.argb(255,255,255,255))
				elseif permScale == 4 then
					graphics.draw_rectangle_2D(permaX, permaY, 400, 150, 2, graphics.argb(255,255,255,255))
				elseif permScale == 3 then
					graphics.draw_rectangle_2D(permaX, permaY, 400, 150, 2, graphics.argb(255,255,255,255))
				elseif permScale == 2 then
					graphics.draw_rectangle_2D(permaX, permaY, 400, 150, 2, graphics.argb(255,255,255,255))
				elseif permScale == 1 then
					graphics.draw_rectangle_2D(permaX, permaY, 400, 150, 2, graphics.argb(255,255,255,255))
				end
			end
    --if tickTable[game.selectedTarget.networkID] then
      --graphics.draw_circle(tickTable[game.selectedTarget.networkID][#tickTable[game.selectedTarget.networkID]].endPos, 50, 2, graphics.argb(255, 192, 57, 43), 70)
    --end
  --graphics.draw_circle(vec3((player.pos.x + player.path.serverVelocity.x), (player.pos.y + player.path.serverVelocity.y), (player.pos.z + player.path.serverVelocity.z)), 50, 2, graphics.argb(255, 192, 57, 43), 70)
  --graphics.draw_circle(vec3(player.path.serverVelocity), 50, 2, graphics.argb(255, 192, 57, 43), 70)
  if menu.draws.killable:get() then
		local tmpdmgScale = menu.draws.dmgScale:get()
		local enemies = objManager.enemies;
		for k = 0, objManager.enemies_n - 1 do
			local enemy = enemies[k];
			if enemy.isOnScreen and not enemy.isDead and enemy.isVisible then
				local enemypos = graphics.world_to_screen(enemy.pos);
				local qDMG = 0
				local eDMG = 0
				local rDMG = 0
				if player:spellSlot(spells.q.slot).state == 0 then
					qDMG = GetDmg(spells.q, player, enemy)
				end
				if player:spellSlot(spells.e.slot).state == 0 then
					eDMG = GetDmg(spells.e, player, enemy)
				end
				if player:spellSlot(spells.r.slot).state == 0 then
					rDMG = GetDmg(spells.r, player, enemy)
				end
				local wDMG = GetDmg(spells.w, player, enemy) + GetDmg(spells.auto, player, enemy)
				--local enemyHealth = GetRealHealth(enemy)
				local enemyHealthPercentMath = ((100*enemy.health/enemy.maxHealth) / 100)
				local dmgx = menu.draws.dmgx:get();
				local dmgy = menu.draws.dmgy:get();
				local rectangleWidth, rectangleHeight, textSize = 150, 25, 16

				if tmpdmgScale == 2 then
					rectangleWidth = 120
					rectangleHeight = 20
					textSize = textSize - 2
				elseif tmpdmgScale == 1 then
					rectangleWidth = 90
					rectangleHeight = 15
					textSize = textSize - 2
				end

				dmgy = dmgy - 250
				if (qDMG + eDMG + rDMG + wDMG) < enemy.health then
					graphics.draw_rectangle_2D(enemypos.x-dmgx, enemypos.y+dmgy, rectangleWidth, rectangleHeight, 2, graphics.argb(255,255,255,255))
				else
					graphics.draw_rectangle_2D(enemypos.x-dmgx, enemypos.y+dmgy, rectangleWidth, rectangleHeight, 5, graphics.argb(255,0,255,0))
					if tmpdmgScale == 3 then
						graphics.draw_text_2D("KILLABLE", 24, enemypos.x-(dmgx), enemypos.y+dmgy+40, graphics.argb(255,0,255,0))
					elseif tmpdmgScale == 2 then
						graphics.draw_text_2D("KILLABLE", 20, enemypos.x-(dmgx), enemypos.y+dmgy+40, graphics.argb(255,0,255,0))
					else
						graphics.draw_text_2D("KILLABLE", 16, enemypos.x-(dmgx), enemypos.y+dmgy+40, graphics.argb(255,0,255,0))
					end
				end
				local healthWidth = (rectangleWidth * enemyHealthPercentMath)
				local startPosition = enemypos.x-dmgx
				if tmpdmgScale == 3 then
					dmgy = dmgy + 12.5
				elseif tmpdmgScale == 2 then
					dmgy = dmgy + 10
				elseif tmpdmgScale == 1 then
					dmgy = dmgy + 7.5
				end
				graphics.draw_line_2D(startPosition, enemypos.y+dmgy, (startPosition)+healthWidth, enemypos.y+dmgy, rectangleHeight, graphics.argb(200,255,0,0))
				if qDMG > 0 then
					local qDMGPercentMath = ((100*qDMG/enemy.maxHealth) / 100)
					graphics.draw_line_2D(startPosition, enemypos.y+dmgy, (startPosition)+(rectangleWidth * qDMGPercentMath), enemypos.y+dmgy, rectangleHeight, graphics.argb(150,100,225,255))
					graphics.draw_text_2D("Q", textSize, (startPosition)+(((rectangleWidth*qDMGPercentMath)/2)-2), enemypos.y+dmgy, graphics.argb(255,255,255,255))
					startPosition = startPosition + (rectangleWidth * qDMGPercentMath)
				end
				if wDMG > 0 then
					local wDMGPercentMath = ((100*wDMG/enemy.maxHealth) / 100)
					graphics.draw_line_2D(startPosition, enemypos.y+dmgy, (startPosition)+(rectangleWidth * wDMGPercentMath), enemypos.y+dmgy, rectangleHeight, graphics.argb(150,50, 150, 0))
					graphics.draw_text_2D("W", textSize, (startPosition)+(((rectangleWidth*wDMGPercentMath)/2)-2), enemypos.y+dmgy, graphics.argb(255,255,255,255))
					startPosition = startPosition + (rectangleWidth * wDMGPercentMath)
				end
				if eDMG > 0 then
					local eDMGPercentMath = ((100*eDMG/enemy.maxHealth) / 100)
					graphics.draw_line_2D(startPosition, enemypos.y+dmgy, (startPosition)+(rectangleWidth * eDMGPercentMath), enemypos.y+dmgy, rectangleHeight, graphics.argb(150,25, 100, 255))
					graphics.draw_text_2D("E", textSize, (startPosition)+(((rectangleWidth*eDMGPercentMath)/2)-2), enemypos.y+dmgy, graphics.argb(255,255,255,255))
					startPosition = startPosition + (rectangleWidth * eDMGPercentMath)
				end
				if rDMG > 0 then
					local rDMGPercentMath = ((100*rDMG/enemy.maxHealth) / 100)
					graphics.draw_line_2D(startPosition, enemypos.y+dmgy, (startPosition)+(rectangleWidth * rDMGPercentMath), enemypos.y+dmgy, rectangleHeight, graphics.argb(150,0, 20, 175))
					graphics.draw_text_2D("R", textSize, (startPosition)+(((rectangleWidth*rDMGPercentMath)/2)-2), enemypos.y+dmgy, graphics.argb(255,255,255,255))
					startPosition = startPosition + (rectangleWidth * rDMGPercentMath)
				end
			end
		end
	end

	if menu.draws.permashow:get() then
		local StackCount = getRStackCount();
		local textHeight = 25
		local textWidth = 250

		if permScale == 4 then
			textWidth = textWidth - 15
		elseif permScale == 3 then
			textWidth = textWidth - 65
		elseif permScale == 2 then
			textWidth = textWidth - 115
		elseif permScale == 1 then
			textWidth = textWidth - 150
		end

		graphics.draw_text_2D("StackCounter    :", textScale, permaX + 10, permaY + textHeight, graphics.argb(255,255,255,255))
		graphics.draw_text_2D(tostring(StackCount), textScale, permaX + textWidth, permaY + textHeight, graphics.argb(255,255,255,0))
		textHeight = textHeight + 10 + (5 * permScale)
		graphics.draw_text_2D("Auto Ult Harras :", textScale, permaX + 10, permaY + textHeight, graphics.argb(255,255,255,255))
		if player:spellSlot(3).state == 0 and menu.r.MaxUltStackHarass:get() >= StackCount and menu.harass.manar:get() <= 100*player.mana/player.maxMana then
			graphics.draw_text_2D("ON", textScale, permaX + textWidth, permaY + textHeight, graphics.argb(255,0,255,0))
		else
			graphics.draw_text_2D("OFF", textScale, permaX + textWidth, permaY + textHeight, graphics.argb(255,255,0,0))
		end
		textHeight = textHeight + 10 + (5 * permScale)
		graphics.draw_text_2D("Auto Ult Combo  :", textScale, permaX + 10, permaY + textHeight, graphics.argb(255,255,255,255))
		if player:spellSlot(3).state == 0 and menu.r.MaxUltStackCombo:get() >= StackCount then
			graphics.draw_text_2D("ON", textScale, permaX + textWidth, permaY + textHeight, graphics.argb(255,0,255,0))
		else
			graphics.draw_text_2D("OFF", textScale, permaX + textWidth, permaY + textHeight, graphics.argb(255,255,0,0))
		end
	end

  if menu.draws.r_range:get() then
		local pos = graphics.world_to_screen(player.pos);
		if not player.isOnScreen then return end
		graphics.draw_circle(player.pos, r_GetMaxRange(), 2, graphics.argb(255, 192, 57, 43), 70)
	end

	--draw calculated W range
	--graphics.draw_circle(player.pos, w_range(), 2, graphics.argb(255, 192, 57, 43), 70)
end

-- Tick hook
local function ontick()
	if menu.r.useRange:get() then
		spells.r.minrange = player.attackRange
	else
		spells.r.minrange = 0
	end

	if menu.r.useRangeKillsteal:get() then
		spells.r.minrangeKS = player.attackRange
	else
		spells.r.minrangeKS = 0
	end
	doTick();
	--SincePrediction.Tick()
	-- if menu.pred.predUse:get() ~= activePredID then
	-- 	activePredID = menu.pred.predUse:get()
	-- end

	if isChangingPermashow then
		local tmpmousePos = graphics.world_to_screen(game.mousePos)
		menu.draws.permashow_x:set('value', mathf.round(mathf.round(tmpmousePos.x, -1), 0))
		menu.draws.permashow_y:set('value', mathf.round(mathf.round(tmpmousePos.y, -1), 0))
	end
end


local function onKeyDown(key)
	if menu.isopen() then
		if keyboard.keyCodeToString(key) == 'LMB' then
			local permaX, permaY = menu.draws.permashow_x:get(), menu.draws.permashow_y:get()
			local tmpmousePos = graphics.world_to_screen(game.mousePos)
			if ((tmpmousePos.x > permaX) and (tmpmousePos.x < (permaX + 400))) and ((tmpmousePos.y > permaY) and (tmpmousePos.y < (permaY + 150))) then
				menu.draws.permashow_x:set('value', mathf.round(mathf.round(tmpmousePos.x, -1), 0))
				menu.draws.permashow_y:set('value', mathf.round(mathf.round(tmpmousePos.y, -1), 0))
				isChangingPermashow = true
			end
		end
	end
end

local function onKeyUp(key)
	if menu.isopen() then
		if keyboard.keyCodeToString(key) == 'LMB' then
			if isChangingPermashow then
				isChangingPermashow = false
			end
		end
	end
end

SincePrediction.__init()
cb.add(cb.draw, ondraw)
orb.combat.register_f_pre_tick(ontick)
cb.add(cb.keydown, onKeyDown)
cb.add(cb.keyup, onKeyUp)
