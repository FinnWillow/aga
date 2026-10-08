stats = {
    move_speed : 1,
    
    max_hp: 100,
    hp : 100,
    
    max_stamina : 100,
    stamina: 100,
    stamina_regen: 0.2,
    
    max_exhaust: 100,
    exhaust: 100,
    state : ARMAT_STATE.ALIVE 
}

stun = false;
stun_time = 10;
stun_timer = new Timer(stun_time)

// debug stats
armat_create_debug = function (category = "Armature") {
    debug_target(stats)
    debug_add(category, "move_speed", DBG.SLIDER_INT, 1, 8)
    debug_add(category, "hp", DBG.SLIDER_INT, 0, stats.max_hp)
    debug_add(category, "stamina", DBG.SLIDER_INT, 0, stats.max_stamina)
    debug_add(category, "exhaust", DBG.SLIDER_INT, 0, stats.max_exhaust)
    debug_add(category, "state", DBG.WATCH)
}
