local root = 'D:/Git/lua-battle'
package.path = string.format("%s;%s/?.lua;%s/skill/?.lua;%s/timer/?.lua;%s/fsm/?.lua;%s/unit/?.lua;%s/parse/?.lua",
	package.path, root, root, root, root, root, root)

local timer_mgr = require('timer_mgr')
local fsm_mgr = require("fsm_mgr")
local unit_mgr = require("unit_mgr")
local unit_helper = require("unit_helper")
local skill_manager = require("skill_manager")

local main = function ( )
	local cost_time = os.clock()
	print('main start...')
	local time = 1
	skill_manager:init()
	unit_mgr.init(skill_manager)
	unit_helper.init(unit_mgr)
	fsm_mgr.init(unit_mgr)

	while true do
		print('\n\n---------------frame:' .. time .. '---------------')
		unit_helper.update(1)
		fsm_mgr.update(1)
		unit_mgr.update(1)
		timer_mgr.update(1)
		time = time + 1

		local sort_units = {}
		for k, _ in pairs( unit_mgr.units ) do
			table.insert(sort_units, k)
		end

		table.sort(sort_units)
		for _, v in ipairs( sort_units ) do
			print( v .. ':' .. unit_mgr.units[v]:get_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP))
		end
	
		if unit_helper.check_finish() or time > 1000 then
			break
		end
	end
		
	print( os.clock() - cost_time )
end

main()