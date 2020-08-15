extern vec2 amount;
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
    return color*vec4(Texel(texture, tc - amount).r, Texel(texture, tc).g, Texel(texture, tc + amount).b, Texel(texture, tc).a);
}

