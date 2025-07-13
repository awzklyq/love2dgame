-- math.randomseed(os.time()%10000)

local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local scene = Scene3D.new()
scene.IsDrawBox = true
scene.bgColor = LColor.new(0,0,0,255)

local i = 3
local mesh3d = Mesh3D.new("assert/obj/taiyang/Sphere.OBJ")
mesh3d.transform3d:mulTranslationRight(-3000 + 500 * i, -3000 + 500 * i, 800)
local scale = 3--math.random(0.5, 2)
mesh3d.transform3d:mulScalingLeft(scale ,scale, scale)
mesh3d:setBaseColor(LColor.new(math.random() * 255, math.random() * 255, math.random() * 255, 255))

currentCamera3D.eye = Vector3.new( 525.36051214316, 2852.3172223799, 1982.0588684058)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local _MeshBox = BoundBox.buildFromMesh3D(mesh3d)
local _TestMeshLines = _MeshBox:buildMeshLines(mesh3d.transform3d)

 CovarianceMatrix.BuildCovarianceMatrix(mesh3d)

local IsRenderOri = true
app.render(function(dt)
    RenderSet.UseCanvasColorAndDepth()
    if IsRenderOri then
        mesh3d:draw()
    end
   
    _TestMeshLines:draw()
    RenderSet.ClearCanvasColorAndDepth()
    RenderSet.getCanvasColor():draw()
end)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "IsRenderOri" )
checkb.IsSelect = IsRenderOri
checkb.ChangeEvent = function(Enable)
    IsRenderOri = Enable
end
