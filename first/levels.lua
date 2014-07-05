local levels = {
	__items = {"level0.tmx", "test.tmx", "test2.tmx", "BossLevel.tmx" },
	__functions = {nil, nil, game.scripts.level2, game.scripts.bosslevel},
	folder = "tiled/"
	index = 0,
	currentlevel = nil
	}
levels.currentlevel = "tiled/test.tmx"

function levels.next() {
	levels.index = levels.index + 1
	levels.currentlevel = levels.__items[levels.index]
}

function levels.seekByIndex (index) 
	levels.index = index
	levels.currentlevel = levels.folder .. levels.__items[index]
	return levels.currentlevel
end

function levels.addFunction(index, lvfunction)
	levels.__functions[index] = lvfunction
end

function levels.getFunction(index)
	func = levels.__functions[index]
	if nil == func then
		return game.scripts.default
	else
		return func
	end
end 

return levels;