shader_type spatial;
render_mode unshaded;

uniform float uv_scale : hint_range(0.1, 50.0) = 10.0;
uniform float star_density : hint_range(0.0, 1.0) = 0.2;
uniform float star_size : hint_range(0.01, 1.0) = 0.05;
uniform int star_colors_count = 4;
uniform vec3 star_colors[4] : source_color;

varying vec3 world_pos;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 pos = world_pos.xz * uv_scale;
	//vec3 a = abs(world_pos);
	//vec2 pos = uv_scale * (a.x > a.y && a.x > a.z ? world_pos.zy : (a.y > a.z ? world_pos.xz : world_pos.xy));
	
	vec2 grid_id = floor(pos);
	vec2 grid_uv = fract(pos) - 0.5; 
	
	
	vec2 rand_offset = vec2(
		random(grid_id), 
		random(grid_id + vec2(1.0, 5.0))
	) - 0.5;
	
	
	float dist = length(grid_uv - rand_offset * 0.7);
	float spawn_prob = random(grid_id + vec2(11.0, 22.0));
	float visibility = step(1.0 - star_density, spawn_prob);
	
	float phase = random(grid_id + vec2(100.0)) * 6.28318;
	float speed = mix(0.5, 2.0, random(grid_id + vec2(200.0))); 
	float star_breath = 0.5 + 0.5 * sin(TIME * speed + phase);
	
	
	int color_idx = int(floor(random(grid_id + vec2(44.0)) * float(star_colors_count)));
	vec3 color = star_colors[color_idx];
	
	float star = (star_size / (dist + 0.001)) * random(vec2(0.01, 0.04)); 
	
	star = pow(star, 2.0); 
	
	ALBEDO = color * star  * visibility * star_breath;
}