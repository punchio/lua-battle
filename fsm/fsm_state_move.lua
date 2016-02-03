--[[
进入此状态条件：
玩家或者策略指定移动到目标单位或者目的地
--]]

local state = require("fsm_state")
local state_move = new(state, STATE_CONFIG.MOVE)

local unit_helper = require("unit_helper")

function state_move:enter(unit)
	print('fsm enter:' .. self.id .. ' unit:' .. unit.id)
end

function state_move:exit(unit)
	print('fsm exit:' .. self.id .. ' unit:' .. unit.id)
	if unit.blackboard.is_default_move == true then
		unit.blackboard.is_default_move = false
	end
end

function state_move:check_transition_ex( unit )
	print('fsm check_transition_ex:' .. self.id .. ' unit:' .. unit.id)
	local move = unit:get_dest_position()
	local position = unit:get_position()

	if unit.blackboard.is_default_move == false and	move.x == position.x and move.y == position.y then
		return STATE_CONFIG.IDLE
	end
	return self.id
end

function state_move:update( unit, delta_time )
	print('fsm update:' .. self.id .. ' unit:' .. unit.id)

	local bd = unit.blackboard
	if bd.is_default_move then
		local step = bd.default_move_step or 1
		local dest_pos = bd.default_path[step]
		local x, y = unit:get_position()

		if dest_pos.x == x and dest_pos.y == y then
			step = step + 1
			dest_pos = bd.default_path[step]
			bd.default_move_step = step
			unit:set_dest_position(dest_pos.x, dest_pos.y)
		end
	elseif bd.chase_enemy ~= 0 then
		local enemy = unit_mgr.get_unit( bd.chase_enemy )
		if enemy then
			unit:set_dest_position(enemy:get_position())
		end
	end

	unit:move(delta_time)
end

return state_move