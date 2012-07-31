stage:setOrientation(Stage.LANDSCAPE_LEFT)

--initialize slider
AceSlide.init({
	orientation = "horizontal",
	spacing = 100,
	parent = stage,
	speed = 5,
	unfocusedAlpha = 0.75,
	easing = nil,
	allowDrag = true,
	dragOffset = 10
})

--create 10 boxes
for i = 1, 10 do
	local box = Bitmap.new(Texture.new("images/crate.png"))
	AceSlide.add(box)
end

--just to show as example
--of modifying all elements
AceSlide.applyToAll(function(elem)
	elem:setScale(2)
end)

--display slider
AceSlide.show()


--create buttons to switch content
local leftButton = Button.new(Bitmap.new(Texture.new("images/left-up.png")), Bitmap.new(Texture.new("images/left-down.png")))
leftButton:setPosition((application:getDeviceHeight()-leftButton:getWidth())/5, (application:getDeviceWidth()/2)-(leftButton:getHeight()/2))
stage:addChild(leftButton)
leftButton:addEventListener("click", 
	function()	
		AceSlide.prevItem()
	end
)

local rightButton = Button.new(Bitmap.new(Texture.new("images/right-up.png")), Bitmap.new(Texture.new("images/right-down.png")))
rightButton:setPosition(((application:getDeviceHeight()-rightButton:getWidth())/5)*4, (application:getDeviceWidth()/2)-(rightButton:getHeight()/2))
stage:addChild(rightButton)
rightButton:addEventListener("click", 
	function()	
		AceSlide.nextItem()
	end
)
	