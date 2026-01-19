math.randomseed(os.time()%10000)

local _GetGaussRand = function()
    local _Num = 3 + math.ceil(math.random() * 2)
    local _Sum = 0
    for i = 1, _Num do
        _Sum = _Sum + math.random()
    end

    return math.abs((_Sum / _Num) - 0.5) * 2
end

local _Number = 100
local _Values = {}
for i = 1, _Number do
    _Values[i] = _GetGaussRand()
end

local _Rects = {}
local _OriRects = {}
local _R = 200
local _Offset = Vector.new(500, 500)
local _StartPos = Complex.new(1.0 ,0)
local _OriRect = Rect.new(_Offset.x - 2, _Offset.y - 2, 4, 4)
_OriRect:SetColor(255,0,0,255)
for i = 1, _Number do
    local _Angle = math.random() * 360
    local _LocalCompex = Complex.CreateFromAngle(_Angle)
    local _NewCompex = _LocalCompex * _StartPos
    local _V = _NewCompex:AsVector() * _Values[i] * _R + _Offset
    local _rect = Rect.new(_V.x - 2, _V.y - 2, 4, 4)
    _Rects[i] = _rect

     local _OriV = _NewCompex:AsVector() * math.random() * _R + _Offset
    local _orirect = Rect.new(_OriV.x - 2, _OriV.y - 2, 4, 4)
    _OriRects[i] = _orirect
    _orirect:SetColor(0,255,0,255)
end

local _OriCircle = Circle.new(_R, _Offset.x ,_Offset.y)
app.render(function(dt)
    for i = 1, #_Rects do
        _Rects[i]:draw()
    end

    for i = 1, #_OriRects do
        _OriRects[i]:draw()
    end

    _OriCircle:draw()
    _OriRect:draw()
end)

-- local _III = 0
-- for i = 1, 10000 do
--     _III = _III +  math.random() 
-- end

-- log('aaaaaaaa', _III / 10000)