
_G.SimpleSSGINode = {}
local CanvasSize = 64
SimpleSSGINode.ForwardCanvae = Canvas.new(CanvasSize, CanvasSize, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
SimpleSSGINode.ForwardCanvae.renderWidth = CanvasSize
SimpleSSGINode.ForwardCanvae.renderHeight = CanvasSize
SimpleSSGINode.ForwardMeshQuad = _G.MeshQuad.new(CanvasSize, CanvasSize, LColor.new(255, 255, 255, 255))

SimpleSSGINode.Canvas = Canvas.new(1, 1, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
SimpleSSGINode.Canvas.renderWidth = 1
SimpleSSGINode.Canvas.renderHeight = 1
SimpleSSGINode.MeshQuad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

SimpleSSGINode.LineWidth = 4;
SimpleSSGINode.Color = LColor.new(255,0,0,255);
SimpleSSGINode.Threshold = 1
SimpleSSGINode.Execute = function(Canva1, ScreenNormalMap, ScreenDepthMap)
   
    if SimpleSSGINode.Canvas.renderWidth ~= Canva1.renderWidth  or SimpleSSGINode.Canvas.renderHeight ~= Canva1.renderHeight then
        SimpleSSGINode.Canvas = Canvas.new(Canva1.renderWidth , Canva1.renderHeight , {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
        SimpleSSGINode.Canvas.renderWidth = Canva1.renderWidth
        SimpleSSGINode.Canvas.renderHeight = Canva1.renderHeight

        SimpleSSGINode.MeshQuad = _G.MeshQuad.new(Canva1.renderWidth, Canva1.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(SimpleSSGINode.ForwardCanvae.obj)
    love.graphics.clear()
    SimpleSSGINode.ForwardMeshQuad:setCanvas(Canva1)
    SimpleSSGINode.ForwardMeshQuad:draw()
    love.graphics.setCanvas()

    love.graphics.setCanvas(SimpleSSGINode.Canvas.obj)
    love.graphics.clear()
    SimpleSSGINode.MeshQuad:setCanvas(Canva1)
    SimpleSSGINode.MeshQuad.shader = Shader.GetSimpleSSGIShader(ScreenNormalMap, ScreenDepthMap, HBAONode.Canvae.renderWidth , HBAONode.Canvae.renderHeight )
    SimpleSSGINode.MeshQuad:draw()
    love.graphics.setCanvas()

    return SimpleSSGINode.Canvas
end

function Shader.GetSimpleSSGIShader(ScreenNormalMap, ScreenDepthMap, sw, sh)
    if Shader["shader_SimpleSSGI"] then
        Shader["shader_SimpleSSGI"].SetSimpleSSGIValue(Shader["shader_SimpleSSGI"],  ScreenNormalMap, ScreenDepthMap, sw, sh)
        return Shader["shader_SimpleSSGI"]
    end
    local pixelcode = [[
    uniform sampler2D ScreeNormalMap;
    uniform sampler2D v_ScreenDepthMap;
    uniform sampler2D ScreeForwardMap;
    uniform float CanvasSize;

    uniform mat4 projectionViewMatrix;

    uniform mat4 Inverse_ProjectviewMatrix;

    uniform float viewsizew;
    uniform float viewsizeh;
    uniform float HBAOLenght;
    uniform float HBAOBaseAngle;
    uniform float depthlimit;
    // Maps standard viewport UV to screen position.
    vec2 ViewportUVToScreenPos(vec2 ViewportUV)
    {
        return vec2(2 * ViewportUV.x - 1, 1 - 2 * ViewportUV.y);
    }

    vec2 ScreenPosToViewportUV(vec2 ScreenPos)
    {
        return vec2(0.5 + 0.5 * ScreenPos.x, 0.5 - 0.5 * ScreenPos.y);
    }
  

    float DecodeDepth(sampler2D DepthMap, vec2 uv)
    {
        return texture2D(DepthMap, uv).r;
    }

    vec3 normal_from_depth(sampler2D tex, vec2 texcoords) {
        // Delta coordinate of 1 pixel: 0.03125 = 1 (pixel) / 32 (pixels)
        vec2 offset1 = vec2(0.0, 1.0 / CanvasSize);
        vec2 offset2 = vec2(1.0 / CanvasSize, 0.0);
        
        // Fetch depth from depth buffer
        float depth = DecodeDepth(v_ScreenDepthMap, texcoords);
        float depth1 = DecodeDepth(v_ScreenDepthMap, texcoords + offset1);
        float depth2 = DecodeDepth(v_ScreenDepthMap, texcoords + offset2);
        
        highp vec3 p1 = vec3(offset1, depth1 - depth);
        highp vec3 p2 = vec3(offset2, depth2 - depth);
        
        // Calculate normal
        highp vec3 normal = cross(p1, p2);
        normal.z = -normal.z;
        
        return normalize(normal);
    }

    
vec3 normal_from_pixels(sampler2D tex, vec2 texcoords1, vec2 texcoords2, out float dist) 
{
    // Fetch depth from depth buffer
    float depth1 = DecodeDepth(tex, texcoords1);
    float depth2 = DecodeDepth(v_ScreenDepthMap, texcoords2);
    
    // Calculate normal
    highp vec3 normal = vec3(texcoords2 - texcoords1, depth2 - depth1);
    normal.z = -normal.z;
    
    // Calculate distance between texcoords
    dist = length(normal);
    
    return normalize(normal);
}

vec3 Calculate_GI(vec3 pixel_normal, vec2 coord, vec2 vScreenPos)
{
    vec3 light_color;
    vec3 pixel_to_light_normal;
    vec3 light_normal, light_to_pixel_normal;
    float dist;
    vec3 gi = vec3(0.0);
    
    // Calculate normal from the pixel to current pixel
    light_to_pixel_normal = normal_from_pixels(v_ScreenDepthMap, coord, vScreenPos, dist);
    // Calculate normal from current pixel to the pixel
    pixel_to_light_normal = -light_to_pixel_normal;
    
    // Get the pixel color
    light_color = texture2D(ScreeForwardMap, coord).rgb;
    // Calculate normal for the pixel
    light_normal = normal_from_depth(v_ScreenDepthMap, coord);
    // Calculate GI
    gi += light_color * max(0.0, dot(pixel_normal, pixel_to_light_normal)) / dist; //;
    return gi;
}
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        const int GRID_COUNT = 32;
        vec3 pixel_normal;
        vec3 gi;
        
        // Calculate normal for current pixel
        pixel_normal = normal_from_depth(v_ScreenDepthMap, texture_coords);
        // Prepare to accumulate GI
        gi = vec3(0.0);
        
        // Accumulate GI from some uniform samples
        for (int y = 0; y < GRID_COUNT; ++y) {
            for (int x = 0; x < GRID_COUNT; ++x) {
                gi += Calculate_GI(pixel_normal, vec2((float(x) + 0.5) / float(GRID_COUNT), (float(y) + 0.5) / float(GRID_COUNT)), texture_coords);
            }
        }
        
        // Make GI not too strong
        gi /= float(GRID_COUNT * GRID_COUNT / 3);
        
        vec4 BaseColor = texture2D(tex, texture_coords);
        return vec4(BaseColor.rgb + gi, BaseColor.a);

      //return vec4(gi, 1.0);
    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]

-- log(vertexcode)
-- log(pixelcode)
    local shader =   Shader.new(pixelcode, vertexcode)
    Shader["shader_SimpleSSGI"] = shader;
    shader.SetSimpleSSGIValue = function (shader, ScreenNormalMap, ScreenDepthMap, sw, sh)
        shader:sendValue("ScreeNnormalMap", ScreenNormalMap.obj)

        shader:sendValue("v_ScreenDepthMap", ScreenDepthMap.obj)

        shader:sendValue("ScreeForwardMap", SimpleSSGINode.ForwardCanvae.obj)

        shader:sendValue("CanvasSize", CanvasSize)

        local viewm = RenderSet.getUseViewMatrix()
        local projectm = RenderSet.getUseProjectMatrix()
        if shader:hasUniform("projectionViewMatrix") then
            local mat = Matrix3D.copy(projectm);
            mat:mulRight(Matrix3D.transpose(Matrix3D.transpose(viewm)))--Todo..
            shader:send("projectionViewMatrix", mat)
        end

        if shader:hasUniform("viewsizew") then
            shader:send("viewsizew", sw)
        end

        if shader:hasUniform("viewsizeh") then
            shader:send("viewsizeh", sh)
        end

        if shader:hasUniform("Inverse_ProjectviewMatrix") then
            local mat = Matrix3D.copy(projectm);
            mat:mulRight(Matrix3D.transpose(Matrix3D.transpose(viewm)))--Todo..
            shader:send("Inverse_ProjectviewMatrix",  Matrix3D.inverse(mat))
        end

        if shader:hasUniform("HBAOLenght") then
            shader:send("HBAOLenght", RenderSet.getHBAORayMatchLength())
        end

        if shader:hasUniform("HBAOBaseAngle") then
            shader:send("HBAOBaseAngle", RenderSet.getHBAOBaseAngle())
        end

        if shader:hasUniform("depthlimit") then
            shader:send("depthlimit", RenderSet.getSSAODepthLimit())
        end
        
    end
    
    shader.SetSimpleSSGIValue(shader, ScreenNormalMap, ScreenDepthMap, sw, sh)
    return shader
end