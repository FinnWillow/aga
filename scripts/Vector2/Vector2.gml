function Vector2(_x = 0, _y = 0) constructor {
    x = _x;
    y = _y;
    
    static set = function (_x_new, _y_new) {
        x = _x_new;
        y = _y_new;
    }
    
    static adds = function (_vec2) {
        return new Vector2(x + _vec2.x, y + _vec2.y);
    }
    
    static subs = function (_vec2) {
        return new Vector2(x- _vec2.x, y - _vec2.y);
    }
    
    static muls = function (_vec2) {
        return new Vector2(x * _vec2.x, y * _vec2.y);
    }
    
    static divs = function (_vec2) {
        return new Vector2(x / _vec2.x, y / _vec2.y);
    }
    
    static scale = function (mag) {
        return new Vector2(x * mag, y * mag);
    }
    
    static cpy = function () {
        return new Vector2(x, y);
    }
    
    static dist = function (_vec2) {
        return sqrt(sqr(_vec2.x - x) + sqr(_vec2.y - y));
    }
    
    static length = function () {
        return sqrt(sqr(x) + sqr(y));
    }
    
    static nor = function () {
        var len = length();
        if (len == 0) {
            return new Vector2();
        }
        
        return new Vector2(x / len, y / len);
    }
}