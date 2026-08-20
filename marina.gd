extends CharacterBody2D

# Marina — Quest Giver & Guru Sorting (Act 2)
# Pattern mengikuti tina.gd: Area2D detection + DialogueManager

var is_chatting: bool = false
var player_in_chat_zone: bool = false

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

func _ready() -> void:
	# Auto-load resource jika belum di-assign di inspector
	if not dialogue_resource:
		if ResourceLoader.exists("res://marina.dialogue"):
			dialogue_resource = load("res://marina.dialogue")

	# Connect area chat detection
	var area = get_node_or_null("area_chat_detection")
	if area:
		if not area.body_entered.is_connected(_on_chat_detection_area_body_entered):
			area.body_entered.connect(_on_chat_detection_area_body_entered)
		if not area.body_exited.is_connected(_on_chat_detection_area_body_exited):
			area.body_exited.connect(_on_chat_detection_area_body_exited)

	# Connect dialogue signal
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

# Input handling untuk dialogue
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if player_in_chat_zone and not is_chatting:
			start_dialogue()

func start_dialogue() -> void:
	print("[Marina] Starting Marina dialogue...")
	is_chatting = true

	var dialogue_title = dialogue_start

	# Branch berdasarkan state
	if GameManager.marina_met:
		dialogue_title = "meet_again"
	elif GameManager.coral_repaired:
		dialogue_title = "start"
	else:
		dialogue_title = "coral_first"

	if dialogue_resource:
		print("[Marina] Dialogue showing: ", dialogue_title)
		DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_title)
	else:
		print("[Marina] ERROR: dialogue_resource is null!")
		is_chatting = false

func _on_dialogue_ended(_resource) -> void:
	print("[Marina] Dialogue ended")
	is_chatting = false

func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("Player") or body.is_in_group("player"):
		player_in_chat_zone = true
		print("[Marina] Player masuk area chat")

func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("Player") or body.is_in_group("player"):
		player_in_chat_zone = false
		print("[Marina] Player keluar area chat")
