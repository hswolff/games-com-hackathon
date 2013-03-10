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
	"plugins.box2d.game"
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

		init: ->
			
			# Add support for simple events on the global ig.game obj.
			MicroEvent.mixin(ig.game.constructor)

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

			ig.game.on 'collect', ->
				@stats.blueberriesCollected += 1


			ig.game.on 'finishLevel', (stats) ->
				alert JSON.stringify stats

		loadLevel: (data) ->
			@parent data

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

		update: ->
			if(ig.input.pressed('nextlevel'))
				ig.game.loadLevelDeferred ig.global["Level#{++@currentLevel}"] 
			if(ig.input.pressed('restart'))
				ig.game.loadLevelDeferred ig.global["Level#{@currentLevel}"] 
			@parent()

		drawStats: ->
			x = ig.system.width/2
			y = 20
			leftAlignedX = 30
			this.statText.draw('Total Score: '+this.stats.score, ig.system.width-30, y, ig.Font.ALIGN.RIGHT)
			this.statText.draw('Level ' + this.currentLevel, leftAlignedX, y, ig.Font.ALIGN.LEFT)
			this.statText.draw('Toppings Collected: '+this.stats.blueberriesCollected, leftAlignedX, y+=40, ig.Font.ALIGN.LEFT)
			this.statText.draw('Attempts: '+this.stats.attempts, leftAlignedX, y+=40, ig.Font.ALIGN.LEFT)
			this.statText.draw "Baskets: #{@stats.baskets}/#{@stats.totalAttempts}", leftAlignedX, y+=40, ig.Font.ALIGN.LEFT

		draw: ->
			# Draw all entities and BackgroundMaps
			@bg?.draw(0,0)
			@parent()
			@drawStats()

			

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
