
_G.DirectionLight = {}

function DirectionLight.new(dir, color)-- lw :line width
    local light = setmetatable({}, {__index = DirectionLight});
    light.dir =dir
    light.dir:normalize()
    light.color = color

    light.renderid = Render.DirectionLightId;
    return light
end

_G.PointLight = {}

function PointLight.new(Position, Color, Distance, Power)-- lw :line width
    local light = setmetatable({}, {__index = PointLight});
    light.Position =Position
    light.Color = Color
    light.Distance = Distance
    light.Power = Power

    light.renderid = Render.PointLightId;
    return light
end

_G.Lights = {}
_G.Lights.Objs = {}
_G.useLight = function(light)
    table.insert(Lights.Objs, light)
    Shader.neednormal = Shader.neednormal + 1
end
_G.UseLight = _G.useLight 

_G.popLight = function()
    table.remove(Lights.Objs, #Lights.Objs)
    Shader.neednormal = Shader.neednormal + 1
    Shader.neednormal = math.max(Shader.neednormal - 1, 0)
end

_G.PopLight = _G.popLight 

_G.useNormal = function()
    Shader.neednormal = Shader.neednormal + 1
end

_G.unUseNormal = function()
    -- table.remove(Lights, #Lights)
    Shader.neednormal = math.max(Shader.neednormal - 1, 0)
end

_G.Lights.getDirectionLights = function()
    local directionlights = {}
    for i = 1, #Lights.Objs do
        local light = Lights.Objs[i]
       
        if  light.renderid == Render.DirectionLightId then
            table.insert(directionlights, light)
         
        end
        if  #directionlights == 4 then
            break
        end
    end
   
    return directionlights
end

_G.Lights.GetPointLights = function()
    local pointlights = {}
    for i = 1, #Lights.Objs do
        local light = Lights.Objs[i]
        if  light.renderid == Render.PointLightId then
            table.insert(pointlights, light)
         
        end
        -- if  #pointlights == 4 then
        --     break
        -- end
    end
   
    return pointlights
end
