_G.Scene3D = {}

function Scene3D.new()
    local scene = setmetatable({}, {__index = Scene3D});

    scene.renderid = Render.Scene3DId

    scene.nodes = {}

    scene.lights = {}

    scene.bgColor = LColor.new(0,0,0,0)

    scene.screenwidth = love.graphics.getPixelWidth()
    scene.screenheight = love.graphics.getPixelHeight()

    scene.frustum = Frustum.new()

    scene:reseizeScreen(scene.screenwidth, scene.screenheight)
    scene.needFXAA = false
    return scene
end

function Scene3D:getDepthCanvas()
    return self.canvasdepth
end

function Scene3D:addLight(light)
    local node = SceneNode3D.new()
    node:bindDirectionLight(light)
    table.insert(self.lights, node)
    return node
end

function Scene3D:removeLight(light)
    for i = 1, #self.lights do
        if self.lights[i].directionLight == light then
            self.lights[i].directionLight = nil
            table.remove(self.lights, i)
            break
        end
    end
end

function Scene3D:addMesh(mesh)
    assert(mesh.renderid and mesh.renderid == Render.Mesh3DId)
    local node = SceneNode3D.new()
    node:bindMesh(mesh)
    mesh.node = node -- warning..
    
    table.insert(self.nodes, node)
    return node
end

function Scene3D:removeMesh(mesh)
    assert(mesh.renderid and mesh.renderid == Render.Mesh3DId)
    if not mesh.node then
        return
    end

    for i = 1, #self.nodes do
        if self.nodes[i] == mesh.node then
            mesh.node = nil
            table.remove(self.nodes, i)
            break
        end
    end
end

function Scene3D:update(e)
    if self.screenwidth ~= RenderSet.screenwidth or self.screenheight ~= RenderSet.screenheight then
        self.screenwidth = RenderSet.screenwidth-- love.graphics.getWidth() * 2
        self.screenheight = RenderSet.screenheight--love.graphics.getHeight() * 2
        self:reseizeScreen(self.screenwidth, self.screenheight)
    end

    self.frustum:buildFromViewAndProject(RenderSet.getDefaultViewMatrix(), RenderSet.getDefaultProjectMatrix())
end

function Scene3D:reseizeScreen(w, h)
    self.canvascolor = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
    self.canvascolor.renderWidth = w
    self.canvascolor.renderHeight = h

    self.canvasPostprocess = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
    self.canvasPostprocess.renderWidth = w
    self.canvasPostprocess.renderHeight = h
    
    self.canvasdepth = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
    self.canvasdepth.renderWidth = w
    self.canvasdepth.renderHeight = h

    self.canvasnormal = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
    self.canvasnormal.renderWidth = w
    self.canvasnormal.renderHeight = h

    self.normal_depth_buffer = Canvas.new(w, h, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})
    self.normal_depth_buffer.renderWidth = w
    self.normal_depth_buffer.renderHeight = h

    self.depthmap_depth_buffer = Canvas.new(w, h, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})
    self.depthmap_depth_buffer.renderWidth = w
    self.depthmap_depth_buffer.renderHeight = h

    self.normalmap_depth_buffer = Canvas.new(w, h, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})
    self.normalmap_depth_buffer.renderWidth = w
    self.normalmap_depth_buffer.renderHeight = h

    self.meshquad = _G.MeshQuad.new(w, h, LColor.new(255, 255, 255, 255))
    self.meshquad.w = w
    self.meshquad.h = h
end

function Scene3D:draw(isdrawCanvaColor)
    self:drawDepth()

    for i = 1, #self.lights do
        local light = self.lights[i]
        if light.directionLight then            
            _G.useLight(light.directionLight)
        end
    end

    love.graphics.setMeshCullMode("front")
    love.graphics.setDepthMode("less", true)
    love.graphics.setCanvas({self.canvascolor.obj, depthstencil = self.normal_depth_buffer.obj})
    love.graphics.clear(self.bgColor._r, self.bgColor._g, self.bgColor._b, self.bgColor._a)
    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if node.mesh  then--and self.frustum:insideBox(node:getClipBox())     
            RenderSet.setshadowReceiver(node.shadowReceiver)
            node.mesh:draw()
            RenderSet.setshadowReceiver(false)
            if  self.isDrawBox then
                node:drawBoxMesh()
            end
            -- end
        end
    end
    love.graphics.setCanvas()
    love.graphics.setMeshCullMode("none")

    for i = 1, #self.lights do
        _G.popLight()
    end

    self:drawNormalmap()

    
    if isdrawCanvaColor then
        self:drawCanvaColor()
    end
end

function Scene3D:drawNormalmap()
    love.graphics.setCanvas({self.canvasnormal.obj, depthstencil = self.normalmap_depth_buffer.obj})
    love.graphics.setMeshCullMode("front")
    love.graphics.setDepthMode("less", true)
    love.graphics.clear(0, 0, 0, 0)

    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if node.mesh  then
            _G.useNormal()
            node.mesh:setRenderType("normalmap")
            node.mesh:draw()
            node.mesh:setRenderType("normal")
            _G.unUseNormal()
        end
    end
    love.graphics.setMeshCullMode("none")
    love.graphics.setCanvas()
end

