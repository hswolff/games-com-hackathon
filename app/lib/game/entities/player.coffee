ig.module(
	"game.entities.player"
).requires(
	"impact.entity",
	"game.entities.projectile"
).defines ->

	window.EntityPlayer = ig.Entity.extend
		size:
			x: 128
			y: 128

		type: ig.Entity.TYPE.A
		checkAgainst: ig.Entity.TYPE.NONE
		collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!

		animSheet: new ig.AnimationSheet("img/cannon.png", 128, 128)
		flip: false
		gravityFactor: 0

		fireInProgress: false
		minPower: 20
		maxPower: 100
		fireTime: 2

		shootSound: new ig.Sound( 'lib/game/music/cannon.mp3' )

		init: (x, y, settings) ->
			@parent x, y, settings

			# Add the animations
			@addAnim "idle", 1, [0]
			@anims.idle.pivot.y = 86


		updateCurrentPower: ->
			powerOfTimer = @maxPower * (@fireInProgress.delta()/@fireTime)
			if @countingUp
				@currentPower = powerOfTimer
			else
				@currentPower = @maxPower - powerOfTimer

		update: ->
			# shoot
			if not ig.game.showStats and ig.input.pressed("shoot") and ig.game.stats.attempts > 0
				@countingUp = true
				if @fireInProgress
					@fireInProgress = false
					@fireProjectile()
				else
					@fireInProgress = new ig.Timer()
					@firePower = 0

			# update power
			if @fireInProgress
				if @fireInProgress.delta() > @fireTime
					@fireInProgress.reset()
					@countingUp = !@countingUp
				@updateCurrentPower()
				@firePower = @minPower + @currentPower

			# move left or right
			if ig.input.state("left")
			    @currentAnim.angle -= Math.PI/5 * ig.system.tick
			else if ig.input.state("right")
			    @currentAnim.angle += Math.PI/5 * ig.system.tick

			@parent()

		draw: ->
			borderSize = 16
			powerWidth = 30

			powerMultiplyer = 2
			# power outline
			ig.system.context.fillStyle = "rgb(0,0,0)"
			ig.system.context.beginPath()
			ig.system.context.rect(
			                borderSize, 
			                ig.system.realHeight-borderSize, 
			                powerWidth, 
			                -@maxPower * powerMultiplyer
			            )
			ig.system.context.closePath()
			ig.system.context.stroke()

			if @fireInProgress
				# power fill
				ig.system.context.fillStyle = "rgb(255,0,0)"
				ig.system.context.beginPath()
				ig.system.context.rect(
				                borderSize, 
				                ig.system.realHeight-borderSize, 
				                powerWidth, 
				                -@currentPower * powerMultiplyer
				            )
				ig.system.context.closePath()
				ig.system.context.fill()

			@parent()


		fireProjectile: ->
			x = @pos.x + @size.x/2 - EntityProjectile::size.x/2
			y = @pos.y + @size.y/2 - EntityProjectile::size.y/2

			velocity = @firePower
			projectile = ig.game.spawnEntity EntityProjectile, x, y

			# Apply impulse based on our angle
			impulse = new b2.Vec2(Math.cos(@currentAnim.angle - Math.PI * 0.5), Math.sin(@currentAnim.angle - Math.PI * 0.5))
			impulse.Multiply(velocity)
			projectile.body.ApplyImpulse impulse, projectile.body.GetPosition()

			ig.game.stats.attempts--

			@shootSound.play()


	return
