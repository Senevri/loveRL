function love.load()
	canvas = love.graphics.newCanvas()
	--image = love.graphics.newImage('testi.bmp')	
	variable = 0
	-- title = love.graphics.getCaption()
	title = "loverogue"
	character = love.graphics.newCanvas(12,12)
	character:renderTo(function()
		r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(255,0,0,255)
		love.graphics.circle('fill', 6,6,5,30)
		love.graphics.setColor(r, g, b, a)	
	end)
end

function love.keypressed(key)
	if key ==  'escape' then
		love.event.push('quit')
	end
end

function love.draw()
	canvas:clear();
	canvas:renderTo(function()
		r, g, b, a = love.graphics.getColor()
		--love.graphics.draw(image, 400, 300, variable, 0.5, 0.5, 150, 150 )
		love.graphics.setColor(128, 128, 255, 225)
		love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), 10, 10)
		love.graphics.setColor(r, g, b, a)
	end)
	love.graphics.draw(canvas)
	love.graphics.draw(character, 30, 30, 0.2, 1, 1, 0, 0)
	love.graphics.setCaption(title .. " (FPS: " .. love.timer.getFPS() .. ")")
	variable = variable + 0.05
	if variable == 1 then
		variable = 0
	end
end
