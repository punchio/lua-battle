local state = require("fsm_state")
local state_dead = new(state, "dead")

local unit_mgr = require("unit_mgr")

function state_dead:enter(unit)
	print('fsm enter:' .. self.id .. ' unit:' .. unit.id)
	unit:set_raw_attribute('dead_time', 10)
end

function state_dead:check_transition(unit)
	print('fsm check transition ex:' .. self.id)
	--unit:set_raw_attribute('dead_time', unit:get_raw_attribute('dead_time') - 1)
	--if unit:get_raw_attribute('dead_time') == 0 then
	--	unit:set_raw_attribute('hp', unit:get_raw_attribute('maxhp'))
	--	return 'born'
	--end
	return self.id
end

return state_dead