_G.SceneNode3D = {}

function SceneNode3D.new()
    local node = setmetatable({}, {__index = SceneNode3D});

    node.renderid = Render.SceneNode3DId

    node.isDrawBox = false

    node.isFrustumChecked = false

    return node
end

function SceneNode3D:bindMesh(mesh)
    assert(mesh.renderid and mesh.renderid == Render.Mesh3DId)
    self.mesh = mesh

    self.box = BoundBox.buildFromMesh3D(mesh)
    -- self.box = mesh.transform3d:mulBoundBox(self.box)
    self.boxmesh = self:getWorldBox():buildMeshLines()
    -- self.boxmesh:setTransform(mesh.transform3d)
    
    self.shadowCaster = false

    self.shadowReceiver = false
end

function SceneNode3D:getWorldBox()
    if self.mesh then
        return self.mesh.transform3d:mulBoundBox(self.box)
        --return self.box
    end
    return BoundBox.new()
end

function SceneNode3D:getClipBox()
    if self.mesh then
        local mat = Matrix3D.copy(RenderSet.getUseProjectMatrix())
        mat:mulRight(RenderSet.getUseViewMatrix())
        mat:mulRight(self.mesh.transform3d)
        return mat:mulBoundBox(self.box)
    end
    return BoundBox.new()
end


function SceneNode3D:bindDirectionLight(light)
    assert(light.renderid and light.renderid == Render.DirectionLightId)
    self.directionLight = light
    light.node = self
    self.needshadow = false

    local width = RenderSet.getShadowMapSize()--love.graphics.getPixelWidth() -- love.graphics.getWidth() * 2
    local height = RenderSet.getShadowMapSize()--love.graphics.getPixelHeight()--love.graphics.getHeight() * 2
    self.shadowmap = Canvas.new(width * _G.GConfig.CSMNumber, height, {format = "rgba32f", readable = true, msaa = 0, mipmaps="none"})
    self.shadowmap:setWrap("clampone", "clampone")
    self.depth_buffer = Canvas.new(width * _G.GConfig.CSMNumber, height, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})

    self.CSMMatrix = {}
    self.CSMDistance = {}
end

function SceneNode3D:createOctreenodes()
    if self.mesh and not self.octreenodes then
        self.octreenodes = setmetatable({}, {__mode = "kv"});
    end
end

function SceneNode3D:drawBoxMesh()
    if self.isDrawBox and self.boxmesh then
        local cullmode = love.graphics.getMeshCullMode()
        love.graphics.setMeshCullMode("none")
        -- love.graphics.setWireframe( true )
        self.boxmesh:draw()
        -- love.graphics.setWireframe( false )
        love.graphics.setMeshCullMode(cullmode)
    end
end

