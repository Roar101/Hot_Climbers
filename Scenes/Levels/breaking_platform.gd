
extends TileMapLayer

@export var break_time: float = 2.0

var activated: bool = false

@onready var detector = $PlatformDetector


func _ready():
	detector.body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if not body.is_in_group("Player"):
		return

	if activated:
		return

	activated = true

	await get_tree().create_timer(break_time).timeout

	enabled = false
