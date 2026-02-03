extends Node

# Quest State
var quest_active: bool = false
var quest_completed: bool = false
var quest_failed: bool = false
var quest_times_completed: int = 0

# Trash Collection
var trash_count: int = 0
var target_trash: int = 10

# Timer
var quest_time_limit: float = 180.0  # 3 minutes default
var time_remaining: float = 0.0
var timer_active: bool = false

# Score
var score: int = 0

# === COIN SYSTEM ===
var coins: int = 0
const SAVE_PATH = "user://coins.txt"
const QUEST_REWARD = 100  # Coin reward per quest

# Spawn Position Management
var spawn_at_bridge: bool = false
var intro_shown: bool = false

# === INVENTORY (Simple) ===
var inventory = {
	"besi": 0,
	"pasir": 0,
	"cable_ties": 0
}

# Signals
signal quest_started(spawn_count: int)
signal trash_collected(new_count: int)
signal quest_completed_signal
signal quest_failed_signal
signal timer_updated(time_left: float)
signal coins_updated(new_amount: int)
signal item_purchased(item_name: String)
signal inventory_updated() # New Signal

# ... (process & quest functions unchanged)

# === INVENTORY FUNCTIONS ===
func add_item(item_name: String, amount: int = 1) -> void:
	if inventory.has(item_name):
		inventory[item_name] += amount
		print("[GameManager] Added to inventory: ", item_name, " x", amount)
		inventory_updated.emit() # Emit signal

func remove_item(item_name: String, amount: int = 1) -> bool:
	if inventory.has(item_name) and inventory[item_name] >= amount:
		inventory[item_name] -= amount
		inventory_updated.emit() # Emit signal
		return true
	return false

func has_item(item_name: String, amount: int = 1) -> bool:
	return inventory.has(item_name) and inventory[item_name] >= amount

func has_coral_materials() -> bool:
	return has_item("besi") and has_item("pasir") and has_item("cable_ties")

func use_coral_materials() -> bool:
	if has_coral_materials():
		remove_item("besi")
		remove_item("pasir")
		remove_item("cable_ties")
		print("[GameManager] Coral materials used!")
		return true
	return false

# === COIN FUNCTIONS ===
func add_coins(amount: int) -> void:
	coins += amount
	coins_updated.emit(coins)
	save_coins()
	print("[GameManager] Coins added: +", amount, " Total: ", coins)

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		coins_updated.emit(coins)
		save_coins()
		print("[GameManager] Coins spent: -", amount, " Remaining: ", coins)
		return true
	else:
		print("[GameManager] Not enough coins! Have: ", coins, " Need: ", amount)
		return false

func save_coins() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(str(coins))
		file.close()
		print("[GameManager] Coins saved to file")

func load_coins() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			coins = int(file.get_as_text())
			file.close()
			print("[GameManager] Coins loaded: ", coins)

func _ready() -> void:
	load_coins()

func _unhandled_input(event: InputEvent) -> void:
	# DEBUG: Print inventory when 'I' is pressed
	if event is InputEventKey and event.pressed and event.keycode == KEY_I:
		print_inventory_debug()

func print_inventory_debug() -> void:
	print("\n=== 🎒 CURRENT INVENTORY ===")
	print("Coins: ", coins)
	for item in inventory:
		var count = inventory[item]
		if count > 0:
			print("- ", item.capitalize(), ": ", count)
	print("==========================\n")
