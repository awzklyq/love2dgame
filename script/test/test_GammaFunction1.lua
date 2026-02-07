--Stirling's formula
function StirlingFormula(InX)
    return math.sqrt(2 * math.pi * InX) * math.exp(-InX) * math.pow(InX, InX)
end

function TestGammaFunction1(InX)
    local _Result = 1
    for i = InX, 1, -1 do
        _Result = _Result * i
    end

    return _Result
end

local V1 = StirlingFormula(4)
local V2 = TestGammaFunction1(4)
log(V1, V2, math.abs(V1 -V2) / V2)

V1 = StirlingFormula(11)
V2 = TestGammaFunction1(11)
log(V1, V2, math.abs(V1 -V2) / V2)

-- local V1 = StirlingFormula(0.5)
-- local V2 = math.sqrt(math.pi )
-- log(V1, V2, math.abs(V1 -V2) / V2)