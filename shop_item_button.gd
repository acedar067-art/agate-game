extends Button

# Script untuk menghandle logika pembelian per item
# Attach script ini ke button di Shop

@export var item_id: String = "besi"  # id di inventory
@export var item_name: String = "Besi"
@export var price: int = 20
@export var icon_texture: Texture2D

func _ready() -> void:
	# Setup visual otomatis
	custom_minimum_size = Vector2(100, 100)
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	expand_icon = true
	
	if icon_texture:
		icon = icon_texture
	
	# Connect signal
	pressed.connect(_on_pressed)
	
	# Connect to signals global
	GameManager.coins_updated.connect(_on_coins_updated)
	GameManager.inventory_updated.connect(_on_inventory_updated) # Kita perlu signal ini di GM?
	# Note: GM mungkin belum punya signal inventory_updated, kita pakai process atau check manual saat coin update
	
	update_text()
	
	# Hindari text double (hide child labels if any)
	for child in get_children():
		if child is Label or child is TextureRect:
			child.visible = false

func _on_pressed() -> void:
	if GameManager.spend_coins(price):
		GameManager.add_item(item_id)
		# Feedback visual & Audio
		if Engine.has_singleton("AudioManager") or get_tree().root.has_node("AudioManager"):
			AudioManager.play_sfx("buy")
			
		print("Bought ", item_name)
		update_text()
	else:
		if Engine.has_singleton("AudioManager") or get_tree().root.has_node("AudioManager"):
			AudioManager.play_sfx("error")
			
		print("Not enough coins for ", item_name)
		# Optional: Shake animation or red flash

func _on_coins_updated(_coins: int) -> void:
	update_text()

func _on_inventory_updated() -> void:
	update_text()

func update_text() -> void:
	var count = 0
	if GameManager.inventory.has(item_id):
		count = GameManager.inventory[item_id]
	
	text = "%s (%d C)\n[%d]" % [item_name, price, count]
