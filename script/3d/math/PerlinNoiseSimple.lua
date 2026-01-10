_G.PerlinNoiseSimple = {}

local _AllNumber = 256

local _Data = {}

-- 32个均匀分布的方向向量（每隔11.25度）
-- local _Gradients = {
--     {1.000, 0.000},      -- 0°
--     {0.981, 0.195},      -- 11.25°
--     {0.924, 0.383},      -- 22.5°
--     {0.831, 0.556},      -- 33.75°
--     {0.707, 0.707},      -- 45°
--     {0.556, 0.831},      -- 56.25°
--     {0.383, 0.924},      -- 67.5°
--     {0.195, 0.981},      -- 78.75°
--     {0.000, 1.000},      -- 90°
--     {-0.195, 0.981},     -- 101.25°
--     {-0.383, 0.924},     -- 112.5°
--     {-0.556, 0.831},     -- 123.75°
--     {-0.707, 0.707},     -- 135°
--     {-0.831, 0.556},     -- 146.25°
--     {-0.924, 0.383},     -- 157.5°
--     {-0.981, 0.195},     -- 168.75°
--     {-1.000, 0.000},     -- 180°
--     {-0.981, -0.195},    -- 191.25°
--     {-0.924, -0.383},    -- 202.5°
--     {-0.831, -0.556},    -- 213.75°
--     {-0.707, -0.707},    -- 225°
--     {-0.556, -0.831},    -- 236.25°
--     {-0.383, -0.924},    -- 247.5°
--     {-0.195, -0.981},    -- 258.75°
--     {0.000, -1.000},     -- 270°
--     {0.195, -0.981},     -- 281.25°
--     {0.383, -0.924},     -- 292.5°
--     {0.556, -0.831},     -- 303.75°
--     {0.707, -0.707},     -- 315°
--     {0.831, -0.556},     -- 326.25°
--     {0.924, -0.383},     -- 337.5°
--     {0.981, -0.195}      -- 348.75°
-- }
 
local _Gradients = {}

PerlinNoiseSimple.Init = function()
    local _TempDatas = {}
    local _NeedNumber = _AllNumber * 2
    for i = 1, _AllNumber do
        _TempDatas[i] = i
    end

    for i = _AllNumber, 1, -1 do
        local _RandomIndex = math.random(1, i + 0.1)
     
        _RandomIndex = _RandomIndex - _RandomIndex % 1
    
        _Data[i] = _TempDatas[_RandomIndex]

        table.remove(_TempDatas, _RandomIndex)

    end

    for i = 1, _AllNumber do
        _Data[i + _AllNumber] = _Data[i]
    end

    for i = 1, _AllNumber do
        local _v = Vector.new(math.random(-1, 1), math.random(-1, 1))
        _v:normalize()
        _Gradients[i] = _v
    end
    -- local Str = ""
    -- for i = 1, _NeedNumber do
    --     Str = Str .. tostring(_Data[i]) .. " , "
    -- end
    -- log(Str)
end

local GetGradVector = function(InIndex)
    local _g = _Gradients[InIndex % _AllNumber + 1]
    return _g
end

local fade = function( t) 
    -- Fade function as defined by Ken Perlin.  This eases coordinate values
    -- so that they will ease towards integral values.  This ends up smoothing
    -- the final output.
    return t * t * t * (t * (t * 6 - 15) + 10);         -- 6t^5 - 15t^4 + 10t^3
end

PerlinNoiseSimple.Process = function(x, y)
    local _ix = math.floor(x) % _AllNumber + 1
    local _iy = math.floor(y) % _AllNumber + 1

    local _xf = x - math.floor(x)
    local _yf = y - math.floor(y)

    local Idx1 = _Data[_Data[_iy] + _ix]
    local Idx2 = _Data[_Data[_iy] + _ix + 1]
    local Idx3 = _Data[_Data[_iy + 1] + _ix]

    local Idx4 = _Data[_Data[_iy + 1] + _ix + 1]

    local _Grad1 = GetGradVector(Idx1)
    local _Grad2 = GetGradVector(Idx2)
    local _Grad3 = GetGradVector(Idx3)
    local _Grad4 = GetGradVector(Idx4)

    local _D1 = Vector.new(_xf, _yf)
    local _D2 = Vector.new(_xf - 1, _yf)
    local _D3 = Vector.new(_xf, _yf - 1)
    local _D4 = Vector.new(_xf - 1, _yf - 1) 

    local _V1 = Vector.dot(_Grad1, _D1)
    local _V2 = Vector.dot(_Grad2, _D2)
    local _V3 = Vector.dot(_Grad3, _D3)
    local _V4 = Vector.dot(_Grad4, _D4)

    local _u = fade(_xf)
    local _v = fade(_yf)
    local _l1 = math.lerp(_V1, _V2, _u)
    local _l2 = math.lerp(_V3, _V4, _u)
    local _l = math.lerp(_l1, _l2, _v)

    return _l
end

PerlinNoiseSimple.Init()
