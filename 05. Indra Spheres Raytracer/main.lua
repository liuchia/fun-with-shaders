local WIDTH = 800;
local HEIGHT = 600;
local FOV = math.rad(80);

local t = 0;
local pos = {0, 0, 15};
local dir = {0, -1, -1};

local canvas, shader;

function love.load()
	love.window.setMode(WIDTH, HEIGHT, {resizable = false});
	canvas = love.graphics.newCanvas(WIDTH, HEIGHT);
	shader = love.graphics.newShader("shader.glsl");

	shader:send("width", WIDTH);
	shader:send("height", HEIGHT);
	shader:send("fov", FOV);
end

function love.draw()
	love.graphics.draw(canvas, 0, 0);
	love.graphics.print(love.timer.getFPS() .. " FPS", 10, 10);
end

function love.update(dt)
	t = t + dt;
	pos = {15 * math.sin(.25*t), 0, 14 * math.cos(.25*t)};
	dir = {-1*math.sin(.25*t), -0.5, -1*math.cos(.25*t)};

	shader:send("dir", dir);
	shader:send("pos", pos);

	love.graphics.setCanvas(canvas);
		love.graphics.setShader(shader);
			love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT);
		love.graphics.setShader();
	love.graphics.setCanvas();
end