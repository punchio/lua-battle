require('log')

local battle_details = {}
local detail_id = 1
local timer_manager
local count = 0
local details = {}

function battle_details.init(timer_mgr)
	timer_manager = timer_mgr
end

function battle_details.add( unit_id, type, action, value )
	local cur_tick = timer_manager.now()
	local queue = details[cur_tick]
	if not queue then
		queue = {}
		details[cur_tick] = queue
	end

	local detail = {}
	detail.id = detail_id
	detail.unit_id = unit_id
	detail.type = type
	detail.action = action
	detail.value = value
	count = count + 1
	table.insert(queue, detail)
	detail_id = detail_id + 1
	log_print('info', 'battle_details add times:', count)
end

function battle_details.get_total( )
	local times = 0
	for k,v in pairs(details) do
		log_print('info', '\ntick:', k)
		times = times + #v
		for i,v in ipairs(v) do
			log_print('info', 'detail:', v.id, v.unit_id, v.type, v.action, v.value)
		end
	end
	log_print('info', 'battle_details total times:', times)
end

function battle_details.clear()
	details = {}
end
return battle_details