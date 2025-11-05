
local ltn12 = require("ltn12")
local mime = require("mime")
log(mime )

-- for i , v in pairs(mime) do
--     log('aaaaaa', i, v)
-- end

local _URL = "http://127.0.0.1:8000/image"
local _Method = "POST"
local _Http = HttpRequest.new(_URL, _Method)

local TestTab = {}
TestTab.key = ""
TestTab.image = _BaseData.Base64_ImageFile("beibingyang.png")


_Http:SendRequest(TestTab)