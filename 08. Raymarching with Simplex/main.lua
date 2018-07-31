local WIDTH = 800;
local HEIGHT = 600;
local SCALE = 1;
local FOV = math.rad(90);

local pos = {0, 130, 0};
local dir = {-1, -1, -1};
local angle = 0;

local canvas, shader;

function love.load()
	love.window.setMode(WIDTH*SCALE, HEIGHT*SCALE, {resizable = false});
	canvas = love.graphics.newCanvas(WIDTH, HEIGHT);
	shader = love.graphics.newShader("shader.glsl");

	shader:send("width", WIDTH);
	shader:send("height", HEIGHT);
	shader:send("fov", FOV);
end

function love.draw()
	love.graphics.push();
		love.graphics.scale(SCALE);
		love.graphics.draw(canvas, 0, 0);
	love.graphics.pop();
	love.graphics.print(love.timer.getFPS() .. " FPS", 10, 10);
end

function love.update(dt)
	if love.keyboard.isDown("w") then for i = 1,3,2 do pos[i] = pos[i] + 50*dir[i]*dt end end
	if love.keyboard.isDown("s") then for i = 1,3,2 do pos[i] = pos[i] - 50*dir[i]*dt end end
	if love.keyboard.isDown("d") then angle = (angle + 1.5*dt) % (2*math.pi) end
	if love.keyboard.isDown("a") then angle = (angle - 1.5*dt) % (2*math.pi) end
	dir = {math.cos(angle), -0.5, math.sin(angle)};

	shader:send("camera_dir", dir);
	shader:send("camera_pos", pos);

	love.graphics.setCanvas(canvas);
		love.graphics.setShader(shader);
			love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT);
		love.graphics.setShader();
	love.graphics.setCanvas();
end