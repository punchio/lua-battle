local timer_mgr = require 'timer_mgr'
local skill_buff = {}
local skill_buff_data = {}

function skill_buff:init_data()
    skill_buff_data = {}

    local buff = {}
    buff.id = 1
    buff.type = 0
    buff.target = "return function() return get_closest_enemy() end"
    buff.total_time = 10
    buff.period_time = 2
    buff.create_effect = "return function() return add_hp(100) end"
    buff.destroy_effect = "return function() return add_hp(-100) end"
    buff.period_effect = "return function() return add_hp(10) end"
    self:init_default_data( buff )
    
    skill_buff_data[buff.id] = buff

    buff = {}
    buff.id = 2
    buff.type = 1
    buff.target = "return function() return get_self() end"
    buff.total_time = 10
    buff.period_time = 2
    buff.create_effect = "return function() return add_hp(200) end"
    buff.destroy_effect = "return function() return add_hp(-200) end"
    buff.period_effect = "return function() return add_hp(20) end"
    buff.replace_buff = {3}
	self:init_default_data( buff )

    skill_buff_data[buff.id] = buff

    buff = {}
    buff.id = 3
    buff.type = 1
    buff.target = "return function() return get_self() end"
    buff.total_time = 10
    buff.period_time = 2
    buff.create_effect = "return function() return add_hp(300) end"
    buff.destroy_effect = "return function() return add_hp(-300) end"
    buff.period_effect = "return function() return add_hp(30) end"
	self:init_default_data( buff )

    skill_buff_data[buff.id] = buff
end

--id	type	target	total time	interval time	create_effect	destroy_effect	period_effect
function skill_buff:init_default_data( buff_data )
	if not buff_data.type then buff_data.type = 0 end

	if buff_data.target then
		buff_data.target = Parse(buff_data.target)
	end
		
	buff_data.has_create_effect = buff_data.create_effect ~= nil
	buff_data.has_destroy_effect = buff_data.destroy_effect ~= nil
	buff_data.has_period_effect = buff_data.period_effect ~= nil
	buff_data.has_replace_buff = buff_data.replace_buff ~= nil

	if buff_data.has_create_effect then
		buff_data.create_effect = Parse(buff_data.create_effect)
	end

	if buff_data.has_destroy_effect then
		buff_data.destroy_effect = Parse(buff_data.destroy_effect)
	end

	if buff_data.has_period_effect == true then
		if not buff_data.period_time then
			buff_data.period_time = 1
		end
		buff_data.period_effect = Parse(buff_data.period_effect)
	end
end

function skill_buff:ctor(owner, skill_mgr)
    self.ptr = {}
    self.ptr.__mode = 'v'

    self.ptr.owner = owner
    self.ptr.skill_mgr = skill_mgr

    self.buff_bag = {}
end

function skill_buff:get_buff_data(buff_id)
    if not skill_buff_data then return nil end
    return skill_buff_data[buff_id]
end

--添加指定ID的buff
function skill_buff:add(buff_id)
	print('skill_buff add:', buff_id)
	local buff_data = self:get_buff_data(buff_id)
	print('skill_buff add1:', buff_data == nil)
    if not buff_data then return false end

    print('skill_buff add2:', buff_data.has_replace_buff)
    if buff_data.has_replace_buff then
    	for i, v in ipairs( buff_data.replace_buff ) do
    		self:remove(v)
    	end
    end

    local target = buff_data.target and buff_data.target(self.ptr.owner)
    print('skill_buff add3:', target == nil)

    self.buff_bag[buff_id] = self:create(buff_data)
    print('skill_buff add4:', self.buff_bag[buff_id].start_timer_id, ' ', self.buff_bag[buff_id].stop_timer_id)

    if buff_data.has_create_effect == true then
    	buff_data.create_effect(self.ptr.owner, target)
    	print('skill_buff add5:')
    end

	return 0
end

--移除指定ID的buff
function skill_buff:remove(buff_id)
	local buff_data = self:get_buff_data(buff_id)
    if not buff_data then return false end

	if buff_data.has_destroy_effect == true then
		local target = buff_data.target and buff_data.target(self.ptr.owner)
		buff_data.destroy_effect(self.ptr.owner, target)
	end

	local buff_obj = self.buff_bag[buff_id]
	if not buff_obj then return end

	if buff_obj.start_timer_id ~= 0 then 
		timer_mgr.remove(buff_obj.start_timer_id)
	end

	if buff_obj.stop_timer_id ~= 0 then 
		timer_mgr.remove(buff_obj.stop_timer_id)
	end

	self.buff_bag[buff_id] = nil
end

--移除指定类型的buff
function skill_buff:remove_by_type(buff_type)
	for id, obj in pairs( self.buff_bag ) do
		if obj.buff_data.type == buff_type then
			self:remove(id)
		end
	end
end

--创建buff参数
function skill_buff:create(buff_data)
	local buff_obj 	= {enabled = false, start_timer_id = 0, stop_timer_id = 0}

	buff_obj.buff_data = buff_data
	buff_obj.buff_data.__mode = 'v'

	if buff_data.has_period_effect then
		buff_obj.start_timer_id = timer_mgr.add_timer(self, skill_buff.active_periord_effect, 0, 0, buff_data.period_time, buff_data.id);
	end
	
	if buff_data.total_time ~= 0 then
		buff_obj.stop_timer_id = timer_mgr.add_timer(self, skill_buff.stop_timer, 1, buff_data.total_time, 0, buff_data.id)
	end

	return buff_obj
end

--停止buff
function skill_buff:stop_timer( timer_id, ... )
	local buff_id = ...
	self:remove(buff_id)
end

--激活周期效果
function skill_buff:active_periord_effect(timer_id, ...)
	local buff_id = ...

	local buff_data = self:get_buff_data(buff_id)
	if not buff_data then return end

	local buff_obj = self.buff_bag[buff_id]
	if not buff_obj then return end

	local target = buff_data.target and buff_data.target(self.ptr.owner)
	buff_data.period_effect(self.ptr.owner, target)
end

function skill_buff:get_remain_tick( buff_id )
	local buff_obj = self.buff_bag[buff_id]
	if not buff_obj then return 0 end

	if buff_obj.stop_timer_id == 0 then 
		return 'N/A'
	else
		return timer_mgr.get_remain_time(buff_obj.stop_timer_id)
	end
end

return skill_buff