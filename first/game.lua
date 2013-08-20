--[[ 
--	Game code 
--
]]--


local game = {}

game.testing = true

game.view = {x=400, y=276, xratio = 1, yratio = 1}


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
	if game.isWalkableTile(x,y) or game.isWalkableObject(x, y) then
		character.x = x
		character.y = y
	end

	return character
end

function game.handleMouse(character, angle)

	if love.mouse.isDown('l') then
		local x, y
		x, y = math.translate(character.x, character.y, angle, character.speed)
		
		if (game.isWalkableTile(x,y)) or game.isWalkableObject(x,y) then
			character.x = x
			character.y = y
		end

	end

	if love.mouse.isDown('r') then
		if character.attack.cooldown > 0 then
			character.attack.cooldown = character.attack.cooldown -1
			game.sfxplaying = game.sfxplaying -1
		else

			local projectile = game.createProjectile(character.x, character.y, character.direction)
			character.attack.cooldown = 60/projectile.rate
			--love.audio.play(game.sfx.attack)
			if 0 >= game.sfxplaying then 
				game.sfx.attack:stop()
				game.sfx.attack:play()
				game.sfxplaying = 6
			end
		end
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


function game.isWalkableObject(x,y)
	for i, obj in ipairs(game.tiledobjects) do 
		-- for walkables, width and height exist -- 
		if obj.type ~= nil and (obj.type == "walkable") then 
			if (tonumber(obj.x) <= x) and (tonumber(obj.y) <= y) and ((obj.x + obj.width) >= x) and ((obj.y+obj.height) >= y) then
				return true;
			end
		end
	end
	return false;
end

game.sfxplaying = 0

function game.createProjectile(x, y, direction)
	local projectile = {x = x, y = y, direction = direction, age = 0, speed=4, rate =30 }
	table.insert(game.projectiles, projectile)
	return projectile
end

-- TODO: Distinct creatures
game.creatures = {}

game.crgfx = {
	"gfx/spidercreature_320.png",
	"gfx/goblincreature_320.png",
	"gfx/colossuscreature_320.png",
	"gfx/bosscreature_320.png",
}

function game.createCreature(x,y,direction,size, health) 
	local creature = {x=x, y=y, direction=direction, size=size, health=health, speed=1.5, damage=0.5}
	table.insert(game.creatures, creature)
end

game.loot = {}

function game.createLoot(x,y) 
	local loot = { x = x, y = y, value = math.random(5) }
	table.insert(game.loot, loot)
end

-- let's test if this is universal -- 
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

function game.getCharacterObjectArea(character, object) 
	if character.x > tonumber(object.x) and character.y > tonumber(object.y) and 
		character.x < object.x + object.width and 
		character.y < object.y + object.height then
		return object.name
		--print (character.area)
	end

	return nil
end


function game.setupCharacter(chr)
	local character = chr
	if nil == chr then
		character = {}
	end
	local objects = TiledMap_Objects(game.levels.currentlevel)
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

	local image = love.graphics.newImage('gfx/testi.png')
	image:setFilter('linear', 'nearest')
	local wh = 16
	character.size = 16
	character.gfx = love.graphics.newCanvas(wh,wh)
	character.gfx:renderTo(function()
		r, g, b, a = love.graphics.getColor()
		--[[
		love.graphics.circle('fill', 6,6,5,30)
		]]--
		love.graphics.draw(image, 0, 0, 0, (wh/image:getWidth()), (wh/image:getHeight()), 0, 0)
		love.graphics.setColor(r, g, b, a)	
		--love.graphics.line(5,1, 6,2)
	end)
	--character.gfx = image
	character.area = nil
	if nil == chr then
		character.loot = 0
		character.speed = 1.5
		character.health = 6
		character.attack = {damage=1, range=1, cooldown = 0}
	end
	character.invincibility = 0
	return character
end

game.tiledobjects = {}

game.sfx = {}

game.shop = {}

game.scripts = require("first.levelscripts")

game.levels = { 
	__items = {"tiled/level0.tmx", "tiled/test.tmx", "tiled/test2.tmx", "tiled/BossLevel.tmx"},
	__functions = {nil, nil, game.scripts.level2, game.scripts.bosslevel},
	index = 0,
	currentlevel = nil
}



function game.levels.next()
	game.levels.index = game.levels.index +1
	game.levels.currentlevel = game.levels.__items[game.levels.index]
end

function game.levels.seekByIndex(index)
	game.levels.index = index
	game.levels.currentlevel = game.levels.__items[index]
end

function game.levels.addFunction(index, lvfunction) 
	game.levels.__functions[index] = lvfunction 
end

function game.levels.getFunction(index) 

	func = game.levels.__functions[index]

	if nil == func then
		return game.scripts.default
	else
		return func
	end
end

function game.loadLevelByIndex(index, character) 
	game.loot = {}
	game.creatures = {}

	game.levels.seekByIndex(index)
	local tilesize = 32
	TiledMap_Load(game.levels.currentlevel, tilesize, '/', "tiled/", 1, 1)
	game.view.xratio = love.graphics.getWidth() / (TiledMap_GetMapW() * tilesize )
	game.view.yratio = love.graphics.getHeight() / (TiledMap_GetMapH() * tilesize )
	character = game.setupCharacter(character)

	local levelfunction = game.levels.getFunction(index)
	if nil ~= levelfunction then
		character, game = levelfunction(character, "init", game)
	end

	return character, game
end

function game.inShop()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(255,255,0,255)
	local shop = {
		attack = (character.attack.damage + 0.5) *6,
		range = (character.attack.range + 0.5) *6,
		speed = (character.speed + 0.5) *6
	}
	love.graphics.print("Sacrifice Loot", 10, 64)
	love.graphics.print("attack " .. shop.attack, 10, 80)
	love.graphics.print("range " .. shop.range, 10, 96)
	love.graphics.print("speed " .. shop.speed, 10, 112)
	game.shop = shop
	love.graphics.setColor(r,g,b,a)
end

return game
