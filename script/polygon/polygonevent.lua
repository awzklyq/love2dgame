 
 local SelectElements = {}

 local EventElements = {}
 _G.AddEventToPolygonevent = function(self, enable)

    if enable then
        local needadd = true
        for i = 1, #EventElements do
            if EventElements[i] == self then
                needadd = false
                break
            end
        end
        if needadd then
            EventElements[#EventElements + 1] = self
        end
    else
        for i = 1, #EventElements do
            if EventElements[i] == self then
                table.remove( EventElements, i)
                break
            end
        end
    end
end

 app.mousepressed(function(x, y, button, istouch)
     for i = 1, #EventElements do
         if EventElements[i]:CheckPointInXY(x, y) then
             local SelectElement = EventElements[i]
             SelectElements[#SelectElements + 1] = SelectElement

             if SelectElement.MouseDownEvent then

                SelectElement.MouseDownEvent(SelectElement, x, y, button, istouch)
             end
         end
     end
 end)
 
 app.mousemoved(function(x, y, button, istouch)
     for i = 1, #SelectElements do
         local SelectElement = SelectElements[i]
         if SelectElement.MouseMoveEvent then
            SelectElement.MouseMoveEvent(SelectElement, x, y, button, istouch)
         end
     end
 end)
 
 app.mousereleased(function(x, y, button, istouch)
     for i = 1, #SelectElements do
         local SelectElement = SelectElements[i]
         if SelectElement.MouseUpEvent then
            SelectElement.MouseUpEvent(SelectElement, x, y, button, istouch)
         end
     end
 
     SelectElements = {}
 end)