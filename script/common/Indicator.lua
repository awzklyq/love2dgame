
_G.Indicator = {}
Indicator.Meta = {__index = Indicator}

local CurrentObj = nil
function Indicator.new()
    local obj = setmetatable({}, Indicator.Meta)

    local ns = 2
    local ss = 10
    obj.XMesh = Mesh3D.CreateCube()
    obj.XColor = LColor.new(180, 0, 0, 255)
    obj.XMesh:SetBaseColor(obj.XColor)
    obj.XMesh.transform3d:mulScalingLeft(ss, ns, ns)
    obj.XMesh.transform3d:mulTranslationRight(ss * 0.5, 0, 0)

    obj.YMesh = Mesh3D.CreateCube()
    obj.YColor = LColor.new(0, 180, 0, 255)
    obj.YMesh:SetBaseColor(obj.YColor)
    obj.YMesh.transform3d:mulScalingLeft(ns, ss, ns)
    obj.YMesh.transform3d:mulTranslationRight(0, ss * 0.5, 0)

    obj.ZMesh = Mesh3D.CreateCube()
    obj.ZColor = LColor.new(0, 0, 180, 255)
    obj.ZMesh:SetBaseColor(obj.ZColor)
    obj.ZMesh.transform3d:mulScalingLeft(ns, ns, ss)
    obj.ZMesh.transform3d:mulTranslationRight(0, 0, ss * 0.5)

    obj.IsSelect = 0
    
    CurrentObj = obj

    return obj
end

function Indicator:mousepressed(x, y, button)
    if button == 1 then
        self.IsSelect = 0
        local ray = Ray.BuildFromScreen(x, y)
        local dis = self.XMesh:PickByRay(ray, false)
        if dis > 0 then
            self.IsSelect = 1
        end

        if self.IsSelect == 0 then
            dis = self.YMesh:PickByRay(ray, false)
            if dis > 0 then
                self.IsSelect = 2
            end
        end

        if self.IsSelect == 0 then
            dis = self.ZMesh:PickByRay(ray, false)
            if dis > 0 then
                self.IsSelect = 3
            end
        end

        if self.IsSelect > 0 then
            log('xxxx', self.IsSelect)
        end
    end
end

function Indicator:mousereleased(x, y, button)
end

function Indicator:mousemoved(x, y, dx, dy)
end

function Indicator:draw()
    self.XMesh:draw()
    self.YMesh:draw()
    self.ZMesh:draw()
end

app.mousepressed(function(x, y, button, istouch)
	if CurrentObj then
        CurrentObj:mousepressed(x, y, button)
    end
end)

app.mousereleased(function(x, y, button, istouch)
	if CurrentObj then
        CurrentObj:mousereleased(x, y, button)
    end
end)

app.mousemoved(function(x, y, dx, dy)
	if CurrentObj then
        CurrentObj:mousemoved(x, y, dx, dy)
    end
end)