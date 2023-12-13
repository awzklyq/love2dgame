-- local a = -0.886528
-- local b = 5.268909
-- local A = 0.411259
-- local B = -0.548794

-- local a = 1.960518
-- local b = 1.558213
-- local A = 0.513282
-- local B = 4.561110

local a = -0.862325
local b = 1.624835
local A = 0.767583
local B = 1.862321
local IsUseFunctionValue1 = true

local GetFunctionValue1 = function(x)
    local x2 = x * x
    local result = math.exp(-a * x2) * (math.sin(b * x2))
    return result
end

local GetFunctionValue2 = function(x)
    local x2 = x * x
    local result = math.exp(-a * x2) * (math.cos(b * x2))
    return result
end

-- for i = -5, 5, 1 do
--     local angle = i-- math.rad(i)
--     log('aaa', i, angle,GetFunctionValue1(angle),  GetFunctionValue2(angle))
-- end

local Rects = {}
local size = 5
local Num = 128
local StartX = Num * 0.5
local StartY = Num * 0.5

local DealRealComponents = function(Rects, offset)
    local cc = Rects[StartX][StartY].color
    for i = -offset, offset do
        for j = -offset, offset do
            if i ~= 0 or j ~= 0 then
                --local v = IsUseFunctionValue1 and GetFunctionValue1(i * (1 / offset)) * A or GetFunctionValue2(i * (1 / offset)) * B
                -- local v = GetFunctionValue2(i * (1 / offset)) * B
                local v = GetFunctionValue1(i * (1 / Num)) * A +  GetFunctionValue2(j * (1 / Num)) * B
                local c = LColor.new(cc.r * v, cc.g * v, cc.b * v, 255)
                Rects[StartX + i][StartY + j].color = c
            end
        end
    end
end

local GenerateRects = function()
    Rects = {}
    for i = 1, Num do
        Rects[i] = {}
        for j = 1, Num do
            Rects[i][j] = Rect.new(i * size, j * size, size, size)
            Rects[i][j]:SetColor(0,0,0)
        end
    end

    Rects[StartX][StartY]:SetColor(255,255,255)

    DealRealComponents(Rects, 16)
end

GenerateRects()

app.render(function(dt)
    for i= 1, #Rects do
        for j= 1, #Rects[i] do
            Rects[i][j]:draw()
        end
    end

end)

local scrollbara = UI.ScrollBar.new( 'Set a', 0, 0, 200, 40, -10, 10, 0.001)
scrollbara.Value = a
scrollbara.ChangeEvent = function(v)
    a = v
    GenerateRects()
end

local scrollbarb = UI.ScrollBar.new( 'Set b', 0, 50, 200, 40, -10, 10, 0.001)
scrollbarb.Value = b
scrollbarb.ChangeEvent = function(v)
    b = v
    GenerateRects()
end

local scrollbarA = UI.ScrollBar.new( 'Set A', 0, 100, 200, 40, -10, 10, 0.001)
scrollbarA.Value = A
scrollbarA.ChangeEvent = function(v)
    A = v
    GenerateRects()
end

local scrollbarB = UI.ScrollBar.new( 'Set B', 0, 150, 200, 40, -10, 10, 0.001)
scrollbarB.Value = B
scrollbarB.ChangeEvent = function(v)
    B = v
    GenerateRects()
end

local checkb = UI.CheckBox.new( 0, 200, 20, 20, "IsUseFunctionValue1" )
checkb.IsSelect = IsUseFunctionValue1
checkb.ChangeEvent = function(Enable)
    IsUseFunctionValue1 = Enable
    GenerateRects()
end

local checkb2 = UI.CheckBox.new( 0, 250, 20, 20, "Change Parame" )
checkb2.IsSelect = true
checkb2.ChangeEvent = function(Enable)
    if Enable then
        a = -1.960518
        b = 1.558213
        A = 0.513282
        B = 4.561110
    else
        a = -0.886528
        b = 5.268909
        A = 0.411259
        B = -0.548794
    end
    GenerateRects()
end