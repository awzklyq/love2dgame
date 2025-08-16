_G.JocaBianNode = {}

JocaBianNode._Meta = {}
JocaBianNode._Meta.__index = JocaBianNode

function JocaBianNode.new(InPosition, InParentNode, InRenderW, InRenderH)
    local obj = setmetatable({}, JocaBianNode._Meta)
    obj:Init(InPosition, InParentNode, InRenderW, InRenderH)

    return obj
end

function JocaBianNode:Init(InPosition, InParentNode, InRenderW, InRenderH)
    self.transform3d = Matrix3D.new()
    self.transform3d:mulTranslationRight(InPosition)
    self:GenerateRenderData(InPosition, InRenderW, InRenderH)
end

function JocaBianNode:GenerateRenderData(InPosition, InRenderW, InRenderH)
    self._NodeRenderLines = MeshLines.CreateFourSidedCone(InRenderW, InRenderH)
    self._NodeRenderLines:setTransform(self.transform3d)
end

function JocaBianNode:ResetRenderTransform()
    self._NodeRenderLines:setTransform(self.transform3d)
end

function JocaBianNode:draw()
    self._NodeRenderLines:draw()
end