fps_timer.loop();

if (fps_timer.is_end()) {
	fps_last = fps_real
}

draw_text(4, 4, string(fps_last))