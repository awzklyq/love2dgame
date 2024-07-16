_G.Scene3D = {}

function Scene3D.new()
    local scene = setmetatable({}, {__index = Scene3D});

    scene.renderid = Render.Scene3DId

    scene.nodes = {}

    scene.lights = {}

    scene.isDrawOctrees = false;
    scene.needcreateoctrees = false;
    scene.octrees = Octree.new()

    scene.bgColor = LColor.new(125,125,125,255)

    scene.screenwidth = love.graphics.getPixelWidth()
    scene.screenheight = love.graphics.getPixelHeight()

    scene.frustum = Frustum.new()
    scene.frustums = {}
    for i = 1, _G.GConfig.CSMNumber do
        scene.frustums[i] = Frustum.new()
    end

    scene:reseizeScreen(scene.screenwidth, scene.screenheight)
    scene.needFXAA = false
    scene.needTAA = false
    scene.visiblenodes = {}
    scene.cullednumber = 0

    scene.needBloom = false;
    scene.needBloom2 = false;
    scene.needBloom3 = false;
    scene.needOutLine = false;
    scene.needHBAO = false;
    scene.needGTAO = false;
    scene.needSimpleSSGI = false;
    scene.needSSAO = false
    scene.needSSDO = false
    scene.needFog = false
    scene.needToneMapping = false;

    scene.needVelocityBuff = false;
    scene.needLights = false;
    VelocityBuffNode.InitDynamicMeshs()
    return scene
end

function Scene3D:getDepthCanvas()
    return self.canvasdepth
end

function Scene3D:createOctrees()
    if not self.needcreateoctrees then 
        return
    end
    local box = BoundBox.new()
    for i ,v in pairs(self.nodes) do
        if v.mesh then
            box:addSelf(v:getWorldBox())
        end
    end

    self.octrees:createOctreesNode(box, _G.GConfig.octreesize)

    self.needcreateoctrees = false

    for i, v in pairs(self.nodes) do
        if v.mesh then
            self.octrees:updateMeshNode(v)
        end
    end
end

function Scene3D:addLight(light)
    local node = SceneNode3D.new()
    node:bindDirectionLight(light)
    table.insert(self.lights, node)
    return node
end

function Scene3D:removeLight(light)
    for i = 1, #self.lights do
        if self.lights[i].directionLight == light then
            self.lights[i].directionLight = nil
            table.remove(self.lights, i)
            break
        end
    end
end

function Scene3D:addMesh(mesh)
    assert(mesh.renderid and mesh.renderid == Render.Mesh3DId)
    local node = SceneNode3D.new()
    node:bindMesh(mesh)
    mesh.node = node -- warning..
    
    table.insert(self.nodes, node)

    self.needcreateoctrees = true

    -- self.octrees:updateMeshNode(node)
    return node
end

function Scene3D:removeMesh(mesh)
    assert(mesh.renderid and mesh.renderid == Render.Mesh3DId)
    if not mesh.node then
        return
    end

    for i = 1, #self.nodes do
        if self.nodes[i] == mesh.node then
            mesh.node = nil
            table.remove(self.nodes, i)
            break
        end
    end
end

function Scene3D:getMeshNodesNumber()
    return #self.nodes
end

function Scene3D:getFrusumCulledNumber()
    return self.cullednumber
end

function Scene3D:getFrustumResultNodes()
    self.cullednumber = 0
    -- for i = 1, #self.nodes do
    --     local node = self.nodes[i]
    --     if self.frustum:insideBox(node:getWorldBox()) then
    --         table.insert(self.visiblenodes, node)
    --     end
    -- end

    self.visiblenodes = {}
    self.octrees:getFrustumResultNodes(self.frustum, self.visiblenodes)

    self.cullednumber = #self.nodes - #self.visiblenodes
end

function Scene3D:update(e)
    VelocityBuffNode.InitDynamicMeshs()

    if self.screenwidth ~= RenderSet.screenwidth or self.screenheight ~= RenderSet.screenheight then
        self.screenwidth = RenderSet.screenwidth-- love.graphics.getWidth() * 2
        self.screenheight = RenderSet.screenheight--love.graphics.getHeight() * 2
        self:reseizeScreen(self.screenwidth, self.screenheight)
    end

    self:createOctrees()

    self.frustum:buildFromViewAndProject(RenderSet.getCameraFrustumViewMatrix(), RenderSet.getCameraFrustumProjectMatrix())

    self:getFrustumResultNodes()
end

