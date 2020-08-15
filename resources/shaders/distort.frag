// change these values to 0.0 to turn off individual effects
extern number scanlines = 0.5;
extern number rgb_offset = 0.2;
extern number horizontal_fuzz = 0.5;

extern number time;

// Noise generation functions borrowed from: 
// https://github.com/ashima/webgl-noise/blob/master/src/noise2D.glsl

vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }
float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439); 
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m;
    m = m*m;

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 pc) {
	float fuzz_offset = snoise(vec2(time*15.0, uv.y*80.0))*0.003;
	float large_fuzz_offset = snoise(vec2(time*1.0, uv.y*25.0))*0.004;
	float x_offset = (fuzz_offset + large_fuzz_offset) * horizontal_fuzz;
    
	float red = Texel(texture, vec2(uv.x + x_offset - 0.01*rgb_offset, uv.y)).r;
	float green = Texel(texture, vec2(uv.x + x_offset , uv.y)).g;
	float blue = Texel(texture, vec2(uv.x + x_offset + 0.01*rgb_offset, uv.y)).b;
	
	vec3 cl = vec3(red, green, blue);
	float scanline = sin(uv.y*800.0)*0.04*scanlines;
	cl -= scanline;
	
	return vec4(cl, 1.0);
}
