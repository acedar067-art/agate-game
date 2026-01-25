extends CanvasLayer

@onready var counter_label: Label = $MarginContainer/Label

func _ready() -> void:
	# Connect to GameManager signals
	GameManager.quest_started.connect(_on_quest_started)
	GameManager.trash_collected.connect(_on_trash_collected)
	GameManager.quest_completed_signal.connect(_on_quest_completed)
	
	# Start hidden
	visible = false

func _on_quest_started(_spawn_count: int) -> void:
	visible = true
	update_counter()

func _on_trash_collected(_count: int) -> void:
	update_counter()

func _on_quest_completed() -> void:
	# Show completion message briefly then hide
	counter_label.text = "✅ Quest Complete! +100"
	await get_tree().create_timer(2.0).timeout
	visible = false

func update_counter() -> void:
	counter_label.text = "🗑️ " + str(GameManager.trash_count) + "/" + str(GameManager.target_trash)
