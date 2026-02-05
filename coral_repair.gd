extends Area2D

# Script untuk Coral Rusak
# Pasang script ini di scene 'damaged_coral.tscn'

@export var repaired_scene: PackedScene # Drag 'coral_afterrepair.tscn' ke sini di Inspector
var player_in_area = false

func _ready():
	# Connect signal body entered/exited logic
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "player" or body.is_in_group("player"):
		player_in_area = true
		print("[Coral] Player detected. Press 'F' to repair.")
		
		# Register to player script if method exists
		if body.has_method("register_nearby_coral"):
			body.register_nearby_coral(self)

func _on_body_exited(body):
	if body.name == "player" or body.is_in_group("player"):
		player_in_area = false
		
		# Unregister
		if body.has_method("unregister_nearby_coral"):
			body.unregister_nearby_coral(self)

func _unhandled_input(event):
	if player_in_area and event.is_action_pressed("pickup"): # Pakai tombol F (Pickup)
		try_repair()

# Public alias for player script to call
func repair():
	try_repair()

func try_repair():
	# Cek apakah material cukup?
	if GameManager.has_coral_materials():
		# Gunakan material
		GameManager.use_coral_materials()
		
		# Lakukan swap scene
		swap_to_repaired()
	else:
		print("[Coral] Missing Materials! Need: Besi, Pasir, Cable.")

func swap_to_repaired():
	if repaired_scene:
		# 1. Spawn scene baru (Coral Bagus)
		var new_coral = repaired_scene.instantiate()
		new_coral.position = position # Samakan posisi
		
		# 2. Masukkan ke scene tree (sebagai sibling)
		get_parent().add_child(new_coral)
		
		# 3. Update Game State (Ending Trigger)
		GameManager.set_coral_repaired()
		
		# 4. Hapus diri sendiri (Coral Rusak)
		queue_free()
		
		print("[Coral] Repaired successfully!")
	else:
		print("[Coral] Error: Repaired Scene not assigned in Inspector!")
