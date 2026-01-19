

math.randomseed(os.time()%10000)
local X_Numer = 16
local Y_Numer = 16
local _StartPos = Vector.new(10, 10)
local _Offset = Vector.new(40, 40)
local _Rects = {}

for i = 1, X_Numer do
    for j = 1, Y_Numer do
        local _Start = _StartPos + _Offset * Vector.new(i, j)
        -- local _End = _Start + Vector.new(2, 2)
        local _rect = Rect.new(_Start.x, _Start.y, 4, 4, "fill")
        local _ColorValueR = (i / X_Numer) *255--  math.random(1, 255)
        local _ColorValueG =  255 - (i / X_Numer) *255--math.random(1, 255)
        local _ColorValueB = 255--math.random(1, 255)
        _rect:SetColor(_ColorValueR, _ColorValueG, _ColorValueB, 255)
        _Rects[#_Rects + 1] = _rect
    end
end

local _NeedUpdate = true
local _Times = 0
app.update(function(e)
    if _NeedUpdate == false then
        return
    end
    -- _NeedUpdate = false
    _Times = _Times + e

    for i = 1, X_Numer do
        for j = 1, Y_Numer do
            local _Index = (i - 1) * Y_Numer + j

            local _Center = _Rects[_Index]:GetCenter()

            local _TempValue = _Center - _StartPos
            _TempValue = _TempValue / (_Offset * Vector.new(X_Numer , Y_Numer) * 0.3)
            local _NewCenter = CurlNoise.Process(_TempValue, _Times) * (0.0625*0.5) + _Center
            -- log('aaaaaaa', _Index, _Center.x, _Center.y, _NewCenter.x, _NewCenter.y)
            -- local _Start = _StartPos + _Offset * Vector.new(_NewCenter.x, _NewCenter.y)
            -- _Rects[i]:SetCenterPosition(_Start.x + 2, _Start.y + 2)
            _Rects[_Index]:SetCenterPosition(_NewCenter.x, _NewCenter.y)
        end
    end

end)

app.render(function(e)
    for i = 1, #_Rects do
        _Rects[i]:draw()
    end
end)
