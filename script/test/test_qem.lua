FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)

RenderSet.BGColor = LColor.new(120,120,120,255)

local mesh3d = Mesh3D.new("SM_Statue.OBJ")
-- mesh3d:setNormalMap("T_Railing_N.TGA")
currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)
currentCamera3D.up = Vector3.new(0,-1,0)

local imagenames = {'T_Railing_M.TGA', "T_FloorMarble_D.TGA"}
local TestMesh1 = _G.QEM.Process(mesh3d)
local TestMesh2 = _G.QEM.Process(TestMesh1)
local TestMesh3 = _G.QEM.Process(TestMesh2)
local index = 2
mesh3d:setCanvas(ImageEx.new(imagenames[index]) )
local QEMDraw = 0
app.render(function(dt)
    -- RenderSet.UseCanvasColorAndDepth()
    if QEMDraw == 1 then
        TestMesh1:draw()
    elseif QEMDraw == 2 then
        TestMesh2:draw()
    elseif QEMDraw == 3 then
        TestMesh3:draw()
    else
        mesh3d:draw()
    end
    -- RenderSet.ClearCanvasColorAndDepth()
    -- RenderSet.getCanvasColor():draw()
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        QEMDraw = (QEMDraw + 1) % 4 
    elseif key == 'a' then
        love.graphics.setWireframe( true )
    elseif key == 'z' then
        love.graphics.setWireframe( false )
    end
end)
