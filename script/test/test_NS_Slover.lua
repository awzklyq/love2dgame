--Real-Time Fluid Dynamics for Games ：Jos Stam

math.randomseed(os.time()%10000)

local _StartX = 50
local _StartY = 50
local _W = 400
local _H = 400
local NSE = NavierStokesEquations.new(_StartX, _StartY, _W, _H, 80, 80)

app.render(function(dt)
    NSE:draw()
end)

app.update(function(dt)
    NSE:update(dt)
end)

app.mousepressed(function(x, y, button, istouch)
    log(x, y)
    -- NSE:SetPositionColor(x, y, LColor.Blue)
    NSE:SetPositionDensity(x, y, 300)
    for i = 1, 20 do
        local SpeedX = math.random(-100, 100) * 0.001, math.random(-100, 100) * 0.001
        local SpeedY = math.random(-100, 100) * 0.001, math.random(-100, 100) * 0.001
        log("Speed", SpeedX, SpeedY)
        --log(math.random(_StartX, _StartX + _W), math.random(_StartY, _StartY + _H), math.random(0, 100) * -1)
        NSE:SetPositionVelocity(math.random(_StartX, _StartX + _W), math.random(_StartY, _StartY + _H), SpeedX, SpeedY)
    end
end)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "Wireframe" )
checkb.ChangeEvent = function(Enable)
    RenderSet.SetWireframe(Enable)
end