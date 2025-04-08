extends Node2D

@onready var game: Node2D = $"../.."
var curr_club_dist : int
var terrain_dependant : bool
signal switched_clubs
@onready var club_label: Label = $Club

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#curr_club_dist = 3
	set_club(LevelManager.get_curr_level_clubs()[0])
	#terrain_dependant = true
	

func is_available_club(club_name : String) -> bool:
	return LevelManager.get_curr_level_clubs().has(club_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	# Default positions
	#$Driver.position = Vector2(0, 65)
	#$Putter.position = Vector2(16, 65)
	#if curr_club_name() == "driver":
		#$Driver.position = Vector2(0, 65 - 2)
	#if curr_club_name() == "putter":
		#$Putter.position = Vector2(16, 65 - 2)

func _input(event: InputEvent) -> void:
	if $"../..".in_the_air:
		return
	if Input.is_action_just_pressed("driver") and is_available_club("driver"):
		curr_club_dist = 3
		terrain_dependant = true
		switched_clubs.emit()
	elif Input.is_action_just_pressed("putter") and is_available_club("putter"):
		curr_club_dist = 1
		terrain_dependant = true
		switched_clubs.emit()
	elif Input.is_action_just_pressed("iron") and is_available_club("iron"):
		curr_club_dist = 2
		terrain_dependant = false
		switched_clubs.emit()
	elif Input.is_action_just_pressed("wedge") and is_available_club("wedge"):
		curr_club_dist = 1
		terrain_dependant = false
		switched_clubs.emit()
	$Club.text = curr_club_name().substr(0, 1).to_upper() + curr_club_name().substr(1)
	
func set_club(club : String):
	if club=="driver":
		curr_club_dist = 3
		terrain_dependant = true
		print("driver")
	elif club=="putter":
		curr_club_dist = 1
		terrain_dependant = true
	elif club=="iron":
		curr_club_dist = 2
		terrain_dependant = false
	elif club=="wedge":
		curr_club_dist = 1
		terrain_dependant = false
	club_label.text = club		
	switched_clubs.emit()

## Returns the name of the current selected club. Returns a string, all lowercase.
func curr_club_name() -> String:
	if curr_club_dist == 3:
		return "driver"
	elif curr_club_dist == 1 && terrain_dependant:
		return "putter"
	elif curr_club_dist == 1:
		return "wedge"
	elif curr_club_dist == 2:
		return "iron"
	return ""
