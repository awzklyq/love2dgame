_G.FloatageManager = {}

FloatageManager.G = Vector.new(0, 1000)
FloatageManager.InvG = Vector.new(0, -1)

FloatageManager.Density = 5

FloatageManager.WaterHeight = 500

FloatageManager.IsDrawWaterLine = false

FloatageManager._Brake = 3.0

FloatageManager.ResetWaterLine = function(InHeight)

    local w = RenderSet and RenderSet.screenwidth or 2000
    FloatageManager.WaterHeight = InHeight
    FloatageManager._WaterNoiseLine = NoiseLine.new(0, InHeight, w, InHeight, 2, 50, 10, 5) 
    FloatageManager._WaterNoiseLine:setMode('y')    

    FloatageManager._WaterLine = Line.new(0, InHeight, w, InHeight)
end

FloatageManager.ResetWaterLine(FloatageManager.WaterHeight)

local _Polygon2Ds = {}

local CheckPolygon2DIn = function(InPolygon)
    for i = 1, #_Polygon2Ds do
        if _Polygon2Ds[i].Polygon == InPolygon then
            return true
        end
    end

    return false
end
FloatageManager.AddPolygon2d = function(InPolygon, InDensity)
    if CheckPolygon2DIn(InPolygon) then
        return 
    end

    InPolygon:GenerateTriangles(true)
    InDensity = InDensity or 1

    local _Surface = InPolygon:GetSurfaceArea()
    _Polygon2Ds[#_Polygon2Ds + 1] = {Polygon = InPolygon, Density = InDensity, Velocity = Vector.new(0, 0), Surface = _Surface, Mass = _Surface * InDensity}
end

FloatageManager.RemovePolygon2d = function(InPolygon)
     for i = 1, #_Polygon2Ds do
        if _Polygon2Ds[i].Polygon == InPolygon then
            table.Remove(_Polygon2Ds, i)
            break
        end
    end
end

local CaclePolygon2DVeolecity = function(InPolygon, InAccelerate, dt)
    InPolygon.Velocity = InPolygon.Velocity + InAccelerate * dt
end

local CaclePolygon2DPosition = function(InPolygon, InAccelerate, dt)
    local _S = InPolygon.Velocity * dt + InAccelerate * dt * dt * 0.5
    InPolygon.Polygon.transform:MulTranslationRight(_S.x, _S.y)
end

local CaclePolygon2DAccelerate = function(InPolygon, InForce)
    return InForce / InPolygon.Mass
end

local CaclePolygon2DGravity = function(InPolygon)
    return FloatageManager.G * InPolygon.Mass
end

local CaclePolygon2DBrake = function(InPolygon, InOriArea, InWaterArea)
    -- InPolygon.Velocity 需要加上水流速度
    return -InPolygon.Velocity *  FloatageManager._Brake * InPolygon.Mass * (InWaterArea / InOriArea)
end

local CheckPolygon2DIsInWaterAndCacleFloatage = function(InPolygon, InGravity)
    local _LeftP, _RightP = InPolygon.Polygon:CutByLineOrEdge(FloatageManager._WaterLine)
    if _RightP:IsHasData() == false then
        return InGravity
    end

    local _InWaterArea = _RightP:GetSurfaceArea()
    local _OriArea = InPolygon.Polygon:GetSurfaceArea()
    local _F = FloatageManager.InvG * FloatageManager.G * _InWaterArea * FloatageManager.Density

    local _Brake = CaclePolygon2DBrake(InPolygon, _OriArea, _InWaterArea)
    return (_F + InGravity + _Brake)
end

FloatageManager.UpdatePolygon2Ds = function(dt)
    for i = 1, #_Polygon2Ds do
        local _p = _Polygon2Ds[i]

        local _Gravity = CaclePolygon2DGravity(_p)

        local _F = CheckPolygon2DIsInWaterAndCacleFloatage(_p, _Gravity)

        local _Accelerate = CaclePolygon2DAccelerate(_p, _F)
        CaclePolygon2DPosition(_p, _Accelerate, dt)
        CaclePolygon2DVeolecity(_p, _Accelerate, dt)
    end
end

FloatageManager.Update = function(dt)
    FloatageManager.UpdatePolygon2Ds(dt)
end

app.update(function(dt)
    FloatageManager.Update(dt)

    if FloatageManager.IsDrawWaterLine then
        FloatageManager._WaterNoiseLine:update(dt)
    end
end)

app.afterrender(function(dt)

    -- _t1:draw()
    if FloatageManager.IsDrawWaterLine then
        FloatageManager._WaterNoiseLine:draw()
    end
end)

app.resizeWindow(function(w, h)
    FloatageManager.ResetWaterLine(FloatageManager.WaterHeight)
end)