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

	vec3 end_color = vec3(1,1,1);

	float xi = 0.0, yi = 0.0;
	for (int i = 0; i <= MAX_ITERATIONS; i++) {
		float xt = xi*xi - yi*yi + x;
		float yt = 2.0 * xi * yi + y;
		xi = xt;
		yi = yt;

		float ox = (xi + ESCAPE_RADIUS) / (2 * ESCAPE_RADIUS);
		float oy = (yi + ESCAPE_RADIUS) / (2 * ESCAPE_RADIUS);

		if (xi*xi + yi*yi > ESCAPE_BOUNDARY) break;

		//Texel(texture, texture_coords ) -- pixel colour at text coord
		if (ox >= 0 && ox <= 1 && oy >= 0 && oy <= 1) {
			vec3 trap = Texel(texture, vec2(ox, oy)).xyz;
			if (length(trap) > 0) {
				end_color -= trap;
				break;
			}
		}
	}

	return vec4(end_color, 1.0);
}