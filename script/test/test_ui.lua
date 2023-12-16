
FileManager.addAllPath("assert")

local btn = UI.Button.new( 10, 10, 100, 50, 'test', 'btn' )

btn.x = 50

btn:setPressedColor(LColor.new(125, 125, 125))

local text = UI.Text.new( "sdfertre", 100, 50, 60, 50 )
text:SetNormalColor(255, 0, 0, 255)

btn.ClickEvent = function()
    text:SetNormalColor(0, 0, 255, 255)

    text.text = "Test AAA"
end




local scrollbar = UI.ScrollBar.new( 'test', 200, 200, 200, 40, 21, 98, 0.5)
scrollbar.ChangeEvent = function(v)
    log('test scrollbar', v)
end


local checkb = UI.CheckBox.new( 200, 260, 20, 20, "Test CheckBox" )
checkb.ChangeEvent = function(Enable)
    log("Test CheckBox Enable", Enable)
end

local btnimg = UI.Button.new( 100, 300, 40, 40, 'test', 'btn' )
btnimg:SetNormalImage("SJ1.png")
btnimg.ClickEvent = function()
    log('btnimg test')
end

local cb = UI.ComboBox.new(100, 350, 100, 40, {"Value1", "Value2", "Value3", "Value4", "Value5"})
cb.Value = "Value4"
cb.ChangeEvent = function(value)
    log(' UI.ComboBox test', value)
end