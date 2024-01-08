 
 local SelectElements = setmetatable({}, {__mode = "kv"})

 local EventElements = setmetatable({}, {__mode = "kv"})
 _G.AddEventToPolygonevent = function(self, enable)

    if enable then
        EventElements[self] = self
    else
        EventElements[self] = nil
    end
end

 app.mousepressed(function(x, y, button, istouch)
     for i, v in pairs(EventElements) do
         if v:CheckPointInXY(x, y) then
             SelectElements[v] = v

             if v.MouseDownEvent then

                v.MouseDownEvent(v, x, y, button, istouch)
             end
         end
     end
 end)
 
 app.mousemoved(function(x, y, button, istouch)
    for i, SelectElement in pairs(SelectElements) do
         if SelectElement.MouseMoveEvent then
            SelectElement.MouseMoveEvent(SelectElement, x, y, button, istouch)
         end
     end
 end)
 
 app.mousereleased(function(x, y, button, istouch)
    local NeedCreate = false
    for i, SelectElement in pairs(SelectElements) do
         if SelectElement.MouseUpEvent then
            SelectElement.MouseUpEvent(SelectElement, x, y, button, istouch)
         end

         NeedCreate = true
     end

     if NeedCreate then
        SelectElements = setmetatable({}, {__mode = "kv"})
     end
 end)