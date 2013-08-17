--[[
--	levelscripts.lua
--	contains scripts which indicate behavior on objects etc. on a per-level base
--
--]]--

local scripts = {}

function scripts.default(character, condition, game)

	if (game == nil) then 
		game = _G['game']
	end

	if condition == "init" then
		for key, object in pairs(game.tiledobjects) do 
			local spawnarea = nil
			if object.name == "SpawnArea" then 
				spawnarea = object
				--[[for k, v in pairs(spawnarea) do
					print (k, v) 
				end
				]]--
				for i = 1, 10, 1 do
					game.createCreature(spawnarea.x + math.random(spawnarea.width), 
					spawnarea.y + math.random(spawnarea.height), 
					math.pi * i/30,  
					math.random(10, 30), math.random(2, 20))
					--	game.createCreature(400, math.random(600), math.pi * i/30,  math.random(10, 30), math.random(5, 60))
				end
			end
		end	

	else	
		if (nil ~= character.area) then 
			print ("in script. Area: " .. character.area)
		end
		--- check if player is in area
		for i ,to in ipairs(game.tiledobjects) do
			character.area = game.getCharacterObjectArea(character, to)

			if character.area == "WayDown" then
				--Todo: go to next level
				game.levels.next()
				if nil ==  game.levels.currentlevel then break end
				character, game = game.loadLevelByIndex(game.levels.index, character)
				break
			end

			if character.area == "Shop" then
				game.inShop()
			end
		end
	end
	return character, game
end

function scripts.level2(character, condition, game)
	love.graphics.print("level 2", 960/2, 300)
	for i ,to in ipairs(game.tiledobjects) do
		character.area = game.getCharacterObjectArea(character, to)
		if character.area ~= nil then 
			love.graphics.print (character.area, 700, 10)
		end
		if character.area == "Treasure" and condition =="init" then
			for i = 1, 10 do
				game.createLoot(to.x + math.random(to.width), to.y + math.random(to.height))
			end
		end

		if character.area == "WayDown" then
			--Todo: go to next level
			game.levels.next()
			if nil ==  game.levels.currentlevel then break end
			character, game = game.loadLevelByIndex(game.levels.index, character)
			break
		end
	end
	return character, game

end

return scripts
