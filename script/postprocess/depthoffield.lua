local PixelFormat = "rgba8"
local PixelOffset = 1
_G.DepthOfField = {}

local BlurHorizontal = {}
local BlurVertical = {}
local BlurVerticalCom = {}

DepthOfField.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
DepthOfField.Canvae.renderWidth = 1
DepthOfField.Canvae.renderHeight = 1
DepthOfField.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

DepthOfField.ClamptBrightness = 0.0
local Bi = 2
DepthOfField.Execute = function(Canva1, InMeshQuad)
    if DepthOfField.Canvae.renderWidth ~= Canva1.renderWidth or DepthOfField.Canvae.renderHeight ~= Canva1.renderHeight then
        DepthOfField.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        DepthOfField.Canvae.renderWidth = Canva1.renderWidth 
        DepthOfField.Canvae.renderHeight = Canva1.renderHeight

        DepthOfField.meshquad = _G.MeshQuad.new(Canva1.renderWidth, Canva1.renderHeight, LColor.new(255, 255, 255, 255))
    end

    -- love.graphics.setCanvas(DepthOfField.Canvae.obj)
    -- love.graphics.clear()
    -- DepthOfField.meshquad:setCanvas(Canva1)
    -- DepthOfField.meshquad.shader = Shader.DOFGetBrightnessShader2(DepthOfField.ClamptBrightness)
    -- DepthOfField.meshquad:draw()
    -- love.graphics.setCanvas()    

    local HorizontalCanvan1 = BlurHorizontal.Execute(Canva1, PixelOffset, 1, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi, true)
    local HorizontalCanvan2 = BlurHorizontal.Execute(Canva1, PixelOffset, 1, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi, false)
    local RenderCanvan2 = BlurVerticalCom.Execute(HorizontalCanvan1, HorizontalCanvan2, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi, 2)
    local VerticalCanvan1 = BlurVertical.Execute(RenderCanvan2, PixelOffset, 1, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi, true)
    local VerticalCanvan2 = BlurVertical.Execute(RenderCanvan2, PixelOffset, 1, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi, false)
    --local RenderCanvan1 = BlurVerticalCom.Execute(HorizontalCanvan1, HorizontalCanvan2, Canva1.renderWidth / 4, Canva1.renderHeight / 4, 1)
    --local VerticalCanvan1 = BlurVertical.Execute(Canva1, PixelOffset, 1, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi, true)
    --local VerticalCanvan2 = BlurVertical.Execute(Canva1, PixelOffset, 1, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi, false)
   -- local RenderCanvan1 = BlurVerticalCom.Execute(HorizontalCanvan1, HorizontalCanvan2, Canva1.renderWidth / 4, Canva1.renderHeight / 4, 1)
    local RenderCanvan1 = BlurVerticalCom.Execute(VerticalCanvan1, VerticalCanvan2, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi, 1)
    
    --local RenderCanvan = BlurVerticalCom.Execute(RenderCanvan1, RenderCanvan2, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi, 3)
    -- local RenderCanvan = BlurVerticalCom.Execute(RenderCanvan1, RenderCanvan2, Canva1.renderWidth / 4, Canva1.renderHeight / 4, 3)
    -- RenderCanvan.renderHeight = Canva1.renderHeight
    -- RenderCanvan.renderWidth = Canva1.renderWidth

    RenderCanvan1.renderHeight = Canva1.renderHeight * 2
    RenderCanvan1.renderWidth = Canva1.renderWidth * 2
    return RenderCanvan1
end

BlurHorizontal.Canvae1 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurHorizontal.Canvae1.renderWidth = 1
BlurHorizontal.Canvae1.renderHeight = 1

BlurHorizontal.Canvae2 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurHorizontal.Canvae2.renderWidth = 1
BlurHorizontal.Canvae2.renderHeight = 1