function Scene3D:reseizeScreen(w, h)
    if  RenderSet.HDR then
        self.CanvasColor = Canvas.new(w, h, {format = "rgba16f", readable = true, msaa = 0, mipmaps="none"})
    else
        self.CanvasColor = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
    end
    self.CanvasColor.renderWidth = w
    self.CanvasColor.renderHeight = h

    self.CanvasAlphaTest = Canvas.new(w, h, {format = "rgba32f", readable = true, msaa = 0, mipmaps="none"})
    self.CanvasAlphaTest.renderWidth = w
    self.CanvasAlphaTest.renderHeight = h

    if RenderSet.HDR then
        self.canvasPostprocess = Canvas.new(w, h, {format = "rgba16f", readable = true, msaa = 0, mipmaps="none"})
    else
        self.canvasPostprocess = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
    end

    self.canvasPostprocess.renderWidth = w
    self.canvasPostprocess.renderHeight = h
    
    self.canvasdepth = Canvas.new(w, h, {format = "r32f", readable = true, msaa = 0, mipmaps="none"})
    self.canvasdepth.renderWidth = w
    self.canvasdepth.renderHeight = h

    self.AlphaTestDepth = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
    self.AlphaTestDepth.renderWidth = w
    self.AlphaTestDepth.renderHeight = h

    self.canvasnormal = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
    self.canvasnormal.renderWidth = w
    self.canvasnormal.renderHeight = h

    self.normal_depth_buffer = Canvas.new(w, h, {format = "depth24stencil8", readable = true, msaa = 0, mipmaps="none"})
    self.normal_depth_buffer.renderWidth = w
    self.normal_depth_buffer.renderHeight = h

    self.depthmap_depth_buffer = Canvas.new(w, h, {format = "depth24stencil8", readable = true, msaa = 0, mipmaps="none"})
    self.depthmap_depth_buffer.renderWidth = w
    self.depthmap_depth_buffer.renderHeight = h

    self.normalmap_depth_buffer = Canvas.new(w, h, {format = "depth24stencil8", readable = true, msaa = 0, mipmaps="none"})
    self.normalmap_depth_buffer.renderWidth = w
    self.normalmap_depth_buffer.renderHeight = h

    self.alphatest_depth_buffer = Canvas.new(w, h, {format = "depth24stencil8", readable = true, msaa = 0, mipmaps="none"})
    self.alphatest_depth_buffer.renderWidth = w
    self.alphatest_depth_buffer.renderHeight = h

    self.meshquad = _G.MeshQuad.new(w, h, LColor.new(255, 255, 255, 255))
    self.meshquad.w = w
    self.meshquad.h = h
end

function Scene3D:draw(isdrawCanvaColor)
    self:drawDepth()

    -- for i = 1, #self.lights do
    --     local light = self.lights[i]
    --     if light.directionLight then            
    --         _G.useLight(light.directionLight)
    --     end
    -- end

    MotionVectorNode:BeforeExecute()

    local AlphaTestNodes = {}
    love.graphics.setMeshCullMode("back")
    love.graphics.setDepthMode("less", true)
    love.graphics.setCanvas({self.CanvasColor.obj, depthstencil = self.depthmap_depth_buffer.obj})
    love.graphics.clear(self.bgColor._r, self.bgColor._g, self.bgColor._b, self.bgColor._a)
    if self.Tiles then--TODO
        
    end
    
    for i = 1, #self.visiblenodes do
        local node = self.visiblenodes[i]
        if node.mesh then--  
            if node.AlphaTest then
                table.insert(AlphaTestNodes, node) 
            else
                if self.needVelocityBuff then
                    if node.needVelocityBuff or node.mesh.needVelocityBuff then
                        VelocityBuffNode.GatherDynamicMesh(node.mesh)
                    end
                end

                RenderSet.setshadowReceiver(node.shadowReceiver)
                RenderSet.SetPBR(node.PBR)

                MotionVectorNode.Execute(node.mesh)
                node.mesh:draw()
                RenderSet.setshadowReceiver(false)
                RenderSet.SetPBR(false)
                if  self.IsDrawBox then
                    node:drawBoxMesh()
                end
            end
            -- end
        end
        node.isFrustumChecked = false
    end

    if self.isDrawOctrees then
        self.octrees:draw()
    end
    
    love.graphics.setCanvas()
    love.graphics.setMeshCullMode("none")


    if RenderSet.AlphaTestMode == 1 then
        self:DrawAlphaTest(AlphaTestNodes)
    elseif RenderSet.AlphaTestMode == 2 then
        self:DrawAlphaTest2(AlphaTestNodes)
    end

    -- for i = 1, #self.lights do
    --     _G.popLight()
    -- end

    self:drawNormalmap()

    
    if isdrawCanvaColor then
        self:drawCanvaColor()
    end

    -- -- must be last
    -- self.visiblenodes = {}
