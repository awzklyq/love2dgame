_G.ImageAnimaManager = {}
ImageAnimaManager.ImageAnimas = {}
function ImageAnimaManager:update(dt)
    for i = 1, #ImageAnimaManager.ImageAnimas do
        ImageAnimaManager.ImageAnimas[i]:Update(dt)
    end
end

app.update(function(dt)
    ImageAnimaManager:update(dt)
end)

_G.ImageAnimaRenderType = {ASImage = 1, ASMeshQuad = 2}
_G.ImageAnima = {}

ImageAnima.__index = function(tab, key, ...)
    local value = rawget(tab, key);
    if value then
        return value;
    end

    if ImageAnima[key] then
        return ImageAnima[key];
    end
    
    if tab["obj"] and tab["obj"][key] then
        if type(tab["obj"][key]) == "function" then
            tab[key] = function(tab, ...)
                return tab["obj"][key](tab["obj"], ...);--todo..
            end
            return  tab[key]
        end
        return tab["obj"][key];
    end

    return nil;
end

ImageAnima.__newindex = function(tab, key, value)
    rawset(tab, key, value);
end


function ImageAnima.new(name, xnum, ynum, Duration, ...)
    local image = setmetatable({}, ImageAnima);

    if type(name) == 'string' then
        image.obj = love.graphics.newImage(_G.FileManager.findFile(name), ...)
    elseif type(name) == 'string' and name.renderid == Render.ImageId then
        image.obj = name.obj
    else
        image.obj = love.graphics.newImage(name, ...)
    end

    image.transform = Matrix.new()

    image.renderid = Render.ImageAnimaId;
    image.Quads = {}

    image.w = image:getWidth()
    image.h = image:getHeight()

    image.x = 0
    image.y = 0
    image.xsize = image.w / xnum
    image.ysize = image.h / ynum

    image.xnum = xnum
    image.ynum = ynum
    for j = 1, ynum do
        for i = 1, xnum do
            image.Quads[#image.Quads + 1] = love.graphics.newQuad( (i - 1) * image.xsize, (j - 1) * image.ysize, image.xsize, image.ysize, image.obj);
        end
    end
    
    image.CurrentQuad = image.Quads[1]
    
    image.alpha = 1

    image.IsLoop = true;
    image.IsPlaying = false;

    image.Duration = Duration;
    image.Tick = 0;
    image.PageTime = image.Duration / #image.Quads

    image.RenderType = ImageAnimaRenderType.ASMeshQuad

    image.MeshQuad = MeshQuad.new(image.xsize, image.ysize, LColor.new(255,255,255,255), image)

    image.CurrentIndex = 1

    return image;
end

function ImageAnima.CreateFromImage(obj, x1, y1, x2, y2, xnum, ynum, Duration, ...)
    local image = setmetatable({}, ImageAnima);

    if type(obj) == 'table' and obj.renderid == Render.ImageId then
        image.obj = obj.obj
    else
        image.obj = love.graphics.newImage(obj, ...)
    end

    image.transform = Matrix.new()

    image.renderid = Render.ImageAnimaId;
    image.Quads = {}

    image.w = image:getWidth()
    image.h = image:getHeight()
    
    image.x1 = x1 or 0
    image.y1 = y1 or 0
    image.x2 = x2 or 0
    image.y2 = y2 or 0

    image.xsize = image.w / xnum
    image.ysize = image.h / ynum
    for j = y1, y2 do
        for i = x1, x2 do
            image.Quads[#image.Quads + 1] = love.graphics.newQuad( (i - 1) * image.xsize, (j - 1) * image.ysize, image.xsize, image.ysize, image.obj);
        end
    end
    image.CurrentQuad = image.Quads[1]
    
    image.alpha = 1

    image.IsLoop = true;
    image.IsPlaying = false;

    image.Duration = Duration;
    image.Tick = 0;
    image.PageTime = image.Duration / #image.Quads

    image.RenderType = ImageAnimaRenderType.ASMeshQuad

    image.MeshQuad = MeshQuad.new(image.xsize, image.ysize, LColor.new(255,255,255,255), image)

    image.CurrentIndex = 1
    return image;
end

function ImageAnima.CreateFromImageAnima(obj, x1, y1, x2, y2,  Duration)
    local image = setmetatable({}, ImageAnima);

    image.obj = obj.obj

    image.transform = Matrix.new()

    image.renderid = Render.ImageAnimaId;

    image.w = image:getWidth()
    image.h = image:getHeight()

    image.x = 0
    image.y = 0

    image.Quads = {}
    image.xsize = obj.xsize
    image.ysize = obj.ysize
    image.xnum = obj.xnum
    image.ynum = obj.ynum
    for j = y1, y2 do
        for i = x1, x2 do
            image.Quads[#image.Quads + 1] = love.graphics.newQuad( (i - 1) * image.xsize, (j - 1) * image.ysize, image.xsize, image.ysize, image.obj);
        end
    end

    image.CurrentQuad = image.Quads[1]
    
    image.alpha = obj.alpha

    image.IsLoop = true;
    image.IsPlaying = false;

    image.Duration = Duration;
    image.Tick = 0;
    image.PageTime = image.Duration / #image.Quads

    image.RenderType = obj.RenderType

    image.MeshQuad = MeshQuad.new(image.xsize, image.ysize, LColor.new(255,255,255,255), image)
    
    image.CurrentIndex = 1

    return image
end

function ImageAnima:SetDuration(Duration)
    self.Duration = Duration;
    self.PageTime = self.Duration / #self.Quads
end

function ImageAnima:SetFlowMap(name, ...)
    self.FlowMap =  ImageEx.new(name, ...)
end

function ImageAnima:Play()
    self.IsPlaying = true

    table.insert(ImageAnimaManager.ImageAnimas, self)
end

function ImageAnima:SwitchNextFrame()
    if self.IsPlaying then
        return
    end
end

function ImageAnima:Stop()
    self.IsPlaying = false
    self.Tick = 0

    self:RemoveSelf()
end

function ImageAnima:Pause()
    self.IsPlaying = false

    self:RemoveSelf()
end

function ImageAnima:IsRenderAsImage()
    return self.RenderType == ImageAnimaRenderType.ASImage
end

function ImageAnima:IsRenderAsMeshQuad()
    return self.RenderType == ImageAnimaRenderType.ASMeshQuad
end

function ImageAnima:RemoveSelf()
    for i = 1, #ImageAnimaManager.ImageAnimas do
        if ImageAnimaManager.ImageAnimas[i] == self then
            table.remove(ImageAnimaManager.ImageAnimas, i)
            break;
        end
    end
end

function ImageAnima:Update(dt)
    self.Tick = self.Tick + dt

    local Index = 0
    if self.Tick < self.Duration then
        Index = math.ceil(self.Tick / self.PageTime)
        self.CurrentQuad = self.Quads[Index]
    else
        if not self.IsLoop then
            self:Pause()
            Index = #ImageAnimaManager.ImageAnimas
            self.CurrentQuad = self.Quads[Index]
        else
            self.Tick = self.Tick % self.Duration
            Index = math.ceil(self.Tick / self.PageTime)
            self.CurrentQuad = self.Quads[Index]
        end
    end

    if self:IsRenderAsMeshQuad() then
        local x, y, w, h = self.CurrentQuad:getViewport( )
        local StartU = x / self:getWidth()
        local StartV = y / self:getHeight()

        local ScaleU = w / self:getWidth()
        local ScaleV = h / self:getHeight()

        local NextIndex = (Index + 1)
        if NextIndex > #self.Quads then
            self.shader = ImageAnimaShader.GetImageAnimaShader(StartU, StartV, ScaleU, ScaleV)
        else
            local nx, ny, nw, hn = self.Quads[NextIndex]:getViewport( )
            local NextU = nx / self:getWidth()
            local NextV = ny / self:getHeight()
            self.shader = ImageAnimaShader.GetImageAnimaShader(StartU, StartV, ScaleU, ScaleV, self.FlowMap, (self.Tick % self.PageTime) / self.PageTime, NextU, NextV)
        end
    
        
    end
end

function ImageAnima:draw()
    Render.RenderObject(self)
end