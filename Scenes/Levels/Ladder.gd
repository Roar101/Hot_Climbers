
extends Area2D

# --------- LADDER --------- #

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


# Player enters ladder
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("enter_ladder"):
			body.enter_ladder()


# Player leaves ladder
func _on_body_exited(body):
	if body.is_in_group("Player"):
		if body.has_method("exit_ladder"):
			body.exit_ladder()
