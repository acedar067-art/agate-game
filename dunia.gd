extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Cek Spawn Position from Sea
	if GameManager.spawn_at_bridge:
		# Reset flag
		GameManager.spawn_at_bridge = false
		
		# Find Bridge/SeaEntrance
		var bridge = get_node_or_null("SeaEntrance") # Coba cari node bernama SeaEntrance
		if not bridge:
			bridge = find_child("SeaEntrance", true, false)
			
		# Find Player
		var player = get_node_or_null("player")
		if not player:
			player = find_child("player", true, false)
			
		if bridge and player:
			print("[Dunia] Positioning player at Bridge (return from sea)")
			player.position = bridge.position
			
			# UPDATE: Geser ke atas (Negative Y) agar pas di visual jembatan
			# Karena SeaEntrance node mungkin ada di area air/ujung jembatan
			player.position.y -= 150
		else:
			print("[Dunia] WARNING: Could not set spawn position. Bridge or Player missing.")

	# Tunggu sebentar agar loading selesai
	await get_tree().create_timer(1.0).timeout
	
	# Panggil intro narration HANYA JIKA BELUM PERNAH
	if not GameManager.intro_shown:
		var trigger = get_node_or_null("NarrationTrigger")
		if trigger:
			trigger.show_intro()
			GameManager.intro_shown = true # Set flag agar tidak muncul lagi
		else:
			print("WARNING: NarrationTrigger node not found in dunia.tscn")

func _process(delta: float) -> void:
	pass
