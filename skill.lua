local skill = {}

function skill:ctor( ... )
	-- body
	self.state = 'init'
end

function skill:cost( ... )
	-- body
end

function skill:target( ... )
	-- body
end

function skill:condition( ... )
	-- ok, wait, unexist
	return 'ok'
end

function skill:ready( ... )
	-- body
end

function skill:over( ... )
	-- body
end

function skill:effect( ... )
	-- body
	--if had buff, add buff
	--do immediate damage
end

function skill:update( ... )
	-- body
	if self.state == 'init' then
		if self:target() ~= nil then
			self.state = 'ready'
		else
			self.state = 'finish'
		end
	end

	if self.state == 'ready' then
		if self:ready() == 'ok' then
			if self.cost() then
				self.state = 'spell'
			else
				self.state = 'finish'
			end
		elseif self:ready() == 'fail' then
			self.state = 'finish'
		end
	end

	if self.state == 'spell' then
		if self:condition() then
			self:effect()
			self.state = 'over'
		else
			self.state = 'finish'
		end
	end

	if self.state == 'over' then
		if self:over() then
			self.state = 'finish'
		end
	end
end

