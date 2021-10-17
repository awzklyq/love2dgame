_G.Font = {}

function Font.new(name)-- lw :line width
    local font = setmetatable({}, Font);
    font.obj = love.graphics.newFont(_G.FileManager.findFile(name), 45, "normal", 10)
    return font
end

Font.__index = function(tab, key, ...)
    local value = rawget(tab, key);
    if value then
        return value;
    end

    if Font[key] then
        return Font[key];
    end
    
    if tab["obj"] and tab["obj"][key] then
        if type(tab["obj"][key]) == "function" then
            tab[key] = function(tab, ...)
                return tab["obj"][key](tab["transform"], ...);--todo..
            end
            return  tab[key]
        end
        return tab["obj"][key];
    end

    return nil;
end

function Font:Use()
    Font.CurrentFont = Font
    love.graphics.setFont(self.obj)
end
