local vector = require("script.light.lib.vector")
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

    grid._Datas = {}
    grid._Mesh = _G.MeshGrids.new(InStartX, InStartY, InW, InH, InWN, InHN, LColor.White, nil, 
    function(InIndex, InI, InJ, InData)
        if not grid._Datas[InI] then
            grid._Datas[InI] = {}
        end

        local _Data = {_Data = InData, _Index = InIndex}

        local AddIndex = 1
        if not grid._Datas[InI][InJ] then
            grid._Datas[InI][InJ] = {}
        else
            AddIndex = #grid._Datas[InI][InJ] + 1
        end

        grid._Datas[InI][InJ][AddIndex] = _Data
       
    end)

    return grid
end

function NSGrids:CheckPositionIn(InX, InY)
    return InX >= self._StartX and InX < self._StartX + self._W and InY >= self._StartY and InY <= self._StartY + self._H
end

function NSGrids:CheckIndexVaild(InI, InJ)
    return InI >= 1 and InI  <= self._WN + 1 and InJ >= 1 and InJ  <= self._HN + 1    
end
function NSGrids:GetGridDataFormPosition(InX, InY)
    if not self:CheckPositionIn(InX, InY) then 
        return nil
    end

    local _X = InX - self._StartX 
    local _Y = InY - self._StartY

    local _IX = _X / self._OffsetX
    local _IY = _Y / self._OffsetY

    local _i = math.floor(_IX)
    local _j = math.floor(_IY)

    local _Position = Vector.new(InX, InY)
    local x1 = self._StartX + self._OffsetX * _i
    local y1 = self._StartY + self._OffsetY * _j

    local v1 = Vector.new(x1, y1)
    local v2 = Vector.new(x1 + self._OffsetX, y1)
    local v3 = Vector.new(x1 + self._OffsetX, y1 + self._OffsetY)
    local v4 = Vector.new(x1, y1 + self._OffsetY)

    local d1 = Vector.Distance(_Position, v1)
    local d2 = Vector.Distance(_Position, v2)
    local d3 = Vector.Distance(_Position, v3)
    local d4 = Vector.Distance(_Position, v4)

    local d = d1 + d2 + d3 + d4
    local _Data1 = {i = _i + 1, j = _j + 1, distance = d1}
    local _Data2 = {i = _i + 1 + 1, j = _j + 1, distance = d2}
    local _Data3 = {i = _i + 1 + 1, j = _j + 1 + 1, distance = d3}
    local _Data4 = {i = _i + 1, j = _j + 1 + 1, distance = d4}

    local _Datas = {}
    _Datas[#_Datas + 1] = _Data1
    _Datas[#_Datas + 1] = _Data2
    _Datas[#_Datas + 1] = _Data3
    _Datas[#_Datas + 1] = _Data4

    return _Datas
end

function NSGrids:SetPositionColor(InX, InY, InColor)
    local _Datas = self:GetGridDataFormPosition(InX, InY)
    if not _Datas then
        return
    end

    local _MinDistance = _Datas[1].distance
    local _Index = 1
    for i = 2, #_Datas do
        if _MinDistance >  _Datas[i].distance then
            _Index = i
            _MinDistance = _Datas[i].distance
        end
    end

    self:UpdateGridColor(_Datas[_Index].i, _Datas[_Index].j, InColor)
end

function NSGrids:UpdateGridColor(InI, InJ, InColor)
    local _Data = self._Datas[InI][InJ]
    check(_Data)

    for i = 1, #_Data do
        local d = _Data[i]
        d._Data[5] = InColor._r
        d._Data[6] = InColor._g
        d._Data[7] = InColor._b
        d._Data[8] = InColor._a

        self._Mesh:SetVertex(d._Index,  d._Data)
    end

end

function NSGrids:draw()
    self._Mesh:draw()    
end

_G.NavierStokesEquations = {}

NavierStokesEquations._Meta = {__index = NavierStokesEquations}
function NavierStokesEquations.new(InStartX, InStartY, InW, InH, InWN, InHN)
    local NS = setmetatable({}, NavierStokesEquations._Meta)

    NS._Grids = NSGrids.new(InStartX, InStartY, InW, InH, InWN, InHN)
    return NS
end

function NavierStokesEquations:SetPositionColor(InX, InY, InColor)
    self._Grids:SetPositionColor(InX, InY, InColor)
end

function NavierStokesEquations:draw()
    self._Grids:draw()
end

