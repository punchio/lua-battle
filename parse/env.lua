require("common")
local unit_mgr = require("unit_mgr")
local formulas = {}
local env = {}
env.g_unit = nil
env.g_target = nil

env.print = print

function env.set_self( unit )
	env.g_unit = unit
end

function env.set_enemy( target )
	env.g_target = target
end

function env.get_self()
	return env.g_unit
end

function env.get_enemy( idx )
	if env.g_target and #env.g_target < idx then
		return env.g_target[idx]
	else
		return nil
	end
end

function env.is_idle(unit)
	unit = unit or env.g_unit
	if unit then
		return unit:get_cur_state() == STATE_CONFIG.IDLE
	else
		return true
	end	
end


function env.get_attr( attr, unit )
	unit = unit or env.g_unit
	if unit then
		return unit:get_attribute(attr)
	else
	    return 0
	end
end

function env.get_enemy_attr( attr, idx )
	if not env.g_target or #env.g_target < idx then 
		return 0 
	else
		return env.get_attr(attr, env.g_target[idx])    
	end
end

function env.add_hp( value, unit )
	unit = unit or env.g_unit
	if unit then
		unit:add_hp(value)
	end
end

function env.add_enemy_hp( value, idx )
	if env.g_target and #env.g_target >= idx then 
		env.add_hp(value, env.g_target[idx])
	end
end

function env.get_hp(unit)
	unit = unit or env.g_unit
	if unit then
		return unit:get_attribute(BATTLE_PROPS_CONFIG.CUR_HP)
	else
	    return 0
	end
end

function env.get_enemy_hp( value, idx )
	if env.g_target and #env.g_target >= idx then 
		return env.g_target[idx]:get_attribute(BATTLE_PROPS_CONFIG.CUR_HP)
	else
	    return 0
	end
end

function env.get_closest_enemy(unit)
	unit = unit or env.g_unit
	return unit_mgr.find_closest_target(unit)
end

function env.get_attack_target(unit)
	unit = unit or env.g_unit
	local enemy = unit_mgr.find_closest_target(unit)
	if unit_mgr.can_attack(env.g_unit, enemy) then
		return enemy
	else
		return nil
	end
end

function env.add_buff( buff_id, unit)
	unit = unit or env.g_unit
	if unit then
		unit.skill_manager.skill_buff:add(buff_id)
	end
end

function env.add_enemy_buff( buff_id, idx )
	if env.g_target and #env.g_target >= idx then 
		return env.g_target[idx].skill_manager.skill_buff:add(buff_id)
	else
	    return 0
	end
end

function env.can_attack( unit )
	return unit_mgr.can_attack(env.g_unit, unit)
end

return env