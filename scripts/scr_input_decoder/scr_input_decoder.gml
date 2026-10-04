enum DEVICE {
    NONE,
    MOUSE,
    WHEEL,
    KEYBOARD
}

function keymap_check(_entry = {device: DEVICE.NONE, code: -1}) {
    switch (_entry.device) {
    	case DEVICE.MOUSE:
            return mouse_check_button(_entry.code)
        
        case DEVICE.WHEEL:
            if (_entry.code == "up") {
                return mouse_wheel_up()
            } else if (_entry.code == "down") {
                return mouse_wheel_down()
            }
            return false;
        
        case DEVICE.KEYBOARD:
            return keyboard_check(_entry.code)
        
        default: return false;
    }
}

function keymap_check_pressed(_entry = {device: DEVICE.NONE, code: -1}) {
    switch (_entry.device) {
    	case DEVICE.MOUSE:
            return mouse_check_button_pressed(_entry.code);
        
        case DEVICE.WHEEL:
            show_debug_message("[scr_input_decoder] " +
                "WARNING: wheel type entry attempted on keymap_check_pressed. " + 
                "Only keymap_check is supported for wheel entry's." 
            )
            return false;
        
        case DEVICE.KEYBOARD:
            return keyboard_check_pressed(_entry.code);
        
        default: return false;
    }
}

function keymap_check_released(_entry = {device: DEVICE.NONE, code: -1}) {
    switch (_entry.device) {
    	case DEVICE.MOUSE:
            return mouse_check_button_released(_entry.code);
        
        case DEVICE.WHEEL:
            show_debug_message("[scr_input_decoder] " +
                "WARNING: wheel type entry attempted on keymap_check_released. " + 
                "Only keymap_check is supported for wheel entry's." 
            )
            return false;
        
        case DEVICE.KEYBOARD:
            return keyboard_check_released(_entry.code);
        
        default: return false;
    }
}