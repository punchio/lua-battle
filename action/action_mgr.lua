require("new")
local action_mgr = {}

action_mgr.free_id = 1

function action_mgr.init()
	print( '\nevt mgr init.\n' )
	action_mgr.events = {}
	action_mgr.broadcaster = {}
	action_mgr.action_types = {}

	local config = require("_config_action")
	for _, v in ipairs( config ) do
		local evt = require(v)
		if evt and not action_mgr.action_types[evt.type] then
			action_mgr.action_types[evt.type] = evt
			print('evt mgr init, add action type:' .. evt.type .. ' file:' .. v)
		else
			print('evt mgr init, dup action type:' .. evt.type .. ' file:' .. v)
		end
	end
end

function action_mgr.add_event( evt_type, ... )
	print('evt mgr add action:' .. evt_type)
	local evt = action_mgr.action_types[evt_type]
	if not evt then
		print('action_mgr add action fail. not exist evt type:' .. evt_type)
		return
	end

	local e = new(evt, action_mgr.pop_free_id())
	e:fill(...)
	if e:trigger() then
		-- register interest action point
		for k, v in pairs( e:register_event() ) do
			--get listeners
			local listerns = action_mgr.broadcaster[k]
			if not listerns then
				listerns = {}
				action_mgr.broadcaster[k] = listerns
			end

			local cb = listerns[e]
			if not cb then
				cb = {}
				listerns[e] = cb
			end
			table.insert(cb, v)
		end
		-- end

		e:create()

		action_mgr.events[e.id] = e
		print('action_mgr add action:' .. e.id)
	end

	return e.id
end

function action_mgr.broadcast( point, ... )
	-- body
	local listeners = action_mgr.broadcaster[point]
	if not listeners then
		return
	end

	for k, v in pairs( listeners ) do
		-- k:action v:function
		for _, _v in ipairs( v ) do
			_v(k, ...)
		end
	end
end

function action_mgr.run(time_delta)
	print('\nevt mgr run.\n')

	local rm = {}
	for k, v in pairs( action_mgr.events ) do
		v:run(time_delta)
		if not v.valid then
			table.insert(rm, k)
		end
	end

	for _, v in ipairs( rm ) do
		print('evt mgr remove action:' .. v)
		local action = action_mgr.events[v]
		for k, v in pairs( action_mgr.broadcaster ) do
			if v[action] then
				v[action] = nil
			end
		end

		action_mgr.events[v] = nil
	end
end

function action_mgr.pop_free_id( )
	local id = action_mgr.free_id
	action_mgr.free_id = id + 1
	print('evt mgr pop free id:' .. id)
	return id
end

return action_mgr