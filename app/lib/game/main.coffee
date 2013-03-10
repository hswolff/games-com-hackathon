ig.module("game.main").requires(
	"impact.game",
	'impact.debug.debug',
	"game.entities.player",
	"game.entities.enemy",
	"game.entities.crate",
	"game.entities.collectible",
	"game.levels.1",
	"game.levels.2",
	"game.levels.3",
	"game.levels.4",
	"game.levels.5",
	"game.levels.6",
	"game.levels.7",
	"game.levels.8",
	"plugins.box2d.game",
	"plugins.box2d.debug"
).defines ->

	window.audiolet = new Audiolet
	
	MyGame = ig.Box2DGame.extend(
		gravity: 500 # All entities are affected by this

		# Load a font
		font: new ig.Font("img/hud-font.png")
		clearColor: "#1b2026"
		stats:
			score: 0
		currentLevel: 1

		muffinSprite: new ig.Image('img/ui-muffin.png')

		init: ->
			@showStats = no
			# Add support for simple events on the global ig.game obj.
			MicroEvent.mixin(ig.game.constructor)

			ig.input.bind( ig.KEY.SPACE, 'continue' )

			# Bind keys
			ig.input.bind ig.KEY.LEFT_ARROW, "left"
			ig.input.bind ig.KEY.RIGHT_ARROW, "right"
			ig.input.bind ig.KEY.SPACE, "shoot"
			ig.input.bind ig.KEY.N, "nextlevel"
			ig.input.bind ig.KEY.R, "restart"
			if ig.ua.mobile
				ig.input.bindTouch "#buttonLeft", "left"
				ig.input.bindTouch "#buttonRight", "right"
				ig.input.bindTouch "#buttonShoot", "shoot"
				ig.input.bindTouch "#buttonJump", "jump"

			b2.SCALE = 0.025

			
			@setBackground()

			@loadLevel window["Level#{@currentLevel}"]

			ig.game.on 'collect', -> @stats.blueberriesCollected += 1


			ig.game.on 'finishLevel', @toggleStats
				

		toggleStats: (stats) ->
			@stats = stats
			@showStats = yes
			@continue = stats.baskets > 0
							
		loadLevel: (data) ->
			@parent data
			@debugDrawer = new ig.Box2DDebug( ig.world )

			# reset stats
			@stats.blueberriesCollected = 0
			@stats.totalAttempts = 3
			@stats.attempts = @stats.totalAttempts
			@stats.baskets = 0

			# pre render maps
			map.preRender = true for map in @backgroundMaps

		setBackground: (path) ->
			@clearColor = null
			@bg = new ig.Image('img/bg.png', 800, 640)

		loadNextLevel: ->
			ig.game.loadLevelDeferred ig.global["Level#{++@currentLevel}"] 

		reloadLevel: ->
			ig.game.loadLevelDeferred ig.global["Level#{@currentLevel}"] 

		update: ->
			if ig.input.pressed('restart')
				@reloadLevel()
				@showStats = false
			else if @showStats and @continue and (ig.input.state('nextlevel') or ig.input.state('shoot'))
				@loadNextLevel()
				@showStats = false
				@parent()						
			else
				@parent()  

		drawHUD: ->
			return unless @stats.attempts

			for i in [1..@stats.attempts]
				@muffinSprite.draw ((@muffinSprite.width + 2) * i), 25


		draw: ->
			# Draw all entities and BackgroundMaps
			if @showStats
				bg = new ig.Image('img/BACKGROUND.png', 800, 640)
				bg.draw(0,0)
				# ig.system.context.fillStyle = "rgba(255,255,255, 0.5)"
				# ig.system.context.fillRect( 0, 0, ig.system.realWidth, ig.system.realHeight )

				x = ig.system.width/2
				y = 80

				if @continue
					@statText.draw('Level Complete', x, y, ig.Font.ALIGN.CENTER)
					@statText.draw("Baskets: #{@stats.baskets}/3 ", x, y + 50, ig.Font.ALIGN.CENTER)
					@statText.draw("Blueberries: #{@stats.blueberriesCollected}/3 ", x, y + 80, ig.Font.ALIGN.CENTER)
					@statText.draw('Press N to continue.', x, ig.system.height - 80, ig.Font.ALIGN.CENTER)
				else
					@statText.draw('Level Failed', x, y, ig.Font.ALIGN.CENTER)

				@statText.draw('Press R to retry.', x, ig.system.height - 120, ig.Font.ALIGN.CENTER)
			else
				@bg?.draw(0,0)
				@parent()
				@drawHUD()

				# @debugDrawer.draw()

			
		statText: new ig.Font( 'img/hud-font.png' )
		levelTimer: new ig.Timer()
	)

	StartScreen = ig.Game.extend(
		instructText: new ig.Font( 'img/herculanum-font.png' )
		init: ->
			ig.input.bind( ig.KEY.SPACE, 'start')
			@setBackground()

		update: ->
			if(ig.input.pressed('start'))
				ig.system.setGame(MyGame)
			@parent()

		setBackground: (path) ->
			@clearColor = null
			@bg = new ig.Image('img/title.png', 800, 640)

		draw: ->
			@parent()
			@bg.draw(0,0)
			x = ig.system.width/2
			y = ig.system.height
			@instructText.draw( 'Welcome to', x-100, 30, ig.Font.ALIGN.CENTER)
			@instructText.draw( 'Press Spacebar To Start', x+40, y-60, ig.Font.ALIGN.CENTER)
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
		ig.main "#canvas", StartScreen, 60, 800, 640
