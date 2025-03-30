extends Node2D

@onready var game: Node2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game.curr_club_dist == 3:
		$Driver.position = Vector2(0, 65 - 2)
	else:
		$Driver.position = Vector2(0, 65)
	if game.curr_club_dist == 1:
		$Putter.position = Vector2(16, 65 - 2)
	else:
		$Putter.position = Vector2(16, 65)
