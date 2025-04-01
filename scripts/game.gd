extends Node2D

signal shot_selected(coords : Vector2i)
var ball_pos : Vector2i
var curr_club_dist
var hole_pos : Vector2i
var strokes : int
@export var particles : PackedScene
var dirt_particles : CPUParticles2D
var tile_size : int
var ui_scale : Vector2
var in_the_air : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_size = 16
	ui_scale = Vector2(8, 8)
	$Course.scale = ui_scale
	shot_selected.connect(_on_shot_selected)
	# Centers Camera on course
	$Camera2D.position.x = -((9 -$Course.tile_array[0].size()) * ui_scale.x * tile_size)/2
	# Determines the starting and hole tile coordinates
	find_begin_and_end()
	$Flag.position = Vector2(hole_pos) * tile_size * ui_scale
	curr_club_dist = 3
	# Generates the first shot selection buttons
	gen_shot_circle(get_shot_dist())
	# Sets up dirt particle node
	dirt_particles = particles.instantiate()
	dirt_particles.scale *= ui_scale
	dirt_particles.scale_amount_min *= ui_scale.x/3
	dirt_particles.scale_amount_max *= ui_scale.x/3
	add_child(dirt_particles)
	# Positions the golf ball
	$GolfBall.position = Vector2(ball_pos) * tile_size * ui_scale


func _process(delta: float) -> void:
	$GolfBall.position = Vector2(ball_pos) * tile_size * ui_scale
	if strokes == 0:
		$GolfBall.position = (Vector2(ball_pos) * tile_size + Vector2(0,-3)) * ui_scale
	# If the ball is in the hole
	if ball_pos == hole_pos:
		AudioManager.play('res://assets/sounds/hole.wav')
		get_tree().reload_current_scene()
	# Updates stroke counter
	$StrokeLabel.text = "Strokes: " + str(strokes)

## Signaled function that runs whenever a signal button is selected
func _on_shot_selected(coords : Vector2i):
	strokes += 1
	clear_shot_circle()
	if curr_club_dist == 3:
		display_dirt(coords - ball_pos)
		AudioManager.play('res://assets/sounds/driver_shot.wav')
		await animate_driver_shot(coords)
	elif curr_club_dist == 1:
		AudioManager.play('res://assets/sounds/putt.wav')
		await animate_putter_shot(coords)
	AudioManager.play("res://assets/sounds/landing.wav")
	ball_pos = coords
	if coords != hole_pos:
		gen_shot_circle(get_shot_dist())

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("putter") and not in_the_air:
		curr_club_dist = 1
		clear_shot_circle()
		gen_shot_circle(get_shot_dist())
	if Input.is_action_just_pressed("driver") and not in_the_air:
		curr_club_dist = 3
		clear_shot_circle()
		gen_shot_circle(get_shot_dist())
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

## Fades out and deletes the current shot buttons
func clear_shot_circle():
	var tween = get_tree().create_tween().set_parallel()
	var button_arr : Array
	for child in get_children():
		if child.is_in_group("SelectionTile") and not child.is_in_group("GettingCleared"):
			child.add_to_group("GettingCleared")
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
			var dist = ball_pos.distance_to(Vector2i(col, row))
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
	return max(0, curr_club_dist - $Course.get_tile_terrain_num(ball_pos))

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
