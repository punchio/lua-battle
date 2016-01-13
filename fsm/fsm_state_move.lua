--[[
进入此状态条件：
玩家或者策略指定移动到目标单位或者目的地
--]]

local state = require("fsm_state")
local state_move = new(state, "move")

local action_mgr = require("action_mgr")
local unit_helper = require("unit_helper")

function state_move:enter(unit)
	print('fsm enter:' .. self.id .. ' unit:' .. unit.id)
	action_mgr.add_action('move', unit.id)
end

return state_move