local skill_calculate = {}

skill_calculate.unit = nil
skill_calculate.target = nil

local formulas = {}

function skill_calculate.init()
	-- csv env config
	-- function name, function string
	-- calc.env_funcs['function name'] = load('function string')
	calc.env_funcs['get_hp'] = load('return get_attr("hp")')

	-- csv skill config
	-- function key, function string
	-- calc.env_funcs['function key'] = load('function string')()
	formulas[1] =  load("return function() return get_str() end", nil, nil, calc.env_funcs)()
	formulas[4] =  load("return function(attr) return get_attr(attr) end", nil, nil, calc.env_funcs)()
end

function skill_calculate.calculate( express, unit, target)
	skill_calculate.unit = unit
	skill_calculate.target = target
	
	local func = formulas[express]
	if not func then
		func = load(expresss, nil, nil, calc.env_funcs)()
		formulas[express] = func
	end
	return func(...)
end

return skill_calculate