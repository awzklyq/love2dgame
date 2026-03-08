--Real-Time Fluid Dynamics for Games ：Jos Stam

math.randomseed(os.time()%10000)

local _MeshGrid = _G.MeshGrids.new(500, 500, 10, 10, LColor.White)

app.render(function(dt)
    _MeshGrid:draw()
end)