BlurHorizontal.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
BlurHorizontal.Execute = function(Canva1, offset, power, w, h, IsImaginary)
   
    if BlurHorizontal.Canvae1.renderWidth ~= w  or BlurHorizontal.Canvae1.renderHeight ~= h then
        BlurHorizontal.Canvae1 = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BlurHorizontal.Canvae1.renderWidth = w
        BlurHorizontal.Canvae1.renderHeight = h

        BlurHorizontal.Canvae2 = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BlurHorizontal.Canvae2.renderWidth = w
        BlurHorizontal.Canvae2.renderHeight = h
        BlurHorizontal.meshquad = _G.MeshQuad.new(BlurHorizontal.Canvae1.renderWidth, BlurHorizontal.Canvae1.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    local BGCanva
    if IsImaginary then
        BGCanva = BlurHorizontal.Canvae2
    else
        BGCanva = BlurHorizontal.Canvae1
    end

    love.graphics.setCanvas(BGCanva.obj)
    love.graphics.clear()
    BlurHorizontal.meshquad:setCanvas(Canva1)
    BlurHorizontal.meshquad.shader = Shader.DOFGetBlurHorizontal(w, h, offset, power, IsImaginary)
    BlurHorizontal.meshquad:draw()
    love.graphics.setCanvas()
    return BGCanva
end

BlurVertical.Canvae1 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurVertical.Canvae1.renderWidth = 1
BlurVertical.Canvae1.renderHeight = 1

BlurVertical.Canvae2 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurVertical.Canvae2.renderWidth = 1
BlurVertical.Canvae2.renderHeight = 1

BlurVertical.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
BlurVertical.Execute = function(Canva1, offset, power, w, h, IsImaginary)
   
    if BlurVertical.Canvae1.renderWidth ~= w  or BlurVertical.Canvae1.renderHeight ~= h then
        BlurVertical.Canvae1 = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BlurVertical.Canvae1.renderWidth = w
        BlurVertical.Canvae1.renderHeight = h

        
        BlurVertical.Canvae2 = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BlurVertical.Canvae2.renderWidth = w
        BlurVertical.Canvae2.renderHeight = h

        BlurVertical.meshquad = _G.MeshQuad.new(BlurVertical.Canvae1.renderWidth, BlurVertical.Canvae1.renderHeight , LColor.new(255, 255, 255, 255))
    end

    local BGCanva
    if IsImaginary then
        BGCanva = BlurVertical.Canvae2
    else
        BGCanva = BlurVertical.Canvae1
    end
    
    love.graphics.setCanvas(BGCanva.obj)
    love.graphics.clear()
    BlurVertical.meshquad:setCanvas(Canva1)
    BlurVertical.meshquad.shader = Shader.DOFGetBlurVertical(w, h, offset, power, IsImaginary)
    BlurVertical.meshquad:draw()
    love.graphics.setCanvas()
    return BGCanva
end

BlurVerticalCom.Canvae1 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurVerticalCom.Canvae1.renderWidth = 1
BlurVerticalCom.Canvae1.renderHeight = 1

BlurVerticalCom.Canvae2 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurVerticalCom.Canvae2.renderWidth = 1
BlurVerticalCom.Canvae2.renderHeight = 1

BlurVerticalCom.Canvae3 = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
BlurVerticalCom.Canvae3.renderWidth = 1
BlurVerticalCom.Canvae3.renderHeight = 1
BlurVerticalCom.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
BlurVerticalCom.Execute = function(Canva1, img, w, h, SelectID)
   
    if BlurVerticalCom.Canvae1.renderWidth ~= w  or BlurVerticalCom.Canvae1.renderHeight ~= h then
        BlurVerticalCom.Canvae1 = Canvas.new(w, h, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BlurVerticalCom.Canvae1.renderWidth = w
        BlurVerticalCom.Canvae1.renderHeight = h

        BlurVerticalCom.Canvae2 = Canvas.new(w, h, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BlurVerticalCom.Canvae2.renderWidth = w
        BlurVerticalCom.Canvae2.renderHeight = h

        BlurVerticalCom.Canvae3 = Canvas.new(w, h, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        BlurVerticalCom.Canvae3.renderWidth = w
        BlurVerticalCom.Canvae3.renderHeight = h

        BlurVerticalCom.meshquad = _G.MeshQuad.new(BlurVerticalCom.Canvae1.renderWidth, BlurVerticalCom.Canvae1.renderHeight , LColor.new(255, 255, 255, 255))
    end

    local BGCanva
    if SelectID == 1 then
        BGCanva = BlurVerticalCom.Canvae1
    elseif SelectID == 2 then
        BGCanva = BlurVerticalCom.Canvae2
    else
        BGCanva = BlurVerticalCom.Canvae3
    end
    love.graphics.setCanvas(BGCanva.obj)
    love.graphics.clear()
    BlurVerticalCom.meshquad:setCanvas(Canva1)
    BlurVerticalCom.meshquad.shader = Shader.DOFGetBlurVerticalCom(img)
    BlurVerticalCom.meshquad:draw()
    love.graphics.setCanvas()

    return BGCanva

end


function Shader.DOFGetBrightnessShader2(l)
    if not l then
        l = 0.001
    end

    if Shader['shader_DOFGetBrightnessShader2']  then
        Shader['shader_DOFGetBrightnessShader2']:sendValue('l', l);

        return Shader['shader_DOFGetBrightnessShader2']
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
    Shader['shader_DOFGetBrightnessShader2'] = shader
    return shader
end


function Shader.DOFGetBlurHorizontal(w, h, offset, power, IsImaginary)

    if Shader['shader_DOFGetBlurHorizontal' .. tostring(IsImaginary)]  then
        Shader['shader_DOFGetBlurHorizontal'.. tostring(IsImaginary)]:sendValue('w', w);
        Shader['shader_DOFGetBlurHorizontal'.. tostring(IsImaginary)]:sendValue('h', h);
        Shader['shader_DOFGetBlurHorizontal'.. tostring(IsImaginary)]:sendValue('offset', offset or 1);
       -- Shader['shader_DOFGetBlurHorizontal']:send('power', power or 1);
        -- Shader['shader_GetBlur2SSE']:send('baseimg', img.obj);
        return  Shader['shader_DOFGetBlurHorizontal'.. tostring(IsImaginary)]
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
        //vec2 halfpixel = vec2(offset / w, offset / h);
       //halfpixel *= 0.5;

        vec2 halfpixel = vec2(0, offset  / h);

        vec4 BaseColor = texture2D(tex, vTexCoord2);


        ]]
        if IsImaginary then
            pixelcode = pixelcode .. [[
                vec4 sum = BaseColor * 0;
        


                //sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 6);
                //sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 5) * 6;
                //sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 4) * 8;
                sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 3) * 3;
                sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 2) * 2;
                sum += texture2D(tex, vTexCoord2 - halfpixel.xy) * 1;
                sum += texture2D(tex, vTexCoord2 + halfpixel.xy) * 1;
                sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 2) * 2;
                sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 3) * 3;
                //sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 4) * 8;
               // sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 5) * 6;
                //sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 6);
                return vec4(sum.xyz / 12, 1);
        }
            ]]
        else
            pixelcode = pixelcode .. [[
                vec4 sum = BaseColor * 4;
        
                //sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 6);
               // sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 5) * 1;
                //sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 4) * 2;
                sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 3) * 1;
                sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 2) * 2;
                sum += texture2D(tex, vTexCoord2 - halfpixel.xy) * 3;
                sum += texture2D(tex, vTexCoord2 + halfpixel.xy) * 3;
                sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 2) * 2;
                sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 3) * 1;
                //sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 4) * 2;
               // sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 5) * 1;
                //sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 6);
                return vec4(sum.xyz / 16, 1);
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
    log(shader)
    shader:sendValue('w', w);
    shader:sendValue('h', h);
    shader:sendValue('offset', offset or 1);
    --shader:send('power', power or 1);
    -- shader:send('baseimg',  img.obj);
    Shader['shader_DOFGetBlurHorizontal'.. tostring(IsImaginary)] = shader
    shader.Name = 'shader_DOFGetBlurHorizontal'.. tostring(IsImaginary)
    return shader
