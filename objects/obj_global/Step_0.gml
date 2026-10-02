/// Global Changers


// -------- fullscreen mode
if (keyboard_check_pressed(global.key_switch_fscn) || keyboard_check_pressed(global.key_alt_switch_fscn)) {
    currnet_fscn = !currnet_fscn
    window_set_fullscreen(currnet_fscn)
}


// -------- alt shutdown
if (keyboard_check(global.key_combo) && keyboard_check_pressed(global.key_alt_shutdown)) {
    game_end()
}