end

function Scene3D:DrawAlphaTest(AlphaTestNodes)
    if #AlphaTestNodes == 0 then return end

    love.graphics.setMeshCullMode("back")
    love.graphics.setDepthMode("less", true)
    love.graphics.setCanvas({self.CanvasColor.obj, depthstencil = self.depthmap_depth_buffer.obj})
    for i = 1, #AlphaTestNodes do
        local node = AlphaTestNodes[i]
        if node.mesh then--  
            RenderSet.setshadowReceiver(node.shadowReceiver)
            RenderSet.SetPBR(node.PBR)
            node.mesh:draw()
            RenderSet.setshadowReceiver(false)
            RenderSet.SetPBR(false)
        end
    end
    
    love.graphics.setCanvas()
    love.graphics.setMeshCullMode("none")

    -------------------------------------
    love.graphics.setMeshCullMode("back")
    love.graphics.setDepthMode("less", false)
    love.graphics.setCanvas({self.AlphaTestDepth.obj})
    love.graphics.clear(0,0,0)

    for i = 1, #AlphaTestNodes do
        local node = AlphaTestNodes[i]
        if node.mesh then
            local rendertype = node.mesh:getRenderType()
            node.mesh:setRenderType("depth")
            node.mesh:draw()
            node.mesh:setRenderType(rendertype)
        end
    end
    love.graphics.setMeshCullMode("none")
    love.graphics.setCanvas()

    -------------------------------------------
    love.graphics.setMeshCullMode("none")
    love.graphics.setDepthMode("less", false)
    love.graphics.setCanvas({self.CanvasColor.obj})
    -- love.graphics.clear(self.bgColor._r, self.bgColor._g, self.bgColor._b, self.bgColor._a)

    for i = 1, #AlphaTestNodes do
        local node = AlphaTestNodes[i]
        if node.mesh then--     
            node.mesh:DrawAlphaTest(self.AlphaTestDepth, self.CanvasColor, RenderSet.AlphaTestBlend)
        end
    end
    love.graphics.setCanvas()
    love.graphics.setMeshCullMode("none") 
end

function Scene3D:DrawAlphaTest2(AlphaTestNodes)
    if #AlphaTestNodes == 0 then return end

    love.graphics.setMeshCullMode("none")
    love.graphics.setDepthMode("less", false)
    love.graphics.setCanvas({self.CanvasColor.obj, depthstencil = self.depthmap_depth_buffer.obj})
    -- love.graphics.clear(self.bgColor._r, self.bgColor._g, self.bgColor._b, self.bgColor._a)
    for i = 1, #AlphaTestNodes do
        local node = AlphaTestNodes[i]
        if node.mesh then--  
            RenderSet.setshadowReceiver(node.shadowReceiver)
            RenderSet.SetPBR(node.PBR)
            node.mesh:DrawAlphaTest2(self.CanvasColor, RenderSet.AlphaTestBlend)
            RenderSet.setshadowReceiver(false)
            RenderSet.SetPBR(false)
        end
    end
    
    love.graphics.setCanvas()
    love.graphics.setMeshCullMode("none")
end

function Scene3D:drawNormalmap()
    _G.useNormal()

    Shader.neednormal = 1
    love.graphics.setCanvas({self.canvasnormal.obj, depthstencil = self.normalmap_depth_buffer.obj})
    love.graphics.setMeshCullMode("back")
    love.graphics.setDepthMode("less", true)
    love.graphics.clear(0, 0, 0, 0)

    for i = 1, #self.visiblenodes do
        local node = self.visiblenodes[i]
        if node.mesh  then
            node.mesh:setRenderType("normalmap")
            node.mesh:draw()
            node.mesh:setRenderType("normal")
        end
    end
    love.graphics.setMeshCullMode("none")
    love.graphics.setCanvas()

    _G.unUseNormal()
end

function Scene3D:drawDepth()
    love.graphics.setCanvas({self.canvasdepth.obj, depthstencil = self.depthmap_depth_buffer.obj})
    love.graphics.setMeshCullMode("back")
    love.graphics.setDepthMode("less", true)
    love.graphics.clear(1,1,1,1)

    for i = 1, #self.visiblenodes do
        local node = self.nodes[i]
        if node.mesh then
            node.mesh:setRenderType("depth")
            node.mesh:draw()
            node.mesh:setRenderType('normal')
        end
    end
    love.graphics.setMeshCullMode("none")
    love.graphics.setCanvas()