end


function Shader.DOFGetBlurVertical(w, h, offset, power, IsImaginary)

    if Shader['shader_DOFGetBlurVertical'.. tostring(IsImaginary)]  then
        Shader['shader_DOFGetBlurVertical'.. tostring(IsImaginary)]:sendValue('w', w);
        Shader['shader_DOFGetBlurVertical'.. tostring(IsImaginary)]:sendValue('h', h);
        Shader['shader_DOFGetBlurVertical'.. tostring(IsImaginary)]:sendValue('offset', offset or 1);
      --  Shader['shader_DOFGetBlurVertical']:send('power', power or 1);
        -- Shader['shader_GetBlur2SSE']:send('baseimg', img.obj);
        return  Shader['shader_DOFGetBlurVertical'.. tostring(IsImaginary)]
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
        vec2 halfpixel = vec2(offset / w, 0);
        //halfpixel *= 0.5;
        vec4 BaseColor = texture2D(tex, vTexCoord2);
        
    
]]
if IsImaginary then
    pixelcode = pixelcode .. [[
        vec4 sum = BaseColor * 0;



        //sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 6);
        //sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 5) * 6;
        //sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 4) * 8;
        sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 3) * 3;
        sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 2) * 2;
        sum += texture2D(tex, vTexCoord2 - halfpixel.xy) * 1;
        sum += texture2D(tex, vTexCoord2 + halfpixel.xy) * 1;
        sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 2) * 2;
        sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 3) * 3;
        //sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 4) * 8;
       // sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 5) * 6;
        //sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 6);
        return vec4(sum.xyz / 12, 1);
}
    ]]
