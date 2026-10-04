function Timer(_cicle) constructor {
    cicle = _cicle;
    timer = 0;
    
    play = function () {
        if (timer != cicle) {
            timer++;
        }
    }
    
    reset = function () {
        timer = 0;
    }
    
    loop = function () { 
        if (is_end()) {
            reset();
        } else {
            play();
        }
    }
    
    is_start = function () {
        return timer == 0;
    }
    
    is_end = function () {
        return timer == cicle;
    }
    
    is_at = function (point) {
        point = clamp(point, 0, cicle);
        return timer == point;
    }
    
    get = function () {
        return timer;
    }
}