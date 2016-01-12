local state = require("fsm_state")
local state_born = new(state, "born")

function state_born:check_transition_ex(unit)
	print('fsm check transition ex:' .. self.id)
	return 'idle'
end

return state_born