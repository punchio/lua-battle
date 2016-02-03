local env = require("env")
local formulas = {}

function Parse( express )
	local func = formulas[express]
	if not func then
		local fc = load(express, nil, nil, env)()
		func = function ( unit, targets, ... )
			print(express)
			env.g_unit = unit
			env.g_target = targets
			if unit then
				print('express unit:', unit.id)
			end
			if targets then
				print('express target:', #targets)
			end
			return fc(...)
		end
		formulas[express] = func
	end
	return func
end