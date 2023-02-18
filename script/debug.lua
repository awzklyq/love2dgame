_G.lovedebug = {}
_G.lovedebug.logtab = function(tab)
    print("lovedebug.logtab :")
    for i, v in pairs(tab) do
        if type(v) ~= 'table' and type(v) ~= 'function' then
            print('i: '..i.."     key: "..v);
        end
    end
end

_G.log = function(...)
    print(...)
end

_G._warn = function(...)
    log("waring: ", ...)
end

_G._errorAssert = function(a, ...)
    assert(a, "Error : ".. ...)
end

_G.logbit = function(v)
    assert(type(v) == 'number')
    v = math.modf(v)
    local temp = v
    local str = {}
    while(v ~= 0) do
        if v%2 == 0 then
            str[#str +1] = "0"
        else
            str[#str +1] = "1"
        end

        v = math.RightMove(v)
    end

    local result = ""
    for i =  #str, 1, -1 do
        result = result .. str[i]
    end
    
    log("Bit: ", temp, result)
end

--deubg
_G.lovedebug.renderbox2d = true;   
_G.lovedebug.renderobject = true;

_G.lovedebug.showstat = false


_G.lovedebug.showgridinfo = false


_G.lovedebug.showBox = false

_G.lovedebug.useCamera = false