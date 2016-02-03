local state = require("fsm_state")
local state_idle = new(state, STATE_CONFIG.IDLE)

function state_idle:check_transition_ex(unit)
	print('fsm check transition ex:' .. self.id)
	if unit.blackboard.is_default_move then
		return STATE_CONFIG.MOVE
	end
	return self.id
end

return state_idle