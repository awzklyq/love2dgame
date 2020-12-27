
_G.DirectionLight = {}

function DirectionLight.new(dir, color)-- lw :line width
    local light = setmetatable({}, {__index = DirectionLight});
    light.dir =dir
    light.color = color

    light.renderid = Render.DirectionLightId;
    return light
end

_G.Lights = {}
_G.useLight = function(light)
    table.insert(Lights, light)
    Shader.neednormal = Shader.neednormal + 1
end

_G.popLight = function()
    table.remove(Lights, #Lights)
    Shader.neednormal = Shader.neednormal + 1
    Shader.neednormal = math.max(Shader.neednormal, 0)
end

_G.Lights.getDirectionLights = function()
    local directionlights = {}
    for i = 1, #Lights do
        local light = Lights[i]
       
        if  light.renderid == Render.DirectionLightId then
            table.insert(directionlights, light)
        end
        if  #directionlights == 4 then
            break
        end
    end
   
    return directionlights
end
