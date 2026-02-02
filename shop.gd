extends Area2D

# Shop Interaction Script
# Membuka shop UI saat player masuk area + tekan B

@export var shop_ui_scene: PackedScene
@onready var shop_gui = null

var player_in_area = false
var is_shop_open = false
var player_ref = null

func _ready():
	# Cek apakah shop UI sudah ada di scene (sebagai CanvasLayer)
	# Jika belum, instantiate
	if shop_ui_scene:
		shop_gui = shop_ui_scene.instantiate()
		get_tree().root.add_child.call_deferred(shop_gui)
		shop_gui.visible = false
		print("[Shop] Shop UI instantiated from scene")
	else:
		# Coba cari node ShopManager yang mungkin sudah ada
		shop_gui = get_node_or_null("/root/dunia/shop_manager")
		if not shop_gui:
			print("[Shop] ERROR: Shop UI scene not assigned and not found in tree!")
			print("[Shop] Trying alternative paths...")
			# Try alternative paths
			shop_gui = get_tree().root.get_node_or_null("shop_manager")
			if shop_gui:
				print("[Shop] Found shop_manager at root level")
		else:
			print("[Shop] Found existing shop_manager in scene")

	# Connect signals area
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event):
	if player_in_area and event is InputEventKey:
		if event.pressed and event.keycode == KEY_B:
			toggle_shop()

func _process(_delta):
	# Jika shop terbuka, cek input close di script manager,
	# tapi kita juga monitor state visible-nya
	if is_shop_open and shop_gui and not shop_gui.visible:
		close_shop() # Sync state jika ditutup dari UI button

func toggle_shop():
	if is_shop_open:
		close_shop()
	else:
		open_shop()

func open_shop():
	if not shop_gui:
		print("[Shop] ERROR: shop_gui is null! Cannot open shop.")
		return
		
	is_shop_open = true
	
	# Try to call open_shop if method exists
	if shop_gui.has_method("open_shop"):
		shop_gui.open_shop()
	else:
		# Fallback: just show the GUI
		shop_gui.visible = true
		print("[Shop] Fallback: setting visible = true")
	
	# Disable player movement
	if player_ref:
		player_ref.can_move = false
		player_ref.velocity = Vector2.ZERO
		# Optional: Play idle animation
		if player_ref.has_method("change_state"):
			player_ref.change_state("idle")
	
	print("[Shop] Player opened shop (visible: ", shop_gui.visible, ")")

func close_shop():
	is_shop_open = false
	if shop_gui:
		shop_gui.close_shop()
	
	# Enable player movement
	if player_ref:
		player_ref.can_move = true
	
	print("[Shop] Player closed shop")

func _on_body_entered(body):
	if body.name == "player" or body.is_in_group("player"):
		player_in_area = true
		player_ref = body
		print("[Shop] Player entered shop area - Press B to open")

func _on_body_exited(body):
	if body.name == "player" or body.is_in_group("player"):
		player_in_area = false
		if is_shop_open:
			close_shop()
		player_ref = null
