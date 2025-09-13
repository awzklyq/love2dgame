-- math.randomseed(os.time()%10000)
FileManager.addAllPath("assert")
local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local scene = Scene3D.new()
scene.IsDrawBox = true
scene.bgColor = LColor.new(0,0,0,255)

local cubenum = 1
local i = 3
local mesh3d = Mesh3D.new("suzanne.OBJ")
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


local _MeshDatas = Mesh3D.loadObjFile(_G.FileManager.findFile("suzanne.OBJ"))
local _VertPos = {}
local _Box = BoundBox.new()--AddVector3
for i = 1, #_MeshDatas do
    local _v = _MeshDatas[i]
    local _pos = Vector3.new(_v[1] , _v[2], _v[3])
    _VertPos[#_VertPos + 1] = _pos
end

local _Box = BoundBox.new()--AddVector3
for i = 1, #_VertPos do
    _Box:AddVector3(_VertPos[i])
end

local _Center = _Box:GetCenter()


local _NewPoss = {}
for i = 1, #_VertPos - 3, 3 do
    local _v1 = _VertPos[i]
    local _v2 = _VertPos[i + 1]
    local _v3 = _VertPos[i + 2]

    local _cv = (_v1 + _v2 + _v3) / 3

    _NewPoss[#_NewPoss + 1] = _v1
    _NewPoss[#_NewPoss + 1] = _v2
    _NewPoss[#_NewPoss + 1] = _cv

    _NewPoss[#_NewPoss + 1] = _v2
    _NewPoss[#_NewPoss + 1] = _v3
    _NewPoss[#_NewPoss + 1] = _cv

    _NewPoss[#_NewPoss + 1] = _v3
    _NewPoss[#_NewPoss + 1] = _v1
    _NewPoss[#_NewPoss + 1] = _cv
end


local _OriNormals = {}
for i = 1, #_NewPoss do
    local _v = _NewPoss[i]
    local _p = _v - _Center

    _OriNormals[i] = _p
end

local _H = Harmonics.new()
_H:GenerateMeshFlag(_NewPoss)

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

log('ttttttttttttt', #_Verts, _Verts[10][1], _Verts[10][2], _Verts[10][3])
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
