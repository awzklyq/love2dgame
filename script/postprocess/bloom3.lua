local PixelFormat = "rgba8"
local PixelOffset = 2
_G.Bloom3 = {}
Bloom3.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
Bloom3.Canvae.renderWidth = 1
Bloom3.Canvae.renderHeight = 1
Bloom3.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

Bloom3.ClamptBrightness = 0.65
Bloom3.Execute = function(Canva1, InMeshQuad)
    if Bloom3.Canvae.renderWidth ~= Canva1.renderWidth or Bloom3.Canvae.renderHeight ~= Canva1.renderHeight then
        Bloom3.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        Bloom3.Canvae.renderWidth = Canva1.renderWidth 
        Bloom3.Canvae.renderHeight = Canva1.renderHeight

        Bloom3.meshquad = _G.MeshQuad.new(Canva1.renderWidth, Canva1.renderHeight, LColor.new(255, 255, 255, 255))
    end

    love.graphics.setCanvas(Bloom3.Canvae.obj)
    love.graphics.clear()
    Bloom3.meshquad:setCanvas(Canva1)
    Bloom3.meshquad.shader = Shader.GetBrightnessShader2(Bloom3.ClamptBrightness)
    Bloom3.meshquad:draw()
    love.graphics.setCanvas()    

    local RenderCanvan = Blur3Down.Execute(Bloom3.Canvae, PixelOffset, 1, Canva1.renderWidth / 2, Canva1.renderHeight / 2, false)
    RenderCanvan = Blur3Down.Execute(RenderCanvan, PixelOffset, 1, Canva1.renderWidth / 4, Canva1.renderHeight / 4, false)
    RenderCanvan = Blur3Down.Execute(RenderCanvan, PixelOffset, 1, Canva1.renderWidth / 8, Canva1.renderHeight / 8, false)
    RenderCanvan = Blur3Down.Execute(RenderCanvan, PixelOffset, 1, Canva1.renderWidth / 16, Canva1.renderHeight / 16, false)
    RenderCanvan = Blur3Up.Execute(RenderCanvan, PixelOffset, 1, Canva1.renderWidth / 8, Canva1.renderHeight / 8)
    RenderCanvan = Blur3Up.Execute(RenderCanvan, PixelOffset, 1, Canva1.renderWidth / 4, Canva1.renderHeight / 4)
    RenderCanvan = Blur3Up.Execute(RenderCanvan, PixelOffset, 1, Canva1.renderWidth / 2, Canva1.renderHeight / 2)
    RenderCanvan = Bloom3Add.Execute(Canva1, RenderCanvan, Canva1.renderWidth, Canva1.renderHeight)
    RenderCanvan.renderHeight = Canva1.renderHeight
    RenderCanvan.renderWidth = Canva1.renderWidth
    return RenderCanvan
end

