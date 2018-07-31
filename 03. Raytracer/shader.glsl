extern vec3 pos;
extern vec3 dir;
extern float width;
extern float height;
extern float fov;

const vec3 PURPLE = vec3(48.0/255, 18.0/255, 45.0/255);
const vec3 CRIMSON = vec3(135.0/255, 7.0/255, 52.0/255);
const vec3 ORANGE = vec3(203.0/255, 45.0/255, 62.0/255);
const vec3 RED = vec3(239.0/255, 71.0/255, 58.0/255);
const vec3 WHITE = vec3(1, 214.0/255, 191.0/255);

const vec3 sphere_pos = vec3(0.0, 0.0, 0.0);
const float radius = 1.0;

const vec3 light_pos = vec3(1.0, 3.0, 5.0);
const float AMBIENT = 0.1;
const float DIFFUSE = 0.2;
const float SPECULAR = 0.6;
const float SHINING = 20;

struct hit_data {
	bool hit;
	vec3 pos;
	vec3 normal;
};

// learn how to use structures
hit_data raycast(vec3 ray_pos, vec3 ray_dir) {
	hit_data return_data = hit_data(false, vec3(0, 0, 0), vec3(0, 0, 0));

	vec3 v = sphere_pos - ray_pos;
	float d = dot(ray_dir, v);
	if (d > 0) {
		vec3 perp = v - (ray_dir * d);
		float pmag = length(perp);
		if (pmag <= radius) {
			float xdist = sqrt(radius*radius - pmag*pmag);
			return_data.hit = true;
			return_data.pos = ray_pos + ray_dir * (d - xdist);
			return_data.normal = normalize(return_data.pos - sphere_pos);
		}
	}

	return return_data;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec3 UP_VECTOR = vec3(0.0, 1.0, 0.0);
	vec3 FORE_VECTOR = dir;
	vec3 RIGHT_VECTOR = cross(FORE_VECTOR, UP_VECTOR);
	vec3 TOP_VECTOR = cross(RIGHT_VECTOR, FORE_VECTOR);

	float hfov = fov / height * width;

	float RIGHT_EXTENT = tan(hfov/2);
	float TOP_EXTENT = tan(fov/2);
	vec3 top_offset = TOP_VECTOR * (TOP_EXTENT * (screen_coords.y/height - 0.5) * -2);
	vec3 ray_dir = normalize(
		FORE_VECTOR
		+ RIGHT_VECTOR * (RIGHT_EXTENT * (screen_coords.x/width - 0.5) * 2)
		+ top_offset 
	);
	
	hit_data h = raycast(pos, ray_dir);

	if (h.hit) {
		// AMBIENT
		float intensity = AMBIENT;
		// DIFFUSE
		vec3 light_dir = light_pos - h.pos;
		intensity += max(0, DIFFUSE * dot(light_dir, h.normal));
		// SPECULAR
		vec3 incoming = normalize(h.pos - light_pos);
		vec3 reflect = reflect(incoming, h.normal);
		vec3 view = normalize(pos - h.pos);
		if (dot(reflect, view) > 0)
			intensity +=  SPECULAR * pow(dot(reflect, view), SHINING);
		return vec4(intensity * RED, 1.0);
	} else {
		return vec4(WHITE, 1.0);
	}
}