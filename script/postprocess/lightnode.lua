_G.LightNode = {}

local Light = LightNode

Light.Canvae1 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
Light.Canvae1.renderWidth = 1
Light.Canvae1.renderHeight = 1

-- Light.Canvae2 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
-- Light.Canvae2.renderWidth = 1
-- Light.Canvae2.renderHeight = 1

Light.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
Light.Color = LColor.new(255, 255, 255,255)
Light.Near = 0.99
Light.Far = 1.0
Light.Execute = function(Canva1, ScreenDepth, Normalmap)
    if Light.Canvae1.renderWidth ~= Canva1.renderWidth or Light.Canvae1.renderHeight ~= Canva1.renderHeight then
        Light.Canvae1 = Canvas.new(Canva1.renderWidth , Canva1.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        Light.Canvae1.renderWidth = Canva1.renderWidth 
        Light.Canvae1.renderHeight = Canva1.renderHeight

        -- Light.Canvae2 = Canvas.new(Canva1.renderWidth , Canva1.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        -- Light.Canvae2.renderWidth = Canva1.renderWidth 
        -- Light.Canvae2.renderHeight = Canva1.renderHeight

        Light.meshquad = _G.MeshQuad.new(Canva1.renderWidth, Canva1.renderHeight, LColor.new(255, 255, 255, 255))
    end

    Light.Canvae2 = Canva1
    love.graphics.setCanvas(Light.Canvae1.obj)
    love.graphics.clear()
    Light.meshquad:setCanvas(Light.Canvae2)
    Light.meshquad.shader = Shader.GePostProcessPointLightShader(normalmap, ScreenDepth, Normalmap)
    Light.meshquad:draw()
    love.graphics.setCanvas()
    return Light.Canvae1
end


function Shader.GePostProcessPointLightShader(normalmap, screendepthmap, Normalmap)
    if Shader["shader_GePostProcessPointLightShader"] then
        Shader["shader_GePostProcessPointLightShader"].setPostProcessPointLightValue(Shader["shader_GePostProcessPointLightShader"],  normalmap, screendepthmap, Normalmap)
        return Shader["shader_GePostProcessPointLightShader"]
    end
    local pixelcode = [[
    uniform sampler2D screendepthmap;
    uniform sampler2D normalmap;
   
    float rand(vec2 co)
    {
        return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
    }   

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
       float depth = texture2D(screendepthmap, texture_coords).r;
       
       vec4 basecolor = texture2D(tex, texture_coords);

       float MixV = clamp((depth - FogNear) / (FogFar - FogNear), 0.0, 1.0);
       basecolor.xyz = mix(basecolor.xyz, FogColor.xyz, MixV);
       return basecolor;
    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]

-- log(vertexcode)
-- log(pixelcode)
    local shader =   Shader.new(pixelcode, vertexcode)
    Shader["shader_GePostProcessPointLightShader"] = shader;
    shader.setPostProcessPointLightValue = function (shader, normalmap, screendepthmap, Normalmap)
        shader:sendValue("screendepthmap", screendepthmap.obj)
        shader:sendValue("normalmap", Normalmap.obj)
    end
    
    shader.setPostProcessFogValue(shader, normalmap, screendepthmap)
    return shader
end