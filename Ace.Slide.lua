--[[
*************************************************************
 * This script is developed by Arturs Sosins aka ar2rsawseen, http://appcodingeasy.com
 * Feel free to distribute and modify code, but keep reference to its creator
 *
 * Gideros AceSlide object creates a sliding element to switch different objects. 
 * Great for providing and input to choose levels or packages in mobile games
 * You can navigate through objects by using provided function or 
 * allowing users to drag and drop to switch content.
 *
 * For more information, examples and online documentation visit: 
 * http://appcodingeasy.com/Gideros-Mobile/Easy-input-for-choosing-packages-or-levels-in-Gideros-Mobile
**************************************************************
]]--
module("AceSlide", package.seeall)

--configuration options
local conf = {
	orientation = "horizontal",
	spacing = 100,
	parent = stage,
	speed = 3,
	unfocusedAlpha = 0.75,
	easing = nil,
	allowDrag = true,
	dragOffset = 2
}

local store
local total = 1
local cur = 1
local scrW
local scrH
local coord
local offset = 0

local function findClosest(current)
	local closest = cur
	local distance = 100000000
	for i = 1, #coord do
		if i ~= cur then
			local newdist = math.abs(coord[i]-current)
			if distance > newdist then
				distance = newdist
				closest = i
			end
		end
	end
	
	return closest
end

local function falseButtons(elem)
	local num = elem:getNumChildren()
	if num > 0 then
		for i = 1, num do
			local sprite = elem:getChildAt(i)
			if sprite.upState and sprite.downState then
				sprite.focus = false
			else
				falseButtons(sprite)
			end
		end
	end
end

local function onMouseDown(self, event)
	if store:hitTestPoint(event.x, event.y) then
		store.isFocus = true
		store.x0 = event.x
		store.y0 = event.y
		store.startX = event.x
		store.startY = event.y

		--event:stopPropagation()
	end
end

local function onMouseMove(self, event)
	if store.isFocus then
	
		if(conf.orientation == "horizontal") then
			local dx = event.x - store.x0
			store:setX(store:getX() + dx)
			store.x0 = event.x
		else
			local dy = event.y - store.y0
			store:setY(store:getY() + dy)
			store.y0 = event.y
		end
		event:stopPropagation()
	end
end

local function onMouseUp(self, event)
	if store.isFocus then
		if(conf.orientation == "horizontal") then
			if(store.x0 - store.startX < -conf.dragOffset or store.x0 - store.startX > conf.dragOffset) then
				if store.x0 - store.startX < -conf.dragOffset and cur == total then
					gotoItem(cur)
				elseif store.x0 - store.startX > conf.dragOffset and cur == 1 then
					gotoItem(cur)
				else
					gotoItem(findClosest(store:getX()))
				end
				falseButtons(store)
				event:stopPropagation()
			else
				gotoItem(cur)
			end
		else
			if(store.y0 - store.startY < -conf.dragOffset or store.y0 - store.startY > conf.dragOffset) then
				if store.y0 - store.startY < -conf.dragOffset and cur == total then
					gotoItem(cur)
				elseif store.y0 - store.startY > conf.dragOffset and cur == 1 then
					gotoItem(cur)
				else
					gotoItem(findClosest(store:getY()))
				end
				falseButtons(store)
				event:stopPropagation()
			else
				gotoItem(cur)
			end
		end
		store.isFocus = false
	end
end

function init(config)
	total = 1
	cur = 1
	offset = 0
	if config then
		--copying configuration
		for key,value in pairs(config) do
			conf[key]= value
		end
	end
	coord = {}
	scrH = application:getContentHeight()
	scrW = application:getContentWidth()
	store = Sprite.new()
	
end

function add(elem, selected)
	if conf.allowDrag then
		elem:addEventListener(Event.MOUSE_DOWN, onMouseDown, elem)
		elem:addEventListener(Event.MOUSE_MOVE, onMouseMove, elem)
		elem:addEventListener(Event.MOUSE_UP, onMouseUp, elem)
	end
	store:addChild(elem)
	total = store:getNumChildren()
	if selected then
		cur = total
	end
