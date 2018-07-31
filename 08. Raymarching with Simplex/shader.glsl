extern vec3 camera_pos;
extern vec3 camera_dir;
extern float width;
extern float height;
extern float fov;

const vec3 PURPLE = vec3(48.0/255, 18.0/255, 45.0/255);
const vec3 CRIMSON = vec3(135.0/255, 7.0/255, 52.0/255);
const vec3 ORANGE = vec3(203.0/255, 45.0/255, 62.0/255);
const vec3 RED = vec3(239.0/255, 71.0/255, 58.0/255);
const vec3 WHITE = vec3(1, 214.0/255, 191.0/255);

vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v){
  const vec4 C = vec4(0.211324865405187, 0.366025403784439,
           -0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
  + i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
    dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

const float MAX_HEIGHT = 100.0f;
float f(vec2 v) {
	float terrain_height = mix(snoise(v*0.002), snoise(v*0.004 + vec2(1.61, 1.61)), 0.4);
	return MAX_HEIGHT*mix(terrain_height, snoise(v*0.05 + vec2(1, 1)), 0.01);
}

const float STEP = 0.0025f;
const float MAX_DISTANCE = 750.0f;
struct March { bool hit; float t; vec3 pos; };
March march(vec3 pos, vec3 dir) {
	March result;

	if (pos.y > MAX_HEIGHT && dir.y > 0) {
		result.hit = false;
		return result;
	}

	float mint = 0.01f;
	if (pos.y > MAX_HEIGHT && dir.y < 0) mint = (pos.y - MAX_HEIGHT) / -dir.y;

	float dt = STEP;
	float prevh = 0.0f;
	float prevy = 0.0f;
	for (float t = mint; t <= MAX_DISTANCE; t += dt) {
		vec3 p = pos + t * dir;
		float h = f(p.xz);
		if (p.y < h) {
			result.t = t - dt + dt*(prevh-prevy)/(p.y-prevy-h+prevh);
			result.hit = true;
			result.pos = pos + result.t * dir;
			return result;
		}
		prevh = h;
		prevy = p.y;
		dt += STEP * t;
	}
	result.hit = false;
	return result;
}

vec3 get_normal(vec3 pos, float t) {
	float epsilon = t * 0.0001;
	return normalize(vec3(
		f(vec2(pos.x-epsilon, pos.z)) - f(vec2(pos.x+epsilon, pos.z)),
		2.0f*epsilon,
		f(vec2(pos.x, pos.z-epsilon)) - f(vec2(pos.x, pos.z+epsilon))
	));
}

const vec3 LIGHT_DIR = normalize(vec3(1,1,1));
vec3 get_shadow(vec3 pos, vec3 dir) {
	float shadow = 1.0;
	float t = 3.0;
	for(int i=0; i<40; i++) {
		vec3 p = pos + t * dir;
		float h = p.y - f(p.xz);
		shadow = min(shadow, 1000.0*h/t);
		t += h;
		if(shadow<0.001 || p.y > MAX_HEIGHT) break;
	}
	return clamp(shadow, 0.0, 1.0);
}

const float DIFFUSE = 0.61;
vec3 get_shading(vec3 pos, vec3 normal) {
	float diffuse = max(0, DIFFUSE * dot(LIGHT_DIR, normal));
	return WHITE * diffuse * get_shadow(pos, LIGHT_DIR);	
}

vec3 get_terrain(vec3 pos, vec3 normal) {
	if (pos.y < -25) return PURPLE;
	if (normal.y > 0.93) return CRIMSON;
	if (normal.y > 0.87) return RED;
	return WHITE;
}

const float FOG_MIN = 25.0f;
const float FOG_MAX = MAX_DISTANCE;
vec3 terrain_color(vec3 pos, float t) {
	vec3 normal = get_normal(pos, t);
	vec3 shading = get_shading(pos, normal);
	vec3 terrain = get_terrain(pos, normal);
	float fog = max(0.0f, (t - FOG_MIN) / (FOG_MAX - FOG_MIN));
	return fog * WHITE + (1.0f - fog) * shading * terrain;
}

const vec3 UP_VECTOR = vec3(0.0, 1.0, 0.0);
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec3 FORE_VECTOR = normalize(camera_dir);
	vec3 RIGHT_VECTOR = cross(FORE_VECTOR, UP_VECTOR);
	vec3 TOP_VECTOR = cross(RIGHT_VECTOR, FORE_VECTOR);
	float hfov = fov / height * width;
	float RIGHT_EXTENT = tan(hfov/2);
	float TOP_EXTENT = tan(fov/2);
	vec3 true_dir = normalize(
		FORE_VECTOR
		+ RIGHT_VECTOR * (RIGHT_EXTENT * (screen_coords.x/width - 0.5f) * 2.0f)
		+ TOP_VECTOR * (TOP_EXTENT * (screen_coords.y/height - 0.5f) * -2.0f) 
	);

	vec3 end_color;

	vec3 pos = camera_pos;
	vec3 dir = true_dir;
	March result = march(pos, dir);
	if (result.hit) {
		end_color = terrain_color(result.pos, result.t);
	} else {
		end_color = WHITE;
	}

	return vec4(end_color, 1.0);
}