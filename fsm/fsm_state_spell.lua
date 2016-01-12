--[[
进入此状态条件：
玩家或者策略指定释放指定技能
--]]

local state = require("fsm_state")
local state_spell = new(state, "spell")

local action_mgr = require("action_mgr")
local unit_helper = require("unit_helper")

function state_spell:enter(unit)
	print('fsm enter:' .. self.id .. ' unit:' .. unit.id)
	action_mgr.add_event('spell', unit.id)
end

function state_spell:exit(unit)
	print( 'fsm exit:' .. self.id )
end

function state_spell:check_transition_ex(unit)
	print('fsm check transition ex:' .. self.id)
	return self.id
end

return state_spell