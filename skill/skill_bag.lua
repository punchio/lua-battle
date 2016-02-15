-- 技能背包
require('log')
local skill_bag = {}

function skill_bag:ctor(owner, skill_mgr)
    self.ptr      = {}
    setmetatable(self.ptr,    {__mode = "v"})

    self.ptr.owner   = owner
    self.ptr.skill_mgr   = skill_mgr

    --one bag: skill ids
    self.skill_bag         = owner.skill_bag or {}

    self.cast_tick    = {}
end

function skill_bag:add(skill_id)
	if self:has(skill_id) == true then return false end
	log_print('detail', 'skill bag mark cast tick:',tick, '|skill:', skill_id, '|owner:', self.ptr.owner.id)
    self.skill_bag[skill_id] = 1 
	return true
end

function skill_bag:remove(skill_id)
    self.skill_bag[skill_id] = nil
end

function skill_bag:has(skill_id)
	return (self.skill_bag[skill_id] == 1)
end

function skill_bag:mark_cast_tick(skill, tick)
    log_print('detail', 'skill bag mark cast tick:',tick, '|skill:', skill, '|owner:', self.ptr.owner.id)
    self.cast_tick[skill.id] = tick
end

function skill_bag:get_cast_tick(skill)
    local tick = self.cast_tick[skill.id]
    if not tick then return 0 end
    return tick
end

function skill_bag:reset_cast_tick()
    self.cast_tick = {}
end

return skill_bag