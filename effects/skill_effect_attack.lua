local start_attack = false
local function skill_effect_attack()
	if not is_idle() then
		start_attack = false
		return 
	end
	local tar = get_closest_enemy()
	if not tar or not can_attack(tar) then 
		start_attack = false
		return 
	end

	print(start_attack)
	if start_attack == false then
		start_attack = true
		-- first attack
		print('start_attack.')
	end

	add_hp(-30, tar)
end

return skill_effect_attack()