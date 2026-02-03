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
	# Hide shop initially
	visible = false
	
	# Connect buttons
	if besi_btn:
		besi_btn.pressed.connect(func(): buy_item("besi"))
	if pasir_btn:
		pasir_btn.pressed.connect(func(): buy_item("pasir"))
	if cable_btn:
		cable_btn.pressed.connect(func(): buy_item("cable_ties"))
	if close_btn:
		close_btn.pressed.connect(close_shop)
	
	# Connect to coin updates
	GameManager.coins_updated.connect(_on_coins_updated)
	
	update_ui()

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

func close_shop() -> void:
	is_open = false
	visible = false
	
	# Force hide Panel juga
	var panel = get_node_or_null("Panel")
	if panel:
		panel.visible = false
		panel.modulate.a = 1.0  # Reset alpha
	
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
		show_message("Berhasil membeli " + item.name + "!")
		update_ui()
	else:
		show_message("Coin tidak cukup! Butuh " + str(price) + " coins")

func update_ui() -> void:
	# Update coin display
	if coin_label:
		coin_label.text = "Coins: " + str(GameManager.coins)
	
	# Update button texts with prices and owned count
	if besi_btn:
		var owned = GameManager.inventory.besi
		besi_btn.text = " [" + str(owned) + "]"
	if pasir_btn:
		var owned = GameManager.inventory.pasir
		pasir_btn.text = "[" + str(owned) + "]"
	if cable_btn:
		var owned = GameManager.inventory.cable_ties
		cable_btn.text = " [" + str(owned) + "]"

func show_message(msg: String) -> void:
	if message_label:
		message_label.text = msg
		# Auto clear after 2 seconds
		await get_tree().create_timer(2.0).timeout
		if message_label:
			message_label.text = ""

func _on_coins_updated(_new_amount: int) -> void:
	update_ui()
