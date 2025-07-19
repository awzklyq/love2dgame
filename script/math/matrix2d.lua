_G.Matrix2D = {}

local metatable_Matrix2D = {}
metatable_Matrix2D.__index = Matrix2D

metatable_Matrix2D.__mul = function(myvalue, value)
    if value.renderid == Render.Vector2Id then
        return myvalue:MulVector2(value)
    elseif value.renderid == Render.Matrix2DId then
        local _NewMat = myvalue:Copy()
        _NewMat:MulRight(value)
        return _NewMat
    end
end

function Matrix2D.new( )

    local mat = setmetatable({1,0,0,
    0,1,0,
    0,0,1}, metatable_Matrix2D);
    mat.renderid = Render.Matrix2DId;

    return mat
end    
    
function Matrix2D.CreatFromNumber(...)
    local mat = setmetatable({...}, metatable_Matrix2D);
    mat.renderid = Render.Matrix2DId;

    return mat
end


function Matrix2D:Log(sss)
	log()
	log('Matrix2D: ', sss)
	log(self[1], self[2], self[3])
	log(self[4], self[5], self[6])
	log(self[7], self[8], self[9])
	log()
end

function Matrix2D:getData(i, j)
    return self[(i - 1) * 3 + j]
end

function Matrix2D:GetRow(i)
    if i == 1 then
        return {self[1], self[2], self[3]}
    elseif i == 2 then
        return {self[4], self[5], self[6]}
    elseif i == 3 then
        return {self[7], self[8], self[9]}
    end
    assert(false)
end


function Matrix2D:SetValue(i, j, InValue)
     self[(i - 1) * 3 + j] = InValue
end

function Matrix2D:MulLeftVector2(v2)
	local xx, yy = v2.x, v2.y
	local rsult = Vector.new()
	
	rsult.x = xx * self:getData(1, 1) + yy * self:getData(2, 1) + self:getData(3, 1)
	rsult.y = xx * self:getData(1, 2) + yy * self:getData(2, 2) + self:getData(3, 2)
	return rsult
end

function Matrix2D:IsIdentity()

    return self[1] == 1 and self[2] == 0 and self[3] == 0 and
    self[4] == 0 and self[5] == 1 and self[6] == 0 and self[7] == 0 and self[8] == 0 and self[9] == 0
end


function Matrix2D:Reset( )
        
    self[1] = 1;
    self[2] = 0;
    self[3] = 0;

    self[4] = 0;
    self[5] = 1;
    self[6] = 0;

    self[7] = 0;
    self[8] = 0;
    self[9] = 1;
end
    
function Matrix2D:SetTranslation(x, y)
    self:Reset( );
    self[7] = x;
    self[8] = y;
end
    
function Matrix2D:GetTranslation( v )
    if  v ~= nil then
            
        v.x = self[7];
        v.y = self[8];
        return v;
    end
    return Vector.new(self[7], self[8])
end
    
function Matrix2D:SetRotation(r)
    self:Reset( );

    r = math.rad(r);

    self[1] = math.cos(r);
    self[2] = math.sin(r);
    self[4] = -math.sin(r);
    self[5] = math.cos(r);
end
    
function Matrix2D:SetRotationXY( rx, ry )
    self:Reset( );

    rx = math.rad(rx);
    ry = math.rad(ry);

    self[1] = math.cos(rx);
    self[2] = math.sin(rx);
    self[4] = -math.sin(ry);
    self[5] = math.cos(ry);
end
    
function Matrix2D:SetRotationX(r)
    self:Reset( );
    
    r =  math.rad(r);
    self[1] = math.cos(r);
    self[2] = math.sin(r);
end
    
function Matrix2D:SetRotationY(r)
    self:Reset( );

    r = math.rad(r);
    self[4] = -math.sin(r);
    self[5] = math.cos(r);
end
    
function Matrix2D:SetScaling(x, y)
    self:Reset( );
    self[1] = x;
    self[5] = y;
end

function Matrix2D:GetScaling( s )
    return Vector.new(math.sqrt(self[1] * self[1] + self[2] * self[2]), math.sqrt( self[4] * self[4] + self[5] * self[5] ))
