extends CanvasLayer

# Narration Manager
# Full-screen narration untuk intro & ending

@onready var bg_rect: ColorRect = $BackgroundRect
@onready var text_label: RichTextLabel = $TextLabel
@onready var continue_label: Label = $ContinueLabel

var narration_lines: Array = []
var current_line: int = 0
var is_active: bool = false
var on_complete_callback: Callable

# Narration presets
var intro_narration = [
	"Di sebuah desa kecil yang damai...",
	"Udara mulai tercemar oleh asap dan limbah.",
	"Laut yang dulu jernih, kini dipenuhi sampah.",
	"Koral-koral di dasar laut rusak dan mati.",
	"",
	"Tina, penjaga alam, membutuhkan bantuanmu.",
	"Bisakah kamu menyelamatkan desa ini?",
]

var ending_poem = [
	"🌿 Puisi untuk Pahlawan Alam 🌿",
	"",
	"Di bawah langit yang kembali cerah,",
	"Udara segar, tanpa lagi keluh kesah.",
	"",
	"Sampah-sampah telah kau bersihkan,",
	"Koral-koral pun telah diperbaiki dengan penuh kesabaran.",
	"",
	"Alam tersenyum, berbisik lembut,",
	"\"Terima kasih, pahlawan sejati yang teguh.\"",
	"",
	"Jagalah alam, karena ia adalah rumah kita,",
	"Untuk hari ini, esok, dan selamanya.",
	"",
	"- Tina, Penjaga Alam",
]

func _ready():
	visible = false

func _input(event):
	if is_active:
		if event is InputEventKey or event is InputEventMouseButton:
			if event.pressed:
				next_line()

func show_intro():
	show_narration(intro_narration, func(): 
		print("[Narration] Intro complete")
		# Mulai game setelah intro
	)

func show_ending():
	show_narration(ending_poem, func():
		print("[Narration] Ending complete")
		# Kembali ke menu atau credits
	)

func show_narration(lines: Array, on_complete: Callable = Callable()):
	narration_lines = lines
	current_line = 0
	on_complete_callback = on_complete
	is_active = true
	visible = true
	
	# Freeze player movement
	get_tree().paused = true
	
	display_current_line()

func display_current_line():
	if current_line < narration_lines.size():
		var line = narration_lines[current_line]
		
		# Animate text (typewriter effect bisa ditambahkan)
		if text_label:
			text_label.text = "[center]" + line + "[/center]"
		
		# Show continue hint
		if continue_label:
			continue_label.visible = true
	else:
		finish_narration()

func next_line():
	current_line += 1
	display_current_line()

func finish_narration():
	is_active = false
	visible = false
	get_tree().paused = false
	
	if on_complete_callback and on_complete_callback.is_valid():
		on_complete_callback.call()
	
	print("[Narration] Finished")

func skip_narration():
	finish_narration()
