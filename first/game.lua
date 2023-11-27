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
        if character.y > 2*love.graphics.getHeight()/3 then
            game.adjusting.amount = 16--love.graphics.getHeight()/8
            game.adjusting.direction = -1
        end
        if character.y < 32 then --love.graphics.getHeight()/8 then
            game.adjusting.amount = 32--love.graphics.getHeight()/8
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
            if (tonumber(obj.x) <= x) and (tonumber(game.adjustY(obj.y)) <= y) and ((obj.x + obj.width) >= x) and ((game.adjustY(obj.y)+obj.height) >= y) then
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

game.crgfx = {
    spider = "gfx/spidercreature_320.png",
    goblin = "gfx/goblincreature_320.png",
    colossus = "gfx/colossuscreature_320.png",
    dragon = "gfx/bosscreature_320.png",
}

game.animationsources = {
    spider = "gfx/spidercreature_strip.png"
}


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

function game.createCreatureAnimation(crtype)
    local animation = nil
    local src = game.animationsources[crtype]
    if (nil ~= src) then
        --print(src)
        local image = love.graphics.newImage(src)
        local canvas = love.graphics.newCanvas(320*1, 320)
        canvas:renderTo(function()
            love.graphics.draw(image, 0, 0, 0,
            canvas:getWidth()/image:getWidth(),
            canvas:getHeight()/image:getHeight())
        end)
        if crtype == "spider" then
            animation = newAnimation(canvas,
            320, 320, 0.2, 2, 1
            )
        end
        animation:play();
        print ("framecount: " .. #animation.frames)
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


function game.setupCharacter(chr)
    local character = chr
    if nil == chr then
        character = {}
    end

	if game.testing then character.loot = 9999 end

    local objects = TiledMap_Objects(game.levels.currentlevel)
    for k, object in pairs(objects) do
        objects[k].x = object.x - game.view.x + (love.graphics.getWidth()/2 )
        objects[k].y = object.y - game.view.y + (love.graphics.getHeight()/2 )
        if object.name == "Start" then
            character.x = object.x + object.width/2 + 6
            character.y = object.y + object.height/2 + 6
        end
    end
    game.tiledobjects = objects

    --local image = love.graphics.newImage('gfx/blank_strip.png')
	local image = love.graphics.newImage('gfx/test_char2_strip.png')
    image:setFilter('linear', 'nearest')
    local wh = 32 -- width, height of target frame
    local framecountx = 2
    character.size = 16
    character.gfx = love.graphics.newCanvas(wh * framecountx,wh)
    character.gfx:renderTo(function()
        r, g, b, a = love.graphics.getColor()
        --[[
        love.graphics.circle('fill', 6,6,5,30)
        ]]--
        -- lots of extra space per frame, so...
        love.graphics.draw(image, 0, 0, 0, (framecountx * (wh)/(image:getWidth())), ((wh)/image:getHeight()), 0, 0)
        love.graphics.setColor(r, g, b, a)
        --love.graphics.line(5,1, 6,2)
    end)

    --character.gfx = image
    character.animation = newAnimation(character.gfx, 32,32,0.5, 2)
	character.area = {}
    if nil == chr then
        character.loot = 0
        character.speed = 1.5
        character.health = 6
        character.attack = {damage=1, range=1, cooldown = 0}
        character.portrait = game.portraits.default
    end
    character.invincibility = 0
    return character
end


game.tiledobjects = {}

game.sfx = {}

game.shop = {}

game.levels = require("first.levels")
game.levels.init(game)

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
    character = game.setupCharacter(character)

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
        attack = (character.attack.damage + 0.5) *6,
        range = (character.attack.range + 0.5) *6,
        speed = (character.speed + 0.5) *6,
		health = 5
    }

	love.graphics.setColor(0,0,16,144)
	love.graphics.rectangle("fill", 6, 60, 128, 80)
	love.graphics.setColor(255,212,0,255)
    love.graphics.print("Sacrifice Loot", 10, 64)
    love.graphics.print("[1]attack " .. shop.attack, 10, 80)
    love.graphics.print("[2]range " .. shop.range, 10, 96)
    love.graphics.print("[3]speed " .. shop.speed, 10, 112)
	love.graphics.print("[4]health " .. shop.health, 10, 128)
    game.shop = shop
    love.graphics.setColor(r,g,b,a)
	return game
end

return game
