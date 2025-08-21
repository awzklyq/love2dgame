FileManager.addAllPath("assert")

math.randomseed(os.time()%10000)

local font = Font.new"FZBaiZDZ113JW.TTF"
font:Use()

local tri = Triangle2D.new(Vector.new(100, 10), Vector.new(100, 200), Vector.new(290, 200))

local TestPoints = {}
local TestLines = {}
local TestTriangle2Ds = {}
local NewTestTriangle2Ds = {}
local NewTestPoints = {}
local CanGen = true

function GenTri()
    if #TestPoints > 1 then
        TestLines = {}
        for i = 2, #TestPoints do
            TestLines[#TestLines+ 1] = Line.new(TestPoints[i - 1].x, TestPoints[i - 1].y, TestPoints[i].x, TestPoints[i].y)
        end
    end

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

function GetNewEdgeP(edge)
    local VE = edge.P1 + edge.P2 + edge.Face1.VF
    if edge.Face2 then
        return (VE + edge.Face2.VF) / 4
    else
        return VE / 3
    end
end
function GenNewTri()

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

app.mousepressed(function(x, y, button, istouch)
   
    if not CanGen then return end
	TestPoints[#TestPoints + 1] = Vector.new(x, y)
    GenTri()
end)

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
    

    love.graphics.print( "Press Key A.  CanGen: "..tostring(CanGen), 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        TestPoints = {}
        TestTriangle2Ds = {}
        TestLines = {}
    elseif key == "a" then
        CanGen = not CanGen
    elseif key == "b" then
        GenNewTri()
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