local orb = module.internal("orb");
local evade = module.internal("evade");
local pred = module.internal("pred");
local ts = module.internal('TS');



killStealActive = false;
passiveTriggered = false;

----------------
-- Spell data --
----------------

local spells = {};

spells.auto = {
	type = 'atk';
	slot = -1;
	doAP = false;
	doAD = true;
}

spells.q = {
	delay = 0.25;
	width = 60;
	speed = 1600;
	boundingRadiusMod = 1;
	collision = { hero = true, minion = true };
	range = 1175;
	UseRange = 1000;
	doAP = true;
	doAD = false;
	islinear = true;
	type = 'q';
	slot = 0;
}

spells.w = {
	type = 'w';
	slot = 2;
	doAP = true;
	doAD = false;
}

spells.e = {
	delay = 0.25;
	width = 115;
	speed = 1350;
	boundingRadiusMod = 1;
	collision = { hero = false, minion = false };
	range = 1280;
	UseRange = 1025;
	doAP = true;
	doAD = false;
	islinear = true;
	type = 'e';
	slot = 2;
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
	delay = 1.0;
	radius = 100;
	width = 200;
	speed = math.huge;
	boundingRadiusMod = 1;
	collision = { hero = false, minion = false };
	doAP = true;
	doAD = false;
	islinear = false;
	type = 'r';
	slot = 3;
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

local menu = menu("kogmaw", "Since KogMaw");

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
--menu:menu("passive", "Passive Settings");
--	menu.passive:boolean("auto", "Auto move", true)
menu:menu("draws", "Draw Settings")
	menu.draws:boolean("killable", "DMG on enemy", true)
	menu.draws:slider("dmgx", "DMG Bar X", 75, 0, 500, 5)
	menu.draws:slider("dmgy", "DMG Bar Y", 140, 0, 500, 5)
	menu.draws:boolean("permashow", "Permashow", true)
	menu.draws:boolean("r_range", "R range", true)
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
		local spred;
		if spell.islinear then
			spred = pred.linear.get_prediction(spell, target, player)
		else
			spred = pred.circular.get_prediction(spell, target, player)
		end
		if not spred then return end
		if not spell.collision.minion or not pred.collision.get_prediction(spell, spred, target) then
			player:castSpell("pos", spell.slot, vec3(spred.endPos.x, target.pos.y, spred.endPos.y))
		end
  end
  return false;
end

local function GetClosestMinion(pos)
  local minionTarget = nil
  for i, minion in pairs(objManager.minions) do
    if minion and minion.isVisible and not minion.isDead and minion.isTargetable then
      if minionTarget == nil then
        minionTarget = minion
      elseif GetDistanceSqr(minionTarget,pos) > GetDistanceSqr(minion,pos) then
        minionTarget = minion
      end
    end
  end
  return minionTarget
end

local function GetDistanceSqr(p1, p2)
  if not p1 then return math.huge end
  p2 = p2 or player
  local dx = p1.x - p2.x
  local dz = (p1.z or p1.y) - (p2.z or p2.y)
  return dx*dx + dz*dz
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
	if shieldType == 1 then
		return unit.health + unit.allShield --Health EveryShield
	elseif shieldType == 2 then
		return unit.health + unit.physicalShield + unit.allShield --Health AD Shield
	elseif shieldType == 3 then
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

function IsValidTarget(target, range)
	if not target then return end
	if not target == TYPE_HERO then return end
	if not target.isVisible then return end
	if not target.isTargetable then return end
	local dist = player.pos:dist(target);
	if dist <= range then
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
	range = (player.attackRange + w_range[player:spellSlot(spells.w.slot).level]) or 0;
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
  local dist = player.pos2D:dist(pred.core.get_pos_after_time(target, spells.r.delay));
	r_rangeUpdate() -- update r range
	if not target.isDead then
	  if dist <= spells.r.range then
	    local rpred = pred.circular.get_prediction(spells.r, target)
	    if not rpred then print('no_rpred') return end
	    player:castSpell("pos", spells.r.slot, vec3(rpred.endPos.x, target.pos.y, rpred.endPos.y))
	  end
	end
end

function combolocal(target)
	--local target = game.selectedTarget or target;
	if not target then return end
	if not target == TYPE_HERO then return end
	if menu.combo.q:get() and player:spellSlot(0).state == 0 and IsValidTarget(target, spells.q.UseRange) then
		Cast(spells.q, target)
	end
	if menu.combo.w:get() and player:spellSlot(1).state == 0 and IsValidTarget(target, w_range()) then
		player:castSpell("self", 1)
	end
	if menu.combo.e:get() and player:spellSlot(2).state == 0 and IsValidTarget(target, spells.e.UseRange) then
		Cast(spells.e, target)
	end
	if menu.combo.r:get() and player:spellSlot(3).state == 0 and menu.r.MaxUltStackCombo:get() >= getRStackCount() and IsValidTarget(target, spells.r.UseRange) then
		r_rangeUpdate() -- update r range
		Cast(spells.r, target)
	end
end

function Harass(target)
	--local target = game.selectedTarget or target;
	if not target then return end
	if not target == TYPE_HERO then return end
	if menu.harass.q:get() and player:spellSlot(0).state == 0 and menu.harass.manaq:get() <= 100*player.mana/player.maxMana and IsValidTarget(target, spells.q.UseRange) then
		Cast(spells.q, target, true)
	end
	if menu.harass.w:get() and player:spellSlot(1).state == 0 and menu.harass.manaw:get() <= 100*player.mana/player.maxMana and IsValidTarget(target, w_range()) then
		player:castSpell("self", 1)
	end
	if menu.harass.e:get() and player:spellSlot(2).state == 0 and menu.harass.manae:get() <= 100*player.mana/player.maxMana and IsValidTarget(target, spells.e.UseRange) then
		Cast(spells.e, target)
	end
	if menu.harass.r:get() and player:spellSlot(3).state == 0 and menu.r.MaxUltStackHarass:get() >= getRStackCount() and menu.harass.manar:get() <= 100*player.mana/player.maxMana and IsValidTarget(target, spells.r.UseRange) then
		r_rangeUpdate() -- update r range
		Cast(spells.r, target)
	end
end

local function setKillstealAcitve(delay)
	killStealActive = false;
	--DelayAction(function() killStealActive = false; end, delay+0.1)
end

function Killsteal()
	if killStealActive then return end
	r_rangeUpdate() -- update r range
  local enemies = objManager.enemies;
  for k = 0, objManager.enemies_n - 1 do
    local enemy = enemies[k];
		if enemy.isTargetable and enemy ~= nil and not enemy.isDead and enemy.isVisible then
			if player:spellSlot(0).state == 0 and GetRealHealth(enemy) < GetDmg(spells.q, player, enemy) and menu.killsteal.q:get()	and IsValidTarget(enemy, spells.q.UseRange) then
				setKillstealAcitve(spells.q.delay)
				Cast(spells.q, enemy)
			elseif player:spellSlot(2).state == 0 and GetRealHealth(enemy) < GetDmg(spells.e, player, enemy) and menu.killsteal.e:get() and IsValidTarget(enemy, spells.e.UseRange) then
				setKillstealAcitve(spells.e.delay)
				Cast(spells.e, enemy)
			elseif player:spellSlot(3).state == 0	and GetRealHealth(enemy) < GetDmg(spells.r, player, enemy) and menu.killsteal.r:get() and IsValidTarget(enemy, spells.r.UseRange) then
				setKillstealAcitve(spells.r.delay)
				Cast(spells.r, enemy)
			elseif player:spellSlot(0).state == 0 and player:spellSlot(2).state == 0 and GetRealHealth(enemy) < GetDmg(spells.q, player, enemy)+GetDmg(spells.e, player, enemy) and menu.killsteal.q:get() and menu.killsteal.e:get() and IsValidTarget(enemy, spells.q.UseRange) then
				setKillstealAcitve(spells.q.delay + spells.e.delay)
				Cast(spells.e, enemy)
				DelayAction(function() Cast(spells.q, enemy) end, spells.e.delay)
			elseif player:spellSlot(3).state == 0 and player:spellSlot(2).state == 0 and GetRealHealth(enemy) < GetDmg(spells.e, player, enemy)+GetDmg(spells.r, player, enemy) and menu.killsteal.e:get() and menu.killsteal.r:get() and IsValidTarget(enemy, spells.e.UseRange) then
				setKillstealAcitve(spells.r.delay + spells.e.delay)
				Cast(spells.e, enemy)
				DelayAction(function() Cast(spells.r, enemy) end, spells.e.delay)
			elseif player:spellSlot(0).state == 0 and player:spellSlot(3).state == 0 and GetRealHealth(enemy) < GetDmg(spells.q, player, enemy)+GetDmg(spells.r, player, enemy) and menu.killsteal.q:get() and menu.killsteal.r:get() and IsValidTarget(enemy, spells.q.UseRange) then
				setKillstealAcitve(spells.r.delay + spells.q.delay)
				Cast(spells.q, enemy)
				DelayAction(function() Cast(spells.r, enemy) end, spells.q.delay)
			elseif player:spellSlot(0).state == 0 and player:spellSlot(3).state == 0 and player:spellSlot(2).state == 0 and GetRealHealth(enemy) < GetDmg(spells.q, player, enemy)+GetDmg(spells.e, player, enemy)+GetDmg(spells.r, player, enemy) and menu.killsteal.q:get() and menu.killsteal.e:get() and menu.killsteal.r:get() and IsValidTarget(enemy, spells.q.UseRange) then
				setKillstealAcitve(spells.r.delay + spells.e.delay + spells.q.delay)
				Cast(spells.e, enemy)
				DelayAction(function() Cast(spells.q, enemy) DelayAction(function() Cast(spells.r, enemy) end, spells.q.delay) end, spells.e.delay)
			end
		end
	end
end

local DisabledMovement = false;
local function doPassive(target)
	local target = game.selectedTarget or target
	if has_buff(player, 'KogMawIcathianSurprise') then
		if not DisabledMovement then
			orb.core.set_pause_move(math.huge)
			orb.core.set_pause_attack(math.huge)
			evade.core.set_pause(math.huge)
			DisabledMovement = true;
		end
		player:move(pred.core.get_pos_after_time(target, 0.1));
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
	local target = get_target();
	--[[
	if player.health < 2 then
		if menu.passive.auto:get() then
			doPassive(target)
		end
	end
	]]

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
  if menu.draws.killable:get() then
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
				dmgy = dmgy - 250
				if (qDMG + eDMG + rDMG + wDMG) < enemy.health then
					graphics.draw_rectangle_2D(enemypos.x-dmgx, enemypos.y+dmgy, 150, 25, 2, graphics.argb(255,255,255,255))
				else
					graphics.draw_rectangle_2D(enemypos.x-dmgx, enemypos.y+dmgy, 150, 25, 5, graphics.argb(255,0,255,0))
					graphics.draw_text_2D("KILLABLE", 24, enemypos.x-60, enemypos.y-60, graphics.argb(255,0,255,0))
				end
				local healthWidth = (150 * enemyHealthPercentMath)
				local startPosition = enemypos.x-dmgx
				graphics.draw_line_2D(startPosition, enemypos.y+dmgy+12.5, (startPosition)+healthWidth, enemypos.y+dmgy+12.5, 25, graphics.argb(200,255,0,0))
				if qDMG > 0 then
					local qDMGPercentMath = ((100*qDMG/enemy.maxHealth) / 100)
					graphics.draw_line_2D(startPosition, enemypos.y+dmgy+12.5, (startPosition)+(150 * qDMGPercentMath), enemypos.y+dmgy+12.5, 25, graphics.argb(150,100,225,255))
					graphics.draw_text_2D("Q", 16, (startPosition)+(((150*qDMGPercentMath)/2)-2), enemypos.y+dmgy+12.5, graphics.argb(255,255,255,255))
					startPosition = startPosition + (150 * qDMGPercentMath)
				end
				if wDMG > 0 then
					local wDMGPercentMath = ((100*wDMG/enemy.maxHealth) / 100)
					graphics.draw_line_2D(startPosition, enemypos.y+dmgy+12.5, (startPosition)+(150 * wDMGPercentMath), enemypos.y+dmgy+12.5, 25, graphics.argb(150,50, 150, 0))
					graphics.draw_text_2D("W", 16, (startPosition)+(((150*wDMGPercentMath)/2)-2), enemypos.y+dmgy+12.5, graphics.argb(255,255,255,255))
					startPosition = startPosition + (150 * wDMGPercentMath)
				end
				if eDMG > 0 then
					local eDMGPercentMath = ((100*eDMG/enemy.maxHealth) / 100)
					graphics.draw_line_2D(startPosition, enemypos.y+dmgy+12.5, (startPosition)+(150 * eDMGPercentMath), enemypos.y+dmgy+12.5, 25, graphics.argb(150,25, 100, 255))
					graphics.draw_text_2D("E", 16, (startPosition)+(((150*eDMGPercentMath)/2)-2), enemypos.y+dmgy+12.5, graphics.argb(255,255,255,255))
					startPosition = startPosition + (150 * eDMGPercentMath)
				end
				if rDMG > 0 then
					local rDMGPercentMath = ((100*rDMG/enemy.maxHealth) / 100)
					graphics.draw_line_2D(startPosition, enemypos.y+dmgy+12.5, (startPosition)+(150 * rDMGPercentMath), enemypos.y+dmgy+12.5, 25, graphics.argb(150,0, 20, 175))
					graphics.draw_text_2D("R", 16, (startPosition)+(((150*rDMGPercentMath)/2)-2), enemypos.y+dmgy+12.5, graphics.argb(255,255,255,255))
					startPosition = startPosition + (150 * rDMGPercentMath)
				end
			end
		end
	end

	if menu.draws.permashow:get() then
		local StackCount = getRStackCount();
		-- graphics.draw_text_2D("A DMG :"..GetDmg(spells.auto, player, game.selectedTarget), 28, (graphics.width/2)-590, graphics.height-465, graphics.argb(255,255,255,255))
		-- graphics.draw_text_2D("Q DMG :"..GetDmg(spells.q, player, game.selectedTarget), 28, (graphics.width/2)-590, graphics.height-430, graphics.argb(255,255,255,255))
		-- graphics.draw_text_2D("W DMG :"..GetDmg(spells.w, player, game.selectedTarget), 28, (graphics.width/2)-590, graphics.height-395, graphics.argb(255,255,255,255))
		-- graphics.draw_text_2D("E DMG :"..GetDmg(spells.e, player, game.selectedTarget), 28, (graphics.width/2)-590, graphics.height-360, graphics.argb(255,255,255,255))
		-- graphics.draw_text_2D("R DMG :"..GetDmg(spells.r, player, game.selectedTarget), 28, (graphics.width/2)-590, graphics.height-325, graphics.argb(255,255,255,255))
		graphics.draw_text_2D("StackCounter    :", 28, (graphics.width/2)-590, graphics.height-290, graphics.argb(255,255,255,255))
		graphics.draw_text_2D(tostring(StackCount), 28, (graphics.width/2)-350, graphics.height-290, graphics.argb(255,255,255,0))
		graphics.draw_text_2D("Auto Ult Harras :", 28, (graphics.width/2)-590, graphics.height-255, graphics.argb(255,255,255,255))
		if player:spellSlot(3).state == 0 and menu.r.MaxUltStackHarass:get() >= StackCount and menu.harass.manar:get() <= 100*player.mana/player.maxMana then
			graphics.draw_text_2D("ON", 28, (graphics.width/2)-350, graphics.height-255, graphics.argb(255,0,255,0))
		else
			graphics.draw_text_2D("OFF", 28, (graphics.width/2)-350, graphics.height-255, graphics.argb(255,255,0,0))
		end
		graphics.draw_text_2D("Auto Ult Combo  :", 28, (graphics.width/2)-590, graphics.height-220, graphics.argb(255,255,255,255))
		if player:spellSlot(3).state == 0 and menu.r.MaxUltStackCombo:get() >= StackCount then
			graphics.draw_text_2D("ON", 28, (graphics.width/2)-350, graphics.height-220, graphics.argb(255,0,255,0))
		else
			graphics.draw_text_2D("OFF", 28, (graphics.width/2)-350, graphics.height-220, graphics.argb(255,255,0,0))
		end
	end

  if menu.draws.r_range:get() then
		local pos = graphics.world_to_screen(player.pos);
		if not player.isOnScreen then return end
		graphics.draw_circle(player.pos, r_GetMaxRange(), 2, graphics.argb(255, 192, 57, 43), 70)
	end
end


-- Tick hook
local function ontick()
	doTick();
end

cb.add(cb.draw, ondraw)
orb.combat.register_f_pre_tick(ontick)
