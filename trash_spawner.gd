extends Node2D

# Trash scenes to spawn
@export var trash_scenes: Array[PackedScene] = []

# Spawn settings
# Spawn settings (Lebih aman agar tidak keluar map)
@export var spawn_area_min: Vector2 = Vector2(200, 200)
@export var spawn_area_max: Vector2 = Vector2(1700, 900)

# Additional Zones (Configure these in Inspector or guesses)
# Zone 1: Perumahan (Housing) - Usually densely populated
@export var zone_housing_rect: Rect2 = Rect2(300, 300, 400, 400)
# Zone 2: Hutan (Forest) - Usually outskirts
@export var zone_forest_rect: Rect2 = Rect2(900, 200, 500, 400)

func _ready() -> void:
	# Connect to GameManager quest_started signal
	GameManager.quest_started.connect(_on_quest_started)

func _on_quest_started(_spawn_count: int) -> void:
	# REQUEST: Lebih banyak sampah & fokus di Perumahan/Hutan
	# Total kita naikkan jadi 25-30
	var total_count = randi_range(25, 30)
	print("[TrashSpawner] Quest started! Spawning ", total_count, " trash...")
	
	# Split distribution:
	# 40% Housing, 40% Forest, 20% Random/Scattered
	var count_housing = int(total_count * 0.4)
	var count_forest = int(total_count * 0.4)
	var count_random = total_count - count_housing - count_forest
	
	spawn_in_zone(zone_housing_rect, count_housing, "Housing")
	spawn_in_zone(zone_forest_rect, count_forest, "Forest")
	spawn_trash_batch(count_random) # Random scatter

func spawn_in_zone(area: Rect2, count: int, zone_name: String) -> void:
	if trash_scenes.is_empty(): return
	
	print("[TrashSpawner] Spawning ", count, " in ", zone_name)
	for i in range(count):
		spawn_single_trash_in_rect(area)

func spawn_trash_batch(count: int) -> void:
	if trash_scenes.is_empty():
		push_error("[TrashSpawner] ERROR: No trash scenes assigned! Assign di Inspector.")
		return
	
	print("[TrashSpawner] Spawning ", count, " random scattered trash...")
	for i in range(count):
		# Existing random logic using min/max vectors
		# Convert min/max to rect
		var random_area = Rect2(spawn_area_min, spawn_area_max - spawn_area_min)
		spawn_single_trash_in_rect(random_area)

func spawn_single_trash_in_rect(rect: Rect2) -> void:
	# Pick random trash scene
	var trash_scene = trash_scenes.pick_random()
	var trash_instance = trash_scene.instantiate()
	
	# Random position within specific RECT
	var random_x = randf_range(rect.position.x, rect.position.x + rect.size.x)
	var random_y = randf_range(rect.position.y, rect.position.y + rect.size.y)
	trash_instance.position = Vector2(random_x, random_y)
	
	# Add to scene
	get_parent().add_child(trash_instance) # Add to Dunias
