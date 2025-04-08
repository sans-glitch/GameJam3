extends Node2D

## A signal emitted whenever a shot has been selected
signal shot_selected(coords : Vector2i)
## Coordinates of the ball within the tilemap array
var ball_pos : Vector2i
## A reference to the club manager node which manages the clubs
@onready var club_manager = $Camera2D/ClubManager
## A reference to the course node which manages the tile map
@onready var course: Node2D = $Course
## Coordinates of the hole within the tilemap array
var hole_pos : Vector2i
## Number of strokes taken in current hole
var strokes : int
## Exported particle node
@export var particles : PackedScene
## Dirt particle node that will be an instance of particles
var dirt_particles : CPUParticles2D
## The size of each tile in pixels
var tile_size : int
## The scale that the tilemap and other ui is scaled to to fit the screen
var ui_scale : Vector2
var in_the_air : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("reset")
	Dialogic.signal_event.connect(_show_gui_element)
	shot_selected.connect(_on_shot_selected)
	# Sets up dirt particle node
	dirt_particles = particles.instantiate()
	dirt_particles.scale *= ui_scale
	dirt_particles.scale_amount_min *= ui_scale.x/3
	dirt_particles.scale_amount_max *= ui_scale.x/3
	add_child(dirt_particles)
	new_level_actions(true)
	

func _process(_delta: float) -> void:
	$GolfBall.position = Vector2(ball_pos) * tile_size * ui_scale
	if strokes == 0:
		$GolfBall.position = (Vector2(ball_pos) * tile_size + Vector2(0,-3)) * ui_scale
	
	# If the ball is in the hole
	#if ball_pos == hole_pos:
		
	# Updates stroke counter
	$Camera2D/StrokeLabel.text = "Strokes: " + str(strokes)
	$Camera2D/Stopwatch.text = Stopwatch.get_time_string()
	
	if $Course.get_tile_terrain_num(ball_pos) == 69:
		await get_tree().create_timer(.5).timeout
		soft_reset(false)
	
	if ($Camera2D/HoleLabel.text == "Hole 1" or $Camera2D/HoleLabel.text == "Hole 2") and $"Tutorial1/1/ColorRect".is_visible_in_tree()==false:
		$Camera2D/Caddie.show()
	else:
		$Camera2D/Caddie.hide()

## Signaled function that runs whenever a signal button is selected
func _on_shot_selected(coords : Vector2i) -> void:
	var wind = LevelManager.get_curr_level_wind()
	coords += wind
	strokes += 1
	clear_shot_circle()
	var land_sound = true
	var club_name = club_manager.curr_club_name()
	
	if club_name == "driver":
		display_dirt(coords - ball_pos)
		AudioManager.play('res://assets/sounds/driver_shot.wav')
		await animate_driver_shot(coords)
	elif club_name == "putter":
		AudioManager.play('res://assets/sounds/putt.wav')
		await animate_putter_shot(coords)
		land_sound = false
	elif club_name == "wedge":
		AudioManager.play('res://assets/sounds/swing_hit.wav')
		await animate_high_shot(coords)
	elif club_name == "iron":
		AudioManager.play('res://assets/sounds/swing_hit.wav')
		await animate_high_shot(coords)
	#if strokes == 0:
		#soft_reset()
	ball_pos = coords
	if $Course.get_tile_terrain_num(ball_pos) == 69:
		AudioManager.play("res://assets/sounds/small_splash.wav")
		return
	
	if land_sound:
		AudioManager.play("res://assets/sounds/landing.wav")
	
	if coords != hole_pos:
		gen_shot_circle(get_shot_dist())
	else:
		ball_in_hole()

func _on_club_switched():
	clear_shot_circle()
	gen_shot_circle(get_shot_dist())

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset") and not in_the_air:
		#if LevelManager.curr_level == 2:
			#soft_reset()
			#return
		#get_tree().reload_current_scene()
		soft_reset(false)
	if Input.is_action_just_pressed("ui_copy"):
		LevelManager.increase_level_num()
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("ui_paste"):
		LevelManager.curr_level -= 1
		get_tree().reload_current_scene()

