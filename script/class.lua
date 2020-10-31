
_G.__setParentClass = function(obj, parent)
    for i, v in pairs(parent) do
        if not obj[i] and type(parent[i]) == "function" then
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