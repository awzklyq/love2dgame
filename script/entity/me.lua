
_G.Me = {}
_G.__setParentClass(Me, _G.Entity)
function Me.new()
    local me = setmetatable({}, {__index = Me});
    _G.__setParentObject(me, Entity);

    me.paodir = Vector.new(0, 1)
    me.speed = 0.1;

    me.tempmat = Matrix.new()

    me.noiseline = NoiseLine.new(100, 100, 300, 400, 5, 12)
    return me;
end

function Me:init()
    self.pao = self:findBodyByName("pao");
    self.lun = self:findBodyByName("lun");
end

function Me:getPaoDir()
    self.tempmat:reset();
    self.tempmat:rotate(self.pao.transform:getAngle())
    self.paodir.x, self.paodir.y = self.tempmat:transformPoint( self.paodir.x, self.paodir.y );

    --self.dir:normalize()
    return self.paodir;
end

function Me:getPosition()
    return self.lun.transform:getPosition(); 
    
end

function Me:update(e)
    Entity.update(self, e);

    self.noiseline:update(e)
    if _G.isKeyDown("left", "right") then
    self.pao.transform:translate(0, -self.pao.h * 0.5)
    self.pao.transform:rotate( _G.isKeyDown("left") and self.speed or -self.speed);
    self.pao.transform:translate(0, self.pao.h * 0.5)
    end
end

function Me:draw(e)
    Entity.draw(self, e);

    self.noiseline:draw(e)
end

local sss = 0
app.keypressed(function(key, scancode, isrepeat)
    local powerbar = _G.GroupManager.currentgroup.powerbar
    if powerbar then
        if key == "space" then
            local me = _G.getMe()
            local dir = me:getPaoDir();
            local value = powerbar:getValue()
            print("current power value: ",value)
            me.lun.box2d:applyLinearImpulse(-dir.x * value, -dir.y* value)
            print(love.math.noise( 21, 1, sss ))
            sss = sss + 0.2
        end
    end
    
end)
