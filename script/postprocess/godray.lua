local PixelFormat = "rgba8"
local PixelOffset = 2
_G.GodRayNode = {}
GodRayNode.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
GodRayNode.Canvae.renderWidth = 1
GodRayNode.Canvae.renderHeight = 1
GodRayNode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

GodRayNode.ClamptBrightness = 0.65

local BlurGodRay = {}
local GodRayAdd = {}
GodRayNode.Execute = function(Canva1, ScreenLightPos)
    if GodRayNode.Canvae.renderWidth ~= Canva1.renderWidth or GodRayNode.Canvae.renderHeight ~= Canva1.renderHeight then
        GodRayNode.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        GodRayNode.Canvae.renderWidth = Canva1.renderWidth 
        GodRayNode.Canvae.renderHeight = Canva1.renderHeight

        GodRayNode.meshquad = _G.MeshQuad.new(Canva1.renderWidth, Canva1.renderHeight, LColor.new(255, 255, 255, 255))
    end

    -- love.graphics.setCanvas(GodRayNode.Canvae.obj)
    -- love.graphics.clear()
    -- GodRayNode.meshquad:setCanvas(Canva1)
    -- GodRayNode.meshquad.shader = Shader.GetBrightnessShader2(GodRayNode.ClamptBrightness)
    -- GodRayNode.meshquad:draw()
    -- love.graphics.setCanvas()    

    -- local RenderCanvan = BlurGodRay.Execute(GodRayNode.Canvae, PixelOffset, 1, Canva1.renderWidth, Canva1.renderHeight, false)
    local scale = 1
    local RenderCanvan =  BlurGodRay.Execute(Canva1, PixelOffset, 1, Canva1.renderWidth * scale , Canva1.renderHeight * scale, ScreenLightPos, 48, 0.8, 0.3,  0.3,  1.0) --Canva1, offset, power, w, h, ScreenLightPos, NUM_SAMPLES, Density, Exposure, Decay, Weight

    RenderCanvan =  BlurGodRay.Execute(RenderCanvan, PixelOffset, 1, Canva1.renderWidth * scale, Canva1.renderHeight * scale, ScreenLightPos, 48, 1, 0.3,  0.3,  1.0)
    RenderCanvan =  BlurGodRay.Execute(RenderCanvan, PixelOffset, 1, Canva1.renderWidth * scale, Canva1.renderHeight * scale, ScreenLightPos, 48, 1.5, 0.3,  0.3,  1.0)
    RenderCanvan =  BlurGodRay.Execute(RenderCanvan, PixelOffset, 1, Canva1.renderWidth * scale, Canva1.renderHeight * scale, ScreenLightPos, 48, 2, 0.3,  0.3,  1.0)
    RenderCanvan =  BlurGodRay.Execute(RenderCanvan, PixelOffset, 1, Canva1.renderWidth * scale, Canva1.renderHeight * scale, ScreenLightPos, 48, 4, 0.3,  0.3,  1.0)
    -- RenderCanvan =  BlurGodRay.Execute(RenderCanvan, PixelOffset, 1, Canva1.renderWidth * scale, Canva1.renderHeight * scale, ScreenLightPos, 48, 8, 0.5,  0.3,  1.0)
   -- RenderCanvan =  BlurGodRay.Execute(RenderCanvan, PixelOffset, 1, Canva1.renderWidth * scale, Canva1.renderHeight * scale, ScreenLightPos, 48, 32, 0.5,  0.3,  1.0)
    -- RenderCanvan = GodRayAdd.Execute(Canva1, RenderCanvan, Canva1.renderWidth, Canva1.renderHeight)
    -- RenderCanvan.renderHeight = Canva1.renderHeight
    -- RenderCanvan.renderWidth = Canva1.renderWidth
    return RenderCanvan
end

