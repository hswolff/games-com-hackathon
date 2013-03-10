ig.module(
	"game.entities.trampoline"
).requires(
	"impact.entity",
	"plugins.box2d.entity"
).defines ->

	window.EntityTrampoline = ig.Box2DEntity.extend
		size:
			x: 64
			y: 64

		type: ig.Entity.TYPE.B
		collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!
		static: true
		animSheet: new ig.AnimationSheet("img/bumper.png", 64, 64)
		restitution: 1.1

		init: (x, y, settings) ->
			@parent x, y, settings
			@addAnim 'idle', 1, [0] 

		createBody: ->
			bodyDef = new b2.BodyDef()
			bodyDef.position.Set (@pos.x + @size.x / 2) * b2.SCALE, (@pos.y + @size.y / 2) * b2.SCALE

			@body = ig.world.CreateBody(bodyDef)

			shapeDef = new b2.CircleDef()
			shapeDef.radius = @size.x / 2 * b2.SCALE
			shapeDef.density = 1
			shapeDef.restitution = @restitution

			@body.CreateShape shapeDef

	return
