extends Node2D

var max_o2: float = 60.0
var current_o2: float = 60.0
var drain_rate: float = 1.0
var is_active: bool = false

signal o2_changed(value: float)
signal o2_depleted
signal o2_low_warning

var _warning_emitted: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta: float) -> void:
	if not is_active:
		return
	
	current_o2 -= drain_rate * delta
	current_o2 = clampf(current_o2, 0.0, max_o2)
	
	var frame_index = int(round((current_o2 / max_o2) * 11))
	frame_index = clampi(frame_index, 0, 11)
	anim.frame = frame_index
	
	o2_changed.emit(current_o2)
	
	# Threshold warning: O₂ < 25%
	if current_o2 / max_o2 <= 0.25 and not _warning_emitted:
		o2_low_warning.emit()
		_warning_emitted = true
	
	# Reset flag jika O₂ naik lagi (misal future upgrade)
	if current_o2 / max_o2 > 0.25:
		_warning_emitted = false
	
	if current_o2 <= 0.0:
		is_active = false
		o2_depleted.emit()

func start_oxygen() -> void:
	current_o2 = max_o2
	is_active = true
	_warning_emitted = false
	anim.frame = 11

func stop_oxygen() -> void:
	is_active = false
