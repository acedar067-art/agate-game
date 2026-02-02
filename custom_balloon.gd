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
			# Dialogue selesai - close balloon
			print("[CustomBalloon] Dialogue finished, closing balloon")
			_close_balloon()
			return
		
		# Show balloon when dialogue starts
		visible = true
		print("[CustomBalloon] Showing line: ", dialogue_line.text)
		
		# Update character name
		if character_label:
			if dialogue_line.character:
				character_label.text = dialogue_line.character
				character_label.visible = true
			else:
				character_label.visible = false
		
		# Update text
		if text_label:
			text_label.text = ""
			var final_text = "[center]" + dialogue_line.text + "[/center]"
			text_label.text = final_text
		
		# Handle responses (choices)
		if response_container:
			for child in response_container.get_children():
				child.queue_free()
			
			if dialogue_line.responses.size() > 0:
				print("[CustomBalloon] ", dialogue_line.responses.size(), " choices available")
				for response in dialogue_line.responses:
					var button = Button.new()
					button.text = response.text
					button.pressed.connect(func(): _on_response_selected(response))
					response_container.add_child(button)
				response_container.visible = true
			else:
				response_container.visible = false
				print("[CustomBalloon] No choices - click to continue")

func _ready():
	# Start hidden
	visible = false
	print("[CustomBalloon] Ready")

func _unhandled_input(event):
	# Continue dialogue on any key/click (if no choices)
	if not visible or not dialogue_line:
		return
	
	if dialogue_line.responses.size() == 0:
		if event is InputEventKey and event.pressed:
			print("[CustomBalloon] Key pressed - continuing dialogue")
			_continue_dialogue()
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.pressed:
			print("[CustomBalloon] Mouse clicked - continuing dialogue")
			_continue_dialogue()
			get_viewport().set_input_as_handled()

func _continue_dialogue():
	if resource and dialogue_line:
		print("[CustomBalloon] Requesting next dialogue line")
		DialogueManager.show_next_dialogue_line(dialogue_line, resource)

func _on_response_selected(response):
	print("[CustomBalloon] Response selected: ", response.text)
	DialogueManager.show_next_dialogue_line(response.next_id, resource)

func _close_balloon():
	print("[CustomBalloon] Closing balloon")
	visible = false
	
	# Wait a frame before queue_free to ensure cleanup
	await get_tree().process_frame
	queue_free()
