extern float width;
extern float height;
extern float range_x;
extern float pos_x;
extern float pos_y;

const vec2 c = vec2(.285, .01);

const int MAX_ITERATIONS = 1000;
const float ESCAPE_RADIUS = 4.0;
const float ESCAPE_BOUNDARY = ESCAPE_RADIUS * ESCAPE_RADIUS;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	float range_y = range_x * height/width;
	float x = pos_x + (float(screen_coords.x) / width - 0.5) * range_x;
	float y = pos_y + (float(screen_coords.y) / height - 0.5) * range_y;

	float t = 1;

	for (float i = 0; i <= MAX_ITERATIONS; i++) {
		float xt = x*x - y*y + c.x;
		float yt = 2.0 * x * y + c.y;
		x = xt;
		y = yt;
		if (x*x + y*y > ESCAPE_BOUNDARY) {
			t = i / MAX_ITERATIONS;
		}
	}

	t = 1 - pow(t, 0.5);

	return vec4(t, t, t, 1.0);
}