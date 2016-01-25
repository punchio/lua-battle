require 'new'
local timer = require('timer')
local timer_mgr = {}

local cur_tick = os.clock()
local timer_id = 1
local timer_queue = {}
local id2queue = {}

function timer_mgr.update()
	cur_tick = os.clock()

	local rm = {}
	for tick, queue in pairs(timer_queue) do
		if tick <= cur_tick then
			print('tick:' .. tick .. ' queue:' .. #queue)
			for _, item in ipairs( queue ) do
				print('item:' .. item.id .. ' cur times:' .. item.cur_times .. ' func:' .. type(item.func) .. ' item.entity:' .. type(item.entity))
				if item.func and item.func(item.entity) then
					item:inc()
					local new_tick = item:get_next_tick(cur_tick)
					if new_tick > 0 then
						local new_queue = timer_queue[new_tick] or {}
						new_queue[item.id] = item
						timer_queue[new_tick] = new_queue
						print('new queue tick:' .. new_tick .. ' cnt:' .. #new_queue .. ' item cur_times:' .. item.cur_times)
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

function timer_mgr.add_timer(obj, func, total_times, start, interval )
	-- body
	local item = new(timer, timer_id)
	item.entity = obj
	item.func = func
	item.total_times = total_times
	item.start_tick = start + cur_tick
	item.interval_tick = interval
	
	timer_id = timer_id + 1
	local new_queue = timer_queue[item.start_tick] or {}
	new_queue[item.id] = item
	timer_queue[item.start_tick] = new_queue
	id2queue[item.id] = item.start_tick

	return item.id
end

function timer_mgr.remove_timer( id )
	-- body
	local queue_id = id2queue[id]
	id2queue[id] = nil
	if not queue_id then
		return false
	end

	local queue = timer_queue[queue_id]
	if not queue then
		return false
	end

	queue[id] = nil
	return true
end

function timer_mgr.has_timer( id )
	-- body
	return id2queue[id] ~= nil
end

return timer_mgr