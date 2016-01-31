-- 技能背包

local skill_bag = {}
skill_bag.__index = skill_bag

function skill_bag.new(owner, skill_mgr)
    local new_obj    = {}
    new_obj.ptr      = {}
    setmetatable(new_obj,        {__index = skill_bag})
    setmetatable(new_obj.ptr,    {__mode = "v"})

    new_obj.ptr.owner   = owner
    new_obj.ptr.skill_mgr   = skill_mgr

    --技能背包,由角色技能背包属性值初始化
    new_obj.skill_bag         = owner.skill_bag or {}

    --技能使用时间，用于技能CD计算
    new_obj.cast_tick    = {}
    
    return new_obj
end

function skill_bag:add(skill_id)
	if self:has(skill_id) == true then return false end
	self.skill_bag[skill_id] = 1 
	return true
end

function skill_bag:remove(skill_id)
    self.skill_bag[skill_id] = nil
end

function skill_bag:has(skill_id)
	return (self.skill_bag[skill_id] == 1)
end

--标记技能使用时间
function skill_bag:mark_cast_tick(skill, tick)
    self.cast_tick[skill.id] = tick
end

--获取指定技能最近一次标记的使用时间
function skill_bag:get_cast_tick(skill)
    local tick = self.cast_tick[skill.id]
    if not tick then return 0 end
    return tick
end

--重置技能使用时间
function skill_bag:reset_cast_tick()
    self.cast_tick = {}
end

return skill_bag