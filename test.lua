--local s = 'get_hp(ab, c); get_enemy_agi(1, 2)'
--local trans = string.gsub(s, '_(%w+)%(', '(%1, ')
--print(trans)
--
--local v = {}
--
--v[1] = 1
--v[2] = 2
--v[3] = 2
--for i, _v in ipairs( v ) do
--	print( i, _v )
--end

local a1 = {}
a1.a = 0
function a1.init()
	a1.a = 1
end

a1.print = print
local s = "local function tmp()	print('a') end return tmp()"
local f = load(s, nil, nil, a1)
f()

local fc = loadfile('effects/buff_example.lua', nil, a1)
print(type(fc()))
for k,v in pairs(fc()) do
	print(k,v)
end
