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
    --return Matrix3D.getViewMatrix(camera3d.eye, camera3d.look, camera3d.up)
  return Matrix3D.transpose(Matrix3D.createLookAtRH(camera3d.eye, camera3d.look, -camera3d.up))
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

local pbr = false
RenderSet.SetPBR = function(value)
    pbr = value
end

RenderSet.GetPBR = function()
    return pbr
end

local normalmap = nil
RenderSet.setNormalMap = function(value)
    normalmap = value
end

RenderSet.getNormalMap = function()
    return normalmap
end

local ssao = 2
RenderSet.setSSAOValue = function(value)
    ssao = math.max(0, value)
end

RenderSet.getSSAOValue = function()
    return ssao
end

local ssaolimit = 0.00001
RenderSet.setSSAODepthLimit = function(value)
    ssaolimit = math.max(0, value)
end

RenderSet.getSSAODepthLimit = function()
    return ssaolimit
end

local HBAORayMatchLength = 1;
RenderSet.getHBAORayMatchLength = function()
    return HBAORayMatchLength
end

RenderSet.setHBAORayMatchLength = function(lenght)
    HBAORayMatchLength = lenght
end

local HBAOBaseAngle = 30
RenderSet.getHBAOBaseAngle = function()
    return HBAOBaseAngle;
end

RenderSet.setHBAOBaseAngle = function(angle)
    HBAOBaseAngle = angle;
end

RenderSet.BGColor = LColor.new(0,0,0,255)
local CanvasColor = Canvas.new(love.graphics.getPixelWidth(), love.graphics.getPixelHeight(), {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
RenderSet.getCanvasColor = function ()
    return CanvasColor
end

local NeedResizeCanva = true
local DepthBuff = Canvas.new(love.graphics.getPixelWidth(), love.graphics.getPixelHeight(), {format = "depth24stencil8", readable = true, msaa = 0, mipmaps="none"})
RenderSet.ResetCanvasColor = function (w, h)
    CanvasColor = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
    DepthBuff = Canvas.new(w, h, {format = "depth24stencil8", readable = true, msaa = 0, mipmaps="none"})

    NeedResizeCanva = false
end


RenderSet.GetDepthBuff = function ()
    return DepthBuff
end

RenderSet.UseCanvasColorAndDepth = function ()
    love.graphics.setMeshCullMode("back")
    love.graphics.setDepthMode("less", true)
    love.graphics.setCanvas({CanvasColor.obj, depthstencil = DepthBuff.obj})
    love.graphics.clear(RenderSet.BGColor._r, RenderSet.BGColor._g, RenderSet.BGColor._b, RenderSet.BGColor._a)
end

RenderSet.ClearCanvasColorAndDepth = function ()
    -- love.graphics.present()
    love.graphics.setCanvas()
    love.graphics.setMeshCullMode("none")
end

app.resizeWindow(function(w, h)
    if NeedResizeCanva then
        CanvasColor = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
        DepthBuff = Canvas.new(w, h, {format = "depth24stencil8", readable = true, msaa = 0, mipmaps="none"})
    end
end)

RenderSet.screenwidth = love.graphics.getPixelWidth()
RenderSet.screenheight = love.graphics.getPixelHeight()
RenderSet.isNeedFrustum = true
RenderSet.AlphaTestBlend = 0.5
RenderSet.AlphaTestMode = 2
RenderSet.frameToken = 1
RenderSet.FrameInterval = 0

RenderSet.HDR = false

RenderSet.EnableCDLOD = true


RenderSet.LOD1Distance = 300
RenderSet.LOD2Distance = 500
RenderSet.LOD3Distance = 800

RenderSet.ESM_C = 10
RenderSet.EnableESM = false
HDRSetting(function(IsHDR)
    if IsHDR then
        RenderSet.HDR = true
    else
        RenderSet.HDR = false
    end
end)
