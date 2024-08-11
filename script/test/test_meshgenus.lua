
FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)


local mesh3d = Mesh3D.new("SM_ACA10017_005.OBJ")
-- mesh3d:setNormalMap("T_Railing_N.TGA")
currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local G = MeshGenusGenerateNode.Process(mesh3d)

app.render(function(dt)
    mesh3d:draw()
end)

local text = UI.Text.new( "Mesh Genus", 10, 10, 100, 50 )
text.text = "Mesh Genus: " .. tostring(G)
