_G.MotionVectorNode = {}

MotionVectorNode.Canvas = Canvas.new(RenderSet.screenwidth, RenderSet.screenheight, {format = "rg32f", readable = true, msaa = 0, mipmaps="none"})
-- MotionVectorNode.Canvas = Canvas.new(RenderSet.screenwidth, RenderSet.screenheight, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})

MotionVectorNode.frameToken = -1

function MotionVectorNode.BeforeExecute()
    local CurrentCanvas = love.graphics.getCanvas()

    love.graphics.setCanvas(MotionVectorNode.Canvas.obj)
    love.graphics.clear()


    love.graphics.setCanvas(CurrentCanvas)

    MotionVectorNode.frameToken = RenderSet.frameToken
end

function MotionVectorNode.Execute(mesh)
    if MotionVectorNode.frameToken ~= RenderSet.frameToken then
        return
    end
    local CurrentCanvas = love.graphics.getCanvas()

    love.graphics.setCanvas(MotionVectorNode.Canvas.obj)
    mesh.shader = Shader.GetMotionVectorShader(mesh.transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix(), mesh.PreTransform )
    Render.RenderObject(mesh)


    love.graphics.setCanvas(CurrentCanvas)
end


function Shader.GetMotionVectorShader(modelMatrix, projectionMatrix, viewMatrix, PreTransform)
    if Shader["MotionVector"] then
        Shader["MotionVector"].settMotionVectorValue(Shader["MotionVector"], modelMatrix, projectionMatrix, viewMatrix, PreTransform)
        return Shader["MotionVector"]
    end
    local pixelcode = [[
    varying vec4 CurPos;
    varying vec4 PrePos;

    // Maps standard viewport UV to screen position.
    vec2 ViewportUVToScreenPos(vec2 ViewportUV)
    {
        return vec2(2 * ViewportUV.x - 1, 1 - 2 * ViewportUV.y);
    }

    vec2 ScreenPosToViewportUV(vec2 ScreenPos)
    {
        return vec2(0.5 + 0.5 * ScreenPos.x, 0.5 - 0.5 * ScreenPos.y);
    }

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 wpos = CurPos / CurPos.w;
        vec2 uv1 = ScreenPosToViewportUV(wpos.xy);

        vec4 ppos = PrePos / PrePos.w;
        vec2 uv2 = ScreenPosToViewportUV(ppos.xy);
        return vec4(uv1.x - uv2.x, uv1.y - uv2.y, 0, 1);
    }
]]
 
    local vertexcode = [[
    uniform mat4 projectionMatrix;
    uniform mat4 modelMatrix;
    uniform mat4 viewMatrix;
    uniform mat4 PreTransform; 

    varying vec4 CurPos;
    varying vec4 PrePos;
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        vec4 wpos = projectionMatrix * viewMatrix * modelMatrix * VertexPosition;

        CurPos = wpos;

        PrePos = PreTransform * VertexPosition;
        
        return wpos;
    }
]]

-- log(vertexcode)
-- log(pixelcode)
    local shader =   Shader.new(pixelcode, vertexcode)
    shader.settMotionVectorValue = function (shader, modelMatrix, projectionMatrix, viewMatrix, PreTransform)
        shader:sendValue("PreTransform", PreTransform)

        shader:sendValue('projectionMatrix', projectionMatrix)
    
        shader:sendValue('modelMatrix', modelMatrix)
    
        shader:sendValue('viewMatrix', viewMatrix)
        
        -- local viewm = RenderSet.getUseViewMatrix()
        -- local projectm = RenderSet.getUseProjectMatrix()
        -- if shader:hasUniform("projectionViewMatrix") then
        --     local mat = Matrix3D.copy(projectm);
        --     mat:mulRight(Matrix3D.transpose(Matrix3D.transpose(viewm)))--Todo..
        --     shader:send("projectionViewMatrix", mat)
        -- end  
    end
    
    shader.settMotionVectorValue(shader, PreTransform)

    Shader["MotionVector"] = shader; 
    return shader
end


app.resizeWindow(function(w, h)
    MotionVectorNode.Canvas = Canvas.new(RenderSet.screenwidth, RenderSet.screenheight, {format = "rg32f", readable = true, msaa = 0, mipmaps="none"})
end)
