_G.LightNode = {}

local Light = LightNode

Light.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
Light.Canvae.renderWidth = 1
Light.Canvae.renderHeight = 1
Light.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
Light.Color = LColor.new(255, 255, 255,255)
Light.Near = 0.99
Light.Far = 1.0
Light.Execute = function(Canva1, ScreenDepth)
    if Light.Canvae.renderWidth ~= Canva1.renderWidth or Light.Canvae.renderHeight ~= Canva1.renderHeight then
        Light.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        Light.Canvae.renderWidth = Canva1.renderWidth 
        Light.Canvae.renderHeight = Canva1.renderHeight

        Light.meshquad = _G.MeshQuad.new(Canva1.renderWidth, Canva1.renderHeight, LColor.new(255, 255, 255, 255))
    end

    love.graphics.setCanvas(Light.Canvae.obj)
    love.graphics.clear()
    Light.meshquad:setCanvas(Canva1)
    Light.meshquad.shader = Shader.GePostProcessFogShader(normalmap, ScreenDepth, Light.Canvae.renderWidth , Light.Canvae.renderHeight)
    Light.meshquad:draw()
    love.graphics.setCanvas()
    return Light.Canvae
end