function Scene3D:drawDepth()
    love.graphics.setCanvas({self.canvasdepth.obj, depthstencil = self.depthmap_depth_buffer.obj})
    love.graphics.setMeshCullMode("front")
    love.graphics.setDepthMode("less", true)
    love.graphics.clear(1,1,1,1)

    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if node.mesh then
            node.mesh:setRenderType("depth")
            node.mesh:draw()
            node.mesh:setRenderType('normal')
        end
    end
    love.graphics.setMeshCullMode("none")
    love.graphics.setCanvas()
end

function Scene3D:drawCanvaColor()
    local needbase = true
    local canvas1 = self.canvascolor
    local canvas2 = self.canvasPostprocess
    if self.needFXAA then
        love.graphics.setCanvas(canvas2)
        self.meshquad:setCanvas(canvas1)
        self.meshquad.shader = Shader.GetFXAAShader(canvas1.renderWidth , canvas1.renderHeight)
        self.meshquad:draw()
        needbase = false
        love.graphics.setCanvas()

        local temp = canvas1
        canvas1 = canvas2
        canvas2 = canvas1
    end

    if self.needSSAO then
        love.graphics.setCanvas(canvas2)
        self.meshquad:setCanvas(canvas1)
        self.meshquad.shader = Shader.GetSSAOShader(self.canvasnormal, self.canvasdepth)
        self.meshquad:draw()
        needbase = false
        love.graphics.setCanvas()

        local temp = canvas1
        canvas1 = canvas2
        canvas2 = canvas1
    end

    if needbase then
        self.canvascolor:draw()
    else
        canvas1:draw()
    end
end

function Scene3D:drawCanvaNormalmap()
    self.canvasnormal:draw()
end

function Scene3D:drawDirectionLightShadow(isdebug)
    for i = 1, #self.lights do
        local lightnode = self.lights[i]
        local directionLight = lightnode.directionLight
        if directionLight and lightnode.needshadow then

            love.graphics.setCanvas({lightnode.shadowmap.obj, depthstencil = lightnode.depth_buffer.obj})
            love.graphics.setMeshCullMode("front")
            love.graphics.setDepthMode("less", true)
            love.graphics.clear(1,1,1,1)
            -- love.graphics.clear(0,0,0)
            local camera3d = _G.getGlobalCamera3D()
            local lightmat = Matrix3D.createLookAtLH( Vector3.negative(directionLight.dir), Vector3.cOrigin, camera3d.up )

            local casterbox = BoundBox.new()
            local receiverbox = BoundBox.new()
            
            for j = 1, #self.nodes do
                local node = self.nodes[j]
                if node.shadowCaster then--node.shadowReceiver
                    casterbox:addSelf(node:getWorldBox())
                end

                if node.shadowReceiver then--node.shadowReceiver
                    local box = node.mesh.transform3d:mulBoundBox(node.box)
                    receiverbox:addSelf(box)
                end
            end

            local shadowprojectbox = BoundBox.getIntersectBox(casterbox, receiverbox)

            shadowprojectbox = lightmat:mulBoundBox(shadowprojectbox)
            shadowprojectbox.max.z = math.max(shadowprojectbox.max.z, camera3d.farClip) + 10000000--TODO
            
            local shadowmapproj = Matrix3D.createOrthoOffCenterLH(
                shadowprojectbox.min.x, shadowprojectbox.max.x, shadowprojectbox.min.y, shadowprojectbox.max.y, shadowprojectbox.min.z, shadowprojectbox.max.z);
            
            RenderSet.pushViewMatrix(Matrix3D.transpose(lightmat))
            RenderSet.pushProjectMatrix(Matrix3D.transpose(shadowmapproj))
            
            for j = 1, #self.nodes do
                local node = self.nodes[j]
                if node.shadowCaster then
                    local rendertype = node.mesh:getRenderType()
                    node.mesh:setRenderType("depth")
                    node.mesh:draw()
                    node.mesh:setRenderType(rendertype)
                end
            end

            RenderSet.popViewMatrix()
            RenderSet.popProjectMatrix()

            love.graphics.setCanvas()
            love.graphics.setMeshCullMode("none")
            -- local texmat = Matrix3D.new();
            -- texmat[1] =  0.5
            -- texmat[6] =  -0.5
            -- texmat[11] =  1.0

            -- texmat[13] = 0.5;
            -- texmat[14] = 0.5;
            -- texmat:transposeSelf()
            local texmat = Matrix3D.createFromNumbers( -- FOr uv
               0.5, 0,0,0,
               0,0.5,0,0,
               0,0,0.5,0,
               0.5,0.5,0.5,1
        )
            texmat:transposeSelf()
            texmat:mulRight(Matrix3D.transpose(shadowmapproj))
            local mat = texmat--Matrix3D.transpose(texmat)
            
            -- mat:mulRight(shadowmapproj)
            -- mat:mulRight(lightmat)
            -- mat:mulRight(Matrix3D.transpose(shadowmapproj))
            mat:mulRight(Matrix3D.transpose(lightmat))
            lightnode.directionlightMatrix = mat

            if isdebug then
                lightnode.shadowmap:draw()
                -- lightnode.depth_buffer:draw()
            end
        end
        
    end
    
end

