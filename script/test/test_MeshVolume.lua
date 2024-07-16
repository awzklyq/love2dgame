FileManager.addAllPath("assert")

local sphere = Mesh3D.new("SM_RailingStairs_Internal.OBJ") -- S_BuildingSetA_Tree_02  SM_RailingStairs_Internal

local BoxLines = sphere.box:buildMeshLines()
-- local BoxMesh = sphere.box:BuildRenderMesh()
local _Boxs = _G.MeshVolumNode.Process(sphere)

local _BoxsLines = {}
-- for i = 1, #_Boxs do
--     _BoxsLines[#_BoxsLines + 1] = _Boxs[i]:buildMeshLines()
-- end

for i = 1, #sphere.FacesInfosBVH do
    _BoxsLines[#_BoxsLines + 1] = sphere.FacesInfosBVH[i].Box:buildMeshLines()
end

local IsDrawBoxMesh = false
local IsDrawMesh = true
app.render(function(dt)
    if IsDrawMesh then
        sphere:draw()
    end

    if IsDrawBoxMesh then
        for i = 1, #_BoxsLines do
            _BoxsLines[i]:draw()
        end
    else
        BoxLines:draw()
    end
end)

currentCamera3D.eye = Vector3.new( 525.36051214316, 2852.3172223799, 1982.0588684058)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local checkb = UI.CheckBox.new( 0, 20, 20, 20, "IsDrawBoxMesh" )
checkb.IsSelect = IsDrawBoxMesh
checkb.ChangeEvent = function(Enable)
    IsDrawBoxMesh = Enable
end

local checkb = UI.CheckBox.new( 0, 50, 20, 20, "IsDrawMesh" )
checkb.IsSelect = IsDrawMesh
checkb.ChangeEvent = function(Enable)
    IsDrawMesh = Enable
end

local text = UI.Text.new( "Area", 0, 70, 60, 50 )
text.text = tostring(_Boxs.VolumPro)