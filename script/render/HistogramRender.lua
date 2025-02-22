_G.HistogramRender = {}
HistogramRender.Meta = {__index = HistogramRender}

HistogramRender.OffsetSize = 0.5
--InDatas: Number
function HistogramRender.new(x, y, w, InH, InDatas)
    local h = setmetatable({}, HistogramRender.Meta)

    h._x = x 
    h._y = y
    h._w = w 
    h._h = InH 

    h._data = InDatas
    h._Count = #InDatas

    return h
end

function HistogramRender.CreateFromTwoDimensionalArray(InDatas, x, y, h, SpanSize)
    local HDs = {}
    local Number = #InDatas
    for i = 1, Number do
        HDs[i] = #InDatas[i]
    end
    
    local NeedSpanSize = SpanSize + HistogramRender.OffsetSize * 2

    return HistogramRender.new(x, y, NeedSpanSize * Number, h, HDs)
end

function HistogramRender:GenerateRenderData()
    local MaxNumber = 0
    for i = 1, self._Count do
        MaxNumber = math.max(MaxNumber, self._data[i])
    end

    local NeedSpanSize = self._w / self._Count

    local LimtH = self._h

    self.Rects = {}
    for i = 1, self._Count do
        local rx = self._x + (i - 1) * NeedSpanSize + HistogramRender.OffsetSize
        local ry = self._y

        local rw = NeedSpanSize - HistogramRender.OffsetSize * 2
        local rh = -(self._data[i] / MaxNumber) * self._h
        local r = Rect.new(rx, ry, rw, rh)
        r:SetColor(255, 0, 0, 255)
        self.Rects[#self.Rects + 1] = r
    end
end

function HistogramRender:Reset()
    self:GenerateRenderData()
end

function HistogramRender:draw()
    if not self.Rects then
        self:GenerateRenderData()
    end

    for i = 1, #self.Rects do
        self.Rects[i]:draw()
    end
end