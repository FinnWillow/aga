fps_timer.loop();

if (fps_timer.is_end()) {
	fps_last = fps_real
}

draw_text_ext_transformed(16, 16, string(fps_last), 1, 256, 6, 8, 0)