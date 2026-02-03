extends CanvasLayer

# Air Quality Overlay
# Menampilkan efek visual udara tercemar (gelap/kotor)

@onready var overlay: ColorRect = $ColorRect

# State
var is_polluted: bool = true  # Mulai dengan udara tercemar

# Warna overlay
const POLLUTED_COLOR = Color(0.2, 0.15, 0.1, 0.35)  # Coklat gelap kotor
const CLEAN_COLOR = Color(0, 0, 0, 0)  # Transparan

# Transition speed
const FADE_SPEED = 0.5

var target_color: Color = POLLUTED_COLOR

func _ready() -> void:
	# Connect ke GameManager
	if GameManager.has_signal("quest_completed_signal"):
		GameManager.quest_completed_signal.connect(_on_quest_completed)
	if GameManager.has_signal("quest_failed_signal"):
		GameManager.quest_failed_signal.connect(_on_quest_failed)
	
	# Check initial state based on game progress
	if GameManager.all_quests_done():
		set_polluted(false)
	else:
		set_polluted(true)
	print("[AirQuality] Initialized - Air is polluted")

func _process(delta: float) -> void:
	# Smooth transition warna
	if overlay:
		overlay.color = overlay.color.lerp(target_color, FADE_SPEED * delta * 5)

func set_polluted(polluted: bool) -> void:
	is_polluted = polluted
	if polluted:
		target_color = POLLUTED_COLOR
		print("[AirQuality] Air is now POLLUTED")
	else:
		target_color = CLEAN_COLOR
		print("[AirQuality] Air is now CLEAN")

func _on_quest_completed() -> void:
	# Udara membaik saat quest selesai
	set_polluted(false)

func _on_quest_failed() -> void:
	# Udara tetap kotor saat quest gagal
	set_polluted(true)

# Manual toggle (untuk testing)
func toggle_pollution() -> void:
	set_polluted(not is_polluted)
