_G.RenderSet = {}

local viewmatrixs = {}
local projectmatrixs = {}
RenderSet.pushViewMatrix = function(vm)
    table.insert(viewmatrixs, vm)
end

RenderSet.popViewMatrix = function()
    if  #viewmatrixs == 0 then return end
    table.remove(viewmatrixs, #viewmatrixs)
end

RenderSet.pushProjectMatrix = function(pm)
    table.insert(projectmatrixs, pm)
end

RenderSet.popProjectMatrix = function()
    if  #projectmatrixs == 0 then return end
    table.remove(projectmatrixs, #projectmatrixs)
end

RenderSet.getUseViewMatrix = function()
    if  #viewmatrixs == 0 then
        return RenderSet.getDefaultViewMatrix()
    end

    return viewmatrixs[#viewmatrixs]
end

RenderSet.getUseProjectMatrix = function()
    if  #projectmatrixs == 0 then
        return RenderSet.getDefaultProjectMatrix()
    end

    return projectmatrixs[#projectmatrixs]
end

RenderSet.getDefaultViewMatrix = function()
    local camera3d = _G.getGlobalCamera3D()
    -- return  Matrix3D.transpose(Matrix3D.createLookAtRH(camera3d.eye, camera3d.look, -camera3d.up))
    return Matrix3D.getViewMatrix(camera3d.eye, camera3d.look, camera3d.up)
end

RenderSet.getDefaultProjectMatrix = function()
    local camera3d = _G.getGlobalCamera3D()
    -- return  Matrix3D.getProjectionMatrix(camera3d.fov, camera3d.nearClip, camera3d.farClip, camera3d.aspectRatio)
    return Matrix3D.createPerspectiveFovRH( camera3d.fov, camera3d.aspectRatio, camera3d.nearClip, camera3d.farClip )
end

RenderSet.getCameraFrustumViewMatrix = function()
    local camera3d = _G.getGlobalCamera3D()
    return Matrix3D.createLookAtLH(camera3d.eye, camera3d.look, camera3d.up)
end

RenderSet.getCameraFrustumProjectMatrix = function()
    local camera3d = _G.getGlobalCamera3D()
    -- return  Matrix3D.getProjectionMatrix(camera3d.fov, camera3d.nearClip, camera3d.farClip, camera3d.aspectRatio)
    return Matrix3D.createPerspectiveFovLH( camera3d.fov, camera3d.aspectRatio, camera3d.nearClip, camera3d.farClip )
end


local shadowMapSize = 1024
RenderSet.setShadowMapSize = function(size)
    shadowMapSize = size
end

RenderSet.getShadowMapSize = function()
    return shadowMapSize
end

local shadowReceiver = false
RenderSet.setshadowReceiver = function(value)
    shadowReceiver = value
end

RenderSet.getshadowReceiver = function()
    return shadowReceiver
end

local normalmap = nil
RenderSet.setNormalMap = function(value)
    normalmap = value
end

RenderSet.getNormalMap = function()
    return normalmap
end

local ssao = 0.0001
RenderSet.setSSAOValue = function(value)
    ssao = math.max(0, value)
end

RenderSet.getSSAOValue = function()
    return ssao
end

RenderSet.screenwidth = love.graphics.getPixelWidth()
RenderSet.screenheight = love.graphics.getPixelHeight()
RenderSet.isNeedFrustum = true

RenderSet.frameToken = 1
