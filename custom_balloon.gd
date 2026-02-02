extends CanvasLayer

# Custom Dialogue Balloon untuk Dialogue Manager
# Style: Full screen dengan background gelap (seperti narration)

@onready var bg_rect: ColorRect = $BackgroundRect
@onready var character_label: Label = $CharacterLabel
@onready var text_label: RichTextLabel = $TextLabel
@onready var response_container: VBoxContainer = $ResponseContainer

var resource: DialogueResource
var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		dialogue_line = next_dialogue_line
		
		if not dialogue_line:
			queue_free()
			return
		
		# Update character name
		if character_label:
			if dialogue_line.character:
				character_label.text = dialogue_line.character
				character_label.visible = true
			else:
				character_label.visible = false
		
		# Update text dengan typewriter effect
		if text_label:
			text_label.text = ""
			var final_text = "[center]" + dialogue_line.text + "[/center]"
			text_label.text = final_text
		
		# Handle responses (choices)
		if response_container:
			for child in response_container.get_children():
				child.queue_free()
			
			for response in dialogue_line.responses:
				var button = Button.new()
				button.text = response.text
				button.pressed.connect(func(): _on_response_selected(response))
				response_container.add_child(button)
			
			response_container.visible = dialogue_line.responses.size() > 0

func _ready():
	# Hide initially
	visible = false

func _input(event):
	# Continue dialogue on any key/click (if no choices)
	if visible and dialogue_line:
		if dialogue_line.responses.size() == 0:
			if event is InputEventKey or event is InputEventMouseButton:
				if event.pressed:
					_continue_dialogue()

func _continue_dialogue():
	DialogueManager.show_next_dialogue_line(dialogue_line, resource)

func _on_response_selected(response):
	DialogueManager.show_next_dialogue_line(response.next_id, resource)
