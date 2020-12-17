_G.lovedebug = {}
_G.lovedebug.logtab = function(tab)
    print("lovedebug.logtab :")
    for i, v in pairs(tab) do
        if type(v) ~= 'table' and type(v) ~= 'function' then
            print('i: '..i.."     key: "..v);
        end
    end
end

_G.log = print

_G._warn = function(...)
    log("waring: ", ...)
end

_G._errorAssert = function(a, ...)
    assert(a, "Error : ".. ...)
end

--deubg
_G.lovedebug.renderbox2d = true;   
_G.lovedebug.renderobject = true;

_G.lovedebug.showstat = false


_G.lovedebug.showgridinfo = false


_G.lovedebug.showBox = false

_G.lovedebug.useCamera = false