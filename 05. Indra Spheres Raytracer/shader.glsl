extern vec3 pos;
extern vec3 dir;
extern float width;
extern float height;
extern float fov;

const int NONE = -1;
const int PLANE = 0;
const int SPHERE = 1;

const float AMBIENT = 0.375;
const float DIFFUSE = 0.95;
const float SPECULAR = 0.95;
const float SHINING = 50;
const float REFLECT = 0.99;

struct Sphere {
	vec3 pos;
	float radius;
	vec3 color;
};

struct Plane {
	vec3 pos;
	vec3 normal;
	vec3 color;
};

struct Ray {
	vec3 pos;
	vec3 dir;
};

struct Hit {
	int type;
	vec3 pos;
	vec3 normal;
	vec3 color;
	float shadow;
	int id;
};

struct Light {
	vec3 pos;
	vec3 color;
};

const vec3 PURPLE = vec3(48.0/255, 18.0/255, 45.0/255);
const vec3 CRIMSON = vec3(135.0/255, 7.0/255, 52.0/255);
const vec3 ORANGE = vec3(203.0/255, 45.0/255, 62.0/255);
const vec3 RED = vec3(239.0/255, 71.0/255, 58.0/255);
const vec3 WHITE = vec3(1, 214.0/255, 191.0/255);
const vec3 GREY = vec3(.5,.5,.5);
const vec3 BLACK = vec3(.1,.1,.1);

Sphere spheres[] = Sphere[] (
	Sphere(vec3(15,15,15), 14, GREY),
	Sphere(vec3(15,15,-15), 14, BLACK),
	Sphere(vec3(15,-15,15), 14, BLACK),
	Sphere(vec3(15,-15,-15), 14, GREY),
	Sphere(vec3(-15,15,15), 14, BLACK),
	Sphere(vec3(-15,15,-15), 14, GREY),
	Sphere(vec3(-15,-15,15), 14, GREY),
	Sphere(vec3(-15,-15,-15), 14, BLACK)
);

Plane planes[] = Plane[] (
	Plane(vec3(0,0,-15), vec3(0,0,1), vec3(1, 1, 1)),
	Plane(vec3(0,0,15), vec3(0,0,-1), vec3(1, 1, 1)),
	Plane(vec3(0,-15,0), vec3(0,1,0), vec3(1, 1, 1)),
	Plane(vec3(0,15,0), vec3(0,-1,0), vec3(1, 1, 1)),
	Plane(vec3(-15,0,0), vec3(1,0,0), vec3(1, 1, 1)),
	Plane(vec3(15,0,0), vec3(-1,0,0), vec3(1, 1, 1))
);

Light lights[] = Light[] (
	Light(vec3(0,0,0), WHITE)//,
	//Light(vec3(3,0,0), vec3(.3,.6,.6))
);

Hit raycast(Ray ray) {
	Hit data = Hit(-1, vec3(0,0,0), vec3(0,0,0), vec3(0,0,0), 0, NONE);
	float distance = 1e6;
	for (int i = 0; i < spheres.length(); i++) {
		Sphere sphere = spheres[i];
		vec3 v = sphere.pos - ray.pos;
		float d = dot(ray.dir, v);
		if (d > 0) {
			vec3 perp = v - (ray.dir * d);
			float pmag = length(perp);
			if (pmag <= sphere.radius) {
				float xdist = sqrt(sphere.radius*sphere.radius - pmag*pmag);
				if (d-xdist < distance) {
					distance = d-xdist;
					data.type = SPHERE;
					data.pos = ray.pos + ray.dir * (d - xdist);
					data.normal = normalize(data.pos - sphere.pos);
					data.color = sphere.color;
					data.id = i;
				}
			}
		}
	}

	for (int i = 0; i < planes.length(); i++) {
		Plane plane = planes[i];

		float denom = dot(ray.dir, plane.normal);
		vec3 normal = plane.normal * sign(denom);
		denom = dot(ray.dir, normal);
		if (denom > 1e-6) {
			float t = dot(plane.pos - ray.pos, normal) / denom;
			if (t > 0 && t < distance) {
				distance = t;
				vec3 pos = ray.pos + ray.dir * t;
				data.type = PLANE;
				data.pos = pos;
				data.normal = normalize(normal*-1);
				data.color = plane.color;
				data.id = i + spheres.length();
			}
		}
	}

	return data;
}

const vec3 UP_VECTOR = vec3(0.0, 1.0, 0.0);
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {

	vec3 FORE_VECTOR = normalize(dir);
	vec3 RIGHT_VECTOR = cross(FORE_VECTOR, UP_VECTOR);
	vec3 TOP_VECTOR = cross(RIGHT_VECTOR, FORE_VECTOR);

	float hfov = fov / height * width;
	float RIGHT_EXTENT = tan(hfov/2);
	float TOP_EXTENT = tan(fov/2);
	
	vec3 end_color;
	vec3 camera_dir = normalize(
		FORE_VECTOR
		+ RIGHT_VECTOR * (RIGHT_EXTENT * (screen_coords.x/width - 0.5) * 2)
		+ TOP_VECTOR * (TOP_EXTENT * (screen_coords.y/height - 0.5) * -2) 
	);

	for (int i = 0; i < lights.length(); i++) {
		Light light = lights[i];
		int depth = 0;
		float factor = 1.0f;
		Ray ray = Ray(pos, camera_dir);

		while (depth < 18) {
			Hit hit = raycast(ray);

			if (hit.type != NONE) {
				// AMBIENT
				if (hit.type == SPHERE)
					end_color += factor * AMBIENT * hit.color * light.color;
				vec3 light_dir = normalize(light.pos - hit.pos);

				Hit hit2 = raycast(Ray(light.pos, -light_dir));

				if (hit2.id == hit.id && length(hit.pos-hit2.pos) < 0.001) {
					// DIFFUSE
					float diffuse = max(0, DIFFUSE * dot(light_dir, hit.normal));
					vec3 flh = factor * light.color * hit.color;
					end_color += hit.type * flh * diffuse;

					// SPECULAR
					vec3 incoming = normalize(hit.pos - light.pos);
					vec3 reflect = reflect(incoming, hit.normal);
					vec3 view = normalize(pos - hit.pos);

					end_color += max(0, dot(reflect, view)) * hit.type * flh * SPECULAR * pow(dot(reflect, view), SHINING);

					incoming = normalize(hit.pos - ray.pos);
					reflect = reflect(incoming, hit.normal);
					ray = Ray(hit.pos+reflect*0.0001, normalize(reflect));
					factor *= REFLECT*diffuse;
					depth += 1;
				} else {
					end_color = factor * light.color * WHITE;
					break;
				}
			} else {
				break;
			}
		}
	}

	return vec4(end_color, 1.0);
}