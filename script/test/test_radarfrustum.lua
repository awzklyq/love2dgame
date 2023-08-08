
math.randomseed(os.time()%10000)
local far = 400
local near = 100
local pos = Vector.new(RenderSet.screenwidth * 0.5, RenderSet.screenheight * 0.5)
local frustum = RadarFrustum2D.new(pos, Vector.new(0, 1), math.rad(90), near, far)
local triangle = Triangle2D.new(Vector.new(), Vector.new(), Vector.new())
local rect1
local rect2
local rect3
local rect4

local anglespeed = math.rad(20)
local angle =0
local NearLine
-- mat:faceTo(dir.x, dir.y)

local Points = {}
local Rects = {}
for i = 1, 80 do
    local x = math.random(pos.x - far, pos.x + far );
    local y = math.random(pos.y - far, pos.y + far )
    local p = Vector.new(x, y)

    local rect = Rect.new(x - 5, y -5, 10, 10)

    rect:setColor(0, 255, 0, 255)
    Points[#Points + 1] = p
    Rects[#Rects + 1] = rect
end

local CheckInPoints = function ()
    for i = 1, #Points do
        if frustum:IsPointIn(Points[i]) then
            Rects[i]:setColor(0, 255, 0, 255)
        else
            Rects[i]:setColor(255, 0, 0, 255)
        end
    end
end

local CreateTriFromFrustum = function ()
    triangle = frustum:GetTriangle()

    rect1 = Rect.new( triangle.P1.x, triangle.P1.y, 8, 8)
    rect1:setColor(255, 0, 0, 255)
    rect2 = Rect.new( triangle.P2.x, triangle.P2.y, 8, 8)
    rect2:setColor(0, 0, 255, 255)
    rect3 = Rect.new( triangle.P3.x, triangle.P3.y, 8, 8)
    rect3:setColor(0, 255, 0, 255)

    local rv4 = frustum.Position + frustum.Forward
    rect4 =  Rect.new( rv4.x,rv4.y, 8, 8)
    rect4:setColor(0, 255, 255, 255)

    NearLine = frustum:GetNearLine()
    NearLine:setColor(255,255,0,255)
end

CreateTriFromFrustum()

app.render(function(dt)
    triangle:draw()

    -- rect1:draw()
    -- rect2:draw()
    -- rect3:draw()
    -- rect4:draw()

    for i = 1, #Rects do
        Rects[i]:draw()
    end

    NearLine:draw()
end)

local needupdate = true
app.update(function(dt)
    if not needupdate then return end
    angle = angle + anglespeed * dt
    frustum:SetDirection(Vector.new(math.sin(angle), math.cos(angle)))
    CreateTriFromFrustum()
    CheckInPoints()
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        needupdate = not needupdate
    elseif key == "a" then
        log("dir", frustum.Direction.x, frustum.Direction.y)
    -- elseif key == "b" then
    --     scene.needTAA = not scene.needTAA
    -- elseif key == "n" then
    --     scene.needFXAA = not scene.needFXAA
    -- elseif key == "z" then
    --     RenderSet.HDR = not RenderSet.HDR
    --     HDRSetting(RenderSet.HDR)

    --     scene:reseizeScreen(RenderSet.screenwidth, RenderSet.screenheight)
    -- elseif key == "c" then
    --     scene.needToneMapping = not scene.needToneMapping
    -- elseif key == "up" then
    --     Bloom2.Adapted_lum = math.clamp(0, 1,Bloom2.Adapted_lum  + 0.05)
    -- elseif key == "down" then
    --     Bloom2.Adapted_lum = math.clamp(0, 1,Bloom2.Adapted_lum  - 0.05)
    -- elseif key == "right" then
    --     Bloom2.ClamptBrightness = math.clamp(0, 1,Bloom2.ClamptBrightness  + 0.05)
    -- elseif key == "left" then
    --     Bloom2.ClamptBrightness = math.clamp(0, 1, Bloom2.ClamptBrightness  - 0.05)
    end
end)