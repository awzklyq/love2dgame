
_G.MainGroup = {}

function MainGroup.new()
    local group = setmetatable({}, {__index = MainGroup});

    group.screentext = LoveScreenText.new(100, 100, "")

    group.MainFont = Font.new"FZZJ-JYTJW.TTF"

    group.IsBegine = false
    return group;
end

function MainGroup:init()
    self.EventIndex = 1
    self.MainEventDatas = lovefile.loadCSV("main.csv")
    self:SetEventIndex(1)

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

    --Timer
    self.ImageTimer = Timer.new(1)
    -- self.BgImage1 = nil
    -- self.BgImage2 = nil
    self.ImageTimer.TriggerFrame = function (tick, duration)
        if group.BgImage1 and group.BgImage2 then
            group.BgImage1.alpha = 1 - tick / duration
            group.BgImage2.alpha = tick / duration
        end
    end

    self.ImageTimer.TraggerEvent = function (tick, duration)
        group.BgImage1 = group.BgImage2
        group.BgImage2 = nil
    end
end

function MainGroup:SetImage(name)
    if not name then return end

    if self.BgImage2 then
        self.BgImage1 = self.BgImage2
        self.BgImage2 = ImageEx.new(name)

        self.BgImage1.w = RenderSet.screenwidth
        self.BgImage1.h = RenderSet.screenheight

        self.BgImage2.w = RenderSet.screenwidth
        self.BgImage2.h = RenderSet.screenheight

        self.ImageTimer:Start()
    elseif self.BgImage1 then
        self.BgImage2 = ImageEx.new(name)

        self.BgImage2.w = RenderSet.screenwidth
        self.BgImage2.h = RenderSet.screenheight
        self.ImageTimer:Start()
    else
        self.BgImage1 = ImageEx.new(name)
        self.BgImage1.w = RenderSet.screenwidth
        self.BgImage1.h = RenderSet.screenheight

    end
end

function MainGroup:DrawImage()
    if self.BgImage1 then
        self.BgImage1:draw()
    end

    if self.BgImage2 then
        self.BgImage2:draw()
    end
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
        self.PreData = self.CurrentData
        self.CurrentData = self.MainEventDatas[index]
        self.screentext.text = self.CurrentData.Event

        self.screentext:setColor(self.CurrentData.colorr, self.CurrentData.colorg, self.CurrentData.colorb)

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

        self.SelectResult = 0;

        self:SetImage(self.CurrentData.bgimage)
    end
end

function MainGroup:firstdraw(dt)
    self:DrawImage()
end

function MainGroup:afterdraw()
    self.MainFont:Use()
    self.screentext:draw()
end


function MainGroup:mousereleased(x, y, button, istouch)
    if button == 1 and self.SelectResult == 0 and self.IsBegine then
        self:NextEvent()
    end
end

function MainGroup:mousepressed(x, y, button, istouch)
    self.IsBegine = true
end

function MainGroup:keypressed(key, scancode, isrepeat)

end

function MainGroup:resizeWindow(w, h)
    self.button1:setPos(0.2 * w, 0.8 * h);
    self.button2:setPos(0.45 * w, 0.8 * h);
    self.button3:setPos(0.75 * w, 0.8 * h);

    if self.BgImage1 then
        self.BgImage1.w = w
        self.BgImage1.h = h
    end

    if self.BgImage2 then
        self.BgImage2.w = w
        self.BgImage2.h = h
    end
end