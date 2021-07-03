
function Shader.GetFXAAShader(w, h)
    if Shader["taa"] then
        Shader["taa"]:send('w', w)
        Shader["taa"]:send('h', h)
        return Shader["taa"]
    end
    local pixelcode = [[
    uniform float w;
    uniform float h;

    float luma(vec4 color)
    {
        return dot(color.rgb, vec3(0.299, 0.587, 0.114));
    }

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float offsetw = 1 / w;
        float offseth = 1 / h;
        vec4 nwolor = Texel(tex, vec2(texture_coords.x - offsetw, texture_coords.y - offseth));
        vec4 neolor = Texel(tex, vec2(texture_coords.x + offsetw, texture_coords.y - offseth));

        vec4 swolor = Texel(tex, vec2(texture_coords.x - offsetw, texture_coords.y + offseth));
        vec4 seolor = Texel(tex, vec2(texture_coords.x + offsetw, texture_coords.y + offseth));

        float nwluma = luma(nwolor);
        float neluma = luma(neolor);

        float swluma = luma(swolor);
        float seluma = luma(seolor);

        vec4 texcolor = Texel(tex, texture_coords);

        float M = luma(texcolor);
        
        float MaxLuma = max(max(nwluma, neluma), max(swluma, seluma));
        float Contrast = max(MaxLuma, M) - min(min(min(nwluma, neluma), min(swluma, seluma)), M);
        float MinThreshold = 0.05;
        float Threshold = 0.25;
       // float fxaaConsoleEdgeThreshold = 0.166f;
       // float fxaaConsoleEdgeThresholdMin = 0.0833;

        if(Contrast < max(MinThreshold, MaxLuma * Threshold))
            return texcolor * color;

        vec2 Dir = vec2((swluma + seluma) - (nwluma + neluma), (nwluma + swluma) - (neluma + seluma));
        Dir.xy = normalize(Dir.xy);

        vec4 P0 = Texel(tex, texture_coords + Dir * (0.5/w, 0.5/h));
        vec4 P1 = Texel(tex, texture_coords - Dir * (0.5/w, 0.5/h));

        float Sharpness = 8;
        float MinDir = min(abs(Dir.x), abs(Dir.y)) * Sharpness;
        vec2 NewDir = vec2(clamp(Dir.x / MinDir, -2, 2), clamp(Dir.y / MinDir, -2, 2));
        vec4 Q0 = Texel(tex, texture_coords + NewDir * (2/w, 2/h));
        vec4 Q1 = Texel(tex, texture_coords - NewDir * (2/w, 2/h));

        vec4 R0 = (P0 + P1 + Q0 + Q1) * 0.25;
        vec4 R1 = (P0 + P1) * 0.5;
        if(luma(R0) < min(min(nwluma, neluma), min(swluma, seluma)) || luma(R0) > max(max(nwluma, neluma), max(swluma, seluma)))
            return R1;
        else
            return R0;
    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]

    local shader =   Shader.new(pixelcode, vertexcode)
    assert(shader:hasUniform( "w") and shader:hasUniform( "h"))
    shader:send('w', w)
    shader:send('h', h)
    Shader["taa"] = shader;
    return shader
end