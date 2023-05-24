_G.CollisionGroup = {}


function CollisionGroup.new(name)
    local obj = setmetatable({}, {__index = CollisionGroup})

    obj.Name = name
    obj.Binders = {}

    obj.OtherGroup = {}

    obj.BindersHelper = {}setmetatable({}, {__mode = "k"})

    return obj
end

function CollisionGroup:AddGropuForOtherSide(name)
    assert(name ~= self.name)
    self.OtherGroup[#self.OtherGroup + 1] = name
end

function CollisionGroup:AddBinder(binder)
    assert(binder.GroupName == self.name)

    if not self.BindersHelper[binder.Binder] then
        self.BindersHelper[binder.Binder] = #self.Binders + 1
    end
    
    local index = self.BindersHelper[binder.Binder]

    local SelfBinders = self.Binders[index]
    if not SelfBinders then
        SelfBinders = {}
        self.Binders[index] = SelfBinders
        
    end
    
    SelfBinders[#SelfBinders + 1] = binder
end

function CollisionGroup:RemoveBinder(binder)
    assert(binder.GroupName == self.name)

    if not self.BindersHelper[binder.Binder] then
        return
    end

    local index = self.BindersHelper[binder.Binder]
    
    local SelfBinders = self.Binders[index]

    if #SelfBinders == 1 then
        table.remove(self.Binders, index)
        self.BindersHelper[binder.Binder] = nil

        for i, v in pairs(self.BindersHelper) do
            if self.BindersHelper[i] > index then
                self.BindersHelper[i] = self.BindersHelper[i] - 1
            end
        end

        return true

    else
        for i = 1, #SelfBinders do
            if binder == SelfBinders[i] then
                SelfBinders[i]:Release()
                table.remove(SelfBinders, i)
                break
            end
        end

        return false
    end
end