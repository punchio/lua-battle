require('log')

local unit_mgr = {}
local unit = require("unit")
local skill_manager
local unit_helper

function unit_mgr.init(skill_mgr, ut_help)
	log_print('detail','unit mgr init.')
	skill_manager = skill_mgr
	unit_helper = ut_help
	unit_mgr.free_id = 1
	unit_mgr.units = {}
end

function unit_mgr.add_unit( unit )
	-- body
	log_print('detail','unit mgr add unit:' .. unit.id)
	unit_mgr.units[unit.id] = unit
end

function unit_mgr.remove_unit( id )
	-- body
	log_print('detail','unit mgr remove unit:' .. id)
	unit_mgr.units[id] = nil
end

function unit_mgr.get_unit( id )
	-- body
	return unit_mgr.units[id]
end

function unit_mgr.pop_free_id( )
	-- body
	local id = unit_mgr.free_id
	unit_mgr.free_id = id + 1
	return id
end


function unit_mgr.random_unit( )
	-- body
	log_print('detail','unit helper random units.')
	local u = new(unit, unit_mgr.pop_free_id())
	u.side = u.id % 2
	log_print('detail','side:' .. u.side)

	u:set_raw_attribute(BATTLE_PROPS_CONFIG.MAX_HP, 700)
	u:set_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP, 300 + math.random(400))
	log_print('detail','hp:' .. u:get_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP))

	u:set_raw_attribute(BATTLE_PROPS_CONFIG.PHY_ATK_POWER, math.random(20) + 50)
	log_print('detail','atk power:' .. u:get_raw_attribute(BATTLE_PROPS_CONFIG.PHY_ATK_POWER))

	u:set_raw_attribute(BATTLE_PROPS_CONFIG.SPEED, math.random(3) + 3)
	log_print('detail','speed:' .. u:get_raw_attribute(BATTLE_PROPS_CONFIG.SPEED))

	u:set_position(math.random(50) + 50, math.random(50) + 50)
	log_print('detail','pos:' .. u:get_position())

	u:init(skill_manager)
	u.skill_manager.skill_bag:add(math.random(3))
	u.skill_manager.skill_buff:add(5)

	return u
end

function unit_mgr.find_closest_target(u)
	local side = u.side
	local target = nil
	local min_dist = 0
	local x1, y1 = u:get_position()
	for _, v in pairs( unit_mgr.units ) do
		if v.side ~= side and v:get_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP) > 0 then
			local x2, y2 = v:get_position()
			local dist = unit_helper.distance(x1, y1, x2, y2)
			log_print('detail',x1, y1, x2, y2, min_dist)
			if min_dist == 0 or min_dist > dist then
				min_dist = dist
				target = v
			end
		end
	end

	if target then
		log_print('detail','unit mgr find close target:', target.id)
	else
	    log_print('detail','unit mgr find nil target.')
	end

	return target
end

function unit_mgr.can_attack( unit, target )
	if not unit or not target then
		return false
	end

	local x1, y1 = unit:get_position()
	local x2, y2 = target:get_position()
	local dist = unit_helper.distance(x1, y1, x2, y2)

	return unit.blackboard.attack_range > dist
end

function unit_mgr.get_enemy_units( side )
	local enemy = {}
	for _, v in pairs( unit_mgr.units ) do
		if v.side ~= side then
			table.insert(enemy, v)
		end
	end

	return enemy
end


function unit_mgr.check_finish()
	local alive_side
	for _, v in pairs( unit_mgr.units ) do
		if v:get_cur_state() ~= STATE_CONFIG.DEAD then
			local side = v.side
			if not alive_side then
				alive_side = side
			elseif alive_side ~= side then
				return false
			end
		end
	end
	log_print('detail','win side:' .. alive_side)
	return true
end

function unit_mgr.update( delta_time )
	--log_print('detail','unit mgr update.')
	--for id, unit in pairs( unit_mgr.units ) do
	--	for i = 1, 3 do
	--		if unit.skill_manager:has_skill(i) then
	--			unit.skill_manager:cast_skill(i)
	--		end
	--	end
	--end
end

return unit_mgr