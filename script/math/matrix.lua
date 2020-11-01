_G.Matrix = {}

function Matrix.new(lmat)
    local mat = setmetatable({}, Matrix);

    mat.transform =  lmat or love.math.newTransform( );

    mat.parenttransform = love.math.newTransform( );

    mat:reset();
    return mat;
end

Matrix.__index = function(tab, key, ...)
    local value = rawget(tab, key);
    if value then
        return value;
    end

    if Matrix[key] then
        return Matrix[key];
    end
    
    if tab["transform"] and tab["transform"][key] then
        if type(tab["transform"][key]) == "function" then
            tab[key] = function(tab, ...)
                return tab["transform"][key](tab["transform"], ...);--todo..
            end
            return  tab[key]
        end
        return tab["transform"][key];
    end

    return nil;
end

Matrix.__newindex = function(tab, key, value)
    rawset(tab, key, value);
end

function Matrix:move(x, y)
    self.transform:translate(x, y);

    self.des.x = self.des.x + x
    self.des.y = self.des.y + y

    self.offsetpos.x = self.offsetpos.x + x
    self.offsetpos.y = self.offsetpos.y + y
end

function Matrix:moveTo(x, y)
    self.transform:translate(x - self.des.x, y - self.des.y);

    --TODO.
    if self.des.x ~= 0 or self.des.y ~= 0 then
    self.offsetpos.x = self.offsetpos.x + x - self.des.x
    self.offsetpos.y = self.offsetpos.y + y - self.des.y
    end

    self.des.x = x
    self.des.y = y
end

function Matrix:scale(x, y)
    self.transform:scale( x, y);
end

function Matrix:faceTo(x, y)
    self.transform:setXDirection( x - self.des.x, y - self.des.y);
end

function Matrix:rotateLeft(angle)
    self.transform:rotateLeft(angle)
    self.angle = self.angle + angle;
end

function Matrix:rotate(angle)
    self.transform:rotate(angle)
    self.angle = self.angle + angle;
end


function Matrix:getPosition()
    return self.des;
end

function Matrix:getOffsetPos()
    return self.offsetpos;
end

function Matrix:getPositionXY()
    return self.des.x, self.des.y;
end

function Matrix:getOffsetPosXY()
    return self.offsetpos.x ,self.offsetpos.y;
end

function Matrix:getAngle()
    return self.angle;
end

function Matrix:setXDirection( x, y )
    local dir = Vector.new( x, y );
    dir:normalize( );

    local e11, e12, e13, e14, e21, e22, e23, e24, e31, e32, e33, e34, e41, e42, e43, e44 = self.transform:getMatrix();
    local vv = Vector.new(e11, e21);
    vv:normalize( );
    if ( math.abs( dir.x - vv.x ) < math.MinNumber and math.abs( dir.y - vv.y ) < math.MinNumber ) then
        return;
    end

    local r = Vector.angle( vv, dir);

    local k = vv.y * dir.x - vv.x * dir.y;
    if k < 0 then
        self:rotate( r );
    else
        self:rotate( -r );
    end
end

function Matrix:setYDirection( x, y )
    local dir = Vector.new( x, y );
    dir:normalize( );
    local e11, e12, e13, e14, e21, e22, e23, e24, e31, e32, e33, e34, e41, e42, e43, e44 = self.transform:getMatrix();
    local vv = Vector.new(e12, e22);
    vv:normalize( );
    if ( math.abs( dir.x - vv.x ) < math.MinNumber and math.abs( dir.y - vv.y ) < math.MinNumber ) then
        return;
    end

    local r = Vector.angle( vv, dir);
    local k = vv.y * dir.x - vv.x * dir.y;
    if k < 0 then
        self:rotate( r );
    else
        self:rotate( -r );
    end
end

function Matrix:reset()
    if not self.des then
        self.des = Vector.new();
        self.offsetpos = Vector.new();
    end

    self.des.x = 0;
    self.des.y = 0;

    self.offsetpos.x = 0;
    self.offsetpos.y = 0;
    self.angle = 0;

    self.transform:reset()
end

-- mul right
function Matrix:apply(mat)
    local lovemat = self.transform:apply(mat);
    return Matrix.new(lovemat)
end

function Matrix:rotateLeft(angle)
    local mat = Matrix.new();
    mat:rotate(angle);
    -- self.transform = mat.transform:apply(self.transform)
    self.transform = self.transform:apply(mat.transform);
end

--使用父矩阵
function Matrix:applyParent(obj, needparentposition, needparentoffsetpos)
    if obj.parent and obj.parent.transform then
        self:applyParent(obj.parent, needparentposition);
    end

    if needparentposition then
        local pos = obj.transform:getPosition();
        self.parenttransform:translate(pos.x, pos.y);
    elseif needparentoffsetpos then
        local pos = obj.transform:getOffsetPos();
        self.parenttransform:translate(pos.x, pos.y);
    end
   
end

function Matrix:use(obj)
    if obj and (obj["needparentposition"] or obj["needparentoffsetpos"]) and obj.parent then

        self.parenttransform:reset();
        
        self:applyParent(obj.parent,  obj["needparentposition"], obj["needparentoffsetpos"]);
        self.parenttransform = self.parenttransform:apply(self.transform);
        love.graphics.applyTransform(self.parenttransform)
        return;
    end
    love.graphics.applyTransform(self.transform);
end

Matrix.useDefault = function()
    love.graphics.replaceTransform(math.defaulttransform);
end

