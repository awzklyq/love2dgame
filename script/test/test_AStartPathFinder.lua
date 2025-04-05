
local AStartPath = AStartPathFinder.new(50, 50, 800, 800, 32, 32)

local StartGrid = nil
local TargetGrid = nil
app.render(function(dt)

    AStartPath:draw()
end)

app.mousepressed(function(x, y, button, istouch)
    local grid = AStartPath:GetGridFromXY(x, y)
    if grid then
        if button == 1 then
            if StartGrid then
                StartGrid:SetColor(LColor.Black)
            end
    
            StartGrid = grid
            if StartGrid then
                StartGrid:SetColor(LColor.Red)
            end
        elseif button == 2 then
            if TargetGrid then
                TargetGrid:SetColor(LColor.Black)
            end
    
            TargetGrid = grid
            if TargetGrid then
                TargetGrid:SetColor(LColor.Blue)
            end
        elseif button == 3 then
            if grid then
                grid:SetCanReach(not grid:CanReach())
    
                if  grid:CanReach() then
                    grid:SetColor(LColor.Black)
                else
                    grid:SetColor(LColor.White)
                end
            end
        end
    end
    
end)

local ResetData = function()
    StartGrid = nil

    TargetGrid = nil

    DebugCircle = nil
    
end
local btn1 = UI.Button.new( 10, 10, 50, 30, 'Reset', 'btn' )
btn1.ClickEvent = function()
    ResetData()

    AStartPath:ForeachGrids(function(InGrid)
        local InfoRect = InGrid._rect

        InfoRect:SetColor(LColor.Black)

        InGrid:SetCanReach(true)
    end)
end

local CR = 80


local GenerateCircleData = function()
    local Center = AStartPath:GetCenter()
    local C = Circle.new(CR, Center.x, Center.y)
    AStartPath:ForeachGrids(function(InGrid)
        local InfoRect = InGrid._rect

        if C:CheckPointIn(InGrid:GetCenter()) then
            InfoRect:SetColor(LColor.White)
            InGrid:SetCanReach(false)
        else
            InfoRect:SetColor(LColor.Black)
            InGrid:SetCanReach(true)
        end
    end)
end

local btn3 = UI.Button.new( 140, 10, 50, 30, 'GenerateCircle', 'btn' )
btn3.ClickEvent = function()

    ResetData()

    GenerateCircleData()
end

local scrollbar = UI.ScrollBar.new( 'Radiu', 200, 10, 200, 40, 10, 300, 5)
scrollbar.Value = CR
scrollbar.ChangeEvent = function(v)
    CR = v
end


local btn2 = UI.Button.new( 80, 10, 50, 30, 'FindPath', 'btn' )
btn2.ClickEvent = function()
    
    if StartGrid and TargetGrid then

        GenerateCircleData()
        
        local PathGrids = AStartPath:FindPath(StartGrid, TargetGrid)
        if PathGrids then
            AStartPath:SetOpenAndClosedColor(LColor.Yellow)

            if StartGrid then
                StartGrid:SetColor(LColor.Red)
            end

            if TargetGrid then
                TargetGrid:SetColor(LColor.Blue)
            end

            for i, v in ipairs(PathGrids) do
                if v ~= StartGrid and v ~= TargetGrid then
                    v:SetColor(LColor.Green)
                end
            end
        end
    end
end
