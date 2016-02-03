require("new")
require("common")


local unit_helper = {}

--[[
BATTLE_PROPS_CONFIG = {
	MAX_HP = 1,
	CUR_HP = 2,
	PHY_ATK_POWER = 3, 
	PHY_DFS_POWER = 4,
	MAG_ATK_POWER = 5,
	MAG_DFS_POWER = 6,

	STRENGTH = 7,
	AGILITY = 8,
	INTELLIGENCE = 9,
	SPEED = 10,
}]]
local unit_mgr

function unit_helper.init( mgr )
	print('unit_helper.init')
	unit_mgr = mgr
	for i = 1, 10 do
		local u = unit_mgr.random_unit()
		unit_mgr.add_unit(u)
	end
end


function unit_helper.distance(x1, y1, x2, y2)
	return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

function unit_helper.square_distance(x1, y1, x2, y2)
	return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
end

function unit_helper.moveto(pos1, pos2, length)
	-- body
	local distance = unit_helper.distance(pos1, pos2)
	--print('pos1:' .. pos1[1] .. ' ' .. pos1[2] .. ' ' .. pos1[3] .. '|' .. 'pos2:' .. pos2[1] .. ' ' .. pos2[2] .. ' ' .. pos2[3] .. '|distance:' .. distance)
	local x_one, y_one, z_one = (pos2[1] - pos1[1])/distance, (pos2[2] - pos1[2])/distance, (pos2[3] - pos1[3])/distance
	local target = {}
	print('pos1:' .. pos1[1] .. ' ' .. pos1[2] .. ' ' .. pos1[3])
	print('pos2:' .. pos2[1] .. ' ' .. pos2[2] .. ' ' .. pos2[3])
	print('moveto:' .. (x_one * length) .. ' ' .. (y_one * length) .. ' ' .. (z_one * length))
	target[1] = math.floor(pos1[1] + x_one * length)
	target[2] = math.floor(pos1[2] + y_one * length)
	target[3] = math.floor(pos1[3] + z_one * length)
	print('target:' ..  target[1] .. ' ' .. target[2] .. ' ' .. target[3])
	return target
end

function unit_helper.attack_nearby(u)
	-- body
	local side = u.side
	local range = 5
	local target = nil
	local min_dist = 0
	for _, v in pairs( unit_mgr.units ) do
		if v.side ~= side and v:get_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP) > 0 then
			local x1, y1 = u:get_position()
			local x2, y2 = v:get_position()
			local dist = unit_helper.distance(x1, y1, x2, y2)
			if dist < range and (min_dist == 0 or min_dist > dist) then
				min_dist = dist
				target = v
			end
		end
	end

	if target then
		print('unit:' .. u.id .. ' get target:' .. target.id)
	else
		print('unit:' .. u.id .. ' cant find nearby target.')
	end
	return target
end

function unit_helper.find_closest_target(u)
	-- body
	local side = u.side
	local range = 5
	local target = nil
	local min_dist = 0
	for _, v in pairs( unit_mgr.units ) do
		if v.side ~= side and v:get_raw_attribute(BATTLE_PROPS_CONFIG.CUR_HP) > 0 then
			local x1, y1 = u:get_position()
			local x2, y2 = v:get_position()
			local dist = unit_helper.distance(x1, y1, x2, y2)
			if dist < 1000 and (min_dist == 0 or min_dist > dist) then
				min_dist = dist
				target = v
			end
		end
	end

	return target
end

function unit_helper.can_attack( unit, target )
	-- body
	if not unit or not target then
		return false
	end

	return 5 > unit_helper.distance(unit:get_position(), target:get_position())
end

function unit_helper.get_enemy_units( side )
	-- body
	local enemy = {}
	for _, v in pairs( unit_mgr.units ) do
		if v.side ~= side then
			table.insert(enemy, v)
		end
	end

	return enemy
end

function unit_helper.get_unit( id )
	-- body
	return unit_mgr.get_unit(id)
end

