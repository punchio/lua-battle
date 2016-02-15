--[[    buff.total_time = 10
    buff.period_time = 2
    buff.create_effect = "return function() return add_hp(100) end"
    buff.destroy_effect = "return function() return add_hp(-100) end"
    buff.period_effect = "return function() return add_hp(10) end"
    self:init_default_data( buff )
    ]]
local buff = {
	total_time = 0,
	period_time = 1,
	--period_effect = 'effects/skill_effect_attack.lua'

	start_attack = false,

 	period_effect = function ()
		if not is_idle() then
			buff.start_attack = false
			return 
		end
		local tar = get_closest_enemy()
		if not tar or not can_attack(tar) then 
			buff.start_attack = false
			return 
		end

		if buff.start_attack == false then
			buff.start_attack = true
			-- first attack
			print('start_attack.')
		end

		add_hp(-30, tar)
	end

}
return buff