end

function Scene3D:drawCanvaColor()
    local needbase = true
    local canvas1 = self.CanvasColor
    local canvas2 = self.canvasPostprocess
    local rendercolor = self.CanvasColor

    -- if self.needToneMapping and RenderSet.HDR then
    --     rendercolor = ToneMapping.Execute(rendercolor)
    -- end

    if self.needLights then
        rendercolor = LightNode.Execute(rendercolor, self.depthmap_depth_buffer, self.canvasnormal)
    end
    if self.needVelocityBuff then
        VelocityBuffNode.Execute(self.screenwidth, self.screenheight)

        rendercolor = VelocityBuffNode.ExecuteBlur(rendercolor, rendercolor.renderWidth , rendercolor.renderHeight)
    end

    if self.needSimpleSSGI then
        rendercolor = SimpleSSGINode.Execute(rendercolor, self.canvasnormal, self.depthmap_depth_buffer)
    end

    if self.needSSDO then
        rendercolor = SSDONode.Execute(rendercolor, self.canvasnormal, self.depthmap_depth_buffer, self)
    end

    if self.needSSAO then
        rendercolor = SSAONode.Execute(rendercolor, self.canvasnormal, self.depthmap_depth_buffer)
    elseif self.needHBAO then
        rendercolor = HBAONode.Execute(rendercolor, self.depthmap_depth_buffer)
    elseif self.needGTAO then
        local camera3d = _G.getGlobalCamera3D()
        rendercolor = GTAONode.Execute(rendercolor, self.canvasnormal, self.depthmap_depth_buffer, camera3d.eye)
    end

    if self.needTAA then
        rendercolor = TAANode.Execute(canvas1, self.canvasnormal, self.depthmap_depth_buffer)
    end

    if self.needFXAA then
        love.graphics.setCanvas(canvas2.obj)
        love.graphics.clear()
        self.meshquad:setCanvas(rendercolor)
        self.meshquad.shader = Shader.GetFXAAShader(rendercolor.renderWidth , rendercolor.renderHeight)
        self.meshquad:draw()
        needbase = false
        love.graphics.setCanvas()

        rendercolor = canvas2
        -- canvas2 = canvas1
        -- canvas1 = rendercolor
    end
    
    if self.needBloom then
        rendercolor = Bloom.Execute(rendercolor, self.meshquad)
    elseif self.needBloom2 then
        rendercolor = Bloom2.Execute(rendercolor, self.meshquad)
    elseif self.needBloom3 then
        rendercolor = Bloom3.Execute(rendercolor, self.meshquad)
    end

    if self.needToneMapping and RenderSet.HDR then
        rendercolor = ToneMapping.Execute(rendercolor)
    end

    if self.needOutLine then
        rendercolor = OutLine.Execute(rendercolor)
    end

    if self.needFog then
        rendercolor = FogNode.Execute(rendercolor, self.depthmap_depth_buffer)
    end

    rendercolor:draw()
end

function Scene3D:drawCanvaNormalmap()
    self.canvasnormal:draw()
end

