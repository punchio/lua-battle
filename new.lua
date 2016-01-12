function new(t, ...)
	local o = setmetatable({}, t)
	t.__index = t
	if t.ctor then
		o:ctor(...)
	end

	return o
end