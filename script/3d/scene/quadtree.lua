local LT_NODE = 1
local RT_NODE = 2
local RB_NODE = 3
local LB_NODE = 4

_G.QuadTree = {}
_G.QuadTreeNode = {}

function QuadTree.new()
    local quadtree = setmetatable({}, {__index = QuadTree});
    quadtree.rootnode = QuadTreeNode.new()
    return quadtree;
end

function QuadTree:CreateOctreesNode(boxsize, size, func)
    self.rootnode = QuadTreeNode.new(-size * 0.5, -size * 0.5, size * 0.5, size * 0.5)

    self.rootnode.isLeaf = false;
    self.rootnode:CreateChildNodes(boxsize, func);
end

function QuadTree:DebugDraw(dt)
    self.rootnode:DebugDraw()
end

function QuadTree:getFrustumResultNodes(frustum, tiles)
    self.rootnode:getFrustumResultNodes(frustum, tiles)
end

function QuadTree:Update(dt, frustum, tiles)
    self:getFrustumResultNodes(frustum, tiles)
end



function QuadTreeNode.new(x1, y1, x2, y2)
    local node = setmetatable({}, {__index = QuadTreeNode});
    -- node.Box = Box2D.new(x1, y1, x2, y2)
    node.Box = BoundBox.buildFromMinMax(Vector3.new(x1, y1, -100), Vector3.new(x2, y2, 100))
    node.IsLeaf = false;

    node.Layer = 1;

    node.Index = 0;

    node.NumberMeshNodes = 0

    node.FrameToken = 0

    node.Visible = true

    node.SubNodes = {}
    return node;
end

function QuadTreeNode:CreateChildNodes(size, func)
    local sizetemp = math.max(self.Box.max.x - self.Box.min.x, self.Box.max.y - self.Box.min.y)
    if size >= sizetemp then
        self.IsLeaf = true
        if func and type(func) == 'function' then
            func(self)
        end

        return
    end

    local center = Vector.new((self.Box.min.x + self.Box.max.x) * 0.5, (self.Box.min.y + self.Box.max.y) * 0.5)
    self.SubNodes[LT_NODE] = QuadTreeNode.new(self.Box.min.x, self.Box.min.y, center.x, center.y)
    self.SubNodes[RT_NODE] = QuadTreeNode.new(center.x, self.Box.min.y, self.Box.max.x, center.y)
    self.SubNodes[RB_NODE] = QuadTreeNode.new(center.x, center.y, self.Box.max.x, self.Box.max.y)
    self.SubNodes[LB_NODE] = QuadTreeNode.new(self.Box.min.x, center.y, center.x, self.Box.max.y)

    self.SubNodes[LT_NODE]:CreateChildNodes(size, func)
    self.SubNodes[RT_NODE]:CreateChildNodes(size, func)
    self.SubNodes[RB_NODE]:CreateChildNodes(size, func)
    self.SubNodes[LB_NODE]:CreateChildNodes(size, func)

    self.SubNodes[LT_NODE].Parent = self
    self.SubNodes[RT_NODE].Parent = self
    self.SubNodes[RB_NODE].Parent = self
    self.SubNodes[LB_NODE].Parent = self

end


function QuadTreeNode:getFrustumResultNodes(frustum, Tiles) 
    if self.IsLeaf then
        if self.Tile then
            Tiles[#Tiles + 1] = self.Tile
        end
    else
        if frustum:insideBox(self.Box) then
            for i = 1, 4 do
                self.SubNodes[i]:getFrustumResultNodes(frustum, Tiles)
            end
        else
            -- log('test frustum cull....')
        end
    end
 
    return nil
end

function QuadTreeNode:DebugDraw(dt)
    if self.IsLeaf then
        if not self.DebugLine then
            self.DebugLine = {}
            
            local min = self.Box.min
            local max = self.Box.max

            local v1 = Vector3.new(min.x, min.y, 0)
            local v2 = Vector3.new(max.x, min.y, 0)
            local v3 = Vector3.new(max.x, max.y, 0)
            local v4 = Vector3.new(min.x, max.y, 0)

            self.DebugLine[#self.DebugLine + 1] = MeshLine.new(v1, v2)
            self.DebugLine[#self.DebugLine + 1] = MeshLine.new(v2, v3)
            self.DebugLine[#self.DebugLine + 1] = MeshLine.new(v3, v4)
            self.DebugLine[#self.DebugLine + 1] = MeshLine.new(v4, v1)
        end

        for i = 1, #self.DebugLine do
            self.DebugLine[i]:draw(dt)
        end
    else
        self.SubNodes[LT_NODE]:DebugDraw(dt)
        self.SubNodes[RT_NODE]:DebugDraw(dt)
        self.SubNodes[RB_NODE]:DebugDraw(dt)
        self.SubNodes[LB_NODE]:DebugDraw(dt)
    end
end