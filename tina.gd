extends CharacterBody2D

const speed = 30
var current_state = IDLE

var dir = Vector2.RIGHT
var start_pos

var is_roaming = false
var is_chatting = false

var player
var player_in_chat_zone = false

# Dialogue Manager integration
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

enum {
	IDLE
}

func _ready():
	randomize()
	start_pos = position
	$AnimatedSprite2D.play("idle")
	
	# Auto-load resource jika null (Fallback)
	if not dialogue_resource:
		if ResourceLoader.exists("res://tina_dialogue.dialogue"):
			dialogue_resource = load("res://tina_dialogue.dialogue")
		elif ResourceLoader.exists("res://npc_dialogue.dialogue"):
			dialogue_resource = load("res://npc_dialogue.dialogue")
	
	# Connect to dialogue signals
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func choose(array):
	array.shuffle()
	return array.front()

# Input handling for dialogue
func _input(event):
	if event.is_action_pressed("interact"):
		print("E pressed! player_in_chat_zone=", player_in_chat_zone, " is_chatting=", is_chatting)
		if player_in_chat_zone and !is_chatting:
			start_dialogue()

func start_dialogue():
	print("Starting Tina dialogue...")
	is_chatting = true
	$AnimatedSprite2D.play("idle")

	var dialogue_title = "start"

	# Check quest states (urutan penting!)
	if GameManager.coral_repaired:
		dialogue_title = "ending"
	elif GameManager.quest_failed:
		dialogue_title = "quest_failed"
	elif GameManager.quest_completed:
		# Quest 1 selesai -> Instruksi Shop
		dialogue_title = "quest_completed_first"
	elif GameManager.quest_active:
		if GameManager.can_complete_quest():
			dialogue_title = "quest_ready_complete"
		else:
			dialogue_title = "quest_in_progress"
	# Else: use "start" untuk new quest

	if dialogue_resource:
		print("Tina dialogue showing: ", dialogue_title)
		# Use DialogueManager's main API
		DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_title)
		is_chatting = true
	else:
		print("ERROR: dialogue_resource is null!")
		is_chatting = false

func _on_dialogue_ended(_resource):
	print("Tina dialogue ended")
	is_chatting = false

func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	print("Body entered Tina zone: ", body.name)
	if body.has_method("Player") or body.is_in_group("player"):
		player = body
		player_in_chat_zone = true

func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("Player") or body.is_in_group("player"):
		player_in_chat_zone = false


func _on_timer_timeout() -> void:
	pass # Replace with function body.
