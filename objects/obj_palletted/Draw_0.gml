shader_set(sha_pallette);
shader_set_uniform_f_array(global.u_pallette_handle,  pallettes[$ pallette]);
draw_self();
shader_reset();