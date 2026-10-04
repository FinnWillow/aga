/// Global Changers


// -------- fullscreen mode
if (keymap_check_pressed(global.keymap.fullscreen)) {
    currnet_fscn = !currnet_fscn
    window_set_fullscreen(currnet_fscn)
}