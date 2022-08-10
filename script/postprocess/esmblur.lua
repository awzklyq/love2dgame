
_G.ESMBlurNode = {}
ESMBlurNode.Canvae = Canvas.new(1, 1, {format = "rgba32f", readable = true, msaa = 0, mipmaps="none"})
ESMBlurNode.Canvae.renderWidth = 1
ESMBlurNode.Canvae.renderHeight = 1
ESMBlurNode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

ESMBlurNode.Color = LColor.new(255,0,0,255);
ESMBlurNode.Sigma = 4

ESMBlurNode.Execute = function(screendepthmap)
   
    if ESMBlurNode.Canvae.renderWidth ~= screendepthmap.renderWidth  or ESMBlurNode.Canvae.renderHeight ~= screendepthmap.renderHeight then
        ESMBlurNode.Canvae = Canvas.new(screendepthmap.renderWidth , screendepthmap.renderHeight , {format = "rgba32f", readable = true, msaa = 0, mipmaps="none"})
        ESMBlurNode.Canvae.renderWidth = screendepthmap.renderWidth
        ESMBlurNode.Canvae.renderHeight = screendepthmap.renderHeight

        ESMBlurNode.meshquad = _G.MeshQuad.new(ESMBlurNode.Canvae.renderWidth, ESMBlurNode.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(ESMBlurNode.Canvae.obj)
    love.graphics.clear()
    -- ESMBlurNode.meshquad:setCanvas(screendepthmap)
    ESMBlurNode.meshquad.shader = Shader.GetESMBlurShader(screendepthmap, ESMBlurNode.Canvae.renderWidth , ESMBlurNode.Canvae.renderHeight,1,5,ESMBlurNode.Sigma)
    ESMBlurNode.meshquad:draw()
    love.graphics.setCanvas()

    love.graphics.setCanvas(screendepthmap.obj)
    love.graphics.clear()
    ESMBlurNode.meshquad:setCanvas(ESMBlurNode.Canvae)
    ESMBlurNode.meshquad.shader = Shader.GetBaseShader()
    ESMBlurNode.meshquad:draw()
    love.graphics.setCanvas()

    return ESMBlurNode.Canvae
end

function Shader.GetESMBlurShader(img, w, h, offset, blurnum, sigma)
    if Shader['ESMBlurShader'] then
        Shader['ESMBlurShader']:SetESMBlurShader(img, w, h, offset, blurnum, sigma)
        return Shader['ESMBlurShader']
    end
    local pixelcode = [[
    uniform float offset;
    uniform int blurnum;
    uniform float sigma;

    uniform sampler2D baseimg;
    uniform float imgw;
    uniform float imgh;

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 coords = texture_coords;
        float stepx = offset / imgw;
        float stepy = offset / imgh;

        float pi = 3.14159;
        vec3 increamentalGaussian;
        increamentalGaussian.x = 1.0/(sqrt(2.0*pi)*sigma);
        increamentalGaussian.y= exp(-0.5/(sigma*sigma));
        increamentalGaussian.z = increamentalGaussian.y * increamentalGaussian.y;
        
        vec4 avgValue = vec4(0.0);
        float coefficientSum = 0.0;
        
        avgValue += texture2D(baseimg, coords)*increamentalGaussian.x;
        coefficientSum += increamentalGaussian.x;
        increamentalGaussian.xy *= increamentalGaussian.yz;
        
        for(int i = 1; i <= blurnum; i ++ )
        {
            for(int j = 1; j <= blurnum; j ++ )
            {
                avgValue += texture2D(baseimg, coords + vec2(i * stepx, j * stepy)) * increamentalGaussian.x;
                avgValue += texture2D(baseimg, coords + vec2(i * -stepx, j * stepy)) * increamentalGaussian.x;
                avgValue += texture2D(baseimg, coords + vec2(i * -stepx, j * -stepy)) * increamentalGaussian.x;
                avgValue += texture2D(baseimg, coords + vec2(i * stepx, j * -stepy)) * increamentalGaussian.x;

                coefficientSum+= 4.0*increamentalGaussian.x;
                increamentalGaussian.xy *= increamentalGaussian.yz;
            }

        }
	
        vec4 texcolor = avgValue/coefficientSum;
        
        texcolor.g = texture2D(baseimg, coords).r;
        return texcolor;
    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]
    local shader = Shader.new(pixelcode, vertexcode);
    shader.SetESMBlurShader = function (obj, img, w, h, offset, blurnum, sigma)
        obj:sendValue('baseimg', img.obj);
        obj:sendValue('imgw', w or img.w);
        obj:sendValue('imgh', h or img.h);

        obj:sendValue('offset', offset or 1);
        obj:sendValue('blurnum', blurnum or 2);
        obj:sendValue('sigma', sigma or 4);
    end

    shader.vscode = vertexcode
    shader.pscode = pixelcode
    Shader['ESMBlurShader'] = shader
    
    shader:SetESMBlurShader(img, w, h, offset, blurnum, sigma)
    return shader;
end