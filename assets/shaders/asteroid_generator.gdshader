shader_type spatial;
render_mode diffuse_toon;

uniform sampler2D noise_tex;
uniform sampler2D tex:filter_nearest;

uniform float strength = 0.5;

void vertex() {
  float n = texture(noise_tex, VERTEX.xy * 0.1).r;
  VERTEX += NORMAL * n * strength;
}

void fragment() {
	ALBEDO = texture(tex, UV).rgb;
}
