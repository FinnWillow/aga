// Inherit the parent event
event_inherited();

if (stats.hp <= 0) {
    stats.state = ARMAT_STATE.DEAD
} else {
    stats.state = ARMAT_STATE.ALIVE
}

if (stats.stamina < stats.max_stamina) {
    stats.stamina += stats.stamina_regen
    stats.stamina = clamp(stats.stamina, 0, stats.max_stamina)
}

if (stun) {
    stun_timer.play()
    if (stun_timer.is_end()) {
        stun_timer.set(stun_time)
        stun = false;
    }
}