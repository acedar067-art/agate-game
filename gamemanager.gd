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

func _process(delta: float) -> void:
	if timer_active and quest_active:
		time_remaining -= delta
		timer_updated.emit(time_remaining)
		
		if time_remaining <= 0:
			fail_quest()

func start_quest() -> void:
	quest_active = true
	quest_completed = false
	quest_failed = false
	trash_count = 0
	
	# Determine target based on how many times completed
	if quest_times_completed == 0:
		target_trash = 10
		quest_time_limit = 180.0  # 3 minutes for first quest
	else:
		target_trash = 20
		quest_time_limit = 300.0  # 5 minutes for second quest
	
	# Start timer
	time_remaining = quest_time_limit
	timer_active = true
	
	# Emit signal with spawn count
	quest_started.emit(20)
	print("[GameManager] Quest started! Target: ", target_trash, " Time: ", quest_time_limit)

func collect_trash() -> void:
	if quest_active and not quest_completed and not quest_failed and trash_count < target_trash:
		trash_count += 1
		trash_collected.emit(trash_count)
		print("[GameManager] Trash collected: ", trash_count, "/", target_trash)

func complete_quest() -> void:
	if quest_active and trash_count >= target_trash:
		quest_completed = true
		quest_active = false
		timer_active = false
		score += 100
		quest_times_completed += 1
		
		# Give coins as reward
		add_coins(QUEST_REWARD)
		
		AudioManager.play_sfx("success")
		quest_completed_signal.emit()
		print("[GameManager] Quest completed! Coins: ", coins)

func fail_quest() -> void:
	quest_failed = true
	quest_active = false
	timer_active = false
	quest_failed_signal.emit()
	print("[GameManager] Quest failed! Time ran out.")

func reset_quest() -> void:
	quest_active = false
	quest_completed = false
	quest_failed = false
	trash_count = 0
	timer_active = false
	print("[GameManager] Quest reset")

func can_complete_quest() -> bool:
	return quest_active and trash_count >= target_trash

func can_take_new_quest() -> bool:
	return not quest_active and not quest_failed and quest_times_completed < 2

func can_retry_quest() -> bool:
	return quest_failed
	
# all_quests_done already exists below

func get_formatted_time() -> String:
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	return "%d:%02d" % [minutes, seconds]

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
	# DEBUG: Print inventory when 'T' is pressed
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		print_inventory_debug()

func all_quests_done() -> bool:
	return quest_times_completed >= 2

func print_inventory_debug() -> void:
	print("\n=== 🎒 CURRENT INVENTORY ===")
	print("Coins: ", coins)
	for item in inventory:
		var count = inventory[item]
		if count > 0:
			print("- ", item.capitalize(), ": ", count)
# === ENDING MECHANIC ===
var coral_repaired: bool = false

func set_coral_repaired() -> void:
	coral_repaired = true
	print("[GameManager] Coral Repaired! Ending unlocked.")

func save_poem_to_txt() -> void:
	var poem_content = """
    === JEJAK KEBAIKAN ===
    
    Di kedalaman laut yang sunyi,
    Ada harapan yang kau beri.
    Sampah yang hilang, karang yang semi,
    Menjaga bumi, tugas yang murni.
    
    Terima kasih, Pahlawan Lingkungan.
    Kebaikanmu abadi, takkan hilang ditelan zaman.
    
    - Tina & Alam Semesta
	"""
	
	# Save to user documents or desktop if possible, but user:// is safest sandbox
	# For Windows "My Documents" access needs OS.get_system_dir which might not be available or sandboxed.
	# We will use user:// first.
	var file = FileAccess.open("user://Puisi_Tina.txt", FileAccess.WRITE)
	if file:
		file.store_string(poem_content)
		file.close()
		
		# Try to open folder so user sees it
		OS.shell_open(ProjectSettings.globalize_path("user://"))
		print("[GameManager] Poem saved. Exiting game...")
		
		# Exit game logic (wait a bit if possible, but immediate works too)
		await get_tree().create_timer(3.0).timeout # Beri waktu 3 detik agar user sadar
		get_tree().quit()
