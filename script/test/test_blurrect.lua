FileManager.addAllPath("assert")

local image = ImageEx.new("itgongzuo.jpg")

local canvas = Canvas.new()

image.w = RenderSet.screenwidth
image.h = RenderSet.screenheight

local mesh = MeshQuadBlur.new( image.w , image.h, LColor.new(255,0,0,255))
mesh:BindImage(image)
mesh:BlurSize(100,100,400,400)
mesh.blurnum = 3
mesh.offset = 2

mesh.power = 0.75

local MainFont = Font.new"FZZJ-LCSSJW.TTF"
MainFont:Use()
app.render(function(dt)

    -- pushCanvas(canvas)
    love.graphics.clear()
    -- image:draw()
    -- popCanvas()

    image.w = RenderSet.screenwidth
    image.h = RenderSet.screenheight 

    mesh:draw()
    love.graphics.setColor(1,1,1);
    love.graphics.print("什么鬼名叫沙漠奥", 100, 100)
end)


app.keypressed(function(key, scancode, isrepeat)
    if key == "w" then
    end
end)