extends CanvasLayer

# Simple Intro Screen
# Klik dimana saja untuk lanjut ke dunia

@onready var text_label: RichTextLabel = $TextLabel

var lines = [
	"Di sebuah desa kecil yang damai...",
	"Udara mulai tercemar oleh asap dan limbah.",
	"Laut yang dulu jernih, kini dipenuhi sampah.",
	"",
	"Tina, penjaga alam, membutuhkan bantuanmu.",
	"Bisakah kamu menyelamatkan desa ini?",
	"",
	"[Tekan tombol apa saja untuk mulai]"
]

var current_line = 0

func _ready():
	display_line()

func _input(event):
	if event is InputEventKey and event.pressed:
		next_line()
	elif event is InputEventMouseButton and event.pressed:
		next_line()

func display_line():
	if current_line < lines.size():
		var text = "[center]" + lines[current_line] + "[/center]"
		text_label.text = text
	else:
		# Habis - load dunia
		go_to_dunia()

func next_line():
	current_line += 1
	if current_line >= lines.size():
		go_to_dunia()
	else:
		display_line()

func go_to_dunia():
	print("[IntroScreen] Loading dunia.tscn")
	get_tree().change_scene_to_file("res://dunia.tscn")
