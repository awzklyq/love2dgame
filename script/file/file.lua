_G.lovefile = {}

lovefile.read = function(filename)
    local file = love.filesystem.newFile(filename)
    file:open("r")
    local data = file:read()
    file:close()
    return data
end

--获取路径
lovefile.stripfilename = function(filename)
	return string.match(filename, "(.+)/[^/]*%.%w+$") --*nix system
	--return string.match(filename, “(.+)\\[^\\]*%.%w+$”) — windows
end

--获取文件名
lovefile.strippath = function(filename)
	return string.match(filename, ".+/([^/]*%.%w+)$") -- *nix system
	--return string.match(filename, “.+\\([^\\]*%.%w+)$”) — *nix system
end

--去除扩展名
lovefile.stripextension = function(filename)
	local idx = filename:match(".+()%.%w+$")
	if(idx) then
		return filename:sub(1, idx-1)
	else
		return filename
	end
end

--获取扩展名
lovefile.getextension = function(filename)
	return filename:match(".+%.(%w+)$")
end