vec4 effect(vec4 vcolor, Image texture, vec2 tc, vec2 pc) {
    vec4 tex_color = Texel(texture, tc);
    return vec4(vcolor.rgb + tex_color.rgb - 0.5, tex_color.a);
}
