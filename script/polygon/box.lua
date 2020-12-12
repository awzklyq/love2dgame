
_G.Box = {}

function Box.new(x1,y1,x2,y2)
    local box = setmetatable({}, {__index = Box});
    box.x1 = x1 or 0;
    box.y1 = y1 or 0;
    box.x2 = x2 or 1;
    box.y2 = y2 or 1;

    box.renderid = Render.BoxBoundId;
    return box;
end

function Box:getBoxValueFromObj()
    assert(self.obj)
    local pos = self.obj.transform:getPosition()
   
    -- local x1, y1, x2, y2 = self.x1 + pos.x, self.y1 + pos.y, self.x2 + pos.x, self.y2 + pos.y

    local x1, y1 = self.obj.transform:transformPoint(self.x1, self.y1, false, true)
    local x2, y2 = self.obj.transform:transformPoint(self.x2, self.y2, false, true)
    return x1, y1, x2, y2
end

function Box:draw()
    if _G.lovedebug.showBox then
    Render.RenderObject(self)
    end
end