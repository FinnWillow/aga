#macro TILE_SIZE 16

/// Reads the black/white collision image (same layout as the tileset).
/// Returns { segments, masks }, both indexed by tile index:
///   segments[i] = array of [x1, y1, x2, y2] outlines (for debug drawing)
///   masks[i]    = array of 16 numbers, one per pixel row; bit n set = pixel n is solid
function build_tile_collision(sprite) {
    var img_w = sprite_get_width(sprite)
    var img_h = sprite_get_height(sprite)
    var cols  = img_w div TILE_SIZE
    var rows  = img_h div TILE_SIZE
    
    // 1. draw the image onto a surface
    sprite_prefetch(sprite)
    var surface = surface_create(img_w, img_h)
    surface_set_target(surface)
    draw_clear_alpha(c_black, 0)
    draw_sprite(sprite, 0, 0, 0)
    surface_reset_target()
    
    // 2. copy the pixels into a buffer
    var buffer = buffer_create(img_w * img_h * 4, buffer_fixed, 1)
    buffer_get_surface(buffer, surface, 0)
    surface_free(surface)
    
    // 3. trace every tile
    var segments = array_create(cols * rows)
    var masks    = array_create(cols * rows)
    for (var row = 0; row < rows; row++) {
        for (var col = 0; col < cols; col++) {
            var index = row * cols + col
            segments[index] = trace_tile(buffer, img_w, col, row)
            masks[index]    = build_tile_mask(buffer, img_w, col, row)
        }
    }
    
    buffer_delete(buffer)
    return { segments: segments, masks: masks }
}

/// One number per pixel row. Bit n of row y is 1 if pixel (n, y) is solid.
function build_tile_mask(buffer, img_w, col, row) {
    var mask = array_create(TILE_SIZE, 0)
    for (var py = 0; py < TILE_SIZE; py++) {
        var bits = 0
        for (var px = 0; px < TILE_SIZE; px++) {
            if (tile_pixel_solid(buffer, img_w, col, row, px, py)) {
                bits |= (1 << px) // switch on bit px
            }
        }
        mask[py] = bits
    }
    return mask
}

/// true if pixel (px, py) of tile (col, row) is white.
/// Anything outside the tile counts as empty, so every shape is closed at its border.
function tile_pixel_solid(buffer, img_w, col, row, px, py) {
    if (px < 0 || py < 0 || px >= TILE_SIZE || py >= TILE_SIZE) {
        return false
    }
    
    var image_x = col * TILE_SIZE + px     // pixel position in the whole image
    var image_y = row * TILE_SIZE + py
    var offset  = (image_y * img_w + image_x) * 4
    return buffer_peek(buffer, offset, buffer_u8) > 127
}

/// Finds the outline of the white pixels in one tile, as straight segments.
function trace_tile(buffer, img_w, col, row) {
    var segments = [];
    
    // ---- horizontal edges: the lines BETWEEN pixel rows (y = 0..16)
    for (var ly = 0; ly <= TILE_SIZE; ly++) {
        var run_start = -1; // -1 = we're not inside a run of edges
    
        // px goes one past the end (TILE_SIZE) so a run that reaches the border still gets closed
        for (var px = 0; px <= TILE_SIZE; px++) {
            var is_edge = false;
            if (px < TILE_SIZE) {
                var above = tile_pixel_solid(buffer, img_w, col, row, px, ly - 1);
                var below = tile_pixel_solid(buffer, img_w, col, row, px, ly);
                is_edge = (above != below); // one solid, one empty = outline
            }
            
            if (is_edge && run_start == -1) {
                run_start = px;                                 // a run begins
            } else if (!is_edge && run_start != -1) {
                array_push(segments, [run_start, ly, px, ly]);  // a run ends: save it
                run_start = -1;
            }
        }
    }
    
    // ---- vertical edges: the lines BETWEEN pixel columns (x = 0..16)
    for (var lx = 0; lx <= TILE_SIZE; lx++) {
        var run_start = -1;
        for (var py = 0; py <= TILE_SIZE; py++) {
            var is_edge = false;
            if (py < TILE_SIZE) {
                var left  = tile_pixel_solid(buffer, img_w, col, row, lx - 1, py);
                var right = tile_pixel_solid(buffer, img_w, col, row, lx, py);
                is_edge = (left != right);
            }
            
            if (is_edge && run_start == -1) {
                run_start = py;
            } else if (!is_edge && run_start != -1) {
                array_push(segments, [lx, run_start, lx, py]);
                run_start = -1;
            }
        }
    }
    
    return segments;
}