function Scene3D:drawDirectionLightShadow(isdebug)
    for i = 1, #self.lights do
        local lightnode = self.lights[i]
        local directionLight = lightnode.directionLight
        if directionLight and lightnode.needshadow then
            love.graphics.setCanvas({lightnode.shadowmap.obj, depthstencil = lightnode.depth_buffer.obj})
            love.graphics.setMeshCullMode("back")
            love.graphics.setDepthMode("less", true)
            love.graphics.clear(1,1,1,1)
            -- love.graphics.clear(0,0,0)
            local camera3d = _G.getGlobalCamera3D()
            local lightmat = Matrix3D.createLookAtLH( Vector3.negative(directionLight.dir), Vector3.cOrigin, camera3d.up )

            local casterbox = BoundBox.new()
            local receiverbox = BoundBox.new()
            
            for j = 1, #self.visiblenodes do
                local node = self.visiblenodes[j]
                if node.shadowCaster then--node.shadowCaster
                    casterbox:addSelf(node:getWorldBox())
                end

                if node.shadowReceiver then--node.shadowReceiver
                    local box = node.mesh.transform3d:mulBoundBox(node.box, true)
                    receiverbox:addSelf(box)
                end
            end

            local shadowprojectbox = self.frustum:intersectBox(receiverbox)--BoundBox.getIntersectBox(casterbox, receiverbox)

            shadowprojectbox = lightmat:mulBoundBox(shadowprojectbox, true)
            shadowprojectbox.max.z = math.max(shadowprojectbox.max.z, camera3d.farClip) + 10000000--TODO
            
            local shadowmapproj = Matrix3D.createOrthoOffCenterLH(
                shadowprojectbox.min.x, shadowprojectbox.max.x, shadowprojectbox.min.y, shadowprojectbox.max.y, shadowprojectbox.min.z, shadowprojectbox.max.z);
            
            RenderSet.pushViewMatrix(Matrix3D.transpose(lightmat))--Matrix3D.transpose
            RenderSet.pushProjectMatrix(Matrix3D.transpose(shadowmapproj))
            
            for j = 1, #self.visiblenodes do
                local node = self.visiblenodes[j]
                if node.shadowCaster then
                    local rendertype = node.mesh:getRenderType()
                    node.mesh:setRenderType("depth")
                    node.mesh:draw()
                    node.mesh:setRenderType(rendertype)
                end
            end

            RenderSet.popViewMatrix()
            RenderSet.popProjectMatrix()

            love.graphics.setCanvas()
            love.graphics.setMeshCullMode("none")
            -- local texmat = Matrix3D.new();
            -- texmat[1] =  0.5
            -- texmat[6] =  -0.5
            -- texmat[11] =  1.0

            -- texmat[13] = 0.5;
            -- texmat[14] = 0.5;
            -- texmat:transposeSelf()
            local texmat = Matrix3D.createFromNumbers( -- FOr uv
               0.5, 0,0,0,
               0,0.5,0,0,
               0,0,0.5,0,
               0.5,0.5,0.5,1
        )

--         local texmat = Matrix3D.createFromNumbers( -- FOr uv
--         1, 0,0,0,
--         0,1,0,0,
--         0,0,1,0,
--         0,0,0,1
--  )
        
            texmat:transposeSelf()
            texmat:mulRight(Matrix3D.transpose(shadowmapproj))
            local mat = texmat--Matrix3D.transpose(shadowmapproj);--texmat--Matrix3D.transpose(texmat)
            
            mat:mulRight(Matrix3D.transpose(lightmat))
            -- mat:mulRight(texmat)
            lightnode.directionlightMatrix = mat
            if isdebug then
                lightnode.shadowmap:draw()
                -- lightnode.depth_buffer:draw()
            end
        end
        if RenderSet.EnableESM then
            ESMBlurNode.Execute(lightnode.shadowmap)
        end
    end
    
end


