require("new")
require("common")
local unit = {}

--[[local BATTLE_PROPS_CONFIG = {
	MAX_HP = 1,
	CUR_HP = 2,
	PHY_ATK_POWER = 3, 
	PHY_DFS_POWER = 4,
	MAG_ATK_POWER = 5,
	MAG_DFS_POWER = 6,

	STRENGTH = 7,
	AGILITY = 8,
	INTELLIGENCE = 9,
	SPEED = 10,
}]]

function unit:ctor(...)
	-- body
	self.id, self.side, self.aoi = ...

	--property
	self.raw_props = {}

	--props : buff value, buff percent
	self.props = {}

	for _, v in pairs( BATTLE_PROPS_CONFIG ) do
		self.raw_props[v] = 0
		self.props[v] = {value = 0, percent = 1}
	end

	--move
	self.blackboard = {}
	self.blackboard.is_default_move = true
	self.blackboard.default_move_step = nil
	self.blackboard.default_path = {{0, 0}, {10, 0}, {20, 0}, {30, 0}}
	self.blackboard.velocity = {x = 0, y = 0}
	self.blackboard.position = {x = 0, y = 0}
	self.blackboard.dest_position = {x = 0, y = 0}
	self.blackboard.chase_enemy = 0
	self.blackboard.sight = 10000
	self.blackboard.auto_fight = true

	--target
	self.blackboard.attack = 0
	self.blackboard.defence = 0

	print('unit ctor id:' .. self.id .. '\n')
end

function unit:init( skill_manager )
	--skill system
	self.skill_manager = new(skill_manager, self)

	self:init_state()
end

function unit:set_raw_attribute(attr, value)
	self.raw_props[attr] = value

	local prop = self.props[attr]
	if not prop then
		prop = {value = value, percent = 1}
	end

	prop.value = value * prop.percent
end

function unit:get_raw_attribute(attr)
	local value = self.raw_props[attr]
	if not value then
		return 0
	else
		return value
	end
end

function unit:get_attribute(attr)
	local prop = self.props[attr]
	if not prop then
		return 0
	else
		return prop.value
	end
end

function unit:init_state()
	self.states = {}

	for k, v in pairs( STATE_CONFIG ) do
		self.states[v] = false
	end
	self.cur_state = STATE_CONFIG.IDLE
	self.states[STATE_CONFIG.IDLE] = true
end

function unit:get_states( )
	return self.states
end

function unit:get_cur_state( )
	return self.cur_state
end

function unit:set_cur_state( state )
	self.cur_state = state
end

function unit:add_hp( value )
	local cur_hp = self:get_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP)
	local new_hp = cur_hp + value
	print('unit:add_hp,', value, cur_hp, new_hp)
	if cur_hp <= 0 then
		--if new_hp > 0 then
		--	print('unit:add_hp,revive', self.id)
		--	self.states[STATE_CONFIG.IDLE] = true
		--	self.states[STATE_CONFIG.DEAD] = false
		--	local states = self:get_states()
		--	for k, v in pairs( states ) do
		--		print(k,v)
		--	end
		--end
	else
		if new_hp <= 0 then
			print('unit:add_hp,dead', self.id)
			self:set_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP, new_hp)
			self.states[STATE_CONFIG.DEAD] = true
						local states = self:get_states()
			for k, v in pairs( states ) do
				print(k,v)
			end
		else
		    self:set_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP, new_hp)
		end 
	end
end

function unit:move(delta_time)
	local speed = self:get_attribute(BATTLE_PROPS_CONFIG.SPEED)
    local dx = self.blackboard.dest_position.x - self.blackboard.position.x;
    local dy = self.blackboard.dest_position.y - self.blackboard.position.y;
    local d = dx*dx + dy*dy;
    local speed_square = speed * speed * delta_time * delta_time;
    if speed_square > d then
    	speed = d
    	self.blackboard.velocity.x = dx
		self.blackboard.velocity.y = dy
    end

	self.blackboard.position.x = self.blackboard.position.x + self.blackboard.velocity.x * delta_time
	self.blackboard.position.y = self.blackboard.position.y + self.blackboard.velocity.y * delta_time
end

function unit:set_dest_position(x, y)
	self.blackboard.dest_position.x = x
	self.blackboard.dest_position.y = y

	local dx = self.blackboard.dest_position.x - self.blackboard.position.x;
    local dy = self.blackboard.dest_position.y - self.blackboard.position.y;
    if dx == 0 and dy == 0 then
    	return
    end

    local d = math.sqrt(dx*dx + dy*dy);
    local speed = self:get_attribute(BATTLE_PROPS_CONFIG.SPEED)
	self.blackboard.velocity.x = speed * dx / d
	self.blackboard.velocity.y = speed * dy / d
end

function unit:get_dest_position( )
	return self.blackboard.dest_position.x, self.blackboard.dest_position.y
end

function unit:set_position(x, y)
	print(x, y)
	self.blackboard.position.x, self.blackboard.position.y = x, y
end

function unit:get_position( )
	return self.blackboard.position.x, self.blackboard.position.y
end

function unit:get_velocity( )
	return self.blackboard.velocity
end

function unit:stop_move( )
	self.blackboard.dest_position.x = self.blackboard.position.x
	self.blackboard.dest_position.y = self.blackboard.position.y
end

function unit:set_chase_enemy( unit_id )
	self.blackboard.chase_enemy = unit_id
end

function unit:get_chase_enemy( )
	return self.blackboard.chase_enemy
end

return unit