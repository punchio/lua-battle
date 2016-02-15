require("new")
require("common")
require('log')
local battle_details = require('battle_details')

local unit = {}

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
	self.blackboard.default_path = {{x = 0, y = 0}, {x = 10, y = 0}, {x = 20, y = 0}, {x = 30, y = 0}}
	self.blackboard.velocity = {x = 0, y = 0}
	self.blackboard.position = {x = 0, y = 0}
	self.blackboard.dest_position = {x = 0, y = 0}
	self.blackboard.chase_enemy = 0
	self.blackboard.sight = 10000
	self.blackboard.auto_fight = true

	--attack
	self.blackboard.first_attack = false
	self.blackboard.attack_range = 5
	self.blackboard.attack = 0
	self.blackboard.defence = 0

	log_print('detail', 'unit ctor, unit id:', self.id)
end

function unit:init( skill_manager )
	log_print('detail', 'unit init skill manager.')
	self.skill_manager = new(skill_manager, self)

	self:init_state()
end

function unit:set_raw_attribute(attr, value)
	log_print('detail', 'unit init set raw attribute, unit id:', self.id, '|property:', attr, '|value:', value)
	self.raw_props[attr] = value

	local prop = self.props[attr]
	if not prop then
		log_print('detail', 'unit init set raw attribute, unit id:', self.id, '|add props, property:', attr, '|value:', value)
		prop = {value = value, percent = 1}
	end

	prop.value = value * prop.percent
	log_print('detail', 'unit init set raw attribute, unit id:', self.id, '|property:', attr, '|value:', prop.value)
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
	log_print('detail', 'unit init state, unit id:', self.id)
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
	log_print('detail', 'unit set cur state, unit id:', self.id, '|state id:', state)
	self.cur_state = state
end

function unit:add_hp( value )
	log_print('detail', 'unit add hp, unit id:', self.id, '|value:', value)
	local cur_hp = self:get_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP)
	local new_hp = cur_hp + value
	log_print('detail', 'unit add hp, unit id:', self.id, '|cur_hp:', cur_hp, '|new_hp:', new_hp)
	if cur_hp <= 0 then
		log_print('warning', 'unit add hp, unit was already dead, unit id:', self.id)
	else
		if new_hp <= 0 then
			log_print('detail', 'unit add hp, unit dead, unit id:', self.id)
			self:set_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP, 0)
			self.states[STATE_CONFIG.DEAD] = true
		else
		    self:set_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP, new_hp)
		end 
	end
	battle_details.add(self.id, 'attack', 'hand2hand', value)
end

function unit:move(delta_time)
	local speed = self:get_attribute(BATTLE_PROPS_CONFIG.SPEED)
    local dx = self.blackboard.dest_position.x - self.blackboard.position.x;
    local dy = self.blackboard.dest_position.y - self.blackboard.position.y;
    local d = dx*dx + dy*dy;
    local speed_square = speed * speed * delta_time * delta_time;
    log_print('detail', 'delta:', delta_time, 'speed:', speed, 'dx:', dx, 'dy:', dy, 'd:', d, 'speed_square', speed_square, self.blackboard.velocity.x, self.blackboard.velocity.y)
    if speed_square > d then
    	speed = d
    	self.blackboard.velocity.x = dx
		self.blackboard.velocity.y = dy
    end
    log_print('detail', 'move postion:', self.blackboard.position.x, self.blackboard.position.y)
	self.blackboard.position.x = self.blackboard.position.x + self.blackboard.velocity.x * delta_time
	self.blackboard.position.y = self.blackboard.position.y + self.blackboard.velocity.y * delta_time
	log_print('detail', 'move postion:', self.blackboard.position.x, self.blackboard.position.y)
end

function unit:set_dest_position(x, y)
	self.blackboard.dest_position.x = x
	self.blackboard.dest_position.y = y

	local dx = self.blackboard.dest_position.x - self.blackboard.position.x;
    local dy = self.blackboard.dest_position.y - self.blackboard.position.y;
    log_print('detail', 'dest:', x, y, 'd:', dx, dy)
    if dx == 0 and dy == 0 then
    	return
    end

    local d = math.sqrt(dx*dx + dy*dy);
    local speed = self:get_attribute(BATTLE_PROPS_CONFIG.SPEED)
	self.blackboard.velocity.x = speed * dx / d
	self.blackboard.velocity.y = speed * dy / d
	log_print('detail', 'velocity:', self.blackboard.velocity.x, self.blackboard.velocity.y)
end

function unit:get_dest_position( )
	return self.blackboard.dest_position.x, self.blackboard.dest_position.y
end

function unit:set_position(x, y)
	log_print('detail', x, y)
	self.blackboard.position.x, self.blackboard.position.y = x, y
end

function unit:get_position( )
	return self.blackboard.position.x, self.blackboard.position.y
end

function unit:get_velocity( )
	return self.blackboard.velocity
end

function unit:stop_move( )
	log_print('detail', 'unit stop move, unit id:', self.id)
	self.blackboard.dest_position.x = self.blackboard.position.x
	self.blackboard.dest_position.y = self.blackboard.position.y
end

function unit:set_chase_enemy( unit_id )
	log_print('detail', 'unit set chase enemy, unit id:', self.id, '|chase enmey:', unit_id)
	self.blackboard.chase_enemy = unit_id
end

function unit:get_chase_enemy( )
	return self.blackboard.chase_enemy
end

return unit