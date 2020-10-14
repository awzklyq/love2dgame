_G.wf = require 'windfield'
dofile('script/physics/boxobject.lua')
_G.box2dworld = wf.newWorld(0, 0, true)
_G.app.load(function()
    -- _G.world = wf.newWorld(0, 0, true)
    box2dworld:setGravity(0, 512)

    -- box = world:newRectangleCollider(400 - 50/2, 0, 50, 50)
    -- box:setRestitution(0.8)
    -- box:applyAngularImpulse(5000)

    -- ground = world:newRectangleCollider(0, 550, 800, 50)
    -- wall_left = world:newRectangleCollider(0, 0, 50, 600)
    -- wall_right = world:newRectangleCollider(750, 0, 50, 600)
    -- ground:setType('static') -- Types can be 'static', 'dynamic' or 'kinematic'. Defaults to 'dynamic'
    -- wall_left:setType('static')
    -- wall_right:setType('static')
    print('ttttttttttttttttttttt')
-- end)
end)

_G.app.update(function(dt)
    box2dworld:update(dt)
end)

_G.app.render(function(dt)
    if _G.lovedebug.renderbox2d then
        box2dworld:draw(dt)
    end
end)