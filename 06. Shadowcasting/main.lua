local WIDTH = 1028;
local HEIGHT = 720;
local SCALE = 0.5;
local canvas, shader;


function love.load()
	love.window.setMode(WIDTH*SCALE, HEIGHT*SCALE, {resizable = false});
	canvas = love.graphics.newCanvas(WIDTH, HEIGHT);
	shader = love.graphics.newShader("shader.glsl");
end

function love.draw()
	love.graphics.push();
		love.graphics.scale(SCALE);
		love.graphics.draw(canvas, 0, 0);
	love.graphics.pop();
	love.graphics.setColor(255, 0, 0);
		love.graphics.print(love.timer.getFPS() .. " FPS", 10, 10);
	love.graphics.setColor(255, 255, 255);
end

local t = 0;
function love.update(dt)
	t = t + dt;
	shader:send("time", t);
	love.graphics.setCanvas(canvas);
		love.graphics.setShader(shader);
			love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT);
		love.graphics.setShader();
	love.graphics.setCanvas();
end