extends CharacterBody2D

const KECEPATAN = 130
var state: State
var states = {}
var vel = Vector2.ZERO
var arah_terakhir = Vector2.RIGHT
var can_move: bool = true  # Flag untuk kontrol movement

func _ready():
	# load states
	states["idle"] = load("res://states/IdleState.gd").new()
	states["jalan"] = load("res://states/JalanState.gd").new()
	states["serang"] = load("res://states/SerangState.gd").new()

	# kasih referensi player ke setiap state
	for s in states.values():
		s.player = self

	change_state("idle")
	
	# Connect ke DialogueManager signals
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
func get_animasi():
	return $AnimatedSprite2D
	
func change_state(new_state):
	if state:
		state.exit()
	if states.has(new_state):
		state = states[new_state]
		state.enter()

func _input(event):
	if can_move:
		state.handle_input(event)

func _process(delta):
	if can_move:
		state.update(delta)

func _physics_process(delta):
	if can_move:
		state.physics_update(delta)
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _on_dialogue_started(_resource) -> void:
	can_move = false
	velocity = Vector2.ZERO
	change_state("idle")
	print("[Player] Dialogue started - movement disabled")

func _on_dialogue_ended(_resource) -> void:
	can_move = true
	print("[Player] Dialogue ended - movement enabled")
