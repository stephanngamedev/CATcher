--hidden status bar
display.setStatusBar(display.HiddenStatusBar)

--import and star physics
local physics = require 'physics'
physics.start()

--screen properties
local screen_width = display.contentWidth
local screen_height = display.contentHeight
local center_x = display.contentCenterX
local center_y = display.contentCenterY

--image sheet data
local data_sheet = {
	width = 87,
	height = 75,
	sheetContentWidth = 348,
	sheetContentHeight = 300,
	numFrames = 16
}

--animation data
local data_sprite = {
	{
		name = 'stopped_left',
		start = 1,
		count = 4,
		time = 1000
	},
	{
		name = 'stopped_right',
		start = 5,
		count = 4,
		time = 1000
	},
	{
		name = 'running_left',
		start = 9,
		count = 4,
		time = 700
	},
	{
		name = 'running_right',
		start = 13,
		count = 4,
		time = 700
	}
}

local background
local cat
local floor
local arrow_left
local arrow_right

local score_display
local score = 0

local sound_star
local sound_background

--init variables
local function init()
	background = display.newImage( 'img/background.png', 0, 0 )

	--create cat image sheet
	cat_sheet = graphics.newImageSheet( 'img/cat_sprites.png', data_sheet )

	--create cat sprite
	cat = display.newSprite( cat_sheet, data_sprite )
	cat.x = center_x
	cat.y = 380
	cat.x_speed = 0
	cat.name = 'cat'

	cat:setSequence('stopped_left')
	cat:play()

	floor = display.newRect( 0, screen_height - 5, screen_width, 5)
	floor.alpha = 0
	floor.name = 'floor'

	--create right and left buttons
	arrow_left = display.newImage( 'img/arrow-left.png', 0, 0 )
	arrow_left.x = 50
	arrow_left.y = screen_height - 50
	arrow_left.alpha = .2
	arrow_right = display.newImage( 'img/arrow-right.png', 0, 0 )
	arrow_right.x = screen_width - 50
	arrow_right.y = screen_height - 50
	arrow_right.alpha = .2

	--create score text
	score_display = display.newText( 'Score: 0', 0, 0, nil, 20 )
	score_display.x = center_x
	score_display.y = 20
	score_display:setTextColor( 255, 255, 0 )

	--load sounds
	sound_star = audio.loadSound( 'sound/star.wav')
	sound_background = audio.loadStream( 'sound/background.mp3')

	--play background sound
	audio.play( sound_background, { loop = -1 })
end

--run on every frame
local function update()
	--move cat
	cat.x = cat.x + cat.x_speed	
end

local function touch_left( event )
	if event.phase == 'began' then
		cat.x_speed = -3
		cat:setSequence('running_left')
		cat:play()
	elseif event.phase == 'ended' then
		cat.x_speed = 0
		cat:setSequence('stopped_left')
		cat:play()
	end
end


local function touch_right( event )
	if event.phase == 'began' then
		cat.x_speed = 3
		cat:setSequence('running_right')
		cat:play()
	elseif event.phase == 'ended' then
		cat.x_speed = 0
		cat:setSequence('stopped_right')
		cat:play()
	end
end

--create fallen stars
local function create_star()
	local star = display.newImage( 'img/star.png', 0, 0 )
	star.x = math.random( 0, screen_width )
	star.y = 10
	star.name = 'star'

	physics.addBody( star, 'dynamic' )
end

local function refresh_score()
	score_display.text = 'Score: '..score
	score_display.x = center_x
end

local function collision( event )
	--collision between floor and star
	if event.object1.name == 'floor' and event.object2.name == 'star' then
		event.object2:removeSelf()
		event.object2 = nil
		score = score - 50
		refresh_score()
	--collision between cat and star
	elseif event.object1.name == 'cat' and event.object2.name == 'star' then
		event.object2:removeSelf()
		event.object2 = nil
		score = score + 100
		refresh_score() 
		audio.play( sound_star )
	end
end

local function add_listeners()
	arrow_left:addEventListener( 'touch', touch_left )
	arrow_right:addEventListener( 'touch', touch_right )
	Runtime:addEventListener( 'enterFrame', update )
	Runtime:addEventListener( 'collision', collision )
end

local function init_physics()
	physics.addBody( cat, 'dynamic' )
	physics.addBody( floor, 'static' )
end

init()
init_physics()
add_listeners()

--create star every 2 seconds
timer.performWithDelay( 2000, create_star, 0 )