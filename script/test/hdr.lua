local vertices = {0, 100, 200, 370, 0, 370}


local mesh = Mesh.CreteMeshFormSimpleConcavePolygon(vertices, LColor.new(300, 100, 0, 255), LColor.new(0, 300, 0, 255), LColor.new(0, 100, 300, 255))
local meshhelper = MeshQuad.new(50, 400, LColor.new(88, 88, 88, 255))
meshhelper.transform:moveTo(40, 10)
mesh.shader = Shader.GetBaseShader()
mesh.transform:moveTo(10, 10)

local settings = {type  = "2d", format="rgba16f", msaa=0,  mipmaps="none"}
local texturesize = 512
local downsamples = {}

local downsamplesize = texturesize / 4
while true do
    
    downsamples[#downsamples + 1] = {canvas = Canvas.new(downsamplesize, downsamplesize, settings), mesh = MeshQuad.new(downsamplesize, downsamplesize, LColor.new(0, 250, 0, 0))}
    if downsamplesize == 1 then
        break
    end

    downsamplesize = downsamplesize / 4
    if downsamplesize < 1 then
        downsamplesize = 1
    end
end
local canvas = Canvas.new(texturesize, texturesize, settings)
local canvasBrightness = Canvas.new(texturesize, texturesize, settings)
local canvasblurw = Canvas.new(texturesize / 4, texturesize / 4, settings)
local canvasblurh = Canvas.new(texturesize / 4, texturesize / 4, settings)
canvas.bgColor = LColor.new(0, 0, 0, 0)

canvasblurw.bgColor = LColor.new(0,0,0, 0)
canvasblurh.bgColor = LColor.new(0,0,0, 0)
canvasBrightness.bgColor = LColor.new(0, 0, 0, 0)
local meshquad = MeshQuad.new(texturesize, texturesize, LColor.new(250, 250, 250, 255))
-- meshquad.transform:moveTo(10, 10)

local meshblurw = MeshQuad.new(texturesize / 4, texturesize / 4, LColor.new(250, 250, 250, 255), canvasBrightness)
-- meshblurw.transform:moveTo(10, 10)
local meshblurh = MeshQuad.new(texturesize / 4, texturesize / 4, LColor.new(250, 250, 250, 255), canvasBrightness)
-- meshblurh.transform:moveTo(10, 10)

meshblurh.shader = Shader.GetHBlurShader(texturesize / 4, 1, 12, 0.4)
meshblurw.shader = Shader.GetWBlurShader(texturesize / 4,1, 12, 0.4)

local meshtest = MeshQuad.new(texturesize, texturesize, LColor.new(250, 250, 250, 255), canvasblurh)
meshtest.shader = Shader.GetBaseShader()

local meshBrightness = MeshQuad.new(texturesize, texturesize, LColor.new(250, 250, 250, 255), canvas)
meshBrightness.shader = Shader.GetBrightnessShader()

local meshhdr = MeshQuad.new(texturesize, texturesize, LColor.new(255, 255, 255, 0))
meshhdr.transform:moveTo(40, 10)
meshhdr.shader = Shader.GetAddTextureHDRShader(canvasblurw, canvasblurh)
meshhdr:setCanvas(canvasBrightness)
app.render(function(dt)
    local mode, alphamode = love.graphics.getBlendMode( )
    _G.pushCanvas(canvas)
    mesh:draw()
    -- meshhelper:draw()
    _G.popCanvas()

    -- downsamples[1].mesh:setTexture(canvas.obj)
    -- for i = 1, #downsamples - 1 do
    --     _G.pushCanvas(downsamples[i].canvas)
    --     downsamples[i].mesh:draw()
    --     _G.popCanvas()
    --     downsamples[i +1].mesh:setCanvas(downsamples[i].canvas)
    -- end

    -- _G.pushCanvas(downsamples[#downsamples].canvas)
    -- downsamples[#downsamples].mesh:draw()
    -- _G.popCanvas()

    -- local r, g, b, a = downsamples[#downsamples].canvas:getPixel( 0,0 )
    -- local color = LColor.new(r, g, b, a)
    -- color:getBrightness()

    meshBrightness.shader:send("l", 0.4)
    
    _G.pushCanvas(canvasBrightness)
    -- love.graphics.setBlendMode("add") 
    meshBrightness:draw()
    _G.popCanvas()

    _G.pushCanvas(canvasblurw)
    meshblurw:draw()
    love.graphics.setBlendMode(mode, alphamode) 
    _G.popCanvas()

    _G.pushCanvas(canvasblurh)
    meshblurh:draw()
    _G.popCanvas()

    -- meshblurw:draw()
   
    -- print(mode, alphamode)
    -- mesh:draw()
    -- meshhelper:draw()
    -- love.graphics.setBlendMode("add") 
    meshhdr:draw()
    -- meshblurh:draw()
    love.graphics.setBlendMode(mode, alphamode) 
end)