local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2

local plane = Mesh3D.new("assert/obj/plane.obj")
plane:setBaseColor(LColor.new(125,125,125, 255))
-- mesh3d:setTexture(love.graphics.newImage("assert/obj/earth.png"))
-- mesh3d.transform3d = Matrix3D.getTransformationMatrix(Vector3.new(0,0,-20), Vector3.new(), Vector3.new(1,1,1))
local cubes = {}
local cubenum = 20
for i = 1, cubenum do
    local mesh3d = Mesh3D.new("assert/obj/bbb.obj")
    mesh3d.transform3d:mulTranslationRight(math.random(-400, 400), math.random(-200, 200), math.random(-200, 200))
    mesh3d.transform3d:mulScalingLeft(0.5, 0.5, 0.5)
    mesh3d:setBaseColor(LColor.new(math.random(1, 255), math.random(1, 255), math.random(1, 255), 255))
    table.insert(cubes, mesh3d)
end

currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local lightdir =Vector3.new(0,-1,0) --Vector3.sub(currentCamera3D.look, currentCamera3D.eye)
local cubevolumes = {}
for i = 1, cubenum do
    local mesh3d = Shadow.buildShadowVolume(cubes[i], lightdir);
    mesh3d.transform3d = cubes[i].transform3d
    mesh3d.shader = Shader.GetBase3DShader()
    mesh3d:setBaseColor(LColor.new(0,0,0,0))
    table.insert(cubevolumes, mesh3d)
end

plane.transform3d:mulTranslationRight(0,-100,-100)
-- plane.transform3d:mulRotationLeft(0,1,0, 0.3)
-- plane.transform3d:mulScalingLeft(50,1,50)
plane.transform3d:mulScalingLeft(50,1,50)
local clearcolor = false

local baseshader = Shader.GetBase3DShader()
plane:setBaseColor(LColor.new(125, 125,125, 255))
local depth_buffer = Canvas.new(width, height, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})
local depth_buffer1 = Canvas.new(width, height, {format = "depth24", readable = true, msaa = 0, mipmaps="none"})	
local color_buffer = Canvas.new(width, height, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
local color_buffer1= Canvas.new(width, height, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
local function renderShadowVolumeFront()
    -- love.graphics.setCanvas({depthstencil = depth_front.obj})
    love.graphics.setMeshCullMode("front")
    love.graphics.setDepthMode("less", false)
    for i = 1, #cubevolumes do
        cubevolumes[i]:draw()
    end
    -- cubevolumes[1]:draw()
 end

local function renderShadowVolumeBack()
    -- love.graphics.setCanvas({depthstencil = depth_back.obj})
    love.graphics.setMeshCullMode("back")
    love.graphics.setDepthMode("less", false)
    for i = 1, #cubevolumes do
        cubevolumes[i]:draw()
    end

    -- cubevolumes[1]:draw()
end

local meshshader = Shader.GetBase3DShader();
local function renderMesh()

    love.graphics.setMeshCullMode("front")
    love.graphics.setDepthMode("less", true)
    for i = 1, #cubes do
        -- cubes[i].shader = baseshader
        cubes[i]:draw()
    end
    -- plane.shader = baseshader
    plane:draw()
end

local StencilRect = Rect.new(0, 0, width, height)
StencilRect.color = LColor.new(0,0,0,255)
local testrect = Rect.new(100, 100, 200, 200)
local renderselect = 1

local function renderShadowVolume()

    love.graphics.setCanvas({ color_buffer.obj, depthstencil = depth_buffer.obj})
    love.graphics.clear(1,1, 1, 1)
    love.graphics.setCanvas()

    love.graphics.setCanvas({ depthstencil = depth_buffer.obj})
    
    love.graphics.stencil(function()
        love.graphics.clear(1,1,1, 1)
        love.graphics.rectangle( "fill", -100, -100, 1200,800);
        
    end, "replace", 0, false)

    renderMesh()
    love.graphics.setCanvas()
    love.graphics.setCanvas({ depthstencil = depth_buffer.obj})
    love.graphics.stencil(renderShadowVolumeFront, "increment",1, true)--increment

    love.graphics.stencil(renderShadowVolumeBack, "increment", 1, true)


    love.graphics.setCanvas()
    
    love.graphics.setCanvas({color_buffer.obj, depthstencil = depth_buffer.obj})
    love.graphics.setStencilTest("equal",1)
    StencilRect:draw()

    love.graphics.setStencilTest()
    love.graphics.setCanvas()
end


local meshquad = MeshQuad.new(width, height, LColor.new(255, 255, 255, 255))
meshquad:setCanvas(color_buffer1)
meshquad:setBaseTexture(color_buffer)
app.render(function(dt)

    if clearcolor then
        love.graphics.clear(0.5,0.5,0.5)
    end
    
    renderShadowVolume()

    meshquad:draw()

end)

local shaderindex = 0
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        -- log('eye: ',currentCamera3D.eye.x, currentCamera3D.eye.y, currentCamera3D.eye.z)
        -- log('look: ',currentCamera3D.look.x, currentCamera3D.look.y, currentCamera3D.look.z)

        love.graphics.setCanvas({color_buffer1.obj, depthstencil = depth_buffer1.obj})
        love.graphics.clear(0,0, 0, 0)
        renderMesh()
        love.graphics.setCanvas()
   
    end

    -- if key == "up" then
    --     plane.transform3d:mulTranslationRight(0,-10,0)
    -- end

    -- if key == "down" then
    --     plane.transform3d:mulTranslationRight(0,0,-10)
    -- end
end)
-- currentCamera3D.eye = Vector3.new(21.196894461553, -47.361568301866, 39.713239351847)
-- currentCamera3D.look = Vector3.new(22.558604721495, -61.107337559643, 5.2498110475302)


-- struct Edge
-- {
--     _dword	mEnd1;
--     _dword	mEnd2;
--     _dword	mDisableCount;
--     _float	mValue;

--     inline Edge( )
--         : mEnd1( (_dword) -1 ), mEnd2( (_dword) -1 ), mDisableCount( 0 ), mValue( 0.0f ) { }
--     inline Edge( _dword v1, _dword v2, _float distance )
--         : mEnd1( v1 ), mEnd2( v2 ), mDisableCount( 0 ), mValue( distance ) { }
-- };

-- class Edge
-- {
-- public:
-- 	// Index of face1.
-- 	_dword	f1;
-- 	// Index of face2.
-- 	_dword	f2;
-- 	// Index of edge in face1 ( 0/1/2 ).
-- 	_dword	e1;
-- 	// Index of edge in face2 ( 0/1/2 ).
-- 	_dword	e2;
-- 	// Index of vertex1.
-- 	_dword	v1;
-- 	// Index of vertex2.
-- 	_dword	v2;
-- };
