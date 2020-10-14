local Camera = dofile 'script/render/camera.lua'

_G.CameraManager = {}
local camera = Camera()
camera:follow(200, 200)
function CameraManager.load()
end

function CameraManager.update(dt)
    mx, my = camera:toWorldCoords(love.mouse.getPosition())
    -- camera:update(dt)
end

function CameraManager.begineDraw()
    camera:attach()
end

function CameraManager.endDraw()
       -- Draw your game here
       camera:detach()
    --    camera:draw() -- Call this here if you're using camera:fade, camera:flash or debug drawing the deadzone
end

function CameraManager.wheelmoved(x, y)
    if y > 0 then
        camera.scale = camera.scale *0.8;
    elseif y < 0 then
        camera.scale = camera.scale *1.2;
    end 
end

function CameraManager.keypressed(key)
    -- if key == 'f' then
    --     camera:fade(1, {0, 0, 0, 1})
    -- end
    
    -- if key == 'g' then
    --     camera:fade(1, {0, 0, 0, 0})
    -- end
end

function CameraManager.mousemoved(x, y, dx, dy, istouch)
    -- if button == 1 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
    --    printx = x
    --    printy = y
    -- end

    if love.mouse.isDown(3) then
        camera.x = camera.x - dx;
        camera.y = camera.y - dy;
    end
 end