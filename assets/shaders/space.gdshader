shader_type spatial;
render_mode unshaded;

uniform float uv_scale : hint_range(0.1, 50.0) = 10.0;
uniform float star_density : hint_range(0.0, 1.0) = 0.2; // 0.0 = none, 1.0 = many
uniform float star_size : hint_range(0.01, 1.0) = 0.05;
uniform vec3 star_colors[4] : source_color;

varying vec3 world_pos;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void vertex() {
    // Get the absolute world position
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // We use .xy for a vertical plane. 
    // If your mesh is horizontal, change this to world_pos.xz
    vec2 pos = world_pos.xy * uv_scale;
    
    vec2 grid_id = floor(pos);
    vec2 grid_uv = fract(pos) - 0.5; // Center the origin in the cell
    
    // Randomize position within the cell
    vec2 rand_offset = vec2(
        random(grid_id), 
        random(grid_id + vec2(1.0, 5.0))
    ) - 0.5;
    
    // Calculate distance from the current pixel to the star center
    // We multiply rand_offset by 0.7 to keep stars from hitting the cell edge
    float dist = length(grid_uv - rand_offset * 0.7);
    
    // Determine if this cell even HAS a star
    float spawn_prob = random(grid_id + vec2(11.0, 22.0));
    float visibility = step(1.0 - star_density, spawn_prob);
    
    // Pick color from array
    int color_idx = int(floor(random(grid_id + vec2(44.0)) * 4.0));
    vec3 color = star_colors[color_idx];
    
    // --- THE "POINT" MATH ---
    // A tight core + a soft falloff
    // Using 1.0 / dist creates a circular point that glows
    float star = (star_size / (dist + 0.001)) * 0.1; 
    
    // Sharpen the point so it's not just a blur
    star = pow(star, 2.0); 
    
    ALBEDO = color * star * visibility;
}