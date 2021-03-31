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

function Octree:updateMeshNode(node)
    if node.octreenode then
        node.octreenode:removeMeshNode(node)
    end
    local result = self.rootnode:checkMeshNodeIn(node)
    if result then
        result:addMeshNode(node)
    end
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

    node.meshnodes = {}

    node.numberMeshNodes = 0

    node.visible = true
    return node;
end

function OctreeNode:addMeshNode(node)
    if self.meshnodes[node] then
        return
    end

    self.meshnodes[node] = node
    node.octreenode = self
    self.numberMeshNodes = self.numberMeshNodes + 1
end

function OctreeNode:checkIn(pos)
    local max = self.box.max
    local min = self.box.min
    return pos.x >= min.x and pos.x <= max.x and pos.y >= min.y and pos.y <= max.y and pos.z >= min.z and pos.z <= max.z
end

function OctreeNode:checkMeshNodeIn(node)
   if self:checkIn(node.mesh.transform3d:getTranslation()) == false then
       return nil
   end

   if self.isLeaf then
        return self
   else
        local result
        for i = 1, 8 do
            result = self.childs[i]:checkMeshNodeIn(node);
            if result then
                return result;
            end
        end
   end

   return nil
end

function OctreeNode:removeMeshNode(node)
    if node.octreenode ~= self then
        return
    end

    self.meshnodes[node] = nil
    node.octreenode = nil

    self.numberMeshNodes = self.numberMeshNodes - 1
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
end

function OctreeNode:draw()
    if self.isLeaf and self.numberMeshNodes > 0 and self.visible then
        if not self.boxmesh then
            self.boxmesh = self.box:buildMeshLines()
            self.boxmesh:setBGColor(LColor.new(255,0,0,255))
        end
    
        self.boxmesh:draw() 
    end

    if not self.isLeaf then
        for i = 1, 8 do
            self.childs[i]:draw()
        end
    end
end