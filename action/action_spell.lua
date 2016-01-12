local action = require("action")
local action_spell = new(action, "spell")

local unit_helper = require("unit_helper")
local action_mgr = require("action_mgr")
local common = require("common")

function action_spell:ctor( ... )
	-- body
	self.id = ...
	print('action ' .. self.type .. ' ctor, id:' .. self.id)
end

function action_spell:fill( ... )
	-- body
	self.unit_id = ...
	self.unit = unit_helper.get_unit(self.unit_id)
	print('action ' .. self.type .. ' fill, id:' .. self.id .. '|unit id:' .. self.unit_id)
end

function action_spell:create_ex( ... )
	-- body
	action_mgr.listen(common.ENTER_SPELL, self.unit_id)
end

function action_spell:destroy_ex( ... )
	-- body
	action_mgr.listen(common.LEAVE_SPELL, self.unit_id)
end

function action_spell:check_valid()
	-- body
	self.unit = unit_helper.get_unit(self.unit_id)
	print('action ' .. self.type .. ' check_valid, id:' .. self.id .. '|unit id:' .. self.unit_id)
	if not self.unit then
		print('unit not valid')
	else
		print('spell id:' .. self.unit:get_raw_attribute('spell') .. '|run time:' .. self.run_time)
	end

	return self.unit and self.unit:get_raw_attribute('spell') ~= 0 and self.run_time > 0
end

function action_spell:check_enable()
	-- body
	return true
end

function action_spell:create_ex()
	-- body
	self.run_time = 0
	self.spell_time = 0
	self.buff_ids = {}
end

function action_spell:enable_ex()
	-- body
	print('action ' .. self.type .. ' enable_ex, id:' .. self.id .. '|unit id:' .. self.unit_id)

	self.old_pos = self.unit:get_raw_attribute('pos')
	--self.unit:set_raw_attribute('pos', {10000, 10000, 10000})

	self.unit:get_attribute('str')
	local buff_id
	buff_id = self.unit:add_attr_buff('str', 'base_value', 10)
	table.insert(self.buff_ids, buff_id)
	buff_id = self.unit:add_attr_buff('str', 'base_percent', -0.1)
	table.insert(self.buff_ids, buff_id)
	buff_id = self.unit:add_attr_buff('str', 'total_percent', 2)
	table.insert(self.buff_ids, buff_id)
	self.unit:get_attribute('str')
end

function action_spell:disable_ex()
	-- body
	print('action ' .. self.type .. ' disable_ex, id:' .. self.id .. '|unit id:' .. self.unit_id)
	if not self.unit then
		print('unit had been destroyed. id:' .. self.unit_id)
		return
	end

	self.unit:set_raw_attribute('pos', self.old_pos)

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
	action_mgr.listen(common.SPELL_BEFORE, self.unit_id)
	self.spell_time = self.run_time

	local dmg = self.unit:get_attribute('str') * 2
	print('action skill unit id:' .. self.unit.id .. '|action id:' .. self.id .. '|damage:' .. dmg)
	local enemy_units = unit_helper.get_enemy_units(self.unit:get_raw_attribute('side'))
	for _, v in ipairs( enemy_units ) do
		print('action skill unit id:' .. self.unit.id .. '|damage to unit:' .. v.id .. '|damage:' .. dmg)
		local hp = v:get_raw_attribute('hp')
		hp = (hp > dmg and (hp - dmg) or 0)
		v:set_raw_attribute('hp', hp)
	end
	action_mgr.listen(common.SPELL_AFTER, self.unit_id)
end

return action_spell
