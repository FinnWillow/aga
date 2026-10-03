coord = new scr_vector_2(x, y)
move_dir = new scr_vector_2(0, 0)
move_spd = new scr_vector_2(0, 0)
has_moved = false
last_move = MOVE_DIR.DOWN;

player_sprites = [
    spr_player_up,
    spr_player_down,
    spr_player_left,
    spr_player_right
]

obj_camera.target = id
obj_camera.snap = true

