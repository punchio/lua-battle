--消息提示，对应ChineseData.xml表定义
local TEXT_ACTION_UNKNOWN           = 1003001       --未知的技能行为错误
local TEXT_ACTION_NOT_EXIST         = 1003002       --技能行为不存在
local TEXT_ACTION_CASTER_DEATH      = 1003003       --执行者已死亡
local TEXT_ACTION_NOT_EXECUTE       = 1003004       --技能行为无需执行
local TEXT_ACTION_NO_TARGETS        = 1003005       --没找到有效的目标
local TEXT_ACTION_NOT_IN_AREA       = 1003006       --目标不在范围内
local TEXT_ACTION_FIND_NO_TARGETS   = 1003007       --找不到目标
local TEXT_ACTION_NO_HIT_STATE      = 1003008       --不可攻击状态
local TEXT_ACTION_NOT_IN_AOI        = 1003009       --不在AOI范围内


--技能行为测试模式
ACTION_TEST_NEED_EXECUTE      = 1             --检查技能行为是否需要执行实现
ACTION_TEST_CASTER_DEATH      = 2             --检查施法者死亡状态
ACTION_TEST_TARGET_DEATH      = 3             --检查目标死亡状态
ACTION_TEST_TARGET_IN_AREA    = 4             --检查目标是否在目标范围内
ACTION_TEST_CAN_HIT_STATE     = 5             --检查是否可攻击状态
ACTION_TEST_IN_AOI            = 6             --检查是否在AOI内

--目标范围
local TARGET_RANGE =
{
    SECTOR          = 0,    --扇形范围
    ROUND           = 1,    --圆形范围
    SINGLE          = 2,    --单体范围
    LINE            = 3,    --直线范围
    FACE            = 4,    --面向（前方）范围
    FRONT_ROUND     = 5,    --前方一段距离的圆形范围
    WORLD_RECT      = 6,    --世界矩形坐标
}

local skill_action = {}
skill_action.__index = skill_action

local csv_skill_action_data         = {}

function skill_action.init_data()
	csv_skill_action_data = parse_csv('CSVSkillAction.csv') -- 读取csv
    if csv_skill_action_data then
        for k, v in pairs(csv_skill_action_data) do
            local action_data = v
            if not action_data.max_target_count then action_data.max_target_count = 0 end
            if not action_data.target_range_type then action_data.target_range_type = 1 end
            if not action_data.cast_pos_type then action_data.cast_pos_type = 0 end
            if not action_data.begin_duration then action_data.begin_duration = 0 end
            if not action_data.end_duration then action_data.end_duration = 0 end

            if not action_data.damage_flag then action_data.damage_flag = 0 end
            if not action_data.cure_flag then action_data.cure_flag = 0 end
            if not action_data.spawn_flag then action_data.spawn_flag = 0 end
            if not action_data.shift_flag then action_data.shift_flag = 0 end
        end
    else
    	csv_skill_action_data = {}
    end
end

function skill_action:new(owner, skill_mgr)
    local new_obj    = {}
    new_obj.ptr      = {}
    setmetatable(new_obj,        {__index = skill_action})
    setmetatable(new_obj.ptr,    {__mode = "v"})

    new_obj.ptr.owner	= owner
    new_obj.ptr.skill_mgr	= skill_mgr

    return new_obj
end

function skill_action:test_action( test_mode, param1, param2 )
    local owner = self.ptr.owner

    --检查技能行为是否需要执行实现
    if test_mode == ACTION_TEST_NEED_EXECUTE then
        local action_data = param1
        if action_data.need_execute == true then return 0 end

        return TEXT_ACTION_NOT_EXECUTE

    --检查施法者死亡状态
    elseif test_mode == ACTION_TEST_CASTER_DEATH then
        if owner:is_dead() then return TEXT_ACTION_CASTER_DEATH end

        return 0

    elseif test_mode == ACTION_TEST_IN_AOI then
        local target = param1
        if owner:in_AOI(target:getId()) == false then return TEXT_ACTION_NOT_IN_AOI end

        return 0

    --检查目标死亡状态
    elseif test_mode == ACTION_TEST_TARGET_DEATH then
        local target = param1
        if not target or not target.is_dead or target:is_dead() then return TEXT_ACTION_CASTER_DEATH end

        return 0

    --检查是否可攻击状态
    elseif test_mode == ACTION_TEST_CAN_HIT_STATE then
        local target = param1
        if not target or not target.stateFlag or Bit.Test(target.stateFlag, state_config.NO_HIT_STATE) then return TEXT_ACTION_NO_HIT_STATE end

        return 0
    
    --检查目标是否在施法区域内
    elseif test_mode == ACTION_TEST_TARGET_IN_AREA then
        local action_data = param1
        local target     = param2
        if not target then return TEXT_ACTION_NOT_IN_AREA end

        local p1     = action_data.targetRangeParam[1] or 0
        local p2     = action_data.targetRangeParam[2] or 0
        local p3     = action_data.targetRangeParam[3] or 0
        local p4     = action_data.targetRangeParam[4] or 0
        local x2, y2 = target:getXY()
        local x1, y1, face1
        if action_data.castPosType == 1 then
            x1, y1  = owner:getXY()
            face1   = owner:getFace()
        elseif action_data.castPosType == 2 then
            x1      = self.theParams.targetPos.x
            y1      = self.theParams.targetPos.y
            face1   = self.theParams.targetPos.face
        else
            x1      = self.theParams.castPos.x
            y1      = self.theParams.castPos.y
            face1   = self.theParams.castPos.face
        end

        if action_data.targetRangeType == TARGET_RANGE.SECTOR then
            if SkillCalculate.TestInSector(x1, y1, face1, x2, y2, p1, p2) ~= true then return TEXT_ACTION_NOT_IN_AREA end
        elseif action_data.targetRangeType == TARGET_RANGE.ROUND then
            if SkillCalculate.GetDistance(x1, y1, x2, y2) > p1 then return TEXT_ACTION_NOT_IN_AREA end
        elseif action_data.targetRangeType == TARGET_RANGE.LINE then
            if SkillCalculate.TestInRectangle(x1, y1, face1, x2, y2, p1, p2) ~= true then return TEXT_ACTION_NOT_IN_AREA end
        elseif action_data.targetRangeType == TARGET_RANGE.FACE then
            if SkillCalculate.TestInSector(x1, y1, face1, x2, y2, p1, 180) ~= true then return TEXT_ACTION_NOT_IN_AREA end
        elseif action_data.targetRangeType == TARGET_RANGE.FRONT_ROUND then
            local x0, y0 = SkillCalculate.GetFrontPosition(x1, y1, face1, p1)
            if SkillCalculate.GetDistance(x0, y0, x2, y2) > p2 then return TEXT_ACTION_NOT_IN_AREA end
        elseif action_data.targetRangeType == TARGET_RANGE.WORLD_RECT then
            if SkillCalculate.TestInWorldRectangle(x2, y2, p1, p2, p3, p4) ~= true then return TEXT_ACTION_NOT_IN_AREA end
        end

        return 0
    end

    return TEXT_ACTION_UNKNOWN
