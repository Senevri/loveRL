local math = require ("first.math")

--function math.getAngle(x1,y1, x2,y2) return math.atan2(x2-x1, y2-y1) end

character = {}


function love.keypressed(key)
	if key ==  'escape' then
		love.event.push('quit')
	end
	if key == "tab" then
      		local state = not love.mouse.isVisible()   -- the opposite of whatever it currently is
      		love.mouse.setVisible(state)
   	end
	print( key)
end

game = {}

function game.keydown(key)

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

game.projectiles = {}

function game.handleMouse(character, angle)
	if love.mouse.isDown('l') then
		character.x = character.x + 1 * math.sin(angle)
		character.y = character.y - 1 * math.cos(angle)

	end

	if love.mouse.isDown('r') then
		game.createProjectile(character.x, character.y, character.direction)
	end

	return character
end

function game.createProjectile(x, y, direction)
	local projectile = {x = x, y = y, direction = direction, age = 0 }
	table.insert(game.projectiles, projectile)
end


game.creatures = {}

function game.createCreature(x,y,direction,size, health) 
	local creature = {x=x, y=y, direction=direction, size=size, health=health}
	table.insert(game.creatures, creature)
end

function game.collision(creature, projectile) 	
	local size = creature.size / 2
	local cx = creature.x + size
	local cy = creature.y + size
	--print (projectile.x, projectile.y)
	if math.dist(cx, cy, projectile.x, projectile.y) <=size then
		return true
	end

	return false
end

function love.load()
	love.mouse.setVisible(false)
	canvas = love.graphics.newCanvas()
	image = love.graphics.newImage('gfx/testi.png')	
	variable = 0
	-- title = love.graphics.getCaption()
	title = "loverogue"
	character.gfx = love.graphics.newCanvas(12,12)
	character.gfx:renderTo(function()
		r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(0,255,0,255)
		love.graphics.circle('fill', 6,6,5,30)
		love.graphics.setColor(r, g, b, a)	
		love.graphics.line(5,1, 6,2)
	end)
	character.x = 30
	character.y = 30

	for i = 1, 30, 1 do
		game.createCreature(math.random(800), math.random(600), math.random(),  math.random(10, 30), math.random(5, 60))
	end
end


function love.draw()
	canvas:clear();
	canvas:renderTo(function()
		r, g, b, a = love.graphics.getColor()
		love.graphics.draw(image, 400, 300, variable, 8, 8, 8, 8 )
		love.graphics.setColor(128, 128, 255, 225)
		love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), 10, 10)
		love.graphics.setColor(255, 0, 0, 225)

		for i = 1, #game.creatures do 
			crtr = game.creatures[i]
			if crtr == nil then break end
			if crtr.health < 1 then 
				table.remove(game.creatures, i)
			end
			love.graphics.rectangle('fill', crtr.x, crtr.y, crtr.size, crtr.size) 
		end
		love.graphics.setColor(0, 0, 255, 192)
		for i = 1, #game.projectiles do
			local prjctl = game.projectiles[i]
			if prjctl == nil then
				break
			end		

			if prjctl.age > 60 then
				table.remove(game.projectiles, i)
			else
				game.projectiles[i].age = game.projectiles[i].age + 1
				love.graphics.circle('fill', prjctl.x, prjctl.y, 5,5)
				game.projectiles[i].x = prjctl.x + 4*math.sin(prjctl.direction)
				game.projectiles[i].y = prjctl.y - 4*math.cos(prjctl.direction)
			end
		end
		love.graphics.setColor(r, g, b, a)
	end)
	love.graphics.draw(canvas)
	
	for keyIndex =  1, 4, 1 do 
		key =  {'w', 'a', 's', 'd'}
		if love.keyboard.isDown(key[keyIndex]) then
			game.keydown(key[keyIndex])	
		end
	end

	angle = -1 * math.getAngle(love.mouse.getX(), love.mouse.getY(), character.x,character.y )
	character.direction = angle
	character = game.handleMouse(character, angle)

	--love.graphics.print(math .. "\0", 0, 0)
	love.graphics.draw(character.gfx, character.x, character.y, angle, 1, 1, 6, 6)
	love.graphics.setCaption(title .. " (FPS: " .. love.timer.getFPS() .. ")")
	variable = variable + 0.05
	if variable == 1 then
		variable = 0
	end
	for i = 1, #game.creatures do
		if nil == game.creatures[i] then break end
		if (math.random() < 0.005) then 
			game.creatures[i].direction = math.random()
		end
		local crtr = game.creatures[i]
		game.creatures[i].x = game.creatures[i].x + 1 * math.sin(game.creatures[i].direction)
		game.creatures[i].y = game.creatures[i].y - 1 * math.cos(game.creatures[i].direction)
		if (game.creatures[i].x < 0 or game.creatures[i].y < 0) or 
			(game.creatures[i].x +crtr.size > 800 or game.creatures[i].y + crtr.size > 600)then 
			game.creatures[i].direction = game.creatures[i].direction -0.5
		end

		for j = 1, #game.projectiles do
			if nil == game.projectiles[j] then break end
			if game.collision(game.creatures[i], game.projectiles[j]) then 
				table.remove(game.projectiles, j)
				--print (game.creatures[i])
				game.creatures[i].health = game.creatures[i].health- 1
			end
		end
	end

end
