shader_type canvas_item;

render_mode blend_mix;

uniform vec2 origin = vec2(-50f, 100f);
uniform float width = 64f;
uniform float speed: hint_range(-5, 5) = 1f;
uniform float opacity: hint_range(0, 1) = 1f;

void vertex() {
	vec2 offset = vec2(0f);
	
	if (VERTEX.x < origin.x) {
		offset.x = width / 2f;
	} else {
		offset.x = -width / 2f;
	}
	
	if (VERTEX.y < origin.y) {
		offset.y = width / 2f;
	} else {
		offset.y = -width / 2f;
	}
	
	VERTEX += offset;
}

void fragment() {
	vec2 newuv = UV;
	newuv.x += TIME * speed;
	vec4 c = texture(TEXTURE, newuv);
	if (c.a > 0.1f) {
		c.a = opacity;
		c.rgb = COLOR.rgb;
	} else {
		c.a = 0f;
	}
	COLOR = c;
}