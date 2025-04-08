extends Node

var curr_level = 1
var furthest_unlocked_level
#@onready var course: Node2D = 


## Gets the clubs available to the player based on the level number.
## Returns an array containing each available club.


func get_curr_level_par():
	#TODO: not plus one yet, keep 14 to 13 as par 5
	var par : Array = [0, 0, 0, 2, 3, 3, 3, 5, 2, 2, 5, 6, 4, 4, 5, 3, 3, 6, 4]
	return par[curr_level]

func get_curr_level_clubs():
	if curr_level <= 5:
		return ["driver", "putter"]
	elif curr_level <= 12:
		return ["driver", "putter", "wedge"]
	else:
		return ["driver", "putter", "wedge", "iron"]

func get_curr_level_wind():
	if curr_level < 18:
		return Vector2i(0, 0)
	return Vector2i(1, 0)

func increase_level_num():
	if curr_level < 18:
		curr_level += 1
	else:
		get_tree().change_scene_to_file("res://scenes/title.tscn")

func load_current_level():
	var level_name = "res://scenes/levels/level_" + str(curr_level) + ".tscn"
	var level = load(level_name)
	if level:
		var course = get_tree().get_first_node_in_group("Course")
		var course_children = course.get_children()
		for child in course_children:
			child.queue_free()
		course.add_child(level.instantiate())
