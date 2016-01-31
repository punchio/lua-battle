local skill_action = {}
local skill_action_data = {}

function skill_action:init_data( )
	--todo fill csv data
	--one action data: target type, cast position, shift, spawn, heal, damage, add buff types, del buff types, enable types, disable types
	skill_action_data = {}
end

function skill_action:ctor( owner, skill_manager)
	self.ptr = {}
	self.ptr.__mode = 'v'
	self.ptr.owner = owner
	self.ptr.skill_manager = skill_manager
end

function skill_action:get_action_data( action_id )
	if not skill_action_data then return nil end
	return skill_action_data[action_id]
end

function skill_action:test_action( action_data, mode )
	return true
end

function skill_action:eliminate_targets( action_data, targets )
	
end

function skill_action:find_targets( action_data )
	return nil
end

function skill_action:cast( action_id, idx, skill_data, targets )
	local raw_action_data = self:get_action_data(action_id)
	if not raw_action_data then return false end

	if not self:test_action(raw_action_data, nil) then return false end

	if not targets then
		targets = self:find_targets(raw_action_data)
	end

	self:eliminate_targets(raw_action_data, targets)

	self:do_shift(raw_action_data)

	self:do_spawn(raw_action_data)

	self:do_damage(raw_action_data)

	self:do_heal(raw_action_data)

	self:do_buff(raw_action_data)
end

function skill_action:do_shift( action_data )
	
end

function skill_action:do_spawn( action_data )
	
end

function skill_action:do_damage( action_data )
	-- body
end

function skill_action:do_heal( action_data )
	
end

function skill_action:do_buff( action_data )
	
end