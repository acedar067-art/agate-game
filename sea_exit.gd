extends Area2D

# Script untuk trigger keluar dari bawah laut
# Pasang di Area2D di bagian atas scene bawah_laut

@export var target_scene: String = "res://dunia.tscn"

var player_in_area: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.name == "player_berenang" or body.is_in_group("player"):
		player_in_area = true
		print("[SeaExit] Tekan H untuk naik ke permukaan")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player" or body.name == "player_berenang" or body.is_in_group("player"):
		player_in_area = false

func _input(event: InputEvent) -> void:
	if player_in_area:
		if event is InputEventKey:
			if event.keycode == KEY_H and event.pressed:
				print("[SeaExit] Naik ke permukaan!")
				get_tree().change_scene_to_file(target_scene)
