const float BOX_HEIGHT = 3.0;

struct Quad {
	vec2 pos;
	vec2 width;
	vec2 height;
	vec3 color;
};

struct Light {
	vec3 pos;
	vec3 color;
	float radius;
};

const vec3 PURPLE = vec3(48.0/255, 18.0/255, 45.0/255);
const vec3 CRIMSON = vec3(135.0/255, 7.0/255, 52.0/255);
const vec3 ORANGE = vec3(203.0/255, 45.0/255, 62.0/255);
const vec3 RED = vec3(239.0/255, 71.0/255, 58.0/255);
const vec3 WHITE = vec3(1, 214.0/255, 191.0/255);

Quad quads[] = Quad[] (
	Quad(vec2(603, 88), vec2(33,0), vec2(0,31), CRIMSON),
	Quad(vec2(661, 84), vec2(35,0), vec2(0,43), CRIMSON),
	Quad(vec2(575, 126), vec2(16,0), vec2(0,39), CRIMSON),
	Quad(vec2(605, 135), vec2(21,0), vec2(0,30), CRIMSON),
	Quad(vec2(638, 127), vec2(22,0), vec2(0,25), CRIMSON),
	Quad(vec2(581, 208), vec2(113,-119), vec2(58,0), CRIMSON),
	Quad(vec2(736, 59), vec2(23,0), vec2(0,23), CRIMSON),
	Quad(vec2(605, 205), vec2(27,0), vec2(0,17), CRIMSON),
	Quad(vec2(608, 253), vec2(22,0), vec2(0,37), CRIMSON),
	Quad(vec2(640, 257), vec2(71,0), vec2(0,68), CRIMSON),
	Quad(vec2(617, 250), vec2(82,-96), vec2(94,0), CRIMSON),
	Quad(vec2(715, 260), vec2(46,0), vec2(0,56), CRIMSON),

	Quad(vec2(528, 288), vec2(73,0), vec2(0,68), RED),

	Quad(vec2(499, 279), vec2(25,0), vec2(0,35), WHITE),
	Quad(vec2(433, 318), vec2(92,0), vec2(0,72), WHITE),
	Quad(vec2(528, 360), vec2(38,0), vec2(0,110), WHITE),
	Quad(vec2(438, 396), vec2(86,0), vec2(0,32), WHITE),
	Quad(vec2(396, 433), vec2(125,0), vec2(0,55), WHITE),

	Quad(vec2(635, 429), vec2(62,0), vec2(0,52), PURPLE),
	Quad(vec2(585, 498), vec2(52,0), vec2(0,28), PURPLE),
	Quad(vec2(638, 485), vec2(56,0), vec2(0,53), PURPLE),

	Quad(vec2(630, 352), vec2(19,0), vec2(0,23), ORANGE),
	Quad(vec2(681, 330), vec2(33,0), vec2(0,42), ORANGE),
	Quad(vec2(696, 378), vec2(18,0), vec2(0,32), ORANGE),
	Quad(vec2(716, 320), vec2(48,0), vec2(0,44), ORANGE),
	Quad(vec2(718, 368), vec2(79,0), vec2(0,42), ORANGE),
	Quad(vec2(713, 412), vec2(100,0), vec2(0,148), ORANGE),
	Quad(vec2(805, 481), vec2(59,0), vec2(0,67), ORANGE),
	Quad(vec2(675, 544), vec2(24,0), vec2(0,19), ORANGE),
	Quad(vec2(543, 595), vec2(51,0), vec2(0,24), ORANGE),
	Quad(vec2(596, 565), vec2(230,0), vec2(0,44), ORANGE)
);

Light lights[] = Light[] (
	//Light(vec3(0,0,0), vec3(.5,.5,.5), 600),
	Light(vec3(300, 360, 16), WHITE, 1000),
	Light(vec3(980, 360, 16), WHITE, 1000)
);

bool intersect(vec3 pos, vec3 light, vec2 p1, vec2 p2) {
	vec2 a = pos.xy;
	vec2 b = light.xy - a;
	vec2 c = p2;
	vec2 d = p1 - p2;

	float denom = b.x*d.y - d.x*b.y;
	if (denom > 0) {
		vec2 ac = (a-c);
		vec2 ca = -ac;
		float t = (ac.x*b.y - b.x*ac.y) / (-denom);
		float s = (ca.x*d.y - d.x*ca.y) / (denom);

		if (s >= 0 && s <= 1 && t >= 0 && t <= 1) {
			float intersection = pos.z + s*(light.z - pos.z);
			return intersection <= BOX_HEIGHT;
		}
	}

	return false;
}

bool raycast(vec3 light, vec3 point) {
	for (int i = 0; i < quads.length(); i++) {
		vec2 v1 = quads[i].pos;
		vec2 v2 = v1 + quads[i].width;
		vec2 v3 = v2 + quads[i].height;
		vec2 v4 = v1 + quads[i].height;
		
		float l = max(length(quads[i].width), length(quads[i].height))*2;
		float dist = length(light.xy - quads[i].pos.xy+quads[i].width/2+quads[i].height/2);
		float limit = dist + 2*l*light.z / (light.z - BOX_HEIGHT);
		if (length(light.xy - point.xy) <= limit) {
			if (intersect(point, light, v1, v2)) return false;
			if (intersect(point, light, v2, v3)) return false;
			if (intersect(point, light, v3, v4)) return false;
			if (intersect(point, light, v4, v1)) return false;
		}
	}
	return true;
}

bool inside(Quad box, vec2 pos) {
	vec2 newpos = pos - box.pos;
	float area = box.width.y*box.height.x - box.width.x*box.height.y;
	float a1 = (newpos.x*box.height.y - newpos.y*box.height.x)/area;
	float a2 = (box.width.x*newpos.y - box.width.y*newpos.x)/area;
	float s = sign(area);
	return s*a1 >= 0 && s*a1 <= 1 && s*a2 >= 0 && s*a2 <= 1;
}

struct SurfacePoint { vec3 color; vec3 pos; bool box; };
SurfacePoint surface_color(vec2 screen_coords) {
	SurfacePoint s;
	s.color = vec3(1, 1, 1);
	s.pos = vec3(screen_coords, 0.0);
	s.box = false;

	for (int i = 0; i < quads.length(); i++) {
		if (inside(quads[i], screen_coords)) {
			s.color = quads[i].color;
			s.pos.z = 3.0;
			s.box = true;
			return s;
		}
	}

	return s;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	//lights[0].pos = vec3(400 + 500*sin(time), 300 + 500*cos(time), 32);

	SurfacePoint s = surface_color(screen_coords);
	vec3 end_color;

	if (s.box) {
		for (int i = 0; i < lights.length(); i++) {
			float dist = length(lights[i].pos - s.pos);
			float strength = max(0, lights[i].radius - dist) / lights[i].radius;
			end_color += strength * lights[i].color * s.color;
		}
	} else {
		for (int i = 0; i < lights.length(); i++) {
			float dist = length(lights[i].pos - s.pos);
			float strength = (lights[i].radius - dist) / lights[i].radius;
			if (strength > 0 && raycast(lights[i].pos, s.pos))
				end_color += WHITE * strength * lights[i].color;
		}
	}

	return vec4(end_color, 1.0);
}