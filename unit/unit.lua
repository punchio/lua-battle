require("new")

local unit = {}

local attribute_type = {
	side = 0,
	maxhp = 1,
	hp = 2,
	str = 3,
	vel = 4,
	pos = 5,
	move = 6,
	attack_range = 7,
	attack = 8,
	defence = 9,
	skill	= 10,
	spell	= 11,
	attack_speed = 12,
	attack_time = 13,
	state_id = 14,
	spelling_time = 15,
	alive_time = 16,
	dead_time = 17,
	ai = 18,
	['auto-attack'] = 19,
}

function unit:ctor(...)
	-- body
	self.id = ...
	self.free_buff_id = 1
	self.buffs = {}
	self.attribute = {}
	--t.buff_attribute = {}
	print('unit ctor id:' .. self.id)
end

function unit:set_raw_attribute(attr, value)
	-- body
	if not attribute_type[attr] then
		print('nil attribute:' .. attr)
		return
	end

	self.attribute[attr] = value

	local value_str
	if not value then
		value_str = ''
	elseif type(self.attribute[attr]) == 'table' then
		value_str = ''
		for _, v in pairs( self.attribute[attr] ) do
			value_str = value_str .. v .. ' '
		end
	else
		value_str = self.attribute[attr]
	end

	--print('unit set raw attribute id:' .. self.id .. 
	--	'|attr:' .. attr .. 
	--	'|value:' .. value_str)
end

function unit:get_raw_attribute(attr)
	-- body
	local value_str
	if not self.attribute[attr] then
		value_str = 'nil'
	elseif type(self.attribute[attr]) == 'table' then
		value_str = ''
		for _, v in pairs( self.attribute[attr] ) do
			value_str = value_str .. v .. ' '
		end
	else
		value_str = self.attribute[attr]
	end
	--print('unit get raw attribute id:' .. self.id .. 
	--	'|attr:' .. attr .. 
	--	'|value:' .. value_str)
	return self.attribute[attr]
end

function unit:get_attribute(attr)
	-- body
	--[[
	local at_buff = self.buffs[attr]
	local base_value = self.attribute[attr]
	local base_percent = 1.0
	local total_percent = 1.0
	local ret_value
	if not base_value then
		ret_value = nil
	elseif not at_buff then
		ret_value = base_value
	else
		for _,v in pairs(at_buff) do
			if v.change_type == "base_value" then
				base_value = base_value + v.change_value
			elseif v.change_type == "base_percent" then
				base_percent = base_percent + v.change_value
			elseif v.change_type == "total_percent" then
				total_percent = total_percent * (1.0 + v.change_value)
			end
		end
		ret_value = base_value * base_percent * total_percent
	end
	--]]

	local base_value = self.attribute[attr]
	local base_percent = 1.0
	local total_percent = 1.0
	local ret_value
	if not base_value then
		ret_value = nil
	elseif not self.buffs then
		ret_value = base_value
	else
		for _,v in pairs(self.buffs) do
			if v.attr ~= attr then
				-- dont add
			elseif v.change_type == "base_value" then
				base_value = base_value + v.change_value
			elseif v.change_type == "base_percent" then
				base_percent = base_percent + v.change_value
			elseif v.change_type == "total_percent" then
				total_percent = total_percent * (1 + v.change_value)
			end
		end
		ret_value = base_value * base_percent * total_percent
	end

	print('unit get attribute id:' .. self.id .. 
		'|attr:' .. attr .. 
		'|base_value:' .. base_value ..
		'|base_percent:' .. base_percent ..
		'|total_percent:' .. total_percent ..
		'|value:' .. ret_value)

	return ret_value
end

function unit:add_attr_buff(attr, change_type, change_value)
	-- body
	print('unit add attr buff, unit id:' .. self.id .. 
		'|attr:' .. attr .. 
		'|change type:' .. change_type .. 
		'|change value:' .. change_value)
	local buff = {}
	buff.id, self.free_buff_id = self.free_buff_id, self.free_buff_id + 1
	buff.attr = attr
	buff.change_type = change_type
	buff.change_value = change_value
	--[[
	local at_buff = self.buffs[attr]
	if not at_buff then
		at_buff = {}
		self.buffs[attr] = at_buff
	end
	at_buff[action_id] = buff
	--]]
	self.buffs[buff.id] = buff

	return buff.id
end

function unit:remove_attr_buff( buff_id )
	-- body
	print('unit remove attr buff id:' .. self.id ..
		'|buff id:' .. buff_id)
	--[[
	for _, v in pairs( self.buffs ) do
		print('unit remove attr buff id:' .. v.id ..
			'|attr:' .. v.attribute ..
			'|change type:' .. v.change_type .. 
			'|change value:' .. v.change_value)
		table.remove(v, action_id)
	end
	--]]
	self.buffs[buff_id] = nil
end

function unit:clear_state()
	-- body
	self.attribute['move'] = nil
	self.attribute['attack'] = 0
	self.attribute['spell'] = 0
end

return unit