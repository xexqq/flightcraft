shader_type sky;
uniform vec3 horizon_color : source_color = vec3(0.92, 0.59, 0.40);
uniform vec3 zenith_color : source_color = vec3(0.08, 0.20, 0.38);
uniform float sun_height = 0.4;
void sky() {
    float h = clamp(EYEDIR.y * 0.5 + 0.5, 0.0, 1.0);
    vec3 base = mix(horizon_color, zenith_color, smoothstep(0.0, 1.0, h));
    float star_noise = fract(sin(dot(floor(EYEDIR * 900.0), vec3(12.9898,78.233,37.719))) * 43758.5453);
    float stars = step(0.9975, star_noise) * step(sun_height, 0.05) * step(0.1, h);
    COLOR = base + vec3(stars);
}
