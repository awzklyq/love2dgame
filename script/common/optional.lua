
local OptionalMeta = {}
_G.Optional = {}
OptionalMeta.__call = function(mytable, newvalue)
    Optional.CheckType(mytable, newvalue)
    -- mytable._HasValue = true
    -- mytable._Value = newvalue

    rawset(mytable, "_HasValue", true)
    rawset(mytable, "_Value", newvalue)
end

OptionalMeta.__newindex = function(mytable, key, value)
    -- if key == "_HasValue" or key == "_Value" then
    --     return rawset(mytable, key, value)
    -- end
    _errorAssert(false, "Optional can not used: set new key and value: " .. tostring(key) )
end

OptionalMeta.__tostring = function(mytable)
    return tostring(mytable.Value)
end

OptionalMeta.__index = function(mytable, key, ...)
    
    if key == "Value" then
        Optional.CheckValue(mytable)
        return rawget(mytable, "_Value")
    end

    if type(Optional[key]) == "function" then
        return rawget(Optional, key,  mytable, ...)
    end

    _errorAssert(false, "Optional can not access the key : " ..  key)
end

function Optional.new(typename)
    local tv = setmetatable({}, OptionalMeta);
    rawset(tv, "_HasValue", false)
    rawset(tv, "_Value", -1)
    rawset(tv, "renderid", Render.OptionalId)

    local IsTypename = false;
    if type(typename) == "string" then
        IsTypename = typename == "string" or typename == "number" or typename == "boolean"
    end

    rawset(tv, "TypeName", IsTypename and typename or type(typename))

    if IsTypename then
        tv._HasValue = false;
        tv._Value = nil
    else
        tv._HasValue = true;
        tv._Value = typename
    end
    tv.renderid = Render.OptionalId;
    return tv;
end

function Optional:CheckValue()
    _errorAssert(self._HasValue, "Optional Error value is null")
end

function Optional:HasValue()
    return  rawget(self, "_HasValue")
end

function Optional:CheckType(typevalue)
    _errorAssert(type(typevalue) == self.TypeName, "Optional Error type 1 2 : " .. tostring(self.TypeName) .. "  " .. tostring(CheckType))
end

function Optional:Reset()
    rawset(self, "_HasValue", false)
    rawset(self, "_Value", -1)
end