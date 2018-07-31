local WIDTH = 800;
local HEIGHT = 600;

local pos_x = 0.0;
local pos_y = 0.0;
local range = 4;

local canvas, shader;

function love.load()
	love.window.setMode(WIDTH, HEIGHT, {resizable = false});
	canvas = love.graphics.newCanvas(WIDTH, HEIGHT);
	shader = love.graphics.newShader("shader.glsl");

	shader:send("width", WIDTH);
	shader:send("height", HEIGHT);
end

function love.draw()
	love.graphics.draw(canvas, 0, 0);
	love.graphics.setColor(255, 0, 0);
		love.graphics.print(love.timer.getFPS() .. " FPS", 10, 10);
	love.graphics.setColor(255, 255, 255);
end

function love.update(dt)
	if range > 0.1 and love.keyboard.isDown("z") then range = range * 0.998; end
	if range < 5 and love.keyboard.isDown("x") then range = range / 0.998; end
	if love.keyboard.isDown("left") then pos_x = pos_x - range/100; end
	if love.keyboard.isDown("right") then pos_x = pos_x + range/100; end
	if love.keyboard.isDown("up") then pos_y = pos_y - HEIGHT/WIDTH*range/100; end
	if love.keyboard.isDown("down") then pos_y = pos_y + HEIGHT/WIDTH*range/100; end

	shader:send("range_x", range);
	shader:send("pos_x", pos_x);
	shader:send("pos_y", pos_y);

	love.graphics.setCanvas(canvas);
		love.graphics.setShader(shader);
			love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT);
		love.graphics.setShader();
	love.graphics.setCanvas();
end