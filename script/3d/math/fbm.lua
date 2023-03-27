_G.FBM = {}

_G.FBM.Process = function (x, y)
    local vc = Vector.new(x, y)
    local amplitude = 0.5
    local frequency = 3
    
    local lacunarity = 2
    local gain = 0.5

    local OCTAVES = 6

    local value = 0
    for i = 1, OCTAVES do
        vc = vc * frequency
        value = value + amplitude * math.noise(vc.x, vc.y)
        frequency = frequency * lacunarity
        amplitude = amplitude * gain
    end

    return value
end