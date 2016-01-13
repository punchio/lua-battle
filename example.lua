--[[
1. 普通攻击
2. 特殊攻击，即进入攻击状态的第一次攻击
3. 伤害技能
4. 状态技能
5. 召唤技能
6. 被动技能
7. 复杂技能
--]]

local actions = {
	[1] = { -- unit id
		{action = 'move', value = {10, 20, 30}},		-- frame = 1, action = move, value = unit 1
		{action = 'spell'},
		{action = 'attack', value = 2}
	}
	,
	[2] = {
		{action = 'move', value =  {10, 20, 30}},
		{action = 'attack', value = 1},
		--{action = 'spell', value = 1}
	}
	,
	[3] = {
		{action = 'move', value =  {10, 20, 30}},
		{action = 'spell'},
		{action = 'attack', value = 4}
	}
	,
	[4] = {
		{action = 'move', value =  {10, 20, 30}},
		{action = 'attack', value = 1},
		--{action = 'spell', value = 1}
	}
}

return actions