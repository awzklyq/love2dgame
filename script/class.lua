
_G.__setParentFunction = function(obj, parent)
    for i, v in pairs(parent) do
        if not obj[i] and type(parent[i]) == "function" then
            obj[i] = parent[i];
            
        end
    end
end

_G.__setParentClassNoTable = function(obj, parent)
    for i, v in pairs(parent) do
        if not obj[i] and (type(parent[i]) == "function" or type(parent[i]) == "string" or type(parent[i]) == "number" or type(parent[i]) == "number") then
            obj[i] = parent[i];            
        end
    end
end

_G.__setParentObject = function(obj, parent)
    if not parent.__tempins then
        parent.__tempins = parent.new();
    end
    for i, v in pairs(parent.__tempins) do
        if not obj[i] and type(parent.__tempins[i]) ~= "function" then
            obj[i] = parent.__tempins[i];
        end
    end
end

_G.__createClassFromLoveObj = function(objname)
    _G[objname] = {}

    _G[objname].__index = function(tab, key, ...)
        local value = rawget(tab, key);
        if value then
            return value;
        end
    
        if _G[objname][key] then
            return _G[objname][key];
        end
        
        if tab["obj"] and tab["obj"][key] then
            if type(tab["obj"][key]) == "function" then
                tab[key] = function(tab, ...)
                    return tab["obj"][key](tab["obj"], ...);--todo..
                end
                return  tab[key]
            end
            return tab["obj"][key];
        end
    
        return nil;
    end

    _G[objname].__newindex = function(tab, key, value)
        rawset(tab, key, value);
    end
end