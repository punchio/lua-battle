local action = require("action")
local action_spell_buff = new(action, "spell_buff")

local unit_helper = require("unit_helper")
local skill_config = require("skill_config")

function action_spell_buff:ctor( ... )
	-- body
	self.id = ...
	self.buff_ids = {}
	print('action ' .. self.type .. ' ctor, id:' .. self.id)
end

function action_spell_buff:fill( ... )
	-- body
	self.unit_id = ...
	self.unit = unit_helper.get_unit(self.unit_id)

	self.last_time = skill_config[1]['buff']['time']
	--self.spell_time = skill_config[1]['spell_time'] or 0

	-- if last time less than spell time, it cannot exit spell state.
	--if self.spell_time > self.last_time then
	--	self.spell_time = self.last_time
	--end

	self.run_time = 0
	
	print('action ' .. self.type .. ' fill, id:' .. self.id .. '|unit id:' .. self.unit_id)
end

function action_spell_buff:check_valid()
	-- body
	return self.run_time < self.last_time
end

function action_spell_buff:check_enable()
	-- body
	return true
end

function action_spell_buff:enable_ex()
	-- body
	print('action ' .. self.type .. ' enable_ex, id:' .. self.id .. '|unit id:' .. self.unit_id)

	local buff = skill_config[1]['buff']
	if buff then
		for k, v in pairs( buff ) do
			if type(v) ~= 'number' then
				self.unit:get_attribute(k)
				local buff_id
				buff_id = self.unit:add_attr_buff(k, 'base_value', v[1])
				table.insert(self.buff_ids, buff_id)
	
				buff_id = self.unit:add_attr_buff(k, 'base_percent', v[2])
				table.insert(self.buff_ids, buff_id)
	
				buff_id = self.unit:add_attr_buff(k, 'total_percent', v[3])
				table.insert(self.buff_ids, buff_id)
				self.unit:get_attribute(k)
			end
		end
	end
end

function action_spell_buff:disable_ex()
	-- body
	print('action ' .. self.type .. ' disable_ex, id:' .. self.id .. '|unit id:' .. self.unit_id)
	if not self.unit then
		print('unit had been destroyed. id:' .. self.unit_id)
		return
	end

	self.unit:get_attribute('str')
	for _, v in ipairs( self.buff_ids ) do
		self.unit:remove_attr_buff(v)
	end
	self.unit:get_attribute('str')
end

function action_spell_buff:run_ex(time_delta)
	-- body
	print('action ' .. self.type .. ' run_ex, id:' .. self.id .. '|unit id:' .. self.unit_id)
	self.run_time = self.run_time + time_delta
	--if self.run_time >= self.spell_time then
	--	self.unit:set_raw_attribute('spell', 0)
	--end
end

return action_spell_buff
