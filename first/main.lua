local math = require ("first.math")
local tiled = require ("first.tiledmap")

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
game.view = {x=400, y=300}

function game.keydown(key)

	if key == 'w' then
		character.y = character.y -character.speed
	end
	
	if key == 's' then
		character.y = character.y +character.speed
	end

	if key == 'a' then
		character.x = character.x -character.speed
	end
	
	if key == 'd' then
		character.x = character.x +character.speed
	end
end

game.projectiles = {}

function game.isWalkableTile(x,y) 
	local tx, ty = TiledMap_GetTilePosUnderMouse(x, y, 400, 300)
	local tiletype = TiledMap_GetMapTile(tx, ty, 1)
	--FIXME magic tile type
	if 10 == tiletype then
		return true 
	else return false end
end

function game.handleMouse(character, angle)

	if love.mouse.isDown('l') then
		local x = character.x + character.speed * math.sin(angle)
		local y = character.y - character.speed * math.cos(angle)
		
		if (game.isWalkableTile(x,y)) then
			character.x = x
			character.y = y
		end

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
	local creature = {x=x, y=y, direction=direction, size=size, health=health, speed=1.5}
	table.insert(game.creatures, creature)
end

game.loot = {}

function game.createLoot(x,y) 
	local loot = { x = x, y = y, value = math.random(5) }
	table.insert(game.loot, loot)
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

function game.setupCharacter() 
	local objects = TiledMap_Objects("tiled/test.tmx")
	for k, object in pairs(objects) do 
		if object.name == "Start" then
			character.x = object.x + object.width/2 + 6
			character.y = object.y + object.height/2 + 6
		end
	end
	game.tiledobjects = objects

	character.gfx = love.graphics.newCanvas(12,12)
	character.gfx:renderTo(function()
		r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(0,255,0,255)
		love.graphics.circle('fill', 6,6,5,30)
		love.graphics.setColor(r, g, b, a)	
		love.graphics.line(5,1, 6,2)
	end)
	character.loot = 0
	character.speed = 1.3
	return character
end

game.tiledobjects = {}

function love.load()
	love.mouse.setVisible(false)
	canvas = love.graphics.newCanvas()
	image = love.graphics.newImage('gfx/testi.png')	
	image:setFilter('linear', 'nearest')
	variable = 0
	-- title = love.graphics.getCaption()
	title = "loverogue"
	TiledMap_Load("tiled/test.tmx", 33)

	game.setupCharacter()
	for i = 1, 30, 1 do
		game.createCreature(math.random(740), math.random(540), math.pi * i/30,  math.random(10, 30), math.random(5, 60))
	--	game.createCreature(400, math.random(600), math.pi * i/30,  math.random(10, 30), math.random(5, 60))
	end
end


function love.draw()
	canvas:clear();
	canvas:renderTo(function()
		TiledMap_DrawNearCam(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
		r, g, b, a = love.graphics.getColor()
		love.graphics.draw(image, 400, 300, variable, 8, 8, 8, 8 )
		love.graphics.setColor(128, 128, 255, 225)
		love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), 10, 10)

		--background for top bar
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle('fill', 0,0,love.graphics.getWidth(), 24)

		love.graphics.setColor(255,255,0,255)
		for i = 1, #game.loot do
			love.graphics.circle('fill', game.loot[i].x, game.loot[i].y, 3+game.loot[i].value*2, 8-game.loot[i].value)
		end
		love.graphics.print("Loot: " .. character.loot, 10, 3)

		love.graphics.setColor(255, 0, 0, 225)
		for i = 1, #game.creatures do 
			crtr = game.creatures[i]
			if crtr == nil then break end
			if crtr.health < 1 then 
				table.remove(game.creatures, i)
				game.createLoot(crtr.x, crtr.y)
			end
			love.graphics.rectangle('fill', crtr.x, crtr.y, crtr.size, crtr.size) 
		end


		love.graphics.setColor(0, 0, 255, 128)
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
		local crtr = game.creatures[i]
		-- go towards player
		if (math.random() < 0.020 and 150 > math.dist(crtr.x, crtr.y, character.x, character.y)) then 
			game.creatures[i].direction = math.getAngle(crtr.x, crtr.y, character.x, character.y)
			--print (game.creatures[i].direction)
			game.creatures[i].speed = 2.5
		end	
		if (math.random() < 0.010) then
			game.creatures[i].direction = (math.random()*math.pi ) 
			game.creatures[i].speed = 1.0
		end
		local crx = game.creatures[i].x + crtr.speed * math.sin(game.creatures[i].direction)
		local cry = game.creatures[i].y + crtr.speed * math.cos(game.creatures[i].direction)
		if game.isWalkableTile(crx +crtr.size /2, cry + crtr.size/2) then
			game.creatures[i].x = crx
			game.creatures[i].y = cry
		end
		if (game.creatures[i].x < 0 or game.creatures[i].y < 0) or 
			(game.creatures[i].x +crtr.size > 800 or game.creatures[i].y + crtr.size > 600) then 
			game.creatures[i].direction = game.creatures[i].direction * -1
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

	if #game.loot > 0 then
		for i = 1, #game.loot do
			if nil == game.loot[i] then break end
			local chr = character
			local loot = game.loot[i]
			if (3 > math.dist(chr.x, chr.y, loot.x, loot.y)) then
				character.loot = chr.loot +  loot.value
				table.remove(game.loot, i)
			end
		end
	end
	--- check if player is in end area
	for i = 1, #game.tiledobjects do
		local object = game.tiledobjects[i]
		if object.name == "WayDown" then
			if character.x > tonumber(object.x) and character.y > tonumber(object.y) and 
				character.x < object.x + object.width and 
				character.y < object.y + object.height then
				--Todo: go to next level
				love.event.push("quit")
			end
		end
	end

end
