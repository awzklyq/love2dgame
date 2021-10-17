FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)

local plane = Mesh3D.new("plane.obj")
plane:setBaseColor(LColor.new(125,125,125, 255))

local mesh3d = Mesh3D.new("bbb.OBJ")
local mesh3d_2 = Mesh3D.new("bbb.OBJ")
currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local image = ImageEx.new("T_FloorMarble_D.TGA") 
-- mesh3d:setTexture(image.obj)
mesh3d:setBaseColor(LColor.new(255, 0, 255, 180))
mesh3d_2:setBaseColor(LColor.new(255, 255, 0, 120))
mesh3d_2.transform3d:mulTranslationRight(40, 0, 0)

local scene = Scene3D.new()
scene.bgColor = LColor.new(125,125,125)
local MeshNode = scene:addMesh(mesh3d)
local MeshNode_2 = scene:addMesh(mesh3d_2)
local PlaneNode = scene:addMesh(plane)

MeshNode.AlphaTest = true
MeshNode_2.AlphaTest = true
app.render(function(dt)
    scene:update(dt)
    scene:draw(true)

    love.graphics.print( "Press Key A.  RenderSet.AlphaTestMode: "..tostring(RenderSet.AlphaTestMode), 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        MeshNode.AlphaTest = not MeshNode.AlphaTest
        MeshNode_2.AlphaTest = not MeshNode_2.AlphaTest
    end

    if key == "up" then
        RenderSet.AlphaTestBlend = RenderSet.AlphaTestBlend + 0.1

    elseif key == "down" then
        RenderSet.AlphaTestBlend = RenderSet.AlphaTestBlend - 0.1
    elseif key == "a" then
        RenderSet.AlphaTestMode = 3 - RenderSet.AlphaTestMode
    end

    RenderSet.AlphaTestBlend = math.clamp(RenderSet.AlphaTestBlend, 0, 1)
end)
