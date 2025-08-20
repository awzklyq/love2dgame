FileManager.addAllPath("assert")

JacoBianManager.Init()

local aixs = Aixs.new(0,0,0, 500)

local JBN1 = JacoBianNode.new(Vector3.new(0,0,300), nil, 50, 150)

local _V = Vector3.new(0, 1, 0)
local _Angle = 90
local _Quat = Quaternion.CreateFromAxisAndAngle(_V, _Angle)
JBN1.transform3d = JBN1.transform3d * _Quat
-- JBN1.transform3d = JBN1.transform3d:MulQuaternionLeft( _Quat)
-- JBN1.transform3d:mulRotationRight( _V.x ,_V.y, _V.z, math.rad(_Angle))

-- JBN1.transform3d = JBN1.transform3d * (_Quat * JBN1.transform3d)
JBN1:ResetRenderTransform()

app.render(function(dt)
    RenderSet.UseCanvasColorAndDepth()

    aixs:draw()

    JBN1:draw()

    RenderSet.ClearCanvasColorAndDepth()
    RenderSet.getCanvasColor():draw()

end)


app.keypressed(function(key, scancode, isrepeat)

end)

currentCamera3D.eye = Vector3.new( 150, 0, 0)
currentCamera3D.look = Vector3.new( 0, 0, 0)