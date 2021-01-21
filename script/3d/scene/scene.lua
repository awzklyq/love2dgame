_G.Scene3D = {}

function Scene3D.new()
    local scene = setmetatable({}, {__index = Scene3D});

    scene.renderid = Render.Scene3DId

    scene.nodes = {}

    scene.lights = {}

    scene.bgColor = LColor.new(0,0,0,0)

    scene.screenwidth = love.graphics.getPixelWidth() -- love.graphics.getWidth() * 2
    scene.screenheight = love.graphics.getPixelHeight()--love.graphics.getHeight() * 2
    scene.canvascolor = Canvas.new(scene.screenwidth, scene.screenheight, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})

    scene.canvasdepth = Canvas.new(scene.screenwidth, scene.screenheight, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})

    scene.depth_buffer = Canvas.new(scene.screenwidth, scene.screenheight, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})

    scene.meshquad = _G.MeshQuad.new(scene.screenwidth, scene.screenheight, LColor.new(255, 255, 255, 255))
    scene.meshquad.w = scene.screenwidth
    scene.meshquad.h = scene.screenheight
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
    self.screenwidth = RenderSet.screenwidth-- love.graphics.getWidth() * 2
    self.screenheight = RenderSet.screenheight--love.graphics.getHeight() * 2
end

function Scene3D:draw(isdrawCanvaColor)
    for i = 1, #self.lights do
        local light = self.lights[i]
        if light.directionLight then            
            _G.useLight(light.directionLight)
        end
    end

    love.graphics.setCanvas({self.canvascolor.obj, depthstencil = self.depth_buffer.obj})
    love.graphics.setMeshCullMode("front")
    love.graphics.setDepthMode("less", true)
    love.graphics.clear(self.bgColor._r, self.bgColor._g, self.bgColor._b, self.bgColor._a)

    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if node.mesh then
            -- node:drawBoxMesh()
            -- if node.shadowReceiver then
            RenderSet.setshadowReceiver(node.shadowReceiver)
            node.mesh:draw()
            RenderSet.setshadowReceiver(false)
            -- end
        end
    end
    love.graphics.setMeshCullMode("none")
    love.graphics.setCanvas()

    for i = 1, #self.lights do
        _G.popLight()
    end

    if isdrawCanvaColor then
        self:drawCanvaColor()
    end
end

function Scene3D:drawDepth()
    love.graphics.setCanvas({self.canvasdepth.obj, depthstencil = self.depth_buffer.obj})
    love.graphics.setMeshCullMode("front")
    love.graphics.setDepthMode("less", true)
    love.graphics.clear(1,1,1,1)

    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if node.mesh then
            local rendertype = node.mesh:getRenderType()
            node.mesh:setRenderType("depth")
            node.mesh:draw()
            node.mesh:setRenderType(rendertype)
        end
    end
    love.graphics.setMeshCullMode("none")
    love.graphics.setCanvas()
end

function Scene3D:drawCanvaColor()
    if self.needFXAA then
        self.canvascolor.renderWidth = self.screenwidth
        self.canvascolor.renderHeight = self.screenheight
        if  self.meshquad.w ~= self.screenwidth or self.meshquad.h ~= self.screenheight then
            self.meshquad = _G.MeshQuad.new(self.screenwidth, self.screenheight, LColor.new(255, 255, 255, 255))
            self.meshquad.w = self.screenwidth
            self.meshquad.h = self.screenheight
        end
        self.meshquad:setCanvas(self.canvascolor)
        self.meshquad.shader = Shader.GetFXAAShader(self.canvascolor.renderWidth , self.canvascolor.renderHeight)
        self.meshquad:draw()
    else
        self.canvascolor:draw()
    end
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

            local shadowprojectbox = BoundBox.new()
            for j = 1, #self.nodes do
                local node = self.nodes[j]
                if node.shadowCaster then--node.shadowReceiver
                    local box = node.mesh.transform3d:mulBoundBox(node.box)
                    shadowprojectbox:addSelf(box)
                end
            end

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
            texmat:mulRight(shadowmapproj)
            local mat = texmat--Matrix3D.transpose(texmat)
            
            -- mat:mulRight(shadowmapproj)
            -- mat:mulRight(lightmat)
            -- mat:mulRight(Matrix3D.transpose(shadowmapproj))
            mat:mulRight(lightmat)
            lightnode.directionlightMatrix = mat

            if isdebug then
                lightnode.shadowmap:draw()
                -- lightnode.depth_buffer:draw()
            end
        end
        
    end
    
end

