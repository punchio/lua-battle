require("common")
local unit_helper = require("unit_helper")
local formulas = {}
local env = {}
env.g_unit = nil
env.g_target = nil

--local s = 'get_hp(ab, c); get_enemy_agi(1, 2)'
--local trans = string.gsub(s, '_(%w+)%(', '(%1, ')
--print(trans)
--[[local BATTLE_PROPS_CONFIG = {
	MAX_HP = 1,
	CUR_HP = 2,
	PHY_ATK_POWER = 3, 
	PHY_DFS_POWER = 4,
	MAG_ATK_POWER = 5,
	MAG_DFS_POWER = 6,

	STRENGTH = 7,
	AGILITY = 8,
	INTELLIGENCE = 9,
	SPEED = 10,
}]]

function env.get_attr( attr, unit )
	if not unit then unit = cast_unit end
	if not unit then return 0 end
	return unit:get_str(attr)
end

function env.get_enemy_attr( attr, idx )
	if not cast_targets or #cast_targets < idx then return 0 end
	return get_str('str', cast_targets[idx])
end

function env.add_hp( value )
	env.g_unit:add_hp(value)
end

function env.get_hp()
	return env.g_unit:get_attribute(BATTLE_PROPS_CONFIG.CUR_HP)
end

function env.get_self()
	return env.g_unit
end

function env.get_closest_enemy()
	return unit_helper.find_closest_target(env.g_unit)
end

function env.add_buff( buff_id )
	env.g_unit.skill_manager.skill_buff:add(buff_id)
end

return env