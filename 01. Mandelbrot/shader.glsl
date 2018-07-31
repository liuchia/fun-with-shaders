extern float width;
extern float height;
extern float range_x;
extern float pos_x;
extern float pos_y;

const int MAX_ITERATIONS = 1000;
const float ESCAPE_RADIUS = 4.0;
const float ESCAPE_BOUNDARY = ESCAPE_RADIUS * ESCAPE_RADIUS;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	float range_y = range_x * height/width;
	float x = pos_x + (float(screen_coords.x) / width - 0.5) * range_x;
	float y = pos_y + (float(screen_coords.y) / height - 0.5) * range_y;

	float t = 1;

	// cardioid bulb check
	float q = (x - 0.25)*(x-0.25) + y*y;
	if (q*(q+x-0.25) < 0.25*y*y || (x+1)*(x+1) + y*y < 0.0625) {
	} else {
		float xi = 0.0, yi = 0.0;
		for (int i = 0; i <= MAX_ITERATIONS; i++) {
			float xt = xi*xi - yi*yi + x;
			float yt = 2.0 * xi * yi + y;
			xi = xt;
			yi = yt;
			if (xi*xi + yi*yi > ESCAPE_BOUNDARY) {
				t = float(i) / MAX_ITERATIONS;
			}
		}
	}

	t = 1 - pow(t, 0.5);

	return vec4(t, t, t, 1.0);
}