extern float width;
extern float height;
extern float range_x;
extern float pos_x;
extern float pos_y;

const int MAX_ITERATIONS = 500;
const float ESCAPE_RADIUS = 2.0;
const float ESCAPE_BOUNDARY = ESCAPE_RADIUS * ESCAPE_RADIUS;
const vec2 c = vec2(-.7269, .1889);

vec3 colors[] = vec3[] (
	vec3(203.0/255, 45.0/255, 62.0/255),
	vec3(135.0/255, 7.0/255, 52.0/255),
	vec3(239.0/255, 71.0/255, 58.0/255),
	vec3(48.0/255, 18.0/255, 45.0/255),
	vec3(1, 214.0/255, 191.0/255)
);

const float TRAP_X = 0.5*sqrt(2);
const float TRAP_Y = -TRAP_X;
const float TRAP_R = 1.5;
const float TRAP_RR = 0.02;
const float BORDER = 0.1;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	float range_y = range_x * height/width;
	float x = pos_x + (float(screen_coords.x) / width - 0.5) * range_x;
	float y = pos_y + (float(screen_coords.y) / height - 0.5) * range_y;
	vec3 end_color = colors[4];

	float dist_cen = length(vec2(TRAP_X, TRAP_Y) - vec2(x, y));
	float min_distance = dist_cen < TRAP_R ? TRAP_R - dist_cen : dist_cen - TRAP_R;
	min_distance = max(0, min_distance - TRAP_RR);

	float xi = 0.0, yi = 0.0;
	for (float i = 0; i <= MAX_ITERATIONS; i++) {
		float xt = x*x - y*y + c.x;
		float yt = 2.0 * x * y + c.y;
		x = xt;
		y = yt;

		dist_cen = length(vec2(TRAP_X, TRAP_Y) - vec2(x, y));
		float dist = dist_cen < TRAP_R ? TRAP_R - dist_cen : dist_cen - TRAP_R;
		float odist = max(0, dist - TRAP_RR*(1-BORDER));
		dist = max(0, dist - TRAP_RR);
		if (dist < min_distance) {
			end_color = odist == dist ? colors[int(mod(i, 4))] : colors[int(mod(i-1, 4))];
			min_distance = dist;
		}
		if (x*x + y*y > ESCAPE_BOUNDARY) {
			break;
		}
	}

	return vec4(end_color, 1.0);
}