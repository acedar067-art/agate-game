extends Area2D

# Script untuk trigger masuk ke bawah laut
# Pasang di Area2D di atas jembatan ke laut

@export var target_scene: String = "res://bawah_laut.tscn"

var player_in_area: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		player_in_area = true
		print("[SeaEntrance] Player masuk area jembatan - Tekan H untuk menyelam")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		player_in_area = false
		print("[SeaEntrance] Player keluar area jembatan")

func _input(event: InputEvent) -> void:
	if player_in_area:
		# Tekan H untuk menyelam ke bawah laut
		if event is InputEventKey:
			if event.keycode == KEY_H and event.pressed:
				print("[SeaEntrance] Menyelam ke bawah laut!")
				get_tree().change_scene_to_file(target_scene)
