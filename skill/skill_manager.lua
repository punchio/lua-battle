require("new")
local timer_mgr = require("timer_mgr")
local skill_action = require("skill_action")
local skill_buff = require("skill_buff")

local skill_skill_mgr = {}

local csv_skill_data = {}
function skill_mgr.init_data()
	csv_skill_data = parse(CSVSkill)

	skill_action.init_data()
	skill_buff.init_data()
end

function skill_mgr.new(owner)
	print("skill_mgr.new, entity id:" .. owner.id)

    local obj    = {}
    obj.ptr      = {}
    setmetatable(obj,        {__index = SkillSystem})
    setmetatable(obj.ptr,    {__mode = "v"})

	-- body
	    --技能使用记录
    obj.skill_record          = {last_skill_id = 0, last_skill_count = 0, last_time_tick = 0}

    --技能行为
    obj.skill_action          = skill_action.new(owner, obj)

    --技能Buff
    obj.skill_buff            = skill_buff.new(owner, obj)

    --技能背包
    obj.skill_bag             = skill_bag.new(owner, obj)

    --技能配置表 
    obj.csv_skill_data            = csv_skill_data

    return obj
end

--获取技能对象，若不存在则返回nil
function skill_mgr:get_skill(skill_id)
    if not csv_skill_data then return nil end
    return csv_skill_data[skill_id]
end

function skill_mgr:test_skill(test_mode, csv_skill_data, param1)
	--CD时间测试
    if test_mode == SKILL_TEST_COLDDOWN then
        local last_skill_id   = self.skill_record.last_skill_id
        local last_skill_data = self:get_skill(last_skill_id)
        if not last_skill_data then
            self.skill_record.last_skill_id = 0
        else
            local now_skill_id    = csv_skill_data.id
            local now_tick       = param1
            if not now_tick then now_tick = timer_mgr.now() end
            if last_skill_id ~= 0 then
                --最少CD限制为100毫秒
                local elapsed_tick = now_tick - self.skill_record.last_time_tick
                if elapsed_tick < 100 then return TEXT_SKILL_COLDDOWN_LIMIT end

                --自身技能CD
                local self_elapsed_tick = now_tick - self.skill_bag:get_cast_tick(csv_skill_data)
                if self_elapsed_tick < csv_skill_data.cd then return TEXT_SKILL_COLDDOWNING end
            end
        end

        return 0

    --检查技能是否已习得
    elseif test_mode == SKILL_TEST_HAS_LEARNED then
        if self.skill_bag:has(csv_skill_data.id) ~= true then
            return TEXT_SKILL_NOT_LEARN
        else
            return 0
        end

    --检查施法者死亡状态
    elseif test_mode == SKILL_TEST_CASTER_DEATH then
        local owner = self.ptr.owner
        if owner:is_dead() then return TEXT_SKILL_CASTER_DEATH end

        return 0

    --施法距离测试
    elseif test_mode == SKILL_TEST_RANGE then
        local target = param1
        if not target or not target.getId or not target.GetScaleRadius then return TEXT_SKILL_RANGE_OBJECT_ILLEGAL end

        if csv_skill_data.castRange ~= 0 then
            local owner = self.ptr.owner
            local distance = math.floor(owner:getDistance(target:getId()))
            target:GetScaleRadius()
            owner:GetScaleRadius()
            local entity_r = target:GetScaleRadius() + owner:GetScaleRadius()
            if csv_skill_data.castRange + entity_r < distance then
                return TEXT_SKILL_OUT_OF_RANGE
            end
        end

        return 0
    end
end

--施放技能
function skill_mgr:cast_skill(csv_skill_data, targets)
    local owner  = self.ptr.owner
    local skill_action = self.skill_action
    
    local idx = 0
    for i, action_id in ipairs(csv_skill_data.skill_action) do
        skill_action:cast(csv_skill_data, idx, action_id, 0, targets)
        idx = idx + 1
    end
end

function skill_mgr:use_skill(skill_id, targets, client_tick)
    log_game_debug("skill_mgr:use_skill", "skill_id=%s, client_tick=%s", skill_id, client_tick)
    
    local csv_skill_data = self:get_skill(skill_id)
    if not csv_skill_data then
        print('skill_mgr:use_skill skill not exist.')
        return
    end

    local ret

    --检查施法者死亡状态
    ret = self:test_skill(SKILL_TEST_CASTER_DEATH, csv_skill_data)
    if ret ~= 0 then
        print('skill_mgr:use_skill caster dead.')
        return
    end

    --检查技能是否已习得
    ret = self:test_skill(SKILL_TEST_HAS_LEARNED, csv_skill_data)
    if ret ~= 0 then
        print('skill_mgr:use_skill owner doesnt have this skill.' .. skill_id)
        return
    end

    ----检查是否加速
    --local S1E = mogo.getTickCount()
    --ret = owner:VerifyTick(0, S1E, client_tick)
    --if ret == false then
    --    owner:ShowTextID(CHANNEL.TIPS, TEXT_SKILL_TICK_ILLEGAL)
    --    return
    --end

    --检查CD时间
    ret = self:test_skill(SKILL_TEST_COLDDOWN, csv_skill_data, client_tick)
    if ret ~= 0 then
        self:DebugShowTextID(CHANNEL.DBG, ret)
        return
    end

    --解析目标
    targets = self:ParseTagerts(targets)

    --标记使用技能的时间
    self:mark_time(csv_skill_data, client_tick)

    --施放技能
    self:cast_skill(csv_skill_data, targets)
end