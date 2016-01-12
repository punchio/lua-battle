require("new")

local action = {}

action.type = "base"

function action:ctor( ... )
	-- body
	self.type = ...
	self.id = 0
	
	print('action ctor id:' .. self.type)
end

function action:fill(...)
	print('action fill id:' .. (... or 'nil'))
end

function action:trigger()
	print('action trigger id:' .. self.id .. '|type:' .. self.type)
	return self:trigger_ex()
end

function action:trigger_ex()
	-- body
	print('action trigger_ex id:' .. self.id .. '|type:' .. self.type)
	return true
end

function action:create()
	print('action create id:' .. self.id .. '|type:' .. self.type)
	self.valid = true
	self:create_ex()
	self:enable()
end

function action:create_ex()
	print('action create_ex id:' .. self.id .. '|type:' .. self.type)
end

function action:destroy()
	print('action destroy id:' .. self.id .. '|type:' .. self.type)
	self:disable()
	self:destroy_ex()
	self.valid = false
end

function action:destroy_ex()
	print('action destroy_ex id:' .. self.id .. '|type:' .. self.type)
end

function action:enable()
	print('action enable id:' .. self.id .. '|type:' .. self.type)
	if self.enabled then
		return
	end
	self.enabled = true
	self:enable_ex()
end

function action:enable_ex()
	print('action enable_ex id:' .. self.id .. '|type:' .. self.type)
end

function action:disable()
	print('action disable id:' .. self.id .. '|type:' .. self.type)
	if not self.enabled then
		return
	end
	self.enabled = false
	self:disable_ex()
end

function action:disable_ex()
	print('action disable_ex id:' .. self.id .. '|type:' .. self.type)
end

function action:run(time_delta)
	print('\nevent run id:' .. self.id .. '|type:' .. self.type)
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

function action:run_ex(time_delta)
	print('action run ex id:' .. self.id)
end

function action:run_when_enable(time_delta)
	print('action run when enable id:' .. self.id)
end

function action:check_valid()
	print('action check valid id:' .. self.id)
	return self.valid
end

function action:check_enable()
	-- body
	print('action check enable id:' .. self.id)
	return self.enabled
end

function action:listen()
	-- body
	-- return {} key:action point value:callback
	return {}
end

-- example
--function action:listen_cb1( ... )
--	-- body
--end
--
--function action:listen_cb2( ... )
--	-- body
--end
--
--function action:listen()
--	return {['1'] = action.listen_cb1, ['2'] = action.listen_cb2}
--end
-- example end


return action