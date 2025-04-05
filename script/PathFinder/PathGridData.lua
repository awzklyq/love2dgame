_G.PathGridData = {}

PathGridData.Meta = {__index = PathGridData}

function PathGridData.new(InI, InJ, Inx, InY, InW, InH)

    local g = setmetatable({}, PathGridData.Meta)

    g._i = InI
    g._j = InJ
    g._x = InX
    g._y = InY

    g._w = InW
    g._h = InH

    g._rect = Rect.new( Inx, InY, InW, InH)
    g._rect:SetColor(LColor.Black)

    g._DebugRect = Rect.new( Inx, InY, InW, InH, "line")

    g.renderid = Render.PathGridId

    return g
end

function PathGridData:draw()
    self._rect:draw()

    self._DebugRect:draw()
end