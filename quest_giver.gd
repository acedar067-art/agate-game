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
	$Timer.start()
	$AnimatedSprite2D.play("idle_quest)giver")  # Always play idle animation

func choose(array):
	array.shuffle()
	return array.front()

# No movement logic needed
func move(delta):
	pass

# Input handling for dialogue
func _input(event):
	if event.is_action_pressed("interact"):
		print("E pressed! player_in_chat_zone=", player_in_chat_zone, " is_chatting=", is_chatting)
		if player_in_chat_zone and !is_chatting:
			start_dialogue()

func start_dialogue():
	print("Starting dialogue...")
	is_chatting = true
	$AnimatedSprite2D.play("idle_quest)giver")  # Ensure idle animation is playing

	var dialogue_title = "start"

	if GameManager.all_quests_done():
		dialogue_title = "all_quests_done"
	elif GameManager.quest_completed:
		if GameManager.quest_times_completed == 1:
			dialogue_title = "quest_completed_first"
	elif GameManager.quest_active:
		if GameManager.can_complete_quest():
			dialogue_title = "quest_ready_complete"
		else:
			dialogue_title = "quest_in_progress"
	elif not GameManager.can_take_new_quest():
		dialogue_title = "all_quests_done"

	if dialogue_resource:
		print("Dialogue resource found, showing: ", dialogue_title)
		DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_title)
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	else:
		print("ERROR: dialogue_resource is null!")

func _on_dialogue_ended(_resource):
	print("Dialogue ended")
	is_chatting = false
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name, " has Player method: ", body.has_method("Player"), " in player group: ", body.is_in_group("player"))
	if body.has_method("Player") or body.is_in_group("player"):
		player = body
		player_in_chat_zone = true

func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("Player") or body.is_in_group("player"):
		player_in_chat_zone = false

func _on_timer_timeout() -> void:
	# Still cycles states, but doesn't move
	current_state = IDLE
	$Timer.wait_time = choose([0.5, 1, 1.5, 2.0])
