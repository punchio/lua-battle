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

--function unit_mgr.add_unit(side, force, hp, skill, posx, posy, range, velocity)
--	-- body
--	local u = new(unit, unit_mgr.pop_free_id())
--	u:set_raw_attribute('side', side)
--	u:set_raw_attribute('maxhp', hp)
--	u:set_raw_attribute('hp', hp)
--	u:set_raw_attribute('str', force)
--	u:set_raw_attribute('vel', velocity)
--	u:set_raw_attribute('pos', {posx, 0, posy})
--	u:set_raw_attribute('attack_range', range)
--	u:set_raw_attribute('skill', skill)
--	
--	--default value
--	u:set_raw_attribute('move', nil)
--	u:set_raw_attribute('attack', 0)
--	u:set_raw_attribute('defence', 0)
--	u:set_raw_attribute('spell', 0)
--	u:set_raw_attribute('state_id', 'invalid')
--	--u:set_raw_attribute('attack_time', 0)
--	--u:set_raw_attribute('attack_speed', 0)
--	
--end

return unit_mgr