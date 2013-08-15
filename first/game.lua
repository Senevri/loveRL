--[[ game code ]]--
--

local game = {}
game.view = {x=400, y=300, xratio = 1, yratio = 1}


function game.keydown(key, character)
	local x = character.x
	local y = character.y

	if key == 'w' then
		y = character.y -character.speed
	end
	
	if key == 's' then
		y = character.y +character.speed
	end

	if key == 'a' then
		x = character.x -character.speed
	end
	
	if key == 'd' then
		x = character.x +character.speed
	end
	if game.isWalkableTile(x,y) then
		character.x = x
		character.y = y
	end

	return character
end

game.projectiles = {}

function game.isWalkableTile(x,y) 
	local tx, ty = TiledMap_GetTilePosUnderMouse(x, y, game.view.x, game.view.y)
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
	local creature = {x=x, y=y, direction=direction, size=size, health=health, speed=1.5, damage=0.5}
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
	local character = {}
	local objects = TiledMap_Objects("tiled/test.tmx")
	for k, object in pairs(objects) do
		print(object.name, object.x, object.y)
		objects[k].x = object.x - game.view.x + (love.graphics.getWidth()/2 )
		objects[k].y = object.y - game.view.y + (love.graphics.getHeight()/2 )
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
	local image = love.graphics.newImage('gfx/testi.png')	
	image:setFilter('linear', 'nearest')
	character.gfx = image
	character.loot = 0
	character.speed = 1.5
	character.health = 6
	character.attack = {damage=1, range=1}
	character.invincibility = 0
	return character
end

game.tiledobjects = {}

return game
