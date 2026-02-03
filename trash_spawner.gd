extends Node2D

# Trash scenes to spawn
@export var trash_scenes: Array[PackedScene] = []

# Spawn settings
@export var spawn_area_min: Vector2 = Vector2(100, 100)
@export var spawn_area_max: Vector2 = Vector2(1800, 1000)

func _ready() -> void:
	# Connect to GameManager quest_started signal
	GameManager.quest_started.connect(_on_quest_started)

func _on_quest_started(_spawn_count: int) -> void:
	# Spawn 25-30 trash items saat quest dimulai (Increased for visibility)
	var actual_count = randi_range(25, 30)
	print("[TrashSpawner] Quest started! Spawning ", actual_count, " trash...")
	spawn_trash_batch(actual_count)

func spawn_trash_batch(count: int) -> void:
	if trash_scenes.is_empty():
		push_error("[TrashSpawner] ERROR: No trash scenes assigned! Assign di Inspector.")
		return
	
	print("[TrashSpawner] Starting spawn of ", count, " trash items...")
	
	for i in range(count):
		spawn_single_trash()
	
	print("[TrashSpawner] Finished spawning ", count, " trash items!")

func spawn_single_trash() -> void:
	# Pick random trash scene
	var trash_scene = trash_scenes.pick_random()
	var trash_instance = trash_scene.instantiate()
	
	# Random position within bounds
	var random_x = randf_range(spawn_area_min.x, spawn_area_max.x)
	var random_y = randf_range(spawn_area_min.y, spawn_area_max.y)
	trash_instance.position = Vector2(random_x, random_y)
	
	# Add to scene
	get_parent().add_child(trash_instance)
