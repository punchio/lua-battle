local action = require("action")
local action_move = new(action, "move")

local unit_helper = require("unit_helper")
local action_mgr = require("action_mgr")
local common = require("common")

function action_move:ctor( ... )
	-- body
	self.id = ...
	print('action ' .. self.type .. ' ctor, id:' .. self.id)
end

function action_move:fill( ... )
	-- body
	self.unit_id = ...
	self.unit = unit_helper.get_unit(self.unit_id)
	print('action ' .. self.type .. ' fill, id:' .. self.id .. '|unit id:' .. self.unit_id)
end

function action_move:create_ex( ... )
	-- body
	action_mgr.broadcast(common.ENTER_MOVE, self.unit_id)
end

function action_move:destroy_ex( ... )
	-- body
	self.unit:set_raw_attribute('move', nil)
	action_mgr.broadcast(common.LEAVE_MOVE, self.unit_id)
end

function action_move:check_valid()
	-- body
	if self.unit:get_raw_attribute('hp') == 0 then
		print('action ' .. self.type .. ' check_valid, id:' .. self.id .. '|unit id:' .. self.unit_id .. ' dead.')
		return false
	end

	local move = unit_helper.get_move_pos(self.unit)
	if not move or unit_helper.distance(self.unit:get_raw_attribute('pos'), move) < 2 then
		return false
	end

	return true
end

function action_move:check_enable()
	-- body
	return true
end

function action_move:run_when_enable(time_delta)
	-- body
	print('action ' .. self.type .. ' run_when_enable, id:' .. self.id .. '|unit id:' .. self.unit_id)
	action_mgr.broadcast(common.MOVE_BEFORE, self.unit_id, self.unit:get_raw_attribute('pos'))
	unit_helper.move(self.unit, time_delta)
	action_mgr.broadcast(common.MOVE_AFTER, self.unit_id, self.unit:get_raw_attribute('pos'))
end

return action_move
