_G.Audio = {}

-- "clone", 

-- "play",  
-- "stop",  
-- "pause", 

-- "setPitch", 
-- "getPitch", 
-- "setVolume", 
-- "getVolume", 
-- "seek",  
-- "tell",  
-- "getDuration", 
-- "setPosition", 
-- "getPosition", 
-- "setVelocity", 
-- "getVelocity", 
-- "setDirection", 
-- "getDirection", 
-- "setCone", 
-- "getCone", 

-- "setRelative", 
-- "isRelative", 

-- "setLooping", 
-- "isLooping", 
-- "isPlaying", 

-- "setVolumeLimits", 
-- "getVolumeLimits", 
-- "setAttenuationDistanc
-- "getAttenuationDistanc
-- "setRolloff", 
-- "getRolloff", 
-- "setAirAbsorption", 
-- "getAirAbsorption", 

-- "getChannelCount", 

-- "setFilter", 
-- "getFilter", 
-- "setEffect", 
-- "getEffect", 
-- "getActiveEffects", 

-- "getFreeBufferCount", 
-- "queue", 

-- "getType", 

-- "getChannels", 



Audio.__index = function(tab, key)
    if _G.Audio[key] then
        return _G.Audio[key];
    end
    
    if tab.Source and type(tab.Source[key]) == 'function' then
        _G.Audio[key] = function(MySelf, ...)
            
            if not MySelf.Source then
                return
            end
            return MySelf.Source[key](MySelf.Source, ...)
        end
        return _G.Audio[key]
    end
    return rawget(tab, key);
end

-- Audio.__newindex = function(tab, key, value)
--     return rawset(tab, key, value);
-- end

function Audio.new(name, AudioType)
    local audio = setmetatable({}, Audio);
    
    --AudioType: static or stream
    audio.Source =audio.newSource(_G.FileManager.findFile(name), AudioType or "static")

    return audio;
end

function Audio:rePlay()
    self:stop()
    self:play()
end