local vertices = {0, 50, 100, 180, 0, 180}


local mesh = Mesh.CreteMeshFormSimpleConcavePolygon(vertices, LColor.new(300, 100, 0, 255), LColor.new(0, 300, 0, 255), LColor.new(0, 100, 300, 255))

mesh.shader = Shader.GetBaseShader()
mesh.transform:scale(4, 4)
mesh.transform:moveTo(20,2)

local settings = {type  = "2d", format="rgba8", msaa=0,  mipmaps="none"}
local downsamples = {}


local canvas = Canvas.new(love.graphics.getPixelWidth(), love.graphics.getPixelHeight(), settings)
local meshquad = _G.MeshQuad.new(love.graphics.getWidth(), love.graphics.getHeight(), LColor.new(255, 255, 255, 255), canvas)
meshquad.shader = Shader.GetFXAAShader(canvas:getWidth(), canvas:getHeight())
local str = "FXAA key: Space"
app.render(function(dt)
    
    _G.pushCanvas(canvas)
    mesh:draw()
    _G.popCanvas()
    meshquad:draw()
    love.graphics.print(str, 10, 20)
end)

local shaderindex = 0
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        shaderindex = shaderindex + 1
        if shaderindex % 2 == 0 then
            str = "FXAA key: Space"
            meshquad.shader = Shader.GetFXAAShader(canvas:getWidth(), canvas:getHeight())
        else
            str = "No FXAA key: Space"
            meshquad.shader = Shader.GetBaseShader()
        end
    end
end)