function unit_helper.get_move_pos( u )
	-- body
	local move = u:get_dest_position()
	if not move then
		return nil
	end

	local t = type(move)
	if t == 'number' then
		local tar = unit_helper.get_unit(move)
		if not tar then
			return nil
		end
		return tar:get_position()
	elseif t == 'table' then
		return move
	end

	return nil
end

function unit_helper.move(u, move_time)
	-- body
	print('unit_helper move, time:' .. move_time ..'|unit:' .. u.id)
	if move_time <= 0 then
		return
	end
	local pos, move = u:get_position(), unit_helper.get_move_pos(u)
	if not move then
		print('unit_helper tar lost, unit id:' .. u.id)
		return
	end

	local move_dist = u:get_attribute('vel') * move_time
	local dist = unit_helper.distance(pos, move)
	if dist > move_dist then
		u:set_dest_position(unit_helper.moveto(pos, move, move_dist))
	else
		u:set_position(move)
	end
end


--function unit_helper.rand_move_to_enemy( u )
--	-- body
--	local side = u:get_raw_attribute('side')
--	for _, v in pairs( unit_mgr.units ) do
--		if not v:get_raw_attribute('move') and v:get_raw_attribute('side') ~= side then
--			--if math.random(100) < 50 then
--				u:set_raw_attribute('move', v.id)
--				--break
--			--end
--		end
--	end
--end
--
--function unit_helper.flee_from_enemy( u )
--	-- body
--	if u:get_raw_attribute('defence') == 0 then
--		return
--	end
--
--	local defence = unit_mgr.get_unit(u:get_raw_attribute('defence'))
--	if not defence then
--		return
--	end
--
--	local pos1, pos2 = u:get_raw_attribute('pos'), defence.get_raw_attribute('pos')
--	local distance = unit_helper.distance(pos1, pos2)
--	if distance < 1 then distance = 1 end
--	local x_one, y_one, z_one = (pos1[1] - pos2[1])/distance, (pos1[2] - pos2[2])/distance, (pos1[3] - pos2[3])/distance
--	if x_one < 1 then x_one = 1 end
--	if y_one < 1 then y_one = 1 end
--	if z_one < 1 then z_one = 1 end
--
--	local new_pos = {pos1[1] + x_one * 10, pos1[2] + y_one * 10, pos1[3] + z_one * 10}
--	local new_move = {pos1[1] + x_one * 30, pos1[2] + y_one * 30, pos1[3] + z_one * 30}
--	u:set_raw_attribute('pos', new_pos)
--	u:set_raw_attribute('move', new_move)
--end

function unit_helper.check_finish()
	-- body
	local alive_side
	for _, v in pairs( unit_mgr.units ) do
		if v:get_cur_state() ~= STATE_CONFIG.DEAD then
			local side = v.side
			if not alive_side then
				alive_side = side
			elseif alive_side ~= side then
				return false
			end
		end
	end
	print('win side:' .. alive_side)
	return true
end

function unit_helper.update(time_delta)
	--input operations
	--for _, v in pairs( unit_mgr.units ) do
	--	if v:get_raw_attribute('state_id') == 'idle' then
	--		local unit_ai = ai_mgr[v.id]
	--		if unit_ai then
	--			print('unit id:' .. v.id .. '|length:' .. #unit_ai)
	--			local idx = v:get_raw_attribute('ai') or 1
	--			if idx > #unit_ai then
	--				idx = 1
	--				print( 'max to 1:' .. v.id )
	--			end
	--			print('idx:' .. idx)
	--			local action, value = unit_ai[idx]['action'], unit_ai[idx]['value']
	--			print('action:' .. action)
	--			if action == 'attack' and not value then
	--				action = 'auto-attack'
	--				value = true
	--			else
	--				v:set_raw_attribute('auto-attack', false)
	--			end
	--			--print('action:' .. action .. '|value:' .. value)
	--			v:set_raw_attribute(action, value)
	--			v:set_raw_attribute('ai', idx + 1)
	--		end
	--	end
	--end
end

return unit_helper