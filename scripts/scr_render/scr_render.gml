/// pixel perfect rendering.
/// the world is drawn 1:1 into the application surface (one surface pixel per
/// art pixel), then the surface is scaled up to the window in Post Draw.
/// the camera hands over a float view with render_set_view. the surface is
/// rendered at that view snapped to whole pixels (plus a 1 px border), and the
/// leftover fraction is applied when the surface is drawn to the window, so the
/// camera still moves smoothly on screen while the art stays on its own grid.

global.render = {
    // the room's view size. zoom 0 always lands on an integer scale.
    base_w: 320,
    base_h: 240,

    // the float view handed over by the camera.
    view_x: 0,
    view_y: 0,
    view_w: 320,
    view_h: 240,

    // the whole pixel view the surface is actually rendered with.
    snap_x: 0,
    snap_y: 0,
    snap_w: 321,
    snap_h: 241,

    // where the game image sits in the window, and its integer scale.
    out_x: 0,
    out_y: 0,
    out_w: 320,
    out_h: 240,
    scale: 1,

    // sha_sharp_bilinear uniforms, set in render_init
    u_tex_size: -1,
    u_scale: -1,
}

/// sets the base resolution (the room's view size). call on room start.
function render_init(_base_w, _base_h) {
    var r = global.render
    r.base_w = _base_w
    r.base_h = _base_h
    r.u_tex_size = shader_get_uniform(sha_sharp_bilinear, "u_tex_size")
    r.u_scale = shader_get_uniform(sha_sharp_bilinear, "u_scale")
    application_surface_draw_enable(false)
    render_update_output()
}

/// sizes the window to the biggest integer scale that fits the display.
/// only meant for windowed mode.
function render_fit_window() {
    var r = global.render

    // leave some room for the title bar and panels
    var scale = max(1, floor(min(
        display_get_width() / r.base_w,
        (display_get_height() - 48) / r.base_h
    )))

    window_set_size(r.base_w * scale, r.base_h * scale)
    window_center()
}

/// hands the camera's float view over to the renderer. call once per frame,
/// after the camera has moved (End Step).
function render_set_view(_cam, _x, _y, _w, _h) {
    var r = global.render
    r.view_x = _x
    r.view_y = _y
    r.view_w = _w
    r.view_h = _h

    // the surface covers the view plus the one pixel the fraction pushes into
    r.snap_x = floor(_x)
    r.snap_y = floor(_y)
    r.snap_w = ceil(_w) + 1
    r.snap_h = ceil(_h) + 1

    camera_set_view_pos(_cam, r.snap_x, r.snap_y)
    camera_set_view_size(_cam, r.snap_w, r.snap_h)
    view_set_xport(0, 0)
    view_set_yport(0, 0)
    view_set_wport(0, r.snap_w)
    view_set_hport(0, r.snap_h)

    if (surface_get_width(application_surface) != r.snap_w
        || surface_get_height(application_surface) != r.snap_h) {
        surface_resize(application_surface, r.snap_w, r.snap_h)
    }
}

/// works out where the game image goes in the window. the base view is fit
/// at the biggest integer scale, centred, with black bars around it.
function render_update_output() {
    var r = global.render
    var win_w = window_get_width()
    var win_h = window_get_height()

    // minimised
    if (win_w <= 0 || win_h <= 0) {
        return
    }

    r.scale = max(1, floor(min(win_w / r.base_w, win_h / r.base_h)))
    r.out_w = r.base_w * r.scale
    r.out_h = r.base_h * r.scale
    r.out_x = (win_w - r.out_w) div 2
    r.out_y = (win_h - r.out_h) div 2

    // gui coordinates are base pixels, starting at the game image's corner
    display_set_gui_maximize(r.scale, r.scale, r.out_x, r.out_y)
}

/// draws the application surface to the window. call in Post Draw.
function render_draw() {
    var r = global.render
    render_update_output()
    draw_clear(c_black)

    if (!surface_exists(application_surface)) {
        return
    }

    // screen pixels per world pixel. exactly r.scale at zoom 0.
    var px = r.out_h / r.view_h

    // the camera's leftover fraction, rounded to whole screen pixels so
    // zoom 0 stays on the pixel grid.
    var off_x = round((r.view_x - r.snap_x) * px)
    var off_y = round((r.view_y - r.snap_y) * px)

    // the surface can lag a frame behind a size change; stretch what is
    // there over the view it was rendered with.
    var surf_w = surface_get_width(application_surface)
    var surf_h = surface_get_height(application_surface)
    var scale_x = px * r.snap_w / surf_w
    var scale_y = px * r.snap_h / surf_h

    var tex = surface_get_texture(application_surface)

    // the 1 px border would spill into the black bars
    gpu_set_scissor(r.out_x, r.out_y, r.out_w, r.out_h)
    gpu_set_blendenable(false)
    gpu_set_texfilter(true)
    shader_set(sha_sharp_bilinear)
    shader_set_uniform_f(r.u_tex_size, 1 / texture_get_texel_width(tex), 1 / texture_get_texel_height(tex))
    shader_set_uniform_f(r.u_scale, px)

    draw_surface_ext(application_surface, r.out_x - off_x, r.out_y - off_y, scale_x, scale_y, 0, c_white, 1)

    shader_reset()
    gpu_set_texfilter(false)
    gpu_set_blendenable(true)
    gpu_set_scissor(0, 0, window_get_width(), window_get_height())
}

/// the mouse position in the world. use instead of mouse_x / mouse_y, which
/// don't know the game image is drawn by hand.
function render_mouse_x() {
    var r = global.render
    return r.view_x + (window_mouse_get_x() - r.out_x) * r.view_h / r.out_h
}

function render_mouse_y() {
    var r = global.render
    return r.view_y + (window_mouse_get_y() - r.out_y) * r.view_h / r.out_h
}
