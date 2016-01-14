local skill = {
	[1] = {
			buff = { effect = {str = {10, -0.1, 0.2}}, time = 1000}, 
			damage = { effect = {str = 0.2, hp = 0.05}, period = 2, time = 10}, 
			ready_time = 2, 
			spell_time = 10},
	[2] = {
			buff = { effect = {str = {20, 0.1, 0.2}}, time = 1000}, 
			damage = { effect = {str = 0.2}, period = 2, time = 10}, 
			ready_time = 2, 
			spell_time = 10},
	[3] = {
			buff = { effect = {str = {30, 0.2, 0.1}}, time = 1000}, 
			damage = { effect = {str = 0.2}, period = 2, time = 10}, 
			ready_time = 2, 
			spell_time = 10},
	[4] = {
			buff = { effect = {str = {40, 0.3, 0.4}}, time = 1000}, 
			damage = { effect = {str = 0.2}, period = 2, time = 10}, 
			ready_time = 2, 
			spell_time = 10},
}

return skill