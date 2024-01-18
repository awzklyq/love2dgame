-- math.randomseed(os.time()%10000)

local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local scene = Scene3D.new()
scene.IsDrawBox = true
scene.bgColor = LColor.new(0,0,0,255)

local cubenum = 1
local i = 3
local mesh3d = Mesh3D.new("assert/obj/taiyang/Sphere.OBJ")
mesh3d.transform3d:mulTranslationRight(-3000 + 500 * i, -3000 + 500 * i, 800)
local scale = 3--math.random(0.5, 2)
mesh3d.transform3d:mulScalingLeft(scale ,scale, scale)
mesh3d:setBaseColor(LColor.new(math.random() * 255, math.random() * 255, math.random() * 255, 255))

--Copy Mesh
local FacesInfos = mesh3d.FacesInfos
local verts = {}
for i = 1, #FacesInfos do
    local tri = FacesInfos[i].Triangle

    local P1 = mesh3d.transform3d *tri.P1
    verts[#verts + 1] = {P1.x, P1.y, P1.z, 0, 0, 0, 0, 1}

    local P2 = mesh3d.transform3d *tri.P2
    verts[#verts + 1] = {P2.x, P2.y, P2.z, 0, 0, 0, 0, 1}

    local P3 = mesh3d.transform3d *tri.P3
    verts[#verts + 1] = {P3.x, P3.y, P3.z, 0, 0, 0, 0, 1}
end

local testmesh = Mesh3D.createFromPoints(verts)
-- testmesh.transform3d = Matrix3D.copy(mesh3d.transform3d)
testmesh:setBaseColor(LColor.new( 255, 0, 255, 255))

currentCamera3D.eye = Vector3.new( 525.36051214316, 2852.3172223799, 1982.0588684058)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local directionlight = DirectionLight.new((currentCamera3D.eye - currentCamera3D.look ):normalize(), LColor.new(255,255,255,255))


local IsRenderOri = true
app.render(function(dt)
    if IsRenderOri then
        mesh3d:draw()
    else
        testmesh:draw()
    end
   
end)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "IsRenderOri" )
checkb.IsSelect = IsRenderOri
checkb.ChangeEvent = function(Enable)
    IsRenderOri = Enable
end
