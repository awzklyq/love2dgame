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

    scene.depth_buffer = Canvas.new(width, height, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})
    return scene
end

function Scene3D:getDepthCanvas()
    return self.canvasdepth
end

function Scene3D:addLight(light)
    table.insert(self.lights, light)
end

function Scene3D:removeLight(light)
    for i = 1, #self.lights do
        if self.lights[i] == light then
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
end

function Scene3D:draw(isdrawCanvaColor)
    for i = 1, #self.lights do
        _G.useLight(self.lights[i])
    end

    love.graphics.setCanvas({self.canvascolor.obj, depthstencil = self.depth_buffer.obj})
    love.graphics.setMeshCullMode("front")
    love.graphics.setDepthMode("less", true)
    love.graphics.clear(self.bgColor._r, self.bgColor._g, self.bgColor._b, self.bgColor._a)

    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if node.mesh then
            node.mesh:draw()
        end
    end

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
    love.graphics.clear(self.bgColor._r, self.bgColor._g, self.bgColor._b, self.bgColor._a)

    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if node.mesh then
            local rendertype = node.mesh:getRenderType()
            node.mesh:setRenderType("depth")
            node.mesh:draw()
            node.mesh:setRenderType(rendertype)
        end
    end

    love.graphics.setCanvas()
end

function Scene3D:drawCanvaColor()
    self.canvascolor:draw()
end

