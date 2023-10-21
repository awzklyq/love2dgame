UI.ScrollBar = {}
local ScrollBar = UI.ScrollBar
function ScrollBar.new( x, y, w, h, minv, maxv, offset )
    local sb = setmetatable({}, UI.GetMeta(ScrollBar));

    sb._x = x or 0
    sb._y = y or 0
    sb._w = w or 100
    sb._h = h or 50

    sb._minv = minv or 0
    sb._maxv = maxv or 1
    sb._offset = offset or 0.1

    sb.circle = Circle.new(0, 0, 50)

    return sb
end