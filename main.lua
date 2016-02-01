local root = 'D:/Git/lua-battle/'
package.path = string.format("%s;%s?.lua;%sskill/?.lua;%stimer/?.lua;%sfsm/?.lua;%sunit/?.lua", package.path, root, root, root, root, root)

local timer_mgr = require('timer_mgr')
local action_mgr = require("action_mgr")
local fsm_mgr = require("fsm_mgr")
local unit_mgr = require("unit_mgr")
local unit_helper = require("unit_helper")

g_unit = nil
function get_attribute( at)
	return g_unit:get_raw_attribute(at)
end

--local function print()
	-- body
--end
--math.randomseed(0)
--_G['print'] = print
local main = function ( )
	local cost_time = os.clock()
	print('main start...')
	local time = 1
	action_mgr.init()
	fsm_mgr.init()
	unit_mgr.init()
	unit_helper.init()

	while true do
		print('\n\n---------------frame:' .. time .. '---------------')
		timer_mgr.update()
		unit_helper.update()
		fsm_mgr.update(1)
		action_mgr.run(1)
		time = time + 1

		local sort_units = {}
		for k, _ in pairs( unit_mgr.units ) do
			table.insert(sort_units, k)
		end

		table.sort(sort_units)
		for _, v in ipairs( sort_units ) do
			print( v .. ':' .. unit_mgr.units[v]:get_raw_attribute('hp'))
		end
	
		if unit_helper.check_finish() or time > 1000 then
			break
		end
	end
		
	print( os.clock() - cost_time )
	g_unit = unit_helper.random_unit()
	local sc = 'return (get_attribute("str") * get_attribute("hp"))'
	print(load(sc)())
end

main()