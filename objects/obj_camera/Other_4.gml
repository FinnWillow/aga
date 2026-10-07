/// views are per room, so every room gets them switched on here. rooms
/// never need views set up (or a camera placed) in the room editor.
view_enabled = true
view_set_visible(0, true)
view_set_camera(0, cam_0)

// the room's own view port settings would apply until the first End Step
render_set_view(cam_0, cam_x, cam_y, cam_h * (camera_width / camera_height), cam_h)

// whatever we followed belonged to the last room
snap = true
