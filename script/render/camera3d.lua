_G.Camera3D = {}
function Camera3D.new(x1, y1, x2, y2, lw)-- lw :line width
    local camera = setmetatable({}, {__index = Camera3D});

    camera.fov = math.pi/2
    camera.nearClip = 0.01
    camera.farClip = 1000
    camera.aspectRatio = love.graphics.getWidth()/love.graphics.getHeight()

    camera.position = Vector3.new(0,0,0)
    camera.direction = 0
    camera.pitch = 0
    camera.theta = 0
    camera.down = Vector3.new(0,-1,0)

    camera.target = Vector3.new(0,0,-1)

    camera.renderid = Render.Camera3DId
    --  -- so that far polygons don't overlap near polygons
    --  love.graphics.setDepthMode("lequal", true)
    return camera;
end


-- function Camera3D:movePhi( phi )

-- 	if phi == 0 then
-- 		return;

-- 	-- if ( mPhiLimit.x != Math::cMinFloat && mPhiLimit.y != Math::cMaxFloat )
-- 	{
-- 		_float curPhi = _phi_get( );
	
-- 			if ( curPhi + phi < c.x )
-- 				phi = mPhiLimit.x - curPhi;
-- 			else if ( curPhi + phi > mPhiLimit.y )
-- 				phi = mPhiLimit.y - curPhi;
-- 		}
		
-- 	}

-- 	Vector3 eye = mEye->mVector * Matrix4( ).Translation( - mLook->mVector ) *
-- 		Matrix4( ).Rotation( mUp->mVector, phi ) * Matrix4( ).Translation( mLook->mVector );

-- 	_moveEye( eye.x, eye.y, eye.z, time );
-- }

-- _void FancyCamera::_moveTheta( _float theta, _dword time )
-- {
-- 	if ( _lockTheta_get( ) )
-- 		return;

-- 	if ( theta == 0.0f )
-- 		return;

-- 	if ( mThetaLimit.x != Math::cMinFloat && mThetaLimit.y != Math::cMaxFloat )
-- 	{
-- 		_float temp = _theta_get( );

-- 		if ( temp - theta < mThetaLimit.x )
-- 			theta = temp - mThetaLimit.x;
-- 		else if ( temp - theta > mThetaLimit.y )
-- 			theta = temp - mThetaLimit.y;
-- 	}

-- 	Vector3 right = Vector3::Cross( mUp->mVector, mLook->mVector - mEye->mVector ).Normalize( );

-- 	Vector3 vec1 = Vector3::Cross( mEye->mVector - mLook->mVector, right );

-- 	Vector3 eye = mEye->mVector * Matrix4( ).Translation( - mLook->mVector ) *
-- 		Matrix4( ).Rotation( right, theta ) * Matrix4( ).Translation( mLook->mVector );

-- 	Vector3 vec2 = Vector3::Cross( eye - mLook->mVector, right );

-- 	if ( Vector3::Dot( vec1, mUp->mVector ) * Vector3::Dot( vec2, mUp->mVector ) < 0.0f )
-- 		mUp->mVector = - mUp->mVector;

-- 	_moveEye( eye.x, eye.y, eye.z, time );
-- }

-- give the camera a point to look from and a point to look towards
function Camera3D:setCameraAndLookAt(x,y,z, xAt,yAt,zAt)
    self.position:setXYZ(x,y,z)
    self.target:setXYZ(xAt,yAt,zAt)

    -- update the camera in the shader
    -- CameraShader:send("viewMatrix", GetViewMatrix(Camera.position, Camera.target, Camera.down))
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
			-- _rd.camera:movePhi(-(mouse.mousex - x) * 0.005)
            -- _rd.camera:moveTheta(-(mouse.mousey - y) * 0.005)
            _G.currentCamera3D .pitch = -(mouse.mousex - x) * 0.005
            local direction = Vector3.sub(_G.currentCamera3D.target, _G.currentCamera3D.position)
            currentCamera3D:setCamera(_G.currentCamera3D.position.x, _G.currentCamera3D.position.y, _G.currentCamera3D.position.z, 1,_G.currentCamera3D .pitch )
        else
            local dir = Vector3.sub(_G.currentCamera3D.target, _G.currentCamera3D.position)
            local vx = Vector3.cross(dir, _G.currentCamera3D.down)
            vx:normalize()
            local vy = Vector3.cross(dir, vx)
            vy:normalize()
			local nearx = Vector3.mul(vx, -(mouse.mousex - x) * 0.001)
			local neary = Vector3.mul(vy,  (mouse.mousey - y) * 0.001)
			local movex = Vector3.mul(nearx, dir:distanceself() / _G.currentCamera3D.nearClip)
			local movey = Vector3.mul(neary, dir:distanceself() / _G.currentCamera3D.nearClip)
			local move = Vector3.add(movex , movey)
			_G.currentCamera3D.position = Vector3.new(_G.currentCamera3D.position.x + move.x, _G.currentCamera3D.position.y + move.y, _G.currentCamera3D.position.z + move.z)
            _G.currentCamera3D.target = Vector3.new(_G.currentCamera3D.target.x + move.x, _G.currentCamera3D.target.y + move.y, _G.currentCamera3D.target.z + move.z)
            print('aaaaaa', _G.currentCamera3D.position.x, _G.currentCamera3D.position.y, _G.currentCamera3D.position.z)
        end
        
	end
	mouse.mousex = x
	mouse.mousey = y
end)

-- app:onMouseWheel(function(d)
-- 	-- _G.currentCamera3D:moveRadius(d * -0.1 * _G.currentCamera3D.radius)
-- end)

app.keypressed(function(key, scancode, isrepeat)
    print(key)
end)



