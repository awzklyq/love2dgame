local PixelFormat = "rgba8"

_G.ToneMapping = {}
ToneMapping.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
ToneMapping.Canvae.renderWidth = 1
ToneMapping.Canvae.renderHeight = 1
ToneMapping.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

ToneMapping.Execute = function(Canva1)
   
    if ToneMapping.Canvae.renderWidth ~= Canva1.renderWidth  or ToneMapping.Canvae.renderHeight ~= Canva1.renderHeight then
        ToneMapping.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        ToneMapping.Canvae.renderWidth = Canva1.renderWidth
        ToneMapping.Canvae.renderHeight = Canva1.renderHeight

        ToneMapping.meshquad = _G.MeshQuad.new(ToneMapping.Canvae.renderWidth, ToneMapping.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(ToneMapping.Canvae.obj)
    love.graphics.clear()
    ToneMapping.meshquad:setCanvas(Canva1)
    ToneMapping.meshquad.shader = Shader.GetToneMappingShader()
    ToneMapping.meshquad:draw()
    love.graphics.setCanvas()
    return ToneMapping.Canvae
end

ToneMapping.Adapted_lum = 0.7
function Shader.GetToneMappingShader()

    if Shader['shader_GetToneMappingShader']  then
        Shader['shader_GetToneMappingShader']:send("Adapted_lum", ToneMapping.Adapted_lum)
        return Shader['shader_GetToneMappingShader']
    end

    local pixelcode = [[
    varying vec2 vTexCoord2;
    uniform float Adapted_lum;
    vec3 ReinhardToneMapping(vec3 color, float adapted_lum) 
    {
        const float MIDDLE_GREY = 1;
        color *= MIDDLE_GREY / adapted_lum;
        return color / (1.0f + color);
    }

    vec3 CEToneMapping(vec3 color, float adapted_lum) 
    {
        return 1 - exp(-adapted_lum * color);
    }

    vec3 FF(vec3 x)
    {
        const float A = 0.22f;
        const float B = 0.30f;
        const float C = 0.10f;
        const float D = 0.20f;
        const float E = 0.01f;
        const float F = 0.30f;
    
        return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
    }

    vec3 Uncharted2ToneMapping(vec3 color, float adapted_lum)
    {
        vec3 WHITE= vec3(11.2);
        return FF(1.6f * adapted_lum * color) / FF(WHITE);
    }

    vec3 ACESToneMapping(vec3 color, float adapted_lum)
    {
        const float A = 2.51f;
        const float B = 0.03f;
        const float C = 2.43f;
        const float D = 0.59f;
        const float E = 0.14f;

        color *= adapted_lum;
        return (color * (A * color + B)) / (color * (C * color + D) + E);
    }

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {

	
        vec4 sceneColor = texture2D(tex, vTexCoord2);
	

		vec3 finalColor = ACESToneMapping(sceneColor.xyz, Adapted_lum);
		return vec4(finalColor, sceneColor.a);

    }
]]

    local vertexcode = [[
    varying vec2 vTexCoord2;
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        vTexCoord2 =  VertexTexCoord.xy;
        return transform_projection * vertex_position;
    }
]]

    local shader =   Shader.new(pixelcode, vertexcode)
    Shader['shader_GetToneMappingShader'] = shader
    Shader['shader_GetToneMappingShader']:send("Adapted_lum", ToneMapping.Adapted_lum)
    return shader
end

HDRSetting(function(IsHDR)
    if IsHDR then
        PixelFormat = "rgba16f"
    else
        PixelFormat = "rgba8"
    end
    ToneMapping.Canvae = Canvas.new(ToneMapping.Canvae.renderWidth , ToneMapping.Canvae.renderWidth, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})

    -- BlurHSE.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
    -- BlurWSE.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
    -- BlurWHSE.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
    -- BlurCircle.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
    -- BloomAdd.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
end)

