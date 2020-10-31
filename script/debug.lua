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