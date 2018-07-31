local WIDTH = 800;
local HEIGHT = 600;

local pos_x = 0.0;
local pos_y = 0.0;
local range = 4;
local c_x = .5;
local c_y = 0;

local canvas, trap, shader, cog;

function love.load()
	love.window.setMode(WIDTH, HEIGHT, {resizable = false});
	canvas = love.graphics.newCanvas(WIDTH, HEIGHT);
	trap = love.graphics.newCanvas(WIDTH, HEIGHT);
	shader = love.graphics.newShader("shader.glsl");
	cog = love.graphics.newImage("Cog.png");

	love.graphics.setColor(255, 255, 255);
	love.graphics.setCanvas(trap);
		love.graphics.push();
			love.graphics.translate(WIDTH/2, HEIGHT/2);
			love.graphics.draw(cog, -250, -250, 0, 0.5, 0.5);
		love.graphics.pop();
	love.graphics.setCanvas();

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
	if range > 0.00001 and love.keyboard.isDown("z") then range = range * 0.98; end
	if range < 5 and love.keyboard.isDown("x") then range = range / 0.98; end
	if love.keyboard.isDown("left") then pos_x = pos_x - range/100; end
	if love.keyboard.isDown("right") then pos_x = pos_x + range/100; end
	if love.keyboard.isDown("up") then pos_y = pos_y - HEIGHT/WIDTH*range/100; end
	if love.keyboard.isDown("down") then pos_y = pos_y + HEIGHT/WIDTH*range/100; end
	if love.keyboard.isDown("a") then c_x = c_x - 0.005; end
	if love.keyboard.isDown("d") then c_x = c_x + 0.005; end
	if love.keyboard.isDown("w") then c_y = c_y - 0.005; end
	if love.keyboard.isDown("s") then c_y = c_y + 0.005; end

	shader:send("range_x", range);
	shader:send("pos_x", pos_x);
	shader:send("pos_y", pos_y);
	shader:send("cx", c_x);
	shader:send("cy", c_y);

	love.graphics.setColor(255, 255, 255);
	love.graphics.setCanvas(canvas);
		love.graphics.setShader(shader);
			love.graphics.draw(trap, 0, 0);
		love.graphics.setShader();
	love.graphics.setCanvas();
end