_G.PathGridData = {}

PathGridData.Meta = {__index = PathGridData}

function PathGridData.new(InI, InJ, InX, InY, InW, InH)

    local g = setmetatable({}, PathGridData.Meta)

    g._i = InI
    g._j = InJ
    g._x = InX
    g._y = InY

    g._w = InW
    g._h = InH

    g._rect = Rect.new( InX, InY, InW, InH)
    g._rect:SetColor(LColor.Black)

    g._Center = Vector.new(InX + InW * 0.5, InY + InH * 0.5)

    g._CanReach = true

    g._DebugRect = Rect.new( InX, InY, InW, InH, "line")

    g.renderid = Render.PathGridId

    return g
end

function PathGridData:SetColor(InColor)
    self._rect:SetColor(InColor)
end

function PathGridData:CanReach()
    return self._CanReach
end

function PathGridData:SetCanReach(InReach)
    self._CanReach = InReach
end

function PathGridData:GetCenter()
    return self._Center
end

function PathGridData:draw()
    self._rect:draw()

    self._DebugRect:draw()
end