require('log')
local env = require("env")
local formulas = {}

function Parse( express )
	local func = formulas[express]
	if not func then
		local fc = load(express, nil, nil, env)
		if fc == nil then
			fc = loadfile(express, nil, env)
			log_print('detail', 'load file', fc == nil, express)
		else
		    fc = fc()
		    log_print('detail', 'load string', fc == nil, express)
		end
		func = function ( unit, targets, ... )
			--log_print('detail', express)
			env.g_unit = unit
			env.g_target = targets
			if unit then
				log_print('detail', 'express unit:', unit.id)
			end
			if targets then
				log_print('detail', 'express target:', #targets)
			end
			return fc(...)
		end
		formulas[express] = func
	end
	return func
end

function Parse_tbl( file )
	print(file)
	local func = formulas[file]
	if not func then
		local fc = loadfile(file, nil, env)
		if not fc then
			log_print('detail', 'load file', file, ' failed.')
			return nil
		end
		print(type(fc))
		func = fc()
		print(type(func))
		formulas[file] = func
	end
	return func
end