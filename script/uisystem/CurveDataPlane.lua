UI.CurvelDataPlane = {}
local CurvelDataPlane = UI.CurvelDataPlane;
function CurvelDataPlane.new( x, y, w, h, InNumber )
	local CDP = UI.CreateMetatable(CurvelDataPlane);

	CDP._x = x or 0;
	CDP._y = y or 0;
	CDP._w = w or 0;
	CDP._h = h or 0;
    CDP._Number = InNumber

	CDP.color  = LColor.new(180, 180, 180);

    CDP.LineColor = LColor.new(255,255,255,255)

    CDP.BackRect = Rect.new(x, y, w, h)
    CDP.BackRect.color = LColor.new(125, 125, 125, 200)

    CDP.PointDatas = {}
    CDP.PointDatas[#CDP.PointDatas + 1] = Vector.new(0, 0)
    CDP.PointDatas[#CDP.PointDatas + 1] = Vector.new(1, 1)

	CDP:reset( );
    
	CDP.type = "CurvelDataPlane";
	CDP.IsVisible = true
	UI.UISystem.addUI( CDP );

	return CDP;
end

function CurvelDataPlane:SetLineColor(r,g,b,a)
    self.LineColor.r = r or self.LineColor.r 
    self.LineColor.g = g or self.LineColor.g 
    self.LineColor.b = b or self.LineColor.b 
    self.LineColor.a = a or self.LineColor.a 
end

function CurvelDataPlane:GenerateLines()
    self.DrawLines = {}
    local TempDrawPoints = {}
    for i = 1, #self.DrawPoints do
        TempDrawPoints[#TempDrawPoints + 1] = Vector.new(self._x + self._w * self.DrawPoints[i].x, self._y + self._h - self.DrawPoints[i].y * self._h)
    end
    for i = 1, #self.DrawPoints - 1 do
        local line = Line.new(TempDrawPoints[i].x, TempDrawPoints[i].y, TempDrawPoints[i + 1].x, TempDrawPoints[i + 1].y, 4)
        line.color = self.LineColor
        self.DrawLines[#self.DrawLines + 1] = line
    end
end

function CurvelDataPlane:FindIntervalPointIndex(ox)
    local ResultNumber = Optional.new('number')
    for i = 1,  #self.PointDatas - 1 do
        if self.PointDatas[i].x <= ox and self.PointDatas[i + 1].x > ox then
            ResultNumber(i)
            break
        end
    end

    if ResultNumber:HasValue() == false then
        ResultNumber(#self.PointDatas)
    end
    return ResultNumber
end

function CurvelDataPlane:ResetDrawPoints()
    self.DrawPoints = {}

    local StartPoint =  Vector.new(self._x, self._y + self._h) -- Need reverse
    local EndPoint = Vector.new(self._x + self._w, self._y) 
    --self._x + self._w * self.PointDatas[i].x, self._y + self._h - self.PointDatas[i].y * self._h
    if #self.PointDatas == 2 then
        for i = 0, self._Number - 1 do
            local dx = i / (self._Number - 1)
            local dy = i / (self._Number - 1)
            self.DrawPoints[#self.DrawPoints + 1] = Vector.new(dx, dy)
        end
    elseif  #self.PointDatas > 2 then

        local PointsNumber = #self.PointDatas
        local SelectBC3 = PointsNumber % 2 ~= 0
        -- self.DrawPoints[#self.DrawPoints + 1] = Vector.new(0, 0)
        for i = 1, self._Number  do
            local df = (i - 1) / (self._Number - 1)
            local Index = self:FindIntervalPointIndex(df)

            _errorAssert(Index:HasValue(), "CurvelDataPlane: Index Has not HasValue ")
            local IndexValue = Index.Value

            if IndexValue == #self.PointDatas then
                self.DrawPoints[#self.DrawPoints + 1] = Vector.new(1, 1)
                break
            end
            local IsUseBC3 = true
            local BC
            
            if not SelectBC3 then
                if IndexValue >= PointsNumber - 3 then
                    IsUseBC3 = false
                    BC = BezierCurve.new( self.PointDatas[PointsNumber - 3], self.PointDatas[PointsNumber - 2], self.PointDatas[PointsNumber - 1], self.PointDatas[PointsNumber])
                end
            end

            if IsUseBC3 then
                if IndexValue % 2 ~= 0 then
                    BC = BezierCurve.new(self.PointDatas[IndexValue], self.PointDatas[IndexValue + 1], self.PointDatas[IndexValue + 2])
                else
                    BC = BezierCurve.new(self.PointDatas[IndexValue - 1], self.PointDatas[IndexValue], self.PointDatas[IndexValue + 1])
                end
            end

            local p = BC:GetPoint(df)
            self.DrawPoints[#self.DrawPoints + 1] = Vector.new(p.x, p.y)
        end

        -- self.DrawPoints[#self.DrawPoints + 1] = Vector.new(1, 1)
    else
        _errorAssert(false, " CurvelDataPlane #self.PointDatas < 2")
    end

    self:GenerateLines()
end

function CurvelDataPlane:reset()
    self:ResetXYWH()

    self:ResetDrawPoints()
end

function CurvelDataPlane:ResetXYWH()
    self.BackRect.x =  self._x
    self.BackRect.y =  self._y
    self.BackRect.w =  self._w
    self.BackRect.h =  self._h

    if self.DrawPoints then
        self:GenerateLines()
    end
end


function CurvelDataPlane:IsInsert( x, y )
    return x > self._x and x < self._x + self._w and y > self._y and y < self._y + self._h;
end

function CurvelDataPlane:InsertData(x, y)
    if self:IsInsert(x, y) == false then return end
    local dx = (x - self._x) / self._w
    local dy = ( (self._y + self._h ) - y) / self._h

    local p = Vector.new(dx, dy)

    p.Rect = Rect.new(x - 4, y - 4, 8, 8, 'fill')
    p.Rect:SetColor(255,0,0,255)
    p.Rect:SetMouseEventEable(true)

    p.Rect.MouseDownEvent = function(rect, x, y)
        rect._IsSelect = true
    end
    
    p.Rect.Point = p
    local CPD = self
    p.Rect.MouseMoveEvent = function(rect, x, y)
        if CPD:IsInsert(x - 4, y - 4) == false then
            return
        end
        rect.x = x - 4
        rect.y = y - 4

        rect.Point.x = (rect.x - self._x) / self._w
        rect.Point.y = ( (self._y + self._h ) - rect.y) / self._h

        table.sort( self.PointDatas, function(a, b)
            return a.x < b.x
        end) 

        CPD:ResetDrawPoints()
    end

    p.Rect.MouseUpEvent = function(rect, x, y)
        rect._IsSelect = false
        
    end

    self.PointDatas[#self.PointDatas + 1] = p
    table.sort( self.PointDatas, function(a, b)
        return a.x < b.x
    end) 

    self:ResetDrawPoints()
end

function CurvelDataPlane:CheckAndRemovePoint(x, y)
    local CanRemove = false
    for i = 2,  #self.PointDatas - 1 do
        if self.PointDatas[i].Rect and self.PointDatas[i].Rect:CheckPointInXY(x, y) then
            table.remove(self.PointDatas, i)
            CanRemove = true
            break
        end
    end

    if CanRemove then
        self:ResetDrawPoints()
    end

    return CanRemove
end

function CurvelDataPlane:triggerMouseDown( b, x, y )
	if self:IsInsert( x, y ) == false then
		return false;
	end

    if b == 2 and self:CheckAndRemovePoint(x, y) == false then
        self:InsertData(x, y)
    end

	return true;
end

function CurvelDataPlane:triggerMouseRelease( b, x, y )
    --self:ShowPlane(false)
	return false
end

function CurvelDataPlane:triggerMouseMoved( x, y )
	return false;
end

function CurvelDataPlane:GetDatas( )
	return self.DrawPoints
end

function CurvelDataPlane:GetData(index)
    _errorAssert(index <= #self.DrawPoints)
	return self.DrawPoints[index]
end

function CurvelDataPlane:draw()
    if not self.IsVisible then return end
    self.BackRect:draw()

    for i = 1, #self.DrawLines do
        self.DrawLines[i]:draw()
    end

    for i = 2, #self.PointDatas - 1 do
        self.PointDatas[i].Rect:draw()
    end
end