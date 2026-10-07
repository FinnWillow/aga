/// debug menu.
/// objects register the fields they want editable in their Create event:
///
///     debug_target(id)
///     debug_add("Camera", "can_shake", DBG.TOGGLE)
///     debug_add("Camera", "intensity", DBG.SLIDER, 0, 16)
///     debug_add("Camera", "shake",     DBG.BUTTON)
///
/// everything goes in one window, one collapsible section per category. it's
/// only built while the menu is open (F1), and rebuilt by itself when something
/// registers or a registered instance is destroyed, so registering once in
/// Create is all an object ever has to do.
/// in the Release config every debug_* call does nothing.

#macro DEBUG true
#macro Release:DEBUG false

enum DBG {
    TOGGLE,         // bool checkbox
    SLIDER,         // real. _a = min, _b = max, _c = step (optional)
    SLIDER_INT,     // integer. _a = min, _b = max, _c = step (optional)
    BUTTON,         // sets the field to true (one frame flags). if _a is a function, calls that instead
    DROPDOWN,       // _a = specifier: "a,b,c" (stores the index) or "a:1,b:5" (stores the value)
    TEXT_INPUT,     // edits as text. _a = type ("r" real, "i" integer, "s" string; default "r")
    WATCH,          // read only
}

global.debug = {
    open: false,

    // set by debug_target; what the next debug_add calls edit.
    target: noone,

    // {category, target, name, type, a, b, c}
    entries: [],

    // the built dbg view, deleted on close / rebuild.
    views: [],

    // set when something registers while the menu is open.
    dirty: false,

    // extra sections that build themselves (the palette editor).
    // {build, update}: build adds its own dbg_section and controls to the
    // window, update runs every step while the menu is open.
    builders: [],
}

/// sets what the following debug_add calls edit: an instance (id), a struct, or global.
function debug_target(_target) {
    if (!DEBUG) {
        return
    }
    global.debug.target = _target
}

/// registers a field of the current target in a category (one window per category).
function debug_add(_category, _name, _type, _a = undefined, _b = undefined, _c = undefined) {
    if (!DEBUG) {
        return
    }
    var d = global.debug
    
    // already registered (e.g. a global field registered by every room's player)
    for (var i = 0; i < array_length(d.entries); i++) {
        var entry = d.entries[i]
        if (entry.target == d.target && entry.category == _category && entry.name == _name) {
            return
        }
    }
    
    array_push(d.entries, {
        category: _category,
        target: d.target,
        name: _name,
        type: _type,
        a: _a,
        b: _b,
        c: _c,
    })
    d.dirty = true
}

/// registers a button that calls _func. for anything a plain field can't do.
function debug_button(_category, _label, _func) {
    debug_add(_category, _label, DBG.BUTTON, _func)
}

/// adds a section that builds itself with dbg_* calls. _build is called every
/// time the menu is built and adds its own dbg_section; _update (optional)
/// runs every step while the menu is open.
function debug_add_builder(_build, _update = undefined) {
    if (!DEBUG) {
        return
    }
    array_push(global.debug.builders, {build: _build, update: _update})
    global.debug.dirty = true
}

/// opens or closes the menu.
function debug_toggle() {
    if (!DEBUG) {
        return
    }
    var d = global.debug
    d.open = !d.open

    if (d.open) {
        debug_build()
    } else {
        debug_clear()
    }
    show_debug_overlay(d.open)
}

/// keeps the menu in sync. call every step.
function debug_update() {
    if (!DEBUG) {
        return
    }
    var d = global.debug

    // the overlay can be closed from its own menu bar too
    if (d.open && !is_debug_overlay_open()) {
        d.open = false
        debug_clear()
        return
    }

    if (!d.open) {
        return
    }

    // rebuild when something registered, or a target is gone (left the room)
    var rebuild = d.dirty
    for (var i = 0; i < array_length(d.entries) && !rebuild; i++) {
        rebuild = !debug_target_exists(d.entries[i].target)
    }

    if (rebuild) {
        debug_build()
    }
    
    for (var i = 0; i < array_length(d.builders); i++) {
        if (d.builders[i].update != undefined) {
            d.builders[i].update()
        }
    }
}

