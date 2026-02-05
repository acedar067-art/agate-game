extends Node

# Preload Audio Files (Sesuaikan dengan nama file Anda di folder audio)
var sfx_library = {
	"pickup": preload("res://audio/ngambil sampah.wav"),
	"success": preload("res://audio/succes.wav"),
	"click": preload("res://audio/tapclick.wav"),
	"buy": preload("res://audio/beli item.wav"),
	"error": preload("res://audio/error.wav"),
	"repair": preload("res://audio/repaircoral.wav")
}

var bgm_library = {
	"main_theme": preload("res://audio/backsound_lofi.mp3")
}

# Players
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	# Setup Music Player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master" # Use Master bus to ensure sound
	add_child(music_player)
	
	# Setup Pool of SFX Players (supaya bisa bunyi bebarengan)
	for i in range(5):
		var p = AudioStreamPlayer.new()
		p.bus = "Master" # Use Master bus
		add_child(p)
		sfx_players.append(p)
	
	print("[AudioManager] Initialized. Playing BGM...")
	# Auto play BGM start
	play_music("main_theme")

# --- FUNCTIONS ---

func play_music(track_name: String) -> void:
	if bgm_library.has(track_name):
		var stream = bgm_library[track_name]
		if music_player.stream != stream:
			music_player.stream = stream
			music_player.play()
	else:
		print("[AudioManager] Music track not found: ", track_name)

func play_sfx(sfx_name: String) -> void:
	if sfx_library.has(sfx_name):
		var stream = sfx_library[sfx_name]
		_play_stream_on_available_player(stream)
	else:
		print("[AudioManager] SFX not found: ", sfx_name)

func _play_stream_on_available_player(stream: AudioStream) -> void:
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	
	# Jika semua sibuk, paksa player pertama (overwrite)
	sfx_players[0].stream = stream
	sfx_players[0].play()
