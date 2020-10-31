
_G.Me = {}
_G.__setParentClass(Me, _G.Entity)
function Me.new()
    local me = setmetatable({}, {__index = Me});
    _G.__setParentObject(me, Entity);

    me.speed = 0.1;
    return me;
end

function Me:init()
    self.pao = self:findBodyByName("pao");
    
end

function Me:update(e)
    Entity.update(self, e);

    self.pao.transform:translate(0, -self.pao.h * 0.5)
    self.pao.transform:rotate(self.speed);
    self.pao.transform:translate(0, self.pao.h * 0.5)
end