else
    pixelcode = pixelcode .. [[
        vec4 sum = BaseColor * 4;

        //sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 6);
       // sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 5) * 1;
        //sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 4) * 2;
        sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 3) * 1;
        sum += texture2D(tex, vTexCoord2 - halfpixel.xy * 2) * 2;
        sum += texture2D(tex, vTexCoord2 - halfpixel.xy) * 3;
        sum += texture2D(tex, vTexCoord2 + halfpixel.xy) * 3;
        sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 2) * 2;
        sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 3) * 1;
        //sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 4) * 2;
       // sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 5) * 1;
        //sum += texture2D(tex, vTexCoord2 + halfpixel.xy * 6);
        return vec4(sum.xyz / 16, 1);
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
    shader:sendValue('w', w);
    shader:sendValue('h', h);
    shader:sendValue('offset', offset or 1);
   -- shader:send('power', power or 1);
    -- shader:send('baseimg',  img.obj);
    Shader['shader_DOFGetBlurVertical'.. tostring(IsImaginary)] = shader
    return shader
end

function Shader.DOFGetBlurVerticalCom(img)

    if Shader['shader_DOFGetBlurVerticalCom']  then
        Shader['shader_DOFGetBlurVerticalCom']:send('img', img.obj);
        return Shader['shader_DOFGetBlurVerticalCom']
    end

    -- pixelcode = pixelcode .. "uniform sampler2D baseimg;\n"
    local pixelcode = " uniform sampler2D img;  \n";
    pixelcode = pixelcode .. [[
    varying vec2 vTexCoord2;

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, vTexCoord2);
        
        vec4 imgcolor = Texel(img, vTexCoord2);


        vec4 ResultColor = (texcolor +  imgcolor ) * 0.5;
        
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
    Shader['shader_DOFGetBlurVerticalCom'] = shader
    return shader
end
HDRSetting(function(IsHDR)
    if IsHDR then
        PixelFormat = "rgba16f"
    else
        PixelFormat = "rgba8"
    end
    DepthOfField.Canvae = Canvas.new(DepthOfField.Canvae.renderWidth, DepthOfField.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})

    BlurVertical.Canvae = Canvas.new(BlurVertical.Canvae.renderWidth, BlurVertical.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
    BlurHorizontal.Canvae = Canvas.new(BlurHorizontal.Canvae.renderWidth, BlurHorizontal.Canvae.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
end)
