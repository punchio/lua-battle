local state = require("fsm_state")
local state_idle = new(state, "idle")

function state_idle:check_transition_ex(unit)
	print('fsm check transition ex:' .. self.id)
	return self.id
end

return state_idle