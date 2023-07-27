_G.EarClip = {}

local Triangle2Ds = {}
local OriPoints = {}
EarClip.Process = function(points)
    Triangle2Ds = {}

    OriPoints = {}

    for i = 1, #points do
        OriPoints[#OriPoints + 1] = points[i]
    end

    local NeedFindEarPoint = true
    while NeedFindEarPoint do
        local NoPoint = true
        for i = #points, 1, -1 do
            local p = points[i]
            if #p.Edges ~= 2 then
                return nil
            end
    
            if EarClip.FindEarPoint(p, points) then
                table.remove(points, i)
                NoPoint = false
            end

            if #points == 3 then
                NeedFindEarPoint = false
                break
            end
        end

        if not NeedFindEarPoint then
            Triangle2Ds[#Triangle2Ds + 1] =  Triangle2D.new(points[1], points[2], points[3], false)
        else
            NeedFindEarPoint = not NoPoint
        end


    end

    return Triangle2Ds
end

EarClip.FindEarPoint = function(p, points)
    local p1 = p.Edges[1]:GetOtherPoint(p)
    local p2 = p.Edges[2]:GetOtherPoint(p)

    if p1.Order > p2.Order then
        local TempX = p2
        p2 = p1
        p1 = TempX
    end

    if p1.IsStart and p2.IsEnd then
        local TempX = p2
        p2 = p1
        p1 = TempX
    end

    local v1 = (p1 - p):normalize()
    local v2 = (p2 - p):normalize()

    if Vector.angleClockwise(v2, v1) > math.pi then
        return false
    end 

    local tri = Triangle2D.new(p, p1, p2, false)
    for i = 1, #OriPoints do
        local pp = OriPoints[i]
        if pp ~= p and pp ~= p1 and pp ~= p2 then
            if tri:CheckPointIn(pp) then
                return false
            end
        end
    end

    p1.Edges[1]:ChangePoint(p, p2)
    p1.Edges[2]:ChangePoint(p, p2)

    p2.Edges[1]:ChangePoint(p, p1)
    p2.Edges[2]:ChangePoint(p, p1)

    Triangle2Ds[#Triangle2Ds + 1] = tri

    return true
end