extends Node

var curr_level = 1
var furthest_unlocked_level
#@onready var course: Node2D = 

func get_curr_level_clubs():
	if curr_level <= 5:
		return ["driver", "putter"]
	elif curr_level <= 12:
		return ["driver", "putter", "wedge"]
	else:
		return ["driver", "putter", "wedge", "iron"]

func increase_level_num():
	if curr_level < 18:
		curr_level += 1

func load_current_level():
	var level_name = "res://scenes/levels/level_" + str(curr_level) + ".tscn"
	var level = load(level_name)
	if level:
		var course = get_tree().get_first_node_in_group("Course")
		var course_children = course.get_children()
		for child in course_children:
			child.queue_free()
		course.add_child(level.instantiate())
