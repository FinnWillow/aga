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
var new_x = lerp(view_x, goto_x, snap || fixed ? 1 : 0.1)
var new_y = lerp(view_y, goto_y, snap || fixed ? 1 : 0.1)
camera_set_view_pos(cam_0, new_x, new_y)

// mouse lean



// snap is a "one frame" trigger to position and zoom the camera without
// lerp. if you want to use it to disable the lerp for longer, use the
// "fixed" flag.
if (snap) {
    snap = false
}