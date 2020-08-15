extern Image displacement_map; 

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
    vec4 displacement_pixel = Texel(displacement_map, tc);
    vec2 position = tc;
    position.x += (displacement_pixel.r*2.0 - 1.0)*0.025*displacement_pixel.a;
    position.y += (displacement_pixel.g*2.0 - 1.0)*0.025*displacement_pixel.a;
    return color*Texel(texture, position);
}
