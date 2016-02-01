local timer = {}

function timer:ctor(id, ...)
	self.id = id
	self.start_tick = 0
	self.interval_tick = 0
	self.total_times = 0
	self.cur_times = 0
	self.obj = nil
	self.func = nil
	self.params = nil
end

function timer:inc()
	self.cur_times = self.cur_times + 1
end

function timer:get_next_tick( tick )
	if self.total_times > 0 and self.total_times == self.cur_times then 
		return 0 
	end

	return tick + self.interval_tick
end

return timer