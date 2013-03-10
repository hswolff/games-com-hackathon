ig.module(
	"game.entities.evilenemy"
).requires(
	"impact.entity",
	"plugins.box2d.entity"
).defines ->

	window.EntityEvilenemy = ig.Box2DEntity.extend
		size:
			x: 64
			y: 64

		offset:
			x: 4
			y: 2

		type: ig.Entity.TYPE.B
		collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!
		static: true
		animSheet: new ig.AnimationSheet("img/mouth.png", 64, 64)

		init: (x, y, settings) ->
			@parent x, y, settings

			# Add the animations
			@addAnim 'move', 0.1, [0,1,2,1] 

			@currentAnim.flip.x = yes

		update: -> @parent()

		collideWith: (entity) -> entity.killed = true


	return