end

function addButton(image, image_pushed, callback, selected)
	local button_default = Bitmap.new(Texture.new(image))
	local button_pushed = Bitmap.new(Texture.new(image_pushed))
 
	local button = Button.new(button_default, button_pushed)	
	button:addEventListener("click", callback)
	if conf.allowDrag then
		button:addEventListener(Event.MOUSE_DOWN, onMouseDown, button)
		button:addEventListener(Event.MOUSE_MOVE, onMouseMove, button)
		button:addEventListener(Event.MOUSE_UP, onMouseUp, button)
	end
	store:addChild(button)
	
	total = store:getNumChildren()
	if selected then
		cur = total
	end
end

function applyToAll(callback)
	for i = 1, total do
		callback(store:getChildAt(i))
	end
end

function show()
	local last = 0
	for i = 1, store:getNumChildren() do
		if i == 1 then
			local sprite = store:getChildAt(i)
			sprite:setAlpha(conf.unfocusedAlpha)
			coord[i] = last
			if(conf.orientation == "horizontal") then
				last = (scrW/2)-(sprite:getWidth()/2)
				offset = last
				sprite:setPosition(last, (scrH/2)-(sprite:getHeight()/2))
				last = last + sprite:getWidth() + conf.spacing
			else
				last = (scrH/2)-(sprite:getHeight()/2)
				offset = last
				sprite:setPosition((scrW/2)-(sprite:getWidth()/2), last)
				last = last + sprite:getHeight() + conf.spacing
			end
		else
			local sprite = store:getChildAt(i)
			sprite:setAlpha(conf.unfocusedAlpha)
			coord[i] = -(last-offset)
			if(conf.orientation == "horizontal") then
				sprite:setPosition(last, (scrH/2)-(sprite:getHeight()/2))
				last = last + sprite:getWidth() + conf.spacing
			else
				sprite:setPosition((scrW/2)-(sprite:getWidth()/2), last)
				last = last + sprite:getHeight() + conf.spacing
			end
		end
	end
	--dirty little fix
	local fix = Sprite.new()
	store:addChild(fix)
	if conf.allowDrag then
		fix:addEventListener(Event.MOUSE_DOWN, onMouseDown, fix)
		fix:addEventListener(Event.MOUSE_MOVE, onMouseMove, fix)
		fix:addEventListener(Event.MOUSE_UP, onMouseUp, fix)
	end
	store:getChildAt(cur):setAlpha(1)
	jumptoItem(cur)
	conf.parent:addChild(store)
end

function gotoItem(ind)
	local target = coord[ind]
	local curpos
	if(conf.orientation == "horizontal") then
		curpos = store:getX()
	else
		curpos = store:getY()
	end
	local switchTime = (conf.speed*math.abs(curpos-target))+1
	local animate = {}
	if(conf.orientation == "horizontal") then
		animate.x = target
	else
		animate.y = target
	end
	store:getChildAt(cur):setAlpha(conf.unfocusedAlpha)
	cur = ind
	local tween = GTween.new(store, switchTime/1000, animate, {delay = 0, ease = conf.easing})
	tween.dispatchEvents = true
	tween:addEventListener("complete", function()
		store:getChildAt(cur):setAlpha(1)
	end)
end

function jumptoItem(ind)
	if(conf.orientation == "horizontal") then
		store:setPosition(coord[ind],0)
	else
		store:setPosition(0,coord[ind])
	end
end

function nextItem()
	if cur ~= total then
		gotoItem(cur + 1)
	else
		gotoItem(total)
	end
end

function prevItem()
	if cur ~= 1 then
		gotoItem(cur - 1)
	else
		gotoItem(1)
	end
end

function firstItem()
	gotoItem(1)
end

function lastItem()
	gotoItem(total)
end