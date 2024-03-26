local Rects = {}

local StartV = Vector.new()

local EndV = Vector.new(RenderSet.screenwidth , RenderSet.screenheight )

local VoxelSize = Vector.new(20,30)
local S = Vector.new(RenderSet.screenwidth * 0.5, RenderSet.screenheight * 0.5)

local Dir = Vector.new(-1, -1)

local Results = DDARayTrace.GetTest2DResult(StartV, EndV, S, Dir, VoxelSize)

for i = 1, #Results do
    local r = Results[i]
    local rect = Rect.new(r.x * VoxelSize.x, r.y * VoxelSize.y, VoxelSize.x, VoxelSize.y)
    Rects[#Rects + 1] = rect

    if i == 1 then
        rect:setColor(255,0,0,255)
    elseif i == #Results then
        rect:setColor(0,255,0,255)
    end
end

app.render(function(dt)
   for i = 1, #Rects do
        Rects[i]:draw()
   end

end)