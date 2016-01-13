--[[
进入此状态条件：
玩家或者策略指定释放指定技能
--]]

local state = require("fsm_state")
local state_attack = new(state, "attack")

local action_mgr = require("action_mgr")
local unit_helper = require("unit_helper")

function state_attack:enter(unit)
	print('fsm enter:' .. self.id .. ' unit:' .. unit.id)
	action_mgr.add_action('attack', unit.id)
end

return state_attack