extends Node2D

var tile_array : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_array = []
	var map_rect = $TileMapLayer.get_used_rect()
	for row in map_rect.size.y:
		tile_array.append([])
		for col in map_rect.size.x:
			tile_array[row].append(get_tile_terrain_num(Vector2i(col, row)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_tile_terrain_num(coords : Vector2i) -> int:
	return $TileMapLayer.get_cell_tile_data(coords).get_custom_data("Terrain")
