extern Image rgb_map; 

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
    vec4 shift_pixel = Texel(rgb_map, tc);
    vec2 rp = tc;
    rp.x -= (shift_pixel.r*2.0 - 1.0);
    vec2 bp = tc;
    bp.x += (shift_pixel.r*2.0 - 1.0);
    return color*vec4(Texel(texture, rp).r, Texel(texture, tc).g, Texel(texture, bp).b, Texel(texture, tc).a);
}
