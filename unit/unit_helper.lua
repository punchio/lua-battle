require("new")
require("common")
local unit_helper = {}

local unit_mgr

function unit_helper.init( mgr )
	print('unit_helper.init')
	unit_mgr = mgr
	for i = 1, 2 do
		local u = unit_mgr.random_unit()
		unit_mgr.add_unit(u)
	end
end

function unit_helper.distance(x1, y1, x2, y2)
	return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

function unit_helper.square_distance(x1, y1, x2, y2)
	return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
end

function unit_helper.update(time_delta)
	--input operations
	--for _, v in pairs( unit_mgr.units ) do
	--	if v:get_raw_attribute('state_id') == 'idle' then
	--		local unit_ai = ai_mgr[v.id]
	--		if unit_ai then
	--			print('unit id:' .. v.id .. '|length:' .. #unit_ai)
	--			local idx = v:get_raw_attribute('ai') or 1
	--			if idx > #unit_ai then
	--				idx = 1
	--				print( 'max to 1:' .. v.id )
	--			end
	--			print('idx:' .. idx)
	--			local action, value = unit_ai[idx]['action'], unit_ai[idx]['value']
	--			print('action:' .. action)
	--			if action == 'attack' and not value then
	--				action = 'auto-attack'
	--				value = true
	--			else
	--				v:set_raw_attribute('auto-attack', false)
	--			end
	--			--print('action:' .. action .. '|value:' .. value)
	--			v:set_raw_attribute(action, value)
	--			v:set_raw_attribute('ai', idx + 1)
	--		end
	--	end
	--end
end

return unit_helper