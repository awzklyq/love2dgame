local Boxs = {}

local StartV = Vector3.new(-1000, -1000, -1000)

local EndV = Vector3.new(1000 , 1000, 1000)

local VoxelSize = Vector3.new(20,30, 30)
local S = Vector3.new(0, 0, 0)

local Dir = Vector3.new(-1, -1, 1)

local Results = DDARayTrace.GetTest3DResult(StartV, EndV, S, Dir, VoxelSize)

for i = 1, #Results do
    local r = Results[i]
    local bmin = r * VoxelSize
    local bmax = bmin + VoxelSize
    -- log('aaaaaaa', bmin.x, bmin.y, bmin.z)
    -- log('bbbbbbb', bmax.x, bmax.y, bmax.z)
    -- log()
    local b = BoundBox.buildFromMinMax(bmin, bmax )
    Boxs[#Boxs + 1] = b:buildMeshLines()

    -- if i == 1 then
    --     rect:setColor(255,0,0,255)
    -- elseif i == #Results then
    --     rect:setColor(0,255,0,255)
    -- end
end

app.render(function(dt)
   for i = 1, #Boxs do
        Boxs[i]:draw()
   end

end)

currentCamera3D.eye = Vector3.new( 1031.6052951947, 1128.4332003128, 1080.5516115369)
currentCamera3D.look = Vector3.new( 907.54906142122 ,-221.74197357722 , 216.09289892418)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        log('eye: ',currentCamera3D.eye.x, currentCamera3D.eye.y, currentCamera3D.eye.z)
        log('look: ',currentCamera3D.look.x, currentCamera3D.look.y, currentCamera3D.look.z)
    end

end)
