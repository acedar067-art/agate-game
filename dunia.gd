extends Node2D

var darkness: CanvasModulate


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
			
	# === VISUAL POLLUTION (Request: 75% Dark) ===
	# === VISUAL POLLUTION (Request: 75% Dark) ===
	# Kita tambahkan CanvasModulate via code agar aman
	darkness = CanvasModulate.new()
	
	# Cek apakah quest sampah sudah selesai?
	# Jika sudah (quest_times_completed >= 1), maka udara bersih (Putih)
	# Jika belum, maka udara kotor (Gelap)
	if GameManager.quest_times_completed >= 1:
		darkness.color = Color.WHITE
		print("[Dunia] Air is clean (Quest Done). Darkness Disabled.")
	else:
		darkness.color = Color(0.3, 0.3, 0.3, 1) # Gelap (75% hitam)
		print("[Dunia] Visual Pollution Enabled (Darkness 70-75%)")
		
	add_child(darkness)
	
	# Connect signal to clear pollution when quest done
	if GameManager:
		GameManager.quest_completed_signal.connect(_on_quest_completed)

func _on_quest_completed() -> void:
	print("[Dunia] Quest Complete! Clearing Pollution...")
	# Tween to White (Clean Air)
	var tween = create_tween()
	tween.tween_property(darkness, "color", Color.WHITE, 3.0) # Transisi 3 detik ke bersih
	
	# CLEANUP: Hapus sisa sampah yang belum diambil
	clean_up_garbage()

func clean_up_garbage() -> void:
	var trash_nodes = get_tree().get_nodes_in_group("trash")
	print("[Dunia] Removing ", trash_nodes.size(), " remaining trash items.")
	for node in trash_nodes:
		if is_instance_valid(node):
			node.queue_free()

func _process(delta: float) -> void:
	pass
