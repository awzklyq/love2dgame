local PixelFormat = "rgba8"
local PixelOffset = 1
_G.DepthOfField = {}

local BlurHorizontal = {}
local BlurVertical = {}
local BlurVerticalCom = {}

local DOFFiltersTypeR = 1
local DOFFiltersTypeG = 2
local DOFFiltersTypeB = 3

local DOFFiltersR = {}
local DOFFiltersG = {}
local DOFFiltersB = {}

local DOFFilterCom = {}

DepthOfField.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
DepthOfField.Canvae.renderWidth = 1
DepthOfField.Canvae.renderHeight = 1
DepthOfField.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

local Bi = 1
DepthOfField.Execute = function(Canva1, InMeshQuad)
    if DepthOfField.Canvae.renderWidth ~= Canva1.renderWidth or DepthOfField.Canvae.renderHeight ~= Canva1.renderHeight then
        DepthOfField.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        DepthOfField.Canvae.renderWidth = Canva1.renderWidth 
        DepthOfField.Canvae.renderHeight = Canva1.renderHeight

        DepthOfField.meshquad = _G.MeshQuad.new(Canva1.renderWidth, Canva1.renderHeight, LColor.new(255, 255, 255, 255))
    end

    local DOFFiltersRCanvas = DOFFiltersR.Execute(Canva1, PixelOffset, 1, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi)
    local DOFFiltersGCanvas = DOFFiltersG.Execute(Canva1, PixelOffset, 1, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi)
    local DOFFiltersBCanvas = DOFFiltersB.Execute(Canva1, PixelOffset, 1, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi)

    local RenderCanvas = DOFFilterCom.Execute(Canva1, DOFFiltersRCanvas, DOFFiltersGCanvas, DOFFiltersBCanvas, Canva1.renderWidth / Bi, Canva1.renderHeight / Bi)

    RenderCanvas.renderHeight = Canva1.renderHeight 
    RenderCanvas.renderWidth = Canva1.renderWidth
    return RenderCanvas
end

DOFFiltersR.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
DOFFiltersR.Canvae.renderWidth = 1
DOFFiltersR.Canvae.renderHeight = 1

