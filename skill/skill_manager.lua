require 'new'
require("parser")
local skill_buff = require 'skill_buff'
local skill_bag = require 'skill_bag'

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
    print('skill_manager init data')
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
    print('skill_manager init_default_data', skill.id)
    if skill.condition then
        print('condition')
        skill.condition = Parse(skill.condition)
    end

    if skill.target then
        print('target')
        skill.target = Parse(skill.target)
    end

    if skill.effect then
        print('effect')
        skill.effect = Parse(skill.effect)
    end
end

--new a manager, give it to the owner
function skill_manager:ctor( owner )
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
    print('cast skill:', skill_id, '|unit:', self.ptr.owner.id)
    local skill = self:get_skill_data(skill_id)
    print(skill == nil)
    if not skill then return false end
    print('cast skill skill:', skill_id, '|unit:', self.ptr.owner.id)

    if skill.condition and skill.condition(self.ptr.owner, nil) then return false end
    print('cast skill condition:', skill_id, '|unit:', self.ptr.owner.id)

    local targets = skill.target and skill.target(self.ptr.owner, nil)
    print('cast skill targets:', skill_id, '|unit:', self.ptr.owner.id, '|target:', targets == nil)

    if skill.effect then 
        print('cast skill effect:', skill_id, '|unit:', self.ptr.owner.id)
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