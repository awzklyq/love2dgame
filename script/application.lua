_G.app = {}
local metatab =  {
    __call = function(self, param1, ...)
    
    if type(param1) == 'function' then
        table.insert(self, param1);
    else
            for i, v in pairs(self) do
                if type(v) == 'function' then
                    self[i](param1, ...);
                end
            end
        end
    end
  }

  --参数统一
 _G.app.update = setmetatable({},  metatab)

_G.app.render = setmetatable({},  metatab)

_G.app.mousepressed = setmetatable({}, metatab)

_G.app.mousemoved = setmetatable({}, metatab)

_G.app.load = setmetatable({},  metatab)

_G.app.mousereleased = setmetatable({},  metatab)

function love.mousereleased(x, y, button, isTouch)
    _G.UIHelper.mouseUp(x, y, button, isTouch)
    _G.app.mousereleased(x, y, button, isTouch)
end

function love.keypressed(key, scancode, isrepeat)
    if  _G.UIHelper.keyDown then
        _G.UIHelper.keyDown(key, scancode, isrepeat)
    end
    
    _G.CameraManager.keypressed(key)
end

function love.keyreleased(key)
    if _G.UIHelper.keyUp then
        _G.UIHelper.keyUp(key)
    end
end

function love.wheelmoved(x, y)
    if  _G.UIHelper.whellMove then
        _G.UIHelper.whellMove(x, y)
    end
    _G.CameraManager.wheelmoved(x, y);
    _G.LightManager.wheelmoved(x, y);
end

function love.textinput(text)
    if _G.UIHelper.textInput then
        _G.UIHelper.textInput(text)
    end
end

function love.update(dt)
    _G.UIHelper.update(dt);
    
    _G.CameraManager.update(dt)
    _G.LightManager.update(dt);
    _G.app.update(dt);
  end

function love.draw()
    -- _G.UIHelper.update(dt);
    -- _G.app.update(dt);
    if _G.LightManager.Need then
        _G.LightManager.draw(function()
            _G.CameraManager.begineDraw();
            _G.app.render();
            _G.CameraManager.endDraw();
        end);
    else
        _G.CameraManager.begineDraw();
        _G.app.render();
        _G.CameraManager.endDraw();
    end

    _G.UIHelper.draw()
    if _G.lovedebug.showstat then
    -- Stats
    local stats = love.graphics.getStats()
    love.graphics.print(tostring(love.timer.getFPS()) .. " FPS | " .. tostring(math.floor(love.timer.getDelta() * 100000) / 100) .. " ms", 10, 10)
    love.graphics.print("Draw calls: " .. tostring(stats.drawcalls), 10, 30)
    love.graphics.print("Canvas switches: " .. tostring(stats.canvasswitches), 10, 50)
    love.graphics.print("Texture memory: " .. tostring(stats.texturememory) .. " B", 10, 70)
    love.graphics.print("Images: " .. tostring(stats.images), 10, 90)
    love.graphics.print("Canvases: " .. tostring(stats.canvases), 10, 110)
    love.graphics.print("Fonts: " .. tostring(stats.fonts), 10, 130)
    end
end

function love.mousepressed(x, y, button, istouch)
    -- if button == 1 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
    --    printx = x
    --    printy = y
    -- end
    _G.UIHelper.mouseDown(x, y, button, isTouch)
    _G.app.mousepressed(x, y, button, istouch);
 end

 function love.mousemoved(x, y, dx, dy, istouch)
    -- if button == 1 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
    --    printx = x
    --    printy = y
    -- end

    _G.UIHelper.mousemoved(x, y, dx, dy);
    _G.CameraManager.mousemoved(x, y, dx, dy, istouch);
    _G.LightManager.mousemoved(x, y, dx, dy, istouch)
    _G.app.mousemoved(x, y, dx, dy, istouch);
 end

 function love.load()
    love.window.setMode( 1024,960 )
    _G.app.load();

    _G.LightManager.load();
 end