DOFFiltersR.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
DOFFiltersR.Execute = function(Canva1, offset, power, w, h)
   
    if DOFFiltersR.Canvae.renderWidth ~= w  or DOFFiltersR.Canvae.renderHeight ~= h then
        DOFFiltersR.Canvae = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        DOFFiltersR.Canvae.renderWidth = w
        DOFFiltersR.Canvae.renderHeight = h
        DOFFiltersR.meshquad = _G.MeshQuad.new(DOFFiltersR.Canvae.renderWidth, DOFFiltersR.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    local  BGCanva = DOFFiltersR.Canvae
    love.graphics.setCanvas(BGCanva.obj)
    love.graphics.clear()
    DOFFiltersR.meshquad:setCanvas(Canva1)
    DOFFiltersR.meshquad.shader = Shader.DOFGetDOFFilters(w, h, offset, power, DOFFiltersTypeR)
    DOFFiltersR.meshquad:draw()
    love.graphics.setCanvas()
    return BGCanva
end


DOFFiltersG.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
DOFFiltersG.Canvae.renderWidth = 1
DOFFiltersG.Canvae.renderHeight = 1

DOFFiltersG.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
DOFFiltersG.Execute = function(Canva1, offset, power, w, h)
   
    if DOFFiltersG.Canvae.renderWidth ~= w  or DOFFiltersG.Canvae.renderHeight ~= h then
        DOFFiltersG.Canvae = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        DOFFiltersG.Canvae.renderWidth = w
        DOFFiltersG.Canvae.renderHeight = h
        DOFFiltersG.meshquad = _G.MeshQuad.new(DOFFiltersG.Canvae.renderWidth, DOFFiltersG.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    local  BGCanva = DOFFiltersG.Canvae
    love.graphics.setCanvas(BGCanva.obj)
    love.graphics.clear()
    DOFFiltersG.meshquad:setCanvas(Canva1)
    DOFFiltersG.meshquad.shader = Shader.DOFGetDOFFilters(w, h, offset, power, DOFFiltersTypeG)
    DOFFiltersG.meshquad:draw()
    love.graphics.setCanvas()
    return BGCanva
end


DOFFiltersB.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
DOFFiltersB.Canvae.renderWidth = 1
DOFFiltersB.Canvae.renderHeight = 1

DOFFiltersB.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
DOFFiltersB.Execute = function(Canva1, offset, power, w, h)
   
    if DOFFiltersB.Canvae.renderWidth ~= w  or DOFFiltersB.Canvae.renderHeight ~= h then
        DOFFiltersB.Canvae = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        DOFFiltersB.Canvae.renderWidth = w
        DOFFiltersB.Canvae.renderHeight = h
        DOFFiltersB.meshquad = _G.MeshQuad.new(DOFFiltersB.Canvae.renderWidth, DOFFiltersB.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    local  BGCanva = DOFFiltersB.Canvae
    love.graphics.setCanvas(BGCanva.obj)
    love.graphics.clear()
    DOFFiltersB.meshquad:setCanvas(Canva1)
    DOFFiltersB.meshquad.shader = Shader.DOFGetDOFFilters(w, h, offset, power, DOFFiltersTypeB)
    DOFFiltersB.meshquad:draw()
    love.graphics.setCanvas()
    return BGCanva
end


DOFFilterCom.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
DOFFilterCom.Canvae.renderWidth = 1
DOFFilterCom.Canvae.renderHeight = 1
DOFFilterCom.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
DOFFilterCom.Execute = function(Canva1, ImageR, ImageG, ImageB, w, h)
   
    if DOFFilterCom.Canvae.renderWidth ~= w  or DOFFilterCom.Canvae.renderHeight ~= h then
        DOFFilterCom.Canvae = Canvas.new(w, h, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        DOFFilterCom.Canvae.renderWidth = w
        DOFFilterCom.Canvae.renderHeight = h

        
        DOFFilterCom.meshquad = _G.MeshQuad.new(DOFFilterCom.Canvae.renderWidth, DOFFilterCom.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end

    local BGCanva = DOFFilterCom.Canvae

    love.graphics.setCanvas(BGCanva.obj)
    love.graphics.clear()
    DOFFilterCom.meshquad:setCanvas(Canva1)
    DOFFilterCom.meshquad.shader = Shader.DOFGetDOFFilterCom(ImageR, ImageG, ImageB, w, h)
    DOFFilterCom.meshquad:draw()
    love.graphics.setCanvas()

    return BGCanva

end

 
function Shader.DOFGetDOFFilters(w, h, offset, power, DOFFiltersType)

    local ShaderName = 'shader_DOFGetDOFFiltersR'..tostring(DOFFiltersType)
    if Shader[ShaderName]  then
        Shader[ShaderName]:sendValue('w', w);
        Shader[ShaderName]:sendValue('h', h);
        Shader[ShaderName]:sendValue('offset', offset or 1);
       -- Shader['shader_DOFGetBlurHorizontal']:send('power', power or 1);
        -- Shader['shader_GetBlur2SSE']:send('baseimg', img.obj);
        return  Shader[ShaderName]
    end

    local pixelcode = [[
    uniform float w;
    uniform float h;
    uniform float offset;
    varying vec2 vTexCoord2;

    const int KERNEL_RADIUS = 8;

    const vec4 Kernel0_RealX_ImY_RealZ_ImW[] = vec4[](
            vec4(/*XY: Non Bracketed*/0.014096,-0.022658,/*Bracketed WZ:*/0.055991,0.004413),
            vec4(/*XY: Non Bracketed*/-0.020612,-0.025574,/*Bracketed WZ:*/0.019188,0.000000),
            vec4(/*XY: Non Bracketed*/-0.038708,0.006957,/*Bracketed WZ:*/0.000000,0.049223),
            vec4(/*XY: Non Bracketed*/-0.021449,0.040468,/*Bracketed WZ:*/0.018301,0.099929),
            vec4(/*XY: Non Bracketed*/0.013015,0.050223,/*Bracketed WZ:*/0.054845,0.114689),
            vec4(/*XY: Non Bracketed*/0.042178,0.038585,/*Bracketed WZ:*/0.085769,0.097080),
            vec4(/*XY: Non Bracketed*/0.057972,0.019812,/*Bracketed WZ:*/0.102517,0.068674),
            vec4(/*XY: Non Bracketed*/0.063647,0.005252,/*Bracketed WZ:*/0.108535,0.046643),
            vec4(/*XY: Non Bracketed*/0.064754,0.000000,/*Bracketed WZ:*/0.109709,0.038697),
            vec4(/*XY: Non Bracketed*/0.063647,0.005252,/*Bracketed WZ:*/0.108535,0.046643),
            vec4(/*XY: Non Bracketed*/0.057972,0.019812,/*Bracketed WZ:*/0.102517,0.068674),
            vec4(/*XY: Non Bracketed*/0.042178,0.038585,/*Bracketed WZ:*/0.085769,0.097080),
            vec4(/*XY: Non Bracketed*/0.013015,0.050223,/*Bracketed WZ:*/0.054845,0.114689),
            vec4(/*XY: Non Bracketed*/-0.021449,0.040468,/*Bracketed WZ:*/0.018301,0.099929),
            vec4(/*XY: Non Bracketed*/-0.038708,0.006957,/*Bracketed WZ:*/0.000000,0.049223),
            vec4(/*XY: Non Bracketed*/-0.020612,-0.025574,/*Bracketed WZ:*/0.019188,0.000000),
            vec4(/*XY: Non Bracketed*/0.014096,-0.022658,/*Bracketed WZ:*/0.055991,0.004413)
    );

    const vec4 Kernel1_RealX_ImY_RealZ_ImW[] = vec4[](
            vec4(/*XY: Non Bracketed*/0.000115,0.009116,/*Bracketed WZ:*/0.000000,0.051147),
            vec4(/*XY: Non Bracketed*/0.005324,0.013416,/*Bracketed WZ:*/0.009311,0.075276),
            vec4(/*XY: Non Bracketed*/0.013753,0.016519,/*Bracketed WZ:*/0.024376,0.092685),
            vec4(/*XY: Non Bracketed*/0.024700,0.017215,/*Bracketed WZ:*/0.043940,0.096591),
            vec4(/*XY: Non Bracketed*/0.036693,0.015064,/*Bracketed WZ:*/0.065375,0.084521),
            vec4(/*XY: Non Bracketed*/0.047976,0.010684,/*Bracketed WZ:*/0.085539,0.059948),
            vec4(/*XY: Non Bracketed*/0.057015,0.005570,/*Bracketed WZ:*/0.101695,0.031254),
            vec4(/*XY: Non Bracketed*/0.062782,0.001529,/*Bracketed WZ:*/0.112002,0.008578),
            vec4(/*XY: Non Bracketed*/0.064754,0.000000,/*Bracketed WZ:*/0.115526,0.000000),
            vec4(/*XY: Non Bracketed*/0.062782,0.001529,/*Bracketed WZ:*/0.112002,0.008578),
            vec4(/*XY: Non Bracketed*/0.057015,0.005570,/*Bracketed WZ:*/0.101695,0.031254),
            vec4(/*XY: Non Bracketed*/0.047976,0.010684,/*Bracketed WZ:*/0.085539,0.059948),
            vec4(/*XY: Non Bracketed*/0.036693,0.015064,/*Bracketed WZ:*/0.065375,0.084521),
            vec4(/*XY: Non Bracketed*/0.024700,0.017215,/*Bracketed WZ:*/0.043940,0.096591),
            vec4(/*XY: Non Bracketed*/0.013753,0.016519,/*Bracketed WZ:*/0.024376,0.092685),
            vec4(/*XY: Non Bracketed*/0.005324,0.013416,/*Bracketed WZ:*/0.009311,0.075276),
            vec4(/*XY: Non Bracketed*/0.000115,0.009116,/*Bracketed WZ:*/0.000000,0.051147)
    );

    vec4 fetchImage(vec2 coords, sampler2D tex)
    {
        vec4 colorImg = texture2D(tex, coords);    
        
        //luma trick to mimic HDR, and take advantage of 16 bit buffers shader toy provides.
        float lum = dot(colorImg.rgb,vec3(0.2126,0.7152,0.0722))*1.8;
        colorImg = colorImg *(1.0 + 0.2*lum*lum*lum);
        //return colorImg;
        return colorImg * colorImg;
    }

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 uv = vTexCoord2;
        vec2 stepVal = 1.0/vec2(w, h);
        
        vec4 val = vec4(0,0,0,0);
        float filterRadius = texture2D(tex, uv).a;
        for (int i=-KERNEL_RADIUS; i <=KERNEL_RADIUS; ++i)
        {
            vec2 coords = uv + stepVal*vec2(float(i),0.0)*filterRadius;
]]
    if DOFFiltersType == DOFFiltersTypeR then
        pixelcode = pixelcode.. "float imageTexelR = fetchImage(coords, tex).r;\n"
    elseif DOFFiltersType == DOFFiltersTypeG then
        pixelcode = pixelcode.. "float imageTexelR = fetchImage(coords, tex).g;\n"
    elseif DOFFiltersType == DOFFiltersTypeB then 
        pixelcode = pixelcode.. "float imageTexelR = fetchImage(coords, tex).b;\n"
    end


    pixelcode = pixelcode ..[[
            vec2 c0 = Kernel0_RealX_ImY_RealZ_ImW[i+KERNEL_RADIUS].xy;
            vec2 c1 = Kernel1_RealX_ImY_RealZ_ImW[i+KERNEL_RADIUS].xy;
            vec4 c0_c1 = vec4(c0.x, c0.y, c1.x, c1.y);

            val.xy += imageTexelR * c0_c1.xy;
            val.zw += imageTexelR * c0_c1.zw;
            
        }
        return val;
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
    
    shader:sendValue('w', w);
    shader:sendValue('h', h);
    shader:sendValue('offset', offset or 1);
    --shader:send('power', power or 1);
    -- shader:send('baseimg',  img.obj);
    Shader[ShaderName] = shader
    shader.Name = 'shader_DOFGetDOFFiltersR'..tostring(DOFFiltersType)
    return shader
end

function Shader.DOFGetDOFFilterCom(ImageR, ImageG, ImageB, w, h)

    local ShaderName = 'shader_DOFGetDOFFilterCom'
    if Shader[ShaderName]  then
        Shader[ShaderName]:sendValue('ImageR', ImageR.obj);
        Shader[ShaderName]:sendValue('ImageG', ImageG.obj);
        Shader[ShaderName]:sendValue('ImageB', ImageB.obj);
        Shader[ShaderName]:sendValue('w', w);
        Shader[ShaderName]:sendValue('h', h);
        return Shader[ShaderName]
    end

    -- pixelcode = pixelcode .. "uniform sampler2D baseimg;\n"
    local pixelcode = [[
        const vec4 Kernel0_RealX_ImY_RealZ_ImW[] = vec4[](
            vec4(/*XY: Non Bracketed*/0.014096,-0.022658,/*Bracketed WZ:*/0.055991,0.004413),
            vec4(/*XY: Non Bracketed*/-0.020612,-0.025574,/*Bracketed WZ:*/0.019188,0.000000),
            vec4(/*XY: Non Bracketed*/-0.038708,0.006957,/*Bracketed WZ:*/0.000000,0.049223),
            vec4(/*XY: Non Bracketed*/-0.021449,0.040468,/*Bracketed WZ:*/0.018301,0.099929),
            vec4(/*XY: Non Bracketed*/0.013015,0.050223,/*Bracketed WZ:*/0.054845,0.114689),
            vec4(/*XY: Non Bracketed*/0.042178,0.038585,/*Bracketed WZ:*/0.085769,0.097080),
            vec4(/*XY: Non Bracketed*/0.057972,0.019812,/*Bracketed WZ:*/0.102517,0.068674),
            vec4(/*XY: Non Bracketed*/0.063647,0.005252,/*Bracketed WZ:*/0.108535,0.046643),
            vec4(/*XY: Non Bracketed*/0.064754,0.000000,/*Bracketed WZ:*/0.109709,0.038697),
            vec4(/*XY: Non Bracketed*/0.063647,0.005252,/*Bracketed WZ:*/0.108535,0.046643),
            vec4(/*XY: Non Bracketed*/0.057972,0.019812,/*Bracketed WZ:*/0.102517,0.068674),
            vec4(/*XY: Non Bracketed*/0.042178,0.038585,/*Bracketed WZ:*/0.085769,0.097080),
            vec4(/*XY: Non Bracketed*/0.013015,0.050223,/*Bracketed WZ:*/0.054845,0.114689),
            vec4(/*XY: Non Bracketed*/-0.021449,0.040468,/*Bracketed WZ:*/0.018301,0.099929),
            vec4(/*XY: Non Bracketed*/-0.038708,0.006957,/*Bracketed WZ:*/0.000000,0.049223),
            vec4(/*XY: Non Bracketed*/-0.020612,-0.025574,/*Bracketed WZ:*/0.019188,0.000000),
            vec4(/*XY: Non Bracketed*/0.014096,-0.022658,/*Bracketed WZ:*/0.055991,0.004413)
        );

        const vec4 Kernel1_RealX_ImY_RealZ_ImW[] = vec4[](
                vec4(/*XY: Non Bracketed*/0.000115,0.009116,/*Bracketed WZ:*/0.000000,0.051147),
                vec4(/*XY: Non Bracketed*/0.005324,0.013416,/*Bracketed WZ:*/0.009311,0.075276),
                vec4(/*XY: Non Bracketed*/0.013753,0.016519,/*Bracketed WZ:*/0.024376,0.092685),
                vec4(/*XY: Non Bracketed*/0.024700,0.017215,/*Bracketed WZ:*/0.043940,0.096591),
                vec4(/*XY: Non Bracketed*/0.036693,0.015064,/*Bracketed WZ:*/0.065375,0.084521),
                vec4(/*XY: Non Bracketed*/0.047976,0.010684,/*Bracketed WZ:*/0.085539,0.059948),
                vec4(/*XY: Non Bracketed*/0.057015,0.005570,/*Bracketed WZ:*/0.101695,0.031254),
                vec4(/*XY: Non Bracketed*/0.062782,0.001529,/*Bracketed WZ:*/0.112002,0.008578),
                vec4(/*XY: Non Bracketed*/0.064754,0.000000,/*Bracketed WZ:*/0.115526,0.000000),
                vec4(/*XY: Non Bracketed*/0.062782,0.001529,/*Bracketed WZ:*/0.112002,0.008578),
                vec4(/*XY: Non Bracketed*/0.057015,0.005570,/*Bracketed WZ:*/0.101695,0.031254),
                vec4(/*XY: Non Bracketed*/0.047976,0.010684,/*Bracketed WZ:*/0.085539,0.059948),
                vec4(/*XY: Non Bracketed*/0.036693,0.015064,/*Bracketed WZ:*/0.065375,0.084521),
                vec4(/*XY: Non Bracketed*/0.024700,0.017215,/*Bracketed WZ:*/0.043940,0.096591),
                vec4(/*XY: Non Bracketed*/0.013753,0.016519,/*Bracketed WZ:*/0.024376,0.092685),
                vec4(/*XY: Non Bracketed*/0.005324,0.013416,/*Bracketed WZ:*/0.009311,0.075276),
                vec4(/*XY: Non Bracketed*/0.000115,0.009116,/*Bracketed WZ:*/0.000000,0.051147)
        );

        const int KERNEL_RADIUS = 8;

        const vec2 Kernel0Weights_RealX_ImY = vec2(0.411259, -0.548794);
        const vec2 Kernel1Weights_RealX_ImY = vec2(0.513282, 4.561110);

        uniform float w;
        uniform float h;
        uniform sampler2D ImageR;
        uniform sampler2D ImageG;
        uniform sampler2D ImageB;
        varying vec2 vTexCoord2; 

        vec4 fetchImage(vec2 coords, sampler2D tex)
        {
            vec4 colorImg = texture2D(tex, coords);    
            
            //luma trick to mimic HDR, and take advantage of 16 bit buffers shader toy provides.
            float lum = dot(colorImg.rgb,vec3(0.2126,0.7152,0.0722))*1.8;
            colorImg = colorImg *(1.0 + 0.2*lum*lum*lum);
            //return colorImg;
            return colorImg * colorImg;
        }

        vec2 multComplex(vec2 p, vec2 q)
        {
            return vec2(p.x*q.x-p.y*q.y, p.x*q.y+p.y*q.x);
        }

         vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
        {
            vec2 uv = vTexCoord2;
            vec2 stepVal = 1.0/vec2(w, h);
        
            vec4 valR = vec4(0,0,0,0);
            vec4 valG = vec4(0,0,0,0);
            vec4 valB = vec4(0,0,0,0);
            float filterRadius = texture2D(tex, uv).a;
            for (int i=-KERNEL_RADIUS; i <=KERNEL_RADIUS; ++i)
            {
                vec2 coords = uv + stepVal*vec2(0.0,float(i))*filterRadius;
                vec4 imageTexelR = texture2D(ImageR, coords);  
                vec4 imageTexelG = texture2D(ImageG, coords);  
                vec4 imageTexelB = texture2D(ImageB, coords);  
                
                //vec4 c0_c1 = getFilters(tex, i+KERNEL_RADIUS);
                vec2 c0 = Kernel0_RealX_ImY_RealZ_ImW[i+KERNEL_RADIUS].xy;
                vec2 c1 = Kernel1_RealX_ImY_RealZ_ImW[i+KERNEL_RADIUS].xy;
                vec4 c0_c1 = vec4(c0.x, c0.y, c1.x, c1.y);
                
                
                valR.xy += multComplex(imageTexelR.xy,c0_c1.xy);
                valR.zw += multComplex(imageTexelR.zw,c0_c1.zw);
                
                valG.xy += multComplex(imageTexelG.xy,c0_c1.xy);
                valG.zw += multComplex(imageTexelG.zw,c0_c1.zw);
                
                valB.xy += multComplex(imageTexelB.xy,c0_c1.xy);
                valB.zw += multComplex(imageTexelB.zw,c0_c1.zw);       
            }
            
            float redChannel   = dot(valR.xy,Kernel0Weights_RealX_ImY)+dot(valR.zw,Kernel1Weights_RealX_ImY);
            float greenChannel = dot(valG.xy,Kernel0Weights_RealX_ImY)+dot(valG.zw,Kernel1Weights_RealX_ImY);
            float blueChannel  = dot(valB.xy,Kernel0Weights_RealX_ImY)+dot(valB.zw,Kernel1Weights_RealX_ImY);
            return vec4(sqrt(vec3(redChannel,greenChannel,blueChannel)),1.0);   
            //return vec4(texture2D(ImageR, uv).xyz, 1.0);
            //return texture2D(ImageG, uv);
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
    Shader[ShaderName] = shader

    Shader[ShaderName]:sendValue('ImageR', ImageR.obj);
    Shader[ShaderName]:sendValue('ImageG', ImageG.obj);
    Shader[ShaderName]:sendValue('ImageB', ImageB.obj);
    Shader[ShaderName]:sendValue('w', w);
    Shader[ShaderName]:sendValue('h', h);

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
