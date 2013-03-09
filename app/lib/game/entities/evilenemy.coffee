ig.module(
	"game.entities.evilenemy"
).requires(
	"impact.entity",
	"plugins.box2d.entity"
).defines ->

	window.EntityEvilenemy = ig.Box2DEntity.extend
		size:
			x: 8
			y: 14

		offset:
			x: 4
			y: 2

		type: ig.Entity.TYPE.B
		collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!
		static: true
		animSheet: new ig.AnimationSheet("media/evil-enemy.png", 16, 24)

		init: (x, y, settings) ->
			@parent x, y, settings

			# Add the animations
			@addAnim 'move', 0.05, [1,2] 

			@currentAnim.flip.x = yes

		update: -> @parent()

		collideWith: (entity) -> entity.kill()

	return