function Scene3D:drawDirectionLightCSM(isdebug)
    local CSMNumber = _G.GConfig.CSMNumber
    if CSMNumber == 1 then
        self:drawDirectionLightShadow()
        return;
    end

    for i = 1, #self.lights do
        local lightnode = self.lights[i]
        local directionLight = lightnode.directionLight
        if directionLight and lightnode.needshadow then
            -- love.graphics.clear(0,0,0)
            local camera3d = _G.getGlobalCamera3D()
            local lightmat = Matrix3D.createLookAtLH( Vector3.negative(directionLight.dir), Vector3.cOrigin, camera3d.up )
        
            local casterboxs = {}
            local receiverboxs = {}
            
            local distance = camera3d.farClip - camera3d.nearClip

            local shadownodes = {}

            local offset = distance / CSMNumber
            for CSMIndex = 1, CSMNumber do
                local viewmatrix = Matrix3D.createLookAtLH(camera3d.eye, camera3d.look, camera3d.up);
                local startnearclip = camera3d.nearClip + (offset * (CSMIndex - 1));
                local projectmatrix = Matrix3D.createPerspectiveFovLH( camera3d.fov, camera3d.aspectRatio, camera3d.nearClip, startnearclip + offset)--startnearclip, startnearclip + offset + 100
                self.frustums[CSMIndex]:buildFromViewAndProject(viewmatrix, projectmatrix)

                shadownodes[CSMIndex] = {}
                
                casterboxs[CSMIndex] = BoundBox.new()
                receiverboxs[CSMIndex] = BoundBox.new()
            end

            
            for j = 1, #self.visiblenodes do
                local node = self.visiblenodes[j]
                for CSMIndex = 1, CSMNumber do
                    if self.frustums[CSMIndex]:insideBox(node:getWorldBox(), true) then
                        if node.shadowCaster then--node.shadowCaster
                            casterboxs[CSMIndex]:addSelf(node:getWorldBox())
                        end
        
                        if node.shadowReceiver then--node.shadowReceiver
                            local box = node.mesh.transform3d:mulBoundBox(node.box, true)
                            receiverboxs[CSMIndex]:addSelf(box)
                        end

                        table.insert(shadownodes[CSMIndex], node)
                    end
                end
            end

            for CSMIndex = 1, CSMNumber do
                local shadowprojectbox = self.frustum:intersectBox(receiverboxs[CSMIndex])--BoundBox.getIntersectBox(casterbox, receiverbox)

                shadowprojectbox = lightmat:mulBoundBox(shadowprojectbox, true)
                local startnearclip = camera3d.nearClip + (offset * (CSMIndex - 1));
                shadowprojectbox.max.z = math.max(shadowprojectbox.max.z, startnearclip +  offset) + 10--TODO
                
                local shadowmapproj = Matrix3D.createOrthoOffCenterLH(
                    shadowprojectbox.min.x, shadowprojectbox.max.x, shadowprojectbox.min.y, shadowprojectbox.max.y, shadowprojectbox.min.z, shadowprojectbox.max.z);
                
                RenderSet.pushViewMatrix(Matrix3D.transpose(lightmat))--Matrix3D.transpose
                RenderSet.pushProjectMatrix(Matrix3D.transpose(shadowmapproj))
                
                love.graphics.setCanvas({lightnode.shadowmap.obj, depthstencil = lightnode.depth_buffer.obj, ViewportX = RenderSet.getShadowMapSize() * (CSMIndex - 1), ViewportY = 0, ViewportW = RenderSet.getShadowMapSize(), ViewportH = RenderSet.getShadowMapSize()})--RenderSet.getShadowMapSize() * (CSMIndex - 1)
                love.graphics.setMeshCullMode("back")
                love.graphics.setDepthMode("less", true)
                if CSMIndex == 1 then
                    love.graphics.clear(1,1,1,1)
                end
                for j = 1, #shadownodes[CSMIndex] do
                    local node = shadownodes[CSMIndex][j]
                    if node.shadowCaster then
                        local rendertype = node.mesh:getRenderType()
                        node.mesh:setRenderType("depth")
                        node.mesh:draw()
                        node.mesh:setRenderType(rendertype)
                    end
                end
    
                RenderSet.popViewMatrix()
                RenderSet.popProjectMatrix()
    
                love.graphics.setCanvas()
                love.graphics.setMeshCullMode("none")
    
                local uvoffset = 1 / CSMNumber * 0.5
                -- local texmat = Matrix3D.createFromNumbers( -- FOr uv
                -- 0.5 / CSMNumber, 0,0,0,
                -- 0,0.5,0,0,
                -- 0,0,0.5,0,
                -- uvoffset + (CSMIndex - 1) * uvoffset * 2,0.5,0.5,1
                -- )

                local texmat = Matrix3D.createFromNumbers( -- FOr uv
                0.5 / CSMNumber, 0,0,0,
                0,0.5,0,0,
                0,0,0.5,0,
                uvoffset + (CSMIndex - 1) * uvoffset * 2,0.5,0.5,1
                )
            
            texmat:transposeSelf()
            texmat:mulRight(Matrix3D.transpose(shadowmapproj))
            local mat = texmat--Matrix3D.transpose(shadowmapproj);--texmat--Matrix3D.transpose(texmat)

            texmat:mulRight(Matrix3D.transpose(lightmat))
    
            lightnode.CSMMatrix[CSMIndex] = texmat
            lightnode.CSMDistance[CSMIndex] = startnearclip + offset
                if isdebug then
                    lightnode.shadowmap:draw()
                    -- lightnode.depth_buffer:draw()
                end
            end

           
        end
        if RenderSet.EnableESM then
            ESMBlurNode.Execute(lightnode.shadowmap)
        end
    end
    
end

function Scene3D:Pick(x, y)

    local PickMeshNode = {}
    local ray = Ray.BuildFromScreen(x, y)
    for j = 1, #self.visiblenodes do
        local node = self.visiblenodes[j]
        local dis = node.mesh:PickByRay(ray)
        if dis > 0 then
            PickMeshNode[#PickMeshNode + 1] = {PickDistance = dis, Node = node}
        end
    end

    table.sort(PickMeshNode, function(a, b) return a.PickDistance < b.PickDistance end)
    return PickMeshNode
end

