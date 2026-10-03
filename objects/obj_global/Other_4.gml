var game_layers = layer_get_all();
for (var i = 0; i < array_length(game_layers); i++) {
    var name = layer_get_name(game_layers[i]);
    
    if (pallettes[$ name] != undefined) {
        layer_script_begin(game_layers[i], method(
            {pal: pallettes[$ name]},
            function () {
                if (event_type == ev_draw && event_number == 0) {
                    shader_set(sha_pallette);
                    shader_set_uniform_f_array(global.u_pallette_handle,  pal);
                }
            }
        ))
        
        layer_script_end(game_layers[i], 
            function () {
                if (event_type == ev_draw && event_number == 0) {
                    shader_reset();
                }
            }
        )
    }
}