end

function Matrix2D:MulTranslationRight(x, y)
    local mat = Matrix2D.new( );
    mat[7] = mat[7] + x;
    mat[8] = mat[8] + y;
    self:MulRight(mat);
    return  self
end
    
function Matrix2D:MulRotationRight(r)
    r = math.rad(r);

    local mat = Matrix2D.new( );
    mat[1] = math.cos(r);
    mat[2] = math.sin(r);
    mat[4] = -math.sin(r);
    mat[5] = math.cos(r);
    self:MulRight(mat);
    return  self
end

function Matrix2D:MulRotationXRight(r)
    r = math.rad(r);

    local mat = Matrix2D.new( );
    mat[1] = math.cos(r);
    mat[2] = math.sin(r);
    self:MulRight(mat);

    return  self
end

    
function Matrix2D:MulRotationYRight(r)
    r = math.rad(r);

    local mat = Matrix2D.new( );
    mat[4] = -math.sin(r);
    mat[5] = math.cos(r);
    self:MulRight(mat);

    return  self
end
    
function Matrix2D:MulRotationXYRight(rx, ry)
    rx = math.rad(rx);
    ry = math.rad(ry);

    local mat = Matrix2D.new( );
    mat[1] = math.cos(rx);
    mat[2] = math.sin(rx);
    mat[4] = -math.sin(ry);
    mat[5] = math.cos(ry);
    self:MulRight(mat);

    return  self
end
    
function Matrix2D:MulScalingRight(x, y)
    local mat = Matrix2D.new( );
    mat[1] = mat[1] + x;
    mat[5] = mat[5] + y;
    self:MulRight(mat);

    return  self
end
    
function Matrix2D:MulTranslationLeft(x, y)

    local mat = Matrix2D.new( );
    mat[7] = mat[7] + x;
    mat[8] = mat[8] + y;
    self:MulLeft(mat);
    
    return self
end
    
function Matrix2D:MulRotationLeft(r)

    r = math.rad(r);

    local mat = Matrix2D.new( );
    mat[1] = math.cos(r);
    mat[2] = math.sin(r);
    mat[4] = -math.sin(r);
    mat[5] = math.cos(r);
    self:MulLeft(mat);

    return self
end
    
function Matrix2D:MulRotationXLeft(r)

    r = math.rad(r);

    local mat = Matrix2D.new( );
    mat[1] = math.cos(r);
    mat[2] = math.sin(r);
    self:MulLeft(mat);

    return self
end
    
function Matrix2D:MulRotationYLeft(r)

    r = math.rad(r);

    local mat = Matrix2D.new( );
    mat[4] = -math.sin(r);
    mat[5] = math.cos(r);
    self:MulLeft(mat);

    return self
end
    
function Matrix2D:MulRotationXYLeft(rx, ry)

    rx = math.rad(rx);
    ry = math.rad(ry);

    local mat = Matrix2D.new( );
    mat[1] = math.cos(rx);
    mat[2] = math.sin(rx);
    mat[4] = -math.sin(ry);
    mat[5] = math.cos(ry);
    self:MulLeft(mat);

    return self
end
    
function Matrix2D:MulScalingLeft(x, y)

    local mat = Matrix2D.new( );
    mat[1] = x;
    mat[5] = y;
    self:MulLeft(mat);

    return self
end
    
function Matrix2D:MulRight(mat)
    local mat11 = self[1]
    local mat12 = self[2]
    local mat13 = self[3]
    local mat21 = self[4]
    local mat22 = self[5]
    local mat23 = self[6]
    local mat31 = self[7]
    local mat32 = self[8]
    local mat33 = self[9]

    self[1] = mat11 * mat[1] + mat12 * mat[4] +  mat13 * mat[7];
    self[2] = mat11 * mat[2] + mat12 * mat[5] +  mat13 * mat[8];
    self[3] = mat11 * mat[3] + mat12 * mat[6] +  mat13 * mat[9];
                                                         
    self[4] = mat21 * mat[1] + mat22 * mat[4] +  mat23 * mat[7];
    self[5] = mat21 * mat[2] + mat22 * mat[5] +  mat23 * mat[8];
    self[6] = mat21 * mat[3] + mat22 * mat[6] +  mat23 * mat[9];
                                                         
    self[7] = mat31 * mat[1] + mat32 * mat[4] +  mat33 * mat[7];
    self[8] = mat31 * mat[2] + mat32 * mat[5] +  mat33 * mat[8];
    self[9] = mat31 * mat[3] + mat32 * mat[6] +  mat33 * mat[9];

    return self
