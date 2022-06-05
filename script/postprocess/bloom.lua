local PixelFormat = "rgba8"

_G.Bloom = {}
Bloom.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
Bloom.Canvae.renderWidth = 1
Bloom.Canvae.renderHeight = 1
Bloom.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

Bloom.ClamptBrightness = 0.65
Bloom.Execute = function(Canva1, InMeshQuad)
    if Bloom.Canvae.renderWidth ~= Canva1.renderWidth or Bloom.Canvae.renderHeight ~= Canva1.renderHeight then
        Bloom.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        Bloom.Canvae.renderWidth = Canva1.renderWidth 
        Bloom.Canvae.renderHeight = Canva1.renderHeight

        Bloom.meshquad = _G.MeshQuad.new(Canva1.renderWidth, Canva1.renderHeight, LColor.new(255, 255, 255, 255))
    end

    love.graphics.setCanvas(Bloom.Canvae.obj)
    love.graphics.clear()
    Bloom.meshquad:setCanvas(Canva1)
    Bloom.meshquad.shader = Shader.GetBrightnessShader(Bloom.ClamptBrightness)
    Bloom.meshquad:draw()
    love.graphics.setCanvas()    

    local RenderCanvan = BlurHSE.Execute(Bloom.Canvae, 1, 2, Canva1.renderWidth / 8 , Canva1.renderHeight / 8 )
    -- RenderCanvan = BlurCircle.Execute(Bloom.Canvae)
    RenderCanvan = BlurWSE.Execute(RenderCanvan, 1, 2, Canva1.renderWidth / 8, Canva1.renderHeight / 8)
    RenderCanvan = BlurHSE.Execute(RenderCanvan, 1, 1, Canva1.renderWidth / 16, Canva1.renderHeight / 16)
    RenderCanvan = BlurWSE.Execute(RenderCanvan, 1, 1, Canva1.renderWidth / 16, Canva1.renderHeight / 16)
    RenderCanvan = BlurHSE.Execute(RenderCanvan, 1, 1, Canva1.renderWidth / 8, Canva1.renderHeight / 8)
    RenderCanvan = BlurWSE.Execute(RenderCanvan, 1, 1, Canva1.renderWidth / 8, Canva1.renderHeight / 8)
	-- RenderCanvan = BlurWHSE.Execute(RenderCanvan, 2, Canva1.renderWidth , Canva1.renderHeight )
    RenderCanvan = BloomAdd.Execute(Canva1, RenderCanvan, Canva1.renderWidth, Canva1.renderHeight)
    RenderCanvan.renderHeight = Canva1.renderHeight
    RenderCanvan.renderWidth = Canva1.renderWidth
    return RenderCanvan
end

