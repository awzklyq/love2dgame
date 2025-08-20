_G.JacoBianNode = {}

JacoBianNode._Meta = {}
JacoBianNode._Meta.__index = JacoBianNode

_G.JacoBianManager = {}

function JacoBianNode.new(InPosition, InParentNode, InRenderW, InRenderH)
    local obj = setmetatable({}, JacoBianNode._Meta)
    obj:Init(InPosition, InParentNode, InRenderW, InRenderH)

   JacoBianManager.AddJacoBianNode(obj)

    return obj
end

function JacoBianNode:Init(InPosition, InParentNode, InRenderW, InRenderH)
    self.transform3d = Matrix3D.new()
    self.transform3d:mulTranslationLeft(InPosition)
    self:GenerateRenderData(InPosition, InRenderW, InRenderH)

    self:SetParentNode(InParentNode)

    self._SubNodes = {}

    self._IsRoot = not InParentNode
    self._IsEnd = true

    self._Index = _NoneIndex
end

function JacoBianNode:SetIndex(InIndex)
    self._Index = InIndex
end

function JacoBianNode:SetParentNode(InParentNode)
    self._ParentNode = InParentNode

    self._IsRoot = not InParentNode
end

function JacoBianNode:AddSubNode(InSubNode)
    self._SubNodes[#self._SubNodes + 1] = InSubNode
    InSubNode:SetParentNode(self)

    self._IsEnd = false
end

function JacoBianNode:IsRoot()
    return self._IsRoot
end

function JacoBianNode:GetParentNode()
    return self._ParentNode
end

function JacoBianNode:IsEnd()
    return self._IsEnd
end

function JacoBianNode:PushParentTransform()
    if self._ParentNode then
        self._ParentNode:PushParentTransform()
    end

    RenderSet.PusMatrix3D(self.transform3d)
end

function JacoBianNode:PopParentTransform()
    if self._ParentNode then
        self._ParentNode:PopParentTransform()
    end

    RenderSet.PopMatrix3D()
end

function JacoBianNode:ApplyParentTransform()
    if self._ParentNode then
        self._ParentNode:PushParentTransform()
    end
end

function JacoBianNode:ClearParentTransform()
    if self._ParentNode then
        self._ParentNode:PopParentTransform()
    end
end

function JacoBianNode:GenerateRenderData(InPosition, InRenderW, InRenderH)
    self._NodeRenderLines = MeshLines.CreateFourSidedCone(InRenderW, InRenderH)
    self._NodeRenderLines:setTransform(self.transform3d)
end

function JacoBianNode:ResetRenderTransform()
    self._NodeRenderLines:setTransform(self.transform3d)
end

function JacoBianNode:PushBackupTransfom()
    if not self._BackupTransform then
        self._BackupTransform = Matrix3D.new()
    end 

    self._BackupTransform:Set(self.transform3d)
end

function JacoBianNode:PopBackupTransfom()
    if not self._BackupTransform then
       return
    end 

    self.transform3d:Set(self._BackupTransform)
end

function JacoBianNode:GetWorldPosition()
    -- self:PushBackupTransfom()
    self:ApplyParentTransform()

    self:PushBackupTransfom()
    local _M = RenderSet:UseMatrix3D()

    self._BackupTransform:mulRight(_M)

    if not self._WorldPosition then
        self._WorldPosition = Vector3.new()
    end
    
    self._BackupTransform:GetPosition(self._WorldPosition)

    self:ClearParentTransform()
    -- self:PopBackupTransfom()

    return self._WorldPosition
end

function JacoBianNode:GetWorldMatrix()
    self:ApplyParentTransform()

    self:PushBackupTransfom()
    local _M = RenderSet:UseMatrix3D()

    self._BackupTransform:mulRight(_M)

    if not self._WorldTransform then
        self._WorldTransform = Matrix3D.new()
    end
    
    self._WorldTransform:Set(self._BackupTransform)

    self:ClearParentTransform()
    -- self:PopBackupTransfom()

    return self._WorldTransform
end

function JacoBianNode:draw()

    self:PushBackupTransfom()
    self:ApplyParentTransform()

    local _M = RenderSet:UseMatrix3D()
    self.transform3d:mulRight(_M)

    self:ResetRenderTransform()

    self._NodeRenderLines:draw()

    self:ClearParentTransform()
    self:PopBackupTransfom()
end


-----------------------------------------------------------------------------------------
JacoBianManager.TargetThreshold = 2.0
JacoBianManager.IterationCount = 100

local _JacoBianNodes = {}
local _RootNode = nil
local _EndNode = nil
local _TargetPosition = Vector3.new()

JacoBianManager.Init = function(InNode)
    _JacoBianNodes = {}
    _RootNode = {}
    _EndNode = {}
end

JacoBianManager.SetTargetPosition = function(InTarget)
    _TargetPosition:Set(InTarget)
end

JacoBianManager.AddJacoBianNode = function(InNode)
    _JacoBianNodes[#_JacoBianNodes + 1] = InNode
end

local _RootWTMInverse = Matrix3D.new()
local _RootWTM = Matrix3D.new()
JacoBianManager.SeleteRootNode = function()
    for i = 1, #_JacoBianNodes do
        if _JacoBianNodes[i]:IsRoot() then
            _RootNode = _JacoBianNodes[i]
            break
        end
    end

    if _RootNode then
        _RootWTM:Set(_RootNode:GetWorldMatrix())
        _RootWTMInverse:Set(_RootWTM)
    else
        _RootWTM:Identity()
        _RootWTMInverse:Identity()

    end
end

JacoBianManager.SeletEndNode = function()
    for i = 1, #_JacoBianNodes do
        if _JacoBianNodes[i]:IsEnd() then
            _EndNode = _JacoBianNodes[i]
            break
        end
    end

    if _EndNode then
        _JacoBianNodes = {}
        _JacoBianNodes[1] = _EndNode
        local _TempNode = _EndNode
        while _TempNode:IsRoot() == false do
            _TempNode = _TempNode:GetParentNode()
            _JacoBianNodes[#_JacoBianNodes + 1] = _TempNode
        end
    end


end

local _JocaBianVector4 = {}
local _InverseMatrixs = {}--Matrix3D.inverse
local _NodeMatrixs = {}
JacoBianManager.InitMatrixs = function()
    _InverseMatrixs = {}
    _NodeMatrixs = {}
    for i = 1, #_JacoBianNodes do
        _InverseMatrixs[i] = Matrix3D.inverse(_JacoBianNodes[i].transform3d)
        _NodeMatrixs[i] = Matrix3D.Copy(_JacoBianNodes[i]:GetWorldMatrix())
    end
end

JacoBianManager.StoreRelativeQuaternion = function(InRotVec4, InIndex)
    -- local matRelative = Matrix3D.Copy(_NodeMatrixs[InIndex])
    -- matRelative:mulRotationLeft(InRotVec4.x, InRotVec4.y, InRotVec4.z, InRotVec4.w)

	-- if InIndex == #_NodeMatrixs then
	-- 	matRelative = _RootWTMInverse * matRelative;
	-- else
	-- 	matRelative = _InverseMatrixs[InIndex + 1] * matRelative;
    -- end

	-- -- Store unconstrained quaternion

	-- if( false == a_bConstrainRotation )
	-- {
	-- 	m_arrCurrentQuat[a_iIndex].SetQuaternion(matRelative);
	-- 	m_arrCurrentQuat[a_iIndex].Normalize();

	-- 	return;
	-- }
end

JacoBianManager.CacleJocaBianMatrix = function()
    JacoBianManager.SeleteRootNode()
    JacoBianManager.SeletEndNode()

    JacoBianManager.InitMatrixs()

    for _Count = 1, JacoBianManager.IterationCount do
        local _MEndPosition = _NodeMatrixs[1]:GetPosition()

        local _MVecDiff = _MEndPosition - _TargetPosition

        local _MVecEntry = {}
        local _MArrAxis = {}

        _JocaBianVector4 = {}

        local _FarrError = _MVecDiff:distanceself() 

        if _FarrError <= JacoBianManager.TargetThreshold then
            break
        end

        for i = 1, #_JacoBianNodes - 1 do
            local WorldPosition = _NodeMatrixs[i + 1]:GetPosition()

            local v_target = _TargetPosition - WorldPosition
            local v_end = _MEndPosition - WorldPosition

            local axis = Vector3.cross(v_target, v_end)
            axis:normalize()
            
            local vec_entry = Vector3.cross(v_end, axis)

            _MArrAxis[i] = axis
            _MVecEntry[i] = vec_entry
        end

        local _FarrForce = {}
        _FarrForce[1] = _MVecDiff.x
        _FarrForce[2] = _MVecDiff.y
        _FarrForce[3] = _MVecDiff.z

        _FarrForce[4] = 0
        _FarrForce[5] = 0
        _FarrForce[6] = 0

        -- log('yyyyyyyy', _FarrForce[1], _FarrForce[2], _FarrForce[3])
        local _MArrQDerivate = {}
        for i = 1, #_MArrAxis do
            local axis = _MArrAxis[i]
            local vecentry = _MVecEntry[i]
            _MArrQDerivate[i] = axis.x * _FarrForce[1] + axis.y * _FarrForce[2] + axis.z * _FarrForce[3]
            _MArrQDerivate[i] = _MArrQDerivate[i] + vecentry.x * _FarrForce[4] + vecentry.y * _FarrForce[5] + vecentry.z * _FarrForce[6]
        end

        for i = 1, #_MArrQDerivate do
            local axis = _MArrAxis[i]

            --  _MArrQDerivate[i] = math.rad(170)

            local _RotVec4 = Vector4.new(axis.x, axis.y, axis.z, _MArrQDerivate[i])

        end
    end
    

end

JacoBianManager.GetJocaBianData = function(InIndex)
    return _JocaBianVector4[InIndex]
end 

JacoBianManager.DrawNodes = function()
    for i = 1, #_JacoBianNodes do
        _JacoBianNodes[i]:draw()
    end
end