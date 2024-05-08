_G.FogNode = {}

local Fog = _G.FogNode
Fog.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
Fog.Canvae.renderWidth = 1
Fog.Canvae.renderHeight = 1
Fog.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
Fog.Color = LColor.new(255, 255, 255,255)
Fog.Near = 0.99
Fog.Far = 1.0
Fog.Execute = function(Canva1, ScreenDepth)
    if Fog.Canvae.renderWidth ~= Canva1.renderWidth or Fog.Canvae.renderHeight ~= Canva1.renderHeight then
        Fog.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        Fog.Canvae.renderWidth = Canva1.renderWidth 
        Fog.Canvae.renderHeight = Canva1.renderHeight

        Fog.meshquad = _G.MeshQuad.new(Canva1.renderWidth, Canva1.renderHeight, LColor.new(255, 255, 255, 255))
    end

    love.graphics.setCanvas(Fog.Canvae.obj)
    love.graphics.clear()
    Fog.meshquad:setCanvas(Canva1)
    Fog.meshquad.shader = Shader.GePostProcessFogShader(normalmap, ScreenDepth, Fog.Canvae.renderWidth , Fog.Canvae.renderHeight)
    Fog.meshquad:draw()
    love.graphics.setCanvas()
    return Fog.Canvae
end


function Shader.GePostProcessFogShader(normalmap, screendepthmap, sw, sh)
    if Shader["shader_GePostProcessFogShader"] then
        Shader["shader_GePostProcessFogShader"].setPostProcessFogValue(Shader["shader_GePostProcessFogShader"],  normalmap, screendepthmap)
        return Shader["shader_GePostProcessFogShader"]
    end
    local pixelcode = [[
    uniform sampler2D screendepthmap;
    uniform sampler2D normalmap;
   
    uniform float viewsizew;
    uniform float viewsizeh;
    uniform vec4 FogColor;
    uniform float FogNear;
    uniform float FogFar;
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
    Shader["shader_GePostProcessFogShader"] = shader;
    shader.setPostProcessFogValue = function (shader, normalmap, screendepthmap)
        shader:sendValue("screendepthmap", screendepthmap.obj)
        shader:sendValue("viewsizew", sw)
        shader:sendValue("viewsizeh", sh)
        shader:sendValue("viewsizeh", sh)
        shader:sendValue("FogColor", Fog.Color:GetShaderValue())
        shader:sendValue("FogNear", Fog.Near)
        shader:sendValue("FogFar", Fog.Far)
    end
    
    shader.setPostProcessFogValue(shader, normalmap, screendepthmap)
    return shader
end