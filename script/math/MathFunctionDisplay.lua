_G.MathFunctionDisplay = {}

function MathFunctionDisplay.new(w ,h)
    local mfd = setmetatable({}, {__index = MathFunctionDisplay});

    mfd.ScaleX = 1
    mfd.ScaleY = 1
    mfd:ResetWH(w, h)
    mfd.renderid = Render.MathFunctionDisplayId

    return mfd;
end

function MathFunctionDisplay:ResetWH(w, h)

    local startx1 = 0
    local starty1 = h * 0.5

    local endx1 = w - 10
    local endy1 = starty1

    local startx2 = w * 0.5
    local starty2 = 10

    local endx2 = w * 0.5
    local endy2 = h


    self.xaix = Line.new(startx1, starty1, endx1, endy1)

    -- self.xaix:SetColor(255, 0, 0, 255)

    self.yaix = Line.new(startx2, starty2, endx2, endy2)
    -- self.yaix:SetColor(0, 255, 0, 255)

    self.Center = Vector.new(w * 0.5, h * 0.5)

    if self.GenetrateCallBack1 then
        self:GeneratePoints1(self.GenerateSX1, self.GenerateEX1, self.GeneratePfffset1, self.Color1, self.GenetrateCallBack1)
    end

    if self.GenetrateCallBack2 then
        self:GeneratePoints2(self.GenerateSX2, self.GenerateEX2, self.GeneratePfffset2, self.Color2, self.GenetrateCallBack2)
    end

    if self.GenetrateCallBack3 then
        self:GeneratePoints3(self.GenerateSX3, self.GenerateEX3, self.GeneratePfffset3, self.Color3, self.GenetrateCallBack3)
    end
end

function MathFunctionDisplay:GeneratePoints1(sx, ex, offset, color, func)
    self.GenetrateCallBack1 = func
    self.GenerateSX1 = sx
    self.GenerateEX1 = ex
    self.GeneratePfffset1 = offset
    self.Color1 = color or LColor.new(255,255,255,255)

    self.points1 = {}
    local Points = self.points1
    for i = sx, ex, offset do
        local j = func(i)
        Points[#Points + 1] = Vector.new(i * self.ScaleX, j * self.ScaleY)
    end

    self.Lines1 = {}
    local Lines = self.Lines1
    for i = 1, #Points - 1 do
        Lines[#Lines + 1] = Line.new(self.Center.x + Points[i].x * self.ScaleX, self.Center.y - Points[i].y * self.ScaleY, self.Center.x + Points[i +1].x * self.ScaleX, self.Center.y - Points[i +1].y * self.ScaleY)
        Lines[#Lines].color = self.Color1
    end
end

function MathFunctionDisplay:GeneratePoints2(sx, ex, offset, color,  func)
    self.GenetrateCallBack2 = func
    self.GenerateSX2 = sx
    self.GenerateEX2 = ex
    self.GeneratePfffset2 = offset
    self.Color2 = color or LColor.new(255,255,255,255)

    self.points2 = {}
    local Points = self.points2
    for i = sx, ex, offset do
        local j = func(i)
        Points[#Points + 1] = Vector.new(i * self.ScaleX, j * self.ScaleY)
    end

    self.Lines2 = {}
    local Lines = self.Lines2
    for i = 1, #Points - 1 do
        Lines[#Lines + 1] = Line.new(self.Center.x + Points[i].x * self.ScaleX, self.Center.y - Points[i].y * self.ScaleY, self.Center.x + Points[i +1].x * self.ScaleX, self.Center.y - Points[i +1].y * self.ScaleY)
        Lines[#Lines].color = self.Color2
    end
end

function MathFunctionDisplay:GeneratePoints3(sx, ex, offset, color, func)
    self.GenetrateCallBack3 = func
    self.GenerateSX3 = sx
    self.GenerateEX3 = ex
    self.GeneratePfffset3 = offset
    self.Color3 = color or LColor.new(255,255,255,255)

    self.points3 = {}
    local Points = self.points3
    for i = sx, ex, offset do
        local j = func(i)
        Points[#Points + 1] = Vector.new(i * self.ScaleX, j * self.ScaleY)
    end

    self.Lines3 = {}
    local Lines = self.Lines3
    for i = 1, #Points - 1 do
        Lines[#Lines + 1] = Line.new(self.Center.x + Points[i].x * self.ScaleX, self.Center.y - Points[i].y * self.ScaleY, self.Center.x + Points[i +1].x * self.ScaleX, self.Center.y - Points[i +1].y * self.ScaleY)
        Lines[#Lines].color = self.Color3
    end
end

function MathFunctionDisplay:SetScale(sx, sy)

    self.ScaleX = sx or 1
    self.ScaleY = sy or 1

    if self.points1 then
        self.Lines1 = {}
        local Points = self.points1
        local Lines = self.Lines1
        for i = 1, #Points - 1 do
            Lines[#Lines + 1] = Line.new(self.Center.x + Points[i].x * self.ScaleX, self.Center.y - Points[i].y * self.ScaleY, self.Center.x + Points[i +1].x * self.ScaleX, self.Center.y - Points[i +1].y * self.ScaleY)
            Lines[#Lines].color = self.Color1
        end
    end

    if self.points2 then
        self.Lines2 = {}
        local Points = self.points2
        local Lines = self.Lines2
        for i = 1, #Points - 1 do
            Lines[#Lines + 1] = Line.new(self.Center.x + Points[i].x * self.ScaleX, self.Center.y - Points[i].y * self.ScaleY, self.Center.x + Points[i +1].x * self.ScaleX, self.Center.y - Points[i +1].y * self.ScaleY)
            Lines[#Lines].color = self.Color2
        end
    end

    if self.points3 then
        self.Lines3 = {}
        local Points = self.points3
        local Lines = self.Lines3
        for i = 1, #Points - 1 do
            Lines[#Lines + 1] = Line.new(self.Center.x + Points[i].x * self.ScaleX, self.Center.y - Points[i].y * self.ScaleY, self.Center.x + Points[i +1].x * self.ScaleX, self.Center.y - Points[i +1].y * self.ScaleY)
            Lines[#Lines].color = self.Color3
        end
    end
end

function MathFunctionDisplay:draw()
    if self.Lines1 then 
        for i = 1, #self.Lines1 do
            self.Lines1[i]:draw()
        end
    end
    if self.Lines2 then 
        for i = 1, #self.Lines2 do
            self.Lines2[i]:draw()
        end
    end
    if self.Lines3 then 
        for i = 1, #self.Lines3 do
            self.Lines3[i]:draw()
        end
    end
    self.xaix:draw()
    self.yaix:draw()
end