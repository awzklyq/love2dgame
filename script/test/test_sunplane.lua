local TestBillBoard = BillBoard.GetDefaultSunPlane(200, 200, 20)--BillBoard.new(100, 100)

local aixs = Aixs.new(0,0,0, 200)
aixs:SetTransform(TestBillBoard.transform3d)
app.render(function(dt)
    TestBillBoard:draw()

    -- aixs:draw()
end)


app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        log(currentCamera3D.eye.x, currentCamera3D.eye.y, currentCamera3D.eye.z)
        log(currentCamera3D.look.x, currentCamera3D.look.y, currentCamera3D.look.z)
    end
end)


currentCamera3D.eye = Vector3.new( 8.3342936041166, -94.458477470116    ,    84.802622837569)
currentCamera3D.look = Vector3.new( 0, 0, -1)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "Test Use Scatter" )
checkb.ChangeEvent = function(Enable)
    if Enable then
        TestBillBoard.shader = Shader.GetBillBoardSunInScatterShader()
    else
        TestBillBoard.shader = Shader.GetBillBoardSunShader()
    end
end

local scrollbarR = UI.ScrollBar.new( 'Radius', 10, 40, 200, 40, 10, 100, 1)
scrollbarR.Value = 20
scrollbarR.ChangeEvent = function(v)
    TestBillBoard.Radius = v
end

local scrollbarP = UI.ScrollBar.new( 'Power', 10, 100, 200, 40, 0.1, 50, 0.1)
scrollbarP.Value = 1
scrollbarP.ChangeEvent = function(v)
    TestBillBoard.LightPower = v
end