BlurGodRay.Canvae1 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurGodRay.Canvae2 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurGodRay.Canvae = BlurGodRay.Canvae1
BlurGodRay.Canvae.renderWidth = 1
BlurGodRay.Canvae.renderHeight = 1
BlurGodRay.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
BlurGodRay.Execute = function(Canva1, offset, power, w, h, ScreenLightPos, NUM_SAMPLES, Density, Exposure, Decay, Weight)
    if BlurGodRay.Canvae == Canva1 then
        if BlurGodRay.Canvae1 == Canva1 then
            BlurGodRay.Canvae = BlurGodRay.Canvae2
        else
            BlurGodRay.Canvae = BlurGodRay.Canvae1
        end
    end

    if BlurGodRay.Canvae.renderWidth ~= w  or BlurGodRay.Canvae.renderHeight ~= h then
        BlurGodRay.Canvae = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BlurGodRay.Canvae.renderWidth = w
        BlurGodRay.Canvae.renderHeight = h

        BlurGodRay.meshquad = _G.MeshQuad.new(BlurGodRay.Canvae.renderWidth, BlurGodRay.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(BlurGodRay.Canvae.obj)
    love.graphics.clear()
    BlurGodRay.meshquad:setCanvas(Canva1)
    -- BlurGodRay.meshquad.shader = Shader.GetBlurGodRay(w, h, offset, power, NeedAdd)
    BlurGodRay.meshquad.shader = Shader.GetBlurGodRay(ScreenLightPos, NUM_SAMPLES, Density, Exposure, Decay, Weight)--ScreenLightPos, NUM_SAMPLES, Density, Exposure, Decay, Weight
    BlurGodRay.meshquad:draw()
    love.graphics.setCanvas()
    return BlurGodRay.Canvae
end

GodRayAdd.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
GodRayAdd.Canvae.renderWidth = 1
GodRayAdd.Canvae.renderHeight = 1
GodRayAdd.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
GodRayAdd.Execute = function(Canva1, img, w, h)
   
    if GodRayAdd.Canvae.renderWidth ~= w  or GodRayAdd.Canvae.renderHeight ~= h then
        GodRayAdd.Canvae = Canvas.new(w, h, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        GodRayAdd.Canvae.renderWidth = w
        GodRayAdd.Canvae.renderHeight = h

        GodRayAdd.meshquad = _G.MeshQuad.new(GodRayAdd.Canvae.renderWidth, GodRayAdd.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end

    love.graphics.setCanvas(GodRayAdd.Canvae.obj)
    love.graphics.clear()
    GodRayAdd.meshquad:setCanvas(Canva1)
    GodRayAdd.meshquad.shader = Shader.GetGodRayAdd(img)
    GodRayAdd.meshquad:draw()
    love.graphics.setCanvas()

    return GodRayAdd.Canvae

end


function Shader.GetBrightnessShader2(l)
    if not l then
        l = 0.001
    end

    if Shader['shader_GetBrightnessShader2']  then
        Shader['shader_GetBrightnessShader2']:sendValue('l', l);

        return Shader['shader_GetBrightnessShader2']
    end
    local pixelcode = 'uniform float l;\n'
    pixelcode = pixelcode .. _G.ShaderFunction.Luminance
    pixelcode = pixelcode .. [[
    varying vec2 vTexCoord2;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, vTexCoord2);
        vec4 basecolor = texcolor;
        float bl = clamp(Luminance(basecolor.xyz) - l, 0.0, 1.0) ;

        //if (bl == 0)
       // discard;
        return basecolor;

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
    --assert(shader:hasUniform( "l"))
    shader:sendValue('l', l);
    Shader['shader_GetBrightnessShader2'] = shader
    return shader
end


function Shader.GetBlurGodRay(ScreenLightPos, NUM_SAMPLES, Density, Exposure, Decay, Weight)

    if Shader['shader_GetBlurGodRay']  then
        Shader['shader_GetBlurGodRay']:sendValue('Density', Density);
        Shader['shader_GetBlurGodRay']:sendValue('Exposure', Exposure);
        Shader['shader_GetBlurGodRay']:sendValue('Decay', Decay); 
        Shader['shader_GetBlurGodRay']:sendValue('Weight', Weight); 
        Shader['shader_GetBlurGodRay']:sendValue('NUM_SAMPLES', NUM_SAMPLES); 
        Shader['shader_GetBlurGodRay']:sendValue('ScreenLightPos', ScreenLightPos); 
        -- Shader['shader_GetBlur2SSE']:send('baseimg', img.obj);
        return  Shader['shader_GetBlurGodRay']
    end
    local pixelcode = [[

    uniform float Density;
    uniform float Exposure;
    uniform float Decay;
    uniform float Weight;
    uniform int NUM_SAMPLES;
    uniform vec4 ScreenLightPos;

    varying vec2 vTexCoord2;

    vec2 ViewportUVToScreenPos(vec2 ViewportUV)
    {
        return vec2(2 * ViewportUV.x - 1, 1 - 2 * ViewportUV.y);
    }

    vec2 ScreenPosToViewportUV(vec2 ScreenPos)
    {
        return vec2(0.5 + 0.5 * ScreenPos.x, 0.5 - 0.5 * ScreenPos.y);
    }

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 texCoord = vTexCoord2;
        vec2 deltaTexCoord = (texCoord - ScreenPosToViewportUV(ScreenLightPos.xy));   // Divide by number of samples and scale by control factor.  
        deltaTexCoord *= 1.0 / NUM_SAMPLES * Density;   // Store initial sample.   
        vec3 outcolor = texture2D(tex, texCoord).xyz;   // Set up illumination decay factor.  
        float illuminationDecay = 1.0;   // Evaluate summation from Equation 3 NUM_SAMPLES iterations.  
        for (int i = 0; i < NUM_SAMPLES; i++)   
        {     
            // Step sample location along ray.    
            texCoord -= deltaTexCoord;     // Retrieve sample at new location.    
            vec3 sample = texture2D(tex, texCoord).xyz;     // Apply sample attenuation scale/decay factors.    
            sample *= illuminationDecay * Weight;     // Accumulate combined outcolor.    
            outcolor += sample;     // Update exponential decay factor.    
            illuminationDecay *= Decay; 
        }   
        // Output final outcolor with a further scale control factor.   
        
        return vec4( outcolor * Exposure, 1);
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

    --shader:send('power', power or 1);
    -- shader:send('baseimg',  img.obj);
    Shader['shader_GetBlurGodRay']= shader
    return shader
end


GodRayNode.Adapted_lum = 0.7
function Shader.GetGodRayAdd(img)

    if Shader['shader_GetGodRayAdd']  then
        Shader['shader_GetGodRayAdd']:send('img', img.obj);
        Shader['shader_GetGodRayAdd']:sendValue('Adapted_lum', GodRayNode.Adapted_lum);
        return Shader['shader_GetGodRayAdd']
    end

    -- pixelcode = pixelcode .. "uniform sampler2D baseimg;\n"
    local pixelcode = " uniform sampler2D img;  \n";
    pixelcode = pixelcode .. [[
    varying vec2 vTexCoord2;
    uniform float Adapted_lum;

    vec3 uncharted2_tonemap_partial(vec3 x)
    {
        float A = 0.15;
        float B = 0.50;
        float C = 0.10;
        float D = 0.20;
        float E = 0.02;
        float F = 0.30;
        return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
    }

    vec3 uncharted2_filmic(vec3 v)
    {
        float exposure_bias = 2.0;
        vec3 curr = uncharted2_tonemap_partial(v * exposure_bias);

        vec3 W = vec3(11.2);
        vec3 white_scale = vec3(1.0) / uncharted2_tonemap_partial(W);
        return curr * white_scale;
    }

    vec3 reinhard_extended(vec3 v, float max_white)
    {
        vec3 numerator = v * (1.0 + (v / vec3(max_white * max_white)));
        return numerator / (1.0 + v);
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
        vec4 texcolor = Texel(tex, vTexCoord2);
        
        vec4 imgcolor = Texel(img, vTexCoord2);


        vec4 ResultColor = (texcolor +  imgcolor ) * color;
        ResultColor.xyz = ACESToneMapping(ResultColor.xyz, Adapted_lum);
        float gamma = 2.2;
        ResultColor.rgb = pow(ResultColor.rgb, vec3(1.0/gamma));
       // float bl = 0.2126 * ResultColor.x + 0.7152 * ResultColor.y + 0.0722 * ResultColor.z;
         //if(bl > 1)
        {
            ResultColor.rgb = reinhard_extended(ResultColor.rgb, 1);
        }

        
        return ResultColor;

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
    shader:send('img', img.obj);
    -- shader:send('baseimg',  img.obj);
    Shader['shader_GetGodRayAdd'] = shader
    Shader['shader_GetGodRayAdd']:sendValue('Adapted_lum', GodRayNode.Adapted_lum);
    return shader
end
HDRSetting(function(IsHDR)
    if IsHDR then
        PixelFormat = "rgba16f"
    else
        PixelFormat = "rgba8"
    end
    GodRayNode.Canvae = Canvas.new(GodRayNode.Canvae.renderWidth, GodRayNode.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})

    Blur3Up.Canvae = Canvas.new(Blur3Up.Canvae.renderWidth, Blur3Up.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
    Blur3Down.Canvae = Canvas.new(Blur3Down.Canvae.renderWidth, Blur3Down.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
end)
