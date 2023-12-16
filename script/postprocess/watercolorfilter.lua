

_G.WaterColorFilterNode = {}
WaterColorFilterNode.Canvae = Canvas.new(1, 1, {format = "rgba32f", readable = true, msaa = 0, mipmaps="none"})
WaterColorFilterNode.Canvae.renderWidth = 1
WaterColorFilterNode.Canvae.renderHeight = 1
WaterColorFilterNode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

WaterColorFilterNode.Color = LColor.new(255,0,0,255);
WaterColorFilterNode.Offset = 2

WaterColorFilterNode.Type = 1

WaterColorFilterNode.Scale1 = 0.8
WaterColorFilterNode.Scale2 = 0.9
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
    WaterColorFilterNode.meshquad.shader = Shader["GetWaterColorFilterShader" .. tostring(WaterColorFilterNode.Type)](inimage, WaterColorFilterNode.Canvae.renderWidth , WaterColorFilterNode.Canvae.renderHeight,WaterColorFilterNode.Offset, WaterColorFilterNode.Scale1, WaterColorFilterNode.Scale2)
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

function Shader.GetWaterColorFilterShader1(img, w, h, offset)
    if Shader['WaterColorFilterShader'] then
        Shader['WaterColorFilterShader']:SetWaterColorFilterShader(img, w, h, offset)
        return Shader['WaterColorFilterShader']
    end
    local pixelcode = [[
    uniform float offset;

    uniform sampler2D baseimg;
    uniform float imgw;
    uniform float imgh;

    vec2 Circle(float Start, float Points, float Point) 
    {
        float Rad = (3.141592 * 2.0 * (1.0 / Points)) * (Point + Start);
        return vec2(sin(Rad), cos(Rad));
    }


    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 coords = texture_coords;
        float stepx = offset / imgw;
        float stepy = offset / imgh;

        vec2 invwh = vec2(stepx, stepy);
        float Start = 2.0/8.0;
	    float Scale = offset;

        vec3 Value1 = texture2D(baseimg, coords +  Circle(Start, 8.0, 1.0) * invwh).xyz;
        vec3 Value2 = texture2D(baseimg, coords +  Circle(Start, 8.0, 2.0) * invwh).xyz;
        vec3 Value3 = texture2D(baseimg, coords +  Circle(Start, 8.0, 3.0) * invwh).xyz;
        vec3 Value4 = texture2D(baseimg, coords +  Circle(Start, 8.0, 4.0) * invwh).xyz;

        vec3 Value5 = texture2D(baseimg, coords +  Circle(Start, 8.0, 5.0) * invwh).xyz;
        vec3 Value6 = texture2D(baseimg, coords +  Circle(Start, 8.0, 6.0) * invwh).xyz;
        vec3 Value7 = texture2D(baseimg, coords +  Circle(Start, 8.0, 7.0) * invwh).xyz;
        vec3 Value8 = texture2D(baseimg, coords +  Circle(Start, 8.0, 8.0) * invwh).xyz;
	
        vec3 ret0 = max(Value1, Value2);
        vec3 ret2 = max(Value3, Value4);
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



function Shader.GetWaterColorFilterShader2(img, w, h, offset, Scale1, Scale2)
    if Shader['WaterColorFilterShader2_Scale1' .. tostring(Scale1) .. '_Scale2'..tostring(Scale2)] then
        Shader['WaterColorFilterShader2_Scale1'.. tostring(Scale1) .. '_Scale2'..tostring(Scale2)]:SetWaterColorFilterShader(img, w, h, offset, Scale1, Scale2)
        return Shader['WaterColorFilterShader2_Scale1'.. tostring(Scale1) .. '_Scale2'..tostring(Scale2)]
    end
    local pixelcode = [[
    uniform float offset;
    uniform float Scale1;
    uniform float Scale2;
    uniform sampler2D baseimg;
    uniform float imgw;
    uniform float imgh;]]

    pixelcode = pixelcode .. _G.ShaderFunction.Luminance

    pixelcode = pixelcode .. [[
    vec2 Circle(float Start, float Points, float Point) 
    {
        float Rad = (3.141592 * 2.0 * (1.0 / Points)) * (Point + Start);
        return vec2(sin(Rad), cos(Rad));
    }


    vec4 MaxW(vec4 v1, vec4 v2)
    {
        if (v1.w > v2.w)
            return v1;
        else
            return v2;

    }
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 coords = texture_coords;
        float stepx = offset / imgw;
        float stepy = offset / imgh;

        vec2 invwh = vec2(stepx, stepy);
        float Start = 2.0/8.0;
	    float Scale = offset;

        vec3 Value1 = texture2D(baseimg, coords + vec2(stepx, stepy)).xyz;
        vec3 Value2 = texture2D(baseimg, coords + vec2(-stepx, stepy)).xyz;
        vec3 Value3 = texture2D(baseimg, coords + vec2(-stepx, -stepy)).xyz;
        vec3 Value4 = texture2D(baseimg, coords + vec2(stepx, -stepy)).xyz;

        vec3 Value5 = texture2D(baseimg, coords + vec2(0, stepy * 2)).xyz;
        vec3 Value6 = texture2D(baseimg, coords + vec2(-stepx * 2, 0)).xyz;
        vec3 Value7 = texture2D(baseimg, coords + vec2(0, -stepy * 2)).xyz;
        vec3 Value8 = texture2D(baseimg, coords + vec2(stepx * 2, 0)).xyz;
	
        vec4 w1 = vec4(Value1, Luminance(Value1) * Scale1);
        vec4 w2 = vec4(Value2, Luminance(Value2) * Scale1);
        vec4 w3 = vec4(Value3, Luminance(Value3) * Scale1);
        vec4 w4 = vec4(Value4, Luminance(Value4) * Scale1);

        vec4 w5 = vec4(Value5, Luminance(Value5) * Scale2);
        vec4 w6 = vec4(Value6, Luminance(Value6) * Scale2);
        vec4 w7 = vec4(Value7, Luminance(Value7) * Scale2);
        vec4 w8 = vec4(Value8, Luminance(Value8) * Scale2);

        

        vec4 ret0 = MaxW(w1, w2);
        vec4 ret2 = MaxW(w3, w4);
        vec4 ret3 = MaxW(ret0, ret2);

        vec4 ret4 = MaxW(w5, w6);
        vec4 ret5 = MaxW(w7, w8);
        vec4 ret6 = MaxW(ret4, ret5);
        vec4 texcolor = texture2D(baseimg, coords);
        texcolor.w = Luminance(texcolor.rgb);
        texcolor = MaxW(texcolor, MaxW(ret6, ret3));
        texcolor.a = 1.0;
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
    shader.SetWaterColorFilterShader = function (obj, img, w, h, offset, Scale1, Scale2)
        obj:sendValue('baseimg', img.obj);
        obj:sendValue('imgw', w or img.w);
        obj:sendValue('imgh', h or img.h);
        obj:sendValue('Scale2', Scale2);
        obj:sendValue('Scale1', Scale1);

        obj:sendValue('offset', offset or 1);
    end

    shader.vscode = vertexcode
    shader.pscode = pixelcode
    Shader['WaterColorFilterShader2_Scale1'.. tostring(Scale1) .. '_Scale2'..tostring(Scale2)] = shader
    
    shader:SetWaterColorFilterShader(img, w, h, offset)
    return shader;
end