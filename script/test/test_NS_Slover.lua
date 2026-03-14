--Real-Time Fluid Dynamics for Games ：Jos Stam

math.randomseed(os.time()%10000)

local NSE = NavierStokesEquations.new(50, 50, 500, 500, 10, 10)

app.render(function(dt)
    NSE:draw()
end)


app.mousepressed(function(x, y, button, istouch)
    log(x, y)
    NSE:SetPositionColor(x, y, LColor.Blue)
end)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "Wireframe" )
checkb.ChangeEvent = function(Enable)
    RenderSet.SetWireframe(Enable)
end