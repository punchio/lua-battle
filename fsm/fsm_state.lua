require("common")
require('log')

local state = {}

state.id = 'base'

function state:ctor(...)
	self.id = ...
	log_print('detail', 'fsm state ctor id:' .. self.id)
end

function state:enter(unit)
	log_print('detail', 'fsm enter:' .. self.id)
end

function state:exit(unit)
	log_print('detail',  'fsm exit:' .. self.id )
end

function state:update(unit, time_delta)
	log_print('detail', 'fsm update:' .. self.id)
end

function state:check_transition(unit)
	log_print('detail', 'fsm check transition:' .. self.id)

	local new_state = self:check_priority(unit)
	if new_state ~= unit:get_cur_state() then
		return new_state
	end

	return self:check_transition_ex(unit)
end

function state:check_transition_ex(unit)
	log_print('detail', 'fsm check transition ex:' .. self.id)
	return self.id
end

-- first check this order
-- 1 = win, 2 = dead, 3 = dizzy, 4 = possess, 5 = immobilize, 6 = silent, 7 = back, 8 = immunity, 9 = move, 10 = idle
function state:check_priority( unit )
	local new = unit:get_cur_state()
	local states = unit:get_states()
	for k, v in pairs( states ) do
		log_print('detail', k,v)
	end

	for i = 1, unit:get_cur_state() - 1 do
		log_print('detail', i)
		if states[i] == true then
			new = i
			break
		end
	end

	return new
end

return state