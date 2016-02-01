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
	if new_state ~= unit:get_raw_attribute('state') then
		return new_state
	end

	return self:check_transition_ex(unit)

--	if unit:get_raw_attribute('hp') <= 0 then
--		return 'dead'
--	elseif unit:get_raw_attribute('move') ~= nil then
--		return 'move'
--	elseif unit:get_raw_attribute('attack') ~= 0 then
--		local target = unit_helper.get_unit(unit:get_raw_attribute('attack'))
--		if not target then
--			unit:set_raw_attribute('attack', 0)
--			return 'idle'
--		elseif not unit_helper.can_attack(unit, target) then
--			unit:set_raw_attribute('move', target.id)
--			return 'move'
--		else
--			return 'attack'
--		end
--	elseif unit:get_raw_attribute('spell') ~= 0 then
--		return 'spell'
--	end
--
--	if unit:get_raw_attribute('auto-attack') then
--		local find = unit_helper.attack_nearby(unit)
--		if find then
--			return 'attack'
--		end
--	end
--
--	return 'idle'--self:check_transition_ex(unit)
end

function state:check_transition_ex(unit)
	print('fsm check transition ex:' .. self.id)
	return self.id
end

-- first check this
function state:check_priority( unit )
	local new = nil
	local state_flag = unit:get_raw_attribute('state_flag')
	for i=1, 10 do
		if state_flag[i] then
			new = state_flag[i]
			break
		end
	end

	return new
end

return state