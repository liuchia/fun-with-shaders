local WIDTH = 1366;
local HEIGHT = 768;
local SCALE = 2;

local pos_x = 0.0;
local pos_y = 0.0;
local range = 4;

local canvas, shader;
local change, scrsht = true, false;

function love.load()
	love.filesystem.setIdentity("Screenshots")
	love.window.setMode(WIDTH, HEIGHT, {resizable = false});
	canvas = love.graphics.newCanvas(WIDTH*SCALE, HEIGHT*SCALE);
	shader = love.graphics.newShader("shader.glsl");

	shader:send("width", WIDTH*SCALE);
	shader:send("height", HEIGHT*SCALE);
end

function love.draw()
	love.graphics.push();
		love.graphics.scale(1/SCALE);
		love.graphics.draw(canvas, 0, 0);
	love.graphics.pop();

	if not scrsht then
		love.graphics.setColor(255, 0, 0);
			love.graphics.print(love.timer.getFPS() .. " FPS", 10, 10);
		love.graphics.setColor(255, 255, 255);
	else
		local screenshot = love.graphics.newScreenshot();
	    screenshot:encode("png", "scrsht.png");
	    scrsht = false;
	end
end

function love.update(dt)
	if change then
		shader:send("range_x", range);
		shader:send("pos_x", pos_x);
		shader:send("pos_y", pos_y);

		love.graphics.setCanvas(canvas);
			love.graphics.setShader(shader);
				love.graphics.rectangle("fill", 0, 0, WIDTH*SCALE, HEIGHT*SCALE);
			love.graphics.setShader();
		love.graphics.setCanvas();
		change = false;
	end

	if range > 0.00001 and love.keyboard.isDown("z") then change = true; range = range * 0.98; end
	if range < 5 and love.keyboard.isDown("x") then change = true; range = range / 0.98; end
	if love.keyboard.isDown("left") then change = true; pos_x = pos_x - range/100; end
	if love.keyboard.isDown("right") then change = true; pos_x = pos_x + range/100; end
	if love.keyboard.isDown("up") then change = true; pos_y = pos_y - HEIGHT/WIDTH*range/100; end
	if love.keyboard.isDown("down") then change = true; pos_y = pos_y + HEIGHT/WIDTH*range/100; end
end

function love.mousepressed(x, y, b)
	if b == 1 then
		scrsht = true
	end
end