FileManager.addAllPath("assert")

math.randomseed(os.time()%10000)

local aixs = Aixs.new(0,0,0, 150)
local directionlight = DirectionLight.new((currentCamera3D.eye - currentCamera3D.look):normalize(), LColor.new(255,255,255,255))
_G.useLight(directionlight)

local water = MeshWater.new(1000, 1000, 20)
water.amplitude = 200
water.kvalue = 1
water.speed = 0.5
water.invWaveLength = 30

water:setWaterMap('water.jpg')
-- water:setWaterNoiseMap('noise2.jpg')
water:setWaterNoiseMap('noise2.jpg')
app.render(function(dt)
    love.graphics.clear(0,0,0,1)
    aixs:draw()
    -- meshline:draw()
    water:draw()
end)

app.update(function(dt)
    water:update(dt)
end)

app.keypressed(function(key, scancode, 、)
    if key == "w" then
        log(currentCamera3D.eye.x,currentCamera3D.eye.y,currentCamera3D.eye.z)
        log(currentCamera3D.look.x,currentCamera3D.look.y,currentCamera3D.look.z)
    end
end)

currentCamera3D.eye = Vector3.new( 1, 436, 208)
currentCamera3D.look = Vector3.new( 0, 0, 0)