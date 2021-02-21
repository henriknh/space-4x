shader_type canvas_item;

uniform vec4 color : hint_color = vec4(1.0);
uniform float width : hint_range(0, 100) = 30;
uniform float check_interval : hint_range(1, 100) = 5;
uniform float texture_size = 128;
uniform float zebra_occurence : hint_range(0, 1) = 0.5;
uniform float zebra_size : hint_range(0, 1) = 0.5;
uniform float zebra_direction : hint_range(-1, 1) = -1;

void vertex() {
	// VERTEX = vec2(VERTEX.x + 50. + 50. * sin(TIME), VERTEX.y);
}

float hasContraryNeighbour(vec2 uv, sampler2D texture2) {
	float neighbors = 0f;
	for (float x = -width; x <= width; x += 1f) {
		for (float y = -width; y <= width; y += 1f) {
			vec2 xy = uv + 1f/texture_size * vec2(x, y);
			
			if (x == 0f) {
				continue;
			} else if (y == 0f) {
				continue;
			} else if (xy.x < 0f) {
				continue;
			} else if (xy.y < 0f) {
				continue;
			} else if (xy.x > 1f) {
				continue;
			} else if (xy.y > 1f) {
				continue;
			} else if (texture(texture2, xy).a > 0.) {
				neighbors += 1f;
			}
		}
	}
	return neighbors;
}

void fragment() {
	COLOR.rgb = color.rgb;
	float neighbors = hasContraryNeighbour(UV, TEXTURE);
 	COLOR.a = 1f - (neighbors / pow(width * 2f, 2f));
 	
// 	int _zebra_value = int(UV.x * texture_size + UV.y * texture_size * zebra_direction);
// 	int _zebra_occurence = int((1f - zebra_occurence) * texture_size);
// 	int _zebra_size = int(texture_size * zebra_size * (1f - zebra_occurence));
// 	if (_zebra_value % _zebra_occurence < _zebra_size) {
// 		COLOR.a = 0f;
// 	}
}