
_G.Voronoi = {}

Delaunay = {}

local DelaunayTriangles = {}

Delaunay.Init = function()
    DelaunayTriangles = {}
end

Delaunay.RemoveTriangle = function(Triangle)
    local isremove = false
    for i = #DelaunayTriangles, 1, -1 do
        if Triangle:CheckTriangleEqual(DelaunayTriangles[i]) then
            -- Triangle:Release()
            table.remove( DelaunayTriangles, i)
            isremove = true
        end
    end

    if not isremove then
        errorAssert(false, "not isremove")
    end
   
end

Delaunay.AddTriangle = function(Triangle, CheckIntersect)
    local needadd = true
    for i = 1, #DelaunayTriangles do
        if Triangle:CheckTriangleEqual(DelaunayTriangles[i]) then
            needadd = false
            break
        end
    end

    if needadd then
        DelaunayTriangles[#DelaunayTriangles + 1] = Triangle
    end
   
end

Delaunay.FindCirclesForInsertPoint = function(p)
    local InTraingle = nil
    for i = 1, #DelaunayTriangles do
        if DelaunayTriangles[i]:CheckPointIn(p) then
            InTraingle = DelaunayTriangles[i]
            break
        end
    end

    if not InTraingle then
        p:Log('P ')
        errorAssert(false, "not InTraingle")
    end

    return InTraingle
end

Delaunay.FindSampleEdgeTriangle = function(InTriangle, edge)
    for i = 1, #DelaunayTriangles do
        if  InTriangle:CheckTriangleEqual(DelaunayTriangles[i]) == false then
            local result = DelaunayTriangles[i]:GetEdgeEqual(edge)
            if result then
                return DelaunayTriangles[i]
            end
        end
    end

    return nil
end

Delaunay.CheckPointInOutCircle = function(p, InTriangle, edge)
    local tri = Delaunay.FindSampleEdgeTriangle(InTriangle, edge)
    if tri then
        return tri:CheckPointInOutCircle(p), tri
    end

    return false, nil
end

Delaunay.GetNewTrianglesFormEdge = function(InTriangle, OtherTriangle, p, edge)
 
    local Results = {}
    --if Triangle2D.PointsEnableBuildTriagnle(InTriangle.P1, InTriangle.P2, p) and Triangle2D.PointsEnableBuildTriagnle(InTriangle.P1, InTriangle.P3, p) and Triangle2D.PointsEnableBuildTriagnle(InTriangle.P2, InTriangle.P3, p) and Triangle2D.PointsEnableBuildTriagnle(OtherTriangle.P1, OtherTriangle.P2, p) and Triangle2D.PointsEnableBuildTriagnle(OtherTriangle.P1, OtherTriangle.P3, p) and Triangle2D.PointsEnableBuildTriagnle(OtherTriangle.P2, OtherTriangle.P3, p) then
        local newts = {}
        -- log()
        -- log("aaaaaaaa", p.x, p.y)
        -- OtherTriangle:Log("OtherTriangle")
        -- InTriangle:Log("InTriangle")
        newts[#newts + 1] = Triangle2D.new(InTriangle.P1, InTriangle.P2, p)
        newts[#newts + 1] = Triangle2D.new(InTriangle.P1, InTriangle.P3, p)
        newts[#newts + 1] = Triangle2D.new(InTriangle.P2, InTriangle.P3, p)

        newts[#newts + 1] = Triangle2D.new(OtherTriangle.P1, OtherTriangle.P2, p)
        newts[#newts + 1] = Triangle2D.new(OtherTriangle.P1, OtherTriangle.P3, p)
        newts[#newts + 1] = Triangle2D.new(OtherTriangle.P2, OtherTriangle.P3, p)

        
        for i  = 1, #newts do
            if newts[i]:GetEdgeEqual(edge) == nil then
                Results[#Results + 1] = newts[i]
            end
        end
    --end

    return Results
end

Delaunay.GetEdgesByTriangle = function(edge, Tri1, Tri2)
    local P1 = Tri1:GetOtherPointFromEdge(edge)
    local P2 = Tri2:GetOtherPointFromEdge(edge)

    local Edges = {}
    Edges[#Edges + 1] = Edge2D.new(P1, edge.P1)
    Edges[#Edges + 1] = Edge2D.new(P1, edge.P2)

    Edges[#Edges + 1] = Edge2D.new(P2, edge.P1)
    Edges[#Edges + 1] = Edge2D.new(P2, edge.P1)
    return Edges
end

Delaunay.GetNewTriangles= function(p, InTriangle)
    local NewTriangles = nil

    local OtherEdges = {}
    if #DelaunayTriangles > 1 then
        local isneed, tri = Delaunay.CheckPointInOutCircle(p, InTriangle, InTriangle.edge1)
        if isneed then
            NewTriangles = Delaunay.GetNewTrianglesFormEdge(InTriangle, tri, p, InTriangle.edge1)

            if #NewTriangles ~= 0 then
                Delaunay.RemoveTriangle(tri)
            
                OtherEdges = Delaunay.GetEdgesByTriangle(InTriangle.edge1, InTriangle, tri)
            else
                isneed = false
            end
            
        end

        if not isneed then
            isneed, tri = Delaunay.CheckPointInOutCircle(p, InTriangle, InTriangle.edge2)
            if isneed then
                NewTriangles = Delaunay.GetNewTrianglesFormEdge(InTriangle, tri, p, InTriangle.edge2)

                if #NewTriangles ~= 0 then
                    Delaunay.RemoveTriangle(tri)
                
                    OtherEdges = Delaunay.GetEdgesByTriangle(InTriangle.edge2, InTriangle, tri)
                else
                    isneed = false
                end
            end
        end

        if not isneed then
            isneed, tri = Delaunay.CheckPointInOutCircle(p, InTriangle, InTriangle.edge3)
            if isneed then
                NewTriangles = Delaunay.GetNewTrianglesFormEdge(InTriangle, tri, p, InTriangle.edge3)

                if #NewTriangles ~= 0 then
                    Delaunay.RemoveTriangle(tri)
                
                    OtherEdges = Delaunay.GetEdgesByTriangle(InTriangle.edge3, InTriangle, tri)
                else
                    isneed = false
                end
            end
        end
    end

    if not NewTriangles or #NewTriangles == 0 then
        NewTriangles = {}
        OtherEdges = {}
        NewTriangles[#NewTriangles + 1] = Triangle2D.new(InTriangle.P1, InTriangle.P2, p)
        NewTriangles[#NewTriangles + 1] = Triangle2D.new(InTriangle.P1, InTriangle.P3, p)
        NewTriangles[#NewTriangles + 1] = Triangle2D.new(InTriangle.P2, InTriangle.P3, p)

        OtherEdges[#OtherEdges + 1] = Edge2D.new(InTriangle.P1, InTriangle.P2)
        OtherEdges[#OtherEdges + 1] = Edge2D.new(InTriangle.P1, InTriangle.P3)
        OtherEdges[#OtherEdges + 1] = Edge2D.new(InTriangle.P2, InTriangle.P3)
    end

    Delaunay.RemoveTriangle(InTriangle)

    return NewTriangles, OtherEdges
end


Delaunay.GetTrianglesByEdge = function(edge)
    local Result = {}
    for i = 1, #DelaunayTriangles do
        local temp = DelaunayTriangles[i]:GetEdgeEqual(edge)
        if temp then
            Result[#Result + 1] = DelaunayTriangles[i]

            if #Result == 2 then
                break
            end
        end
        
    end

    return Result
end

Delaunay.GetTrianglesByEdge = function(edge)
    local Result = {}
    for i = 1, #DelaunayTriangles do
        local temp = DelaunayTriangles[i]:GetEdgeEqual(edge)
        if temp then
            Result[#Result + 1] = DelaunayTriangles[i]

            if #Result == 2 then
                break
            end
        end
        
    end

    return Result
end


Delaunay.SwapTrianges = function(Tri1, Tri2, edge)
    local P1 = Tri1:GetOtherPointFromEdge(edge)
    local P2 = Tri2:GetOtherPointFromEdge(edge)

    local newTri1 = Triangle2D.new(P1, P2, edge.P1)
    local newTri2 = Triangle2D.new(P1, P2, edge.P2)


    Delaunay.RemoveTriangle(Tri1)
    Delaunay.RemoveTriangle(Tri2)

    Delaunay.AddTriangle(Tri1)
    Delaunay.AddTriangle(Tri2)
end 

Delaunay.OptimizeTriangle = function(OtherEdges)
    for i = 1, #OtherEdges do
        local tris = Delaunay.GetTrianglesByEdge(OtherEdges[i])
        if #tris == 2 then
            if tris[1]:CheckPointInOutCircle(tris[2]:GetOtherPointFromEdge(OtherEdges[i])) or tris[2]:CheckPointInOutCircle(tris[1]:GetOtherPointFromEdge(OtherEdges[i])) then
                Delaunay.SwapTrianges(tris[1], tris[2], OtherEdges[i])
            end
        end
    end
end

Delaunay.InsertPoint = function(p, InTraingle)
    local NewTriangles, OtherEdges = Delaunay.GetNewTriangles(p, InTraingle)

    for i = 1, #NewTriangles do
        Delaunay.AddTriangle(NewTriangles[i])
    end

    if Voronoi.Test11 then
        Delaunay.OptimizeTriangle(OtherEdges)
    end
end


Delaunay.Process = function(Points, FirstTri)
    DelaunayTriangles[#DelaunayTriangles + 1] = FirstTri
    for i = 1, #Points do
        local Triangles = Delaunay.FindCirclesForInsertPoint(Points[i])
        
        Delaunay.InsertPoint(Points[i], Triangles)
    end
end

Voronoi.Process = function(Points, FirstTri)
    Delaunay.Init()
    Delaunay.Process(Points, FirstTri)

    local ResetsTri = {}
    for i = 1, #DelaunayTriangles do
        local dt = DelaunayTriangles[i]
        -- if not dt:CheckOnePoint(FirstTri.P1) and not dt:CheckOnePoint(FirstTri.P1) and not dt:CheckOnePoint(FirstTri.P2) then
            ResetsTri[#ResetsTri + 1] = DelaunayTriangles[i]
        -- end
    end

    --Remove FirstTri
    table.remove(ResetsTri, 1)
    -- for i = #ResetsTri, 1, -1 do
    --     if ResetsTri[i]:HasPoint(FirstTri.P1) or ResetsTri[i]:HasPoint(FirstTri.P2) or ResetsTri[i]:HasPoint(FirstTri.P3) then
    --         table.remove(ResetsTri, i)
    --     end
    -- end

    return ResetsTri
end

Voronoi.AddPoint = function(Point, FirstTri)
    local Triangles = Delaunay.FindCirclesForInsertPoint(Point)
       
    Delaunay.InsertPoint(Point, Triangles, FirstTri)

    local ResetsTri = {}
    for i = 1, #DelaunayTriangles do
        local dt = DelaunayTriangles[i]
        -- if not dt:CheckOnePoint(FirstTri.P1) and not dt:CheckOnePoint(FirstTri.P1) and not dt:CheckOnePoint(FirstTri.P2) then
            ResetsTri[#ResetsTri + 1] = DelaunayTriangles[i]
        -- end
    end
    return ResetsTri
end