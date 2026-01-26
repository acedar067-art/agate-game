extends Area2D

var player_nearby: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.has_method("Player"):
		player_nearby = body
		# Register this trash to player
		if body.has_method("register_nearby_trash"):
			body.register_nearby_trash(self)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.has_method("Player"):
		player_nearby = null
		# Unregister from player
		if body.has_method("unregister_nearby_trash"):
			body.unregister_nearby_trash(self)
