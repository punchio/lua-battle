local log_detail_level = 1
local log_info_level = 2
local log_warning_level = 3
local log_error_level = 4

local log_level = {}
log_level["detail"] = false
log_level["info"] = true
log_level["warning"] = false
log_level["error"] = false


function log_print( level, ... )
	if log_level[level] == true then
		print(level, ...)
	end
end