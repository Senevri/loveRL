--[[
--	Game code
--
]]--

local game = {}

game.testing = false

game.view = {x=love.graphics.getWidth()/2, y=love.graphics.getHeight()/2, xratio = 1, yratio = 1}

game.portraits = {}
game.creatures = {}
game.projectiles = {}
game.loot = {}

game.inputScripts = {}

game.crgfx = {
    spider = "gfx/spidercreature_320.png",
    goblin = "gfx/goblincreature_320.png",
    colossus = "gfx/colossuscreature_320.png",
    dragon = "gfx/bosscreature_320.png",
}

game.animationsources = {
    spider = {gfx = "gfx/spidercreature_strip.png", delay=0.2, frames=3, framesize=320}
}

function game.setup()
    portraits = {
        default = 'portrait_default.png',
        hurt = 'portrait_hurt.png',
        attack = 'portrait_attack.png',
        quad = 'portrait_quad.png'
    }
    for key, value in pairs(portraits) do
        game.portraits[key] = love.graphics.newImage('gfx/' .. value)
    end

    for k, _ in pairs(game.crgfx) do
        game.createCreatureAnimation(k)
    end
end

game.adjusting = {amount=0, direction=0}
function game.adjustObjectPositions()
    if (game.adjusting.amount ~=0) then
        for i, to in ipairs(game.creatures) do
            to.y = to.y + game.adjusting.direction
        end

        for i, to in ipairs(game.projectiles) do
            to.y = to.y + game.adjusting.direction
        end

        for i, to in ipairs(game.loot) do
            to.y = to.y + game.adjusting.direction
        end
        character.y = character.y + game.adjusting.direction
        game.view.y = game.view.y - game.adjusting.direction
        game.adjusting.amount = game.adjusting.amount -1
    else
        if character.y*SCALE > 2*love.graphics.getHeight()/3 then
            game.adjusting.amount = 16*SCALE--love.graphics.getHeight()/8
            game.adjusting.direction = -1
        end
        if character.y*SCALE < character.size*2*SCALE then --love.graphics.getHeight()/8 then
            game.adjusting.amount = 32*SCALE--love.graphics.getHeight()/8
            game.adjusting.direction = 1
        end
    end
end

function game.adjustY(origy)
    return origy - game.view.y + love.graphics.getHeight()/2
end


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

    if love.mouse.isDown(1) then
        local x, y, wx, wy
        x, y =  math.translate(character.x, character.y, angle, character.speed)

        wx, wy = math.translate(x, y, angle, character.size/2)

        if (game.isWalkableTile(wx,wy)) or game.isWalkableObject(wx,wy) then
            character.x = x
            character.y = y
        end

    end

    if love.mouse.isDown(2) then
        character.portrait = game.portraits.attack
        if character.attack.cooldown > 0 then
            character.attack.cooldown = character.attack.cooldown -1
            game.sfxplaying = game.sfxplaying -1
        else

            local projectile = game.createProjectile(character.x, character.y, character.direction)
            projectile.rate = projectile.rate*character.attack.rate
            projectile.speed = projectile.speed + character.attack.speed
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

function game.isWalkableTile(x, y, size)
    if nil == size then
        size = 0
    end
    local tx, ty = TiledMap_GetTilePosUnderMouse(x+size/2, y+size/2, game.view.x, game.view.y)
    local gid = TiledMap_GetMapTile(tx, ty, 1)
    --FIXME magic tile type
	local tiletype = TiledMap_GetTileProperties(gid).type
    if "walkable" == tiletype then
        return true
    else return false end
end


function game.isWalkableObject(x,y)
    for i, obj in ipairs(game.tiledobjects) do
        -- for walkables, width and height exist --
        if obj.type ~= nil and (obj.type == "walkable") then
            if (tonumber(obj.x) <= x) and (tonumber(game.adjustY(obj.y)) <= y) and ((obj.x + obj.width) >= x) and ((game.adjustY(obj.y)+obj.height) >= y) then
                return true;
            end
        end
    end
    return false;
end

game.sfxplaying = 0

function game.createProjectile(x, y, direction)
    local projectile = {x = x, y = y, direction = direction, age = 0, speed=1, rate =1 }
    table.insert(game.projectiles, projectile)
    return projectile
end

-- TODO: Distinct creatures

function game.createCreature(x,y,direction, size, health, crtype)
    local creature = {
        x=x, y=y, direction=direction,
        size=size, health=health, speed=1.5, damage=0.5,
        gfx = love.graphics.newImage(game.crgfx[crtype]),
        animation = game.createCreatureAnimation(crtype),
    }
    table.insert(game.creatures, creature)
	return creature
end

game.animations = {}

