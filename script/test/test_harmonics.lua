FileManager.addAllPath("assert")

-- log('eeeeeeee', 1 /2  * math.sqrt( (15 / math.pi)))
-- local font = Font.new"minijtls.TTF"
-- font:Use()

math.randomseed(os.time()%10000)

local UniformSampleSphere = function( E )

    local Phi = 2 * math.pi * E.x;
    local CosTheta = 1 - 2 * E.y;
    local SinTheta = math.sqrt( 1 - CosTheta * CosTheta );

    local H = Vector3.new();
    H.x = SinTheta * math.cos( Phi );
    H.y = SinTheta * math.sin( Phi );
    H.z = CosTheta;

    local PDF = 1.0 / (4 * math.pi);

    return Vector4.new( H.x, H.y, H.z, PDF );
end

-- love.graphics.setWireframe( true )
local aixs = Aixs.new(0,0,0, 150)
local image = ImageEx.new("shtest.png")

local ImgData = love.image.newImageData(_G.FileManager.findFile"shtest.png")
log('aaaa', image.w, image.h)

local Normals = {}

local SampleSize = Vector.new(image.w, image.h)
local ImageData3 =love.image.newImageData(SampleSize.x, SampleSize.y)
local harmonics = Harmonics.new()
local dir = Vector3.new(math.random(), math.random(), math.random())
local basecolor = Vector3.new(math.random(), math.random(), math.random())
for x = 1, SampleSize.x - 1 do
    for y = 1, SampleSize.y - 1 do
        local r, g, b, a = ImgData:getPixel(x, y)
        local result = UniformSampleSphere(Vector.new(x / SampleSize.x , y / SampleSize.y))

        local nor = Vector3.new(result.x, result.y, result.z)

        local dot = Vector3.dot(nor, dir)
        local color =  basecolor * dot

        ImageData3:setPixel(x, y, color.x, color.y, color.z, 1)
        Normals[#Normals + 1] = {Normal = nor, Color =  color, X = x, Y = y}
    end
end
harmonics:Generate(Normals)

local ImageData2 =love.image.newImageData(SampleSize.x, SampleSize.y)
for i, v in pairs(Normals) do
    local Color = harmonics:GetColor(v.Normal)
    ImageData2:setPixel(v.X, v.Y, Color.x, Color.y, Color.z, 1)
end

local image2 = ImageEx.new(ImageData2)
local image3 = ImageEx.new(ImageData3)
local RenderImage  = true

app.render(function(dt)
    love.graphics.clear(0,0,0,1)
    aixs:draw()
    if RenderImage then
        image3:draw()
    else
        image2:draw()
    end

end)


app.keypressed(function(key, scancode)
    if key == "w" then
        log(currentCamera3D.eye.x,currentCamera3D.eye.y,currentCamera3D.eye.z)
        log(currentCamera3D.look.x,currentCamera3D.look.y,currentCamera3D.look.z)
    elseif key == 'a' then
        love.graphics.setWireframe( true )
    elseif key == 'z' then
        love.graphics.setWireframe( false )
    elseif key == "x" then
        RenderImage = not RenderImage
        log('xxxx', RenderImage)
    elseif key == "f" then
        
    elseif key == "g" then
    elseif key == "space" then
     
    end
end)