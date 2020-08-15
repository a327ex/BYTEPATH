extern float grayscale_amount = 0.0;

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
    vec4 current_pixel = Texel(texture, tc);
    float luminance = 0.299*current_pixel.r + 0.587*current_pixel.g + 0.114*current_pixel.b;
    vec4 monochrome = vec4(luminance, luminance, luminance, current_pixel.a);
    return mix(current_pixel, monochrome, grayscale_amount);
}
