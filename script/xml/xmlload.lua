_G.XmlLoader = {}
local xml = require("script/xml/xmlSimple").newParser()
function XmlLoader.new(xmlfile)
    local datas = _G.lovefile.read(xmlfile)
    local obj = setmetatable(xml:ParseXmlText(datas), {__index = XmlLoader});
    return obj;
end

function XmlLoader:getParam(holder, paramname)
    return holder["@"..paramname];
end

--srctab, destab, paramnames must be tatble
function XmlLoader:copyParams(srctab, destab, paramnames)
    for i, v in pairs(paramnames) do
        destab[v] = srctab["@"..v];
    end
end

function XmlLoader:copyParamsToNumber(srctab, destab, paramnames)
    for i, v in pairs(paramnames) do
        destab[v] = tonumber(srctab["@"..v]);
    end
end