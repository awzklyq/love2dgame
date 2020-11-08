
_G.Box = {}

function Box.new(x1,y1,x2,y2)
    local box = setmetatable({}, {__index = Box});
    box.x1 = x1 or 0;
    box.y1 = y1 or 0;
    box.x2 = x2 or 1;
    box.y2 = y2 or 1;
    return box;
end

function Box:getBoxValueFromObj()
    assert(self.obj)
    local pos = self.obj.transform:getPosition()
    local x1, y1, x2, y2 = self.x1 + pos.x, self.y1 + pos.y, self.x2 + pos.x, self.y2 + pos.y
    return x1, y1, x2, y2
end