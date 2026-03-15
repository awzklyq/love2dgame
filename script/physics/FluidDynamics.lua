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
    grid._Viscosity = 0.05

    grid._OffsetX = InW / InWN
    grid._OffsetY = InH / InHN

    grid._SourceColor = LColor.Blue

    grid._Datas = {}
    grid._Mesh = _G.MeshGrids.new(InStartX, InStartY, InW, InH, InWN, InHN, LColor.White, nil, 
    function(InIndex, InI, InJ, InData, InX, InY)
        if not grid._Datas[InI] then
            grid._Datas[InI] = {}
        end

        local _Data = {_Data = InData, _Index = InIndex}

        local AddIndex = 1
        if not grid._Datas[InI][InJ] then
            grid._Datas[InI][InJ] = {_Density0 = 0.0, _Density1 = 0.0, _VaildDensity = false, _VelocityU0 = 0, _VelocityU1 = 0, _VaildVelocityU = false, _VelocityV0 = 0, _VelocityV1 = 0, _VaildVelocityV = false, _X = InX, _Y = InY}
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

function NSGrids:SetVaildVelocity()
    for i = 1, #self._Datas do
        for j = 1, #self._Datas[i] do
            local _Data = self._Datas[i][j]
            check(_Data)

            _Data._VelocityU0 = _Data._VelocityU1
            _Data._VaildVelocityU = false

            _Data._VelocityV0 = _Data._VelocityV1
            _Data._VaildVelocityV = false
        end
    end
end

function NSGrids:GetDiffValue(dt)
    return self._Diff * self._WN * self._HN * dt
end

function NSGrids:GetViscosityValue(dt)
    return self._Viscosity * self._WN  * dt --* self._HN
end

function NSGrids:GetGridVaild_Density(InI, InJ)
    if not self:CheckIndexVaild(InI, InJ) then
        return 0
    end

    local _Data = self._Datas[InI][InJ]
    return _Data._VaildDensity and _Data._Density1 or _Data._Density0
end

function NSGrids:GetGridVaild_VelocityU(InI, InJ)
    if not self:CheckIndexVaild(InI, InJ) then
        return 0
    end

    local _Data = self._Datas[InI][InJ]
    return _Data._VaildVelocityU and _Data._VelocityU1 or _Data._VelocityU0
end

function NSGrids:GetGridVaild_VelocityV(InI, InJ)
    if not self:CheckIndexVaild(InI, InJ) then
        return 0
    end

    local _Data = self._Datas[InI][InJ]
    return _Data._VaildVelocityV and _Data._VelocityV1 or _Data._VelocityV0
end

function NSGrids:Diffusion_Density(InDiff)
    for i = 1, #self._Datas do
        for j = 1, #self._Datas[i] do
            local _Data = self._Datas[i][j]
            local ds = InDiff * (self:GetGridVaild_Density(i - 1, j) +  self:GetGridVaild_Density(i + 1, j) + self:GetGridVaild_Density(i, j - 1) + self:GetGridVaild_Density(i , j + 1) )
            ds = _Data._Density0 + ds
            ds = ds / (1 + 4 * InDiff)

            if math.abs(ds) < math.cEpsilon * 100 then
                _Data._Density1 = 0
            else
                _Data._Density1 = ds
            end
            
            _Data._VaildDensity = true
        end
    end
end

function NSGrids:Advection_Density(dt)
     for i = 1, #self._Datas do
        for j = 1, #self._Datas[i] do
            local _Data = self._Datas[i][j]
            
            local vu = _Data._VelocityU0 * dt
            local vv = _Data._VelocityV0 * dt
            local NewPosition = Vector.new(_Data._X, _Data._Y) - Vector.new(vv, vu)

            local _GridDatas = self:GetGridDataFormPosition(NewPosition.x, NewPosition.y)
            
            local _Density = 0
            if _GridDatas then
                for k = 1, #_GridDatas do
                    local _GridData = _GridDatas[k]
                    _Density = _Density + self:GetGridVaild_Density(_GridData.i, _GridData.j) * _GridData.weight
                end

                _Data._Density1 = _Density
            end
        end
    end
end


function NSGrids:Diffusion_Velocity(InViscosity)
    for i = 1, #self._Datas do
        for j = 1, #self._Datas[i] do
            local _Data = self._Datas[i][j]
            local vu = InViscosity * (self:GetGridVaild_VelocityU(i - 1, j) +  self:GetGridVaild_VelocityU(i + 1, j) + self:GetGridVaild_VelocityU(i, j - 1) + self:GetGridVaild_VelocityU(i , j + 1) )
            vu = _Data._VelocityU0 + vu
            vu = vu / (1 + 4 * InViscosity)

            _Data._VelocityU1 = vu

            if math.abs(vu) < math.cEpsilon then
                _Data._VelocityU1 = 0    
            end
            
            _Data._VaildVelocityU = true


            local vv = InViscosity * (self:GetGridVaild_VelocityV(i - 1, j) +  self:GetGridVaild_VelocityV(i + 1, j) + self:GetGridVaild_VelocityV(i, j - 1) + self:GetGridVaild_VelocityV(i , j + 1) )
    
            vv = _Data._VelocityV0 + vv
            vv = vv / (1 + 4 * InViscosity)

            _Data._VelocityV1 = vv

            if math.abs(vv) < math.cEpsilon then
                _Data._VelocityV1 = 0    
            end
            _Data._VaildVelocityV = true
        end
    end
end

function NSGrids:Advection_Velocity(dt)
     for i = 1, #self._Datas do
        for j = 1, #self._Datas[i] do
            local _Data = self._Datas[i][j]
            
            local vu = self:GetGridVaild_VelocityU(i, j) * dt
            local PY = _Data._Y - vu

            local _GridDatas = self:GetGridDataFormPosition(_Data._X, PY)
            local _VelocityU = 0
            if _GridDatas then
                for k = 1, #_GridDatas do
                    local _GridData = _GridDatas[k]
                    _VelocityU = _VelocityU + self:GetGridVaild_VelocityU(_GridData.i, _GridData.j) * _GridData.weight
                end

                _Data._VelocityU1 = _VelocityU
            end

            -----------------
            local vv = self:GetGridVaild_VelocityV(i, j) * dt
            local PX = _Data._X - vv

            _GridDatas = self:GetGridDataFormPosition(PX, _Data._Y)
            local _VelocityV = 0
            if _GridDatas then
                for k = 1, #_GridDatas do
                    local _GridData = _GridDatas[k]
                    _VelocityV = _VelocityV + self:GetGridVaild_VelocityV(_GridData.i, _GridData.j) * _GridData.weight
                end

                _Data._VelocityV1 = _VelocityV
            end
        end
    end
end

function NSGrids:Update_Density(dt)
    local diff = self:GetDiffValue(dt)
    
    self:Diffusion_Density(diff)

    self:Advection_Density(dt)

    self:SetVaildDensity()
end

function NSGrids:Update_Velocity(dt)
    local Viscosity = self:GetViscosityValue(dt)
    
    self:Diffusion_Velocity(Viscosity)

    self:Advection_Velocity(dt)

    self:SetVaildVelocity()
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
    local dd = (d - d1) + (d - d2) + (d - d3) + (d - d4)
    local _Data1 = {i = _i + 1, j = _j + 1, distance = d1, weight = (d - d1) / dd}
    local _Data2 = {i = _i + 1 + 1, j = _j + 1, distance = d2, weight = (d - d2) / dd}
    local _Data3 = {i = _i + 1 + 1, j = _j + 1 + 1, distance = d3, weight = (d - d3) / dd}
    local _Data4 = {i = _i + 1, j = _j + 1 + 1, distance = d4, weight = (d - d4) / dd}

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


function NSGrids:SetPositionVelocity(InX, InY, InVelocityV, InVelocityU)
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
    self:Set_Velocity(_Datas[_Index].i, _Datas[_Index].j, InVelocityV, InVelocityU)
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

function NSGrids:Set_Velocity(InI, InJ, InVelocityV, InVelocityU)
    local _Data = self._Datas[InI][InJ]
    check(_Data)
    _Data._VelocityU0 = InVelocityU
    _Data._VelocityV0 = InVelocityV

end

function NSGrids:update(dt)
    self:Update_Velocity(dt)
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

function NavierStokesEquations:SetPositionVelocity(InX, InY, InVelocityV, InVelocityU)
    self._Grids:SetPositionVelocity(InX, InY, InVelocityV, InVelocityU)
end

function NavierStokesEquations:draw()
    self._Grids:draw()
end

function NavierStokesEquations:update(dt)
    self._Grids:update(dt)
end

