local http = require("socket.http")
local ltn12 = require("ltn12")

_G.HttpRequest = {}

HttpRequest._Meta = {__index = HttpRequest}

function HttpRequest.new(InUrl, InMethod)
    local _h = setmetatable({}, HttpRequest._Meta)

    _h._Headers = {["Content-Type"] = "application/json",  ["Content-Length"] = 0 } -- Content-Length must be more than 0

    _h._URL = InUrl
    _h._Method = InMethod
    _h._Response_Body = {}

    return _h
end

function HttpRequest:SendRequest(InTableData)
    local _JsonData = _Json.encode(InTableData)

    self._Headers["Content-Length"] = #_JsonData

    self._Response_Body = {}

    local res, code, response_headers= http.request({
        url = self._URL,
        method = self._Method,
        headers =self._Headers,
        
        source = ltn12.source.string(_JsonData),
        sink =  ltn12.sink.table(self._Response_Body),
    })

    -- log('aaaa', res, code, response_headers)

    -- for i, v in pairs(self._Response_Body) do
    --     log('bbbbbbbbb', i, v)
    -- end
end

function HttpRequest:GetResponseAsString()
    local _ResultStr = ""

    for i, v in pairs(self._Response_Body) do
        _ResultStr = _ResultStr .. tostring(self._Response_Body[i])
        -- log('aaaa', i, self._Response_Body[i])
    end

    return _ResultStr
end