shader_set(sha_pallette)
shader_set_uniform_f_array(global.u_pallette_handle, global.pallettes[$ pallette])
// whole pixels, the same way the renderer snaps the camera
draw_sprite_ext(sprite_index, image_index, floor(x), floor(y), image_xscale, image_yscale, image_angle, image_blend, image_alpha)
shader_reset()
