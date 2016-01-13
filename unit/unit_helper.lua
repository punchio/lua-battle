require("new")
local unit = require("unit")
local unit_mgr = require("unit_mgr")
local fsm_mgr = require("fsm_mgr")
local ai_mgr = require("example")

local unit_helper = {}

function unit_helper.random_unit( )
	-- body
	print('unit helper random units.')
	local u = new(unit, unit_mgr.pop_free_id())
	u:set_raw_attribute('side', u.id % 2)
	print('side:' .. u:get_raw_attribute('side'))

	u:set_raw_attribute('maxhp', 100)
	u:set_raw_attribute('hp', 100)
	print('hp:' .. u:get_raw_attribute('hp'))

	u:set_raw_attribute('str', math.random(10) + 50)
	print('str:' .. u:get_raw_attribute('str'))

	u:set_raw_attribute('vel', math.random(3) + 3)
	print('vel:' .. u:get_raw_attribute('vel'))

	u:set_raw_attribute('pos', {math.random(50) + 50, math.random(50) + 50, math.random(50) + 50})
	print('pos:' .. u:get_raw_attribute('pos')[1], u:get_raw_attribute('pos')[2], u:get_raw_attribute('pos')[3])

	u:set_raw_attribute('move', nil)
	u:set_raw_attribute('attack_range', (math.random() > 0.5 and 3) or 10)
	print('range:' .. u:get_raw_attribute('attack_range'))
	u:set_raw_attribute('attack', 0)
	u:set_raw_attribute('defence', 0)
	u:set_raw_attribute('skill', {0})
	u:set_raw_attribute('spell', 0)
	u:set_raw_attribute('attack_speed', math.random(3) + 3)
	print('speed:' .. u:get_raw_attribute('attack_speed'))
	u:set_raw_attribute('attack_time', 0)
	u:set_raw_attribute('state_id', 'invalid')
	return u
end

function unit_helper.distance(pos1, pos2)
	-- body
	if not pos1 or not pos2 then
		return 100
	end
	return math.sqrt((pos1[1] - pos2[1]) * (pos1[1] - pos2[1]) + (pos1[2] - pos2[2]) * (pos1[2] - pos2[2]) + (pos1[3] - pos2[3]) * (pos1[3] - pos2[3]))
end

function unit_helper.square_distance(pos1, pos2)
	if not pos1 or not pos2 then
		return 10000
	end
	return (pos1[1] - pos2[1]) * (pos1[1] - pos2[1]) + (pos1[2] - pos2[2]) * (pos1[2] - pos2[2]) + (pos1[3] - pos2[3]) * (pos1[3] - pos2[3])
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
	local side = u:get_raw_attribute('side')
	local range = u:get_raw_attribute('attack_range')
	local target = nil
	local min_dist = 0
	for _, v in pairs( unit_mgr.units ) do
		if v:get_raw_attribute('side') ~= side and v:get_raw_attribute('hp') > 0 then
			local dist = unit_helper.distance(u:get_raw_attribute('pos'), v:get_raw_attribute('pos'))
			if dist < range and (min_dist == 0 or min_dist > dist) then
				min_dist = dist
				target = v
			end
		end
	end

	if target then
		unit:set_raw_attribute('attack', target.id)
		print('unit:' .. u.id .. ' get target:' .. target.id)
	else
		print('unit:' .. u.id .. ' cant find nearby target.')
	end
	return target
end

function unit_helper.find_closest_target(u)
	-- body
	local side = u:get_raw_attribute('side')
	local range = u:get_raw_attribute('attack_range')
	local target = nil
	local min_dist = 0
	for _, v in pairs( unit_mgr.units ) do
		if v:get_raw_attribute('side') ~= side and v:get_raw_attribute('hp') > 0 then
			local dist = unit_helper.distance(u:get_raw_attribute('pos'), v:get_raw_attribute('pos'))
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

	return unit:get_raw_attribute('attack_range') > unit_helper.distance(unit:get_raw_attribute('pos'), target:get_raw_attribute('pos'))
end

function unit_helper.get_enemy_units( side )
	-- body
	local enemy = {}
	for _, v in pairs( unit_mgr.units ) do
		if v:get_raw_attribute('side') ~= side then
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
	local move = u:get_raw_attribute('move')
	if not move then
		return nil
	end

	local t = type(move)
	if t == 'number' then
		local tar = unit_helper.get_unit(move)
		if not tar then
			return nil
		end
		return tar:get_raw_attribute('pos')
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
	local pos, move = u:get_raw_attribute('pos'), unit_helper.get_move_pos(u)
	if not move then
		print('unit_helper tar lost, unit id:' .. u.id)
		return
	end

	local move_dist = u:get_attribute('vel') * move_time
	local dist = unit_helper.distance(pos, move)
	if dist > move_dist then
		u:set_raw_attribute('pos', unit_helper.moveto(pos, move, move_dist))
	else
		u:set_raw_attribute('pos', move)
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
		if v:get_raw_attribute('state_id') ~= 'dead' then
			local side = v:get_raw_attribute('side')
			if not alive_side then
				alive_side = side
			elseif alive_side ~= side then
				return false
			end
		end
	end

	return true
end

function unit_helper.init()
	-- body
	for i = 1, 10 do
		local u = unit_helper.random_unit()
		unit_mgr.add_unit(u)
	end
end

function unit_helper.update(time_delta)
	--input operations
	for _, v in pairs( unit_mgr.units ) do
		if v:get_raw_attribute('state_id') == 'idle' then
			local unit_ai = ai_mgr[v.id]
			if unit_ai then
				print('unit id:' .. v.id .. '|type u:' .. type(unit_ai) .. '|length:' .. #unit_ai)
				local idx = v:get_raw_attribute('ai') or 1
				if idx > #unit_ai then
					idx = 1
				end
				print('idx:' .. idx)
				local ai = unit_ai[idx]
				print('type value:' .. type(ai['value']) .. ' idx:' .. idx)
				v:set_raw_attribute(ai['action'], ai['value'])
				v:set_raw_attribute('ai', idx + 1)
			end
		end
	end
end

return unit_helper