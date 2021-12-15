_G.QuadTree = {}
_G.QuadTreeNode = {}

function QuadTree.new()
    local quadtree = setmetatable({}, {__index = QuadTree});
    quadtree.rootnode = QuadTreeNode.new()
    return quadtree;
end

function QuadTree:createOctreesNode(boxsize, size)
    self.rootnode = QuadTreeNode.new(-size * 0.5, -size * 0.5, size * 0.5, size * 0.5)

    self.rootnode.isLeaf = false;
    self.rootnode:createChildNodes(size);
end

function QuadTreeNode.new(x1, y1, x2, y1)
    local node = setmetatable({}, {__index = QuadTreeNode});
    node.box = Box2D.new(x1, y1, x2, y1)
    node.isLeaf = false;

    node.layer = 1;

    node.index = 0;

    node.numberMeshNodes = 0

    node.frameToken = 0

    node.visible = true
    return node;
end