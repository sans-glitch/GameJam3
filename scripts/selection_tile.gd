class_name SelectionTile extends Button

const BUTTON_SCENE: PackedScene = preload("res://scenes/selection_tile.tscn")
var coords : Vector2i
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#position = coords
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

static func new_button(coords : Vector2i, scale : Vector2, tile_size : int) -> SelectionTile:
	var button: SelectionTile = BUTTON_SCENE.instantiate()
	button.coords = coords
	button.position = Vector2(coords) * tile_size * scale
	button.scale = scale
	button.size = Vector2(tile_size, tile_size)
	return button


func _on_pressed() -> void:
	get_parent().shot_selected.emit(coords)
