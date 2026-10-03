shader_set(sha_pallette);
shader_set_uniform_f_array(u_pallette_handle, pallettes.grass);
draw_self();
shader_reset();