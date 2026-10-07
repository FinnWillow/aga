if (image_index == 0) {
    image_index = 1
}

if (!instance_exists(target)) {
    return
}

// place the camera with its animation on the target.
x = target.x
y = target.y

// if the target has a move_dir, set it so it can be used in the 
// overshot of the camera. the look_ahead flag is used to optionally 
// disable or enable the look ahead feature of the camera.
if (variable_instance_exists(target, "move_dir") && look_ahead) {
    dir_x = target.move_dir.x
    dir_y = target.move_dir.y
}

var view_x = cam_x
var view_y = cam_y

// zoom the camera. zoom is in pixels; once close enough, land exactly
// on the target so zoom 0 ends up back on an integer scale.
var zoom_h = camera_height - zoom
var lerp_h = lerp(cam_h, zoom_h, snap || !can_move_lean ? 1 : 0.1)
if (abs(lerp_h - zoom_h) < 0.05) {
    lerp_h = zoom_h
}

var new_h = clamp(lerp_h, 1, room_height)
var new_w = new_h * (camera_width / camera_height)

// position the camera.
var goto_x = x + (dir_x * displacement) - (new_w * 0.5)
var goto_y = y + (dir_y * displacement) - (new_h * 0.5)

// mouse lean.
// take the position of the camera, and the position of the cursor, 
// relative to the current camera position. there are 3 rings of distance.
// ring 0 does not lean the camera at all.
// ring 1 does lean based on a relative distance from that ring, as if the ring 
// itself extended from the start of ring 0 to the end of ring 1.
// ring 2 does no extra leam and instead teats the lean as if the cursor was on
// the end of ring 1.
// can be disabled and lerps.
var local_mx = render_mouse_x() - view_x - new_w / 2
var local_my = render_mouse_y() - view_y - new_h / 2

var local_dist = point_distance(0, 0, local_mx, local_my)
if (local_dist == 0) {
    local_dist = 0.01
}

var ring = can_mouse_lean ? clamp(local_dist - ring_0, 0, ring_1 - ring_0) : 0

var offset_x = goto_x + (local_mx / local_dist) * ring * lean_force
var offset_y = goto_y + (local_my / local_dist) * ring * lean_force

var new_x = lerp(view_x, offset_x, snap || !can_move_lean ? 1 : 0.1)
var new_y = lerp(view_y, offset_y, snap || !can_move_lean ? 1 : 0.1)

// move the camera up and down on an interval to give a camera shake effect.
// intensity = how strong the effect is
// falloff = how much it should drop in intensity each frame, where 0 is none,
// 1 is the same as disableing it (ish) and -1 is automatic (from the duration)
// duration = how many frames the shake lasts for.

if (shake && can_shake) {
    curr_period = intensity
    curr_shake_frame = 0
}

if (curr_shake_frame != -1 && curr_shake_frame < duration) {
    new_y += curr_period
    var next_dir = sign(-curr_period)
    var curr_falloff = falloff != -1 
        ? falloff
        : intensity / duration
    
    curr_period = (abs(curr_period) - curr_falloff) * next_dir
    
    curr_shake_frame++
}

cam_x = new_x
cam_y = new_y
cam_h = new_h
render_set_view(cam_0, new_x, new_y, new_w, new_h)

// snap is a "one frame" trigger to position and zoom the camera without
// lerp. if you want to use it to disable the lerp for longer, use the
// "can_move_lean" flag. must be used in the Begin Step or Step event.
snap = false

// shake is another "one frame" trigger to shake the camera with a given
// intensity and duration. can be disabled with "can_shake".
shake = false