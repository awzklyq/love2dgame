_G.Face3D = {}

__setParentClassNoTable(Face3D, _G.Plane)

function Face3D.new(p1, p2, p3)
    local face = setmetatable({}, {__index = Face3D});

    face.a = 0
    face.b = 0
    face.c = 0
    face.d = 0

    face.Points= {}

    face.Points[1] = p1
    face.Points[2] = p2
    face.Points[3] = p3
    face.name = 'Face3D'

    face:buildFromThreePoints(p1, p2, p3)

    return face
end