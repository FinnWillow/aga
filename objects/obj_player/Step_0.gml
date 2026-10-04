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

// -------- unstuck: if something put us inside collision, step out to the nearest free spot
if (blocked(x, y)) {
    var freed = false
    for (var dist = 1; dist <= 4 && !freed; dist++) {   // try 1 px away first, then 2, 3, 4
        for (var dir = 0; dir < 360; dir += 45) {        // 8 directions
            var test_x = x + lengthdir_x(dist, dir)
            var test_y = y + lengthdir_y(dist, dir)
            if (!blocked(test_x, test_y)) {
                x = test_x
                y = test_y
                coord.set(test_x, test_y)
                freed = true
                show_debug_message("UNSTUCK: moved " + string(dist) + " px at " + string(dir) + " deg")
                break
            }
        }
    }
}

var prior_coord = coord.cpy()

// -------- movement and collision
move_axis(move_spd.x, 0)
move_axis(0, move_spd.y)

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
    var still_valid  = (last_move == MOVE_DIR.UP    && coord_diff.y < 0)
                    || (last_move == MOVE_DIR.DOWN  && coord_diff.y > 0)
                    || (last_move == MOVE_DIR.LEFT  && coord_diff.x < 0)
                    || (last_move == MOVE_DIR.RIGHT && coord_diff.x > 0)
    
    // otherwise pick a new one; only one branch can run
    if (!still_valid) {
        if (coord_diff.y < 0) {
            last_move = MOVE_DIR.UP
        } else if (coord_diff.y > 0) {
            last_move = MOVE_DIR.DOWN
        } else if (coord_diff.x < 0) {
            last_move = MOVE_DIR.LEFT
        } else if (coord_diff.x > 0) {
            last_move = MOVE_DIR.RIGHT
        }
    }
    
    sprite_index = player_sprites[last_move]
}