extends Node

var curr_level = 1
var furthest_unlocked_level
#@onready var course: Node2D = 


## Gets the clubs available to the player based on the level number.
## Returns an array containing each available club.


func get_curr_level_par():
	var par : Array = [0, 0, 0, 2, 3, 3, 3, 2, 5, 3, 8, 4, 3, 6, 5, 4, 3, 3, 3]
	return par[curr_level]

func get_curr_level_clubs():
	if curr_level == 18:
		return [ "putter", "wedge", "iron"]
	elif curr_level <= 6:
		return ["driver", "putter"]
	elif curr_level <= 11:
		return ["driver", "putter", "wedge"]
	else:
		return ["driver", "putter", "wedge", "iron"]

func get_curr_level_wind():
	if curr_level == 9:
		return Vector2i(-1, 0)
	if curr_level == 10:
		return Vector2i(0, 1)	
	if curr_level == 12:
		return Vector2i(0, -1)	
	if curr_level == 17:
		return Vector2i(-1, 0)		
	if curr_level < 18:
		return Vector2i(0, 0)
	return Vector2i(-1, 0)

func increase_level_num():
	curr_level += 1
	if curr_level > 18:
		get_tree().change_scene_to_file("res://scenes/end.tscn")
		Dialogic.start("win_game")
		Stopwatch.stopped = true
		

func load_current_level():
	var level_name = "res://scenes/levels/level_" + str(curr_level) + ".tscn"
	var level = load(level_name)
	if level:
		var course = get_tree().get_first_node_in_group("Course")
		var course_children = course.get_children()
		for child in course_children:
			child.queue_free()
		course.add_child(level.instantiate())
