require 'new'
require('log')

local timer = require('timer')
local timer_mgr = {}

local cur_tick = 1
local timer_id = 1
local timer_queue = {}
local id2queue = {}

function timer_mgr.update(time_delta)
	cur_tick = cur_tick + time_delta

	local rm = {}
	for tick, queue in pairs(timer_queue) do
		if tick <= cur_tick then
			log_print('detail', 'timer mgr update, tick:' .. tick .. ' queue:' .. #queue)
			for _, item in ipairs( queue ) do
				log_print('detail', 'timer mgr update, item:' .. item.id .. ' cur times:' .. item.cur_times .. ' func:' .. type(item.func) .. ' item.obj:' .. type(item.obj))
				if item.func then
					item.func(item.obj, item.id, table.unpack(item.params))
					item:inc()
					local new_tick = item:get_next_tick(cur_tick)
					if new_tick > 0 then
						local new_queue = timer_queue[new_tick] or {}
						new_queue[item.id] = item
						timer_queue[new_tick] = new_queue
						log_print('detail', 'timer mgr update, add to new queue tick:' .. new_tick .. ' cnt:' .. #new_queue .. ' item cur_times:' .. item.cur_times)
					end
				end
			end
			table.insert(rm, tick)
		end
	end

	for _,v in ipairs(rm) do
		timer_queue[v] = nil
	end
end

function timer_mgr.add_timer(obj, func, total_times, start, interval, ...)
	total_times = total_times or 1
	start = start or 0
	interval = interval or 0

	local item = new(timer, timer_id)
	item.obj = obj
	item.func = func
	item.total_times = total_times
	item.start_tick = start + cur_tick
	item.interval_tick = interval or 0
	item.stop_tick = item.start_tick + item.interval_tick * item.total_times
	item.params = table.pack(...)

	timer_id = timer_id + 1
	local new_queue = timer_queue[item.start_tick] or {}
	new_queue[item.id] = item
	timer_queue[item.start_tick] = new_queue
	id2queue[item.id] = item.start_tick

	log_print('detail', 'timer mgr add timer,timer id:', item.id, 
		'|start_tick:', item.start_tick, 
		'|stop_tick:', item.stop_tick, 
		'|interval:', item.interval_tick)
	return item.id
end

function timer_mgr.remove_timer( id )
	log_print('detail', 'timer mgr remove timer, timer id:', id)
	local queue_id = id2queue[id]
	id2queue[id] = nil
	if not queue_id then
		log_print('warning', 'timer mgr remove timer, timer not exist.timer id:', id)
		return false
	end

	local queue = timer_queue[queue_id]
	if not queue then
		log_print('warning', 'timer mgr remove timer, timer queue not exist.timer queue id:', queue_id)
		return false
	end

	queue[id] = nil
	return true
end

function timer_mgr.has_timer( id )
	return id2queue[id] ~= nil
end

function timer_mgr.get_remain_time( id )
	local queue_id = id2queue[id]
	if not queue_id then return 0 end

	local queue = timer_queue[queue_id]
	if not queue then return 0 end

	local timer = queue[id]
	if not timer then return 0 end

	if timer.total_times == 0 then
		return 'N/A'
	else
		return timer.stop_tick - cur_tick
	end
end

function timer_mgr.now()
	return cur_tick
end

return timer_mgr