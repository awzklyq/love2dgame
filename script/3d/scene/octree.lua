_G.Octree = {}
_G.OctreeNode = {}

function Octree.new()
    local octree = setmetatable({}, {__index = Octree});
    octree.rootnode = OctreeNode.new()
    return octree;
end

function OctreeNode.new()
    local node = setmetatable({}, {__index = OctreeNode});
    node.box = BoundBox.new()
    -- node.subnodes[8]
    node.isLeaf = false;
    return node;
end