end
    
function Matrix2D:MulLeft(mat)
	local mat11 = self[1]
    local mat12 = self[2]
    local mat13 = self[3]
    local mat21 = self[4]
    local mat22 = self[5]
    local mat23 = self[6]
    local mat31 = self[7]
    local mat32 = self[8]
    local mat33 = self[9]

	self[1] = mat[1] * mat11 + mat[2] * mat21 + mat[3] * mat31; 
	self[2] = mat[1] * mat12 + mat[2] * mat22 + mat[3] * mat32; 
	self[3] = mat[1] * mat13 + mat[2] * mat23 + mat[3] * mat33; 
                                                
	self[4] = mat[4] * mat11 + mat[5] * mat21 + mat[6] * mat31; 
	self[5] = mat[4] * mat12 + mat[5] * mat22 + mat[6] * mat32; 
	self[6] = mat[4] * mat13 + mat[5] * mat23 + mat[6] * mat33; 
	                                            
	self[7] = mat[7] * mat11 + mat[8] * mat21 + mat[9] * mat31; 
	self[8] = mat[7] * mat12 + mat[8] * mat22 + mat[9] * mat32; 
	self[9] = mat[7] * mat13 + mat[8] * mat23 + mat[9] * mat33;

	return self
end
    
function Matrix2D:Transform(v)

    if v.renderid == Render.Vector2Id then
        return Vector.new(v.x * self[1] + v.y * self[4] + self[7],v.x * self[2] + v.y * self[5] + self[8])
    elseif v.renderid == Render.Vector3Id then
        return Vector3.new(v.x * self[1] + v.y * self[4] + v.z * self[7], v.x * self[2] + v.y * self[5] +  v.y * self[8], v.x * self[3] + v.y * self[6] +  v.y * self[9])
    elseif v.renderid == Render.Point3Id then
         --return Point3D.new(v.x * self[1] + v.y * self[4] + v.z * self[7], v.x * self[2] + v.y * self[5] +  v.y * self[8], v.x * self[3] + v.y * self[6] +  v.y * self[9])
        return Point3D.new(v.x * self[1] + v.y * self[2] + v.z * self[3], v.x * self[4] + v.y * self[5] +  v.y * self[6], v.x * self[7] + v.y * self[8] +  v.y * self[9])
    end

    _errorAssert(false, "Matrix2D:Transform")
end
    
function Matrix2D:SetXDirection( x, y )
        
    local dir = Vector.new( x, y );
    dir:normalize( );
    local vv = Vector.new( self[1], self[2] );
    vv:normalize( );
    if  math.abs( dir.x - vv.x ) < math.MinNumber and math.abs( dir.y - vv.y ) < math.MinNumber then
        return
    end

    local r = Vector.angle( vv, Vector.new( 1, 0 ) );
    return self:MulRotationLeft( r );
end
    
-- Set y aixs to direction.
function Matrix2D:SetYDirection( x, y )

    local dir = Vector.new( x, y );
    dir:normalize( );
    local vv = Vector.new( self[4], self[5] );
    vv:normalize( );
    if math.abs( dir.x - vv.x ) < math.MinNumber and math.abs( dir.y - vv.y ) < math.MinNumber then
        return
    end

    local r = Vector.angle( vv, dir );
    return self:MulRotationLeft( r );
end
    
