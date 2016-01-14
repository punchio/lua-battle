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
		{action = 'spell', value = 1},
		{action = 'attack'},
		{action = 'move', value = {0, 0, 0}},
		{action = 'attack'},
	}
	,
	[2] = {
		{action = 'move', value =  {0, 0, 0}},
		{action = 'attack', value = 1},
		{action = 'spell', value = 2},
		{action = 'attack'},
	}
	,
	[3] = {
		{action = 'move', value =  {0, 0, 0}},
		{action = 'attack', value = 4},
		{action = 'spell', value = 3},
		{action = 'attack'},
	}
	,
	[4] = {
		{action = 'attack', value = 1},
		{action = 'spell', value = 4},
		{action = 'move', value =  {0, 0, 0}},
		{action = 'attack'},
	}
}

return actions