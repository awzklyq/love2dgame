
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

function Shader.GetImageBlurShader()
    if Shader.ImageBlurShader then
        return Shader.ImageBlurShader
    end
    local pixelcode = [[
    uniform float offset;
    uniform int blurnum;
    uniform float power;

    uniform sampler2D baseimg;
    uniform float imgw;
    uniform float imgh;

    uniform float startuvx;
    uniform float startuvy;

    uniform float enduvx;
    uniform float enduvy;

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 coords = texture_coords;
        vec4 texcolor = vec4(0,0,0,0);
        if(startuvx <= coords.x && enduvx >= coords.x && startuvy <= coords.y && enduvy >= coords.y)
        {
            float stepx = offset / imgw;
            float stepy = offset / imgh;
            
            int sum = 0;
            for(int i = -blurnum; i <= blurnum; i ++ )
            {
                for(int j = -blurnum; j <= blurnum; j ++ )
                {
                    texcolor += Texel(baseimg, coords + vec2(i * stepx, j * stepy));
                    sum++;
                }

            }
            
            texcolor /= sum;
            texcolor *= power;                
        }
        else
        {
            texcolor = Texel(baseimg, coords );
        }
        

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
    shader.SetImageBlurShader = function (obj, img, w, h, startuvx, startuvy, enduvx, enduvy, offset, blurnum, power)
        obj:send('baseimg', img);
        obj:send('imgw', w or img.w);
        obj:send('imgh', h or img.h);

        obj:send('startuvx', startuvx or 0);
        obj:send('startuvy', startuvy or 0);

        obj:send('enduvx', enduvx or 1);
        obj:send('enduvy', enduvy or 1);

        obj:send('offset', offset or 1);
        obj:send('blurnum', blurnum or 2);
        obj:send('power', power or 1);
    end

    shader.vscode = vertexcode
    shader.pscode = pixelcode
    Shader.ImageBlurShader = shader
    
    return shader;
end