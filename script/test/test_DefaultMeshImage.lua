FileManager.addAllPath("assert")

local TestMesh = Mesh3D.new("SM_RailingStairs_Internal.OBJ")

local TestImageData = ImageDataEx.new(2, 1, 'rgba8')
TestImageData:SetPixel(0, 0, LColor.new(0,255,255,255))
TestImageData:SetPixel(1, 0, LColor.new(255,0,0,255))
local TestImage = TestImageData:GetImage()
TestMesh:SetImage(TestImage)

TestImage.renderWidth = 200
TestImage.renderHeight = 200

app.render(function(dt)
    -- TestMesh:draw()
    TestImage:draw()

end)

currentCamera3D.eye = Vector3.new( 525.36051214316, 2852.3172223799, 1982.0588684058)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)