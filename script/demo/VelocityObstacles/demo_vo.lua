FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)

dofile('script/demo/VelocityObstacles/demo_VOMoveObject.lua')

LMVelocityObstacles.IsDrawCone2D = true

local Speed = 2;
local mo1 = DemoVOMoveObject.new(200, 200, 50, Vector.new(1, 0), 150 * Speed)
mo1.IsNeedAvoidObstacles = true
LMVelocityObstacles.AddObj(mo1)

mo1.circle:SetColor(255,255,0,255)

function GetRandomPosition()
    local x = math.random(10, RenderSet.screenwidth - 10)
    local y = math.random(10, RenderSet.screenheight - 10)
    return Vector.new(x, y)
end

local NumnerMO = 3
local MOS = {}
local function GenenrateMVO(InNumber)
    MOS = {}
    for i = 1, InNumber do
        local DefaultPos = GetRandomPosition()
        local mo2 = DemoVOMoveObject.new(DefaultPos.x, DefaultPos.y, 50, Vector.new(1, 0), 30 * Speed)
        mo2.IsNeedAvoidObstacles = true
        LMVelocityObstacles.AddObj(mo2)

        mo2.ArrivedTargetCallFunc = function(This, x, y)
            local pos = GetRandomPosition()
            This:MoveToXY(pos.x, pos.y)
        end

        local pos = GetRandomPosition()
        mo2:MoveToXY(pos.x, pos.y)

        MOS[#MOS + 1] = mo2
    end
    
end

GenenrateMVO(NumnerMO)

app.update(function(dt)
end)


app.render(function(dt)
    for i = 1, #MOS do
        MOS[i]:draw()
    end

    mo1:draw()
end)

app.mousepressed(function(x, y, button, istouch)
    if button == 1 then
        mo1:MoveToXY(x, y)
    end
end)