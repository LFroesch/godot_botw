shader_type spatial;
render_mode cull_disabled;

uniform vec3 color: source_color;
uniform vec3 shadow_color: source_color;

uniform sampler2D curve_sampler: repeat_disable;
uniform sampler2D wind_sampler: repeat_enable, filter_linear;
uniform float wind_strength = 0.4;
global uniform vec3 player_position;

void vertex() {
	// wind
	vec2 world_pos = vec2(NODE_POSITION_WORLD.x, NODE_POSITION_WORLD.z);
	float curve = texture(curve_sampler, vec2(UV.y, 0.0)).x;
	float wind = (texture(wind_sampler, world_pos * 0.08 + TIME * 0.05).x - 0.5) * curve;
	vec3 wind_displacement = vec3(wind) * wind_strength * (1.0 - UV.y);
	VERTEX += vec3(wind);

	// player displacement
	vec3 direction_to_player = player_position - NODE_POSITION_WORLD;
	float distance_to_player = length(direction_to_player);
	float falloff = 1.0 - smoothstep(0.5, 2.0, distance_to_player);
	VERTEX += -normalize(direction_to_player) * falloff * curve * 0.3;

}

void fragment() {
	ALBEDO = mix(color, shadow_color * color, UV.y);
}
