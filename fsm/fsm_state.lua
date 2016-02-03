require("common")
local unit_helper = require("unit_helper")

local state = {}

state.id = 'base'

function state:ctor(...)
	self.id = ...
	print('fsm state ctor id:' .. self.id)
end

function state:enter(unit)
	print('fsm enter:' .. self.id)
end

function state:exit(unit)
	print( 'fsm exit:' .. self.id )
end

function state:update(unit, time_delta)
	print('fsm update:' .. self.id)
end

function state:check_transition(unit)
	print('fsm check transition:' .. self.id)

	local new_state = self:check_priority(unit)
	if new_state ~= unit:get_cur_state() then
		return new_state
	end

	return self:check_transition_ex(unit)
end

function state:check_transition_ex(unit)
	print('fsm check transition ex:' .. self.id)
	return self.id
end

-- first check this order
-- 1 = win, 2 = dead, 3 = dizzy, 4 = possess, 5 = immobilize, 6 = silent, 7 = back, 8 = immunity, 9 = move, 10 = idle
function state:check_priority( unit )
	local new = STATE_CONFIG.IDLE
	local states = unit:get_states()
	for k, v in pairs( states ) do
		print(k,v)
	end
	for i, v in ipairs( states ) do
		if v == true then
			new = i
			break
		end
	end

	return new
end

return state