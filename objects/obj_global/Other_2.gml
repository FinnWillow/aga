/// setup

// -------- state
// global
global.default_fscn_state = true
global.u_pallette_handle = shader_get_uniform(sha_pallette, "u_pallette")

var tile_collision = build_tile_collision(spr_tileset_collision);
global.tile_shapes = tile_collision.segments;
global.tile_masks = tile_collision.masks;

// player
global.player_move_speed = 2


// -------- keys
global.keymap = {
    move_forward :      { device: DEVICE.KEYBOARD, code: ord("W") },
    move_backward :     { device: DEVICE.KEYBOARD, code: ord("S") },
    move_leftward :     { device: DEVICE.KEYBOARD, code: ord("A") },
    move_rightward :    { device: DEVICE.KEYBOARD, code: ord("D") },
    dodge:              { device: DEVICE.KEYBOARD, code: vk_space },
    
    attack:     { device: DEVICE.MOUSE,    code: mb_left },
    action:     { device: DEVICE.MOUSE,    code: mb_right },
    reload:     { device: DEVICE.KEYBOARD, code: ord("R") },
    parry:      { device: DEVICE.KEYBOARD, code: vk_shift },
    item_next:  { device: DEVICE.WHEEL,    code: "down" },
    item_prev:  { device: DEVICE.WHEEL,    code: "up" },
    item_1:     { device: DEVICE.KEYBOARD, code: ord("1") },
    item_2:     { device: DEVICE.KEYBOARD, code: ord("2") },
    item_3:     { device: DEVICE.KEYBOARD, code: ord("3") },
    item_4:     { device: DEVICE.KEYBOARD, code: ord("4") },
    
    interact:   { device: DEVICE.KEYBOARD, code: ord("E") },
    journal:    { device: DEVICE.KEYBOARD, code: vk_tab },
    pause:      { device: DEVICE.KEYBOARD, code: vk_escape },
    confirm:    { device: DEVICE.KEYBOARD, code: vk_enter },
    
    fullscreen: { device: DEVICE.KEYBOARD, code: vk_f11 },
    debug_menu: { device: DEVICE.KEYBOARD, code: vk_f1 },
}

// -------- local
currnet_fscn = global.default_fscn_state


// -------- startup functions
window_set_fullscreen(global.default_fscn_state)