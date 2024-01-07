FileManager.addAllPath("assert")
dofile('script/demo/ball/demo_ball_motionmanager.lua')
math.randomseed(os.time()%10000)

local resulttype = dofile('script/demo/ball/demo_ball_type.lua')
local Common = dofile('script/demo/ball/demo_ball_common.lua')
_G.BallDatas = {}
BallDatas.Rect1 = nil
BallDatas.Rect2 = nil
BallDatas.rayMian = nil
BallDatas.Rects = {}
BallDatas.RectSeleted = {}
BallDatas.PointSeleted = {}
BallDatas.RaySeleted = {}
local VE = resulttype.VE
local RectType = resulttype.RectType
BallDatas.RectType = RectType
BallDatas.RectTypes = {}
BallDatas.CircleRole = nil
BallDatas.MCE = nil 
BallDatas.VE = VE

local GenerateOffset = 3
local scrollbar = UI.ScrollBar.new( 'GenerateOffset', 150, 10, 200, 40, 3, 8, 1)
scrollbar.Value = GenerateOffset
scrollbar.ChangeEvent = function(v)
    GenerateOffset = v
end

local ScaleDistance = 1
local scrollbar2 = UI.ScrollBar.new( 'Scale Distance', 370, 10, 200, 40, 0.1, 3, 0.1)
scrollbar2.Value = ScaleDistance
scrollbar2.ChangeEvent = function(v)
    ScaleDistance = v
    VE:ScaleDistace(ScaleDistance)
end

local scrollbar3 = UI.ScrollBar.new( 'Scale Speed', 600, 10, 200, 40, 0.01, 1, 0.05)
scrollbar3.Value = 1
scrollbar3.ChangeEvent = function(v)
    BallDatas.MCE.Speed = v
end


Common.GenerateRects(BallDatas)
local TempRect = Rect.new()

TempRect.mode = 'line'
app.render(function(dt)
    for i = 1, #BallDatas.Rects do
        local rect = BallDatas.Rects[i]
        rect:draw()
        TempRect.x = rect.x
        TempRect.y = rect.y
        TempRect.w = rect.w
        TempRect.h = rect.h

        if rect.IsDelete then
            TempRect:SetColor(255,0,0,255)
        else
            TempRect:SetColor(255,255,255,255)
        end
        TempRect:draw()
    end


    BallDatas.Rect1:draw()
    BallDatas.Rect2:draw()
    BallDatas.rayMian:draw()

    for i = 1, #BallDatas.RaySeleted do
        BallDatas.RaySeleted[i]:draw()
    end

    for i = 1, #BallDatas.PointSeleted do
        BallDatas.PointSeleted[i]:draw()
    end

    BallDatas.CircleRole:draw()

end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        Common.GenerateRects(BallDatas, GenerateOffset)
    end

end)
