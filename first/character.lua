function setupCharacter(chr, game)
    local character = chr
    if nil == chr then
        character = {}
        character.loot = 10
        character.speed = 2
        character.max_speed = 10
        character.health = 6
        character.attack = {damage=1, range=2, cooldown = 0, rate = 2, speed = 4}
    end

    character.portrait = game.portraits.default
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

    if not character.gfx then

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

        character.animation = newAnimation(character.gfx, wh, wh, 0.5, 2)
    end
	character.area = {}

    character.invincibility = 0
    return character
end

return setupCharacter