function Matrix2D:Inverse( )
        
    local d = self:Determinant( );

    if d ~= 0 then 
    
        self:Adjoint( );

        d = 1 / d;
        self[1] = self[1] * d; self[2] = self[2] * d; self[3] = self[3] * d;
        self[4] = self[4] * d; self[5] = self[5] * d; self[6] = self[6] * d;
        self[7] = self[7] * d; self[8] = self[8] * d; self[9] = self[9] * d;
    end

    return d ~= 0;
end
    
function Matrix2D:Adjoint( )
        
    local mat11 = self[1]
    local mat12 = self[2]
    local mat13 = self[3]
    local mat21 = self[4]
    local mat22 = self[5]
    local mat23 = self[6]
    local mat31 = self[7]
    local mat32 = self[8]
    local mat33 = self[9]
    self[1] = mat22 * mat33 - mat23 * mat32; self[2] = mat13 * mat32 - mat12 * mat33; self[3] = mat12 * mat23 - mat13 * mat22;
    self[4] = mat23 * mat31 - mat21 * mat33; self[5] = mat11 * mat33 - mat13 * mat31; self[6] = mat13 * mat21 - mat11 * mat23;
    self[7] = mat21 * mat32 - mat22 * mat31; self[8] = mat12 * mat31 - mat11 * mat32; self[9] = mat11 * mat22 - mat12 * mat21;

        --     this.mat[0] = m11 * m22 - m12 * m21; this.mat[1] = m02 * m21 - m01 * m22; this.mat[2] = m01 * m12 - m02 * m11;
		-- this.mat[3] = m12 * m20 - m10 * m22; this.mat[4] = m00 * m22 - m02 * m20; this.mat[5] = m02 * m10 - m00 * m12;
		-- this.mat[6] = m10 * m21 - m11 * m20; this.mat[7] = m01 * m20 - m00 * m21; this.mat[8] = m00 * m11 - m01 * m10;

    return self;
end
    
function Matrix2D:Determinant( )
        
    return self[1] * self[5] * self[9]+ self[2] * self[6] * self[7] + self[3] * self[4] * self[8] - self[1] * self[6] * self[8] - self[1] * self[4] * self[9] - self[3] *self[5] *self[7];
    -- return m[0][0] * m[1][1] * m[2][2] + m[0][1] * m[1][2] * m[2][0] + m[0][2] * m[1][0] * m[2][1]
	-- 	 - m[0][0] * m[1][2] * m[2][1] - m[0][1] * m[1][0] * m[2][2] - m[0][2] * m[1][1] * m[2][0];
end

function Matrix2D:Transpose()
    local _NewMat = Matrix2D.new()
     for i = 1, 3 do
        for j = 1, 3 do
            _NewMat:SetValue(j, i, self:getData(i, j))
        end
    end

    return _NewMat
end

function Matrix2D:Set(InMat)
    for i = 1, 9 do
        self[i] = InMat[i]
    end
end

function Matrix2D:Copy()
    local _NewMat = Matrix2D.new()
    
    _NewMat:Set(self)

   return _NewMat
end

function Matrix2D:use(obj)
    if not self.transform then
        self.transform = love.math.newTransform()
    end

    self.transform:setMatrix(self[1], self[2], self[3],
    self[4], self[5], self[6],
    self[7], self[8], self[9])

    love.graphics.applyTransform(self.transform);
