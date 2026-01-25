extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if player entered
	if body.is_in_group("player") or body.has_method("Player"):
		# Only collect if quest is active
		if GameManager.quest_active:
			GameManager.collect_trash()
			queue_free()  # Remove trash from scene
			print("[Trash] Picked up!")
