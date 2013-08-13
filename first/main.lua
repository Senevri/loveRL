math = require "math"

function math.getAngle(x1,y1, x2,y2) return math.atan2(x2-x1, y2-y1) end

character = {}

function love.load()
	canvas = love.graphics.newCanvas()
	image = love.graphics.newImage('gfx/testi.png')	
	variable = 0
	-- title = love.graphics.getCaption()
	title = "loverogue"
	character.gfx = love.graphics.newCanvas(12,12)
	character.gfx:renderTo(function()
		r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(255,0,0,255)
		love.graphics.circle('fill', 6,6,5,30)
		love.graphics.setColor(r, g, b, a)	
		love.graphics.line(5,1, 6,2)
	end)
	character.x = 30
	character.y = 30
end

function love.keypressed(key)
	if key ==  'escape' then
		love.event.push('quit')
	end
end

function love.keydown(key)

	if key == 'w' then
		character.y = character.y -1
	end
	
	if key == 's' then
		character.y = character.y +1
	end

	if key == 'a' then
		character.x = character.x -1
	end
	
	if key == 'd' then
		character.x = character.x +1
	end
end

function love.draw()
	canvas:clear();
	canvas:renderTo(function()
		r, g, b, a = love.graphics.getColor()
		love.graphics.draw(image, 400, 300, variable, 8, 8, 8, 8 )
		love.graphics.setColor(128, 128, 255, 225)
		love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), 10, 10)
		love.graphics.setColor(r, g, b, a)
	end)
	love.graphics.draw(canvas)
	
	for keyIndex =  1, 4, 1 do 
		key =  {'w', 'a', 's', 'd'}
		if love.keyboard.isDown(key[keyIndex]) then
			love.keydown(key[keyIndex])	
		end
	end

	--love.graphics.print(math .. "\0", 0, 0)
	angle = -1 * math.getAngle(love.mouse.getX(), love.mouse.getY(), character.x,character.y )
	love.graphics.draw(character.gfx, character.x, character.y, angle, 1, 1, 6, 6)
	love.graphics.setCaption(title .. " (FPS: " .. love.timer.getFPS() .. ")")
	variable = variable + 0.05
	if variable == 1 then
		variable = 0
	end
end