end
    
    
    --     this.getRotation( )
        
    --         var q = new Quaternion( )
    --         this.decompose( q );
            
    --         var v = new Vector4( );
    --         q.decompose( v );
            
    --         if ( q.z < 0 )
    --             v.w *= -1;
    
    --         return math.convertAngle(v.w);
    --     end
    
    --     //旋转四元数
    --     //Quaternion q 
    --     this.rotationQ( q )
        
    --         var xx = q.x * q.x * 2.0, yy = q.y * q.y * 2.0, zz = q.z * q.z * 2.0;
    --         var xy = q.x * q.y * 2.0, zw = q.z * q.w * 2.0, xz = q.x * q.z * 2.0;
    --         var yw = q.y * q.w * 2.0, yz = q.y * q.z * 2.0, xw = q.x * q.w * 2.0;
    
    --         var m = self
    --         m[0] = 1.0 - yy - zz; m[1] = xy + zw; m[2] =  xz - yw;
    --         m[3] = xy - zw; m[4] = 1.0 - xx - zz; m[5] = yz + xw;
    --         m[6] = xz + yw; m[7] = yz - xw; m[8] = 1.0 - xx - yy;
    
    --         return this;
    --     end
    
    --     //Quaternion q
    --     this.decompose( q )
        
    --         var m = self
    
    --         // Determine which of w, x, y, or z has the largest absolute value.
    --         var fourWSquaredMinus1 = m[0] + m[4] + m[8];
    --         var fourXSquaredMinus1 = m[0] - m[4] - m[8];
    --         var fourYSquaredMinus1 = m[4] - m[0] - m[8];
    --         var fourZSquaredMinus1 = m[8] - m[0] - m[4];
    
    --         var biggestIndex = 0;
    --         var fourBiggestSquaredMinus1 = fourWSquaredMinus1;
    
    --         if ( fourXSquaredMinus1 > fourBiggestSquaredMinus1 )
            
    --             fourBiggestSquaredMinus1 = fourXSquaredMinus1;
    --             biggestIndex = 1;
    --         end
    
    --         if ( fourYSquaredMinus1 > fourBiggestSquaredMinus1 )
            
    --             fourBiggestSquaredMinus1 = fourYSquaredMinus1;
    --             biggestIndex = 2;
    --         end
    
    --         if ( fourZSquaredMinus1 > fourBiggestSquaredMinus1 )
            
    --             fourBiggestSquaredMinus1 = fourZSquaredMinus1;
    --             biggestIndex = 3;
    --         end
    
    --         var biggestVal = math.sqrt( fourBiggestSquaredMinus1 + 1 ) * 0.5;
    --         var mult = 0.25 / biggestVal;
    
    --         // Apply table to compute quaternion values.
    --         switch ( biggestIndex )
            
    --             case 0:
    --                 q.w = biggestVal;
    --                 q.x = ( m[5] - m[7] ) * mult;
    --                 q.y = ( m[6] - m[2] ) * mult;
    --                 q.z = ( m[1] - m[3] ) * mult;
    --                 break;
    
    --             case 1:
    --                 q.x = biggestVal;
    --                 q.w = (m[5] - m[7] ) * mult;
    --                 q.y = ( m[1] + m[3] ) * mult;
    --                 q.z = ( m[6] + m[2] ) * mult;
    --                 break;
    
    --             case 2:
    --                 q.y = biggestVal;
    --                 q.w = ( m[6] - m[2] ) * mult;
    --                 q.x = ( m[2] + m[3] ) * mult;
    --                 q.z = ( m[5] + m[7] ) * mult;
    --                 break;
    
    --             case 3:
    --                 q.z = biggestVal;
    --                 q.w = ( m[1] - m[3] ) * mult;
    --                 q.x = ( m[6] + m[2] ) * mult;
    --                 q.y = ( m[5] + m[7] ) * mult;
    --                 break;
    --         end
            
    --         return q;
    --     end
    
    --     //Vector v, s Quaternion q
    --     this.decompose3( v, s, q )
        
    --         v.x = self[6];
    --         v.y = self[7];
    
    --         var scale = this.getScaling()
    --         s.x = scale.x;
    --         s.y = scale.y;
    
    --         this.decompose( q );
    --     end
    
    --     //需要先做四元数旋转
    --     //Vector v, s Quaternion q
    --     this.compose3( v, s, r )
        
    --         this.setRotation( r );
    
    --         self[0] *= s.x; self[1] *= s.x;
    --         self[3] *= s.y; self[4] *= s.y;
    
    --         self[6] = v.x; self[7] = v.y; 
    --     end
    
    --     this.compose6( vx, vy, sx, sy, rx, ry )
        
    --         this.setRotationXY( rx, ry );
    
    --         self[0] *= sx; self[1] *= sx;
    --         self[3] *= sy; self[4] *= sy;
    
    --         self[6] = vx; self[7] = vy; 
    --     end
    -- Matrix2D.cIdentity = new Matrix2D( );