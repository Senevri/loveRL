--[[
	First LÖVE2d Game. 
	Author: Esa Karjalainen
	(esa.karjalainen (at) gmail.com)
	Tiled maps, Diablolike
]]--

--[[
--	Todo:
--	Specific Monsters:
--	 - Small
--	 - Medium
--	 - Large
--	 - Boss
--	Animations
--	Traps
--	Monster AI
--	Items
--	Melee
--
--	Done:
]]--

local math = require ("first.math")
local tiled = require ("libs.tiledmap") -- customized

local game = require("first.game")

require("libs.AnAL")
-- external library, consider using. 
--HC = require 'HardonCollider'

--function math.getAngle(x1,y1, x2,y2) return math.atan2(x2-x1, y2-y1) end

math.setup()

character = {}

function love.keypressed(key)
	if key ==  'escape' then
		love.event.push('quit')
	end
	if key ==  'return' then

		for i, time in pairs(times) do
			--print("index: " .. i .. " time: " .. time)
		end
		game.paused = not game.paused
	end
	if key == "tab" then
      		local state = not love.mouse.isVisible()   -- the opposite of whatever it currently is
      		love.mouse.setVisible(state)
   	end
	if character.area == "Shop" then 
	
		if key == "1" and 
			character.loot >= game.shop.attack
			then
			character.attack.damage = character.attack.damage + 0.5
			character.loot = character.loot - game.shop.attack
		end

		if key == "2" and 
			character.loot >= game.shop.range
			then
			character.attack.range = character.attack.range + 0.5 
			character.loot = character.loot - game.shop.range
		end

		if key == "3" and 
			character.loot >= game.shop.speed 
			then

			character.speed = character.speed + 0.5 
			character.loot = character.loot - game.shop.speed 
		end
	end

	--for testing
	if game.testing == false then return end
	if key == "f1" then 
		game.paused = false
		character.health = character.health +1
		game.levels.next()
		if nil ~=  game.levels.currentlevel then 
			character, game = game.loadLevelByIndex(game.levels.index, character)
		end
	end

	--print( key)
end

marker = nil
crgfx = {}
game.music = {}
game.effects = {}

function love.load()
	--load sounds
	game.sfx["attack"] = love.audio.newSource("sfx/shoot.wav", static)
	game.sfx["pickup_loot"] = love.audio.newSource("sfx/Pickup_Coin.wav", static)
	game.sfx["hurt"] = love.audio.newSource("sfx/Hit_Hurt.wav", static)

	--[[game.music["default"] = love.audio.newSource("3p_music/BoxCat_Games_-_12_-_Passing_Time.mp3", static)
	game.music["default"]:setVolume(0.1)
	
	game.music["battle"] = love.audio.newSource("3p_music/BoxCat_Games_-_05_-_Battle_Boss.mp3", static)
	game.music["battle"]:setVolume(0.1)
	love.audio.play(game.music["default"])
]]--

	love.mouse.setVisible(false)
	canvas = love.graphics.newCanvas()
	--image = love.graphics.newImage('gfx/testi.png')	
	--image:setFilter('linear', 'nearest')

	for i, filename in ipairs(game.crgfx) do 
		table.insert(crgfx, love.graphics.newImage(filename))
		--crgfx[i]:setFilter('linear', 'nearest')
	end

	variable = 0
	-- title = love.graphics.getCaption()
	title = "loveRL"

	character, game = game.loadLevelByIndex(1)

	-- create directional display marker
	local markerimage = love.graphics.newImage('gfx/marker.png')
	markerimage:setFilter('linear', 'nearest')
	local wh = 48
	marker = love.graphics.newCanvas(wh, wh)
	marker:renderTo(function()
		r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(255,255,255,224)
		--[[
		love.graphics.circle('fill', 6,6,5,30)
		]]--
		love.graphics.draw(markerimage, 0, 0, 0, (wh/markerimage:getWidth()), (wh/markerimage:getHeight()), 
			0,0)
		love.graphics.setColor(r, g, b, a)	
		--love.graphics.line(5,1, 6,2)
	end)

	splash = love.graphics.newImage("gfx/splash.png")
	splash:setFilter('linear', 'nearest')

	--love.graphics.draw(splash, 0, 0, 0, sw/love.graphics.getWidth(), sh/love.graphics.getHeight())
	game.paused = true
	game.setup()
end

function love.update(dt)
	character.animation:update(dt)
    for i, creature in ipairs(game.creatures) do
        if creature.animation ~= nil then 
            print("not nil")
            creature.animation:update(dt) 
        end
    end
end

times = { start = 0, middle = 0, endseg = 0, custom = 0, rest = 0}

