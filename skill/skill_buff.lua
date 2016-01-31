local timer_mgr = require 'timer_mgr'
local skill_buff = {}
local skill_buff_data = {}

function skill_buff:init_data()
    skill_buff_data = {}
    --one buff data: type, last time, affect attributes, active actions
end

function skill_buff:ctor(owner, skill_mgr)
    self.ptr = {}
    self.ptr__mode = 'v'

    self.ptr.owner = owner
    self.ptr.skill_mgr = skill_mgr

    self.buff_bag = {}

    self.attr_effect = {}

    self.state_effect = {}
end

function skill_buff:get_buff_data(buff_id)
    if not skill_buff_data then return nil end
    return skill_buff_data[buff_id]
end

function skill_buff:test_buff( buff_data, mode )
	return true
end

function skill_buff:create(buff_data)
	local owner 	= self.ptr.owner
	local buff_obj 	= {enabled = false, stop_timer_id = 0, skill_timer_ids = {}, effect_ids = {}}
	local time_now = timer_mgr.now()

	buff_obj.stop_timer_id = timer_mgr.add_timer(self, skill_buff.stop_timer, 1, buff_data.total_time, 0, buff_data.id)

	for start_tick, skill_id in pairs(buff_data.active_skill) do
		if skill:has_skill(skill_id) then
			local timer_id = timer_mgr.add_timer(self, skill_buff.active_skill, 1, start_tick, 0, buff_data.id, skill_id)
			table.insert(buff_obj.skill_timer_ids, timer_id) 
		end
	end

	return buff_obj
end

function skill_buff:active_skill_timer(timer_id, ...)
	local buff_id, skill_id = ...

	local buff_obj = self.buff_bag[buff_id]
	if not buff_obj then return end

	if buff_obj.enabled then
		self.ptr.skill_mgr:execute_buff_skill(skill_id)
	end
end

function skill_buff:stop_timer( timer_id, ... )
	local buff_id = ...
	self:remove(buff_id)
end

function skill_buff:add(buff_id)
	local raw_buff_data = self:get_buff_data(buff_id)
    if not raw_buff_data then return false end

    if not self:test_buff(raw_buff_data) then return false end

    self.buff_bag[buff_id] = self:create(raw_buff_data)

    self:enable(buff_id)

	return 0
end

--移除Buff
function skill_buff:remove(buff_id)
	self:disable(buff_id)

	local buff_obj = self.buff_bag[buff_id]
	if not buff_obj then return end

	if buff_obj.stop_timer_id ~= 0 then 
		timer_mgr.remove(buff_obj.stop_timer_id)
	end
	
	if #buff_obj.skill_timer_ids ~= 0 then
		for _, timer_id in ipairs(buff_obj.skill_timer_ids) do
			timer_mgr.remove(timer_id)
		end
	end

	self.buff_bag[buff_id] = nil
end

function skill_buff:enable( buff_id )
	local raw_buff_data = self:get_buff_data(buff_id)
	if not raw_buff_data then return end

	local buff_obj = self.buff_bag[buff_id]
	if not buff_obj then return end

	buff_obj.enabled = true

	for k, v in ipairs( raw_buff_data.affect_attr ) do
		self.prt.owner:get_attribute(k)
		table.insert(buff_obj.effect_ids, self.unit:add_attr_buff(k, v[1], v[2], v[3]))
		self.prt.owner:get_attribute(k)
	end
end

function skill_buff:disable( buff_id )
    local buff_obj = self.buff_bag[buff_id]
	if not buff_obj then return end

    self.prt.owner:get_attribute('str')
	for _, v in ipairs( buff_obj.effect_ids ) do
		self.unit:remove_attr_buff(v)
	end
	self.prt.owner:get_attribute('str')

    buff_obj.enabled = false
end

return skill_buff