_G.BlurHSE = {}
BlurHSE.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurHSE.Canvae.renderWidth = 1
BlurHSE.Canvae.renderHeight = 1
BlurHSE.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
BlurHSE.Execute = function(Canva1, offset, power, w, h)
   
    if BlurHSE.Canvae.renderWidth ~= w  or BlurHSE.Canvae.renderHeight ~= h then
        BlurHSE.Canvae = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BlurHSE.Canvae.renderWidth = w
        BlurHSE.Canvae.renderHeight = h

        BlurHSE.meshquad = _G.MeshQuad.new(BlurHSE.Canvae.renderWidth, BlurHSE.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(BlurHSE.Canvae.obj)
    love.graphics.clear()
    BlurHSE.meshquad:setCanvas(Canva1)
    BlurHSE.meshquad.shader = Shader.GetBlurHSE(BlurHSE.Canvae.renderWidth, offset, power)
    BlurHSE.meshquad:draw()
    love.graphics.setCanvas()
    return BlurHSE.Canvae

end

_G.BlurWSE = {}
BlurWSE.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurWSE.Canvae.renderWidth = 1
BlurWSE.Canvae.renderHeight = 1
BlurWSE.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
BlurWSE.Execute = function(Canva1, offset, power, w, h)
   
    if BlurWSE.Canvae.renderWidth ~= w   or BlurWSE.Canvae.renderHeight ~= h  then
        BlurWSE.Canvae = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BlurWSE.Canvae.renderWidth = w
        BlurWSE.Canvae.renderHeight = h

        BlurWSE.meshquad = _G.MeshQuad.new(BlurWSE.Canvae.renderWidth, BlurWSE.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end

    love.graphics.setCanvas(BlurWSE.Canvae.obj)
    love.graphics.clear()
    BlurWSE.meshquad:setCanvas(Canva1)
    BlurWSE.meshquad.shader = Shader.GetBlurWSE(BlurWSE.Canvae.renderHeight, offset, power)
    BlurWSE.meshquad:draw()
    love.graphics.setCanvas()

    return BlurWSE.Canvae

end

_G.BlurWHSE = {}
BlurWHSE.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurWHSE.Canvae.renderWidth = 1
BlurWHSE.Canvae.renderHeight = 1
BlurWHSE.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
BlurWHSE.Execute = function(Canva1, offset, power, w, h)
   
    if BlurWHSE.Canvae.renderWidth ~= w   or BlurWHSE.Canvae.renderHeight ~= h  then
        BlurWHSE.Canvae = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BlurWHSE.Canvae.renderWidth = w
        BlurWHSE.Canvae.renderHeight = h

        BlurWHSE.meshquad = _G.MeshQuad.new(BlurWHSE.Canvae.renderWidth, BlurWHSE.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end

    love.graphics.setCanvas(BlurWHSE.Canvae.obj)
    love.graphics.clear()
    BlurWHSE.meshquad:setCanvas(Canva1)
    BlurWHSE.meshquad.shader = Shader.GetBlurWHSE(BlurWHSE.Canvae.renderWidth, BlurWHSE.Canvae.renderHeight, offset, power)
    BlurWHSE.meshquad:draw()
    love.graphics.setCanvas()

    return BlurWHSE.Canvae

end

_G.BlurCircle = {}
BlurCircle.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurCircle.Canvae.renderWidth = 1
BlurCircle.Canvae.renderHeight = 1
BlurCircle.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
BlurCircle.Execute = function(Canva1)
   
    if BlurCircle.Canvae.renderWidth ~= Canva1.renderWidth   or BlurCircle.Canvae.renderHeight ~= Canva1.renderHeight  then
        BlurCircle.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BlurCircle.Canvae.renderWidth = Canva1.renderWidth 
        BlurCircle.Canvae.renderHeight = Canva1.renderHeight 

        BlurCircle.meshquad = _G.MeshQuad.new(BlurCircle.Canvae.renderWidth, BlurCircle.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end

    love.graphics.setCanvas(BlurCircle.Canvae.obj)
    love.graphics.clear()
    BlurCircle.meshquad:setCanvas(Canva1)
    BlurCircle.meshquad.shader = Shader.GetBlurCircle()
    BlurCircle.meshquad:draw()
    love.graphics.setCanvas()

    return BlurCircle.Canvae

end

_G.BloomAdd = {}
BloomAdd.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BloomAdd.Canvae.renderWidth = 1
BloomAdd.Canvae.renderHeight = 1
BloomAdd.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
BloomAdd.Execute = function(Canva1, img, w, h)
   
    if BloomAdd.Canvae.renderWidth ~= w  or BloomAdd.Canvae.renderHeight ~= h then
        BloomAdd.Canvae = Canvas.new(w, h, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BloomAdd.Canvae.renderWidth = w
        BloomAdd.Canvae.renderHeight = h

        BloomAdd.meshquad = _G.MeshQuad.new(BloomAdd.Canvae.renderWidth, BloomAdd.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end

    love.graphics.setCanvas(BloomAdd.Canvae.obj)
    love.graphics.clear()
    BloomAdd.meshquad:setCanvas(Canva1)
    BloomAdd.meshquad.shader = Shader.GetBloomAdd(img)
    BloomAdd.meshquad:draw()
    love.graphics.setCanvas()

    return BloomAdd.Canvae

end


function Shader.GetBrightnessShader(l)
    if not l then
        l = 0.001
    end

    if Shader['shader_GetBrightnessShader']  then
        Shader['shader_GetBrightnessShader']:send('l', l);

        return Shader['shader_GetBrightnessShader']
    end
    local pixelcode = 'uniform float l;\n'
    pixelcode = pixelcode .. _G.ShaderFunction.Luminance
    pixelcode = pixelcode .. [[
    varying vec2 vTexCoord2;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, vTexCoord2);
        vec4 basecolor = texcolor * color;
        float bl = clamp(Luminance(basecolor.xyz) - l, 0.0, 1.0) ;

        if (bl == 0)
        discard;
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
    assert(shader:hasUniform( "l"))
    shader:send('l', l);
    Shader['shader_GetBrightnessShader'] = shader
    return shader
end

function Shader.GetBlurHSE(w, offset, power)

    if Shader['shader_GetBlurSSE']  then
        Shader['shader_GetBlurSSE']:send('w', w);
        Shader['shader_GetBlurSSE']:send('offset', offset or 1);
        Shader['shader_GetBlurSSE']:send('power', power or 1);
        -- Shader['shader_GetBlurSSE']:send('baseimg', img.obj);
        return  Shader['shader_GetBlurSSE']
    end
    local pixelcode = 'uniform float w;\n'
    pixelcode = pixelcode .. 'uniform float offset;\n'
    pixelcode = pixelcode .. 'uniform float power;\n'
    -- pixelcode = pixelcode .. "uniform sampler2D baseimg;\n"

    pixelcode = pixelcode .. _G.ShaderFunction.Luminance
    pixelcode = pixelcode .. [[
    varying vec2 vTexCoord2;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float sw = offset / w;
        vec4 texcolor = Texel(tex, vTexCoord2);
        vec3 c1 = Texel(tex, vec2(vTexCoord2.x, vTexCoord2.y - 1 * sw)).xyz;
        vec3 c2 = Texel(tex, vec2(vTexCoord2.x, vTexCoord2.y - 2 * sw)).xyz;
        vec3 c3 = Texel(tex, vec2(vTexCoord2.x, vTexCoord2.y - 3 * sw)).xyz;
        vec3 c4 = Texel(tex, vec2(vTexCoord2.x, vTexCoord2.y - 4 * sw)).xyz;
        vec3 c5 = Texel(tex, vec2(vTexCoord2.x, vTexCoord2.y - 5 * sw)).xyz;
        vec3 c6 = Texel(tex, vec2(vTexCoord2.x, vTexCoord2.y + 5 * sw)).xyz;
        vec3 c7 = Texel(tex, vec2(vTexCoord2.x, vTexCoord2.y + 4 * sw)).xyz;
        vec3 c8 = Texel(tex, vec2(vTexCoord2.x, vTexCoord2.y + 3 * sw)).xyz;
        vec3 c9 = Texel(tex, vec2(vTexCoord2.x, vTexCoord2.y + 2 * sw)).xyz;
        vec3 c10 = Texel(tex, vec2(vTexCoord2.x, vTexCoord2.y + 1 * sw)).xyz;


        vec3 basecolor = (texcolor.xyz + c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9 + c10 ) / 12;
        return vec4(basecolor, texcolor.w) * color * power;

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
    shader:send('offset', offset or 1);
    shader:send('power', power or 1);
    -- shader:send('baseimg',  img.obj);
    Shader['shader_GetBlurSSE'] = shader
    return shader
end


function Shader.GetBlurWSE(h, offset, power)

    if Shader['shader_GetBlurWSE']  then
        Shader['shader_GetBlurWSE']:send('h', h);
        Shader['shader_GetBlurWSE']:send('offset', offset or 1);
        Shader['shader_GetBlurWSE']:send('power', power or 1);
        return Shader['shader_GetBlurWSE']
    end
    local pixelcode = 'uniform float h;\n'
    pixelcode = pixelcode .. 'uniform float offset;\n'
    pixelcode = pixelcode .. 'uniform float power;\n'
    -- pixelcode = pixelcode .. "uniform sampler2D baseimg;\n"

    pixelcode = pixelcode .. _G.ShaderFunction.Luminance
    pixelcode = pixelcode .. [[
    varying vec2 vTexCoord2;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float sw = offset / h;
        vec4 texcolor = Texel(tex, vTexCoord2);
        vec3 c1 = Texel(tex, vec2(vTexCoord2.x - 1 * sw  , vTexCoord2.y)).xyz;
        vec3 c2 = Texel(tex, vec2(vTexCoord2.x - 2 * sw, vTexCoord2.y)).xyz;
        vec3 c3 = Texel(tex, vec2(vTexCoord2.x - 3 * sw, vTexCoord2.y)).xyz;
        vec3 c4 = Texel(tex, vec2(vTexCoord2.x - 4 * sw, vTexCoord2.y)).xyz;
        vec3 c5 = Texel(tex, vec2(vTexCoord2.x - 5 * sw, vTexCoord2.y)).xyz;
        vec3 c6 = Texel(tex, vec2(vTexCoord2.x + 5 * sw, vTexCoord2.y)).xyz;
        vec3 c7 = Texel(tex, vec2(vTexCoord2.x + 4 * sw, vTexCoord2.y)).xyz;
        vec3 c8 = Texel(tex, vec2(vTexCoord2.x + 3 * sw, vTexCoord2.y)).xyz;
        vec3 c9 = Texel(tex, vec2(vTexCoord2.x + 2 * sw , vTexCoord2.y )).xyz;
        vec3 c10 = Texel(tex, vec2(vTexCoord2.x +  1 * sw, vTexCoord2.y )).xyz;


        vec3 basecolor = (texcolor.xyz + c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9 + c10 ) / 11;
        return vec4(basecolor, texcolor.w) * color * power;

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
    shader:send('h', h);
    shader:send('offset', offset or 1);
    shader:send('power', power or 1);
    -- shader:send('baseimg',  img.obj);
    Shader['shader_GetBlurWSE'] = shader
    return shader
end

function Shader.GetBlurWHSE(w, h, offset, power)

    if Shader['shader_GetBlurWHSE']  then
        Shader['shader_GetBlurWHSE']:send('h', h);
        Shader['shader_GetBlurWHSE']:send('w', w);
        Shader['shader_GetBlurWHSE']:send('offset', offset or 1);
        Shader['shader_GetBlurWHSE']:send('power', power or 1);
        return Shader['shader_GetBlurWHSE']
    end
    local pixelcode = 'uniform float h;\n'
    pixelcode = pixelcode .. 'uniform float w;\n'
    pixelcode = pixelcode .. 'uniform float offset;\n'
    pixelcode = pixelcode .. 'uniform float power;\n'
    -- pixelcode = pixelcode .. "uniform sampler2D baseimg;\n"

    pixelcode = pixelcode .. _G.ShaderFunction.Luminance
    pixelcode = pixelcode .. [[
    varying vec2 vTexCoord2;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float sw = offset / w;
        float sh = offset / h;
        vec4 texcolor = Texel(tex, vTexCoord2);
		for(int  i = -2; i < 2 ; i ++)
		{
			for(int j = -2; j < 2; j ++)
			{
				
				texcolor.xyz += Texel(tex, vec2(vTexCoord2.x + i * sw  , vTexCoord2.y + j * sh)).xyz;
			}
		}

        vec3 basecolor = texcolor.xyz / 26;
        return vec4(basecolor, texcolor.w) * color * power;

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
    shader:send('h', h);
    shader:send('w', w);
    shader:send('offset', offset or 1);
    shader:send('power', power or 1);
    -- shader:send('baseimg',  img.obj);
    Shader['shader_GetBlurWHSE'] = shader
    return shader
end


function Shader.GetBloomAdd(img)

    if Shader['shader_GetBloomAdd']  then
        Shader['shader_GetBloomAdd']:send('img', img.obj);
        return Shader['shader_GetBloomAdd']
    end

    -- pixelcode = pixelcode .. "uniform sampler2D baseimg;\n"
    local pixelcode = " uniform sampler2D img;  \n";
    pixelcode = pixelcode .. [[
    varying vec2 vTexCoord2;

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

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, vTexCoord2);
        
        vec4 imgcolor = Texel(img, vTexCoord2);


        vec4 ResultColor = (texcolor +  imgcolor ) * color;
        float gamma = 2.2;
        ResultColor.rgb = pow(ResultColor.rgb, vec3(1.0/gamma));
        float bl = 0.2126 * ResultColor.x + 0.7152 * ResultColor.y + 0.0722 * ResultColor.z;
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
    Shader['shader_GetBloomAdd'] = shader
    return shader
end

function Shader.GetBlurCircle()

    if Shader['shader_GetBlurCircle']  then
        return Shader['shader_GetBlurCircle']
    end
    local pixelcode = 'uniform float h;\n'
    -- pixelcode = pixelcode .. "uniform sampler2D baseimg;\n"

    pixelcode = pixelcode .. _G.ShaderFunction.CircleSampler
    pixelcode = pixelcode .. [[
    varying vec2 vTexCoord2;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float StartUp = 1.0 / 9.0;
        float StartDown = 1.0 / 5.0;
        vec4 texcolor = Texel(tex, vTexCoord2);
        vec3 c1 = Texel(tex, vTexCoord2 + CircleSampler(9.0, StartUp, 1)).xyz;
        vec3 c2 = Texel(tex, vTexCoord2 + CircleSampler(9.0, StartUp, 2)).xyz;
        vec3 c3 = Texel(tex, vTexCoord2 + CircleSampler(9.0, StartUp, 3)).xyz;
        vec3 c4 = Texel(tex, vTexCoord2 + CircleSampler(9.0, StartUp, 4)).xyz;
        vec3 c5 = Texel(tex, vTexCoord2 + CircleSampler(9.0, StartUp, 5)).xyz;
        vec3 c6 = Texel(tex, vTexCoord2 + CircleSampler(9.0, StartUp, 6)).xyz;
        vec3 c7 = Texel(tex, vTexCoord2 + CircleSampler(9.0, StartUp, 7)).xyz;
        vec3 c8 = Texel(tex, vTexCoord2 + CircleSampler(9.0, StartUp, 8)).xyz;
        vec3 c9 = Texel(tex, vTexCoord2 + CircleSampler(9.0, StartUp, 9)).xyz;
		
        vec3 c10 = Texel(tex, vTexCoord2 + CircleSampler(5.0, StartDown, 1)).xyz;
        vec3 c11 = Texel(tex, vTexCoord2 + CircleSampler(5.0, StartDown, 2)).xyz;
        vec3 c12 = Texel(tex, vTexCoord2 + CircleSampler(5.0, StartDown, 3)).xyz;
		vec3 c13 = Texel(tex, vTexCoord2 + CircleSampler(5.0, StartDown, 4)).xyz;
        vec3 c14 = Texel(tex, vTexCoord2 + CircleSampler(5.0, StartDown, 5)).xyz;

        vec3 basecolor = (texcolor.xyz + c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9 + c10 + c11 + c12 + c13 + c14	) / 15;
        return vec4(basecolor, texcolor.w) * color;

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
    -- shader:send('baseimg',  img.obj);
    Shader['shader_GetBlurCircle'] = shader
    return shader
end

HDRSetting(function(IsHDR)
    -- if IsHDR then
    --     PixelFormat = "rgba16f"
    -- else
    --     PixelFormat = "rgba8"
    -- end
    -- Bloom.Canvae = Canvas.new(Bloom.Canvae.renderWidth, Bloom.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})

    -- BlurHSE.Canvae = Canvas.new(BlurHSE.Canvae.renderWidth, BlurHSE.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
    -- BlurWSE.Canvae = Canvas.new(BlurWSE.Canvae.renderWidth, BlurWSE.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
    -- BlurWHSE.Canvae = Canvas.new(BlurWHSE.Canvae.renderWidth, BlurWHSE.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
    -- BlurCircle.Canvae = Canvas.new(BlurCircle.Canvae.renderWidth, BlurCircle.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
    -- BloomAdd.Canvae = Canvas.new(BloomAdd.Canvae.renderWidth, BloomAdd.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
end)
