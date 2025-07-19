FileManager.addAllPath("assert")

local mesh3d = Mesh3D.new("SM_RailingStairs_Internal.OBJ")
-- mesh3d:setNormalMap("T_Railing_N.TGA")
currentCamera3D.eye = Vector3.new( 195.88320929841 ,281.50478660121 ,-206.73155244685)
currentCamera3D.look = Vector3.new(-179.03673421501   ,     37.019015588789 ,-173.0665490595)
local aixs = Aixs.new(0,0,0, 300)
local _Box1 = BoundBox.buildFromMesh3D(mesh3d)
local _Box1Lines = _Box1:buildMeshLines()

local _OBB = CovarianceMatrix.BuildOBBFormMesh(mesh3d)
local _OBBLines = _OBB:buildMeshLines()
local IsRenderOBB = false
app.render(function(dt)
    RenderSet.UseCanvasColorAndDepth()

    mesh3d:draw()
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