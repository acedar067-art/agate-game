extends Label

func _ready() -> void:
	# Connect to GameManager signal
	GameManager.coins_updated.connect(update_display)
	
	# Initial Display
	update_display(GameManager.coins)

func update_display(amount: int) -> void:
	text = "Koin: " + str(amount)
