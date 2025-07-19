-- math.randomseed(os.time()%10000)

local Points = {}

local Len = 30
local _Number = 10
local BasePoint = Point3D.new(1, 1, 1)
for i = 1, _Number do
    Points[#Points + 1] = BasePoint * Point3D.new(math.random((i-1) * Len,i * Len), math.random((i-1) * Len,i * Len), math.random((i-1) * Len,i * Len))
end

local _Box1 = BoundBox.buildFromPoints(Points)
local _Box1Lines = _Box1:buildMeshLines()

local _OBB = CovarianceMatrix.BuildOBBFromPoints(Points)
local _OBBLines = _OBB:buildMeshLines()
local IsRenderOBB = false

local aixs = Aixs.new(0,0,0, 300)
app.render(function(dt)
    RenderSet.UseCanvasColorAndDepth()
    for i = 1, _Number do
        Points[i]:draw()
    end
    if IsRenderOBB == false then
        _Box1Lines:draw()
    else
        _OBBLines:draw()
    end
    aixs:draw()
    RenderSet.ClearCanvasColorAndDepth()
    RenderSet.getCanvasColor():draw()
end)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "IsRenderOBB" )
checkb.IsSelect = IsRenderOBB
checkb.ChangeEvent = function(Enable)
    IsRenderOBB = Enable
end


currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)