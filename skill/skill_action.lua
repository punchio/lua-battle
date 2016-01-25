local skill_action = {}

function skill_action:ctor( ... )
	-- body
	self.state = 'init'
end

function skill_action:cost( ... )
	-- body
end

function skill_action:target( ... )
	-- body
end

function skill_action:condition( ... )
	-- ok, wait, unexist
	return 'ok'
end

function skill_action:ready( ... )
	-- body
end

function skill_action:over( ... )
	-- body
end

function skill_action:effect( ... )
	-- body
	--if had buff, add buff
	--do immediate damage
end

function skill_action:update( ... )
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

return skill_action