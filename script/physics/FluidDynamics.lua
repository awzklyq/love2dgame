--Navier-Stokes Equations
--Real-Time Fluid Dynamics for Games  --Jos Stam

_G.NSGrids = {}
NSGrids._Meta = {__index = NSGrids}
function NSGrids.new(InStartX, InStartY, InW, InH, InWN, InHN)
    local grid = setmetatable({}, NSGrids._Meta)

    grid._StartX = InStartX
    grid._StartY = InStartY
    
    grid._W = InW
    grid._H = InH

    grid._WN = InWN
    grid._HN = InHN

    grid._OffsetX = InW / InWN
    grid._OffsetY = InH / InHN
    return grid
end

_G.NavierStokesEquations = {}

NavierStokesEquations._Meta = {__index = NavierStokesEquations}
function NavierStokesEquations.new(InGridDatas)
    local NS = setmetatable({}, NavierStokesEquations._Meta)

    return NS
end

function NavierStokesEquations:Init(InGridDatas)
    --Bind Datas
    self._GridDatas = InGridDatas
    
end