local action = require("action")
local action_spell_damage = new(action, "spell_damage")

local unit_helper = require("unit_helper")
local skill_config = require("skill_config")

function action_spell_damage:ctor( ... )
	-- body
	self.id = ...
	self.buff_ids = {}
	print('action ' .. self.type .. ' ctor, id:' .. self.id)
end

function action_spell_damage:fill( ... )
	-- body
	self.unit_id = ...
	self.unit = unit_helper.get_unit(self.unit_id)

	self.last_time = skill_config[1]['time']
	self.period = skill_config[1]['damage']['period']
	self.run_time = 0
	self.spell_time = 0

	print('action ' .. self.type .. ' fill, id:' .. self.id .. '|unit id:' .. self.unit_id)
end

function action_spell_damage:check_valid()
	-- body
	return self.run_time < self.last_time
end

function action_spell_damage:check_enable()
	-- body
	return true
end

function action_spell_damage:run_ex(time_delta)
	-- body
	print('action ' .. self.type .. ' run_ex, id:' .. self.id .. '|unit id:' .. self.unit_id)
	self.run_time = self.run_time + time_delta
end

function action_spell_damage:run_when_enable(time_delta)
	-- body
	print('action ' .. self.type .. ' run_when_enable, id:' .. self.id .. '|unit id:' .. self.unit_id .. '|diff time:' .. (self.run_time - self.spell_time))
	if self.run_time - self.spell_time < self.period then
		return
	end

	self.spell_time = self.run_time

	local damage = skill_config[1]['damage']
	if damage then
		for k, v in pairs( damage ) do
			local dmg = self.unit:get_attribute(k) * v
			print('action skill unit id:' .. self.unit.id .. '|action id:' .. self.id .. '|damage:' .. dmg)
			local enemy_units = unit_helper.get_enemy_units(self.unit:get_raw_attribute('side'))
			for _, _v in ipairs( enemy_units ) do
				print('action skill unit id:' .. self.unit.id .. '|damage to unit:' .. _v.id .. '|damage:' .. dmg)
				local hp = _v:get_raw_attribute('hp')
				hp = (hp > dmg and (hp - dmg) or 0)
				_v:set_raw_attribute('hp', hp)
			end
		end

	end
end

return action_spell_damage
