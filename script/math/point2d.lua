
_G.Point2D = {}

function Point2D.new(x, y, lw)-- lw :line width
    local p = setmetatable({}, {__index = Point2D});

    p.x = x or 0
    p.y = y or 0

    p.lw = lw or 1;
    p.color = LColor.new(255,255,255,255)

    p.renderid = Render.Point2Id ;

    return p;
end

function Point2D:SetColor(r, g, b, a)
    self.color.r = r or 255
    self.color.g = g or 255
    self.color.b = b or 255
    self.color.a = a or 255
end

function Point2D:draw()
    Render.RenderObject(self);
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

