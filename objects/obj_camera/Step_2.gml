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

var view_x = camera_get_view_x(cam_0)
var view_y = camera_get_view_y(cam_0)

// zoom the camera
var lerp_h = lerp(camera_get_view_height(cam_0), zoom_factor * camera_height, snap || fixed ? 1 : 0.1)

var new_h = clamp(lerp_h, 0, room_height)
var new_w = new_h * (camera_width / camera_height)
camera_set_view_size(cam_0, new_w, new_h)

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
var local_mx = mouse_x - view_x - new_w / 2
var local_my = mouse_y - view_y - new_h / 2

var local_dist = abs(point_distance(0, 0, local_mx, local_my))
var ring = mouse_lean ? clamp(local_dist - ring_0, 0, ring_1 - ring_0) : 0

var offset_x = goto_x + (local_mx / local_dist) * ring * lean_force
var offset_y = goto_y + (local_my / local_dist) * ring * lean_force

var new_x = lerp(view_x, offset_x, snap || fixed ? 1 : 0.1)
var new_y = lerp(view_y, offset_y, snap || fixed ? 1 : 0.1)

camera_set_view_pos(cam_0, new_x, new_y)

// snap is a "one frame" trigger to position and zoom the camera without
// lerp. if you want to use it to disable the lerp for longer, use the
// "fixed" flag. must be used in the Begin Step or Step event.
snap = false