ig.module("game.main").requires(
	"impact.game",
    'impact.debug.debug',
	"game.entities.player",
	"game.entities.enemy",
	"game.entities.crate",
	"game.entities.collectible",
	"game.levels.test",
	"game.levels.one",
	"game.levels.two",
	"game.levels.three",
	"plugins.box2d.game"
).defines ->
	
	MyGame = ig.Box2DGame.extend(
		gravity: 100 # All entities are affected by this

		# Load a font
		font: new ig.Font("media/04b03.font.png")
		clearColor: "#1b2026"
		init: ->
			
			# Bind keys
			ig.input.bind ig.KEY.LEFT_ARROW, "left"
			ig.input.bind ig.KEY.RIGHT_ARROW, "right"
			ig.input.bind ig.KEY.X, "jump"
			ig.input.bind ig.KEY.C, "shoot"
			if ig.ua.mobile
				ig.input.bindTouch "#buttonLeft", "left"
				ig.input.bindTouch "#buttonRight", "right"
				ig.input.bindTouch "#buttonShoot", "shoot"
				ig.input.bindTouch "#buttonJump", "jump"
			
			# Load the LevelTest as required above ('game.level.test')
			# @loadLevel LevelTest
			@loadLevel LevelOne

		loadLevel: (data) ->
			@parent data
			i = 0

			while i < @backgroundMaps.length
				@backgroundMaps[i].preRender = true
				i++

		update: ->
			@parent()

		draw: ->
			# Draw all entities and BackgroundMaps
			@parent()
			@font.draw "Arrow Keys, X, C", 2, 2  unless ig.ua.mobile
	)

	StartScreen = ig.Game.extend(
		instructText: new ig.Font( 'media/04b03.font.png' )
		init: ->
			ig.input.bind( ig.KEY.SPACE, 'start')
		update: ->
			if(ig.input.pressed('start'))
				ig.system.setGame(MyGame)
			this.parent()
		draw: ->
			this.parent()
			x = ig.system.width/2
			y = ig.system.height - 10
			this.instructText.draw( 'Welcome', x-40, 10, ig.Font.ALIGN.CENTER)
			this.instructText.draw( 'to', x-40, 40, ig.Font.ALIGN.CENTER)
			this.instructText.draw( 'MUFFIN QUEST', x, 70, ig.Font.ALIGN.CENTER)
			this.instructText.draw( 'Press Spacebar To Start', x+40, y,
			ig.Font.ALIGN.CENTER)
	)

	if ig.ua.iPad
		ig.Sound.enabled = false
		ig.main "#canvas", StartScreen, 60, 240, 160, 2
	else if ig.ua.mobile
		ig.Sound.enabled = false
		width = 320
		height = 320
		ig.main "#canvas", StartScreen, 60, 160, 160, 1
		c = ig.$("#canvas")
		c.width = width
		c.height = height
		pr = 2 #ig.ua.pixelRatio;
		unless pr is 1
			
			#~ c.style.width = (width / pr) + 'px';
			#~ c.style.height = (height / pr) + 'px';
			c.style.webkitTransformOrigin = "left top"
			
			#~ 'translate3d('+(width / (4 * pr))+'px, '+(height / (4 * pr))+'px, 0)' + 
			#~ 'scale3d('+pr+', '+pr+', 0)' +
			c.style.webkitTransform = "scale3d(2,2, 0)" + ""
	
	#~ ig.system.canvas.style.width = '320px';
	#~ ig.system.canvas.style.height = '320px';
	#~ ig.$('#body').style.height = '800px';
	
	#~ 320
	#~ 80 480  80 // div 320/1.5 = 213
	#~ 160 640 160 // div 320/2 = 160
	else
		ig.main "#canvas", StartScreen, 60, 240, 160, 3
