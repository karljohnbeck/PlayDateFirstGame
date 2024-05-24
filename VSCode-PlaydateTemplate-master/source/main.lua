import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

local gfx <const> = playdate.graphics


-- constants
local playerSprite = nil
local playerSpeed = 4
local gameTimer = nil
local playTime = 30 * 1000;
local toppingSprite = nil;
local score = 0;
local Y = 40;
local randX = math.random(40, 360);
local misses = 0;
local fallspeed = 2;
local toppingImage = nil;
local images = {
	'image/burger',
	'image/ketchup',
	'image/lettuce',
	'image/onion',
	'image/tomato'
}

--  functions
local function resetTimer()
	playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end

local function updateToppingImage()
	print(toppingImage)
	toppingImage = gfx.image.new(images[math.random(#images)])
	toppingSprite:setImage(toppingImage)
end

local function moveTopping()
	X = randX
	if Y > 200 then
		misses += 1
		-- random topping
		updateToppingImage()
		
		randX = math.random(40, 360)
		Y = 40
	end

	toppingSprite:moveTo(randX, Y)
	Y += fallspeed
end

-- local function draw()
-- 	screen.clear()
-- 	screen.text("Welcome to My Game!")
-- 	screen.update()
--   end

-- on game load
local function initialize ()
	math.randomseed(playdate.getSecondsSinceEpoch())

	local playerImage = gfx.image.new("image/player")
	playerSprite = gfx.sprite.new(playerImage)
	playerSprite:moveTo(200, 120)
	playerSprite:setCollideRect(0,0,playerSprite:getSize())
	playerSprite:add()


	toppingImage = gfx.image.new(images[math.random(#images)])
	toppingSprite = gfx.sprite.new(toppingImage)
	moveTopping()
	toppingSprite:setCollideRect(0, 0, toppingSprite:getSize())
	toppingSprite:add()

			-- game background
	local backgroundImage = gfx.image.new("image/background")
	gfx.sprite.setBackgroundDrawingCallback(
		function (x, y, width, height)
			gfx.setClipRect(x, y, width, height)
			backgroundImage:draw(0,0)
			gfx.clearClipRect()
		end
	)

	resetTimer()

end;

initialize()

-- on page game render 30 times a sec
function playdate.update()
	if playTimer.value == 0 then
		if playdate.buttonIsPressed(playdate.kButtonA) then
			resetTimer()
			moveTopping()
			score = 0
		end
	else
		if playdate.buttonIsPressed(playdate.kButtonUp) then
			playerSprite:moveBy(0, -playerSpeed)
		end
		if playdate.buttonIsPressed(playdate.kButtonRight) then
			playerSprite:moveBy(playerSpeed, 0)
		end
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			playerSprite:moveBy(0, playerSpeed)
		end
		if playdate.buttonIsPressed(playdate.kButtonLeft) then
			playerSprite:moveBy(-playerSpeed, 0)
		end

		local collisions = toppingSprite:overlappingSprites()
		if #collisions >= 1 then
			Y = 40
			fallspeed += 1
			score += 1
			randX = math.random(40, 360)
			-- random topping
			updateToppingImage()
			moveTopping()

		end
		moveTopping()

	end

	playdate.timer.updateTimers()
	gfx.sprite.update()

	gfx.drawText("Time: " .. math.ceil(playTimer.value/1000), 5, 5)
	gfx.drawText("Score: " .. score, 320, 5)
	gfx.drawText("misses: " .. misses, 230, 5)

end

