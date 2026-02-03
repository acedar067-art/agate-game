extends Node

# Narration Trigger
# Handles intro, ending, and transition narrations

@export var narration_resource: DialogueResource

func _ready():
	# Auto-load resource jika belum di-assign di inspector
	if not narration_resource:
		narration_resource = load("res://narration.dialogue")

func show_intro():
	if narration_resource:
		print("[Narration] Showing intro")
		DialogueManager.show_dialogue_balloon(narration_resource, "intro_start")

func show_ending():
	if narration_resource:
		print("[Narration] Showing ending poem")
		DialogueManager.show_dialogue_balloon(narration_resource, "ending_poem")

func show_go_to_sea():
	if narration_resource:
		print("[Narration] Showing go to sea dialogue")
		DialogueManager.show_dialogue_balloon(narration_resource, "go_to_sea")

# Call from other scripts:
# get_node("/root/Dunia/NarrationTrigger").show_intro()
