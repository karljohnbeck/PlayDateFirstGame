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
local playTime = 30 * 1000
local coinSprite = nil
local score = 0
local Y = 40
local randX = math.random(40, 360)
local misses = 0 

--  functions
local function resetTimer()
	playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end

local function moveCoin()
	X = randX
	if Y > 200 then
		misses += 1
		randX = math.random(40, 360)
		Y = 40
	end
	-- removed
	-- local randX = 40

	-- local randY = math.random(40, 200)

	coinSprite:moveTo(randX, Y)
	Y += 2
end

-- on game load
local function initialize ()
	math.randomseed(playdate.getSecondsSinceEpoch())

	local playerImage = gfx.image.new("image/player")
	playerSprite = gfx.sprite.new(playerImage)
	playerSprite:moveTo(200, 120)
	playerSprite:setCollideRect(0,0,playerSprite:getSize())
	playerSprite:add()

	local coinImage = gfx.image.new("image/coin")
	coinSprite = gfx.sprite.new(coinImage)
	moveCoin()
	coinSprite:setCollideRect(0, 0, coinSprite:getSize())
	coinSprite:add()

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
			moveCoin()
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

		local collisions = coinSprite:overlappingSprites()
		if #collisions >= 1 then
			randX = math.random(40, 360)
			Y = 200
			moveCoin()
			score += 1
		end
		moveCoin()

	end

	playdate.timer.updateTimers()
	gfx.sprite.update()

	gfx.drawText("Time: " .. math.ceil(playTimer.value/1000), 5, 5)
	gfx.drawText("Score: " .. score, 320, 5)
	gfx.drawText("misses: " .. misses, 230, 5)

end

