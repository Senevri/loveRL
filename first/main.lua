--[[
	First LÖVE2d Game. 
	Author: Esa Karjalainen
	(esa.karjalainen (at) gmail.com)
	Tiled maps, Diablolike
]]--

local math = require ("first.math")
local tiled = require ("first.tiledmap")

local game = require("first.game")

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
	if character.area == "Shop" then 
	
		if key == "1" and 
			character.loot >= ((character.attack.damage+0.5) * 4) 
			then
			character.attack.damage = character.attack.damage + 0.5
			character.loot = character.loot - character.attack.damage * 4
		end

		if key == "2" and 
			character.loot >= ((character.attack.range+0.5) * 4) 
			then
			character.attack.range = character.attack.range + 0.5 
			character.loot = character.loot - character.attack.range * 4
		end

		if key == "3" and 
			character.loot >= ((character.speed+0.5) * 4) 
			then

			character.speed = character.speed + 0.5 
			character.loot = character.loot - character.speed * 4
		end
	end

	print( key)
end

function love.load()
	--load sounds
	game.sfx["attack"] = love.audio.newSource("sfx/shoot.wav", static)
	game.sfx["pickup_loot"] = love.audio.newSource("sfx/Pickup_Coin.wav", static)
	game.sfx["hurt"] = love.audio.newSource("sfx/Hit_Hurt.wav", static)

	love.mouse.setVisible(false)
	canvas = love.graphics.newCanvas()
	image = love.graphics.newImage('gfx/testi.png')	
	image:setFilter('linear', 'nearest')
	variable = 0
	-- title = love.graphics.getCaption()
	title = "loverogue"
	local tilesize = 32
	TiledMap_Load("tiled/test.tmx", tilesize, '/', "tiled/", 1, 1)
	game.view.xratio = love.graphics.getWidth() / (TiledMap_GetMapW() * tilesize )
	game.view.yratio = love.graphics.getHeight() / (TiledMap_GetMapH() * tilesize )
	print (game.view.xratio, game.view.yratio)
	character = game.setupCharacter()

	for key, object in pairs(game.tiledobjects) do 
		local spawnarea = nil
		if object.name == "SpawnArea" then 
			spawnarea = object
			for k, v in pairs(spawnarea) do
				print (k, v) 
			end
			for i = 1, 10, 1 do
				game.createCreature(spawnarea.x + math.random(spawnarea.width), 
						spawnarea.y + math.random(spawnarea.height), 
						math.pi * i/30,  
						math.random(10, 30), math.random(5, 60))
			--	game.createCreature(400, math.random(600), math.pi * i/30,  math.random(10, 30), math.random(5, 60))
			end
		end
	end	
end


