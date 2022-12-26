_G.VelocityBuffNode = {}
local DynamicMeshs = {}
local PreVelocityMats = {}
VelocityBuffNode.InitDynamicMeshs = function(Mesh)
    DynamicMeshs = {}
    PreVelocityMats = {}
end

VelocityBuffNode.GatherDynamicMesh = function(Mesh)
    DynamicMeshs[#DynamicMeshs + 1] = Mesh
    PreVelocityMats[#PreVelocityMats + 1] = Matrix3D.copy(Mesh.PreTransform)
end

VelocityBuffNode.VelocityBuff = Canvas.new(1, 1, {format = "rg16f", readable = true, msaa = 0, mipmaps="none"})
VelocityBuffNode.VelocityBuff.renderWidth = 1
VelocityBuffNode.VelocityBuff.renderHeight = 1

local normal_depth_buffer = Canvas.new(1, 1, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})
normal_depth_buffer.renderWidth = 1
normal_depth_buffer.renderHeight = 1

VelocityBuffNode.Execute = function(renderWidth, renderHeight)
   
    if VelocityBuffNode.VelocityBuff.renderWidth ~= renderWidth  or VelocityBuffNode.VelocityBuff.renderHeight ~= renderHeight then
        VelocityBuffNode.VelocityBuff = Canvas.new(renderWidth , renderHeight , {format = "rg16f", readable = true, msaa = 0, mipmaps="none"})
        VelocityBuffNode.VelocityBuff.renderWidth = renderWidth
        VelocityBuffNode.VelocityBuff.renderHeight = renderHeight

        normal_depth_buffer = Canvas.new(renderWidth, renderHeight, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})
        normal_depth_buffer.renderWidth = renderWidth
        normal_depth_buffer.renderHeight = renderHeight

        VelocityBuffNode.meshquad = _G.MeshQuad.new(VelocityBuffNode.VelocityBuff.renderWidth, VelocityBuffNode.VelocityBuff.renderHeight , LColor.new(255, 255, 255, 255))
    end

    love.graphics.setMeshCullMode("front")
    love.graphics.setDepthMode("less", true)
    love.graphics.setCanvas({VelocityBuffNode.VelocityBuff.obj, depthstencil = normal_depth_buffer.obj})

    love.graphics.setCanvas(VelocityBuffNode.VelocityBuff.obj)
    love.graphics.clear(0,0,0,1)

    for i = 1, #DynamicMeshs do
        local mat = RenderSet.getUseProjectMatrix() * RenderSet.getUseViewMatrix() * DynamicMeshs[i].transform3d
        DynamicMeshs[i].shader = Shader.GetVelocityBuffShader(mat, PreVelocityMats[i])
        -- DynamicMeshs[i]:draw()
        Render.RenderObject(DynamicMeshs[i])
    end

    love.graphics.setCanvas()
    love.graphics.setMeshCullMode("none")

end
VelocityBuffNode.uVelocityScale = 1.0;
local PixelFormat = "rgba8"
VelocityBuffNode.Canvae = Canvas.new(1, 1, {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
VelocityBuffNode.Canvae.renderWidth = 1
VelocityBuffNode.Canvae.renderHeight = 1
VelocityBuffNode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))
VelocityBuffNode.ExecuteBlur = function(Canva1, w, h)
    if VelocityBuffNode.Canvae.renderWidth ~= w  or VelocityBuffNode.Canvae.renderHeight ~= h then
        VelocityBuffNode.Canvae = Canvas.new(w , h , {format = PixelFormat, readable = true, msaa = 0, mipmaps="none"})
        VelocityBuffNode.Canvae.renderWidth = w
        VelocityBuffNode.Canvae.renderHeight = h

        VelocityBuffNode.meshquad = _G.MeshQuad.new(VelocityBuffNode.Canvae.renderWidth, VelocityBuffNode.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(VelocityBuffNode.Canvae.obj)
    love.graphics.clear()
    VelocityBuffNode.meshquad:setCanvas(Canva1)
    VelocityBuffNode.meshquad.shader = Shader.GetVelocityBlurShader(w, h)
    VelocityBuffNode.meshquad:draw()
    love.graphics.setCanvas()
    return VelocityBuffNode.Canvae
end

function Shader.GetVelocityBuffShader(ModelViewProjection, PrevModelViewProjection)
    if Shader["VelocityBuff"] then
        Shader["VelocityBuff"].setValue(Shader["VelocityBuff"], ModelViewProjection, PrevModelViewProjection)
        return Shader["VelocityBuff"]
    end
    local pixelcode = [[
    varying vec4 vPosition;
    varying vec4 vPrevPosition;
     
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 oVelocity = vec4(0.0, 0.0, 0.0, 1.0);
        vec2 a = (vPosition.xy / vPosition.w) * 0.5 + 0.5;
        vec2 b = (vPrevPosition.xy / vPrevPosition.w) * 0.5 + 0.5;
        oVelocity.xy = (a - b);

        oVelocity.x = pow(oVelocity.x, 3.0);
        oVelocity.y = pow(oVelocity.y, 3.0);
       return oVelocity;
    }
]]
 
    local vertexcode = [[ 
    uniform mat4 uModelViewProjectionMat;
    uniform mat4 uPrevModelViewProjectionMat;

    varying vec4 vPosition;
    varying vec4 vPrevPosition;

    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        vPosition = uModelViewProjectionMat * VertexPosition;
        vPrevPosition = uPrevModelViewProjectionMat * VertexPosition;
        return uModelViewProjectionMat * VertexPosition; //vPosition
    }
]]

