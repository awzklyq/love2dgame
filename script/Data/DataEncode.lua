local _Mime = require("mime")

_G._BaseData = {}

_BaseData.Base64_File = function(InFile)
    local encoded = _Mime.b64(lovefile.read(InFile))
    return encoded
end