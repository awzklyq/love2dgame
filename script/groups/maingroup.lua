
_G.MainGroup = {}

function MainGroup.new()
    local group = setmetatable({}, {__index = MainGroup});

    group.screentext = LoveScreenText.new(100, 100, "")

    group.MainFont = Font.new"minijtls.ttf"
    return group;
end

function MainGroup:init()
    self.EventIndex = 1
    self.MainEventDatas = lovefile.loadCSV("main.csv")
    self.CurrentData = self.MainEventDatas[self.EventIndex]

    self.screentext.text = self.CurrentData.Event

    self.SelectResult = 0

    local group = self
    self.button1 = LoginGroup:createUI("Button")
    self.button1:setText("选择1");
    self.button1.click = function()
        group.SelectResult = 1
        group:HiddenSelectButton()
        group:TriggerSelectEvent()
    end

    self.button2 = LoginGroup:createUI("Button")
    -- self.button2.visible = false
    self.button2:setText("选择2");
    self.button2.click = function()
        group.SelectResult = 2
        group:HiddenSelectButton()
        group:TriggerSelectEvent()
    end

    self.button3 = LoginGroup:createUI("Button")
    self.button3:setText("选择3");
    self.button3.click = function()
        group.SelectResult = 3
        group:HiddenSelectButton()
        group:TriggerSelectEvent()
    end

    self.button1:setPos(0.2 * RenderSet.screenwidth, 0.8 * RenderSet.screenheight);
    self.button2:setPos(0.45 * RenderSet.screenwidth, 0.8 * RenderSet.screenheight);
    self.button3:setPos(0.75 * RenderSet.screenwidth, 0.8 * RenderSet.screenheight);

    self:HiddenSelectButton()
end

function MainGroup:HiddenSelectButton()
    self.button1.visible = false 
    self.button2.visible = false 
    self.button3.visible = false 
end

function MainGroup:ShowSelectButton()
    self.button1.visible = true 
    self.button2.visible = true 
    self.button3.visible = true 
end

function MainGroup:TriggerSelectEvent()
    if self.CurrentData["triggerselect"..self.SelectResult] then
        self:SetEventIndex(self.CurrentData["triggerselect"..self.SelectResult] - 1)
    end 
end

function MainGroup:createUI(typename, ...)
    return UIHelper.createGroupUI("Main", typename, ...);
end

function MainGroup:clearUI()
    return UIHelper.clearGroupUI("Main");
end

function MainGroup:release()
    self:clearUI();
end

function MainGroup:NextEvent()
    self:SetEventIndex(self.EventIndex + 1)
end

function MainGroup:SetEventIndex(index)
    if index <= #self.MainEventDatas then
        self.EventIndex = index
        self.CurrentData = self.MainEventDatas[index]
        self.screentext.text = self.CurrentData.Event

        if self.CurrentData.select1 then
            self.button1:setText(self.CurrentData.select1);
            self.button1.visible = true
        end

        if self.CurrentData.select2 then
            self.button2:setText(self.CurrentData.select2);
            self.button2.visible = true
        end

        if self.CurrentData.select3 then
            self.button3:setText(self.CurrentData.select2);
            self.button3.visible = true
        end
    end
end

function MainGroup:afterdraw()
    self.MainFont:Use()
    self.screentext:draw()
end


function MainGroup:mousereleased(x, y, button, istouch)
    if button == 1 and self.SelectResult == 0 then
        self:NextEvent()
    end
end

function MainGroup:keypressed(key, scancode, isrepeat)

end

function MainGroup:resizeWindow(w, h)
    self.button1:setPos(0.2 * w, 0.8 * h);
    self.button2:setPos(0.45 * w, 0.8 * h);
    self.button3:setPos(0.75 * w, 0.8 * h);
end