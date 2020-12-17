local vertices = {0, 50, 100, 180, 0, 180}


local mesh = Mesh.CreteMeshFormSimpleConcavePolygon(vertices, LColor.new(300, 100, 0, 255), LColor.new(0, 300, 0, 255), LColor.new(0, 100, 300, 255))

mesh.shader = Shader.GetBaseShader()
mesh.transform:scale(4, 4)
mesh.transform:moveTo(50, 50)

local settings = {type  = "2d", format="rgba16f", msaa=0,  mipmaps="none"}
local texturesize = 512
local downsamples = {}

local downsamplesize = texturesize / 4

local canvas = Canvas.new(texturesize, texturesize, settings)

app.render(function(dt)
    -- local mode, alphamode = love.graphics.getBlendMode( )
    -- _G.pushCanvas(canvas)
    mesh:draw()
    -- meshhelper:draw()
    -- _G.popCanvas()

  
end)