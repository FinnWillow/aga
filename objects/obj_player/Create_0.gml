coord = new Vector2(x, y)
move_dir = new Vector2(0, 0)
move_spd = new Vector2(0, 0)
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

// -------- debug
debug_target(global)
debug_add("Player", "player_move_speed", DBG.SLIDER_INT, 1, 8)
debug_target(id)
debug_add("Player", "x", DBG.WATCH)
debug_add("Player", "y", DBG.WATCH)

blocked = function (_x, _y) {
    return place_meeting(_x, _y, obj_col) || tile_meeting(_x, _y)
}

/// Moves along ONE axis by (dx, dy) (one of them is 0).
/// If blocked while walking straight (one key), slips sideways around corners and along diagonals.
move_axis = function (dx, dy) {
    if (dx == 0 && dy == 0) {
        return
    }
    
    // the plain move
    if (!blocked(coord.x + dx, coord.y + dy)) {
        coord.x += dx
        coord.y += dy
        return
    }
    
    // only slip when walking straight; with two keys held the other axis already slides
    if (move_spd.x != 0 && move_spd.y != 0) {
        return
    }
    
    // our speed this frame (one of them is 0)
    var step  = abs(dx) + abs(dy)
    
    // the sideways axis: perpendicular to the move
    var side_x = (dx == 0) ? 1 : 0
    var side_y = (dy == 0) ? 1 : 0
    
    // try slipping 1 px sideways, then 2, ... up to twice our speed (walls up to ~63 degrees)
    for (var nudge = 1; nudge <= step * 2; nudge++) {
        for (var side = -1; side <= 1; side += 2) {  // both sides: -1 and +1
            // forward + sideways, then scaled back so the total distance equals our speed
            var raw_x = dx + side_x * nudge * side
            var raw_y = dy + side_y * nudge * side
            var scale = step / point_distance(0, 0, raw_x, raw_y)
            var test_x = coord.x + raw_x * scale
            var test_y = coord.y + raw_y * scale
            
            // test exactly where we'll end up
            if (!blocked(test_x, test_y)) {
                coord.x = test_x
                coord.y = test_y
                return
            }
        }
    }
}