// ADD ANTIALIASING ?
extern float time;

const float AMBIENT = 1;

struct Quad {
	vec2 pos;
	vec2 width;
	vec2 height;
	vec3 color;
};

struct Light {
	vec2 pos;
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
	Light(vec2(0, 0), WHITE, 1000),
	Light(vec2(1000,500), WHITE, 1000),
	Light(vec2(480, 270), RED, 2000)
);

bool intersect(vec2 pos, vec2 target, vec2 p1, vec2 p2) {
	vec2 a = pos;
	vec2 b = target - pos;
	vec2 c = p1;
	vec2 d = p2 - p1;

	float denom = b.x*d.y - d.x*b.y;
	if (denom > 0) {
		vec2 ac = (a-c);
		vec2 ca = (c-a);
		float t = (ac.x*b.y - b.x*ac.y) / (-denom);
		float s = (ca.x*d.y - d.x*ca.y) / (denom);
		return s >= 0 && s <= 1 && t >= 0 && t <= 1;
	} else {
		return false;
	}
}

bool raycast(vec2 light, vec2 point) {
	for (int i = 0; i < quads.length(); i++) {
		vec2 v1 = quads[i].pos;
		vec2 v2 = v1 + quads[i].width;
		vec2 v3 = v2 + quads[i].height;
		vec2 v4 = v1 + quads[i].height;
		if (intersect(point, light, v1, v2)) return false;
		if (intersect(point, light, v2, v3)) return false;
		if (intersect(point, light, v3, v4)) return false;
		if (intersect(point, light, v4, v1)) return false;
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

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	lights[2].pos = vec2(400 + 1000*sin(time), 300 + 1000*cos(time));

	vec3 end_color = vec3(0,0,0);
	bool insider = false;

	for (int i = 0; i < quads.length(); i++) {
		if (inside(quads[i], screen_coords)) {
			insider = true;
			end_color += quads[i].color * AMBIENT;
			for (int j = 0; j < lights.length(); j++) {
				if (inside(quads[i], lights[j].pos)) {
					float strength = max(0, lights[j].radius - length(lights[j].pos-screen_coords)) / lights[j].radius;
					end_color += quads[i].color * lights[j].color * strength;
					break;
				}
			}
			break;
		}
	}

	if (!insider) {
		for (int i = 0; i < lights.length(); i++) {
			float strength = max(0, lights[i].radius - length(lights[i].pos-screen_coords)) / lights[i].radius;
			float inside_factor = 1.0;
			for (int j = 0; j < quads.length(); j++) {
				if (inside(quads[j], lights[i].pos)) {
					inside_factor = 0.5;
					break;
				}
			}
			if (raycast(lights[i].pos, screen_coords))
				end_color += inside_factor*lights[i].color*strength;
		}
	}

	return vec4(end_color, 1.0);
}