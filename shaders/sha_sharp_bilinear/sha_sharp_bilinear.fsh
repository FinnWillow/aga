//
// Sharp bilinear upscale. Inside each texel it samples the texel centre (like
// nearest), and only blends across the last screen pixel at the texel's edge.
// At an integer scale and whole-pixel offset this is exactly nearest; at any
// other scale every texel stays the same size, with 1 px soft edges.
// Needs texture filtering on.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_tex_size;  // texture size in texels
uniform float u_scale;    // screen pixels per texel

void main()
{
    vec2 texel = v_vTexcoord * u_tex_size;
    vec2 centre_dist = fract(texel) - 0.5;
    float region = max(0.5 - 0.5 / u_scale, 0.0);
    vec2 f = (centre_dist - clamp(centre_dist, -region, region)) * u_scale + 0.5;
    
    gl_FragColor = v_vColour * texture2D(gm_BaseTexture, (floor(texel) + f) / u_tex_size);
}
