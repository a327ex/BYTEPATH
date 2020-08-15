extern vec4 out_color;
vec4 effect(vec4 vcolor, Image texture, vec2 tc, vec2 pc) {
    vec4 t = Texel(texture, tc);
    return vec4(out_color.rgb, t.a*out_color.a);
}