## Resets the stroke number and ball position without reloading the scene. 
## Required for tutorial level 2.
func soft_reset(update_dialogue : bool) -> void:
	find_begin_and_end()
	clear_shot_circle()
	gen_shot_circle(get_shot_dist())
	strokes = 0
	new_level_actions(update_dialogue)

## Fades out and deletes the current shot buttons
func clear_shot_circle() -> void:
	var tween = get_tree().create_tween().set_parallel()
	var button_arr : Array
	for child in get_children():
		if child.is_in_group("SelectionTile") and not child.is_in_group("GettingCleared"):
			child.add_to_group("GettingCleared")
			child.disabled = true
			button_arr.append(child)
			tween.tween_property(
				child,
				"modulate",
				Color.TRANSPARENT,
				0.25
			)
	await tween.finished
	for child in button_arr:
		if child.is_inside_tree():
			child.queue_free()

## Instantiates and places shot select buttons on tile grid
func gen_shot_circle(rad : int):
	for row in $Course.tile_array.size():
		for col in $Course.tile_array[0].size():
			var dist = (ball_pos).distance_to(Vector2i(col, row))
			if abs(rad - dist) < 0.5:
				add_child(SelectionTile.new_button(Vector2i(col, row), ui_scale, tile_size))

## Animates the ball's movement from its current position to the selected position when hit by driver
func animate_driver_shot(coords : Vector2i):
	in_the_air = true
	var tween = get_tree().create_tween()
	var time_mult = 3
	tween.set_parallel()
	tween.tween_property(
		$GolfBall,
		":position:x",
		(Vector2(coords) * ui_scale.x * tile_size).x,
		0.25*time_mult
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(
		$GolfBall,
		":position:y",
		($GolfBall.position.y + (Vector2(coords) * ui_scale.x * tile_size).y)/2 - (14*tile_size),
		0.125*time_mult
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(
		$GolfBall,
		":position:y",
		(Vector2(coords) * ui_scale.x * tile_size).y,
		0.125*time_mult
	).set_ease(Tween.EASE_IN).set_delay(0.125*time_mult).set_trans(Tween.TRANS_QUART)
	await tween.finished
	in_the_air = false

## Animates the ball's movement from its current position to the selected position when hit by wedge or iron
func animate_high_shot(coords : Vector2i):
	in_the_air = true
	var tween = get_tree().create_tween()
	var time_mult = 3
	tween.set_parallel()
	tween.tween_property(
		$GolfBall,
		":position:x",
		(Vector2(coords) * ui_scale.x * tile_size).x,
		0.25*time_mult
	)
	tween.tween_property(
		$GolfBall,
		":position:y",
		($GolfBall.position.y + (Vector2(coords) * ui_scale.x * tile_size).y)/2 - (16*tile_size),
		0.125*time_mult
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(
		$GolfBall,
		":position:y",
		(Vector2(coords) * ui_scale.x * tile_size).y,
		0.125*time_mult
	).set_ease(Tween.EASE_IN).set_delay(0.125*time_mult).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	in_the_air = false

## Animates the ball's movement from its current position to the selected position when hit by putter
func animate_putter_shot(coords : Vector2i):
	in_the_air = true
	var tween = get_tree().create_tween()
	var time_mult = 3
	tween.set_parallel()
	tween.tween_property(
		$GolfBall,
		":position",
		(Vector2(coords) * ui_scale.x * tile_size),
		0.25*time_mult
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	await tween.finished
	in_the_air = false

## Returns the current shot distance calculated from the current club and terrain
func get_shot_dist():
	var club_dist = club_manager.curr_club_dist
	var terrain_amt = $Course.get_tile_terrain_num(ball_pos)
	if club_manager.terrain_dependant:
		return max(0, club_dist - terrain_amt)
	return club_dist

## Finds start and end tile on course
func find_begin_and_end():
	for row in $Course.tile_array.size():
		for col in $Course.tile_array[0].size():
			if $Course.is_tile_end(Vector2i(col, row)):
				hole_pos = Vector2i(col, row)
			elif $Course.is_tile_beginning(Vector2i(col, row)):
				ball_pos = Vector2i(col, row)

## Shows dirt spray particles in the shot direction
func display_dirt(dir : Vector2):
	dirt_particles.position = (ball_pos * tile_size + Vector2i(tile_size/2, tile_size/2)) * ui_scale.x
	dirt_particles.direction = dir
	dirt_particles.restart()

## Determines the proper ui scale based on the course size and centers the camera onto the course.
func set_ui_scale():
	var course_dimensions = course.get_course_dimensions()
	var scale = min(get_viewport_rect().size.x/course_dimensions.x, get_viewport_rect().size.y/course_dimensions.y)
	ui_scale = Vector2(scale/tile_size, scale/tile_size)
	$Camera2D.position.x = -(get_viewport_rect().size.x - (course_dimensions.x * ui_scale.x * tile_size))/2
	$Camera2D.position.y = -(get_viewport_rect().size.y - (course_dimensions.y * ui_scale.y * tile_size))/2

func _show_gui_element(argument : String) -> void:
	match argument:
		"par_show":
			$Camera2D/Par.show()
		"red_ball":
			$Inventory.show_red_ball()
		"gold_ball":
			$Inventory.show_gold_ball()
		"sunhat":
			$Inventory.show_hat()
		"glove":
			$Inventory.show_glove()

func reset_gui():
	tile_size = 16
	ui_scale = Vector2(8, 8)
	set_ui_scale()
	$Course.scale = ui_scale
	$GolfBall.scale = ui_scale
	
	$Flag.position = Vector2(hole_pos) * tile_size * ui_scale
	$GolfBall.position = Vector2(ball_pos) * tile_size * ui_scale
	$Camera2D/ClubManager.switched_clubs.connect(_on_club_switched)
	$Camera2D/HoleLabel.text = "Hole " + str(LevelManager.curr_level)
	$Camera2D/Par.text = "Par " + str(LevelManager.get_curr_level_par())
	$Camera2D/Stopwatch.text = Stopwatch.get_time_string()
	
	$Camera2D/Par.hide()
	$Tutorial1.hide()
	$Tutorial2.hide()
	if LevelManager.curr_level > 3:
		$Camera2D/Par.show()
	if LevelManager.curr_level == 1:
		$Tutorial1.show()
	elif LevelManager.curr_level == 2:
		$Tutorial2.show()
	# Displays wind if needed
	if LevelManager.get_curr_level_wind().length() > 0:
		var direction = LevelManager.get_curr_level_wind()
		$Camera2D/GPUParticles2D.show()
		$Camera2D/GPUParticles2D.process_material.set_direction(Vector3(direction.x, direction.y, 0))
	else:
		$Camera2D/GPUParticles2D.hide()

func display_dialogue():
	match LevelManager.curr_level:
		1:
			Dialogic.start("start_game")
		3:
			Dialogic.start("hole3")
		5:
			Dialogic.start("red_ball")
		6:
			Dialogic.start("unlockWedge")
		8:
			Dialogic.start("glove")
		9:
			Dialogic.start("win")
		12:
			Dialogic.start("unlockIron")
		13:
			Dialogic.start("sunny")
		14:
			Dialogic.start("sun_hat")
		16:
			Dialogic.start("gold_ball")
		18:
			Dialogic.start("broken_driver")

func new_level_actions(update_dialogue : bool):
	#LevelManager.load_current_level()
	$Course._ready()
	reset_gui()
	find_begin_and_end()
	club_manager.set_club(LevelManager.get_curr_level_clubs()[0])
	# Generates the first shot selection buttons
	gen_shot_circle(get_shot_dist())
	display_dialogue()

func ball_in_hole():
	AudioManager.play('res://assets/sounds/hole.wav')
	if LevelManager.curr_level == 2 and strokes > 4:
		soft_reset(false)
		$Tutorial2.curr_slide_num = 6
		$Tutorial2.show_slide(6)
		return
	var par = LevelManager.get_curr_level_par()
	if par != 0 and strokes > par: # Over par
		soft_reset(false)
		return
	#Advance level
	LevelManager.increase_level_num()
	if LevelManager.curr_level == 19:
		return
	soft_reset(true)
