math.randomseed(os.time()%10000)

local width = love.graphics.getPixelWidth() 
local height = love.graphics.getPixelHeight()  

local Canvae = Canvas.new(width, height, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
Canvae.renderWidth = width
Canvae.renderHeight = height

local Canvae2 = Canvas.new(width, height, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
Canvae2.renderWidth = width
Canvae2.renderHeight = height

local meshquad = _G.MeshQuad.new(width, height, LColor.new(255, 255, 255, 255))
local image = ImageEx.new("shtest.png")
meshquad:setCanvas(image)
-- scene.needSSAO = true
app.render(function(dt)
    love.graphics.setCanvas(Canvae.obj)
    love.graphics.clear()
    meshquad:setCanvas(image)
    meshquad.shader = Shader.GetBaseImageShader()
    meshquad:draw()
    meshquad:flush()
    love.graphics.setCanvas()    

    love.graphics.setCanvas(Canvae2.obj)
    love.graphics.clear()
    meshquad:setCanvas(Canvae)
    meshquad.shader = Shader.GetBaseImageShader()
    meshquad:draw()
    meshquad:flush()
    love.graphics.setCanvas()   

    Canvae2:draw()
end)

