-- fsm状态在此注册,文件名以fsm_state_开头，状态类型为剩余文件名
local config = {
	"fsm_state_dead",
	"fsm_state_idle",
	"fsm_state_move",
}

config.default = "fsm_state_idle"

return config