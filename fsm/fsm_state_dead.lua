local state = require("fsm_state")
local state_dead = new(state, STATE_CONFIG.DEAD)

function state_dead:enter(unit)
	print('fsm enter:' .. self.id .. ' unit:' .. unit.id)
end

function state_dead:check_transition(unit)
	print('fsm check transition ex:' .. self.id)
	if unit:get_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP) > 0 then
		return STATE_CONFIG.MOVE
	end
	return self.id
end

return state_dead