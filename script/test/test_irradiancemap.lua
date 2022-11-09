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

local GetAngel = function( E )

    local Phi = 2 * math.pi * E.x;
    local CosTheta = 1 - 2 * E.y;
    local Theta = math.acos(CosTheta)
    return Vector.new(Phi, Theta)
end

local GetHalfSphereSample = function( E )
    local xx = (E.x * 0.5) / math.pi
    local yy = (1 - math.cos(E.y)) * 0.5
    return Vector.new(xx, yy)
end

-- love.graphics.setWireframe( true )
local aixs = Aixs.new(0,0,0, 150)
local image = ImageEx.new("itgongzuo.jpg")

local ImgData = love.image.newImageData(_G.FileManager.findFile"itgongzuo.jpg")
log('aaaa', image.w, image.h)

local Normals = {}

local SampleSize = Vector.new(image.w, image.h)
local harmonics = Harmonics.new()
for x = 1, SampleSize.x - 1 do
    for y = 1, SampleSize.y - 1 do
        local r, g, b, a = ImgData:getPixel(x, y)
        local result = UniformSampleSphere(Vector.new(x / SampleSize.x , y / SampleSize.y))

        local nor = Vector3.new(result.x, result.y, result.z)
        nor:normalize()
        local color = Vector3.new(r, g, b)
        Normals[#Normals + 1] = {Normal = nor, Color =  color, X = x, Y = y}
    end
end
harmonics:Generate(Normals)

local ImageData2 =love.image.newImageData(SampleSize.x, SampleSize.y)
for i, v in pairs(Normals) do
    local Color = harmonics:GetColor(v.Normal)
    ImageData2:setPixel(v.X, v.Y, Color.x, Color.y, Color.z, 1)
end

---------------
Normals = {}
harmonics = Harmonics.new()
local ImageData4 =love.image.newImageData(SampleSize.x, SampleSize.y)

local offsetx = math.rad(2)
local offsety = math.rad(2)
local halfpi = math.rad(60)

for x = 1, SampleSize.x - 1 do
    for y = 1, SampleSize.y - 1 do
        local AngeV = GetAngel(Vector.new(x / SampleSize.x, y / SampleSize.y))
        local nor = UniformSampleSphere(Vector.new(x / SampleSize.x , y / SampleSize.y))
        nor = Vector3.new(nor.x, nor.y, nor.z)
        nor:normalize()
        local cc = Vector4.new(0,0,0,0)
        local icount = 0
        for ia = AngeV.x - halfpi, AngeV.x + halfpi, offsetx do
            for ja = AngeV.y - halfpi, AngeV.y + halfpi, offsety do
                local SphereXY = GetHalfSphereSample(Vector.new(ia, ja))
                local SphereNor = UniformSampleSphere(Vector.new(SphereXY.x ,SphereXY.y))
                SphereNor = Vector3.new(SphereNor.x, SphereNor.y, SphereNor.z)
                SphereNor:normalize()
                local ssize = Vector.new(SphereXY.x * SampleSize.x, SphereXY.y * SampleSize.y)
                if ssize.x < 0 then
                    ssize.x = ssize.x + SampleSize.x
                elseif ssize.x > SampleSize.x then
                    ssize.x = ssize.x - SampleSize.x
                end

                if ssize.y < 0 then
                    ssize.y = ssize.y + SampleSize.y
                elseif ssize.y > SampleSize.y then
                    ssize.y = ssize.y - SampleSize.y
                end

                local dot = Vector4.dot3(SphereNor, nor)
                ssize.x = math.clamp(ssize.x, 0, SampleSize.x )
                ssize.y = math.clamp(ssize.y, 0, SampleSize.y )
                local r, g, b, a = ImgData:getPixel(ssize.x, ssize.y)
                cc.x = cc.x + dot * r
                cc.y = cc.y + dot * g
                cc.z = cc.z + dot *  b
                cc.w = cc.w + dot * a
                icount = icount + 1
            end
        end
         
        local result = UniformSampleSphere(Vector.new(x / SampleSize.x , y / SampleSize.y))

        local nor = Vector3.new(result.x, result.y, result.z)
        nor:normalize()
        
        cc = cc / icount
        local color = Vector3.new(cc.x, cc.y, cc.z)
        ImageData4:setPixel(x, y, color.x, color.y, color.z, 1)
        Normals[#Normals + 1] = {Normal = nor, Color =  color, X = x, Y = y}
    end
end

harmonics:Generate(Normals)

local ImageData3 =love.image.newImageData(SampleSize.x, SampleSize.y)
for i, v in pairs(Normals) do
    local Color = harmonics:GetColor(v.Normal)
    ImageData3:setPixel(v.X, v.Y, Color.x, Color.y, Color.z, 1)
end

local image2 = ImageEx.new(ImageData2)
local image3 = ImageEx.new(ImageData3)
local image4 = ImageEx.new(ImageData4)
local RenderImage  = 0

app.render(function(dt)
    love.graphics.clear(0,0,0,1)
    aixs:draw()
    if RenderImage == 0 then
        image:draw()
    elseif RenderImage == 1 then
        image2:draw()
    elseif RenderImage == 2 then
        image3:draw()
    elseif RenderImage == 3 then
        image4:draw()
    end

end)


app.keypressed(function(key, scancode)
    if key == "space" then
        RenderImage = (RenderImage + 1) % 4

        log('xxxx', RenderImage)
    end
end)