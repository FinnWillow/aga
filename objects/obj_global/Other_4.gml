global.level_tilemaps = []      // level -> all tilemaps on that level

var game_layers = layer_get_all();
for (var i = 0; i < array_length(game_layers); i++) {
    // filter out non tilemap layers
    if (layer_tilemap_get_id(game_layers[i]) == -1) {
        continue;
    }
    
    // separate the name into workable data where that data is always 
    // <palletee>_other_suff_<ln> where n is the layer index from 0 to 6.
    var split_name = string_split(layer_get_name(game_layers[i]), "_");
    for (var j = 0; j < array_length(split_name); j++) {
        split_name[j] = string_lower(split_name[j]);
    }
    
    // get the draw layer depth per layer
    
    var draw_layer_str = string_lower(array_last(split_name));
    var level = 0;
    if (string_char_at(draw_layer_str, 1) == "l") {
        level = real(string_char_at(draw_layer_str, 2));
    }
    var draw_layer = to_draw_layer(level);
    
    // remember this tilemap for collision
    var tilemap = layer_tilemap_get_id(game_layers[i])
    
    while (array_length(global.level_tilemaps) <= level) {
        array_push(global.level_tilemaps, [])
    }
    
    array_push(global.level_tilemaps[level], tilemap)
    
    // set it
    var edit_depth = layer_get_depth(game_layers[i]);
    layer_depth(game_layers[i], draw_layer + (edit_depth / 100));
    
    // skip index layers to get no palletteing
    var name = string_lower(array_first(split_name));
    if (name == "index") {
        continue;
    }
    
    // apply the appropriate pallete using the sha_pallette shader.
    if (global.pallettes[$ name] != undefined) {
        layer_script_begin(game_layers[i], method(
            {pal: global.pallettes[$ name]},
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

// for each level: its own tilemaps + the level below's non-"own" tilemaps
global.collision_tilemaps = []
var level_count = array_length(global.level_tilemaps)
for (var lv = 0; lv <= level_count; lv++) { // one extra: standing above the highest tiles
    var maps = []
    if (lv < level_count) {
        maps = array_concat(maps, global.level_tilemaps[lv])
    }
    
    if (lv + 1 < level_count) {
        maps = array_concat(maps, global.level_tilemaps[lv + 1])
    }
    
    array_push(global.collision_tilemaps, maps)
}

// make the timer
fps_timer = new Timer(30);
fps_last = fps_real;
