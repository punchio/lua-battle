local action = require("action")
local action_spell = new(action, "spell")

local unit_helper = require("unit_helper")
local action_mgr = require("action_mgr")
local common = require("common")
local skill_config = require("skill_config")

function action_spell:ctor( ... )
	-- body
	self.id = ...
	self.buff_ids = {}
	print('action ' .. self.type .. ' ctor, id:' .. self.id)
end

function action_spell:fill( ... )
	-- body
	self.unit_id = ...
	self.unit = unit_helper.get_unit(self.unit_id)

	self.last_time = skill_config[1]['time']
	self.run_time = 0
	self.spell_time = 0
	
	print('action ' .. self.type .. ' fill, id:' .. self.id .. '|unit id:' .. self.unit_id)
end

function action_spell:create_ex( ... )
	-- body
	action_mgr.broadcast(common.ENTER_SPELL, self.unit_id)
end

function action_spell:destroy_ex( ... )
	-- body
	action_mgr.broadcast(common.LEAVE_SPELL, self.unit_id)
end

function action_spell:check_valid()
	-- body
	return self.unit:get_raw_attribute('spell') ~= 0 and self.run_time < self.last_time
end

function action_spell:check_enable()
	-- body
	return true
end

function action_spell:enable_ex()
	-- body
	print('action ' .. self.type .. ' enable_ex, id:' .. self.id .. '|unit id:' .. self.unit_id)

	local buff = skill_config[1]['buff']
	if buff then
		for k, v in pairs( buff ) do
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

function action_spell:disable_ex()
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

function action_spell:run_ex(time_delta)
	-- body
	print('action ' .. self.type .. ' run_ex, id:' .. self.id .. '|unit id:' .. self.unit_id)
	self.run_time = self.run_time + time_delta
end

function action_spell:run_when_enable(time_delta)
	-- body
	print('action ' .. self.type .. ' run_when_enable, id:' .. self.id .. '|unit id:' .. self.unit_id .. '|diff time:' .. (self.run_time - self.spell_time))
	if self.run_time - self.spell_time < 3 then
		return
	end
	action_mgr.broadcast(common.SPELL_BEFORE, self.unit_id)
	self.spell_time = self.run_time

	local damage = skill_config[1]['damage']
	if damage then
		for k, v in pairs( damage ) do
			local dmg = self.unit:get_attribute(k) * v
			print('action skill unit id:' .. self.unit.id .. '|action id:' .. self.id .. '|damage:' .. dmg)
			local enemy_units = unit_helper.get_enemy_units(self.unit:get_raw_attribute('side'))
			for _, v in ipairs( enemy_units ) do
				print('action skill unit id:' .. self.unit.id .. '|damage to unit:' .. v.id .. '|damage:' .. dmg)
				local hp = v:get_raw_attribute('hp')
				hp = (hp > dmg and (hp - dmg) or 0)
				v:set_raw_attribute('hp', hp)
			end
		end

	end
	action_mgr.broadcast(common.SPELL_AFTER, self.unit_id)
end

return action_spell
