-- math.randomseed(os.time()%10000)

local width = love.graphics.getPixelWidth() 
local height = love.graphics.getPixelHeight()

local sphere = Mesh3D.new("assert/obj/bbb.obj")
sphere:setBaseColor(LColor.new(125,125,125, 255))
-- mesh3d:setTexture(love.graphics.newImage("assert/obj/earth.png"))
-- mesh3d.transform3d = Matrix3D.getTransformationMatrix(Vector3.new(0,0,-20), Vector3.new(), Vector3.new(1,1,1))

currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

sphere.transform3d:mulTranslationRight(0,-100,-100)
sphere.transform3d:mulScalingLeft(5,5,5)

local triangles = {}
local GenTriangles = function(w, h)
    triangles = {}
    local v1 = Triangle2D.new(Vector.new(0,0), Vector.new(w * 0.5, 0), Vector.new(0, h * 0.5))
    v1:SetColor(255,0,0,255)
    triangles[#triangles + 1] = v1
    v1.mode = 'fill'

    local v2 = Triangle2D.new(Vector.new(0, h * 0.5), Vector.new(w * 0.5, 0), Vector.new(w * 0.5, h * 0.5))
    v2:SetColor(255,255,0,255)
    triangles[#triangles + 1] = v2
    v2.mode = 'fill'

    v1 = Triangle2D.new(Vector.new(w * 0.5, 0), Vector.new(w, 0), Vector.new(w, h * 0.5))
    v1:SetColor(180,180,255,255)
    triangles[#triangles + 1] = v1
    v1.mode = 'fill'

    v2 = Triangle2D.new(Vector.new(w * 0.5, 0), Vector.new(w * 0.5, h * 0.5), Vector.new(w, h * 0.5))
    v2:SetColor(255,0,255,255)
    triangles[#triangles + 1] = v2
    v2.mode = 'fill'

    v1 = Triangle2D.new(Vector.new(0, h * 0.5), Vector.new(w * 0.5, h * 0.5), Vector.new(w * 0.5, h))
    v1:SetColor(0,255,0,255)
    triangles[#triangles + 1] = v1
    v1.mode = 'fill'

    v2 = Triangle2D.new(Vector.new(0, h * 0.5), Vector.new(0, h), Vector.new(w* 0.5, h))
    v2:SetColor(0,0,255,255)
    triangles[#triangles + 1] = v2
    v2.mode = 'fill'

    v1 = Triangle2D.new(Vector.new(w * 0.5, h * 0.5), Vector.new(w, h * 0.5), Vector.new(w * 0.5, h))
    v1:SetColor(0,255,255,255)
    triangles[#triangles + 1] = v1
    v1.mode = 'fill'

    v2 = Triangle2D.new(Vector.new(w * 0.5, h), Vector.new(w, h), Vector.new(w, h * 0.5))
    v2:SetColor(135,78,111,255)
    triangles[#triangles + 1] = v2
    v2.mode = 'fill'
end

GenTriangles(width, height)
local aixs = Aixs.new(0,-100,-100, 500)
local CanvasColor = Canvas.new(love.graphics.getPixelWidth(), love.graphics.getPixelHeight(), {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
app.render(function(dt)
    love.graphics.setCanvas(CanvasColor.obj)
    love.graphics.clear(0,0,0,0)
    for i, v in ipairs(triangles) do
        v:draw()
    end
    love.graphics.setCanvas()

    -- CanvasColor:draw()
    RenderSet.UseCanvasColorAndDepth()

    aixs:draw()
    sphere:setCanvas(CanvasColor)
    sphere.shader = Shader.GetOctahedralMapShader(sphere.transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix())
    -- sphere:draw()
    Render.RenderObject(sphere)

    RenderSet.ClearCanvasColorAndDepth()

    RenderSet.getCanvasColor():draw()
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        -- log('eye: ',currentCamera3D.eye.x, currentCamera3D.eye.y, currentCamera3D.eye.z)
    end
end)

app.resizeWindow(function(w, h)
    GenTriangles(w, h)
    CanvasColor = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
end)