/// Draws the collision outlines of the tiles around (wx, wy) that block the given level.
/// radius = tiles in each direction (1 = a 3x3 area).
function draw_tile_collision(level, wx, wy, radius) {
    var maps = get_collision_tilemaps(level)
    var tile_cx = floor(wx / TILE_SIZE)
    var tile_cy = floor(wy / TILE_SIZE)
    
    draw_set_colour(c_red)
    for (var ty = tile_cy - radius; ty <= tile_cy + radius; ty++) {
        for (var tx = tile_cx - radius; tx <= tile_cx + radius; tx++) {
            var tile_x = tx * TILE_SIZE
            var tile_y = ty * TILE_SIZE
            
            for (var m = 0; m < array_length(maps); m++) {
                var data = tilemap_get_at_pixel(maps[m], tile_x, tile_y)
                
                if (data == -1) {
                    continue // outside the tilemap
                }
                
                var segments = global.tile_shapes[tile_get_index(data)]
                
                for (var s = 0; s < array_length(segments); s++) {
                    var seg = segments[s]
                    draw_line(tile_x + seg[0], tile_y + seg[1], tile_x + seg[2], tile_y + seg[3])
                }
            }
        }
    }
    
    draw_set_colour(c_white)
}

/// All tilemaps that block an object standing on this level.
function get_collision_tilemaps(level) {
    if (level < 0 || level >= array_length(global.collision_tilemaps)) {
        return []
    }   
    
    return global.collision_tilemaps[level]
}

/// true if the rectangle (world pixels, edges included) touches any solid
/// collision pixel that blocks the given level.
function tile_rect_collision(left, top, right, bottom, level) {
    var maps = get_collision_tilemaps(level)
    if (array_length(maps) == 0) {
        return false
    }
    
    left   = floor(left)
    top    = floor(top)
    right  = floor(right)
    bottom = floor(bottom)
    
    // which tiles the rectangle touches
    var tx1 = floor(left   / TILE_SIZE)
    var tx2 = floor(right  / TILE_SIZE)
    var ty1 = floor(top    / TILE_SIZE)
    var ty2 = floor(bottom / TILE_SIZE)
    
    for (var ty = ty1; ty <= ty2; ty++) {
        for (var tx = tx1; tx <= tx2; tx++) {
            var tile_x = tx * TILE_SIZE
            var tile_y = ty * TILE_SIZE
            
            // the part of the rectangle that lies inside this tile, in tile pixels (0..15)
            var px1 = max(left   - tile_x, 0)
            var px2 = min(right  - tile_x, TILE_SIZE - 1)
            var py1 = max(top    - tile_y, 0)
            var py2 = min(bottom - tile_y, TILE_SIZE - 1)
            
            // a number with bits px1..px2 switched on
            var x_bits = ((1 << (px2 + 1)) - 1) ^ ((1 << px1) - 1)
            
            for (var m = 0; m < array_length(maps); m++) {
                var data = tilemap_get_at_pixel(maps[m], tile_x, tile_y)
                if (data == -1) {
                    continue
                }
                
                var mask = global.tile_masks[tile_get_index(data)]
                for (var py = py1; py <= py2; py++) {
                    if ((mask[py] & x_bits) != 0) {
                        return true // a solid pixel inside the rectangle
                    }
                }
            }
        }
    }
    return false
}

/// Like place_meeting, but against tile collision.
/// Call it from the moving instance: uses its collision mask and its draw_level.
function tile_meeting(_x, _y) {
    var spr = (mask_index != -1) ? mask_index : sprite_index // the sprite whose mask we use
    var left   = _x - sprite_get_xoffset(spr) + sprite_get_bbox_left(spr)
    var top    = _y - sprite_get_yoffset(spr) + sprite_get_bbox_top(spr)
    var right  = _x - sprite_get_xoffset(spr) + sprite_get_bbox_right(spr)
    var bottom = _y - sprite_get_yoffset(spr) + sprite_get_bbox_bottom(spr)
    return tile_rect_collision(left, top, right, bottom, draw_level)
}