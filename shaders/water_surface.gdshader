shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
uniform vec4 water_color : source_color = vec4(0.07, 0.36, 0.52, 0.72);
uniform float wave_strength = 0.025;
uniform float wave_speed = 0.35;
void vertex() {
    float wave = sin(VERTEX.x * 0.14 + TIME * wave_speed) * cos(VERTEX.z * 0.11 + TIME * wave_speed * 0.8);
    VERTEX.y += wave * wave_strength;
}
void fragment() {
    float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
    ALBEDO = mix(water_color.rgb, vec3(0.42, 0.68, 0.78), fresnel * 0.6);
    ALPHA = water_color.a;
    ROUGHNESS = 0.16;
    METALLIC = 0.08;
}