function love.draw()

	local ttime = love.timer.getMicroTime()
	character.portrait = game.portraits.default;
	if (character.invincibility > 15) then character.portrait = game.portraits.hurt end;
	local screenw = love.graphics.getWidth()
	local screenh = love.graphics.getHeight()
	if game.paused then 
		local sw, sh, aspect,screenaspect
		sw = splash:getWidth()
		sh = splash:getHeight()
	
		aspect = sw/sh
		screenaspect = screenw/screenh

		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(splash, screenw/2,screenh/2, 0, 
			love.graphics.getWidth()/sw*aspect/screenaspect, love.graphics.getHeight()/sh,
			sw/2, sh/2)
		return 
	end

	if love.graphics.getWidth() < (2*game.view.x) then 
		game.view.x = character.x
		game.view.y = character.y
	end
	r, g, b, a = love.graphics.getColor()

	times.start = times.start + (love.timer.getMicroTime() - ttime);
	ttime = love.timer.getMicroTime()

	--background for top bar
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle('fill', 0,0,love.graphics.getWidth(), 24)

		love.graphics.setColor(255,255,255,255)
		TiledMap_DrawNearCam(game.view.x,game.view.y, nil)
		--game.view.x = character.x
		--game.view.y = character.y 
		--TiledMap_DrawNearCam(character.x,character.y, nil)
		game.adjustObjectPositions()	
		local rsize = 16
		local mul = {1, 2, 4, 8}
		for i, img in ipairs(crgfx) do
			love.graphics.draw(img, screenw-(2*rsize*mul[i]), 80, variable, rsize*mul[i]/320, rsize*mul[i]/320, 160, 160)
		end

		variable = variable + 0.01
		if variable == 1 then
			variable = 0
		end
		love.graphics.setColor(0, 255, 0, 250)
		love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), 10, 10)


		love.graphics.setColor(r, g, b, a)
	--end);
	--love.graphics.draw(canvas, 0, 0)

	times.middle = times.middle + (love.timer.getMicroTime() - ttime);
	ttime = love.timer.getMicroTime()

	for i, to in  ipairs(game.tiledobjects) do 
		--local to = game.tiledobjects[i]
		if nil == to then break end
		if nil ~= to.gid then 
			local tileimage = TiledMap_GetTileByGid(to.gid)
			if nil ~= tileimage then 
				love.graphics.draw(tileimage, to.x, to.y, 0, 1, 1, 0, tileimage:getHeight() ) 
			end
		end

		local object = game.tiledobjects[i]
		if nil == object or nil ~= object.gid then break end

		character.area = game.getCharacterObjectArea(character,object)
	end
	times.endseg = times.endseg + (love.timer.getMicroTime() - ttime);
	ttime = love.timer.getMicroTime()
	
	-- run per-level custom script

	local levelfunction = game.levels.getFunction(game.levels.index)
	if nil ~= levelfunction then 
		character, game = levelfunction(character, nil, game) 
	end

	times.custom = times.custom + (love.timer.getMicroTime() - ttime);
	ttime = love.timer.getMicroTime()


	love.graphics.setColor(255,255,0,255)
	for i, loot in ipairs( game.loot ) do
		love.graphics.circle('fill', loot.x, loot.y, 3+loot.value*2, 8-loot.value)

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

	--canvas = love.graphics.newCanvas(screenw, screenh)
	--canvas:renderTo(function()
		love.graphics.print("Loot: " .. character.loot, 10, 3)


		love.graphics.setColor(255, 0, 0, 225)
		love.graphics.print("Health: " .. character.health, 100, 3)

		love.graphics.setColor(255, 0, 255, 225)

		love.graphics.print("Attack: " .. character.attack.damage, 200, 3)
		love.graphics.print("Range: " .. character.attack.range, 300, 3)

		love.graphics.print("Speed: " .. character.speed, 400, 3)
	--end)
	--love.graphics.draw(canvas)

	love.graphics.setColor(255, 0, 0, 225)

	--Draw Creatures-- 
	for i = 1, #game.creatures do 
		crtr = game.creatures[i]
		if crtr == nil then break end
		if crtr.health < 1 then 
			table.remove(game.creatures, i)
			game.createLoot(crtr.x, crtr.y)
		end

		wh = 48
		love.graphics.setColor(255, 255, 255, 255)
        drawCreature(crtr)

		--done drawing, now logic
		if nil == game.creatures[i] then break end
		local crtr = game.creatures[i]

		-- take player health on collision 
		if game.collision(character, crtr) and
			character.invincibility == 0 then
			character.health = character.health - crtr.damage
			crtr.speed = 0 
			character.invincibility = 30
			character.portrait = game.portraits.hurt
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
			game.creatures[i].direction = (math.random(0, 32)*math.pi/16) 
			game.creatures[i].speed = 1.0
		end
		--
		local crx, cry
		crx, cry = math.translate(crtr.x, crtr.y, game.creatures[i].direction, crtr.speed)

		if game.isWalkableTile(crx, cry, crtr.size) then
			game.creatures[i].x = crx
			game.creatures[i].y = cry
		else 
			game.creatures[i].direction = game.creatures[i].direction + math.pi/16
		end

        --[[ 
		if (game.creatures[i].x < 0 or game.creatures[i].y < 0) or 
			(game.creatures[i].x +crtr.size > love.graphics.getWidth() or 
			game.creatures[i].y + crtr.size > love.graphics.getHeight()) then 
			game.creatures[i].direction = game.creatures[i].direction + math.pi
		end
        ]]--

		for j = 1, #game.projectiles do
			if nil == game.projectiles[j] then break end
			if game.collision(game.creatures[i], game.projectiles[j]) then 
				table.remove(game.projectiles, j)
				--print (game.creatures[i])
				game.creatures[i].health = game.creatures[i].health-character.attack.damage
			end
		end
	end


	for i = 1, #game.projectiles do
		local prjctl = game.projectiles[i]
		
		if prjctl == nil then
			break
		end		

		if prjctl.age > character.attack.range*10 then
			table.remove(game.projectiles, i)
		else
			game.projectiles[i].age = game.projectiles[i].age + 1
			love.graphics.setColor(0, 192-prjctl.age, 255, 160)
			love.graphics.circle('fill', prjctl.x, prjctl.y, 5+character.attack.damage,5)
			game.projectiles[i].x, game.projectiles[i].y = math.translate(prjctl.x, prjctl.y, prjctl.direction, prjctl.speed)
		end
	end
	love.graphics.setColor(r, g, b, a)
	--end)
	--love.graphics.draw(canvas)

	for keyIndex =  1, 4, 1 do 
		key =  {'w', 'a', 's', 'd'}
		if love.keyboard.isDown(key[keyIndex]) then
			character = game.keydown(key[keyIndex], character)	
		end
	end


	local angle = math.getAngle(character.x, character.y,  love.mouse.getX(), love.mouse.getY() )
	character.direction = angle
	character = game.handleMouse(character, angle)

	if character.invincibility > 0 then 
		r, g, b, a = love.graphics.getColor()
		character.invincibility = character.invincibility - 1
		love.graphics.setColor(255,128,128,255)
	end

	
	--love.graphics.draw(character.gfx, character.x, character.y, 0, 1, 1, (character.gfx:getHeight()/2), (character.gfx:getWidth()/2))
	character.animation:draw(character.x-character.size, character.y-character.size)
    -- local frame = character.animation:getCurrentFrame() --returns index
	-- love.graphics.draw(frame, character.x, character.y, 0, 1, 1, frame:getHeight()/2, frame:getWidth()/2)
	love.graphics.setColor(0,255,32,220)
	love.graphics.draw(marker, character.x, character.y, angle + math.halfPI, 1, 1, (marker:getHeight()/2), (marker:getWidth()/2))
	love.graphics.setColor(r,g,b,a)
	love.graphics.setCaption(title .. " (FPS: " .. love.timer.getFPS() .. ")")

	-- draw character portrait with assumption it's 256 by 256.
	love.graphics.draw(character.portrait, screenw /2, screenh -64, 0, 0.5, 0.5, 128, 128)

	--- check if player dead
	if character.health <= 0 then
		--fixme make proper
		love.event.push("quit") 
	end
	times.rest = times.rest + (love.timer.getMicroTime() - ttime);
	ttime = love.timer.getMicroTime()

end

function drawCreature(crtr) 
    local crwidth=crtr.gfx:getWidth()
    local crheight=crtr.gfx:getHeight()
    if crtr.animation == nil then 
        love.graphics.draw(crtr.gfx, 
        crtr.x+crtr.size/2, 
        crtr.y + (crtr.size/2),
        math.halfPI + crtr.direction, crtr.size/crwidth, crtr.size/crheight, 
        crwidth/2, crheight/2	
        )
    else
        crtr.animation:draw(
        crtr.x+crtr.size/2, 
        crtr.y + (crtr.size/2),
        math.halfPI + crtr.direction, crtr.size/crwidth, crtr.size/crheight, 
        crwidth/2, crheight/2	
        )
    end
    love.graphics.setColor(255, 0, 0, 128)
    love.graphics.draw(marker, crtr.x + crtr.size/2, crtr.y+crtr.size/2, 
    math.halfPI + crtr.direction, 2.2*crtr.size/48, 2.2*crtr.size/48, 24, 24)
end
