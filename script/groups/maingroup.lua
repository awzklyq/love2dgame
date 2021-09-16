
_G.MainGroup = {}

function MainGroup.new()
    local group = setmetatable({}, {__index = MainGroup});

    group.screentext = LoveScreenText.new(100, 100, "")
    return group;
end

function MainGroup:init()
    self.EventIndex = 1
    self.EventDatas = lovefile.loadCSV("main.txt")
    self.CurrentData = self.EventDatas[self.EventIndex]

    self.screentext.text = self.CurrentData.Event
    log(self.screentext.text)
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
    self.EventIndex = self.EventIndex + 1
end

function MainGroup:afterdraw()
    self.screentext:draw()
end


function MainGroup:mousepressed(x, y, button, istouch)
    if button == 1 then
        

    end
end

function MainGroup:keypressed(key, scancode, isrepeat)

end