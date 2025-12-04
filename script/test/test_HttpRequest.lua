
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
TestTab.prompt = [[Describe the object in the image using the following dimensions and format, using simple, direct terms whenever possible:
        "category": string (e.g., art, electronics, household items)
        "class": string (e.g., book, car, house)
        "appearance": string (e.g., red and white box)
        "usage": string (obvious use, not imaginary)
        "style": string (e.g., classic, gothic, futuristic; outputs Null if no obvious style is present). 
        Only output JSON. Do not respond to content outside the required format.]]

TestTab.image = _BaseData.Base64_File("beibingyang.png")


_Http:SendRequest(TestTab)
local str = _Http:GetResponseAsString()
log(str)