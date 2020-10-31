_G.Matrix = {}

function Matrix.new(lmat)
    local mat = setmetatable({}, {__index = function(mytable, key, ...)
        if Matrix[key] then
            return Matrix[key];
        end
        
        if mytable.transform and mytable.transform[key] then

            if type(mytable.transform[key]) == 'function' then
                mytable[key] = function(tab, ...)
                    return mytable.transform[key](mytable.transform, ...);--todo..
                end
                return mytable[key];
            end

            return mytable.transform[key]
        end

        return nil;
      end});

    mat.transform =  lmat or love.math.newTransform( );

    mat.parenttransform = love.math.newTransform( );
    return mat;
end

-- function Matrix:translate(x, y)
--     self.transform:translate(x, y);
-- end

-- function Matrix:scale(x, y)
--     self.transform:scale( x, y);
-- end

-- function Matrix:reset()
--     self.transform:reset();
-- end

-- function Matrix:rotate(angle)
--     self.transform:rotate(angle);
-- end

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

-- mul right
function Matrix:apply(mat)
    local lovemat = self.transform:apply(mat);
    return Matrix.new(lovemat)
end

function Matrix:rotateLeft(angle)
    local mat = Matrix.new();
    mat:rotate(angle);
    -- self.transform = self.transform:apply(mat.transform)
    self.transform = mat.transform:apply(self.transform)
end

--使用父矩阵
function Matrix:applyParent(obj)
    if obj.parent and obj.parent.transform then
        self:applyParent(obj.parent);
    end
    -- self.parenttransform:setMatrix(self.parenttransform:apply(obj.transform.transform):getMatrix());
    self.parenttransform = obj.transform.transform;
end

function Matrix:use(obj)
    if obj and obj.parent then
        -- self.parenttransform:reset();
       
        self.parenttransform = obj.parent.transform.transform;
        self.parenttransform = self.parenttransform:apply(self.transform);
        love.graphics.applyTransform(self.parenttransform)
        return;
    end
    love.graphics.applyTransform(self.transform);
end

Matrix.reset = function()
    love.graphics.replaceTransform(math.defaulttransform);
end