-- log(vertexcode)
-- log(pixelcode)
    local shader =   Shader.new(pixelcode, vertexcode)
    Shader["VelocityBuff"] = shader;
    shader.setValue = function (shader, ModelViewProjection, PrevModelViewProjection)
        if shader:hasUniform("uModelViewProjectionMat") then
            local mat = Matrix3D.copy(ModelViewProjection);
            shader:send("uModelViewProjectionMat", mat)
        end

        if shader:hasUniform("uPrevModelViewProjectionMat") then
            local mat = Matrix3D.copy(PrevModelViewProjection);
            shader:send("uPrevModelViewProjectionMat", mat)
        end
        
    end
    
    shader.setValue(shader, ModelViewProjection, PrevModelViewProjection)
    return shader
end


function Shader.GetVelocityBlurShader(w, h)
    if Shader["VelocityBlur"] then
        Shader["VelocityBlur"].setValue(Shader["VelocityBlur"], w, h)
        return Shader["VelocityBlur"]
    end
    local pixelcode = [[
    uniform float w;
    uniform float h;
    uniform float CurrentFPS;

    uniform sampler2D uTexInput; // texture we're blurring
    uniform sampler2D uTexVelocity; // velocity buffer

    varying vec2 vTexCoord2;

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 texelSize = vec2(1.0 / w, 1.0 / h);

        vec2 velocity = texture2D(uTexVelocity, texture_coords).rg;
        vec4 BaseColor =  texture2D(tex, vTexCoord2);

        if (length(velocity) <= 0.000001)
        {
            return BaseColor;
        }

        velocity.x = pow(velocity.x, 1.0 / 3.0);
        velocity.y = pow(velocity.y, 1.0 / 3.0);
        velocity = velocity * 2.0 - 1.0;

       
        float TargetFps = 120.0;
        float uVelocityScale = CurrentFPS / TargetFps;

        //velocity *= uVelocityScale;

        float speed = length(velocity) / length(texelSize);

        float MAX_SAMPLES = 16;
        float nSamples =  clamp(speed, 1, MAX_SAMPLES);

        float velocityscale = clamp(speed, 4, 8);
        for (int i = 1; i < nSamples; ++i)
        {
            vec2 offset = texelSize * velocityscale * (float(i) / float(nSamples - 1) - 0.5);
            BaseColor.xyz += texture2D(tex, vTexCoord2 + offset).xyz;
        }

        BaseColor.xyz /= nSamples;

        return BaseColor;
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

-- log(vertexcode)
-- log(pixelcode)
    local shader =   Shader.new(pixelcode, vertexcode)
    Shader["VelocityBlur"] = shader;
    shader.setValue = function (shader, w, h)
        shader:sendValue("w", w)
        shader:sendValue("h", h)
        shader:sendValue("CurrentFPS", love.timer.getFPS())
        shader:sendValue("uTexVelocity", VelocityBuffNode.VelocityBuff.obj)        
    end
    
    shader.setValue(shader, w, h, CurrentFPS)
    return shader
end