function game.createCreatureAnimation(crtype)
    love.graphics.scale(1)
    for k, anim in pairs(game.animations) do
        if k == crtype then
            print(game.animations)
            local copy = {}
            setmetatable(copy, {__index = anim })
            return copy
        end
    end
    local animation = nil
    local src = game.animationsources[crtype]
    if (nil ~= src) then
        --print(src)
        local image = love.graphics.newImage(src.gfx)
        local canvas = love.graphics.newCanvas(src.framesize*src.frames, src.framesize)
        canvas:renderTo(function()
            love.graphics.draw(image, 0, 0, 0,
            canvas:getWidth()/image:getWidth(),
            canvas:getHeight()/image:getHeight())
        end)
        if crtype == "spider" then
            animation = newAnimation(canvas,
            src.framesize, src.framesize, src.delay, src.frames
            )
        end

        print ("framecount: " .. #animation.frames)
        print("created anim " ..crtype .. ": " .. src.gfx)
        game.animations[crtype] = animation
        animation:play();
    end
    return animation
end

function findNearestValidTile(x, y, half_tile)
    -- get nearest valid tile.
    local offsets = {
        {x = half_tile, y = 0},
        {x = -half_tile, y = 0},
        {x = 0, y = half_tile},
        {x = 0, y = -half_tile}
    }

    for _, offset in ipairs(offsets) do
        local newX, newY = x + offset.x, y + offset.y
        if game.isWalkableTile(newX, newY) then
            return newX, newY
        end
    end

    return x, y  -- If no valid tile found, return the original position
end

function game.createLoot(x,y)
	--FIXME: do not create loot inside a wall
    local half_tile = 32
    x, y = findNearestValidTile(x, y, half_tile)
    local val = math.random(5)
    local loot = { x = x, y = y, value = val, size = 3 + val * 2 }
    table.insert(game.loot, loot)
end

-- let's test if this is universal --
function game.collision(creature, creature2)
    local size = creature.size / 2
    local cx = creature.x + size
    local cy = creature.y + size
    if creature2.size == nil then
        creature2.size = 0
    end
    local size2 = creature2.size / 2
    local cx2 = creature2.x + size2
    local cy2 = creature2.y + size2

    --optimization
    if (cx-cx2)*(cx-cx2)+(cy-cy2)*(cy-cy2) > (size+size2)*(size+size2) then
        return false
    end

    --get accurate distance if the above passed
    --print (projectile.x, projectile.y)
    if math.dist(cx, cy, cx2, cy2) <= size+size2 then
        return true
    end

    return false
end

function game.getCharacterObjectArea(character, object)
    local charx = character.x --+ game.view.x --- (love.graphics.getWidth()/2)
    local chary = character.y
    local objy = object.y - game.view.y + love.graphics.getHeight()/2

    --print(game.testing)
	-- draw box around area
	if game.testing then
		love.graphics.rectangle("line", object.x,
		object.y - game.view.y + love.graphics.getHeight()/2,
		object.width, object.height)
	end

	if charx > tonumber(object.x) and chary > tonumber(objy) and
        charx < object.x + object.width and
        chary < objy + object.height then
        return object.name
    end

    return nil
end




game.tiledobjects = {}

game.sfx = {}

game.shop = {}

game.levels = require("first.levels")
game.levels.init(game)

game.setupCharacter = require("first.character")

function game.loadLevelByIndex(index, character)
    game.loot = {}
    game.creatures = {}

    game.view = {x=love.graphics.getWidth()/2, y=love.graphics.getHeight()/2, xratio = 1, yratio = 1}

    game.levels.seekByIndex(index)
    local tilesize = 32
	print (game.levels.currentlevel)
    TiledMap_Load(game.levels.currentlevel, tilesize, '/', "tiled/", 1, 1)
    game.view.xratio = love.graphics.getWidth() / (TiledMap_GetMapW() * tilesize )
    game.view.yratio = love.graphics.getHeight() / (TiledMap_GetMapH() * tilesize )
    character = game.setupCharacter(character, game)
    print(character.portrait)

    local levelfunction = game.levels.getFunction(index)
    if nil ~= levelfunction then
        character, game = levelfunction(character, "init", game)
    end

    return character, game
end


-- FIXME hacky shop
function game.inShop()
	-- print ("inshop " .. character.area)
    --character.area = "Shop"
    local r, g, b, a = love.graphics.getColor()

    local shop = {
        {item="attack", cost=(character.attack.damage + 0.5) *6},
        {item="range", cost = (character.attack.range + 0.5) *6},
        {item="movement", cost = (character.speed + 0.5) *6},
        {item="firerate", cost = (character.attack.rate + 1)},
        {item="bulletspeed", cost = (character.attack.speed + 1)},
		{item="health", cost = 5}
    }

    prices = {}
    for _, v in ipairs(shop) do
        prices[v.item] = v.cost
    end

    game.drawShopUI(shop)
    game.shop = prices
    love.graphics.setColor(r,g,b,a)
	return game
end

function game.drawShopUI(shop)
    local x = 4 + character.x + character.size/2
    local y = 4 + character.y - character.size/2

    local rowsize = 16

	love.graphics.setColor(0,0,16,144)
	love.graphics.rectangle("fill", x-4, y-4, 128, 4+(1 + #shop) * rowsize)
	love.graphics.setColor(255,212,0,255)
    love.graphics.print("Sacrifice Loot", x, y)

    for i, v in ipairs(shop) do
        love.graphics.print("[" .. tostring(i) .. "]" .. v.item .. " " .. v.cost, x, y+i*rowsize)
    end
end

return game
