extends Node

# Quest State
var quest_active: bool = false
var quest_completed: bool = false
var quest_times_completed: int = 0  # Track how many times quest completed

# Trash Collection
var trash_count: int = 0
var target_trash: int = 10

# Score
var score: int = 0

# Signals
signal quest_started(spawn_count: int)
signal trash_collected(new_count: int)
signal quest_completed_signal

func start_quest() -> void:
	quest_active = true
	quest_completed = false
	trash_count = 0
	
	# Determine target based on how many times completed
	if quest_times_completed == 0:
		target_trash = 10
	else:
		target_trash = 20
	
	# Emit signal with spawn count (always 20 for easy finding)
	quest_started.emit(20)
	print("[GameManager] Quest started! Target: ", target_trash)

func collect_trash() -> void:
	if quest_active and not quest_completed and trash_count < target_trash:
		trash_count += 1
		trash_collected.emit(trash_count)
		print("[GameManager] Trash collected: ", trash_count, "/", target_trash)

func complete_quest() -> void:
	if quest_active and trash_count >= target_trash:
		quest_completed = true
		quest_active = false
		score += 100
		quest_times_completed += 1
		quest_completed_signal.emit()
		print("[GameManager] Quest completed! Score: ", score, " Times: ", quest_times_completed)

func reset_quest() -> void:
	quest_active = false
	quest_completed = false
	trash_count = 0
	print("[GameManager] Quest reset")

func can_complete_quest() -> bool:
	return quest_active and trash_count >= target_trash

func can_take_new_quest() -> bool:
	# Can take quest if not active and completed less than 2 times (10 + 20)
	return not quest_active and quest_times_completed < 2

func all_quests_done() -> bool:
	return quest_times_completed >= 2
