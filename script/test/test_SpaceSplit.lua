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

SpaceSplit.TypeBySurface = 1
SpaceSplit.TypeByAix = 2

SpaceSplit.Type = SpaceSplit.TypeBySurface

local Results = SpaceSplit.GenerateBatches(vertsAABB, 512, 4)
local DrawBoxsBySurface = {}


for i = 1, #Results do
    local ab = BoundBox.new()
    for j = 1, #Results[i] do
        ab = ab + Results[i][j]
    end

    local ss = ab.max - ab.min
    DrawBoxsBySurface[#DrawBoxsBySurface +1] = ab:buildMeshLines()
    DrawBoxsBySurface[#DrawBoxsBySurface]:setBGColor(LColor.new(math.random(80,255), math.random(80,255), math.random(80,255), 255))
end


SpaceSplit.Type = SpaceSplit.TypeByAix

Results = SpaceSplit.GenerateBatches(vertsAABB, 512, 4)
local DrawBoxsByAix = {}


for i = 1, #Results do
    local ab = BoundBox.new()
    for j = 1, #Results[i] do
        ab = ab + Results[i][j]
    end

    local ss = ab.max - ab.min
    DrawBoxsByAix[#DrawBoxsByAix +1] = ab:buildMeshLines()
    DrawBoxsByAix[#DrawBoxsByAix]:setBGColor(LColor.new(math.random(80,255), math.random(80,255), math.random(80,255), 255))
end

SpaceSplit.Type = SpaceSplit.TypeByHalf

Results = SpaceSplit.GenerateBatches(vertsAABB, 512, 4)
local DrawBoxsByAixHalf = {}


for i = 1, #Results do
    local ab = BoundBox.new()
    for j = 1, #Results[i] do
        ab = ab + Results[i][j]
    end

    local ss = ab.max - ab.min
    DrawBoxsByAixHalf[#DrawBoxsByAixHalf +1] = ab:buildMeshLines()
    DrawBoxsByAixHalf[#DrawBoxsByAixHalf]:setBGColor(LColor.new(math.random(80,255), math.random(80,255), math.random(80,255), 255))
end

local aixs = Aixs.new(0,-100,-100, 500)
local CanvasColor = Canvas.new(love.graphics.getPixelWidth(), love.graphics.getPixelHeight(), {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})

local DrawType = 0

-- local mab = meshobj.transform3d:mulBoundBox(BoundBox.buildFromMesh3D(meshobj))
-- local mm = mab:buildMeshLines()
app.render(function(dt)
    RenderSet.UseCanvasColorAndDepth()
    
    aixs:draw()

    meshobj:draw()

    if DrawType == 0 then
        for i = 1, #DrawBoxsBySurface do
            DrawBoxsBySurface[i]:draw()
        end
    elseif DrawType == 1 then
        for i = 1, #DrawBoxsByAix do
            DrawBoxsByAix[i]:draw()
        end
    else
        for i = 1, #DrawBoxsByAixHalf do
            DrawBoxsByAixHalf[i]:draw()
        end
    end

    love.graphics.print( " DrawType: "..  tostring(DrawType), 10, 10)
    -- boxlines:draw()
    -- mm:draw()
    RenderSet.ClearCanvasColorAndDepth()

    RenderSet.getCanvasColor():draw()
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        DrawType = (DrawType + 1) % 3
    end
end)