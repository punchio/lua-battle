require("new")

local task = {}

task.type = "base"

function task:ctor( ... )
	-- body
	self.type = ...
	self.id = 0
	
	print('task ctor id:' .. self.type)
end

function task:fill(...)
	print('task fill id:' .. (... or 'nil'))
end

function task:trigger()
	print('task trigger id:' .. self.id .. '|type:' .. self.type)
	return self:trigger_ex()
end

function task:trigger_ex()
	-- body
	print('task trigger_ex id:' .. self.id .. '|type:' .. self.type)
	return true
end

function task:create()
	print('task create id:' .. self.id .. '|type:' .. self.type)
	self.valid = true
	self:create_ex()
	self:enable()
end

function task:create_ex()
	print('task create_ex id:' .. self.id .. '|type:' .. self.type)
end

function task:destroy()
	print('task destroy id:' .. self.id .. '|type:' .. self.type)
	self:disable()
	self:destroy_ex()
	self.valid = false
end

function task:destroy_ex()
	print('task destroy_ex id:' .. self.id .. '|type:' .. self.type)
end

function task:enable()
	print('task enable id:' .. self.id .. '|type:' .. self.type)
	if self.enabled then
		return
	end
	self.enabled = true
	self:enable_ex()
end

function task:enable_ex()
	print('task enable_ex id:' .. self.id .. '|type:' .. self.type)
end

function task:disable()
	print('task disable id:' .. self.id .. '|type:' .. self.type)
	if not self.enabled then
		return
	end
	self.enabled = false
	self:disable_ex()
end

function task:disable_ex()
	print('task disable_ex id:' .. self.id .. '|type:' .. self.type)
end

function task:run(time_delta)
	print('\ntask run id:' .. self.id .. '|type:' .. self.type)
	if not self.valid then
		return
	end
	
	if not self:check_valid() then
		self:destroy()
		return
	end

	local check = self:check_enable()
	if self.enabled ~= check then 
		self.enabled = check
		if self.enabled then
			self:enable()
		else
			self:disable()
		end
	end

	self:run_ex(time_delta)

	if self.enabled then
		self:run_when_enable(time_delta)
	end
end

function task:run_ex(time_delta)
	print('task run ex id:' .. self.id)
end

function task:run_when_enable(time_delta)
	print('task run when enable id:' .. self.id)
end

function task:check_valid()
	print('task check valid id:' .. self.id)
	return self.valid
end

function task:check_enable()
	-- body
	print('task check enable id:' .. self.id)
	return self.enabled
end

function task:register_task()
	-- body
	-- return {} key:task point value:callback
	return {}
end

-- example
--function task:register_task_cb1( ... )
--	-- body
--end
--
--function task:register_task_cb2( ... )
--	-- body
--end
--
--function task:register_task()
--	return {['1'] = task.listen_cb1, ['2'] = task.listen_cb2}
--end
-- example end


return task