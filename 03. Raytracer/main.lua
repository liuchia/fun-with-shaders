local WIDTH = 800;
local HEIGHT = 600;
local FOV = math.rad(70);

local t = 0;
local pos = {0, 0, 5};
local dir = {0, 0, -1};

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
	love.graphics.setColor(255, 0, 0);
		love.graphics.print(love.timer.getFPS() .. " FPS", 10, 10);
	love.graphics.setColor(255, 255, 255);
end

function love.update(dt)
	t = t + dt;
	pos = {5 * math.sin(t), 0, 5 * math.cos(t)};
	dir = {-1*math.sin(t), 0, -1*math.cos(t)};
	shader:send("dir", dir);
	shader:send("pos", pos);

	love.graphics.setCanvas(canvas);
		love.graphics.setShader(shader);
			love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT);
		love.graphics.setShader();
	love.graphics.setCanvas();
end