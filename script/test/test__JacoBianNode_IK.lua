FileManager.addAllPath("assert")

local aixs = Aixs.new(0,0,0, 150)

local _JocaBianNode = JocaBianNode.new(Vector3.new(0,0,0), nil, 50, 150)
app.render(function(dt)
    RenderSet.UseCanvasColorAndDepth()

    aixs:draw()

    _JocaBianNode:draw()
    RenderSet.ClearCanvasColorAndDepth()
    RenderSet.getCanvasColor():draw()

end)


app.keypressed(function(key, scancode, isrepeat)
    if key == "w" then
        _JocaBianNode.transform3d:mulScalingLeft(2,2,2)
    end
end)

currentCamera3D.eye = Vector3.new( 150, 0, 0)
currentCamera3D.look = Vector3.new( 0, 0, 0)