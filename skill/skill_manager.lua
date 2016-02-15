require 'new'
require("parser")
require('log')

local skill_buff = require 'skill_buff'
local skill_bag = require 'skill_bag'
local battle_details = require('battle_details')

local skill_manager = {}

local skill_data = {}

function skill_manager:init()
    -- body
    skill_manager:init_data()
    skill_buff:init_data()
end

function skill_manager:init_data( )
    --todo fill csv data
    --id  cd  target  condition   effect
    log_print('detail', 'skill_manager init data')
    skill_data = {}

    local skill = {}
    skill.id = 1
    skill.cd = 5
    skill.target = "return function() return get_closest_enemy() end"
    skill.condition = "return function() return get_hp() > 500 end"
    skill.effect = "return function() return add_buff(1) end"

    self:init_default_data(skill)

    skill_data[skill.id] = skill

    skill = {}
    skill.id = 2
    skill.cd = 5
    skill.target = "return function() return get_closest_enemy() end"
    skill.condition = "return function() return get_hp() > 500 end"
    skill.effect = "return function() return add_buff(2) end"

    self:init_default_data(skill)

    skill_data[skill.id] = skill

    skill = {}
    skill.id = 3
    skill.cd = 5
    skill.target = "return function() return get_closest_enemy() end"
    skill.condition = "return function() return get_hp() > 500 end"
    skill.effect = "return function() return add_buff(3) end"

    self:init_default_data(skill)

    skill_data[skill.id] = skill
end

function skill_manager:init_default_data( skill )
    log_print('detail', 'skill_manager init_default_data', skill.id)
    if skill.condition then
        log_print('detail', 'has condition', skill.id)
        skill.condition = Parse(skill.condition)
    end

    if skill.target then
        log_print('detail', 'has target', skill.id)
        skill.target = Parse(skill.target)
    end

    if skill.effect then
        log_print('detail', 'has effect', skill.id)
        skill.effect = Parse(skill.effect)
    end
end

--new a manager, give it to the owner
function skill_manager:ctor( owner )
    log_print('detail', 'skill manager attach to owner:', owner.id)
    self.ptr      = {}
    self.ptr.__mode = 'v'

    self.ptr.owner = owner

    self.skill_buff = new(skill_buff, owner, self)

    self.skill_bag = new(skill_bag, owner, self)
end

function skill_manager:has_skill( skill_id )
    return self.skill_bag:has(skill_id)
end

function skill_manager:get_skill_data( skill_id )
    if not skill_data then return nil end
    return skill_data[skill_id]
end

function skill_manager:cast_skill( skill_id )
    log_print('detail', 'skill manager cast skill:', skill_id, '|owner:', self.ptr.owner.id)
    local skill = self:get_skill_data(skill_id)
    if not skill then
        log_print('error', 'skill manager cast skill not exist, skill id:', skill_id, '|owner:', self.ptr.owner.id)
        return false 
    end

    if skill.condition and skill.condition(self.ptr.owner, nil) then 
        log_print('detail', 'skill manager cast skill fail, condition error.skill id:', skill_id, '|owner:', self.ptr.owner.id)
        return false 
    end

    local targets
    if skill.target then
        targets = skill.target(self.ptr.owner, nil)
        if targets then
            log_print('detail', 'skill manager cast skill find target, count:', #targets, 'skill id:', skill_id, '|owner:', self.ptr.owner.id)
        else
            log_print('detail', 'skill manager cast skill find no targets.skill id:', skill_id, '|owner:', self.ptr.owner.id)
        end
    end

    battle_details.add(self.id, 'skill', nil, targets)

    if skill.effect then 
        log_print('detail', 'skill manager cast skill effect. skill id:', skill_id, '|owner:', self.ptr.owner.id)
        skill.effect(self.ptr.owner, targets)
    end
end

function skill_manager:add_buff( buff_id )
    return self.skill_buff:add(buff_id)
end

function skill_manager:remove_buff( buff_id )
    return self.skill_buff:remove(buff_id)
end

function skill_manager:remove_buff_by_type( buff_type )
    return self.skill_buff:remove_by_type(buff_type)
end

function skill_manager:get_buff_remain_tick( buff_id )
    return self.skill_buff:get_remain_time(buff_id)
end

function skill_manager:get_cast_tick( skill_id )
    return self.skill_bag:get_cast_tick(skill_id)
end

function skill_manager:get_skill_range( skill_id )
    local skill_data = self:get_skill_data()
    if not skill_data then return 0 end
    return skill_data.range
end

return skill_manager