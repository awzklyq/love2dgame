math.randomseed(os.time()%10000)
RenderSet.BGColor = LColor.new(80,80,80,255)

local IsInCollection = function(InCollections, InV)
    for i = 1, #InCollections do
        if InCollections[i] == InV then
            return true
        end
    end

    return false
end

local AddCollection = function(InCollections, InV)
    local IsNeedAdd = not IsInCollection(InCollections, InV)

    if IsNeedAdd then
        InCollections[#InCollections + 1] = InV
    end
end

local SubCollection = function(InCollections, InV)
    for i = 1, #InCollections do
        if InCollections[i] == InV then
            table.remove(InCollections, i)
            break
        end
    end
end

local DealRectClickEvent = function(InControl, InCollections, InV)
    if InControl == 1 then
        SubCollection(InCollections, InV)
    else
        AddCollection(InCollections, InV)
    end
end

local A = {}
local B = {}

local M = 15
local N = 15
local mat = Matrixs.new(M, N)

local M2 = 5
local N2 = 5

local MidX = 3
local MidY = 3

local mat2 = Matrixs.new(M2, N2)

local GenerateDrawGrayDatas = function()
    mat:GenerateDrawGrayDatas(50, 50, 500, 500)
    local DrawGrayRects = mat:GetDrawGrayDatas()
    for i = 1, M do
        for j = 1, N do
            local r = DrawGrayRects[i][j]
            r:SetMouseEventEable(true)
            r._I = i
            r._J = j
            r.MouseUpEvent = function(ThisRect, x, y, ButtonValue)
                local V = ButtonValue == 1 and 1 or 0
                mat[ThisRect._I][ThisRect._J] = V
                ThisRect:SetColor(V * 255, V * 255, V * 255, 255)
                DealRectClickEvent(V, A, Vector.new(i, j))
            end
        end
    end
end

local ResetDatas = function()
    for i = 1, M do
        for j = 1, N do
            mat:SetValue(i, j, 1)
        end
    end

    GenerateDrawGrayDatas()

    for i = 1, M2 do
        for j = 1, N2 do
            mat2:SetValue(i, j, 1)
        end
    end

    mat2:GenerateDrawGrayDatas(600, 50, 100, 100)
    local DrawGrayRects2 = mat2:GetDrawGrayDatas()
    for i = 1, M2 do
        for j = 1, N2 do
            local r = DrawGrayRects2[i][j]
            r:SetMouseEventEable(true)
            r._I = i
            r._J = j
            r.MouseUpEvent = function(ThisRect, x, y, ButtonValue)
                local V = ButtonValue == 1 and 1 or 0
                mat[ThisRect._I][ThisRect._J] = V
                ThisRect:SetColor(V * 255, V * 255, V * 255, 255)

                DealRectClickEvent(V, B, Vector.new(i - MidX, j - MidY))
            end
        end
    end

    A = {}
    B = {}
end

ResetDatas()

app.render(function(dt)
    mat:DrawGrayDatas()
    mat2:DrawGrayDatas()
end)


local ExpandCollection = function()
    -- for i = 1, #B do
    --     log('B Value', B[i].x, B[i].y)
    -- end

    local NewA = {}
    for i = 1, #A do
        for j = 1, #B do
            local NewV = A[i] + B[j]
            NewV.x =  math.clamp(NewV.x, 1, N)
            NewV.y =  math.clamp(NewV.y, 1, M)

            AddCollection(NewA, NewV)
        end
    end

    for i = 1, M do
        for j = 1, N do
            local V = IsInCollection(NewA, Vector.new(i, j)) and 0 or 1
            mat[i][j] = V
        end
    end

    GenerateDrawGrayDatas()

    A = NewA
end

local ResetBtn = UI.Button.new( 10, 10, 50, 30, 'Reset', 'btn' )

ResetBtn.ClickEvent = function()
    ResetDatas()
end

local AddBtn = UI.Button.new(80, 10, 50, 30, 'Add', 'btn' )
AddBtn.ClickEvent = function()
    ExpandCollection()
end

local CorrodeCollection = function()
    local NewA = {}
    for i = 1, #A do
        for j = 1, #B do
            local NewV = A[i] + B[j]
            NewV.x =  math.clamp(NewV.x, 1, N)
            NewV.y =  math.clamp(NewV.y, 1, M)

            if IsInCollection(A, NewV) then
                AddCollection(NewA, NewV)
            end
        end
    end

    for i = 1, M do
        for j = 1, N do
            local V = IsInCollection(NewA, Vector.new(i, j)) and 0 or 1
            mat[i][j] = V
        end
    end

    GenerateDrawGrayDatas()

    A = NewA
end

local SubBtn = UI.Button.new( 150, 10, 50, 30, 'Sub', 'btn' )

SubBtn.ClickEvent = function()
    CorrodeCollection()
end
