_G.__createClassFromLoveObj("BillBoard")

local BillBoardNumber = 0
local BillBoardTransformUpdata = setmetatable({}, {__mode = "v"})  

local AddToUpdate = function(b)
    table.insert(BillBoardTransformUpdata, b)
    BillBoardNumber = BillBoardNumber + 1
end

local RemoveFromUpdate = function(i)
    table.remove(BillBoardTransformUpdata, i)
    BillBoardNumber = BillBoardNumber - 1
end

local vertexFormat = {
    {"VertexPosition", "float", 3},
    {"VertexTexCoord", "float", 2},
    {"VertexColor", "float", 3},--normal
    {"ConstantColor", "byte", 4},
}

--{x,y,z,u,v,nx,ny,nz}
local QuadData = 
{
    {-0.5, 0, -0.5, 0, 0, 0, 1, 0},
    {0.5, 0, -0.5, 1, 0, 0, 1, 0},
    {0.5, 0, 0.5, 1, 1, 0, 1, 0},
    {-0.5, 0, -0.5, 0, 0, 0, 1, 0},
    {0.5, 0, 0.5, 1, 1, 0, 1, 0},
    {-0.5, 0, 0.5, 0, 1, 0, 1, 0}
}
function BillBoard.new(w, h)-- lw :line width
    local mesh = setmetatable({}, BillBoard);

    mesh.transform3d = Matrix3D.new();

    local datas = {}
    for i = 1, 6 do
        datas[i] = {}
        datas[i][1] = QuadData[i][1] * w
        datas[i][2] = QuadData[i][2]
        datas[i][3] = QuadData[i][3] * h
        datas[i][4] = QuadData[i][4]
        datas[i][5] = QuadData[i][5]
        datas[i][6] = QuadData[i][6]
        datas[i][7] = QuadData[i][7]
        datas[i][8] = QuadData[i][8]
    end
    
    mesh.verts = datas
    mesh.shader = Shader.GetBillBoardBaseShader()
    mesh.obj = love.graphics.newMesh(vertexFormat, mesh.verts, "triangles")

    mesh.box = BoundBox.buildFromMesh3D(mesh)
    
    mesh.visible = true

    mesh.Position = Vector3.new()

    mesh.bcolor = LColor.new(255,255,255,255)
    mesh.renderid = Render.BillBoardId;

    mesh.Scale = Vector3.new(1, 1, 1)

    mesh.Alpha = 1.0

    AddToUpdate(mesh)

    return mesh
end

function BillBoard:SetCanvas(canvas)
    self:setTexture(canvas.obj)
end

function BillBoard:SetImage(image)
    self:setTexture(image.obj)
end

function BillBoard:UpdateTransform(CameraDir)
    local mat = RotationMatrixs.MakeFromYZ(CameraDir, currentCamera3D.up)
    -- local mat = RotationMatrixs.MakeFromYZ(CameraDir, currentCamera3D.up)
    -- mat[4] = self.Position.x
    -- mat[8] = self.Position.y
    -- mat[12] = self.Position.z

    mat:mulScalingLeft(self.Scale.x, self.Scale.y, self.Scale.z)

    mat:mulTranslationRight(self.Position.x, self.Position.y, self.Position.z)
    self.transform3d:Set(mat)
end

function BillBoard:draw()
    if not self.visible then return end

    local camera3d = _G.getGlobalCamera3D()
  

    --self.shader:SetBillboardValue(self.Alpha)
    self.shader:setCameraAndMatrix3D(self.transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix(), camera3d.eye, self)
    
 
    if self.ShaderFunc then
        self:ShaderFunc()
    end

    Render.RenderObject(self)
end


app.update(function(dt)
    local cameradir = currentCamera3D:GetDirction()
    for i = BillBoardNumber, 1, -1 do
        if not BillBoardTransformUpdata[i] then
            RemoveFromUpdate(i)
        else
            BillBoardTransformUpdata[i]:UpdateTransform(cameradir)
        end
    end
end)