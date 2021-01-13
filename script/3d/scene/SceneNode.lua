_G.SceneNode3D = {}

function SceneNode3D.new()
    local node = setmetatable({}, {__index = SceneNode3D});

    node.renderid = Render.SceneNode3DId
    return node
end

function SceneNode3D:bindMesh(mesh)
    assert(mesh.renderid and mesh.renderid == Render.Mesh3DId)
    self.mesh = mesh
end

