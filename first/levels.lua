
local scripts = require("first.levelscripts")
local levels = { 
    __items = {"tiled/level0.tmx", "tiled/test.tmx", "tiled/test2.tmx", "tiled/BossLevel.tmx"},
    __functions = {nil, nil, scripts.level2, scripts.bosslevel},
    index = 0,
    currentlevel = nil
}



function levels.next()
    levels.index = levels.index +1
    levels.currentlevel = levels.__items[levels.index]
end



function levels.seekByIndex(index)
    levels.index = index
    levels.currentlevel = levels.__items[index]
end



function levels.addFunction(index, lvfunction) 
    levels.__functions[index] = lvfunction 
end



function levels.getFunction(index) 

    func = levels.__functions[index]

    if nil == func then
        return scripts.default
    else
        return func
    end
end

return levels

