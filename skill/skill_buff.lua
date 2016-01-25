
-- 技能Buff
local skill_buff_data   = {}


local NOTIFY_EVENT_VIP_LEVEL  	  = 1			  --VIP等级通知事件


--消息提示，对应ChineseData.xml表定义
local TEXT_BUFF_UNKNOWN           = 1004001       --未知的Buff错误
local TEXT_BUFF_CANT_ADD          = 1004002       --不可添加Buff
local TEXT_BUFF_CANT_CREATE 	  = 1004003 	  --无法创建Buff


skill_buff 				= {}
skill_buff.__index 		= skill_buff

function skill_buff:InitData()
    skill_buff_data = parse_csv() -- 读取csv
    if skill_buff_data then
        for k, v in pairs(skill_buff_data) do
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
    	skill_buff_data = {}
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
	buff_data.attr_effect 	= lua_map:new()
	if not attr_effect then return end

	for k, v in pairs(attr_effect) do
		if v ~= 0 then
			buff_data.attr_effect[k] = v
		end
	end
end

function skill_buff:ctor(owner, skill)
    self.ptr      = {}
    setmetatable(self.ptr,    {__mode = "v"})

    self.ptr.owner	= owner
    self.ptr.skill	= skill

    --技能Buff背包
    self.buff_bag 		= {}

    --属性影响
    self.attr_effect 	= {}

    --状态影响
    self.state_effect 	= {}
end

function skill_buff:del()
	for buff_id, _ in pairs(self.buff_bag) do
		self:remove(buff_id)
	end
end

function skill_buff:on_die()
	for buff_id, _ in pairs(self.buff_bag) do
		local buff_data = self:get_buff_data(buff_id)
		if buff_data.remove_mode == 1 then
			self:remove(buff_id)
		end
	end
end

------------------------------------------------------------------------

--获取技能Buff对象，若不存在则返回nil
function skill_buff:get_buff_data(buff_id)
    if not skill_buff_data then return nil end
    return skill_buff_data[buff_id]
end

--判断身上是否存在指定的技能Buff，返回true/false
function skill_buff:has(buff_id)
	return (self.buff_bag:find(buff_id) ~= nil)
end

--获取技能Buff对象已过时间
function skill_buff:get_elapse_tick(buff)
	local elapse_tick = mogo.getTickCount() - buff.start_time.sys_tick
	if elapse_tick < 0 then elapse_tick = 0 end
	elapse_tick = elapse_tick + buff.start_time.buff_tick
	return elapse_tick
end

--获取技能Buff剩余时间（返回负数代表无限期）
function skill_buff:get_remain_tick(buff_data, create_time, elapse_tick)
	if buff_data.total_time == 0 then return -1 end

	local remainTick = buff_data.total_time - elapse_tick
	if buff_data.saveDB == 1 then
		--按绝对时间计算
		remainTick = buff_data.total_time - (os.time() - create_time) * 1000
	end
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
function skill_buff:add(buff_id, create_time, elapse_tick)
	create_time = create_time or os.time()
    elapse_tick = elapse_tick or 0
    --log_game_debug("skill_buff:add", "buff_id=%s, elapse_tick=%s", buff_id, elapse_tick)

	local buff_data = self:get_buff_data(buff_id)
    if not buff_data then return TEXT_BUFF_UNKNOWN end

    if self:can_add(buff_data) ~= true then return TEXT_BUFF_CANT_ADD end

	local owner 	= self.ptr.owner
    local buff 	= self:create(buff_data, create_time, elapse_tick)
    if not buff then return TEXT_BUFF_CANT_CREATE end

    --移除自身相同Buff
    self:remove(buff_id)

    --覆盖Buff
	for _, replace_buff_id in pairs(buff_data.replace_buff) do
    	self:remove(replace_buff_id)
	end

    --加入属性效果
    self:update_attr_effect(buff_data, true)

    --加入相关状态，待处理
    self:update_state_effect(buff_data, true)

    --把对象加入Buff背包
    self.buff_bag:insert(buff_id, buff)

    --通知事件：开始
    self:NotifyEvent_Start(buff_data)

    --视野广播
    local remainTick = self:get_remain_tick(buff_data, create_time, elapse_tick)
    if remainTick < 0 then remainTick = 0 end
    owner:broadcastAOI(true, "SkillBuffResp", owner:getId(), buff_id, 1, remainTick)
    self:UpdateBuffToClient(buff_data, true)

    log_game_debug("skill_buff:add", "OK! buff_id=%s", buff_id)

	return 0
