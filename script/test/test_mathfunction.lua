local startx1, starty1, endx1, endy1, startx2, starty2, endx2, endy2, ox, oy

local offsetaix = 40

local xnumbers = {}
local ynumbers = {}

local xaix = Line.new(startx1, starty1, endx1, endy1) 
local yaix = Line.new(startx2, starty2, endx2, endy2)

local IsTime = true
local scalex = 30
local scaley = 30
local startv = -100
local endv = 100
local offset = 2

local speed = 300

local starttemp = endv
local endtemp = endv
local dttemp = 0;
local k = 5
function GetFunction(x)
    local f = (math.sin(x) + 1) * 0.5
    return math.pow(f, k) * 2
end

local values = {}
local linevalues = Lines.new()
function GetValues()
    values = {}
    linevalues:clearValues()
    for i = startv, endv, offset do
        values[#values + 1] = {x = i * scalex, y = GetFunction(i * scalex) * scaley}
        linevalues:addValue(values[#values].x + ox, -values[#values].y + oy)
    end
end

app.update(function(dt)
    if not IsTime then return end 

    local NeedAdd = 0
   
    dttemp = dttemp + dt * speed
    for i = #values, 1, -1 do
        values[i].x = values[i].x - dt * speed
        linevalues.values[i].x = values[i].x + ox
        if values[i].x < startv * scalex then
            linevalues:removeValueFromIndex(i)
            table.remove(values, i)
            NeedAdd = NeedAdd + 1
        end
    end

    if NeedAdd > 0 then
        endtemp = starttemp + NeedAdd *offset - 1
        -- for i = starttemp, endtemp, offset do
        --     values[#values + 1] = {x = i * scalex, y = GetFunction(i * scalex) * scaley}
        --     linevalues:addValue(values[#values].x + ox, -values[#values].y + oy)

        --     values[#values].x = values[#values].x -dt * speed
        --     linevalues.values[#values].x = values[#values].x + ox
        -- end

        starttemp = endtemp
        -- log('aaaaaaaaa',NeedAdd)
        -- for i = endv - offset * NeedAdd + 1, endv, offset do
            
        --     values[#values + 1] = {x = i * scalex, y = GetFunction(i * scalex) * scaley}
        --     linevalues:addValue(values[#values].x + ox, -values[#values].y + oy)
        -- end
        -- log('bbbbbbbbbbb',#values, values[#values].x)
    end
end)
app.render(function(dt)
    for i = 1, #xnumbers do
        local xn = xnumbers[i]
        xn.line:draw()
        love.graphics.print(tostring(xn.value), xn.x, xn.y + 10)
    end

    for i = 1, #ynumbers do
        local yn = ynumbers[i]
        yn.line:draw()

        love.graphics.print(tostring(yn.value), yn.x - 30, yn.y)
    end

    xaix:draw()
    yaix:draw()

    linevalues:draw()

end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        for i = 1, #linevalues.values do
            log('aaaaaaaa',  i, #linevalues.values, values[i].x, linevalues.values[i].x, linevalues.values[i].y)
        end
    end
end)

app.resizeWindow(function(w, h)
    resize()
end)


function resize()
    startx1 = 0
    starty1 = RenderSet.screenheight * 0.5

    endx1 = RenderSet.screenwidth - 10
    endy1 = starty1

    startx2 = RenderSet.screenwidth * 0.5
    starty2 = 10

    endx2 = RenderSet.screenwidth * 0.5
    endy2 = RenderSet.screenheight

    ox = RenderSet.screenwidth * 0.5
    oy = RenderSet.screenheight * 0.5

    xaix = Line.new(startx1, starty1, endx1, endy1)
    yaix = Line.new(startx2, starty2, endx2, endy2)

    xnumbers = {}
    ynumbers = {}
    --#region xnumbers
    local x1 = startx1 - ox
    local x2 = endx1 - ox
    for i = x1, x2, offsetaix do
        local line = Line.new(i + ox, starty1, i + ox, starty1 - 10)
        line:setColor(200, 0, 0, 255)
        xnumbers[#xnumbers +1] = {line = line, value = (i - i % 10) / 10, x = i + ox, y = starty1}
    end
    --#endregion

    --#region ynumbers
    local y1 = starty2 - oy
    local y2 = endy2 - oy
    for i = y1, y2, offsetaix do
        local line = Line.new(startx2, i + oy, startx2 + 10, i + oy)
        line:setColor(200, 0, 0, 255)
        ynumbers[#ynumbers + 1] = {line = line, value = (y1 - y1 % 10) / 10, x = startx2, y = i + oy}
    end
    --#endregion

    GetValues()
end

resize()