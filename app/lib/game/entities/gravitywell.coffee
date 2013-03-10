ig.module(
	"game.entities.gravitywell"
).requires(
	"impact.entity",
	"plugins.box2d.entity"
).defines ->

	window.EntityGravitywell = ig.Box2DEntity.extend
		size:
			x: 220
			y: 192

		offset:
			x: -100
			y: -60

		type: ig.Entity.TYPE.B
		collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!
		static: true
		animSheet: new ig.AnimationSheet("img/plate.png", 64, 64)

		init: (x, y, settings) ->
			@parent x, y, settings

			# Add the animations
			@addAnim 'move', 1, [0,1,2] 
			@body.SetXForm @body.GetPosition(), -Math.PI/2

		update: -> @parent()

		collideWith: (entity) -> 
			console.log 'hello'

			dx = @body.GetPosition().x - entity.body.GetPosition().x
			dy = @body.GetPosition().y - entity.body.GetPosition().y

			distance = Math.sqrt(dx * dx + dy * dy)
			angle = Math.atan2(dy, dx)			

			intensity = 2
			currVel = entity.body.GetLinearVelocity()

			dir = new b2.Vec2()

			dir.x = currVel.x + intensity * Math.cos(angle)
			dir.y = currVel.y + intensity * Math.sin(angle)

			entity.body.SetLinearVelocity(dir)

	return
