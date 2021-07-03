
function Shader.GetAddTextureHDRShader(tex1, tex2)

    local pixelcode = [[
    uniform sampler2D texture1;
    uniform sampler2D texture2;
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
        vec4 texcolor = Texel(tex, texture_coords);
        vec4 texcolor1 = Texel(texture1, texture_coords);
        vec4 texcolor2 = Texel(texture2, texture_coords);

        vec4 basecolor = texcolor * color + texcolor1 + texcolor2;

        float gamma = 2.2;
        basecolor.rgb = pow(basecolor.rgb, vec3(1.0/gamma));
        float bl = 0.2126 * basecolor.x + 0.7152 * basecolor.y + 0.0722 * basecolor.z;
        if(bl > 1)
        {
            basecolor.rgb = reinhard_extended(basecolor.rgb, 1);
        }
        
        //return texcolor1 + texcolor2;

  
        return basecolor;

    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]


    local shader =   Shader.new(pixelcode, vertexcode)
    -- assert(shader:hasUniform( "texture1") and shader:hasUniform( "texture2"))
    if shader:hasUniform( "texture1") and tex1 then
        if tex1.renderid == Render.CanvasId then
            shader:send('texture1', tex1.obj);
        else
            shader:send('texture1', tex1);
        end
    end

    if shader:hasUniform( "texture2") and tex2 then
        if tex2.renderid == Render.CanvasId then
            shader:send('texture2', tex2.obj);
        else
            shader:send('texture2', tex2);
        end
    end

    return shader
end
