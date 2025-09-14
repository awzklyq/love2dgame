-- math.randomseed(os.time()%10000)
FileManager.addAllPath("assert")
local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local scene = Scene3D.new()
scene.IsDrawBox = true
scene.bgColor = LColor.new(0,0,0,255)

local cubenum = 1
local i = 3
local SphereData = Mesh3D.CreateSphereData(126, 126, 30)
local mesh3d = Mesh3D.new("suzanne.OBJ", true)
mesh3d.transform3d:mulTranslationRight(0, 0, 0)
local scale = 3--math.random(0.5, 2)
mesh3d.transform3d:mulScalingLeft(scale ,scale, scale)
mesh3d:setBaseColor(LColor.new(math.random() * 255, math.random() * 255, math.random() * 255, 255))

currentCamera3D.eye = Vector3.new( 50, 50, 0)
currentCamera3D.look = Vector3.new( 0 , 0, 0)
currentCamera3D.up = Vector3.new(0,0, -1)
local directionlight = DirectionLight.new((currentCamera3D.eye - currentCamera3D.look ):normalize(), LColor.new(255,255,255,255))


local IsRenderOri = true

local scene = Scene3D.new()
local lightnode = scene:addLight(directionlight)
lightnode.needshadow = true

local _OriNormals = {}

local _SphereData = Mesh3D.CreateSphereData(128, 128)
for i = 1, #_SphereData do
    local _v = Vector3.new(_SphereData[i][1], _SphereData[i][2], _SphereData[i][3])
    _OriNormals[i] = _v
end

local _H = Harmonics.new()
-- _H:GenerateMeshFlag(_NewPoss)
_H:GenerateSH5FromMesh(mesh3d)

local _NewPoss = _H:ReStrutMeshInfo(_OriNormals)

local _Verts = {}
for i = 1, #_NewPoss do
    local _v = {}
    _v[1] = _NewPoss[i].x
    _v[2] = _NewPoss[i].y
    _v[3] = _NewPoss[i].z

    _v[4] = 0
    _v[5] = 0

    _v[6] = 0
    _v[7] = 0
    _v[8] = 1

    _Verts[i] = _v
end

-- log('ttttttttttttt', #_Verts, _Verts[10][1], _Verts[10][2], _Verts[10][3])
local TempMesh = Mesh3D.createFromPoints(_Verts)
TempMesh.transform3d:mulTranslationRight(0, 0, 0)
-- local scale = 3--math.random(0.5, 2)
TempMesh.transform3d:mulScalingLeft(scale * 2 ,scale * 2, scale * 2)
TempMesh:setBaseColor(LColor.new(math.random() * 255, math.random() * 255, math.random() * 255, 255))

-- local node = scene:addMesh(mesh3d)
local node = scene:addMesh(TempMesh)
node.shadowCaster = true

scene.needGTAO = true

app.render(function(dt)
    scene:update(dt)
    scene:drawDirectionLightCSM()
    scene:draw(true)
end)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "IsRenderOri" )
checkb.IsSelect = IsRenderOri
checkb.ChangeEvent = function(Enable)
    IsRenderOri = Enable
end
