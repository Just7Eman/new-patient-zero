extends HBoxContainer

@onready var timer_progress_bar: ProgressBar = %TimerProgressBar
@onready var timer_label: Label = %TimerLabel

@export var duration: float = 5.0

var timer: float = 0.0

func _process(delta: float) -> void:
	if timer > 0:
		timer -= delta
		timer_progress_bar.value = timer
		timer_label.text = str(snapped(timer, 0.1))
		
func _on_start_timer_button_pressed() -> void:
	timer_progress_bar.max_value = duration
	timer = duration
