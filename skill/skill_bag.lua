-- 技能背包

g_skill_bag = {}

function g_skill_bag:ctor(owner, skill)
    self.owner = owner
    self.skill = skill

    self.skill_bag = owner.skill_bag or {}
    self.cast_tick = {}
end

function g_skill_bag:add(skill_id)
	if self:has(skill_id) == true then return false end
	self.skill_bag[skill_id] = 1 
	return true
end

function g_skill_bag:remove(skill_id)
    self.skill_bag[skill_id] = nil
end

function g_skill_bag:has(skill_id)
	return (self.skill_bag[skill_id] == 1)
end

--标记技能使用时间
function g_skill_bag:mark_cast_tick(skill, tick)
    self.cast_tick[skill.id] = tick
end

--获取指定技能最近一次标记的使用时间
function g_skill_bag:get_cast_tick(skill)
    local tick = self.cast_tick[skill.id]
    if not tick then return 0 end
    return tick
end

--重置技能使用时间
function g_skill_bag:reset_cast_tick()
    self.cast_tick = {}
end