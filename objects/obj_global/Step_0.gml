/// Global Changers


// -------- debug menu
if (DEBUG && keymap_check_pressed(global.keymap.debug_menu)) {
    debug_toggle()
}
debug_update()


// -------- fullscreen mode
if (keymap_check_pressed(global.keymap.fullscreen)) {
    currnet_fscn = !currnet_fscn
    window_set_fullscreen(currnet_fscn)
    
    if (!currnet_fscn) {
        render_fit_window()
    }
}

if (keymap_check_pressed(global.keymap.dodge)) {
    obj_camera.shake = true
}