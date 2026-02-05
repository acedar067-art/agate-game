extends CanvasLayer

# Shop Manager
# Handles shop UI and purchasing items

# Shop items configuration
var shop_items = {
	"besi": {"name": "Besi", "price": 20, "description": "Material untuk repair koral"},
	"pasir": {"name": "Pasir", "price": 15, "description": "Material untuk repair koral"},
	"cable_ties": {"name": "Cable Ties", "price": 10, "description": "Material untuk repair koral"}
}

# UI References (assign di Inspector atau via code)
@onready var coin_label: Label = $Panel/CoinLabel
@onready var besi_btn: Button = $Panel/BesiButton
@onready var pasir_btn: Button = $Panel/PasirButton
@onready var cable_btn: Button = $Panel/CableButton
@onready var close_btn: Button = $Panel/CloseButton
@onready var message_label: Label = $Panel/MessageLabel

var is_open: bool = false

func _ready() -> void:
	# Ensure Shop UI is always on top and active
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Hide shop initially
	visible = false
	
	# Configure Buttons (Component Based)
	setup_button(besi_btn, "res://Gemini_Generated_Image_ur85juur85juur85-removebg-preview.png", "besi", 20, "Besi")
	setup_button(pasir_btn, "res://Gemini_Generated_Image_4fmj6s4fmj6s4fmj-removebg-preview.png", "pasir", 15, "Pasir")
	setup_button(cable_btn, "res://Gemini_Generated_Image_qko9c1qko9c1qko9-removebg-preview.png", "cable_ties", 10, "Cable")
	
	if close_btn:
		close_btn.pressed.connect(close_shop)
	
	# Connect to coin updates
	GameManager.coins_updated.connect(_on_coins_updated)
	
	update_ui()

func setup_button(btn: Button, icon_path: String, item_id: String, price: int, item_name: String) -> void:
	if not btn: return
	
	# ATTACH CUSTOM SCRIPT DYNAMICALLY
	# Ini cara agar button punya logic sendiri sesuai request
	var component_script = load("res://shop_item_button.gd")
	if not btn.get_script(): # Only attach if not already attached
		btn.set_script(component_script)
		
	# Configure properties on the new script instance
	# Karena script baru di-attach, kita akses property-nya
	btn.item_id = item_id
	btn.item_name = item_name
	btn.price = price
	
	if ResourceLoader.exists(icon_path):
		btn.icon_texture = load(icon_path)
		
	# Trigger ready manual jika perlu, atau biarkan engine handle saat tree enter
	# Tapi karena node sudah di tree, _ready mungkin sudah lewat. 
	# Kita panggil func setup manual atau re-trigger _ready safely?
	# Script replacement di runtime agak tricky untuk _ready.
	# Mari kita panggil method manual jika ada.
	if btn.has_method("_ready"):
		btn._ready()

# ... (rest of code)

func update_ui() -> void:
	# Update coin display
	if coin_label:
		coin_label.text = "Coins: " + str(GameManager.coins)
	
	# Update button texts with prices and owned count
	if besi_btn:
		var owned = GameManager.inventory.besi
		besi_btn.text = "Besi (20 C) [" + str(owned) + "]"
	if pasir_btn:
		var owned = GameManager.inventory.pasir
		pasir_btn.text = "Pasir (15 C) [" + str(owned) + "]"
	if cable_btn:
		var owned = GameManager.inventory.cable_ties
		cable_btn.text = "Cable Ties (10 C) [" + str(owned) + "]"

# Input handling removed - handled by shop.gd interaction area

func toggle_shop() -> void:
	if is_open:
		close_shop()
	else:
		open_shop()

func open_shop() -> void:
	is_open = true
	visible = true
	
	# Make sure Panel is visible too
	var panel = get_node_or_null("Panel")
	if panel:
		panel.visible = true
	
	update_ui()
	get_tree().paused = false  # Atau true jika mau pause game
	print("[Shop] Shop opened")

signal shop_closed

# ...

func close_shop() -> void:
	is_open = false
	visible = false
	
	# Force hide Panel juga
	var panel = get_node_or_null("Panel")
	if panel:
		panel.visible = false
		panel.modulate.a = 1.0  # Reset alpha
	
	shop_closed.emit()
	print("[Shop] Shop closed")

func buy_item(item_id: String) -> void:
	if not shop_items.has(item_id):
		show_message("Item tidak ditemukan!")
		return
	
	var item = shop_items[item_id]
	var price = item.price
	
	if GameManager.spend_coins(price):
		GameManager.add_item(item_id)
		GameManager.item_purchased.emit(item_id)
		
		AudioManager.play_sfx("buy")
		show_message("Berhasil membeli " + item.name + "!")
		update_ui()
	else:
		AudioManager.play_sfx("error")
		show_message("Coin tidak cukup! Butuh " + str(price) + " coins")



func show_message(msg: String) -> void:
	if message_label:
		message_label.text = msg
		# Auto clear after 2 seconds
		await get_tree().create_timer(2.0).timeout
		if message_label:
			message_label.text = ""

func _on_coins_updated(_new_amount: int) -> void:
	update_ui()
