// the object to snap the camera to.
target = noone

// how far should the camera's look ahead be.
displacement = 32.0

// the winth and height of the camera.
camera_width = camera_get_view_width(view_camera[0])
camera_height = camera_get_view_height(view_camera[0])

// how much to zoom it in
zoom_factor = 1

// singlue use flag; disables lerping for one frame and
// makes the camera snap to its target
snap = true

// disables lerping completely. use this once instead of
// setting snap each frame, if the desired result is a
// no lerp camera.
fixed = false;

// disables the look ahead of the camera. equivalent to
// displacement = 0 visually, but more direct.
look_ahead = true

dir_x = 0
dir_y = 0

image_index = 1
view_camera[0] = camera_create_view(0, 0, camera_width, camera_height, 0, noone, -1, -1, -1, -1)
cam_0 = view_camera[0]
