local unit_mgr = {}
local unit = require("unit")
local skill_manager

function unit_mgr.init(mgr)
	print('unit mgr init.')
	skill_manager = mgr
	unit_mgr.free_id = 1
	unit_mgr.units = {}
end

function unit_mgr.add_unit( unit )
	-- body
	print('unit mgr add unit:' .. unit.id)
	unit_mgr.units[unit.id] = unit
end

function unit_mgr.remove_unit( id )
	-- body
	print('unit mgr remove unit:' .. id)
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
	print('unit helper random units.')
	local u = new(unit, unit_mgr.pop_free_id())
	u.side = u.id % 2
	print('side:' .. u.side)

	u:set_raw_attribute(BATTLE_PROPS_CONFIG.MAX_HP, 700)
	u:set_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP, 300 + math.random(400))
	print('hp:' .. u:get_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP))

	u:set_raw_attribute(BATTLE_PROPS_CONFIG.PHY_ATK_POWER, math.random(20) + 50)
	print('atk power:' .. u:get_raw_attribute(BATTLE_PROPS_CONFIG.PHY_ATK_POWER))

	u:set_raw_attribute(BATTLE_PROPS_CONFIG.SPEED, math.random(3) + 3)
	print('speed:' .. u:get_raw_attribute(BATTLE_PROPS_CONFIG.SPEED))

	u:set_position(math.random(50) + 50, math.random(50) + 50)
	print('pos:' .. u:get_position())

	u:init(skill_manager)
	u.skill_manager.skill_bag:add(math.random(3))
	
	return u
end

function unit_mgr.update( delta_time )
	print('unit mgr update.')
	for id, unit in pairs( unit_mgr.units ) do
		for i = 1, 3 do
			if unit.skill_manager:has_skill(i) then
				unit.skill_manager:cast_skill(i)
			end
		end
		

		--if unit:get_cur_state() ~= STATE_CONFIG.DEAD and 
		--   unit.blackboard.is_default_move == false and 
		--   unit.blackboard.auto_fight == true then
		--	local target = unit_helper.attack_nearby(unit)
		--	if target then
		--		unit:set_dest_position(target:get_position())
		--	end
		--end
	end
end

return unit_mgr