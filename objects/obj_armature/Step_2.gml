// Inherit the parent event
event_inherited();

if (stats.hp <= 0) {
    stats.state = ARMAT_STATE.DEAD
}

if (stun) {
    stun_timer.play()
    if (stun_timer.is_end()) {
        stun_timer.set(stun_time)
        stun = false;
    }
}