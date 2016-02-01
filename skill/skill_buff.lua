local timer_mgr = require("timer_mgr")

-- 技能Buff

--消息提示，对应ChineseData.xml表定义
local TEXT_BUFF_UNKNOWN           = 1004001       --未知的Buff错误
local TEXT_BUFF_CANT_ADD          = 1004002       --不可添加Buff
local TEXT_BUFF_CANT_CREATE 	  = 1004003 	  --无法创建Buff


local skill_buff 				= {}
skill_buff.__index 		= skill_buff

local csv_skill_buff_data   = {}
function skill_buff.init_data()
    csv_skill_buff_data = parse_csv('CSVSkillBuff.csv') -- 读取csv
    if csv_skill_buff_data then
        for k, v in pairs(csv_skill_buff_data) do
            local buff_data = v
            if not buffd
            if not buff_data.total_time then buff_data.total_time = 0 end
            if not buff_data.remove_mode then buff_data.remove_mode = 0 end
            if not buff_data.notify_event then buff_data.notify_event = 0 end

            buff_data.exclude_buff    = self:init_default_list(buff_data.exclude_buff, 0, {}, true)
            buff_data.replace_buff    = self:init_default_list(buff_data.replace_buff, 0, {}, true)
            buff_data.append_state    = self:init_default_list(buff_data.append_state, 0, {}, true)

            self:check_active_skill_data(buff_data)
            self:check_attr_effect_data(buff_data)
        end
    else
    	csv_skill_buff_data = {}
    end
end

function skill_buff:init_default_list(org_list, min_size, default_list, is_nonzero)
    if not org_list then return default_list end
    if is_nonzero == true and #org_list == 1 and org_list[1] == 0 then org_list = {} end
    --if lua_util.get_table_real_count(org_list) < min_size then return default_list end
    return org_list
end

function skill_buff:check_active_skill_data(buff_data)
	local active_skill 		= buff_data.active_skill
	buff_data.active_skill 	= {}

	for tick, skill_id in pairs(active_skill) do
		if buff_data.total_time ~= 0 then
			if tick >= buff_data.total_time then break end
		end
		buff_data.active_skill[tick] = skill_id
	end
end

function skill_buff:check_attr_effect_data(buff_data)
	local attr_effect 		= buff_data.attr_effect
	buff_data.attr_effect 	= {}
	if not attr_effect then return end

	for k, v in pairs(attr_effect) do
		if v ~= 0 then
			buff_data.attr_effect[k] = v
		end
	end
end

function skill_buff:new(owner, skill_mgr)
	local new_obj    = {}
    new_obj.ptr      = {}
    setmetatable(new_obj,        {__index = skill_buff})
    setmetatable(new_obj.ptr,    {__mode = "v"})

    self.ptr.owner	= owner
    self.ptr.skill_mgr	= skill_mgr

    --技能Buff背包 key:buff_id val:timer_ids val:param]
    self.buff_bag 		= {}

    --属性影响
    self.attr_effect 	= {}

    --状态影响
    self.state_effect 	= {}

    return new_obj
end

function skill_buff:del()
	for buff_id, _ in pairs(self.buff_bag) do
		self.buff_bag = nil
	end
end

function skill_buff:on_die()
	for buff_id, _ in pairs(self.buff_bag) do
		local buff_data = self:get_buff_data(buff_id)
		if buff_data then
			self:remove(buff_id)
		end
	end
end

------------------------------------------------------------------------

--获取技能Buff对象，若不存在则返回nil
function skill_buff:get_buff_data(buff_id)
    if not csv_skill_buff_data then return nil end
    return csv_skill_buff_data[buff_id]
end

--判断身上是否存在指定的技能Buff，返回true/false
function skill_buff:has(buff_id)
	return self.buff_bag[buff_id] ~= nil
end

--获取技能Buff对象已过时间
function skill_buff:get_elapse_tick(buff_obj)
	local elapse_tick = mogo.getTickCount() - buff_obj.start_time.sys_tick
	if elapse_tick < 0 then elapse_tick = 0 end
	elapse_tick = elapse_tick + buff_obj.start_time.buff_tick
	return timer_mgr.now() - buff_obj.start_tick
end

--获取技能Buff剩余时间（返回负数代表无限期）
function skill_buff:get_remain_tick(buff_data, elapse_tick)
	if buff_data.total_time == 0 then return -1 end

	local remainTick = buff_data.total_time - elapse_tick

	if remainTick < 0 then remainTick = 0 end
	return remainTick
end

--把属性影响更新到表
function skill_buff:update_attr_effect_to(attrTable)
	for k, v in pairs(self.attr_effect) do
		if not attrTable[k] then
			attrTable[k] = v
		else
			attrTable[k] = attrTable[k] + v
		end
	end
	return attrTable
end

--获取单个属性影响值
function skill_buff:get_attr_effect(attrName)
	return self.attr_effect[attrName] or 0
end

--添加技能Buff，成功返回0
function skill_buff:add(buff_id)
    --log_game_debug("skill_buff:add", "buff_id=%s, elapse_tick=%s", buff_id, elapse_tick)

	local csv_buff_data = self:get_buff_data(buff_id)
    if not csv_buff_data then return TEXT_BUFF_UNKNOWN end

    if self:can_add(csv_buff_data) ~= true then return TEXT_BUFF_CANT_ADD end

	local owner 	= self.ptr.owner
    local buff_obj 	= self:create(csv_buff_data)
    if not buff_obj then return TEXT_BUFF_CANT_CREATE end

    --覆盖Buff
	for _, replace_buff_id in pairs(csv_buff_data.replace_buff) do
    	self:remove(replace_buff_id)
	end

    --把对象加入Buff背包
    self.buff_bag[buff_id] = buff_obj

    self:enable(buff_id)

	return 0
