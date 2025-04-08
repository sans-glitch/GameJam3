extends Node
#class_name Stopwatch
#
#const STOPWATCH_SCENE = preload("res://scenes/stopwatch.tscn")
var time : float = 0.0
var stopped : bool = false

func _physics_process(delta: float) -> void:
	if stopped:
		return
	time += delta
	
func reset():
	time = 0.0

func get_time_string() -> String:
	var sec = fmod(time, 60)
	var min = time / 60
	var format_string = "%02d : %02d"
	var time_string = format_string % [min, sec]
	return time_string

#static func new_stopwatch(stopped : bool) -> Stopwatch:
	#var sw = STOPWATCH_SCENE.instantiate()
	#sw.stopped = stopped
	#return sw