function love.draw()
	canvas:clear();
	canvas:renderTo(function()
		if love.graphics.getWidth() < (2*game.view.x) then 
			game.view.x = character.x
			game.view.y = character.y
		end
		TiledMap_DrawNearCam(game.view.x,game.view.y)
		r, g, b, a = love.graphics.getColor()
		love.graphics.draw(image, 740, 64, variable, 4, 4, 8, 8 )
		love.graphics.setColor(0, 255, 0, 250)
		love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), 10, 10)

		--background for top bar
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle('fill', 0,0,love.graphics.getWidth(), 24)
		
		love.graphics.setColor(r, g, b, a)
		for i = 1, #game.tiledobjects do 
			local to = game.tiledobjects[i]
			if nil ~= to.gid then 
				local tileimage = TiledMap_GetTileByGid(to.gid)
				if nil ~= tileimage then 
					love.graphics.draw(tileimage, to.x, to.y, 0, 1, 1, 0, tileimage:getHeight() ) 
				end
			end			
		end

		love.graphics.setColor(255,255,0,255)
		for i = 1, #game.loot do
			love.graphics.circle('fill', game.loot[i].x, game.loot[i].y, 3+game.loot[i].value*2, 8-game.loot[i].value)
		end
		love.graphics.print("Loot: " .. character.loot, 10, 3)

		love.graphics.setColor(255, 0, 0, 225)
		love.graphics.print("Health: " .. character.health, 100, 3)

		love.graphics.setColor(255, 0, 255, 225)

		love.graphics.print("Attack: " .. character.attack.damage, 200, 3)
		love.graphics.print("Range: " .. character.attack.range, 300, 3)

		love.graphics.print("Speed: " .. character.speed, 400, 3)

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


		love.graphics.setColor(0, 192, 255, 160)
		for i = 1, #game.projectiles do
			local prjctl = game.projectiles[i]
			if prjctl == nil then
				break
			end		

			if prjctl.age > character.attack.range*10 then
				table.remove(game.projectiles, i)
			else
				game.projectiles[i].age = game.projectiles[i].age + 1
				love.graphics.circle('fill', prjctl.x, prjctl.y, 5+character.attack.damage,5)
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
			character = game.keydown(key[keyIndex], character)	
		end
	end

	angle = -1 * math.getAngle(love.mouse.getX(), love.mouse.getY(), character.x,character.y )
	character.direction = angle
	character = game.handleMouse(character, angle)

	if character.invincibility > 0 then 
		r, g, b, a = love.graphics.getColor()
		character.invincibility = character.invincibility - 1
		love.graphics.setColor(255,128,128,255)
	end
	--love.graphics.print(math .. "\0", 0, 0)
	love.graphics.draw(character.gfx, character.x, character.y, angle - math.pi/2, 1, 1, (character.gfx:getHeight()/2), (character.gfx:getWidth()/2))
	love.graphics.setColor(r,g,b,a)
	love.graphics.setCaption(title .. " (FPS: " .. love.timer.getFPS() .. ")")
	variable = variable + 0.05
	if variable == 1 then
		variable = 0
	end


	for i = 1, #game.creatures do
		if nil == game.creatures[i] then break end
		local crtr = game.creatures[i]
		
		-- take player health on collision 
		if math.dist(crtr.x + crtr.size/2, crtr.y + crtr.size/2, character.x + 6, character.y+6) < (crtr.size/2 + 6) and
			character.invincibility == 0 then
			character.health = character.health - crtr.damage
			crtr.speed = 0 
			character.invincibility = 30
			game.sfx.hurt:stop()
			game.sfx.hurt:play()
		else
		end



		-- go towards player
		if (math.random() < 0.020 and 150 > math.dist(crtr.x, crtr.y, character.x, character.y)) then 
			game.creatures[i].direction = math.getAngle(crtr.x, crtr.y, character.x, character.y)
			--print (game.creatures[i].direction)
			game.creatures[i].speed = 2.2
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
			(game.creatures[i].x +crtr.size > love.graphics.getWidth() or 
			game.creatures[i].y + crtr.size > love.graphics.getHeight()) then 
			game.creatures[i].direction = game.creatures[i].direction * -1
		end

		for j = 1, #game.projectiles do
			if nil == game.projectiles[j] then break end
			if game.collision(game.creatures[i], game.projectiles[j]) then 
				table.remove(game.projectiles, j)
				--print (game.creatures[i])
				game.creatures[i].health = game.creatures[i].health-character.attack.damage
			end
		end
	end

	if #game.loot > 0 then
		for i = 1, #game.loot do
			if nil == game.loot[i] then break end
			local chr = character
			local loot = game.loot[i]
			if ((3+loot.value) > math.dist(chr.x, chr.y, loot.x+1+loot.value, loot.y+1+loot.value)) then
				character.loot = chr.loot +  loot.value
				table.remove(game.loot, i)
				game.sfx.pickup_loot:stop()
				game.sfx.pickup_loot:play()
			end
		end
	end

	--- check if player is in end area
	for i = 1, #game.tiledobjects do
		character.area = nil
		local object = game.tiledobjects[i]
		if character.x > tonumber(object.x) and character.y > tonumber(object.y) and 
			character.x < object.x + object.width and 
			character.y < object.y + object.height then
			character.area = object.name
		end


		if character.area == "WayDown" then
			--Todo: go to next level
			love.event.push("quit")
		end
	end

	--- check if player dead
	if character.health <= 0 then
		--fixme make proper
		love.event.push("quit") 
	end

end
