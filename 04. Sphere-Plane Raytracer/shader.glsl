extern vec3 pos;
extern vec3 dir;
extern float width;
extern float height;
extern float fov;
extern float time;

const int NONE = -1;
const int PLANE = 0;
const int SPHERE = 1;

const float AMBIENT = 0.25;
const float DIFFUSE = 0.5;
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

Sphere spheres[] = Sphere[] (
	Sphere(vec3(0,0,0), 3, vec3(48.0/255, 18.0/255, 45.0/255)),
	Sphere(vec3(3,3,3), 1.5, vec3(135.0/255, 7.0/255, 52.0/255)),
	Sphere(vec3(-1,-5,3), 1, vec3(203.0/255, 45.0/255, 62.0/255)),
	Sphere(vec3(-2,2,-6), 1.5, vec3(239.0/255, 71.0/255, 58.0/255)),
	Sphere(vec3(0,6,0), 1, vec3(1, 214.0/255, 191.0/255))
);

Plane planes[] = Plane[] (
	Plane(vec3(0,0,-15), vec3(0,0,1), vec3(1, 214.0/255, 191.0/255)),
	Plane(vec3(0,0,15), vec3(0,0,-1), vec3(1, 214.0/255, 191.0/255)),
	Plane(vec3(0,-15,0), vec3(0,1,0), vec3(1, 214.0/255, 191.0/255)),
	Plane(vec3(0,15,0), vec3(0,-1,0), vec3(1, 214.0/255, 191.0/255)),
	Plane(vec3(-15,0,0), vec3(1,0,0), vec3(1, 214.0/255, 191.0/255)),
	Plane(vec3(15,0,0), vec3(-1,0,0), vec3(1, 214.0/255, 191.0/255))
);

Light lights[] = Light[] (
	Light(vec3(0,0,13), vec3(.6,.3,.3)),
	Light(vec3(3,0,11), vec3(.3,.6,.6)),
	Light(vec3(-1,0,-5), vec3(.1,.1,.1))
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

vec3 newpos(vec3 pos, float freq) {
	float radius = length(pos);
	vec3 i = normalize(pos);
	vec3 j = cross(i, vec3(1,0,0));
	return radius * (sin(freq*time)*i + cos(freq*time)*j);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	spheres[1].pos = newpos(vec3(3,3,3), .25);
	spheres[2].pos = newpos(vec3(5,-2,3), .5);
	spheres[3].pos = newpos(vec3(-2,2,6), 1.0/3);
	spheres[4].pos = newpos(vec3(0,6,0), 1);

	vec3 UP_VECTOR = vec3(0.0, 1.0, 0.0);
	vec3 FORE_VECTOR = normalize(dir);
	vec3 RIGHT_VECTOR = cross(FORE_VECTOR, UP_VECTOR);
	vec3 TOP_VECTOR = cross(RIGHT_VECTOR, FORE_VECTOR);

	float hfov = fov / height * width;
	float RIGHT_EXTENT = tan(hfov/2);
	float TOP_EXTENT = tan(fov/2);
	
	vec3 end_color = vec3(0,0,0);
	vec3 camera_dir = normalize(
		FORE_VECTOR
		+ RIGHT_VECTOR * (RIGHT_EXTENT * (screen_coords.x/width - 0.5) * 2)
		+ TOP_VECTOR * (TOP_EXTENT * (screen_coords.y/height - 0.5) * -2) 
	);

	for (int i = 0; i < lights.length(); i++) {
		Light light = lights[i];
		int depth = 0;
		float factor = 1;
		Ray ray = Ray(pos, camera_dir);

		while (depth < 5) {
			Hit hit = raycast(ray);

			if (hit.type != NONE) {
				// AMBIENT
				end_color += factor * AMBIENT * hit.color * light.color;
				vec3 light_dir = normalize(light.pos - hit.pos);

				Hit hit2 = raycast(Ray(light.pos, -light_dir));

				if (hit2.id == hit.id && length(hit.pos-hit2.pos) < 0.01) {
					// DIFFUSE
					float diffuse = max(0, DIFFUSE * dot(light_dir, hit.normal));
					end_color += factor * light.color * hit.color * diffuse;

					// SPECULAR
					vec3 incoming = normalize(hit.pos - light.pos);
					vec3 reflect = reflect(incoming, hit.normal);
					vec3 view = normalize(pos - hit.pos);
					if (dot(reflect, view) > 0)
						end_color += factor * light.color * hit.color * SPECULAR * pow(dot(reflect, view), SHINING);

					incoming = normalize(hit.pos - ray.pos);
					reflect = reflect(incoming, hit.normal);
					ray = Ray(hit.pos+reflect*0.01, normalize(reflect));
					factor *= REFLECT * diffuse;
					depth += 1;
				} else {
					break;
				}
			} else {
				break;
			}
		}
	}

	return vec4(end_color, 1.0);
}