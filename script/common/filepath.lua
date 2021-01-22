_G.FileManager = {}

_G.FileManager.paths = {}
_G.FileManager.addPath = function(path)
    if love.filesystem.isDirectory(path) then
    table.insert(_G.FileManager.paths, path)
    end
end

_G.FileManager.addAllPath = function(path)
    local info  = love.filesystem.getInfo(path)
    if info.type == "directory" then
        local files = love.filesystem.getDirectoryItems(path)
        for i, v in ipairs(files) do
            local temp
            if love.filesystem.exists(path..'/'..v) then
                temp = path..'/'..v
            elseif love.filesystem.exists(path..v) then
                temp = path..v
            end
            if temp then
                local info  = love.filesystem.getInfo(temp)
                if info.type == "directory" then
                    _G.FileManager.addAllPath(temp)
                    table.insert(_G.FileManager.paths, temp)
                end
            end
        end

    end
end

_G.FileManager.findFile = function(file)
    if love.filesystem.exists(file) then
        return file;
    end
    
    for i, v in ipairs(_G.FileManager.paths) do
       if love.filesystem.exists(v..file) then
            return v..file;
       end

       if love.filesystem.exists(v..'/'..file) then
            return v..'/'..file;
       end
   end
end