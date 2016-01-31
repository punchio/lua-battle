require 'new'
local skill_action = require 'skill_action'
local skill_buff = require 'skill_buff'
local skill_bag = require 'skill_bag'

local skill_calculate = require 'skill_calculate'

local skill_manager = {}

local skill_data = {}

function skill_manager:init()
    -- body
    skill_manager:init_data()
    skill_action:init_data()
    skill_buff:init_data()
end

function skill_manager:init_data( )
    --todo fill csv data
    --one skill data : CD, cast range, target type, conditions, and actions

    skill_data = {}
end

--new a manager, give it to the owner
function skill_manager:ctor( owner )
    self.ptr      = {}
    self.ptr.__mode = 'v'

    self.ptr.owner = owner

    self.skill_action = skill_action:new(owner, self)

    self.skill_buff = skill_buff:new(owner, self)

    self.skill_bag = skill_bag:new(owner, self)
end

function skill_manager:has_skill( skill_id )
    return self.skill_bag:has_skill(skill_id)
end

function skill_manager:get_skill_data( skill_id )
    if not skill_data then return nil end
    return skill_data[skill_id]
end

function skill_manager:test_skill( skill_data, mode )
    return true
end

function skill_manager:find_targets( skill_data )
    return {}
end

function skill_manager:use_skill( skill_id )
    local skill_data = self.get_skill_data(skill_id)
    if not skill_data then return false end

    if not self:test_skill(skill_data, nil) then return false end

    local targets = self:find_targets(skill_data)

    self:cast_effect(skill_data, targets)
end

function skill_manager:execute_buff_skill( skill_id )
    local skill_data = self.get_skill_data(skill_id)
    if not skill_data then return false end

    if not self:test_skill(skill_data, nil) then return false end
    
    self:cast_effect(skill_data, nil)
end

function skill_manager:cast_effect( skill_data, targets )
    for idx, action_id in ipairs(skill_data.actions) do
        self.skill_action:cast(action_id, idx, skill_data, targets)
    end
end