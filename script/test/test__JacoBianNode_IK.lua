FileManager.addAllPath("assert")

JacoBianManager.Init()

local aixs = Aixs.new(0,0,0, 150)

local JBN1 = JacoBianNode.new(Vector3.new(0,0,100), nil, 50, 150)

local JBN2 = JacoBianNode.new(Vector3.new(0,0,100), nil, 50, 150)

local JBN3 = JacoBianNode.new(Vector3.new(0,0,100), nil, 50, 150)

local JBN4 = JacoBianNode.new(Vector3.new(0,0,100), nil, 50, 150)

local JBN5 = JacoBianNode.new(Vector3.new(0,0,100), nil, 50, 150)

local JBN6 = JacoBianNode.new(Vector3.new(0,0,100), nil, 50, 150)

JBN1:AddSubNode(JBN2)
JBN2:AddSubNode(JBN3)
JBN3:AddSubNode(JBN4)
JBN4:AddSubNode(JBN5)
JBN5:AddSubNode(JBN6)

-- JacoBianManager.SeleteRootNode()
-- JacoBianManager.SeleteEndNode()

local _TargetPosition = Vector3.new(1,2,3):normalize()

JacoBianManager.SetTargetPosition(_TargetPosition * 500)
JacoBianManager.CacleJocaBianMatrix()
app.render(function(dt)
    RenderSet.UseCanvasColorAndDepth()

    aixs:draw()

    JacoBianManager.DrawNodes()

    RenderSet.ClearCanvasColorAndDepth()
    RenderSet.getCanvasColor():draw()

end)


app.keypressed(function(key, scancode, isrepeat)
    if key == "w" then
        JBN1.transform3d:mulRotationLeft(1,0,0, 5)
        JBN1:ResetRenderTransform()
    end
end)

currentCamera3D.eye = Vector3.new( 150, 0, 0)
currentCamera3D.look = Vector3.new( 0, 0, 0)