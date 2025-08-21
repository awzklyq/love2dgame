FileManager.addAllPath("assert")

math.randomseed(os.time()%10000)

local font = Font.new"FZBaiZDZ113JW.TTF"
font:Use()

local tri = Triangle2D.new(Vector.new(100, 10), Vector.new(100, 200), Vector.new(290, 200))


local TestLines = {}
local TestTriangle2Ds = {}
local NewTestTriangle2Ds = {}
local NewTestPoints = {}
local CanGen = true
local TestPointsQ = {}
local TestPoints = {}
function GenTri()
    TestPoints = {}
    for i = 1, #TestPointsQ do
        TestPoints[#TestPoints + 1] = Vector.new(TestPointsQ[i].x, TestPointsQ[i].y)
    end

    if #TestPoints > 1 then
        TestLines = {}
        for i = 2, #TestPoints do
            TestLines[#TestLines+ 1] = Line.new(TestPoints[i - 1].x, TestPoints[i - 1].y, TestPoints[i].x, TestPoints[i].y)
        end
    end

    TestTriangle2Ds = {}
    if #TestPoints >= 3 then
        for i = 3, #TestPoints do
            TestTriangle2Ds[#TestTriangle2Ds+ 1] = Triangle2D.new(TestPoints[i - 2], TestPoints[i - 1], TestPoints[i])
            local tri2 = TestTriangle2Ds[#TestTriangle2Ds]
            tri2.edge1.Face1 = tri2
            tri2.edge2.Face1 = tri2
            tri2.edge3.Face1 = tri2

            if not TestPoints[i - 2].Faces then
                TestPoints[i - 2].Faces = {}
            end

            if not TestPoints[i - 1].Faces then
                TestPoints[i - 1].Faces = {}
            end

            if not TestPoints[i].Faces then
                TestPoints[i].Faces = {}
            end

            TestPoints[i - 2].Faces[#TestPoints[i - 2].Faces + 1] =  tri2
            TestPoints[i - 1].Faces[#TestPoints[i - 1].Faces + 1] =  tri2
            TestPoints[i].Faces[#TestPoints[i].Faces + 1] =  tri2

            if i > 3 then

                local tri1 = TestTriangle2Ds[#TestTriangle2Ds - 1]

                if tri1.edge2 == tri2.edge1 then
                    tri2.edge1.Face2 = tri1
                    tri1.edge2.Face2 = tri2
                else
                    _errorAssert(false, "TestTriangle2Ds edge face!")
                end
            end
        end
    end
end

function GetNewEdgePCC(edge)
    local VE = edge.P1 + edge.P2 + edge.Face1.VF
    if edge.Face2 then
        return (VE + edge.Face2.VF) / 4
    else
        return VE / 3
    end
end

function GenNewTriCC()
    if #TestTriangle2Ds == 0 then return end

    for i = 1, #TestPoints do
       local CP  = TestPoints[i]
       local VF = Vector.new(0, 0)
       for f = 1, #CP.Faces do
            VF = VF + CP.Faces[f].VF
       end
       CP.VQ = VF / #CP.Faces

       
       local VE = Vector.new(0, 0)
       for e = 1, #CP.Edges do
            VE = VE + (CP.Edges[e].P1 + CP.Edges[e].P2) * 0.5
       end

       CP.VR = VE / #CP.Edges
       local newp = CP.VQ / 4  + CP.VR * (1 / 2)  + CP / 4

       NewTestPoints[#NewTestPoints + 1] = newp

       CP.NewPoint = newp
   end

   NewTestTriangle2Ds = {}
   for i = 1, #TestTriangle2Ds do
        local tri = TestTriangle2Ds[i]
        tri.VE1 = GetNewEdgeP(tri.edge1)
        tri.VE2 = GetNewEdgeP(tri.edge2)
        tri.VE3 = GetNewEdgeP(tri.edge3)

        NewTestTriangle2Ds[#NewTestTriangle2Ds + 1] = Triangle2D.new(tri.VE1, tri.edge1.P1.NewPoint, tri.VF)
        NewTestTriangle2Ds[#NewTestTriangle2Ds + 1] = Triangle2D.new(tri.VE1, tri.edge1.P2.NewPoint, tri.VF)

        NewTestTriangle2Ds[#NewTestTriangle2Ds + 1] = Triangle2D.new(tri.VE2, tri.edge2.P1.NewPoint, tri.VF)
        NewTestTriangle2Ds[#NewTestTriangle2Ds + 1] = Triangle2D.new(tri.VE2, tri.edge2.P2.NewPoint, tri.VF)

        NewTestTriangle2Ds[#NewTestTriangle2Ds + 1] = Triangle2D.new(tri.VE3, tri.edge3.P1.NewPoint, tri.VF)
        NewTestTriangle2Ds[#NewTestTriangle2Ds + 1] = Triangle2D.new(tri.VE3, tri.edge3.P2.NewPoint, tri.VF)
    end

    for i = 1, #NewTestTriangle2Ds do
        NewTestTriangle2Ds[i]:SetColor(0,255,0,255)
    end
end


function GetNewEdgeP(edge)
    if #edge.ThirdPoints > 2 then
        _errorAssert(false, "GetNewEdgeP!")
    end

    local i1 = 3 / 8;
    local i2 = (3 - #edge.ThirdPoints) / 8;
    local VE = edge.P1 * i1 + edge.P2 * i1
    for i = 1, #edge.ThirdPoints do
        VE = VE + edge.ThirdPoints[i] * i2
    end

    return VE
end

local DebugPoints1 = {}
local DebugPoints2 = {}
local DebugRects = {}


function GenTriCC()
    TestPoints = {}

    for i = 1, #TestPointsQ do
        TestPoints[#TestPoints + 1] = Vector.new(TestPointsQ[i].x, TestPointsQ[i].y)
    end

    if #TestPoints > 1 then
        TestLines = {}
        for i = 2, #TestPoints do
            TestLines[#TestLines+ 1] = Line.new(TestPoints[i - 1].x, TestPoints[i - 1].y, TestPoints[i].x, TestPoints[i].y)
        end
    end

    TestTriangle2Ds = {}
    if #TestPoints >= 3 then
        for i = 3, #TestPoints do
            TestTriangle2Ds[#TestTriangle2Ds+ 1] = Triangle2D.new(TestPoints[i - 2], TestPoints[i - 1], TestPoints[i])
            local tri2 = TestTriangle2Ds[#TestTriangle2Ds]
            tri2.edge1.Face1 = tri2
            tri2.edge2.Face1 = tri2
            tri2.edge3.Face1 = tri2

            if not TestPoints[i - 2].Faces then
                TestPoints[i - 2].Faces = {}
            end

            if not TestPoints[i - 1].Faces then
                TestPoints[i - 1].Faces = {}
            end

            if not TestPoints[i].Faces then
                TestPoints[i].Faces = {}
            end

            TestPoints[i - 2].Faces[#TestPoints[i - 2].Faces + 1] =  tri2
            TestPoints[i - 1].Faces[#TestPoints[i - 1].Faces + 1] =  tri2
            TestPoints[i].Faces[#TestPoints[i].Faces + 1] =  tri2

            tri2.VF = (tri2.P1 + tri2.P2 + tri2.P3) / 3
            if i > 3 then

                local tri1 = TestTriangle2Ds[#TestTriangle2Ds - 1]

                if tri1.edge2 == tri2.edge1 then
                    tri2.edge1.Face2 = tri1
                    tri1.edge2.Face2 = tri2
                else
                    _errorAssert(false, "TestTriangle2Ds edge face!")
                end
            end
        end
    end
end
function GenNewTri()

    if #TestTriangle2Ds == 0 then return end

    for i = 1, #TestPoints do
       local CP  = TestPoints[i]
          
       local VPs = Vector.new(0, 0)
       for e = 1, #CP.Edges do
            VPs = VPs + (CP.Edges[e].P1 + CP.Edges[e].P2 - CP)
       end

       VPs = VPs / #CP.Edges

       local an = 1 - #CP.Edges / 10

       local newp = VPs * (1-an) + CP * an
       NewTestPoints[#NewTestPoints + 1] = newp

       CP.NewPoint = newp
   end

   NewTestTriangle2Ds = {}
   DebugPoints1 = {}
   DebugPoints2 = {}
   DebugRects = {}
   for i = 1, #TestTriangle2Ds do
        local tri = TestTriangle2Ds[i]
        tri.VE1 = GetNewEdgeP(tri.edge1)
        tri.VE2 = GetNewEdgeP(tri.edge2)
        tri.VE3 = GetNewEdgeP(tri.edge3)

        NewTestTriangle2Ds[#NewTestTriangle2Ds + 1] = Triangle2D.new(tri.VE1, tri.VE2, tri.VE3)
        NewTestTriangle2Ds[#NewTestTriangle2Ds + 1] = Triangle2D.new(tri.VE1, tri.VE2, tri.P2.NewPoint)
        NewTestTriangle2Ds[#NewTestTriangle2Ds + 1] = Triangle2D.new(tri.VE1, tri.VE3, tri.P1.NewPoint)
        NewTestTriangle2Ds[#NewTestTriangle2Ds + 1] = Triangle2D.new(tri.VE3, tri.VE2, tri.P3.NewPoint)
        NewTestTriangle2Ds[#NewTestTriangle2Ds + 1] = Triangle2D.new(tri.P1.NewPoint, tri.P2.NewPoint, tri.P3.NewPoint)

        DebugPoints1[#DebugPoints1 + 1] = tri.VE1
        DebugPoints1[#DebugPoints1 + 1] = tri.VE2
        DebugPoints1[#DebugPoints1 + 1] = tri.VE3

        DebugPoints2[#DebugPoints2 + 1] = tri.P1.NewPoint
        DebugPoints2[#DebugPoints2 + 1] = tri.P2.NewPoint
        DebugPoints2[#DebugPoints2 + 1] = tri.P3.NewPoint
    end

    for i = 1, #NewTestTriangle2Ds do
        NewTestTriangle2Ds[i]:SetColor(0,255,0,255)
    end

    for i = 1, #DebugPoints1 do
        local p = DebugPoints1[i]
        DebugRects[#DebugRects + 1] = Rect.new(p.x - 2, p.y - 2, 4, 4, "fill")
        DebugRects[#DebugRects]:setColor(255,0,0,255)
    end

    for i = 1, #DebugPoints2 do
        local p = DebugPoints2[i]
        DebugRects[#DebugRects + 1] = Rect.new(p.x - 2, p.y - 2, 4, 4, "fill")
        DebugRects[#DebugRects]:setColor(0,0,255,255)

    end
end

local ModeQ = "CC"
app.mousepressed(function(x, y, button, istouch)
   
    if not CanGen then return end
	TestPointsQ[#TestPointsQ + 1] = Vector.new(x, y)
    if ModeQ == "CC" then
        GenTriCC()
    else
        GenTri()
    end
end)

local IsDrawDebug = false
app.render(function(dt)
    --tri:draw()
    -- for i = 1, #TestLines do
    --     TestLines[i]:draw()
    -- end

    for i = 1, #TestTriangle2Ds do
        TestTriangle2Ds[i]:draw()
    end

    for i = 1, #NewTestTriangle2Ds do
        NewTestTriangle2Ds[i]:draw()
    end

    if IsDrawDebug then
        for i = 1, #DebugRects do
            DebugRects[i]:draw()
        end
    end
    

    love.graphics.print( "Press Key C.  IsDrawDebug: "..tostring(IsDrawDebug) .. " D  Mode: ".. ModeQ, 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        TestPointsQ = {}
        TestTriangle2Ds = {}
        TestLines = {}
    elseif key == "a" then
        CanGen = not CanGen
    elseif key == "b" then
        if ModeQ == "CC" then
            GenTriCC()
            GenNewTriCC()
        else
            GenTri()
            GenNewTri()
        end
    elseif key == "d" then
        if ModeQ == "CC" then
            ModeQ = "Loop"
        else
            ModeQ = "CC"
        end
    elseif key == "c" then
        IsDrawDebug = not IsDrawDebug
    elseif key == "delete" then
        if #TestPoints > 0 then
            table.remove(TestPoints, #TestPoints)
            TestLines = {}
            TestTriangle2Ds = {}
            GenTri()
        end
    end

    log(key)
end)