extern Image glitch_map; 

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
    vec4 glitch_pixel = Texel(glitch_map, tc);
    vec2 position = tc;
    position.x += (glitch_pixel.r*2.0 - 1.0);
    return color*Texel(texture, position);
}
