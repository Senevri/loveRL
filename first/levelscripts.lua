--[[
--	levelscripts.lua
--	contains scripts which indicate behavior on objects etc. on a per-level base
--
--]]--

local scripts = {bossspawned = 0}

local creatureSpecs = {
    spider = { size=32},
    goblin = { size=40},
    colossus = { size=64},
    boss = { size=128, spawned = false}
}

function shop(key, character, game)

	if nil ~= character.area and character.area["Shop"] then
        print ("shop transaction")
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
        if key == "4" and
            character.loot >= game.shop.health
            then
				character.loot = character.loot - game.shop.health
                character.health = character.health + 1
            end
	end
	key = nil
	return character, game, key
end

function scripts.default(character, condition, game)

	if (game == nil) then
		game = _G['game']
	end

	if condition == "init" then
		for key, object in pairs(game.tiledobjects) do
			local spawnarea = nil
			if object.name == "SpawnArea" then
				spawnarea = object
				local randomcreature = {"spider", "goblin", "colossus"}
				for i = 1, 10, 1 do
					local crid = math.random(3)
                    local spec = creatureSpecs[randomcreature[crid]]
					game.createCreature(
                    spawnarea.x + math.random(spawnarea.width),
					spawnarea.y + math.random(spawnarea.height),
					math.pi * i/30,
					spec.size, 5*crid,
					randomcreature[crid])
					--	game.createCreature(400, math.random(600), math.pi * i/30,  math.random(10, 30), math.random(5, 60))
				end
			end
		end
		table.insert(game.inputScripts, shop)

	else
		if (nil ~= character.area) then
			-- print ("in script. Area: " .. character.area)
		end
		--- check if player is in area
		for i ,to in ipairs(game.tiledobjects) do
			local temparea = game.getCharacterObjectArea(character, to)
			if nil~= temparea then character.area[temparea] = true end

			if character.area["WayDown"] then
				--Todo: go to next level
				game.levels.next()
				if nil ==  game.levels.currentlevel then break end
				character, game = game.loadLevelByIndex(game.levels.index, character)
				break
			end

			if character.area["Shop"] then
				game = game.inShop()
			end
		end
	end
	return character, game
end

function scripts.level2(character, condition, game)
	love.graphics.print("level 2", 960/2, 300)
	for i ,to in ipairs(game.tiledobjects) do
		local temparea = game.getCharacterObjectArea(character, to)
		if nil ~= temparea then character.area[temparea] = true end
		if character.area["Treasure"] and condition =="init" then
			for i = 1, 10 do
				game.createLoot(to.x + math.random(to.width), to.y + math.random(to.height))
			end
		end

		if character.area["WayDown"] then
			--Todo: go to next level
			game.levels.next()
			if nil ==  game.levels.currentlevel then break end
			character, game = game.loadLevelByIndex(game.levels.index, character)
			break
		end
	end
	return character, game
end

function scripts.bosslevel(character, condition, game)
	character, game = scripts.default(character, condition, game)

	if condition == "init" then
		TiledMap_SetLayerInvisByName("Hidden")
		TiledMap_SetLayerInvisByName("Hidden2")
		game.music.default:stop();
		game.music.battle:play();
		print("bosslevel init")
		--table.insert(game.inputScripts, shop)
	else

		if nil ~= character.area and character.area["ItemRoom"] then
			--love.graphics.print (character.area, 700, 10)
		end

		for i, to in ipairs(game.tiledobjects) do
			--print(to.name)
			local temparea = game.getCharacterObjectArea(character, to)
			-- if nil ~= temparea then character.area[temparea] = true
			if character.area["ItemRoom"] then
				love.graphics.print ("Found Secret Area!", 700, 10)
				if nil == scripts.chestlooted then
					TiledMap_SetLayerVisibleByName("Hidden")
				end
				TiledMap_SetLayerVisibleByName("Hidden2")
			end

			if character.area["Chest"] then
				-- give money
				if nil ~= to.properties then
					for j, prop in ipairs(to.properties) do
						if prop.name == "loot" then
							character.loot = character.loot + prop.value
							prop.value = 0
							scripts.chestlooted = true
						end
					end
				end
				--to.loot = 0
				TiledMap_SetLayerInvisByName("Hidden")
			end

			if to.name == "BossSpawn" then
				if scripts.bossspawned == 0 then
					local spawnarea = to
					love.graphics.print("boss!", to.x, game.adjustY(to.y))
					game.createCreature(
					spawnarea.x,
					spawnarea.y,
					math.pi * i/30,
					creatureSpecs["boss"].size, 100,
					"colossus")
					scripts.bossspawned = 1
				end
			end

			--[[if character.area == "Shop" then
				game.inShop()
			end
			]]--

			if (game.scripts.creatureSlain == nil) then
				game.scripts.creatureSlain = function(creature)
					for i = 0, 10, 1 do
						game.createLoot(creature.x + math.random(creature.size), creature.y + math.random(creature.size))
					end
				end
			end
			--clear on exit
			if character.area["WayDown"] then
				game.scripts.creatureSlain =nil
				game.scripts.bossspawned = 0
				game.scripts.chestlooted = nil
				--standard snippet
				game.levels.next()
				if nil ==  game.levels.currentlevel then break end
				character, game = game.loadLevelByIndex(game.levels.index, character)
				break
			end

		end
	end
	return character, game
end

return scripts
