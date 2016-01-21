local calc = {}
calc.env_funcs = {}

local unit = {}
unit['hp'] = 10
unit['str'] = 1
unit['agi'] = 2 

local unit1 = {}
unit1['hp'] = 0
unit1['str'] = 1
unit1['agi'] = 2 

function get_unit( ... )
	-- body
	return unit1
end

function get_attr( at, u )
	-- body
	u = u or unit
	return u[at]
end

function get_hp(u)
	-- body
	return get_attr('hp', u)
end

function get_str(u)
	-- body
	return get_attr('str', u)
end

function get_agi(u)
	-- body
	return get_attr('agi', u)
end

calc.env_funcs['get_hp'] = get_hp
calc.env_funcs['get_str'] = get_str
calc.env_funcs['get_agi'] = get_agi
calc.env_funcs['get_attr'] = get_attr
calc.env_funcs['get_unit'] = get_unit

function calculate( express, ... )
	-- body
	local fc = load(express, nil, 'bt', calc.env_funcs)
	return fc()
end

print(calculate('local u = get_unit(); return get_hp(u) + get_agi(u) + get_attr("str", u);'))