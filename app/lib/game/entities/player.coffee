ig.module(
	"game.entities.player"
).requires(
	"impact.entity",
	"game.entities.projectile"
).defines ->

	window.EntityPlayer = ig.Entity.extend
		size:
			x: 8
			y: 14

		offset:
			x: 4
			y: 2

		type: ig.Entity.TYPE.A
		checkAgainst: ig.Entity.TYPE.NONE
		collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!

		animSheet: new ig.AnimationSheet("img/cannon.png", 128, 128)
		offset:
			x: 64
			y: 64
		flip: false
		gravityFactor: 0

		fireInProgress: false
		maxPower: 100
		fireTime: 2

		init: (x, y, settings) ->
			@parent x, y, settings

			# Add the animations
			@addAnim "idle", 1, [0]

		update: ->

			if @fireInProgress
				if @fireInProgress.delta() > @fireTime
					@fireInProgress.reset()
				@firePower = @maxPower * (@fireInProgress.delta()/@fireTime)
			# move left or right
			if ig.input.state("left")
			    this.currentAnim.angle -= Math.PI/5 * ig.system.tick;
			else if ig.input.state("right")
			    this.currentAnim.angle += Math.PI/5 * ig.system.tick;


			# shoot
			if ig.input.pressed("shoot")
				if @fireInProgress
					@fireInProgress = false
					@fireProjectile()
				else
					@fireInProgress = new ig.Timer()
					@firePower = 0


			@parent()

		draw: ->
			@parent()

			if @fireInProgress
				ig.game.font.draw "Power: #{@firePower}", 2, 20

		fireProjectile: ->
			x = @pos.x
			y = @pos.y

			velocity = @firePower
			projectile = ig.game.spawnEntity EntityProjectile, x, y

			# Apply impulse based on our angle
			currentAngle = @currentAnim.angle - (Math.PI * .5)
			impulse = new b2.Vec2(Math.cos(currentAngle), Math.sin(currentAngle))
			impulse.Normalize()
			impulse.Multiply(velocity)
			projectile.body.ApplyImpulse impulse, projectile.body.GetPosition()

	return
