require('log')

local timer_mgr = require 'timer_mgr'
local skill_buff = {}
local skill_buff_data = {}
local battle_details = require('battle_details')

function skill_buff:init_data()
    skill_buff_data = {}

    local buff = {}
    buff.id = 1
    buff.type = 0
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
    buff.total_time = 10
    buff.period_time = 2
    buff.create_effect = "return function() return add_hp(300) end"
    buff.destroy_effect = "return function() return add_hp(-300) end"
    buff.period_effect = "return function() return add_hp(30) end"
	self:init_default_data( buff )

	buff = {}
    buff.id = 4
    buff.type = 0
    buff.total_time = 0
    buff.period_time = 1
    buff.period_effect = 'effects/skill_effect_attack.lua'
    --buff.period_effect = 'return function() if not is_idle() then return end; local tar = get_closest_enemy(); if not tar then return end; add_hp(-30, tar); end' 
	self:init_default_data( buff )

	buff = Parse_tbl('effects/buff_example.lua')
	buff.id = 5
	log_print('detail', type(buff))
	for k,v in pairs(buff) do
		print(k,v)
	end

	--self:init_default_data(buff)

    skill_buff_data[buff.id] = buff
end

--id	type	total time	interval time	create_effect	destroy_effect	period_effect
function skill_buff:init_default_data( buff_data )
	if not buff_data.type then buff_data.type = 0 end
		
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
	log_print('detail', 'skill_buff add buff:', buff_id, '|owner:', self.ptr.owner.id)
	local buff_data = self:get_buff_data(buff_id)
    if not buff_data then 
    	log_print('warning', 'skill_buff add buff:', buff_id, ' not exist.')
    	return false 
    end

    battle_details.add(self.ptr.owner.id, 'buff', 'add', buff_id)

    log_print('detail', 'skill_buff add buff:', buff_id, '|has replace buff:', buff_data.has_replace_buff)
    if buff_data.has_replace_buff then
    	for i, v in ipairs( buff_data.replace_buff ) do
    		self:remove(v)
    	end
    end

    self.buff_bag[buff_id] = self:create(buff_data)
    log_print('detail', 'skill_buff add buff:', buff_id, '|start timer:', self.buff_bag[buff_id].start_timer_id,
     '|stop timer:', self.buff_bag[buff_id].stop_timer_id)

    if buff_data.has_create_effect == true then
    	log_print('detail', 'skill_buff add buff:', buff_id, ', run create effect.')
    	buff_data.create_effect(self.ptr.owner)
    else
        log_print('detail', 'skill_buff add buff:', buff_id, ' has no create effect.')
    end

	return true
end

--移除指定ID的buff
function skill_buff:remove(buff_id)
	local buff_data = self:get_buff_data(buff_id)
	log_print('detail', 'skill_buff remove buff:', buff_id, '|owner:', self.ptr.owner.id)
    if not buff_data then 
    	log_print('detail', 'skill_buff remove buff:', buff_id, ' not exist.')
    	return false 
    end

	local buff_obj = self.buff_bag[buff_id]
	if not buff_obj then
		log_print('warning', 'skill_buff remove buff:', buff_id, ', dont have this buff.')
		return false
	end

	battle_details.add(self.ptr.owner.id, 'buff', 'remove', buff_id)

	if buff_data.has_destroy_effect == true then
		log_print('detail', 'skill_buff remove buff:', buff_id, ', run destroy effect.')
		buff_data.destroy_effect(self.ptr.owner)
	else
	    log_print('detail', 'skill_buff remove buff:', buff_id, ' has no destroy effect.')
	end

	if buff_obj.start_timer_id ~= 0 then
		log_print('detail', 'skill_buff remove buff:', buff_id, ', remove start timer:', buff_obj.start_timer_id)
		timer_mgr.remove(buff_obj.start_timer_id)
	end

	if buff_obj.stop_timer_id ~= 0 then 
		log_print('detail', 'skill_buff remove buff:', buff_id, ', remove stop timer:', buff_obj.stop_timer_id)
		timer_mgr.remove(buff_obj.stop_timer_id)
	end

	self.buff_bag[buff_id] = nil
	return true
end

--移除指定类型的buff
function skill_buff:remove_by_type(buff_type)
	log_print('detail', 'skill_buff remove buff type:', buff_type)
	for id, obj in pairs( self.buff_bag ) do
		if obj.buff_data.type == buff_type then
			self:remove(id)
		end
	end
end

--创建buff参数
function skill_buff:create(buff_data)
	log_print('detail', 'skill_buff create buff data:', buff_data.id)
	local buff_obj 	= {enabled = false, start_timer_id = 0, stop_timer_id = 0}

	buff_obj.buff_data = buff_data
	buff_obj.buff_data.__mode = 'v'

	if buff_data.has_period_effect then
		buff_obj.start_timer_id = timer_mgr.add_timer(self, skill_buff.active_period_effect, 0, 0, buff_data.period_time, buff_data.id);
		log_print('detail', 'skill_buff create buff data:', buff_data.id, '|start timer id:', buff_obj.start_timer_id)
	end
	
	if buff_data.total_time ~= 0 then
		buff_obj.stop_timer_id = timer_mgr.add_timer(self, skill_buff.stop_timer, 1, buff_data.total_time, 0, buff_data.id)
		log_print('detail', 'skill_buff create buff data:', buff_data.id, '|stop timer id:', buff_obj.stop_timer_id)
	end

	return buff_obj
end

--停止buff
function skill_buff:stop_timer( timer_id, ... )
	local buff_id = ...
	log_print('detail', 'skill_buff stop timer:', timer_id, '|buff id:', buff_id)
	self:remove(buff_id)
end

--激活周期效果
function skill_buff:active_period_effect(timer_id, ...)
	local buff_id = ...
	log_print('detail', 'skill_buff active period effect:', timer_id, '|buff id:', buff_id)
	local buff_data = self:get_buff_data(buff_id)
	if not buff_data then
		log_print('error', 'skill_buff active period effect, buff id not exist.')
		return
	end

	local buff_obj = self.buff_bag[buff_id]
	if not buff_obj then 
		log_print('error', 'skill_buff active period effect, buff obj not exist.')
		return 
	end
	log_print('detail', 'skill_buff active period effect:', timer_id, '|buff id:', buff_id, '|owner:', self.ptr.owner.id, '|run period effect.')

	buff_data.period_effect(self.ptr.owner, target)
end

--not using
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