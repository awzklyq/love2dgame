local Camera = dofile 'script/render/camera.lua'

_G.CameraManager = {}
local camera = Camera()
camera:follow(200, 200)
function CameraManager.load()
end

function CameraManager.update(dt)
    if _G.lovedebug.useCamera == false then return end
    mx, my = camera:toWorldCoords(love.mouse.getPosition())
    camera:update(dt)

    -- local group = _G.GroupManager.currentgroup
    -- if group and group.levelres then
    --     local body = group.levelres:findBodyByName("asd")
    --     if body then
    --         local pos = body.transform:getPosition()
    --         camera:follow(pos.x, pos.y)
    --     end
    -- end

    local me = _G.getMe()
    if me then
        local pos = me:getPosition()
        camera:follow(pos.x, pos.y)
    end
end

function CameraManager.begineDraw()
    if _G.lovedebug.useCamera == false then return end
    camera:attach()
end

function CameraManager.endDraw()
    if _G.lovedebug.useCamera == false then return end
       -- Draw your game here
       camera:detach()
    --    camera:draw() -- Call this here if you're using camera:fade, camera:flash or debug drawing the deadzone
end

function CameraManager.wheelmoved(x, y)
    if _G.lovedebug.useCamera == false then return end
    if y > 0 then
        camera.scale = camera.scale *0.8;
    elseif y < 0 then
        camera.scale = camera.scale *1.2;
    end 
end

function CameraManager.keypressed(key)
    if _G.lovedebug.useCamera == false then return end
    -- if key == 'f' then
    --     camera:fade(1, {0, 0, 0, 1})
    -- end
    
    -- if key == 'g' then
    --     camera:fade(1, {0, 0, 0, 0})
    -- end
end

function CameraManager.mousemoved(x, y, dx, dy, istouch)
    if _G.lovedebug.useCamera == false then return end
    -- if button == 1 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
    --    printx = x
    --    printy = y
    -- end

    if love.mouse.isDown(3) then
        camera.x = camera.x - dx;
        camera.y = camera.y - dy;
    end
 end