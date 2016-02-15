local root = 'D:/Git/lua-battle'
package.path = string.format("%s;%s/?.lua;%s/skill/?.lua;%s/timer/?.lua;%s/fsm/?.lua;%s/unit/?.lua;%s/parse/?.lua;%s/effects/?.lua;%s/effects/*",
	package.path, root, root, root, root, root, root, root, root)

require('log')
local timer_mgr = require('timer_mgr')
local battle_details = require('battle_details')
local fsm_mgr = require("fsm_mgr")
local unit_mgr = require("unit_mgr")
local unit_helper = require("unit_helper")
local skill_manager = require("skill_manager")

local main = function ( )
	local cost_time = os.clock()
	log_print('detail', 'main start...')
	local time = 1
	battle_details.init(timer_mgr)
	skill_manager:init()
	unit_mgr.init(skill_manager, unit_helper)
	unit_helper.init(unit_mgr)
	fsm_mgr.init(unit_mgr)

	while true do
		log_print('detail','---------------frame:' .. time .. '---------------')
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
			log_print('detail', v .. ':' .. unit_mgr.units[v]:get_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP), unit_mgr.units[v]:get_cur_state())
		end
	
		if unit_mgr.check_finish() or time > 1000 then
			battle_details.get_total()
			break
		end

		battle_details.clear()
	end
		
	log_print('detail', os.clock() - cost_time )
end

main()