local vertices = {100, 100, 100, 370, 400, 370}


local mesh = Mesh.CreteMeshFormSimpleConcavePolygon(vertices, LColor.new(255, 0, 0))

local settings = {type  = "2d", format="rg11b10f", readable=true, msaa=0, dpiscale=(love.graphics.getDPIScale()), mipmaps="none"}
local canvas = Canvas.new(800, 600, settings)
canvas.bgColor = LColor.new(100, 100, 100)

canvas.transform:moveTo(100, 100)
canvas.transform:scale(0.5, 0.5)
app.render(function(dt)
    _G.pushCanvas(canvas)
    mesh:draw()
    _G.popCanvas()

    canvas:draw()
end)