/// deletes every view.
function debug_clear() {
    var d = global.debug
    for (var i = 0; i < array_length(d.views); i++) {
        dbg_view_delete(d.views[i])
    }
    d.views = []
}

/// (re)builds every view from the registered entries.
function debug_build() {
    var d = global.debug
    debug_clear()
    d.dirty = false

    // forget entries of destroyed instances
    d.entries = array_filter(d.entries, function (_entry) {
        return debug_target_exists(_entry.target)
    })

    // group by category, keeping the order things registered in
    var categories = []
    var by_category = {}
    for (var i = 0; i < array_length(d.entries); i++) {
        var entry = d.entries[i]
        if (!struct_exists(by_category, entry.category)) {
            by_category[$ entry.category] = []
            array_push(categories, entry.category)
        }
        array_push(by_category[$ entry.category], entry)
    }

    // one window down the left edge, under the overlay's menu and fps bars
    array_push(d.views, dbg_view("Debug", true, 8, 88, 400, max(200, window_get_height() - 96)))
    
    // one section per category. sections can't nest, so a category holding
    // fields of more than one target gets a section per target instead.
    for (var i = 0; i < array_length(categories); i++) {
        var entries = by_category[$ categories[i]]
        
        var single = true
        for (var j = 1; j < array_length(entries) && single; j++) {
            single = entries[j].target == entries[0].target
        }
        
        var last_target = undefined
        for (var j = 0; j < array_length(entries); j++) {
            var entry = entries[j]
            if (entry.target != last_target) {
                dbg_section(single 
                    ? categories[i] 
                    : categories[i] + " - " + debug_target_name(entry.target))
                last_target = entry.target
            }
            debug_build_entry(entry)
        }
    }
    
    for (var i = 0; i < array_length(d.builders); i++) {
        d.builders[i].build()
    }
}

/// one control for one entry.
function debug_build_entry(_entry) {
    var ref = ref_create(_entry.target, _entry.name)

    switch (_entry.type) {
        case DBG.TOGGLE:
            dbg_checkbox(ref, _entry.name)
            break

        case DBG.SLIDER:
            if (_entry.c == undefined) {
                dbg_slider(ref, _entry.a ?? 0, _entry.b ?? 1, _entry.name)
            } else {
                dbg_slider(ref, _entry.a ?? 0, _entry.b ?? 1, _entry.name, _entry.c)
            }
            break

        case DBG.SLIDER_INT:
            dbg_slider_int(ref, _entry.a ?? 0, _entry.b ?? 100, _entry.name, _entry.c ?? 1)
            break

        case DBG.BUTTON:
            var func = is_method(_entry.a) || is_callable(_entry.a)
                ? _entry.a
                : method({target: _entry.target, name: _entry.name}, function () {
                    debug_set(target, name, true)
                })
            dbg_button(_entry.name, func)
            break

        case DBG.DROPDOWN:
            dbg_drop_down(ref, _entry.a ?? "", _entry.name)
            break

        case DBG.TEXT_INPUT:
            dbg_text_input(ref, _entry.name, _entry.a ?? "r")
            break

        case DBG.WATCH:
            dbg_watch(ref, _entry.name)
            break
    }
}

/// sets a field on an instance, struct or global.
function debug_set(_target, _name, _value) {
    if (is_struct(_target)) {
        _target[$ _name] = _value
    } else if (instance_exists(_target)) {
        variable_instance_set(_target, _name, _value)
    }
}

function debug_target_exists(_target) {
    return is_struct(_target) || instance_exists(_target)
}

/// section title for a target: the object name, the struct's constructor, or "global".
function debug_target_name(_target) {
    if (_target == global) {
        return "global"
    }
    if (is_struct(_target)) {
        return instanceof(_target)
    }
    return object_get_name(_target.object_index)
}
