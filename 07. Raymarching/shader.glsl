extern vec3 pos;
extern vec3 dir;
extern float width;
extern float height;
extern float fov;

const float AMBIENT = 0.25;
const float DIFFUSE = 0.5;
const float SPECULAR = 0.95;
const float SHINING = 50;

const float EPSILON = 0.001;
const float INCREMENT = 1.0 / 1000.0;
const float PI = 3.14159265;

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

Light lights[] = Light[] (
	Light(vec3(0,50,13), vec3(1, 1, 1))
);

float rand(vec2 c){
	return fract(sin(dot(c.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float noise(vec2 p, float freq ){
	float unit = width/freq;
	vec2 ij = floor(p/unit);
	vec2 xy = mod(p,unit)/unit;
	//xy = 3.*xy*xy-2.*xy*xy*xy;
	xy = .5*(1.-cos(PI*xy));
	float a = rand((ij+vec2(0.,0.)));
	float b = rand((ij+vec2(1.,0.)));
	float c = rand((ij+vec2(0.,1.)));
	float d = rand((ij+vec2(1.,1.)));
	float x1 = mix(a, b, xy.x);
	float x2 = mix(c, d, xy.x);
	return mix(x1, x2, xy.y);
}

float pNoise(vec2 p, int res){
	float persistance = .5;
	float n = 0.;
	float normK = 0.;
	float f = 4.;
	float amp = 1.;
	int iCount = 0;
	for (int i = 0; i<50; i++){
		n+=amp*noise(p, f);
		f*=2.;
		normK+=amp;
		amp*=persistance;
		if (iCount == res) break;
		iCount++;
	}
	float nf = n/normK;
	return nf*nf*nf*nf;
}

float f(float x, float y) {
	return 150*pNoise(vec2(x, y), 5);
}

vec3 UP_VECTOR = vec3(0.0, 1.0, 0.0);
vec3 terrain_color = vec3(203.0/255, 45.0/255, 62.0/255);
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
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

	float fog = 0;
	float vel = 2;
	vec3 p = pos;

	while (fog < 1) {
		vec3 op = p;
		p += camera_dir * vel;
		if (f(p.x, p.z) >= p.y) {
			vec3 hit = vec3((p.x+op.x)*0.5, f(p.x, p.z), (p.z+op.z)*0.5);
			end_color += (1-fog) * AMBIENT * terrain_color;

			vec3 normal = normalize(vec3(
				f(p.x-EPSILON, p.z) - f(p.x+EPSILON, p.z),
				2.0f*EPSILON,
				f(p.x, p.z-EPSILON) - f(p.x, p.z+EPSILON)
			));

			for (int i = 0; i < lights.length(); i++) {
				Light light = lights[i];

				vec3 light_dir = normalize(light.pos - hit);
				float diffuse = max(0, DIFFUSE * dot(light_dir, normal));
				end_color += (1-fog) * light.color * terrain_color * diffuse;	
			}
			break;
		}
		fog += 0.01;
		vel *= 1.01;
	}

	end_color += fog * vec3(1, 214.0/255, 191.0/255);
	return vec4(end_color, 1);
}