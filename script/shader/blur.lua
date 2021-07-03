
function Shader.GetWBlurShader(w, offset, blurnum, power)
    if not offset then offset = 1 end
    if not blurnum then offset = 5 end
    if not power then power = 1 end
    local pixelcode = [[
    uniform float w;
    uniform float offset;
    uniform int blurnum;
    uniform float power;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float step = offset / w;
        vec2 coords = texture_coords;
        vec4 texcolor = Texel(tex, texture_coords);
        for(int i = -blurnum; i <= blurnum; i ++ )
        {
            coords.x = texture_coords.x + i * step;
            texcolor += Texel(tex, coords);

        }
         texcolor /= blurnum ;

        return texcolor * color * power;
    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]
    local shader = Shader.new(pixelcode, vertexcode);
    assert(shader:hasUniform( "w") and shader:hasUniform( "offset") and shader:hasUniform( "blurnum") and shader:hasUniform( "power"))
    shader:send('w', w);
    shader:send('offset', offset);
    shader:send('blurnum', blurnum);
    shader:send('power', power);
    return shader;
end


function Shader.GetHBlurShader(h, offset, blurnum, power)
    if not offset then offset = 1 end
    if not blurnum then offset = 5 end
    if not power then power = 1 end
    local pixelcode = [[
    uniform float h;
    uniform float offset;
    uniform int blurnum;
    uniform float power;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float step = offset / h;
        vec2 coords = texture_coords;
        vec4 texcolor = Texel(tex, texture_coords);
        for(int i = -blurnum; i <= blurnum; i ++ )
        {
            coords.y = texture_coords.y + i * step;
            texcolor += Texel(tex, coords);

        }
         texcolor /= blurnum ;

        return texcolor * color * power;
    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]
    local shader = Shader.new(pixelcode, vertexcode);
    assert(shader:hasUniform( "h") and shader:hasUniform( "offset") and shader:hasUniform( "blurnum") and shader:hasUniform( "power"))
    shader:send('h', h);
    shader:send('offset', offset);
    shader:send('blurnum', blurnum);
    shader:send('power', power);
    return shader;
end