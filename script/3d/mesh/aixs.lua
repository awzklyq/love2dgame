
_G.Aixs = {}

function Aixs.new(x, y, z, length)-- lw :line width
    local aixs = setmetatable({}, {__index = Aixs});

    x = x or 0
    y = y or 0
    z = z or 0

    length = length or 10

    aixs.pos = Vector3.new(x, y, z)
    aixs.length = length
    aixs.x_aix = MeshLine.new(Vector3.new(0, 0, 0), Vector3.new(length, 0, 0))
    aixs.x_aix.bcolor = LColor.new(255,0,0,255)

    aixs.y_aix = MeshLine.new(Vector3.new(0, 0, 0), Vector3.new(0, length, 0))
    aixs.y_aix.bcolor = LColor.new(0,255,0,255)

    aixs.z_aix = MeshLine.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, length))
    aixs.z_aix.bcolor = LColor.new(0,0,255,255)

    aixs.transform3d = Matrix3D.new();
    aixs.x_aix.transform3d = aixs.transform3d
    aixs.y_aix.transform3d = aixs.transform3d
    aixs.z_aix.transform3d = aixs.transform3d

    aixs.transform3d:mulTranslationRight(x, y, z)
    return aixs
end

function Aixs:draw()
    self.x_aix:draw()
    self.y_aix:draw()
    self.z_aix:draw()
end