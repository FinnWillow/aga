// the winth and height of the camera.
camera_width = camera_get_view_width(view_camera[0])
camera_height = camera_get_view_height(view_camera[0])

// the object to snap the camera to.
target = noone

// how far should the camera's look ahead be.
displacement = 20.0

// zoom in pixels. positive zooms in, negative zooms out: the view
// shrinks or grows by this many pixels vertically, the width follows
// the aspect. eases there like the rest of the camera. 0 is the only
// pixel perfect level; anything else is smoothed by the upscale.
zoom = 0

// singlue use flag; disables lerping for one frame and
// makes the camera snap to its can_move_lean
snap = true

// disables lerping of the look ahead completely. 
// use this once instead of setting snap each frame, 
// if the desired result is a no lerp camera.
can_move_lean = true

// disables the look ahead of the camera. equivalent to
// displacement = 0 visually, but more direct.
look_ahead = true

// disables the mouse lean of the camera. equivalent to
// making the cursor always sit in ring 0.
can_mouse_lean = true

// rings; each ring represents where it ends. to get the
// boundary of a ring, take the value of the ring before
// it and subtract it from the current. ring 0 starts at 0.
// ring 2 is from the end of ring 1 to infinity / the end 
// of the screen bounds.
ring_0 = 32
ring_1 = camera_width / 2

// how much the lean impacts the camera offsetting. 0 to 1.
lean_force = 0.3

// camera shake trigger. must be called in Begin Step or
// Step.
shake = false

// disables camera shake
can_shake = true

// how intense should the shake be. keep this value small to
// not cause nausea. measured in pixel offset at its peaks.
intensity = 0.25

// how much should the shake fall off over time. it is recomended
// that you keep it above 0 and below intensity, since these hyper 
// exreme values can cause problems. does not have to be synced, 
// as the system will cut the shake short if movement is too small.
// a value of -1 makes it automatic, based on intensity, and duration.
falloff = -1

// how long should the shake last for in frames. if for some reason
// movement is too small, the shake will be cut short, so the apparent
// shake will be shorter.
duration = 4

curr_shake_frame = -1
curr_period = intensity


dir_x = 0
dir_y = 0

// the camera's float view. the view camera itself only gets whole
// pixels (see render_set_view), so the lerps have to run on these.
cam_x = 0
cam_y = 0
cam_h = camera_height

image_index = 1
view_camera[0] = camera_create_view(0, 0, camera_width, camera_height, 0, noone, -1, -1, -1, -1)
cam_0 = view_camera[0]
render_set_view(cam_0, cam_x, cam_y, camera_width, camera_height)
