local unit_mgr = require("unit_mgr")
local fsm_mgr = {}

function fsm_mgr.init( ... )
	print('\nfsm mgr init manager.\n')
	fsm_mgr.states = {}

	local config = require("_config_fsm")
	for _, v in ipairs( config ) do
		local state = require(v)
		if not fsm_mgr.states[state.id] then
			fsm_mgr.states[state.id] = state
			if config.default == v then
				fsm_mgr.default_state = state
			end
			print('fsm mgr init, add state id:' .. state.id .. ' file:' .. v)
		else
			print('fsm mgr init, dup state id:' .. state.id .. ' file:' .. v)
		end
	end
end

function fsm_mgr.change_state(unit, state_id)
	print('fsm mgr change state. unit id:' .. unit.id)
	if not unit then
		print('nil unit.')
		return
	end

	-- exit old state
	local old = fsm_mgr.states[unit:get_raw_attribute('state_id')]
	if not old then
		print('invalid old state, unit:' .. unit.id .. '|state:' .. unit:get_raw_attribute('state_id'))
	else
		old:exit(unit)
		unit:set_raw_attribute('state_id', 'invalid')
	end

	-- enter new state
	local new = fsm_mgr.states[state_id]
	if not new then
		print('invalid new state, unit:' .. unit.id .. '|state:' .. state_id)
		new = fsm_mgr.default_state
	end
	
	if not new then
		print('invalid default state.')
		return
	end

	new:enter(unit)
	unit:set_raw_attribute('state_id', new.id)

end

function fsm_mgr.update(time_delta)
	print('\nfsm mgr update.')
	local rm = {}
	for _, v in pairs( unit_mgr.units ) do
		print('\nfsm mgr update unit:' .. v.id .. '|state id:' .. v:get_raw_attribute('state_id'))
		local cur = fsm_mgr.states[v:get_raw_attribute('state_id')]
		if not cur then
			fsm_mgr.change_state(v, fsm_mgr.default_state.id)
			cur = fsm_mgr.default_state
		end

		local new_type = cur:check_transition(v)
		if new_type ~= cur.id then

			-- exit old state
			cur:exit(v)
			v:set_raw_attribute('state_id', 'invalid')

			-- enter new state
			cur = fsm_mgr.states[new_type] or fsm_mgr.default_state
			cur:enter(v)
			v:set_raw_attribute('state_id', cur.id)
		end

		-- update cur state
		cur:update(v, time_delta)

		--if cur.id == 'dead' then
		--	table.insert(rm, v.id)
		--end
	end

	--for _, v in ipairs( rm ) do
	--	unit_mgr.remove_unit(v)
	--end

	print('\nfsm mgr update finish.')
end

--[[
function fsm_mgr.clear( ... )
	print('fsm clear.')
end

function fsm_mgr.add_state( state_id, state )
	print('fsm add state:' .. state_id)
end

function fsm_mgr.set_default_state( state_id )
	print('fsm set default state:' .. state_id)
end
--]]

return fsm_mgr