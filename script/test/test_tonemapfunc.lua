local adapted_lum = 0.5

--Reinhard..
local ReinhardLine = {}
local ReinhardPoints = {}
function ReinhardToneMapping(x, adapted_lum) 
    local MIDDLE_GREY = 1;
    x = x *  MIDDLE_GREY / adapted_lum;
    return x / (1.0 + x);
end

--CETone..
local CEToneLine = {}
local CETonePoints = {}
function CEToneMapping(x, adapted_lum) 
    return 1 - math.exp(-adapted_lum * x)
end

--Uncharted2
local UnchartedLine = {}
local UnchartedPoints = {}
function F(x)
	local A = 0.22
	local B = 0.30
	local C = 0.10
	local D = 0.20
	local E = 0.01
	local F = 0.30
 
	return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
end

function Uncharted2ToneMapping(x,  adapted_lum)

	local WHITE = 11.2
	return F(1.6 * adapted_lum * x) / F(WHITE);
end

-- ACES
local ACESLine = {}
local ACESPoints = {}
function ACESToneMapping(x,  adapted_lum)
	local A = 2.51
	local B = 0.03
	local C = 2.43
	local D = 0.59
	local E = 0.14

	x = x * adapted_lum;
	return (x * (A * x + B)) / (x * (C * x + D) + E);
end

function CreateFunc()
    ReinhardLine = {}
    ReinhardPoints = {}
    CEToneLine = {}
    CETonePoints = {}
    UnchartedLine = {}
    UnchartedPoints = {}
    ACESLine = {}
    ACESPoints = {}

    local XN = {0.01, 0.011, 0.013, 0.017, 0.025, 0.041, 0.073, 0.137, 0.265, 0.521, 1.033, 2.057, 4.105, 8.201, 16.393, 32.777}
    local Step = #XN
    local SSS = 400
    local hw =  RenderSet.screenwidth * 0.5
    local hh =  RenderSet.screenheight * 0.5

    local offseth = 0
    local offsetw = 50

    -- ReinhardPoints[#ReinhardPoints + 1] = Vector.new(hw, hh)
    for i = 1, Step do
        ReinhardPoints[#ReinhardPoints + 1] = Vector.new(i * offsetw  + hw, hh - ReinhardToneMapping(XN[i], adapted_lum) * SSS + offseth)
    end
    
    for i = 1, #ReinhardPoints - 1 do
        ReinhardLine[#ReinhardLine + 1] = Line.new(ReinhardPoints[i].x, ReinhardPoints[i].y, ReinhardPoints[i + 1].x, ReinhardPoints[i + 1].y)
    
        ReinhardLine[#ReinhardLine]:setColor(255, 0, 0, 1)
    end

    -- CETonePoints[#CETonePoints + 1] = Vector.new(hw, hh)
    for i = 1, Step do
        CETonePoints[#CETonePoints + 1] = Vector.new(i * offsetw  + hw ,  hh -CEToneMapping(XN[i], adapted_lum) * SSS + offseth)

    end

    for i = 1, #CETonePoints - 1 do
        CEToneLine[#CEToneLine + 1] = Line.new(CETonePoints[i].x, CETonePoints[i].y, CETonePoints[i + 1].x, CETonePoints[i + 1].y)

        CEToneLine[#CEToneLine]:setColor(0, 255, 0, 1)
    end


    for i = 1, Step do
        UnchartedPoints[#UnchartedPoints + 1] = Vector.new(i * offsetw  + hw,  hh -Uncharted2ToneMapping(XN[i], adapted_lum) * SSS + offseth)

    end

    for i = 1, #CETonePoints - 1 do
        UnchartedLine[#UnchartedLine + 1] = Line.new(UnchartedPoints[i].x, UnchartedPoints[i].y, UnchartedPoints[i + 1].x, UnchartedPoints[i + 1].y)

        UnchartedLine[#UnchartedLine]:setColor(0, 0, 255, 1)
    end

    for i = 1, Step do
        -- ACESPoints[#ACESPoints + 1] = Vector.new(XN[i] * offsetw  + hw,  hh -ACESToneMapping(XN[i], adapted_lum) * SSS + offseth)
        ACESPoints[#ACESPoints + 1] = Vector.new(i * offsetw  + hw,  hh - ACESToneMapping(XN[i], adapted_lum) * SSS + offseth)
    end

    for i = 1, #CETonePoints - 1 do
        ACESLine[#ACESLine + 1] = Line.new(ACESPoints[i].x, ACESPoints[i].y, ACESPoints[i + 1].x, ACESPoints[i + 1].y)

        ACESLine[#ACESLine]:setColor(255, 255, 0, 1)
    end

   
end

CreateFunc()

local xnumbers = {}
local ynumbers = {}
local xaix = Line.new( )
local yaix = Line.new( )
function CreateAix()
    local startx1 = 0
    local starty1 = RenderSet.screenheight * 0.5

    local endx1 = RenderSet.screenwidth - 10
    local endy1 = starty1

    local startx2 = RenderSet.screenwidth * 0.5
    local starty2 = 10

    local endx2 = RenderSet.screenwidth * 0.5
    local endy2 = RenderSet.screenheight

    local ox = RenderSet.screenwidth * 0.5
    local oy = RenderSet.screenheight * 0.5

    xaix = Line.new(startx1, starty1, endx1, endy1)
    yaix = Line.new(startx2, starty2, endx2, endy2)

    xnumbers = {}
    ynumbers = {}
    --#region xnumbers
    local x1 = startx1 - ox
    local x2 = endx1 - ox

    local offsetaix = 40
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
        ynumbers[#ynumbers + 1] = {line = line, value = ( i % 10 - i) / 10, x = startx2, y = i + oy}
    end
    --#endregion
end
CreateAix()

function DrawAix()
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

end

app.render(function(dt)

    DrawAix()
    for i = 1, #ReinhardLine do
        ReinhardLine[i]:draw()
    end

    for i = 1, #CEToneLine do
        CEToneLine[i]:draw()
    end

    for i = 1, #UnchartedLine do
        UnchartedLine[i]:draw()
    end

    for i = 1, #ACESLine do
        ACESLine[i]:draw()
    end
end)


app.resizeWindow(function(w, h)
    CreateAix()
    CreateFunc()
end)