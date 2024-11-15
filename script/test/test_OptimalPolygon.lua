math.randomseed(os.time()%10000)

local NumberRects = 20
local Shrink = 300
local rsize = 8 * 0.5
local Rects = {}
local Points = {}
local Lines = {}
local OutIndices = {}
local OptimalLines = {}
local GenerateRects = function()
    Rects = {}
    Points = {}
    local w = RenderSet.screenwidth
    local h = RenderSet.screenheight

    local sx = w * 0.5
    local sy = h * 0.5

    for i = 1, NumberRects do
        local x = math.random(-Shrink, Shrink)
        local y = math.random(-Shrink, Shrink)

        local v = Vector.new(x, y)
        v:normalize();
        v = v * math.random(10, Shrink) + Vector.new(sx, sy) 
        Points[#Points + 1] = v
        
        local r = Rect.new(v.x - rsize, v.y - rsize, rsize, rsize)
        r:SetColor(255,255,0,255)
        Rects[#Rects + 1] = r
    end
end

local GenerateLines = function()
    Lines = {}
    if #Points <= 2 then
        return
    end

    OutIndices = {}
    math.ComputeConvexHull2(Points, OutIndices)

    if #OutIndices <= 1 then
        return
    end
    
    for i = 1, #OutIndices do
        local i1 = i
        local i2 = i + 1
        if i2 > #OutIndices then
            i2 = 1
        end

        local l = Line.new(Points[OutIndices[i1]].x, Points[OutIndices[i1]].y, Points[OutIndices[i2]].x, Points[OutIndices[i2]].y)
        l:SetColor(255, 0, 255, 255)
        Lines[#Lines + 1] = l
    end
end

local IsDrawOptLine = true
local IsDrawLastOptLine = true
app.render(function(dt)
    for i = 1, #Lines do
        Lines[i]:draw()
    end

    for i = 1, #Rects do
        Rects[i]:draw()
    end

    if IsDrawOptLine then
        for i = 1, #OptimalLines do
            if not IsDrawLastOptLine then
                if i == #OptimalLines then
                    break
                end
            end

            OptimalLines[i]:draw()
        end
    end
end)

local VertexCount = 8
local btn = UI.Button.new( 10, 10, 100, 50, 'Reset', 'btn' )
btn:setPressedColor(LColor.new(125, 125, 125))
btn.ClickEvent = function()
    GenerateRects()
    GenerateLines()

    local w = RenderSet.screenwidth
    local h = RenderSet.screenheight
    local OutData = {}
    OutData.OutBoundingVertices = {}
    math.FindOptimalPolygon(w, h, VertexCount, OutIndices, Points, OutData)
    local OutBoundingVertices = OutData.OutBoundingVertices
    -- OutBoundingVertices[#OutBoundingVertices + 1] = Points[OutIndices[1]]
    OptimalLines = {}
    for i = 1, #OutBoundingVertices do
        local i1 = i
        local i2 = i + 1
        if i2 > #OutBoundingVertices then
            i2 = 1
        end

        local l = Line.new(OutBoundingVertices[i1].x, OutBoundingVertices[i1].y, OutBoundingVertices[i2].x, OutBoundingVertices[i2].y)
        l:SetColor(100, 255, 255, 255)
        OptimalLines[#OptimalLines + 1] = l
    end
end

local scrollbar = UI.ScrollBar.new( 'test', 10, 80, 200, 40, 10, 1000, 5)
scrollbar.Value = NumberRects
scrollbar.ChangeEvent = function(v)
    NumberRects = v
end

local checkb = UI.CheckBox.new( 10, 120, 20, 20, "Is Draw Opt" )
checkb.IsSelect = IsDrawOptLine
checkb.ChangeEvent = function(Enable)
    IsDrawOptLine = Enable
end

local checkb1 = UI.CheckBox.new( 10, 150, 20, 20, "Is Draw Last Opt" )
checkb1.IsSelect = IsDrawLastOptLine
checkb1.ChangeEvent = function(Enable)
    IsDrawLastOptLine = Enable
end

local cb = UI.ComboBox.new(10, 170, 100, 40, {"Value 4", "Value 6", "Value 8"})
cb.Value = "Value 8"
cb.ChangeEvent = function(value)
    log('rrrrrrrrr',value)
    if value == "Value 8" then
        VertexCount = 8
    elseif value == "Value 6" then
        VertexCount = 6
    elseif value == "Value 4" then
        VertexCount = 4
    end

    btn.ClickEvent()
end