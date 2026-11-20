
extends CharacterBody2D

@export var move_speed: float = 400
@export var jump_force: float = 650
@export var gravity: float = 30
@export var climb_speed: float = 200
@export var max_jump_count: int = 2

var jump_count: int = 2

@export_group("Toggle Functions")
@export var double_jump := false

var movement_enabled: bool = true
var ladders_touching: int = 0
var is_climbing: bool = false
var ladder_jump_locked: bool = false
var is_landing: bool = false

@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles


func _ready():
	player_sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(_delta):
	var was_on_floor = is_on_floor()

	movement()

	if not movement_enabled:
		return

	if not was_on_floor and is_on_floor() and not is_climbing:
		is_landing = true
		player_sprite.play("Land")

	if not is_on_floor() or is_climbing:
		is_landing = false


func _process(_delta):
	player_animations()
	flip_player()


func movement():
	if not movement_enabled:
		velocity.x = 0
		return

	var horizontal_input = Input.get_axis("Left", "Right")
	var vertical_input = Input.get_axis("Up", "Down")

	if ladders_touching > 0 and not ladder_jump_locked:
		if abs(vertical_input) > 0.1:
			is_climbing = true

	if is_climbing:
		velocity.y = vertical_input * climb_speed

		if Input.is_action_just_pressed("Jump"):
			is_climbing = false
			ladder_jump_locked = true
			jump()

	else:
		if not is_on_floor():
			velocity.y += gravity
		else:
			jump_count = max_jump_count

		handle_jumping()

	velocity.x = horizontal_input * move_speed

	move_and_slide()


func enter_ladder():
	ladders_touching += 1


func exit_ladder():
	ladders_touching = max(0, ladders_touching - 1)

	if ladders_touching == 0:
		is_climbing = false
		ladder_jump_locked = false


func handle_jumping():
	if Input.is_action_just_pressed("Jump") and movement_enabled:
		if is_on_floor() and not double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1


func jump():
	is_landing = false
	jump_tween()
	AudioManager.jump_sfx.play()
	velocity.y = -jump_force


func player_animations():
	particle_trails.emitting = false

	if not movement_enabled:
		return

	if is_climbing:
		var vertical_input = Input.get_axis("Up", "Down")

		if abs(vertical_input) > 0.1:
			player_sprite.play("Climb")
		else:
			if player_sprite.animation != "Climb":
				player_sprite.play("Climb")
			player_sprite.pause()

		return

	if is_landing:
		return

	if not is_on_floor():
		if velocity.y < 0:
			player_sprite.play("Jump")
		else:
			player_sprite.play("Fall")
		return

	if abs(velocity.x) > 0:
		particle_trails.emitting = true
		player_sprite.play("Walk", 1.5)
	else:
		player_sprite.play("Idle")


func _on_animation_finished():
	if player_sprite.animation == "Land":
		is_landing = false


func flip_player():
	if velocity.x < 0:
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false


func death_tween():
	movement_enabled = false
	is_climbing = false
	is_landing = false

	var tween = create_tween()

	tween.tween_property(
		player_sprite,
		"scale",
		Vector2.ZERO,
		0.15
	)

	tween.parallel().tween_property(
		player_sprite,
		"position",
		Vector2.ZERO,
		0.15
	)

	await tween.finished

	global_position = spawn_point.global_position

	await get_tree().create_timer(0.3).timeout

	movement_enabled = true

	AudioManager.respawn_sfx.play()
	respawn_tween()


func respawn_tween():
	var tween = create_tween()

	tween.tween_property(
		player_sprite,
		"scale",
		Vector2.ONE,
		0.15
	)

	tween.parallel().tween_property(
		player_sprite,
		"position",
		Vector2(0, -48),
		0.15
	)


func jump_tween():
	var tween = create_tween()

	tween.tween_property(
		self,
		"scale",
		Vector2(0.7, 1.4),
		0.1
	)

	tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		0.1
	)


func _on_collision_body_entered(body):
	if body.is_in_group("Traps"):
		AudioManager.death_sfx.play()
		death_particles.emitting = true
		death_tween()
