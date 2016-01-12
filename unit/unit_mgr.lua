local unit_mgr = {}

function unit_mgr.init()
	-- body
	print('unit mgr init.')
	unit_mgr.free_id = 1
	unit_mgr.units = {}
end

--[[
function unit_mgr.update( delta )
	-- body
	print('unit mgr update.')

	for _, v in pairs( unit_mgr.units ) do
		fsm_mgr.update(v)
	end
end
--]]

function unit_mgr.add_unit( unit )
	-- body
	print('unit mgr add unit:' .. unit.id)
	unit_mgr.units[unit.id] = unit
end

function unit_mgr.remove_unit( id )
	-- body
	print('unit mgr remove unit:' .. id)
	unit_mgr.units[id] = nil
end

function unit_mgr.get_unit( id )
	-- body
	return unit_mgr.units[id]
end

function unit_mgr.pop_free_id( )
	-- body
	local id = unit_mgr.free_id
	unit_mgr.free_id = id + 1
	return id
end

return unit_mgr