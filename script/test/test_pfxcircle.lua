local PfxNumber = 200
local pfxduration = 3
local CR = 40
local C1 = LColor.new(0, 0, 255, 255)
local C2 = LColor.new(255, 0, 255, 255)
local CS = {}

local CC = Circle.new(CR, 200, 200)

local Timers = {}
local NextIndex = 1

local PlayCircle = function(index, x, y)
    CS[index].x = x
    CS[index].y = y
    CS[index].Visible = true
    Timers[index]:Start()
end

local SwitchCircle = function(x, y)
    PlayCircle(NextIndex, x, y)
    if NextIndex == PfxNumber then
        NextIndex = 1

    else
        NextIndex = NextIndex + 1
    end
    
end

local GenerateCircle = function()
    NextIndex = 1
    -- CC:SetMouseEventEable(false)
    CC = Circle.new(CR, CC.x, CC.y)
    CC:SetColor(C1)
    CC.mode = 'fill'

    CC:SetMouseEventEable(true)

   
    CC.MouseDownEvent = function(c, x, y)
        c.sx = x
        c.sy = y
    end
    CC.MouseMoveEvent = function(c, x, y)
        if c.sx == nil or c.sy == nil then return end

        SwitchCircle(c.x, c.y)
        c.x = c.x + (x - c.sx)
        c.y = c.y + (y - c.sy)

        c.sx = x
        c.sy = y
    end

    CC.MouseUpEvent = function(c, x, y)
        c.sx = nil
        c.sy = nil
    end
    
    for i = 1, #Timers do
        Timers[i]:Release()
    end

    CS = {}
    Timers = {}
   
    for i = 1, PfxNumber do
        local c = Circle.new(CR, 200, 200)
        CS[i] = c
        
        c:SetColor(C1)
        c.mode = 'fill'

        c.Visible = false
        Timers[i] = Timer.new(pfxduration)

        Timers[i].TriggerFrame = function(tick, duration)
            local t = tick / duration
            c.r = math.lerp(CR, 0, t)
            c.color.r = math.lerp(C1.r, C2.r, t)
            c.color.g = math.lerp(C1.g, C2.g, t)
            c.color.b = math.lerp(C1.b, C2.b, t)
            
        end

        Timers[i].TraggerEvent = function()
            c.Visible = false
        end
    end
end

GenerateCircle()

app.render(function(dt)
    for i = 1, PfxNumber do
        CS[i]:draw()
    end

    CC:draw()
end)

local scrollbar = UI.ScrollBar.new( 'Duration', 10, 10, 200, 40, 0.5, 10, 0.1)
scrollbar.Value = pfxduration
scrollbar.ChangeEvent = function(v)
    pfxduration = v
    GenerateCircle()
end

local scrollbar = UI.ScrollBar.new( 'PfxNumber', 250, 10, 200, 40, 100, 1000, 10)
scrollbar.Value = PfxNumber
scrollbar.ChangeEvent = function(v)
    PfxNumber = v
    GenerateCircle()
end

local cp1 = UI.ColorPlane.new( "color1", 10, 50, 30, 30)

cp1.Value = C1
cp1.ChangeEvent = function(value)
    C1:Set(value)
    GenerateCircle()
end

local cp2 = UI.ColorPlane.new( "color2", 70, 50, 30, 30)

cp2.Value = C2
cp2.ChangeEvent = function(value)
    C2:Set(value)
    GenerateCircle()
end