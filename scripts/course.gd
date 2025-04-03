extends Node2D

var tile_array : Array
var tile_map : TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is TileMapLayer:
			tile_map = child
	tile_array = []
	var map_rect = tile_map.get_used_rect()
	for row in map_rect.size.y:
		tile_array.append([])
		for col in map_rect.size.x:
			tile_array[row].append(get_tile_terrain_num(Vector2i(col, row)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_tile_terrain_num(coords : Vector2i) -> int:
	return tile_map.get_cell_tile_data(coords).get_custom_data("Terrain")

func is_tile_beginning(coords : Vector2i) -> bool:
	return tile_map.get_cell_tile_data(coords).get_custom_data("Begin")
	
func is_tile_end(coords : Vector2i) -> bool:
	return tile_map.get_cell_tile_data(coords).get_custom_data("End")

func get_course_dimensions():
	var map_rect = tile_map.get_used_rect()
	return map_rect.size
