_G.Tiled = {}

function Tiled.new(filename)
    local data = _G.lovefile.read(filename);
    local mapdata = loadstring(data)();
    local obj =  setmetatable(mapdata, {__index = Tiled});
   
    obj.path = lovefile.stripfilename(filename)..'/';

    obj:loadLayerImage();
    return obj;
end 

function Tiled:loadLayerImage()
    for i, v in ipairs(self.layers) do
        self.layers[i].img = love.graphics.newImage(self.path..v.name..".png")
    end
end

function Tiled:drawLayers()
    for i, v in ipairs(self.layers) do
        love.graphics.draw(self.layers[i].img, self.layers[i].x, self.layers[i].y);
    end
end