end

function skill_action:eliminate_target( action_data, targets )
    local owner = self.ptr.owner

    local ret   = 0
    local ret_targets = {}

    for k, v in pairs(targets) do
    	
    	--判断是否已达目标数量上限
        if action_data.max_target_count > 0 then
            if count >= action_data.max_target_count then
                break
            end
        end

        repeat
            --是否在AOI范围内（若不存在则可能是一个空target，所以需要优先判断并移除）
            ret = self:TestAction(ACTION_TEST_IN_AOI, v)
            if ret ~= 0 then
                log_game_debug("SkillAction:EliminateTarget", "ACTION_TEST_IN_AOI=%s", ret)
                break
            end

            --死亡状态判断
            ret = self:TestAction(ACTION_TEST_TARGET_DEATH, v)
            if ret ~= 0 then
                log_game_debug("SkillAction:EliminateTarget", "ACTION_TEST_TARGET_DEATH=%s", ret)
                break
            end

            --是否可攻击状态判断
            ret = self:TestAction(ACTION_TEST_CAN_HIT_STATE, v)
            if ret ~= 0 then
                log_game_debug("SkillAction:EliminateTarget", "ACTION_TEST_CAN_HIT_STATE=%s", ret)
                break
            end

            --敌我阵营判断
            ret = SkillCalculate.GetFaction(owner, v)
            if ret ~= Faction.Enemy then
                log_game_debug("SkillAction:EliminateTarget", "Not enemy : %s", ret)
                break
            end

            --施法区域判断
            ret = self:TestAction(ACTION_TEST_TARGET_IN_AREA, action_data, v)
            if ret ~= 0 then
                break
            end

            ret_targets[k] = v
            count = count + 1
            break
        until true
    end
    target = ret_targets

    return ret
end

function skill_action:cast( skilldata, action_id, targets, start_tick )
	local action_data = skilldata.action_data

	local ret = self:test_action(ACTION_TEST_NEED_EXECUTE, action_data)
    if ret ~= 0 then
        log_game_debug("SkillAction:Cast", "Not Execute! skillID=%s, actionID=%s, actionSeq=%s", skillData.id, actionID, actionSeq)
        return
    end

    --检查施法者死亡状态
    ret = self:test_action(ACTION_TEST_CASTER_DEATH)
    if ret ~= 0 then
        log_game_debug("SkillAction:ProcSkillActionTimer", "Caster Death!")
        self:ShowTextID(CHANNEL.DBG, ret)
        self:RemoveAll()
        return
    end

    
    --寻找有效目标
    if skillData.findTargetInAction ~= 0 then
        if not targets or targets:size() == 0 then
            targets = SkillCalculate.FindTargets(owner, Faction.Enemy)
            if targets:size() == 0 then
                log_game_debug("SkillAction:ProcSkillActionTimer", "Find no targets!")
                --return
            end
        end
    end

    --移除无效技能目标
    self:eliminate_target(action_data, targets)

    --处理位移
    self:DoShiftAction(skillData, action_data)

    --召唤怪物
    self:DoSpawnAction(skillData, action_data)

    if targets:size() ~= 0 then
        --根据条件剔除目标
        local ret = self:EliminateTarget(skillData, action_data, targets)
    end

    --处理伤害
    self:DoDamageAction(skillData, action_data, targets)

    --处理加血
    self:DoHealAction(skillData, action_data, targets)

    --处理Buff
    self:DoBuffAction(skillData, action_data, targets)

    --处理机关事件
    self:DoTriggerEvent(skillData, action_data, targets)

end

return skill_action