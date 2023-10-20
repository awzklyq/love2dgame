_G.lovefile = {}

lovefile.DefaultForder =  'C:/Users/Liuyongqi/AppData/Roaming/LOVE/love2dgame/'
lovefile.read = function(filename)
    local file = love.filesystem.newFile(_G.FileManager.findFile(filename))
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

lovefile.exists = function(filename)
	return love.filesystem.exists( filename )
end

lovefile.getWorkingDirectory = function()
	return love.filesystem.getWorkingDirectory()
end

lovefile.newFile = function(filename, mode)
	local file, errorstr = love.filesystem.newFile(filename, mode )
	return file, errorstr
end

lovefile.write = function(name, data)
	local f, errorstr = lovefile.newFile(name)
	f:open("w")
	f:write(data)
	-- f:flush()
	f:close()
end

lovefile.getUserDirectory = function()
	return love.filesystem.getUserDirectory()
end

function Split(szFullString, szSeparator)
	local nFindStartIndex = 1
	local nSplitIndex = 1
	local nSplitArray = {}
	while true do
	   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
	   if not nFindLastIndex then
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
		break
	   end
	   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
	   nFindStartIndex = nFindLastIndex + string.len(szSeparator)
	   nSplitIndex = nSplitIndex + 1
	end
	return nSplitArray
end

lovefile.loadCSV = function(filename)
    local iterator  = love.filesystem.lines(_G.FileManager.findFile(filename))
	local indexs = Split(iterator(1), ",")
	local num = #indexs

	local datas = {}
	
	local dataindex = 2
	local data = iterator(dataindex)
	while data do
		local sdata = Split(data, ",")
		local temp = {}
		for i = 1, num do
			local d = sdata[i]
			if tonumber(d) then
				d = tonumber(d)
			elseif d == "" then
				d = nil
			end

			temp[indexs[i]] = d
		end
		
		datas[#datas + 1] = temp

		dataindex = dataindex + 1
		data = iterator(dataindex)
	end

	return datas
end
