_G.Camera3D = {}
function Camera3D.new(x1, y1, x2, y2, lw)-- lw :line width
    local camera = setmetatable({}, {__index = Camera3D});

    camera.fov = math.pi/2
    camera.nearClip = 0.1
    camera.farClip = 100000
    camera.aspectRatio = love.graphics.getWidth()/love.graphics.getHeight()

    camera.eye = Vector3.new(0,0,0)

    camera.up = Vector3.new(0,1,0)

    camera.look = Vector3.new(0,0,-1)

    camera.renderid = Render.Camera3DId
    --  -- so that far polygons don't overlap near polygons
    --  love.graphics.setDepthMode("lequal", true)
    return camera;
end

function Camera3D:getPhi( )

    return ( Vector3.sub(self.eye, self.look) ):Cartesian2Spherical( ).z;
end

function Camera3D:getTheta( )
    return ( Vector3.sub(self.eye, self.look) ).Cartesian2Spherical( ).y;
end

function Camera3D:getRadius( )
    return Vector3.distance(self.eye, self.look)
end

function Camera3D:movePhi( phi )

	if phi == 0 then
        return;
    end

    local curPhi = self:getPhi()
    local temp = curPhi + phi;
	while ( temp > math.c2pi ) do
        temp = temp - math.c2pi;
    end

    while ( temp < 0 ) do
        temp = temp + math.c2pi;
    end

    if  temp < math.MinNumber and temp > math.MaxNumber then
    
        if  math.abs( curPhi - math.MinNumber ) < math.abs( curPhi - math.MaxNumber ) then
            phi = mPhiLimit.x - curPhi;
        else
            phi = mPhiLimit.y - curPhi;
        end
    end

    local mat = Matrix3D.new()
    mat:mulTranslationRight(-self.look.x, -self.look.y, -self.look.z)
    mat:mulRotationRight(self.up.x, self.up.y, self.up.z, phi)
    mat:mulTranslationRight(self.look.x, self.look.y, self.look.z)

    self.eye = mat:mul(self.eye)
end

function Camera3D:moveTheta( theta)
	if ( theta == 0.0 ) then
        return;
    end


    local right = Vector3.cross( self.up, Vector3.sub(self.look, self.eye) )
    right:normalize( )

	local vec1 = Vector3.cross( Vector3.sub(self.eye, self.look), right );

    local mat = Matrix3D.new()
    mat:mulTranslationRight(-self.look.x, -self.look.y, -self.look.z)
    mat:mulRotationRight(right.x, right.y, right.z, theta)
    mat:mulTranslationRight(self.look.x, self.look.y, self.look.z)

    local eye = mat:mul(self.eye);
	local vec2 = Vector3.cross( Vector3.sub(self.eye, self.look), right );

	if ( Vector3.dot( vec1, self.up ) * Vector3.dot( vec2, self.up ) < 0.0 ) then
        self.up = Vector3.new(-self.up.x, -self.up.y, -self.up.z)
    end

	self.eye = eye
end

function Camera3D:moveRadius( radius)
	if ( radius == 0.0 ) then
        return;
    end

	if self.eye:equal(self.look ) then
        return;
    end

    local dir = Vector3.sub(self.eye, self.look)
    dir:normalize()
	self.eye = Vector3.add(self.eye, dir:mul(radius))
end

-- give the camera a point to look from and a point to look towards
function Camera3D:setCameraAndLookAt(x,y,z, xAt,yAt,zAt)
    self.eye:setXYZ(x,y,z)
    self.look:setXYZ(xAt,yAt,zAt)

    -- update the camera in the shader
    -- CameraShader:send("viewMatrix", GetViewMatrix(Camera.position, Camera.look, Camera.up))
end

_G.currentCamera3D = Camera3D.new()
_G.getGlobalCamera3D = function()
    return _G.currentCamera3D
end
_G.setGlobalCamera3D = function(camera)
    _G.currentCamera3D = camera
end

--------------------- camera3d control
local mouse = {mousex = 0, mousey = 0}
app.mousemoved(function(x, y, dx, dy, istouch)
	if love.mouse.isDown(3) then
		if love.keyboard.isDown("lalt") then
			_G.currentCamera3D:movePhi(-(mouse.mousex - x) * 0.005)
            _G.currentCamera3D:moveTheta((mouse.mousey - y) * 0.005)
            
        else
            local dir = Vector3.sub(_G.currentCamera3D.look, _G.currentCamera3D.eye)
            local vx = Vector3.cross(dir, _G.currentCamera3D.up)
            vx:normalize()
            local vy = Vector3.cross(dir, vx)
            vy:normalize()
			local nearx = Vector3.mul(vx, -(mouse.mousex - x) * 0.001)
			local neary = Vector3.mul(vy,  (mouse.mousey - y) * 0.001)
			local movex = Vector3.mul(nearx, dir:distanceself() / _G.currentCamera3D.nearClip)
			local movey = Vector3.mul(neary, dir:distanceself() / _G.currentCamera3D.nearClip)
			local move = Vector3.add(movex , movey)
			_G.currentCamera3D.eye = Vector3.new(_G.currentCamera3D.eye.x + move.x, _G.currentCamera3D.eye.y + move.y, _G.currentCamera3D.eye.z + move.z)
            _G.currentCamera3D.look = Vector3.new(_G.currentCamera3D.look.x + move.x, _G.currentCamera3D.look.y + move.y, _G.currentCamera3D.look.z + move.z)
        end
        
	end
	mouse.mousex = x
	mouse.mousey = y
end)

-- app:onMouseWheel(function(d)
-- 	-- _G.currentCamera3D:moveRadius(d * -0.1 * _G.currentCamera3D.radius)
-- end)

app.wheelmoved(function(x, y)
    _G.currentCamera3D:moveRadius(y * -0.1 * _G.currentCamera3D:getRadius())
end)

app.keypressed(function(key, scancode, isrepeat)
    print(key)
end)



