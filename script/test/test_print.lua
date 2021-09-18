-- local font = love.graphics.newImageFont( _G.FileManager.findFile'font_example.png', ' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789' )
-- function love.draw()
--     love.graphics.setFont( font )
--     love.graphics.print( 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', 16, 16 )
--     love.graphics.print( 'Text is now drawn using the font', 16, 32 )
-- end

-- Create a ttf file font with a custom size of 20 pixels.
mainFont = love.graphics.newFont(_G.FileManager.findFile"minijtls.ttf", 20)

contents, size = love.filesystem.read( "data", _G.FileManager.findFile"main.txt" )

print(contents:getString())
function love.draw() 
	-- Setting the font so that it is used when drawning the string.
	love.graphics.setFont(mainFont)

	-- Draws "Hello world!" at position x: 100, y: 200 with the custom font applied.
	love.graphics.print(contents:getString(), 100, 200)
end