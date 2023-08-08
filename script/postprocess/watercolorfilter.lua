

_G.WaterColorFilterNode = {}
WaterColorFilterNode.Canvae = Canvas.new(1, 1, {format = "rgba32f", readable = true, msaa = 0, mipmaps="none"})
WaterColorFilterNode.Canvae.renderWidth = 1
WaterColorFilterNode.Canvae.renderHeight = 1
WaterColorFilterNode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

WaterColorFilterNode.Color = LColor.new(255,0,0,255);
WaterColorFilterNode.Sigma = 4

WaterColorFilterNode.Execute = function(inimage)
   
    if WaterColorFilterNode.Canvae.renderWidth ~= inimage.renderWidth  or WaterColorFilterNode.Canvae.renderHeight ~= inimage.renderHeight then
        WaterColorFilterNode.Canvae = Canvas.new(inimage.renderWidth , inimage.renderHeight , {format = "rgba32f", readable = true, msaa = 0, mipmaps="none"})
        WaterColorFilterNode.Canvae.renderWidth = inimage.renderWidth
        WaterColorFilterNode.Canvae.renderHeight = inimage.renderHeight

        WaterColorFilterNode.meshquad = _G.MeshQuad.new(WaterColorFilterNode.Canvae.renderWidth, WaterColorFilterNode.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(WaterColorFilterNode.Canvae.obj)
    love.graphics.clear()
    -- WaterColorFilterNode.meshquad:setCanvas(inimage)
    WaterColorFilterNode.meshquad.shader = Shader.GetWaterColorFilterShader(inimage, WaterColorFilterNode.Canvae.renderWidth , WaterColorFilterNode.Canvae.renderHeight,2)
    WaterColorFilterNode.meshquad:draw()
    love.graphics.setCanvas()

    -- love.graphics.setCanvas(inimage.obj)
    -- love.graphics.clear()
    -- WaterColorFilterNode.meshquad:setCanvas(WaterColorFilterNode.Canvae)
    -- WaterColorFilterNode.meshquad.shader = Shader.GetBaseShader()
    -- WaterColorFilterNode.meshquad:draw()
    -- love.graphics.setCanvas()

    return WaterColorFilterNode.Canvae
end

function Shader.GetWaterColorFilterShader(img, w, h, offset, blurnum, sigma)
    if Shader['WaterColorFilterShader'] then
        Shader['WaterColorFilterShader']:SetWaterColorFilterShader(img, w, h, offset, blurnum, sigma)
        return Shader['WaterColorFilterShader']
    end
    local pixelcode = [[
    uniform float offset;

    uniform sampler2D baseimg;
    uniform float imgw;
    uniform float imgh;

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 coords = texture_coords;
        float stepx = offset / imgw;
        float stepy = offset / imgh;

        vec3 Value1 = texture2D(baseimg, coords + vec2(stepx, stepy)).xyz;
        vec3 Value2 = texture2D(baseimg, coords + vec2(-stepx, stepy)).xyz;
        vec3 Value3 = texture2D(baseimg, coords + vec2(-stepx, -stepy)).xyz;
        vec3 Value4 = texture2D(baseimg, coords + vec2(stepx, -stepy)).xyz;

        vec3 Value5 = texture2D(baseimg, coords + vec2(0, stepy)).xyz;
        vec3 Value6 = texture2D(baseimg, coords + vec2(-stepx, 0)).xyz;
        vec3 Value7 = texture2D(baseimg, coords + vec2(0, -stepy)).xyz;
        vec3 Value8 = texture2D(baseimg, coords + vec2(stepx, 0)).xyz;
	
        vec3 ret0 = max(Value1, Value2);
        vec3 ret2 = max(Value1, Value2);
        vec3 ret3 = max(ret0, ret2);

        vec3 ret4 = max(Value5, Value6);
        vec3 ret5 = max(Value7, Value8);
        vec3 ret6 = max(ret4, ret5);
        vec4 texcolor = texture2D(baseimg, coords);
        
        texcolor.xyz = max(ret6, max(texcolor.xyz, ret3));
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
    shader.SetWaterColorFilterShader = function (obj, img, w, h, offset)
        obj:sendValue('baseimg', img.obj);
        obj:sendValue('imgw', w or img.w);
        obj:sendValue('imgh', h or img.h);

        obj:sendValue('offset', offset or 1);
    end

    shader.vscode = vertexcode
    shader.pscode = pixelcode
    Shader['WaterColorFilterShader'] = shader
    
    shader:SetWaterColorFilterShader(img, w, h, offset)
    return shader;
end