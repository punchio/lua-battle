local action = require("action")
local action_attack = new(action, "attack")

local unit_helper = require("unit_helper")
local action_mgr = require("action_mgr")
local common = require("common")

function action_attack:ctor( ... )
	-- body
	self.id = ...
	print('action ' .. self.type .. ' ctor, id:' .. self.id)
end

function action_attack:fill( ... )
	-- body
	self.unit_id = ...
	self.unit = unit_helper.get_unit(self.unit_id)
	self.defencer = unit_helper.get_unit(self.unit:get_raw_attribute('attack'))
	print('action ' .. self.type .. ' ctor, id:' .. self.id .. '|unit id:' .. self.unit_id)
end

function action_attack:create_ex( ... )
	-- body
	action_mgr.broadcast(common.ENTER_ATTACK, self.unit_id, self.defencer.id)
end

function action_attack:destroy_ex( ... )
	-- body
	self.unit:set_raw_attribute('attack', 0)
	action_mgr.broadcast(common.LEAVE_ATTACK, self.unit_id, self.defencer.id)
end

function action_attack:check_valid()
	-- body
	if self.defencer:get_raw_attribute('hp') == 0 then
		print('action ' .. self.type .. ' check_valid, id:' .. self.id .. ' target ' .. self.defencer.id ..' dead.')
		return false
	end

	local dist = unit_helper.distance(self.unit:get_raw_attribute('pos'), self.defencer:get_raw_attribute('pos'))
	if dist < self.unit:get_raw_attribute('attack_range') then
		--print('action ' .. self.type .. ' check_valid, id:' .. self.id .. ' return true')
		return true
	end

	print('action ' .. self.type .. ' check_valid, id:' .. self.id .. ' out of range.')
	return false
end

function action_attack:check_enable()
	-- body
	return true
end

function action_attack:run_when_enable(time_delta)
	-- body
	action_mgr.broadcast(common.ATTACK_BEFORE, self.unit_id, self.defencer.id)
	print('action ' .. self.type .. ' run, unit id:' .. self.unit_id .. '|action id:' .. self.id)
	local left_hp = self.defencer:get_raw_attribute('hp')
	local damage = self.unit:get_attribute('str')
	
	if left_hp < damage then
		damage = left_hp
	end

	self.defencer:set_raw_attribute('hp', left_hp - damage)

	action_mgr.broadcast(common.ATTACK_AFTER, self.unit_id, self.defencer.id, damage)

	-- 仇恨机制
	if self.defencer:get_raw_attribute('defence') == 0 then
		self.defencer:set_raw_attribute('defence', self.unit_id)
	end
end

return action_attack
