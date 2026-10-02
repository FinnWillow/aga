
function Easing() constructor {
    static inter = function (start_vec2 = new Vector2(), end_vec2 = new Vector2(), t) {
        return new Vector2(
            start_vec2.x + (end_vec2.x - start_vec2.x) * t,
            start_vec2.y + (end_vec2.y - start_vec2.y) * t
        );
    }
    
    static flip = function (t) {
        return 1.0 - t;
    }
    
    static in_quad = function (t) {
        return t * t;
    }
    
    static out_quad = function (t) {
        return 1.0 - (1.0 - t) * (1.0 - t);
    }
    
    static in_out_quad = function (t) {
        return t < 0.5 
            ? 2.0 * t * t 
            : 1.0 - (-2.0 * t + 2.0) * (-2.0 * t + 2.0) / 2.0;
    }
    
    static in_cubic = function (t) {
        return t * t * t
    }
    
    static out_cubic = function (t) {
        return 1.0 - (1.0 - t) * (1.0 - t) * (1.0 - t);
    }
    
    static in_out_cubic = function (t) {
        return t < 0.5 
            ? 4.0 * t * t * t 
            : 1.0 - (-2.0 * t + 2.0) * (-2.0 * t + 2.0) * (-2.0 * t + 2.0) / 2.0;
    }
    
    static in_expo = function (t) {
        return t == 0.0 ? 0.0 : power(2, 10.0 * t - 10);
    }
    
    static out_expo = function (t) {
        return t == 1.0 ? 1.0 : 1.0 - power(2, -10.0 * t);
    }
}