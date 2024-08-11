FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)
local mesh3d = Mesh3D.new("SM_RailingStairs_Internal.OBJ")
-- mesh3d:setNormalMap("T_Railing_N.TGA")
currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local imagenames = {'T_Railing_M.TGA', "T_FloorMarble_D.TGA"}

local index = 2
mesh3d:setCanvas(ImageEx.new(imagenames[index]) )


app.render(function(dt)
    mesh3d:draw()
end)


currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)