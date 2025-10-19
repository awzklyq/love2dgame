
_G.Point2D = {}

Point2D.Meta = {}

Point2D.Meta.__index = Point2D

Point2D.Meta.__eq = function(myvalue, value)
    return myvalue.x == value.x and myvalue.y == value.y
end

Point2D.Meta.__sub = function(myvalue, value)
    if type(value) == "number" then
        return Point2D.new(myvalue.x - value, myvalue.y - value)
    else
        return Point2D.new(myvalue.x - value.x, myvalue.y - value.y)
    end
end

Point2D.Meta.__div = function(myvalue, value)
    if type(value) == "number" then
        return Point2D.new(myvalue.x / value, myvalue.y / value)
    elseif  type(value) == "table" and (value.renderid == Render.Vector2Id or value.renderid == Render.Point2Id) then
        return Point2D.new(myvalue.x / value.x, myvalue.y / value.y)
    else
        _errorAssert(false, "Point2D.Meta.__div~")
    end  
   
end

Point2D.Meta.__add = function(myvalue, value)
    if type(value) == "number" then
        return Point2D.new(myvalue.x + value, myvalue.y + value)
    else
        return Point2D.new(myvalue.x + value.x, myvalue.y + value.y)
    end
end

Point2D.Meta.__mul = function(myvalue, value)
    if type(value) == 'table' then
        if value.renderid == Render.Matrix2DId then
            return value:MulLeftVector2(myvalue)
        elseif value.renderid == Render.Vector2Id or value.renderid == Render.Point2Id then
            return Point2D.new(myvalue.x * value.x, myvalue.y * value.y)
        else
            _errorAssert(false, 'function Point2D.__mul')
        end
    else
        return Point2D.new(myvalue.x * value, myvalue.y * value)
    end
end

function Point2D.new(x, y, lw)-- lw :line width
    local p = setmetatable({}, Point2D.Meta);

    p.x = x or 0
    p.y = y or 0

    p.lw = lw or 4;
    p.color = LColor.new(255,255,255,255)

    p.renderid = Render.Point2Id ;

    return p;
end

function Point2D:CheckInLeftOfLine(InLine)
    local _Center = InLine:GetCenter()
    local _v1 = self - _Center
    local _v2 = InLine:GetEndPoint() - InLine:GetStartPoint()
    return Vector.angleClockwise(_v1, _v2) >= math.pi
end

function Point2D:CheckInLeftOfEdge(InEdge)
    local _Center = InEdge:GetCenter()
    local _v1 = self - _Center
    local _v2 = InEdge:GetP2() - InEdge:GetP1()
    return Vector.angleClockwise(_v1, _v2) >= math.pi
end

function Point2D:ToVector()
    return Vector.new(self.x, self.y)
end

function Point2D:Copy()
    return Point2D.new(self.x, self.y)
end

function Point2D:CheckInLeftOfLineOrEdge(InObj)
    if InObj.renderid == Render.EdgeId then
        return self:CheckInLeftOfEdge(InObj)
    else
        return self:CheckInLeftOfLine(InObj)
    end
end

function Point2D:GenerateDrawData()
    if self._Rect == nil then
        self._Rect = Rect.CreatFromCenter(self.x, self.y, self.lw, self.lw, 'fill')
        self._Rect:SetColor(self.color)
    end
end
function Point2D:SetColor(r, g, b, a)
    if g == nil then
        self.color:Set(r)
    else
        self.color.r = r or 255
        self.color.g = g or 255
        self.color.b = b or 255
        self.color.a = a or 255
    end
    if self._Rect then
        self._Rect:SetColor(r, g, b, a)
    end
end

function Point2D.Copy(this)
    return Point2D.new(this.x, this.y)
end

function Point2D:draw()
    -- Render.RenderObject(self);
    self:GenerateDrawData()
    self._Rect:draw()
end

function Point2D:AsVector()
    return Vector.new(self.x, self.y)
end


_G.Point2DCollect = {}

function Point2DCollect.new(ps, lw)-- lw :line width
    local p = setmetatable({}, {__index = Point2DCollect});

    p.ps = ps or {}
    p.lw = lw or 1;
    p.color = LColor.new(255,255,255,255)

    p.renderid = Render.Point2DCollectId;

    p:GenerateRenderDatas()

    return p;
end

function Point2DCollect:AddPoint(p)
    self.ps[#self.ps + 1] = p
    self:GenerateRenderDatas()
end

function Point2DCollect:GenerateRenderDatas()
    self.Datas = {}
    for i = 1, #self.ps do
        self.Datas[#self.Datas + 1] = self.ps[i].x
        self.Datas[#self.Datas + 1] = self.ps[i].y
    end
end

function Point2DCollect:SetColor(r, g, b, a)
    self.color.r = r or 255
    self.color.g = g or 255
    self.color.b = b or 255
    self.color.a = a or 255
end


function Point2DCollect:draw()
    Render.RenderObject(self);
end


Point2D.Origin = Point2D.new(0, 0)