end

--移除Buff
function skill_buff:remove(buff_id)
    log_game_debug("skill_buff:remove", "buff_id=%s", buff_id)

	local buff = self.buff_bag:find(buff_id)
	if not buff then return end

	--删除停止定时器
	local owner = self.ptr.owner
	if buff.stop_timer_id ~= 0 then
		owner:delLocalTimer(buff.stop_timer_id)
		buff.stop_timer_id = 0
	end

	--删除激活技能的定时器
	for _, timerID in pairs(buff.skill_timer_ids) do
		owner:delLocalTimer(timerID)
	end

	self:Destory(buff_id)
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
function skill_buff:create(buff_data, create_time, elapse_tick)
	local stop_tick = self:get_remain_tick(buff_data, create_time, elapse_tick)
	if stop_tick == 0 then return nil end

	local owner 	= self.ptr.owner
    local skill 	= self.ptr.skill
	local start_time = {create_time = create_time, sys_tick = mogo.getTickCount(), buff_tick = elapse_tick}
	local buff 	= {start_time = start_time, stop_timer_id = 0, skill_timer_ids = {}}

	--设置停止定时器
	if buff_data.total_time > 0 and stop_tick > 0 then
    	local stop_timer_id 	= owner:addLocalTimer("ProcSkillBuffStopTimer", stop_tick, 1, buff_data.id)
    	buff.stop_timer_id = stop_timer_id
	end

	--设置激活技能的定时器
	for startTick, skillID in pairs(buff_data.active_skill) do
		if startTick >= elapse_tick then
			local skillTick = startTick - elapse_tick
			if skill:GetSkill(skillID) then
	    		local skillTimerID 	= owner:addLocalTimer("ProcSkillBuffTimer", skillTick, 1, buff_data.id, skillID)
	    		table.insert(buff.skill_timer_ids, skillTimerID)
			end
		end
	end

	return buff
end

--删除Buff
function skill_buff:Destory(buff_id)
  	local owner 	= self.ptr.owner

    log_game_debug("skill_buff:Destory", "buff_id=%s", buff_id)

	--移除属性效果
    local buff_data = self:get_buff_data(buff_id)
    self:update_attr_effect(buff_data, false)

	--移除相关状态，待处理
    self:update_state_effect(buff_data, false)

    --移除Buff背包中的对象
    self.buff_bag:erase(buff_id)

    --通知事件：停止
    self:NotifyEvent_Stop(buff_data)

    --视野广播
    owner:broadcastAOI(true, "SkillBuffResp", owner:getId(), buff_id, 0, 0)
    self:UpdateBuffToClient(buff_data, false)
end

function skill_buff:NotifyEvent_Start(buff_data)
	if buff_data.notifyEvent == 1 then
  		local owner 		= self.ptr.owner
  		if owner.c_etype ~= public_config.ENTITY_TYPE_AVATAR then return end

		local maxVipLevel 	= self:GetMaxVipLevel()
		owner.base.VipBuffNoitfy(0, maxVipLevel)
	else
		return
	end
end

function skill_buff:NotifyEvent_Stop(buff_data)
	if buff_data.notifyEvent == 1 then
  		local owner 		= self.ptr.owner
  		if owner.c_etype ~= public_config.ENTITY_TYPE_AVATAR then return end

		local maxVipLevel 	= self:GetMaxVipLevel()
		owner.base.VipBuffNoitfy(1, maxVipLevel)
	else
		return
	end
end

--更新属性效果
function skill_buff:update_attr_effect(buff_data, is_add)
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

	self:Destory(buff_id)
end

--处理激活技能的定时器
function skill_buff:ProcSkillBuffTimer(timerID, activeCount, buff_id, skillID)
    log_game_debug("skill_buff:ProcSkillBuffTimer", "buff_id=%s, skillID=%s", buff_id, skillID)

    self.ptr.skill:OnBuffExecuteSkill(skillID)
end








