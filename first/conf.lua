function love.conf(t)
    t.title = "lovehack"        -- The title of the window the game is in (string)
    t.author = "Esa Karjalainen"        -- The author of the game (string)
    t.url = nil                 -- The website of the game (string)
    t.identity = nil            -- The name of the save directory (string)
    t.version = "0.10.2"         -- The LÖVE version this game was made for (string)
    t.console = true 		--(boolean, Windows only)
    t.release = false           -- Enable release mode (boolean)
    t.gammacorrect = false

    t.window.title = "LöveARL"
    t.window.icon = nil
    t.window.width = 960        -- The window width (number)
    t.window.height = 600       -- The window height (number)
    t.window.borderless = false
    t.window.resizable = false
    t.window.minwidth = 1
    t.window.minheight = 1
    t.window.fullscreen = false -- Enable fullwindow (boolean)
    t.window.fullscreentype = "desktop"
    t.window.vsync = true       -- Enable vertical sync (boolean)
    t.window.msaa = 0           -- The number of FSAA-buffers (number)
    t.window.display = 1
    t.window.highdpi = false
    t.window.x = nil
    t.window.y = nil

    t.modules.audio = true      -- Enable the audio module (boolean)
    t.modules.event = true      -- Enable the event module (boolean)
    t.modules.graphics = true   -- Enable the graphics module (boolean)
    t.modules.image = true      -- Enable the image module (boolean)
    t.modules.joystick = true   -- Enable the joystick module (boolean)
    t.modules.keyboard = true   -- Enable the keyboard module (boolean)
    t.modules.math = true
    t.modules.mouse = true      -- Enable the mouse module (boolean)
    t.modules.physics = true    -- Enable the physics module (boolean)
    t.modules.sound = true      -- Enable the sound module (boolean)
    t.modules.system = true
    t.modules.timer = true      -- Enable the timer module (boolean)
    t.modules.touch = true
    t.modules.video = true
    t.modules.window = true
    t.modules.thread = true
end
