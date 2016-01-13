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
	{ 1, --unit id
	  {
		[1] = {action = 'move', target = 2}		-- frame = 1, action = move, target = unit 1
		[3] = {action = 'attack', target = 2}
		[5] = {action = 'spell', target = 2}
	  }
	}
	,
	{ 2,
	  {
		[1] = {action = 'move', target = 1}
		[3] = {action = 'attack', target = 1}
		[5] = {action = 'spell', target = 1}
	  }
	}
	,
	{ 3,
	  {
		[1] = {action = 'move', target = 4}
		[3] = {action = 'attack', target = 4}
		[5] = {action = 'spell', target = 4}
	  }
	}
	,
	{ 4,
	  {
		[1] = {action = 'move', target = 1}
		[3] = {action = 'attack', target = 1}
		[5] = {action = 'spell', target = 1}
	  }
	}
}