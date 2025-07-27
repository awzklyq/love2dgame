_G.BSPFace2D = {}

BSPFace2D._Meta = {__index = BSPFace2D }

function BSPFace2D.new()
    local b = setmetatable({}, BSPFace2D._Meta)

    return b
end