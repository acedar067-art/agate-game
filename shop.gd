extends Area2D

# Shop Interaction Script
# Membuka shop UI saat player masuk area + tekan B

@export var shop_ui_path: NodePath = "/root/dunia/shop_manager" # Default path
var shop_gui = null
var player_in_area = false

func _ready():
	# Tunggu sebentar untuk pastikan scene tree ready
	await get_tree().process_frame
	
	# Cari shop GUI yang sudah ada di scene (CanvasLayer)
	if has_node(shop_ui_path):
		shop_gui = get_node(shop_ui_path)
	else:
		# Fallback search
		shop_gui = get_tree().root.find_child("shop_manager", true, false)
	
	if shop_gui:
		print("[Shop] Connected to Shop UI: ", shop_gui.name)
		# Listen to UI closing signal
		if shop_gui.has_signal("shop_closed"):
			shop_gui.shop_closed.connect(_on_shop_closed_from_ui)
	else:
		print("[Shop] ERROR: shop_manager UI not found in scene!")

	# Connect signals area
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

var player_ref = null

func _unhandled_input(event):
	if player_in_area and event.is_action_pressed("interact_shop") or (event is InputEventKey and event.pressed and event.keycode == KEY_B):
		toggle_shop()

func toggle_shop():
	if not shop_gui: return
	
	if shop_gui.visible:
		close_shop()
	else:
		open_shop()

func open_shop():
	shop_gui.open_shop()
	
	# Freeze player
	var p = player_ref
	if not p:
		# Fallback: cari player di group "player"
		p = get_tree().get_first_node_in_group("player")
	if not p:
		# Fallback 2: cari node bernama "player" di root
		p = get_tree().root.find_child("player", true, false)
		
	if p:
		print("[Shop] Freezing player movement (verified)")
		# Simpan ref agar unfreeze bisa pakai ref yang sama
		player_ref = p
		
		# Set property
		p.set("can_move", false)
		p.set("velocity", Vector2.ZERO)
		
		# Call method state change if exists
		if p.has_method("change_state"):
			p.change_state("idle")
	else:
		print("[Shop] CRITICAL ERROR: Player node NOT found! Cannot freeze.")

func close_shop():
	shop_gui.close_shop()
	
	# Unfreeze player
	if player_ref:
		print("[Shop] Unfreezing player movement")
		player_ref.set("can_move", true)
	else:
		# Fallback unfreeze (just in case ref lost)
		var p = get_tree().get_first_node_in_group("player")
		if p: p.set("can_move", true)

func _on_body_entered(body):
	if body.name == "player" or body.is_in_group("player"):
		player_in_area = true
		player_ref = body
		print("[Shop] Press B to open shop")

func _on_body_exited(body):
	if body.name == "player" or body.is_in_group("player"):
		player_in_area = false
		if shop_gui and shop_gui.visible:
			close_shop()
		player_ref = null

func _on_shop_closed_from_ui() -> void:
	# Called when X button pressed in UI
	# Only unfreeze, don't call close_shop() recursively
	
	# Unfreeze player
	if player_ref:
		print("[Shop] Shop UI closed via X - Unfreezing player")
		player_ref.set("can_move", true)
	else:
		var p = get_tree().get_first_node_in_group("player")
		if p: p.set("can_move", true)