_G.Blur3Down = {}
Blur3Down.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
Blur3Down.Canvae.renderWidth = 1
Blur3Down.Canvae.renderHeight = 1
Blur3Down.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
Blur3Down.Execute = function(Canva1, offset, power, w, h, NeedAdd)
   
    if Blur3Down.Canvae.renderWidth ~= w  or Blur3Down.Canvae.renderHeight ~= h then
        Blur3Down.Canvae = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        Blur3Down.Canvae.renderWidth = w
        Blur3Down.Canvae.renderHeight = h

        Blur3Down.meshquad = _G.MeshQuad.new(Blur3Down.Canvae.renderWidth, Blur3Down.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(Blur3Down.Canvae.obj)
    love.graphics.clear()
    Blur3Down.meshquad:setCanvas(Canva1)
    Blur3Down.meshquad.shader = Shader.GetBlur3Down(w, h, offset, power, NeedAdd)
    Blur3Down.meshquad:draw()
    love.graphics.setCanvas()
    return Blur3Down.Canvae
end

_G.Blur3Up = {}
Blur3Up.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
Blur3Up.Canvae.renderWidth = 1
Blur3Up.Canvae.renderHeight = 1
Blur3Up.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
Blur3Up.Execute = function(Canva1, offset, power, w, h)
   
    if Blur3Up.Canvae.renderWidth ~= w  or Blur3Up.Canvae.renderHeight ~= h then
        Blur3Up.Canvae = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        Blur3Up.Canvae.renderWidth = w
        Blur3Up.Canvae.renderHeight = h

        Blur3Up.meshquad = _G.MeshQuad.new(Blur3Up.Canvae.renderWidth, Blur3Up.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(Blur3Up.Canvae.obj)
    love.graphics.clear()
    Blur3Up.meshquad:setCanvas(Canva1)
    Blur3Up.meshquad.shader = Shader.GetBlur3Down(w, h, offset, power)
    Blur3Up.meshquad:draw()
    love.graphics.setCanvas()
    return Blur3Up.Canvae
end

_G.Bloom3Add = {}
Bloom3Add.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
Bloom3Add.Canvae.renderWidth = 1
Bloom3Add.Canvae.renderHeight = 1
Bloom3Add.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
Bloom3Add.Execute = function(Canva1, img, w, h)
   
    if Bloom3Add.Canvae.renderWidth ~= w  or Bloom3Add.Canvae.renderHeight ~= h then
        Bloom3Add.Canvae = Canvas.new(w, h, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        Bloom3Add.Canvae.renderWidth = w
        Bloom3Add.Canvae.renderHeight = h

        Bloom3Add.meshquad = _G.MeshQuad.new(Bloom3Add.Canvae.renderWidth, Bloom3Add.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end

    love.graphics.setCanvas(Bloom3Add.Canvae.obj)
    love.graphics.clear()
    Bloom3Add.meshquad:setCanvas(Canva1)
    Bloom3Add.meshquad.shader = Shader.GetBloom3Add(img)
    Bloom3Add.meshquad:draw()
    love.graphics.setCanvas()

    return Bloom3Add.Canvae

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


function Shader.GetBlur3Down(w, h, offset, power, NeedAdd)

    if Shader['shader_GetBlur3Down' .. tostring(NeedAdd)]  then
        Shader['shader_GetBlur3Down'.. tostring(NeedAdd)]:send('w', w);
        Shader['shader_GetBlur3Down'.. tostring(NeedAdd)]:send('h', h);
        Shader['shader_GetBlur3Down'.. tostring(NeedAdd)]:send('offset', offset or 1);
        Shader['shader_GetBlur3Down'.. tostring(NeedAdd)]:send('offset', offset or 1);
       -- Shader['shader_GetBlur3Down']:send('power', power or 1);
        -- Shader['shader_GetBlur2SSE']:send('baseimg', img.obj);
        return  Shader['shader_GetBlur3Down']
    end
    local pixelcode = 'uniform float w;\n'
    pixelcode = pixelcode .. 'uniform float h;\n'
    pixelcode = pixelcode .. 'uniform float offset;\n'
    --pixelcode = pixelcode .. 'uniform float power;\n'
    -- pixelcode = pixelcode .. "uniform sampler2D baseimg;\n"

    pixelcode = pixelcode .. [[
    varying vec2 vTexCoord2;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 halfpixel = vec2(offset / w, offset / h);
        halfpixel *= 0.5;

        vec4 BaseColor =  texture2D(tex, vTexCoord2);
        vec4 sum = BaseColor * 4.0;
        sum += texture2D(tex, vTexCoord2 - halfpixel.xy);
        sum += texture2D(tex, vTexCoord2 + halfpixel.xy);
        sum += texture2D(tex, vTexCoord2 + vec2(halfpixel.x, -halfpixel.y));
        sum += texture2D(tex, vTexCoord2 - vec2(halfpixel.x, -halfpixel.y));
        ]]
        if NeedAdd then
            pixelcode = pixelcode .. [[
                return vec4(BaseColor.xyz + sum.xyz / 8.0, BaseColor.a);
        }
            ]]
        else
            pixelcode = pixelcode .. [[
                return vec4(sum.xyz / 8.0, BaseColor.a);
        }
            ]]
        end

    local vertexcode = [[
    varying vec2 vTexCoord2;
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        vTexCoord2 =  VertexTexCoord.xy;
        return transform_projection * vertex_position;
    }
]]

    local shader =   Shader.new(pixelcode, vertexcode)
    shader:send('w', w);
    shader:send('h', h);
    shader:send('offset', offset or 1);
    --shader:send('power', power or 1);
    -- shader:send('baseimg',  img.obj);
    Shader['shader_GetBlur3Down'.. tostring(NeedAdd)] = shader
    return shader
end


function Shader.GetBlur3Up(w, h, offset, power)

    if Shader['shader_GetBlur3Up']  then
        Shader['shader_GetBlur3Up']:send('w', w);
        Shader['shader_GetBlur3Up']:send('h', h);
        Shader['shader_GetBlur3Up']:send('offset', offset or 1);
      --  Shader['shader_GetBlur3Up']:send('power', power or 1);
        -- Shader['shader_GetBlur2SSE']:send('baseimg', img.obj);
        return  Shader['shader_GetBlur3Up']
    end
    local pixelcode = 'uniform float w;\n'
    pixelcode = pixelcode .. 'uniform float h;\n'
    pixelcode = pixelcode .. 'uniform float offset;\n'
   -- pixelcode = pixelcode .. 'uniform float power;\n'
    -- pixelcode = pixelcode .. "uniform sampler2D baseimg;\n"

    pixelcode = pixelcode .. _G.ShaderFunction.Luminance
    pixelcode = pixelcode .. [[
    varying vec2 vTexCoord2;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 halfpixel = vec2(offset / w, offset / h);
        halfpixel *= 0.5;
        vec4 BaseColor =  texture2D(tex, vTexCoord2);
        vec4 sum = texture2D(tex, vTexCoord2 + vec2(-halfpixel.x * 2.0, 0.0));
        sum += texture2D(tex, vTexCoord2 + vec2(-halfpixel.x, halfpixel.y)) * 2.0;
        sum += texture2D(tex, vTexCoord2 + vec2(0.0, halfpixel.y * 2.0));
        sum += texture2D(tex, vTexCoord2 + vec2(halfpixel.x, halfpixel.y)) * 2.0;
        sum += texture2D(tex, vTexCoord2 + vec2(halfpixel.x * 2.0, 0.0));
        sum += texture2D(tex, vTexCoord2 + vec2(halfpixel.x, -halfpixel.y)) * 2.0;
        sum += texture2D(tex, vTexCoord2 + vec2(0.0, -halfpixel.y * 2.0));
        sum += texture2D(tex, vTexCoord2 + vec2(-halfpixel.x, -halfpixel.y)) * 2.0;
        return vec4(BaseColor.xyz + sum.xyz / 12.0, BaseColor.a) ;
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
    shader:send('w', w);
    shader:send('h', h);
    shader:send('offset', offset or 1);
   -- shader:send('power', power or 1);
    -- shader:send('baseimg',  img.obj);
    Shader['shader_GetBlur3Up'] = shader
    return shader
end

Bloom3.Adapted_lum = 0.7
function Shader.GetBloom3Add(img)

    if Shader['shader_GetBloom3Add']  then
        Shader['shader_GetBloom3Add']:send('img', img.obj);
        Shader['shader_GetBloom3Add']:sendValue('Adapted_lum', Bloom3.Adapted_lum);
        return Shader['shader_GetBloom3Add']
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
    Shader['shader_GetBloom3Add'] = shader
    Shader['shader_GetBloom3Add']:sendValue('Adapted_lum', Bloom3.Adapted_lum);
    return shader
end
HDRSetting(function(IsHDR)
    if IsHDR then
        PixelFormat = "rgba16f"
    else
        PixelFormat = "rgba8"
    end
    Bloom3.Canvae = Canvas.new(Bloom3.Canvae.renderWidth, Bloom3.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})

    Blur3Up.Canvae = Canvas.new(Blur3Up.Canvae.renderWidth, Blur3Up.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
    Blur3Down.Canvae = Canvas.new(Blur3Down.Canvae.renderWidth, Blur3Down.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
end)
