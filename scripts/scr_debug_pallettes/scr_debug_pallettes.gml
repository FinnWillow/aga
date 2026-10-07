/// palette editor for the debug menu. pick a palette, edit its 4 slots in HSV
/// with aseprite's ranges (H 0-360, S and V 0-100), and the tiles and objects
/// using it change live. "copy gml" puts the palette on the clipboard in the
/// same layout as scr_pallettes, ready to paste over the old one.
/// register once with: debug_add_builder(debug_pallette_build, debug_pallette_update)

function debug_pallette_state() {
    if (!variable_global_exists("debug_pal")) {
        var names = struct_get_names(global.pallettes)
        array_sort(names, true)

        global.debug_pal = {
            names: names,

            // the dropdown's pick, and the palette the sliders currently hold
            index: 0,
            shown: -1,

            // slider values per slot, and what they were last step
            slots: [],
            last: [],

            // name -> the palette as it was before any edit, for revert
            original: {},
        }

        for (var i = 0; i < 4; i++) {
            array_push(global.debug_pal.slots, {h: 0, s: 0, v: 0})
            array_push(global.debug_pal.last, {h: 0, s: 0, v: 0})
        }
    }
    return global.debug_pal
}

function debug_pallette_build() {
    var p = debug_pallette_state()
    if (array_length(p.names) == 0) {
        return
    }

    // reload the sliders from the palette (it may have been reverted or pasted)
    p.shown = -1
    debug_pallette_update()

    dbg_section("Palettes")
    dbg_drop_down(ref_create(p, "index"), string_join_ext(",", p.names), "palette")
    dbg_button("copy gml", debug_pallette_copy_gml)
    dbg_same_line()
    dbg_button("copy hsv / hex", debug_pallette_copy_hsv)
    dbg_button("revert", debug_pallette_revert)

    for (var i = 0; i < 4; i++) {
        dbg_text("slot " + string(i + 1))
        dbg_slider_int(ref_create(p.slots[i], "h"), 0, 360, "H")
        dbg_slider_int(ref_create(p.slots[i], "s"), 0, 100, "S")
        dbg_slider_int(ref_create(p.slots[i], "v"), 0, 100, "V")
    }
}

/// loads the sliders when the dropdown changes, and writes slider changes
/// into the palette. only writes on a change, so opening the editor never
/// alters a palette by rounding.
function debug_pallette_update() {
    var p = debug_pallette_state()
    var name = p.names[p.index]
    var pal = global.pallettes[$ name]

    if (!struct_exists(p.original, name)) {
        p.original[$ name] = array_create(array_length(pal))
        array_copy(p.original[$ name], 0, pal, 0, array_length(pal))
    }

    // a new palette picked: fill the sliders from it
    if (p.shown != p.index) {
        p.shown = p.index
        for (var i = 0; i < 4; i++) {
            var hsv = rgb_to_hsv(pal[i * 3], pal[i * 3 + 1], pal[i * 3 + 2])
            p.slots[i].h = round(hsv[0])
            p.slots[i].s = round(hsv[1] * 100)
            p.slots[i].v = round(hsv[2] * 100)
            p.last[i].h = p.slots[i].h
            p.last[i].s = p.slots[i].s
            p.last[i].v = p.slots[i].v
        }
        return
    }

    // write changed slots into the palette, in place, so every layer
    // and object holding this array sees it
    for (var i = 0; i < 4; i++) {
        var slot = p.slots[i]
        var last = p.last[i]
        if (slot.h == last.h && slot.s == last.s && slot.v == last.v) {
            continue
        }

        var rgb = hsv_to_rgb(slot.h, slot.s / 100, slot.v / 100)
        for (var k = 0; k < 3; k++) {
            pal[i * 3 + k] = round(rgb[k] * 255) / 255
        }
        last.h = slot.h
        last.s = slot.s
        last.v = slot.v
    }
}

function debug_pallette_revert() {
    var p = debug_pallette_state()
    var name = p.names[p.index]
    var pal = global.pallettes[$ name]
    array_copy(pal, 0, p.original[$ name], 0, array_length(pal))
    p.shown = -1
}

/// the palette in scr_pallettes' layout.
function debug_pallette_copy_gml() {
    var p = debug_pallette_state()
    var name = p.names[p.index]
    var pal = global.pallettes[$ name]

    var text = "    " + name + ": [\n"
    for (var i = 0; i < 4; i++) {
        text += "        // index " + string(i + 1) + "\n"
        for (var k = 0; k < 3; k++) {
            var num = string(round(pal[i * 3 + k] * 255))
            text += "        " + num + string_repeat(" ", 5 - string_length(num)) + "/ 255,\n"
        }
        if (i < 3) {
            text += "        \n"
        }
    }
    text += "    ],\n"

    clipboard_set_text(text)
    show_debug_message(text)
}

/// one line per slot, with HSV for aseprite and the hex code.
function debug_pallette_copy_hsv() {
    var p = debug_pallette_state()
    var name = p.names[p.index]
    var pal = global.pallettes[$ name]

    var text = name + "\n"
    for (var i = 0; i < 4; i++) {
        var slot = p.slots[i]
        var hex = ""
        for (var k = 0; k < 3; k++) {
            var byte = round(pal[i * 3 + k] * 255)
            hex += string_char_at("0123456789abcdef", byte div 16 + 1)
                + string_char_at("0123456789abcdef", byte mod 16 + 1)
        }
        text += "slot " + string(i + 1) + ": H " + string(slot.h) + " S " + string(slot.s)
            + " V " + string(slot.v) + "  #" + hex + "\n"
    }

    clipboard_set_text(text)
    show_debug_message(text)
}

/// r, g, b in 0-1 -> [h 0-360, s 0-1, v 0-1]
function rgb_to_hsv(_r, _g, _b) {
    var hi = max(_r, _g, _b)
    var lo = min(_r, _g, _b)
    var range = hi - lo

    var h = 0
    if (range > 0) {
        if (hi == _r) {
            h = 60 * ((_g - _b) / range)
        } else if (hi == _g) {
            h = 60 * ((_b - _r) / range + 2)
        } else {
            h = 60 * ((_r - _g) / range + 4)
        }
    }
    if (h < 0) {
        h += 360
    }

    var s = (hi == 0) ? 0 : range / hi
    return [h, s, hi]
}

/// h 0-360, s and v 0-1 -> [r, g, b] in 0-1
function hsv_to_rgb(_h, _s, _v) {
    var c = _v * _s
    var hp = (_h mod 360) / 60
    var mid = c * (1 - abs((hp mod 2) - 1))
    var m = _v - c

    var rgb
    switch (floor(hp)) {
        case 0:  rgb = [c, mid, 0]; break
        case 1:  rgb = [mid, c, 0]; break
        case 2:  rgb = [0, c, mid]; break
        case 3:  rgb = [0, mid, c]; break
        case 4:  rgb = [mid, 0, c]; break
        default: rgb = [c, 0, mid]; break
    }
    return [rgb[0] + m, rgb[1] + m, rgb[2] + m]
}
