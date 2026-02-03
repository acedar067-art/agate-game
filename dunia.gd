extends Node2D

func _ready() -> void:
	# Tunggu sebentar agar loading selesai
	await get_tree().create_timer(1.0).timeout
	
	# Panggil intro narration
	var trigger = get_node_or_null("NarrationTrigger")
	if trigger:
		trigger.show_intro()
	else:
		print("WARNING: NarrationTrigger node not found in dunia.tscn")

func _process(delta: float) -> void:
	pass
