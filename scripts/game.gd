extends Node2D

signal shot_selected(coords : Vector2i)
var ball_pos : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shot_selected.connect(_on_shot_selected)
	ball_pos = Vector2i(0, 0)
	#var button = SelectionTile.new_button()
	#add_child(SelectionTile.new_button(Vector2i(1, 2), $Course.scale))
	gen_shot_circle(3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$GolfBall.position = Vector2(ball_pos) * 16 * $Course.scale

func _on_shot_selected(coords : Vector2i):
	ball_pos = coords
	gen_shot_circle(3)
	print(coords)
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
