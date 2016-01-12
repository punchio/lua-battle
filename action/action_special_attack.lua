local action = require("action")
local action_special_attack = new(action, "special-attack")

local unit_helper = require("unit_helper")
local action_mgr = require("action_mgr")
local common = require("common")

function action_special_attack:ctor( ... )
	-- body
	self.id = ...
	print('action ' .. self.type .. ' ctor, id:' .. self.id)
end

function action_special_attack:fill( ... )
	-- body
	self.unit_id = ...
	self.unit = unit_helper.get_unit(self.unit_id)
	print('action ' .. self.type .. ' ctor, id:' .. self.id .. '|unit id:' .. self.unit_id)
end

function action_special_attack:event_run( ... )
	-- body
	print('enter move')
	local attack_id, defence_id = ...
	if attack_id ~= self.unit_id then
		return
	end

	local defencer = unit_helper.get_unit(defence_id)
	if not defencer then
		print('action ' .. self.type .. ' defencer dead.')
		return
	end

	local left_hp = defencer:get_raw_attribute('hp')
	local damage = self.attacker:get_attribute('str') * 10

	if left_hp < damage then
		damage = left_hp
	end

	self.defencer:set_raw_attribute('hp', left_hp - damage)

	print('action ' .. self.type .. ' attacker:' .. self.unit_id .. ' attack defencer:' .. defence_id .. ' ' .. damage .. '.');
end

function action_special_attack:register_event_cb2( ... )
	-- body
	print('enter leave')
end

function action_special_attack:register_event()
	return {[common.ENTER_ATTACK] = action_move.event_run}
end