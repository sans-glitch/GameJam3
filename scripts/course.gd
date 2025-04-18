extends Node2D

var tile_array : Array
var tile_map : TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelManager.load_current_level()
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

## Gets the amount a specific tile inhibits the club range.
## [param coords] is the specific tile's position in the tile map array.
func get_tile_terrain_num(coords : Vector2i) -> int:
	if coords.x < 0 or coords.y < 0 or coords.x > get_course_dimensions().x or coords.y > get_course_dimensions().y:
		return 69
	return tile_map.get_cell_tile_data(coords).get_custom_data("Terrain")

## Determines if the specific tile is the starting tile (tee).
## [param coords] is the specific tile's position in the tile map array.
func is_tile_beginning(coords : Vector2i) -> bool:
	return tile_map.get_cell_tile_data(coords).get_custom_data("Begin")
	
## Determines if the specific tile is the ending tile (hole).
## [param coords] is the specific tile's position in the tile map array.
func is_tile_end(coords : Vector2i) -> bool:
	return tile_map.get_cell_tile_data(coords).get_custom_data("End")

## Returns the size of the tile map's [method TileMapLayer.get_used_rect]
func get_course_dimensions() -> Vector2i:
	var map_rect = tile_map.get_used_rect()
	return map_rect.size
