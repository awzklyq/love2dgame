
local Rects = {}
local SR = Rect.new()
local ER = Rect.new()
local VoxelSize = Vector.new(20,30)

local GenerateRects = function()
    Rects = {}
    local S = Vector.new(math.random(VoxelSize.x , RenderSet.screenwidth - VoxelSize.x), math.random(VoxelSize.x , RenderSet.screenheight - VoxelSize.y))

    local EndP = Vector.new(math.random(VoxelSize.x , RenderSet.screenwidth - VoxelSize.x), math.random(VoxelSize.x , RenderSet.screenheight - VoxelSize.y))

    -- local S = Vector.new(687, 441)

    -- local EndP = Vector.new(549, 377)

    --     log('ccccc', S.x, S.y)
    -- log('bbbbbbb', EndP.x, EndP.y)
    -- log()
    local StartV = Vector.new(0, 0)

    local EndV = Vector.new(RenderSet.screenwidth , RenderSet.screenheight )

    local CurrentV = Vector.new(math.floor((S.x - StartV.x) / VoxelSize.x), math.floor((S.y - StartV.y) / VoxelSize.y))

    local EndV = Vector.new(math.floor((EndP.x - StartV.x) / VoxelSize.x), math.floor((EndP.y - StartV.y) / VoxelSize.y))

    local Results = DDARayTrace.GetTest2DResult2(StartV, EndV, S, EndP, VoxelSize)

    for i = 1, #Results do
        local r = Results[i]
        local rect = Rect.new(r.x * VoxelSize.x, r.y * VoxelSize.y, VoxelSize.x, VoxelSize.y)
        Rects[#Rects + 1] = rect
    end

    SR = Rect.new(CurrentV.x * VoxelSize.x, CurrentV.y * VoxelSize.y, VoxelSize.x, VoxelSize.y)
    SR:SetColor(255,0,0,255)
    ER = Rect.new(EndV.x * VoxelSize.x, EndV.y * VoxelSize.y, VoxelSize.x, VoxelSize.y)
    ER:SetColor(0,255,0,255)
end

GenerateRects()

app.render(function(dt)
   for i = 1, #Rects do
        Rects[i]:draw()
   end

   SR:draw()
   ER:draw()
end)

local btn = UI.Button.new( 10, 10, 100, 50, 'GenerateRects', 'btn' )

btn.ClickEvent = function()
    GenerateRects()
end

local scrollbar1 = UI.ScrollBar.new( 'VoxelSize X', 10, 60, 200, 40, 10, 100, 10)
scrollbar1.Value = VoxelSize.x
scrollbar1.ChangeEvent = function(v)
    VoxelSize.x = v
end

local scrollbar2 = UI.ScrollBar.new( 'VoxelSize X', 10, 110, 200, 40, 10, 100, 10)
scrollbar2.Value = VoxelSize.y
scrollbar2.ChangeEvent = function(v)
    VoxelSize.y = v
end