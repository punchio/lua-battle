--[[
进入此状态条件：
玩家或者策略指定移动到目标单位或者目的地
--]]
require('log')
local state = require("fsm_state")
local state_move = new(state, STATE_CONFIG.MOVE)
local unit_mgr = require("unit_mgr")

function state_move:enter(unit)
	log_print('detail', 'fsm enter:' .. self.id .. ' unit:' .. unit.id)
	if unit.blackboard.is_default_move == true then
		local step = unit.blackboard.default_move_step or 1
		local dest_pos = unit.blackboard.default_path[step]
		if not dest_pos then
			unit.blackboard.is_default_move = false
		else
			unit:set_dest_position(dest_pos.x, dest_pos.y)	
		end
		
	end
end

function state_move:exit(unit)
	log_print('detail', 'fsm exit:' .. self.id .. ' unit:' .. unit.id)
	if unit.blackboard.is_default_move == true then
		unit.blackboard.is_default_move = false
	end
end

function state_move:check_transition_ex( unit )
	log_print('detail', 'fsm check_transition_ex:' .. self.id .. ' unit:' .. unit.id)
	local enemy = unit_mgr.find_closest_target(unit)
	local to_x, to_y = unit:get_dest_position()
	local now_x, now_y = unit:get_position()
	if not enemy then
		log_print('detail', 'there is no enemy.')
	else
	    log_print('detail', 'closest enemy:', enemy.id)
	end

	if unit_mgr.can_attack(unit, enemy) then
		unit:set_dest_position(now_x, now_y)
		log_print('detail', 'can_attack')
		return STATE_CONFIG.IDLE
	end	
	
	local bd = unit.blackboard
	if bd.is_default_move == false then
		if to_x == now_x and to_y == now_y then
			bd.chase_enemy = enemy.id
		end
	end
	return self.id
end

function state_move:update( unit, delta_time )
	log_print('detail', 'fsm update:' .. self.id .. ' unit:' .. unit.id, unit:get_position())

	local bd = unit.blackboard
	log_print('detail', 'state_move update:', bd.is_default_move, 'chase_enemy:', bd.chase_enemy)
	if bd.is_default_move == true then
		local step = bd.default_move_step or 1
		local dest_pos = bd.default_path[step]
		local x, y = unit:get_position()
		log_print('detail',  'state_move update, state move step:', step, 'dest:', dest_pos.x, dest_pos.y )

		if dest_pos.x == x and dest_pos.y == y then
			step = step + 1
			dest_pos = bd.default_path[step]
			bd.default_move_step = step
			log_print('detail', 'state_move update, step:', step)
			if not dest_pos then 
				bd.is_default_move = false
				log_print('detail', 'default move over.')
			else
				unit:set_dest_position(dest_pos.x, dest_pos.y)
			end
		end
	elseif bd.chase_enemy ~= 0 then
		local enemy = unit_mgr.get_unit( bd.chase_enemy )
		if enemy then
			log_print('detail', 'state move update, chase enemy, unit id:', unit.id, '|enemy:', bd.chase_enemy)
			unit:set_dest_position(enemy:get_position())
		else
			log_print('detail', 'state move update, enemy not exist, unit id:', unit.id, '|enemy:', bd.chase_enemy)
		end
	end

	unit:move(delta_time)
end

return state_move