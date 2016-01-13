local action = require("action")
local action_spell = new(action, "spell")

local unit_helper = require("unit_helper")
local action_mgr = require("action_mgr")
local common = require("common")
local skill_config = require("skill_config")

function action_spell:ctor( ... )
	-- body
	self.id = ...
	print('action ' .. self.type .. ' ctor, id:' .. self.id)
end

function action_spell:fill( ... )
	-- body
	self.unit_id = ...
	self.unit = unit_helper.get_unit(self.unit_id)

	self.ready_time = skill_config[1]['ready_time'] or 0
	self.spell_time = skill_config[1]['spell_time'] or 0
	self.total_time = self.ready_time + self.spell_time + 1
	self.spelling = false
	self.run_time = 0
	
	print('action ' .. self.type .. ' fill, id:' .. self.id .. '|unit id:' .. self.unit_id)
end

function action_spell:create_ex( ... )
	-- body
	action_mgr.broadcast(common.ENTER_SPELL, self.unit_id)
end

function action_spell:destroy_ex( ... )
	-- body
	self.unit:set_raw_attribute('spell', 0)
	action_mgr.broadcast(common.LEAVE_SPELL, self.unit_id)
end

function action_spell:check_valid()
	-- body
	return self.run_time < self.total_time
end

function action_spell:run_ex(time_delta)
	-- body
	print('action ' .. self.type .. ' run_ex, id:' .. self.id .. '|unit id:' .. self.unit_id)
	self.run_time = self.run_time + time_delta
	if not self.spelling and self.run_time >= self.ready_time then
		self.spelling = true
		action_mgr.broadcast(common.SPELL_BEFORE, self.unit_id)
		action_mgr.add_action( 'spell_buff', self.unit_id)
		action_mgr.add_action( 'spell_damage', self.unit_id)
		action_mgr.broadcast(common.SPELL_AFTER, self.unit_id)
	end
end

return action_spell
