_G.Octree = {}
_G.OctreeNode = {}

function Octree.new()
    local octree = setmetatable({}, {__index = Octree});
    octree.rootnode = OctreeNode.new()
    return octree;
end

function Octree:createOctreesNode(box, size)
    local copybox = BoundBox.copy(box)

    local vsize = copybox.max - copybox.min;
    local max = math.max(vsize.z, math.max(vsize.x ,vsize.y));

    self.rootnode.box = BoundBox.buildFromMinMax(copybox.min, copybox.min + Vector3.new(max, max, max))
    self.rootnode.isLeaf = false;
    self.rootnode:createChildNodes(size);
end

function Octree:draw()
        local cullmode = love.graphics.getMeshCullMode()
        love.graphics.setMeshCullMode("none")
        -- love.graphics.setWireframe( true )
        self.rootnode:draw()
        -- love.graphics.setWireframe( false )
        love.graphics.setMeshCullMode(cullmode)
end


function OctreeNode.new()
    local node = setmetatable({}, {__index = OctreeNode});
    node.box = BoundBox.new()
    -- node.subnodes[8]
    node.isLeaf = false;

    node.layer = 1;

    node.index = 0;
    return node;
end

function OctreeNode:createChildNodes(size)
    local min = self.box.min
    local max = self.box.max
    local vsize = (max - min);
    local max = math.max(vsize.z, math.max(vsize.x ,vsize.y));
    local isLeaf =  size >= max;
    self.isLeaf = isLeaf
    if isLeaf then
        return
    end

    vsize = vsize * 0.5
    self.childs = {}

    
    self.childs[1] = OctreeNode.new()
    self.childs[1].box = BoundBox.buildFromMinMax(min, min + vsize)

    self.childs[2] = OctreeNode.new()
    self.childs[2].box = BoundBox.buildFromMinMax(Vector3.new(min.x + vsize.x, min.y, min.z), Vector3.new(min.x + vsize.x, min.y, min.z) + vsize)

    self.childs[3] = OctreeNode.new()
    self.childs[3].box = BoundBox.buildFromMinMax(Vector3.new(min.x , min.y + vsize.y, min.z), Vector3.new(min.x, min.y + vsize.y, min.z) + vsize)

    self.childs[4] = OctreeNode.new()
    self.childs[4].box = BoundBox.buildFromMinMax(Vector3.new(min.x + vsize.x , min.y + vsize.y, min.z), Vector3.new(min.x + vsize.x, min.y + vsize.y, min.z) + vsize)

    self.childs[5] = OctreeNode.new()
    self.childs[5].box = BoundBox.buildFromMinMax(Vector3.new(min.x, min.y, min.z + vsize.z), Vector3.new(min.x , min.y, min.z+ vsize.z) + vsize)

    self.childs[6] = OctreeNode.new()
    self.childs[6].box = BoundBox.buildFromMinMax(Vector3.new(min.x + vsize.x, min.y, min.z + vsize.z), Vector3.new(min.x + vsize.x, min.y, min.z + vsize.z) + vsize)

    self.childs[7] = OctreeNode.new()
    self.childs[7].box = BoundBox.buildFromMinMax(Vector3.new(min.x , min.y + vsize.y, min.z + vsize.z) , Vector3.new(min.x, min.y + vsize.y, min.z + vsize.z) + vsize)

    self.childs[8] = OctreeNode.new()
    self.childs[8].box = BoundBox.buildFromMinMax(Vector3.new(min.x + vsize.x , min.y + vsize.y, min.z + vsize.z), Vector3.new(min.x + vsize.x, min.y + vsize.y, min.z + vsize.z) + vsize)
    
    for i = 1, 8 do
        self.childs[i].layer = self.layer + 1
        self.childs[i].index = i
        self.childs[i]:createChildNodes(size)
    end

    -- log('cccccccccccccc', self.layer, self.index, self)
    if(self.layer == 6 and  self.index == 1) then
        log('cccccccccccccc', self.layer, self.index, debug.traceback())
    
    end
end

function OctreeNode:draw()
    if not self.boxmesh then
        self.boxmesh = self.box:buildMeshLines()
    end

    self.boxmesh:draw()

    if not self.isLeaf then
        for i = 1, 8 do
            self.childs[i]:draw()
        end
    end
end