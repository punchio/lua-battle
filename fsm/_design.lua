--[[
			状态机设计
	每个状态包含enter，exit，update，check_transition
	当前状态检查check_transition，如果返回值与当前状态不一致，则退出当前状态exit，进入新的状态enter，
	设置新状态为当前状态，更新当前状态update
--]]