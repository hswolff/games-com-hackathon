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
		gravity: 980 # All entities are affected by this

		# Load a font
		font: new ig.Font("img/hud-font.png")
		clearColor: "#1b2026"
		stats:
			score: 0
		currentLevel: 1

		muffinSprite: new ig.Image('img/ui-muffin.png')

		medalSprites:
			bronze: new ig.Image('img/medal-bronze.png')
			silver: new ig.Image('img/medal-silver.png')
			gold: new ig.Image('img/medal-gold.png')

		basketSprite: new ig.Image("img/basket.png")
		blueberrySprite: new ig.Image("img/blueberry.png")

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
			level = ig.global["Level#{++@currentLevel}"] 
			if level
				ig.game.loadLevelDeferred level
			else
				ig.system.setGame(EndScreen)

		reloadLevel: ->
			ig.game.loadLevelDeferred ig.global["Level#{@currentLevel}"] 

		update: ->
			if ig.input.pressed('restart')
				@reloadLevel()
				@showStats = false
			else if @showStats and @continue and (ig.input.state('nextlevel') or ig.input.state('shoot'))
				@loadNextLevel()
				@parent()
				@showStats = false
			else
				@parent()  

		drawHUD: ->
			@font.draw("Level #{@currentLevel}", 25, 25, ig.Font.ALIGN.LEFT)
			
			return unless @stats.attempts

			for i in [1..@stats.attempts]
				@muffinSprite.draw ((@muffinSprite.width + 2) * i) + 115, 30

		getMedal: ->
			total = @stats.baskets + @stats.blueberriesCollected
			award = if total >= 6
				'gold'
			else if 3 <= total < 6
				'silver'
			else 
				'bronze'
				
			@medalSprites[award]

		draw: ->
			# Draw all entities and BackgroundMaps
			if @showStats
				bg = new ig.Image('img/BACKGROUND.png', 800, 640)
				bg.draw(0,0)
				# ig.system.context.fillStyle = "rgba(255,255,255, 0.5)"
				# ig.system.context.fillRect( 0, 0, ig.system.realWidth, ig.system.realHeight )
				centerX = ig.system.width/2
				y = 175
				
				if @continue
					medalY = 25
					medal = @getMedal()
					medal.draw centerX-medal.width/2, medalY

					levelFontY = medalY + medal.height + 10
					@font.draw("Level #{@currentLevel} Complete", centerX, levelFontY, ig.Font.ALIGN.CENTER)

					basketFontY = levelFontY + @font.height + 20
					@font.draw("Baskets", centerX, basketFontY, ig.Font.ALIGN.CENTER)
					basketSpriteY = basketFontY + @font.height/1.5
					for i in [1..@stats.baskets]
						@basketSprite.draw ((@basketSprite.width + 2) * i) + 80, basketSpriteY

					blueberryFontY = basketSpriteY + @basketSprite.height + 20
					@font.draw("Blueberries", centerX, blueberryFontY, ig.Font.ALIGN.CENTER)
					blueberryImageY = blueberryFontY + @font.height
					for i in [1..@stats.blueberriesCollected]
						@blueberrySprite.draw ((@blueberrySprite.width + 20) * i) + 285, blueberryImageY

					@font.draw('Press N to continue.', centerX, ig.system.height - 80, ig.Font.ALIGN.CENTER)
				else
					@font.draw('Level Failed', centerX, y, ig.Font.ALIGN.CENTER)

				@font.draw('Press R to retry.', centerX, ig.system.height - 120, ig.Font.ALIGN.CENTER)
			else
				@bg?.draw(0,0)
				@parent()
				@drawHUD()

				# @debugDrawer.draw()
	)

	StartScreen = ig.Game.extend(
		instructText: new ig.Font( 'img/herculanum-font.png' )
		init: ->
			ig.input.bind( ig.KEY.SPACE, 'start')
			@setBackground()

			ig.music.add('lib/game/music/muffin.ogg')

			ig.music.volume = 0.5
			ig.music.play()

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

			@instructText.draw( 'Arrow Keys to Aim', x+40, y-230, ig.Font.ALIGN.CENTER)
			@instructText.draw( 'Spacebar to Launch Muffin', x+40, y-180, ig.Font.ALIGN.CENTER)

	)

	EndScreen = ig.Game.extend(
		instructText: new ig.Font( 'img/herculanum-font.png' )
		init: ->
			ig.input.bind( ig.KEY.SPACE, 'start')
			@setBackground()

			ig.music.add('lib/game/music/muffin.ogg')

			ig.music.volume = 0.5
			ig.music.play()

		update: ->
			if(ig.input.pressed('start'))
				ig.system.setGame(MyGame)
			@parent()

		setBackground: (path) ->
			@clearColor = null
			@bg = new ig.Image('img/BACKGROUND.png', 800, 640)

		draw: ->
			@parent()
			@bg.draw(0,0)
			x = ig.system.width/2
			y = ig.system.height/2
			@instructText.draw( 'You Won!', x, y-y/2, ig.Font.ALIGN.CENTER)
			@instructText.draw( 'Press Spacebar to Start Again', x, y+y/2, ig.Font.ALIGN.CENTER)

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
