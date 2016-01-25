require("new")
local skill = require("skill")

local mgr = {}
mgr.skills = {}

function mgr.add_skill( ... )
	-- body
	table.insert(mgr.skills, new(skill, ...)
end

function mgr.update( ... )
	-- body
	local rm = {}

	for k, v in pairs( mgr.skills ) do
		v.update()
		if v.over ~= 'finish' then
			table.insert(rm, k)
		end
	end

	for i, v in ipairs( rm ) do
		table.remove(mgr.skills, v)
	end
end