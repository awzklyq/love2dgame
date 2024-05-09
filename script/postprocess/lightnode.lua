_G.LightNode = {}

local Light = LightNode

Light.Canvae1 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
Light.Canvae1.renderWidth = 1
Light.Canvae1.renderHeight = 1

-- Light.Canvae2 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
-- Light.Canvae2.renderWidth = 1
-- Light.Canvae2.renderHeight = 1

Light.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

local SwitchCanvaes = function()
    local TempCanvae = Light.Canvae1
    Light.Canvae1 = Light.Canvae2
    Light.Canvae2 = TempCanvae

end

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
    local ResultCanvae = Canva1
    local TargetCanvae = Light.Canvae1
    local PointLights = Lights.GetPointLights()
    if #PointLights > 0 then
       
        for i = 1, #PointLights do
            love.graphics.setCanvas(Light.Canvae1.obj)
            love.graphics.clear()
            Light.meshquad:setCanvas(Light.Canvae2)
            Light.meshquad.shader = Shader.GePostProcessPointLightShader(ScreenDepth, Normalmap, PointLights[i])
            Light.meshquad:draw()
            love.graphics.setCanvas()
            
            -- SwitchCanvaes()
        end

        ResultCanvae = Light.Canvae1
    end

    -- Light.Canvae1 = TargetCanvae
    return ResultCanvae
end


function Shader.GePostProcessPointLightShader(screendepthmap, Normalmap, PointLightObj)
    if Shader["shader_GePostProcessPointLightShader"] then
        Shader["shader_GePostProcessPointLightShader"].setPostProcessPointLightValue(Shader["shader_GePostProcessPointLightShader"],  screendepthmap, Normalmap, PointLightObj)
        return Shader["shader_GePostProcessPointLightShader"]
    end
    local pixelcode = [[
    uniform sampler2D screendepthmap;
    uniform sampler2D normalmap;

    uniform mat4 Inverse_ProjectviewMatrix;
    uniform vec3 LightPostion;
    uniform vec4 LightColor;
    uniform float LightPower;
    uniform float LightDistance;
    uniform vec3 CameraEye;
    ]]

    pixelcode = pixelcode .. _G.ShaderFunction.ScreenAndViewPortFunc 
    pixelcode = pixelcode .. _G.ShaderFunction.LightFunc

    pixelcode = pixelcode .. [[

    float DistanceVector3(vec3 p1, vec3 p2)
    {
        return length(p1 - p2);
    }

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
       float depth = texture2D(screendepthmap, texture_coords).r;
       
       vec2 uv = ViewportUVToScreenPos(texture_coords);
       vec4 vpos = vec4(uv.x, uv.y, depth, 1.0);

       vec4 spos = Inverse_ProjectviewMatrix * vpos; // Only Inverse_Projectview..
       spos /= spos.w;

       vec4 basecolor = texture2D(tex, texture_coords);

       vec3 LightDir = normalize(spos.xyz - LightPostion.xyz);

       vec4 normal = texture2D(normalmap, texture_coords);
       normal = normalize(normal * 2.0 - vec4(1.0, 1.0, 1.0, 1.0));

       vec3 ViewDir = normalize(spos.xyz - CameraEye.xyz);

       vec3 LightDiffuseColor = LightDiffuseColor(LightColor.xyz, LightDir.xyz, normal.xyz) * 0.5;

       vec3 LightSpecularColor = LightSpecularColorPhong(LightColor.xyz, LightDir.xyz, normal.xyz, ViewDir) * 0.5;

       float DistanceFormFragToLight = distance(spos.xyz, LightPostion.xyz);
       
       float LightPowerByDisntance = max(0.0, 1.0 - DistanceFormFragToLight / LightDistance) * LightPower;


       basecolor.xyz *= (LightDiffuseColor + LightSpecularColor) * LightPowerByDisntance;
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
    shader.setPostProcessPointLightValue = function (shader, screendepthmap, Normalmap, PointLightObj)
        shader:sendValue("screendepthmap", screendepthmap.obj)
        shader:sendValue("normalmap", Normalmap.obj)

        local camera3d = _G.getGlobalCamera3D()
        shader:sendValue("CameraEye", camera3d.eye:GetShaderValue())

        local viewm = RenderSet.getUseViewMatrix()
        local projectm = RenderSet.getUseProjectMatrix()

        if shader:hasUniform("Inverse_ProjectviewMatrix") then
            local mat = Matrix3D.copy(projectm);
            mat:mulRight(viewm)--Todo..
            shader:send("Inverse_ProjectviewMatrix",  Matrix3D.inverse(mat))
        end

        shader:sendValue("LightPostion", PointLightObj.Position:GetShaderValue())
        shader:sendValue("LightColor", PointLightObj.Color:GetShaderValue())
        shader:sendValue("LightPower", PointLightObj.Power)
        shader:sendValue("LightDistance", PointLightObj.Distance)

    end
    
    shader.setPostProcessPointLightValue(shader, screendepthmap, Normalmap, PointLightObj)
    return shader
end