end

--移除Buff
function skill_buff:remove(buff_id)
    log_game_debug("skill_buff:remove", "buff_id=%s", buff_id)

	local buff_obj = self.buff_bag:find(buff_id)
	if not buff_obj then return end

	--删除停止定时器
	local owner = self.ptr.owner
	if buff_obj.stop_timer_id ~= 0 then
		owner:delLocalTimer(buff_obj.stop_timer_id)
		buff_obj.stop_timer_id = 0
	end

	--删除激活技能的定时器
	for _, timerID in pairs(buff_obj.skill_timer_ids) do
		owner:delLocalTimer(timerID)
	end

	self:disable(buff_id)

	self.buff_bag[buff_id] = nil
end


------------------------------------------------------------------------

--判断是否可以添加技能Buff，返回true/false
function skill_buff:can_add(buff_data)
	--检查是否存在互斥Buff
	for _, buff_id in pairs(buff_data.exclude_buff) do
		if self:has(buff_id) == true then return false end
	end

	return true
end

--创建Buff对象
function skill_buff:create(buff_data)
	local owner 	= self.ptr.owner
    local skill 	= self.ptr.skill
	local buff_obj 	= {start_time = timer_mgr.now(), stop_timer_id = 0, skill_timer_ids = {}}

	--设置停止定时器
	if buff_data.total_time > 0 then
    	local stop_timer_id 	= owner:addLocalTimer("ProcSkillBuffStopTimer", buff_data.total_time, 1, buff_data.id)
    	buff_obj.stop_timer_id = stop_timer_id
	end

	--设置激活技能的定时器
	for startTick, skillID in pairs(buff_data.active_skill) do
		if skill:GetSkill(skillID) then
    		local skillTimerID 	= owner:addLocalTimer("ProcSkillBuffTimer", startTick, 1, buff_data.id, skillID)
    		table.insert(buff_obj.skill_timer_ids, skillTimerID)
		end
	end

	return buff_obj
end

function skill_buff:enable( buff_id )
	local csv_buff_data = self:get_buff_data(buff_id)
	if not csv_buff_data then return end

    --加入属性效果
    self:update_attr_effect(csv_buff_data, true)

    --加入相关状态，待处理
    self:update_state_effect(csv_buff_data, true)
end

function skill_buff:disable( buff_id )
    local csv_buff_data = self:get_buff_data(buff_id)
    if not csv_buff_data then return end
    
    --移除属性效果
    self:update_attr_effect(csv_buff_data, false)

	--移除相关状态，待处理
    self:update_state_effect(csv_buff_data, false)
end

--更新属性效果
function skill_buff:update_attr_effect(buff_data, is_add)
	local buff_obj = self.buff_bag[buff_data.id]
	if not buff_obj then return end

	if buff_obj.effect_update == is_add then return end

	buff_obj.effect_update = is_add

	local changed = false
	for k, v in pairs(buff_data.attr_effect) do
		changed = true
		if is_add == false then v = -v end
		if not self.attr_effect:find(k) then
			self.attr_effect:insert(k, v)
		else
			self.attr_effect[k] = self.attr_effect[k] + v
			if self.attr_effect[k] == 0 then
				self.attr_effect:erase(k)
			end
		end
	end

	if changed == true then
		--self.ptr.owner:RecalculateBattleProperties() 重新计算属性
	end
end

--更新状态效果
function skill_buff:update_state_effect(buff_data, is_add)
	if #buff_data.append_state == 0 then return end

	local buff_obj = self.buff_bag[buff_data.id]
	if not buff_obj then return end

	if buff_obj.state_update == is_add then return end

	buff_obj.state_update = is_add

	if is_add == true then
		for _, state_id in pairs(buff_data.append_state) do
			if self.state_effect[state_id] then
				self.state_effect[state_id] = self.state_effect[state_id] + 1
			else
				self.state_effect[state_id] = 1
			end
		end
	else
		for _, state_id in pairs(buff_data.append_state) do
			if self.state_effect[state_id] then
				self.state_effect[state_id] = self.state_effect[state_id] - 1
				if self.state_effect[state_id] == 0 then
					self.state_effect[state_id] = nil
				end
			end
		end
	end

	--更新到属性
	local bitData 	= 0

	--针对死亡位进行or运算
	if Bit.Test(self.ptr.owner.state_flag, 0) then
		bitData = 1
	end

	for state_id, _ in pairs(self.state_effect) do
		bitData = Bit.Set(bitData, state_id)
	end

	self.ptr.owner.state_flag = bitData
end


------------------------------------------------------------------------

--处理停止定时器
function skill_buff:ProcSkillBuffStopTimer(timerID, activeCount, buff_id)
    log_game_debug("skill_buff:ProcSkillBuffStopTimer", "buff_id=%s", buff_id)

	self:destroy(buff_id)
end

--处理激活技能的定时器
function skill_buff:ProcSkillBuffTimer(timerID, activeCount, buff_id, skillID)
    log_game_debug("skill_buff:ProcSkillBuffTimer", "buff_id=%s, skillID=%s", buff_id, skillID)

    self.ptr.skill:OnBuffExecuteSkill(skillID)
end








return skill_buff