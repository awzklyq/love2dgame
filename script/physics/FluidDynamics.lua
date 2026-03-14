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

    grid._Diff = 0.005

    grid._OffsetX = InW / InWN
    grid._OffsetY = InH / InHN

    grid._SourceColor = LColor.Blue

    grid._Datas = {}
    grid._Mesh = _G.MeshGrids.new(InStartX, InStartY, InW, InH, InWN, InHN, LColor.White, nil, 
    function(InIndex, InI, InJ, InData)
        if not grid._Datas[InI] then
            grid._Datas[InI] = {}
        end

        local _Data = {_Data = InData, _Index = InIndex}

        local AddIndex = 1
        if not grid._Datas[InI][InJ] then
            grid._Datas[InI][InJ] = {_Density0 = 0.0, _Density1 = 0.0, _VaildDensity = false}
        else
            AddIndex = #grid._Datas[InI][InJ] + 1
        end

        grid._Datas[InI][InJ][AddIndex] = _Data
       
    end)

    return grid
end

function NSGrids:SetVaildDensity()
    for i = 1, #self._Datas do
        for j = 1, #self._Datas[i] do
            local _Data = self._Datas[i][j]
            check(_Data)

            if _Data._Density0 ~= _Data._Density1 then
                self:UpdateGridColor(i, j, LColor.Lerp(LColor.White, self._SourceColor, _Data._Density1))
            end
            _Data._Density0 = _Data._Density1
            _Data._VaildDensity = false
        end
    end
end

function NSGrids:GetDiffValue(dt)
    return self._Diff * self._WN * self._HN * dt
end
function NSGrids:GetGridVaild_Density(InI, InJ)
    if not self:CheckIndexVaild(InI, InJ) then
        return 0
    end

    local _Data = self._Datas[InI][InJ]
    return _Data._VaildDensity and _Data._Density1 or _Data._Density0
end

function NSGrids:Diffusion_Density(InDiff)
    for i = 1, #self._Datas do
        for j = 1, #self._Datas[i] do
            local _Data = self._Datas[i][j]
            local ds = InDiff * (self:GetGridVaild_Density(i - 1, j) +  self:GetGridVaild_Density(i + 1, j) + self:GetGridVaild_Density(i, j - 1) + self:GetGridVaild_Density(i , j + 1) )
            ds = _Data._Density0 + ds
            ds = ds / (1 + 4 * InDiff)

            _Data._Density1 = ds
            _Data._VaildDensity = true
        end
    end

    self:SetVaildDensity()
end

function NSGrids:Update_Density(dt)
    local diff = self:GetDiffValue(dt)

    
    self:Diffusion_Density(diff)
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

function NSGrids:SetPositionDensity(InX, InY, InDensity)
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

    -- log('aaaaa', InDensity)
    self:Set_Density(_Datas[_Index].i, _Datas[_Index].j, InDensity)
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

function NSGrids:Set_Density(InI, InJ, InDensity)
    local _Data = self._Datas[InI][InJ]
    check(_Data)
    _Data._Density0 = InDensity

end

function NSGrids:update(dt)
    self:Update_Density(dt)
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

function NavierStokesEquations:SetPositionDensity(InX, InY, InDensity)
    self._Grids:SetPositionDensity(InX, InY, InDensity)
end


function NavierStokesEquations:draw()
    self._Grids:draw()
end

function NavierStokesEquations:update(dt)
    self._Grids:update(dt)
end

