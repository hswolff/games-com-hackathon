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

		init: (x, y, settings) ->
			@parent x, y, settings

			# Add the animations
			@addAnim "idle", 1, [0]
			@anims.idle.pivot.y = 86


		update: ->

			if @fireInProgress
				if @fireInProgress.delta() > @fireTime
					@fireInProgress.reset()
				@firePower = @minPower + @maxPower * (@fireInProgress.delta()/@fireTime)

			# move left or right
			if ig.input.state("left")
			    this.currentAnim.angle -= Math.PI/5 * ig.system.tick
			else if ig.input.state("right")
			    this.currentAnim.angle += Math.PI/5 * ig.system.tick

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
				ig.game.font.draw "Power: #{@firePower}", 120, ig.system.height-60

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


	return
