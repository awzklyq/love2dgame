_G.SceneNode3D = {}

function SceneNode3D.new()
    local node = setmetatable({}, {__index = SceneNode3D});

    node.renderid = Render.SceneNode3DId

    node.isDrawBox = false

    return node
end

function SceneNode3D:bindMesh(mesh)
    assert(mesh.renderid and mesh.renderid == Render.Mesh3DId)
    self.mesh = mesh

    self.box = BoundBox.buildFromMesh3D(mesh)
    self.boxmesh = self.box:buildMesh()
    self.boxmesh.transform3d = mesh.transform3d
    
    self.shadowCaster = false

    self.shadowReceiver = false
end

function SceneNode3D:bindDirectionLight(light)
    assert(light.renderid and light.renderid == Render.DirectionLightId)
    self.directionLight = light
    light.node = self
    self.needshadow = false

    local width = RenderSet.getShadowMapSize()--love.graphics.getPixelWidth() -- love.graphics.getWidth() * 2
    local height = RenderSet.getShadowMapSize()--love.graphics.getPixelHeight()--love.graphics.getHeight() * 2
    self.shadowmap = Canvas.new(width, height, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
    self.shadowmap:setWrap("clampone", "clampone")
    self.depth_buffer = Canvas.new(width, height, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})

end

function SceneNode3D:drawBoxMesh()
    if self.isDrawBox and self.boxmesh then
        local cullmode = love.graphics.getMeshCullMode()
        love.graphics.setMeshCullMode("none")
        love.graphics.setWireframe( true )
        self.boxmesh:draw()
        love.graphics.setWireframe( false )
        love.graphics.setMeshCullMode(cullmode)
    end
end

