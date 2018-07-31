extern float width;
extern float height;
extern float range_x;
extern float pos_x;
extern float pos_y;

const int MAX_ITERATIONS = 1000;
const float ESCAPE_RADIUS = 4.0;
const float ESCAPE_BOUNDARY = ESCAPE_RADIUS * ESCAPE_RADIUS;

const float TRAP_X = 0.71;
const float TRAP_Y = 0.71;
const float TRAP_R = 1.5;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	float range_y = range_x * height/width;
	float x = pos_x + (float(screen_coords.x) / width - 0.5) * range_x;
	float y = pos_y + (float(screen_coords.y) / height - 0.5) * range_y;

	float t = 1;

	float dist_cen = length(vec2(TRAP_X, TRAP_Y) - vec2(x, y));
	float min_distance = dist_cen < TRAP_R ? TRAP_R - dist_cen : dist_cen - TRAP_R;

	float xi = 0.0, yi = 0.0;
	for (int i = 0; i <= MAX_ITERATIONS; i++) {
		float xt = xi*xi - yi*yi + x;
		float yt = 2.0 * xi * yi + y;
		xi = xt;
		yi = yt;

		dist_cen = length(vec2(TRAP_X, TRAP_Y) - vec2(xi, yi));
		float dist = dist_cen < TRAP_R ? TRAP_R - dist_cen : dist_cen - TRAP_R;
		min_distance = min(dist, min_distance);
		if (xi*xi + yi*yi > ESCAPE_BOUNDARY) {
			break;
		}
	}

	t = min_distance;
	return vec4(t,t,t, 1.0);
}