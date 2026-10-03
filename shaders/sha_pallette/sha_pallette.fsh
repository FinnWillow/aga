//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 u_pallette[4];

vec4 ind_1 = vec4(  0.0,   0.0,   0.0, 1.0);
vec4 ind_2 = vec4( 85.0 / 255.0,  85.0 / 255.0,  85.0 / 255.0, 1.0);
vec4 ind_3 = vec4(170.0 / 255.0, 170.0 / 255.0, 170.0 / 255.0, 1.0);
vec4 ind_4 = vec4(  1.0,   1.0,   1.0, 1.0);

void main()
{
    vec4 tex_sample = texture2D( gm_BaseTexture, v_vTexcoord );
    float f_sample = floor(tex_sample.r * 3.0 + 0.5);
    
    if (f_sample == 0.0){
        tex_sample = vec4(u_pallette[0], tex_sample.a);
    } else if (f_sample == 1.0) {
        tex_sample = vec4(u_pallette[1], tex_sample.a);
    } else if (f_sample == 2.0) {
        tex_sample = vec4(u_pallette[2], tex_sample.a);
    } else if (f_sample == 3.0) {
        tex_sample = vec4(u_pallette[3], tex_sample.a);
    }
    
    gl_FragColor = v_vColour * tex_sample;
}
