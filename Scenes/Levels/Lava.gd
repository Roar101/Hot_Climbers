
extends Area2D

# --------- LAVA SETTINGS --------- #

@export var rise_speed: float = 25.0

var lava_stopped: bool = false

@onready var game_over_ui: CanvasLayer = $"../GameOverUI"


# --------- START --------- #

func _ready():
	game_over_ui.hide()

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


# --------- LAVA MOVEMENT --------- #

func _physics_process(delta):

	if lava_stopped:
		return

	position.y -= rise_speed * delta


# --------- PLAYER TOUCHES LAVA --------- #

func _on_body_entered(body):

	if lava_stopped:
		return

	if body.is_in_group("Player"):

		# Stop lava
		lava_stopped = true

		# Stop player
		body.velocity = Vector2.ZERO
		body.set_physics_process(false)
		body.set_process(false)

		# Death sound
		AudioManager.death_sfx.play()

		# Death particles
		if body.has_node("DeathParticles"):
			body.get_node("DeathParticles").emitting = true

		# Hide player
		if body.has_node("AnimatedSprite2D"):
			body.get_node("AnimatedSprite2D").hide()

		# Show Game Over
		game_over_ui.show()


# --------- RESTART GAME --------- #

func _input(event: InputEvent):

	if not lava_stopped:
		return

	if event.is_action_pressed("Jump"):

		# Reset score
		GameManager.score = 0

		# Restart level
		get_tree().call_deferred("reload_current_scene")
