extern float width;
extern float height;
extern float range_x;
extern float pos_x;
extern float pos_y;
extern float cx;
extern float cy;

const vec3 PURPLE = vec3(48.0/255, 18.0/255, 45.0/255);
const vec3 CRIMSON = vec3(135.0/255, 7.0/255, 52.0/255);
const vec3 ORANGE = vec3(203.0/255, 45.0/255, 62.0/255);
const vec3 RED = vec3(239.0/255, 71.0/255, 58.0/255);
const vec3 WHITE = vec3(1, 214.0/255, 191.0/255);
const vec2 c = vec2(.25, .0);

const int MAX_ITERATIONS = 1000;
const float ESCAPE_RADIUS = 4.0;
const float ESCAPE_BOUNDARY = ESCAPE_RADIUS * ESCAPE_RADIUS;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	float range_y = range_x * height/width;
	float x = pos_x + (float(screen_coords.x) / width - 0.5) * range_x;
	float y = pos_y + (float(screen_coords.y) / height - 0.5) * range_y;

	vec3 end_color = vec3(1,1,1);

	for (int i = 0; i <= MAX_ITERATIONS; i++) {
		float xt = x*x - y*y + cx;
		float yt = 2.0 * x * y + cy;
		x = xt;
		y = yt;

		if (x*x + y*y > ESCAPE_BOUNDARY) break;

		float ox = (x + ESCAPE_RADIUS) / (2 * ESCAPE_RADIUS);
		float oy = (y + ESCAPE_RADIUS) / (2 * ESCAPE_RADIUS);
		if (ox >= 0 && ox <= 1 && oy >= 0 && oy <= 1) {
			vec4 trap = Texel(texture, vec2(ox, oy));
			if (trap.a == 1 && length(trap.xyz) < 1) {
				end_color = trap.xyz;
				break;
			}
		}
	}

	return vec4(end_color, 1.0);
}