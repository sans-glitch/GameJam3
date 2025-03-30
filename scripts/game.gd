extends Node2D

signal shot_selected(coords : Vector2i)
var ball_pos : Vector2i
var curr_club_dist
var hole_pos : Vector2i
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shot_selected.connect(_on_shot_selected)
	ball_pos = Vector2i(0, 0)
	find_hole()
	$Flag.position = Vector2(hole_pos) * 16 * $Course.scale
	curr_club_dist = 3
	#var button = SelectionTile.new_button()
	#add_child(SelectionTile.new_button(Vector2i(1, 2), $Course.scale))
	gen_shot_circle(curr_club_dist)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$GolfBall.position = Vector2(ball_pos) * 16 * $Course.scale
	if ball_pos == hole_pos:
		get_tree().reload_current_scene()

func _on_shot_selected(coords : Vector2i):
	AudioManager.play('res://assets/sounds/driver_shot.wav')
	await animate_shot(coords)
	ball_pos = coords
	gen_shot_circle(curr_club_dist - $Course.get_tile_terrain_num(ball_pos))
#
func gen_shot_circle(rad : int):
	for child in get_children():
		if child.is_in_group("SelectionTile"):
			child.queue_free()
	for row in $Course.tile_array.size():
		for col in $Course.tile_array[0].size():
			var dist = ball_pos.distance_to(Vector2i(col, row))
			if abs(rad - dist) < 0.5:
				add_child(SelectionTile.new_button(Vector2i(col, row), $Course.scale))

func animate_shot(coords : Vector2i):
	var tween = get_tree().create_tween()
	var time_mult = 3
	tween.set_parallel()
	tween.tween_property(
		$GolfBall,
		":position:x",
		(Vector2(coords) * 8 * 16).x,
		0.25*time_mult
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(
		$GolfBall,
		":position:y",
		($GolfBall.position.y + (Vector2(coords) * 8 * 16).y)/2 - (14*16),
		0.125*time_mult
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(
		$GolfBall,
		":position:y",
		(Vector2(coords) * 8 * 16).y,
		0.125*time_mult
	).set_ease(Tween.EASE_IN).set_delay(0.125*time_mult).set_trans(Tween.TRANS_QUAD)
	await tween.finished

func find_hole():
	for row in $Course.tile_array.size():
		for col in $Course.tile_array[0].size():
			if $Course.get_tile_terrain_num(Vector2i(col, row)) == 10:
				hole_pos = Vector2i(col, row)
