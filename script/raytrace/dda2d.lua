_G.DDAStateFor2D = {}

function DDAStateFor2D.new(InRayDir, InRaySourcePoint, InStepSign, InDeltaT)
    local DDAState = setmetatable({}, {__index = DDAStateFor2D});
   
    DDAState.renderid = Render.DDAStateFor2DId

    DDAState.RayDir = InRayDir
    DDAState.RaySourcePoint = InRaySourcePoint;
    DDAState.StepSign = InStepSign
    DDAState.DeltaT = InDeltaT

    return DDAState;
end