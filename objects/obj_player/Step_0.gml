// -------- state
var move_forward = keyboard_check(global.key_move_forward)
var move_backward = keyboard_check(global.key_move_backward)
var move_leftward = keyboard_check(global.key_move_leftward)
var move_rightward = keyboard_check(global.key_move_rightward)

move_dir.set(
    move_rightward - move_leftward, // x+ = right; x- = left; left = 0 - 1. right = 1 - 0
    move_backward - move_forward    // y+ = down;  y- = up;   up   = 0 - 1. down  = 1 - 0
)

move_dir = move_dir.nor();

move_spd.set(
    move_dir.x * global.player_move_speed,
    move_dir.y * global.player_move_speed 
)

var prior_coord = coord.cpy()

// -------- movement and collision
if (!place_meeting(coord.x + move_spd.x, coord.y, obj_col)) {
    coord.x += move_spd.x
}

if (!place_meeting(coord.x, coord.y + move_spd.y, obj_col)) {
    coord.y += move_spd.y
}

x = coord.x
y = coord.y

// -------- animation

var coord_diff = coord.subs(prior_coord);

if (coord_diff.length() == 0) {
    image_speed = 0
    image_index = 0
    has_moved = false
} else {
    image_speed = 1
    
    if (!has_moved) {
        image_index = 1
        has_moved = true
    }
    
    // keep the current facing while we're still moving that way
    var still_valid  = (last_move == MoveDir.UP    && coord_diff.y < 0)
                    || (last_move == MoveDir.DOWN  && coord_diff.y > 0)
                    || (last_move == MoveDir.LEFT  && coord_diff.x < 0)
                    || (last_move == MoveDir.RIGHT && coord_diff.x > 0)
    
    // otherwise pick a new one; only one branch can run
    if (!still_valid) {
        if (coord_diff.y < 0) {
            last_move = MoveDir.UP
        } else if (coord_diff.y > 0) {
            last_move = MoveDir.DOWN
        } else if (coord_diff.x < 0) {
            last_move = MoveDir.LEFT
        } else if (coord_diff.x > 0) {
            last_move = MoveDir.RIGHT
        }
    }
    
    sprite_index = player_sprites[last_move]
}
