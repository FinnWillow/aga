/// setup

// -------- state
// global
global.default_fscn_state = true
global.can_shutdown = false
global.overr_shutdown_timr = false


// player
global.player_move_speed = 2


// -------- keys
global.key_switch_fscn = vk_f11
global.key_combo = vk_alt
global.key_move_forward = ord("W")
global.key_move_backward = ord("S")
global.key_move_leftward = ord("A")
global.key_move_rightward = ord("D")


// -------- alt keys
global.key_alt_switch_fscn = ord("0")
global.key_alt_shutdown = vk_backspace


// -------- local
currnet_fscn = global.default_fscn_state


// -------- startup functions
window_set_fullscreen(global.default_fscn_state)