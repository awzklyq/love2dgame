_G.DDARayTrace = {}

DDARayTrace.GetTest2DResult = function(StartV, EndV, S, Dir, VoxelSize)
    local CurrentV = Vector.new(math.floor((S.x - StartV.x) / VoxelSize.x), math.floor((S.y - StartV.y) / VoxelSize.y))

    Dir:normalize()
    local InvDir = Vector.new()
    local StepV = Vector.new()
    local T = Vector.new()
    local DeltaT = Vector.new()

    local Testresult = {}
    if not Dir:IsZero() then
        StepV(Dir.x > 0 and 1 or -1, Dir.y > 0 and 1 or -1)
        InvDir(1.0 / Dir.x, 1.0 / Dir.y)
        T(S.x - CurrentV.x * VoxelSize.x, S.y - CurrentV.y * VoxelSize.y)
    else
        return Testresult
    end

    DeltaT(VoxelSize.x * InvDir.x, VoxelSize.y * InvDir.y)

   
    local VoxelIncr = Vector.new()

    local Steps = 10;
    for i = 1, Steps do
        local XLessThanY = T.x < T.y
        VoxelIncr(XLessThanY and 1 or 0,  XLessThanY and 0 or 1)

        T = T + Vector.abs(VoxelIncr *  DeltaT);
        CurrentV = CurrentV + VoxelIncr * StepV
        Testresult[#Testresult + 1] = Vector.new(CurrentV.x, CurrentV.y)
    end
    return Testresult
end

DDARayTrace.GetTest2DResult2 = function(StartV, EndV, S, EndP, VoxelSize)
    local CurrentV = Vector.new(math.floor((S.x - StartV.x) / VoxelSize.x), math.floor((S.y - StartV.y) / VoxelSize.y))

    local EndV = Vector.new(math.floor((EndP.x - StartV.x) / VoxelSize.x), math.floor((EndP.y - StartV.y) / VoxelSize.y))

    -- local Dir = EndP - S
    local Dir = (EndV * VoxelSize) + (VoxelSize * 0.5) - (CurrentV * VoxelSize) + (VoxelSize * 0.5)
    Dir:normalize()
    local InvDir = Vector.new()
    local StepV = Vector.new()
    local T = Vector.new()
    local DeltaT = Vector.new()

    local Testresult = {}

    if not Dir:IsZero() then
        StepV(Dir.x > 0 and 1 or -1, Dir.y > 0 and 1 or -1)
        InvDir( Dir.x ~= 0 and 1.0 / Dir.x or 1, Dir.y ~= 0 and 1.0 / Dir.y or 1)
        T(S.x - CurrentV.x * VoxelSize.x, S.y - CurrentV.y * VoxelSize.y)
    else
        return Testresult
    end

    DeltaT(VoxelSize.x * InvDir.x, VoxelSize.y * InvDir.y)
    -- log('aaaaaaa', InvDir.x, InvDir.y, DeltaT.x, DeltaT.y)
    local VoxelIncr = Vector.new()
    local Steps = 1000;
    for i = 1, Steps do
        local XLessThanY = T.x < T.y

        local YLessThanX = T.y < T.x
        VoxelIncr(YLessThanX and 0 or 1,  XLessThanY and 0 or 1)
        
        if EndV.x == CurrentV.x then
            DeltaT.y = 0
        elseif EndV.y == CurrentV.y then
            DeltaT.x = 0
        end
        
        T = T + Vector.abs(VoxelIncr *  DeltaT);
        CurrentV = CurrentV + VoxelIncr * StepV
        Testresult[#Testresult + 1] = Vector.new(CurrentV.x, CurrentV.y)
        if EndV == CurrentV then
            
            break
        end

    end
    return Testresult
end


DDARayTrace.GetTest3DResult = function(StartV, EndV, S, Dir, VoxelSize)
    local CurrentV = Vector3.new(math.floor((S.x - StartV.x) / VoxelSize.x), math.floor((S.y - StartV.y) / VoxelSize.y), math.floor((S.z - StartV.z) / VoxelSize.z))

    Dir:normalize()
    local InvDir = Vector3.new()
    local StepV = Vector3.new()
    local T = Vector3.new()
    local DeltaT = Vector3.new()

    local Testresult = {}
    if not Dir:IsZero() then
        StepV(Dir.x > 0 and 1 or -1, Dir.y > 0 and 1 or -1, Dir.z > 0 and 1 or -1)
        InvDir(1.0 / Dir.x, 1.0 / Dir.y, 1.0 / Dir.z)
        T(S.x - CurrentV.x * VoxelSize.x, S.y - CurrentV.y * VoxelSize.y, S.z - CurrentV.z * VoxelSize.z)
    else
        return Testresult
    end

    DeltaT(VoxelSize.x * InvDir.x, VoxelSize.y * InvDir.y, VoxelSize.z * InvDir.z)

    local VoxelIncr = Vector3.new()

    local Steps = 30;
    for i = 1, Steps do
        local XLessThanYZ = T.x <= T.y and T.x <= T.z
        local YLessThanXZ = T.y <= T.x and T.y <= T.z
        local ZLessThanXY = T.z <= T.x and T.z <= T.y
        VoxelIncr(XLessThanYZ and 1 or 0,  YLessThanXZ and 1 or 0, ZLessThanXY and 1 or 0)

        T = T + Vector3.abs(VoxelIncr *  DeltaT);
        CurrentV = CurrentV + VoxelIncr * StepV

        Testresult[#Testresult + 1] = Vector3.new(CurrentV.x, CurrentV.y, CurrentV.z)
    end
    return Testresult
end