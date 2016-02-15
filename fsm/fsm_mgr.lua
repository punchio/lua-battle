local fsm_mgr = {}
local unit_manager

function fsm_mgr.init( mgr )
	log_print('detail', 'fsm mgr init manager.')
	unit_manager = mgr
	fsm_mgr.states = {}

	local config = require("_config_fsm")
	for _, v in ipairs( config ) do
		local state = require(v)
		if not fsm_mgr.states[state.id] then
			fsm_mgr.states[state.id] = state
			if config.default == v then
				fsm_mgr.default_state = state
			end
			log_print('detail', 'fsm mgr init, add state id:' .. state.id .. ' file:' .. v)
		else
			log_print('detail', 'fsm mgr init, dup state id:' .. state.id .. ' file:' .. v)
		end
	end
end

function fsm_mgr.change_state(unit, state_id)
	log_print('detail', 'fsm mgr change state. unit id:' .. unit.id)
	if not unit then
		log_print('detail', 'nil unit.')
		return
	end

	-- exit old state
	local old = fsm_mgr.states[unit:get_cur_state()]
	if not old then
		log_print('detail', 'invalid old state, unit:' .. unit.id .. '|state:' .. unit:get_cur_state())
	else
		old:exit(unit)
	end

	-- enter new state
	local new = fsm_mgr.states[state_id]
	if not new then
		log_print('detail', 'invalid new state, unit:' .. unit.id .. '|state:' .. state_id)
		new = fsm_mgr.default_state
	end
	
	if not new then
		log_print('detail', 'invalid default state.')
		return
	end

	new:enter(unit)
	unit:set_cur_state(new.id)
end

function fsm_mgr.update(time_delta)
	log_print('detail', 'fsm mgr update.')
	local rm = {}
	for _, v in pairs( unit_manager.units ) do
		log_print('detail', 'fsm mgr update unit:' .. v.id .. '|state id:' .. v:get_cur_state())
		local cur = fsm_mgr.states[v:get_cur_state()]
		if not cur then
			fsm_mgr.change_state(v, fsm_mgr.default_state.id)
			cur = fsm_mgr.default_state
		end

		local new_type = cur:check_transition(v)
		if new_type ~= cur.id then
			-- exit old state
			cur:exit(v)
			log_print('detail', 'exit state:', cur.id)
			-- enter new state
			cur = fsm_mgr.states[new_type] or fsm_mgr.default_state
			cur:enter(v)
			log_print('detail', 'enter state:', cur.id)
			v:set_cur_state(cur.id)
		end

		cur:update(v, time_delta)
	end

	log_print('detail', 'fsm mgr update finish.')
end

--[[
function fsm_mgr.clear( ... )
	log_print('detail', 'fsm clear.')
end

function fsm_mgr.add_state( state_id, state )
	log_print('detail', 'fsm add state:' .. state_id)
end

function fsm_mgr.set_default_state( state_id )
	log_print('detail', 'fsm set default state:' .. state_id)
end
--]]

return fsm_mgr