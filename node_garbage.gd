extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.has_method("Player"):
		if GameManager.quest_active:
			GameManager.collect_trash()
			queue_free()
			print("[Garbage] Picked up!")
