-- math.randomseed(os.time()%10000)
FileManager.addAllPath("assert")

local width = love.graphics.getPixelWidth() 
local height = love.graphics.getPixelHeight()

local meshobj = Mesh3D.new("SM_RailingStairs_Internal.obj")
meshobj:setBaseColor(LColor.new(125,125,125, 255))


currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

meshobj.transform3d:mulTranslationRight(0,-100,-100)
meshobj.transform3d:mulScalingLeft(5,5,5)

local verts = meshobj:GetPositions()
local vertsAABB = {}
assert(#verts % 3 == 0)

for i = 1, #verts - 1, 3 do
    local aabb = BoundBox.new()
    aabb = aabb + verts[i]
    aabb = aabb + verts[i +1]
    aabb = aabb + verts[i + 2]
    vertsAABB[#vertsAABB + 1] =  meshobj.transform3d:mulBoundBox(aabb)
    
end
local Results = SpaceSplit.GenerateBatches(vertsAABB, 64, 2)
local DrawBoxs = {}


log('aaaa', #Results)

for i = 1, #Results do
    log("bbbbbb", #Results[i])
    local ab = BoundBox.new()
    for j = 1, #Results[i] do
        ab = ab + Results[i][j]
    end

    local ss = ab.max - ab.min
    log('ssssssss', ss.x, ss.y, ss.z)
    DrawBoxs[#DrawBoxs +1] = ab:buildMeshLines()
    DrawBoxs[#DrawBoxs]:setBGColor(LColor.new(math.random(80,255), math.random(80,255), math.random(80,255), 255))
end
local aixs = Aixs.new(0,-100,-100, 500)
local CanvasColor = Canvas.new(love.graphics.getPixelWidth(), love.graphics.getPixelHeight(), {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})


local GeneratDrawData = function()

end



-- local mab = meshobj.transform3d:mulBoundBox(BoundBox.buildFromMesh3D(meshobj))
-- local mm = mab:buildMeshLines()
app.render(function(dt)
    RenderSet.UseCanvasColorAndDepth()
    
    aixs:draw()

    meshobj:draw()

    for i = 1, #DrawBoxs do
        DrawBoxs[i]:draw()
    end

    -- boxlines:draw()
    -- mm:draw()
    RenderSet.ClearCanvasColorAndDepth()

    RenderSet.getCanvasColor():draw()
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        -- log('eye: ',currentCamera3D.eye.x, currentCamera3D.eye.y, currentCamera3D.eye.z)
    end
end)