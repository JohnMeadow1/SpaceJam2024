extends Node2D
class_name GameMap

var map_mask = [
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0],
[0,0,0,1,0,0,1,0,0,0,0,1,1,1,0,0],
[0,0,0,1,0,0,1,1,1,0,0,1,0,1,0,0],
[1,1,1,1,0,0,1,0,1,1,0,1,0,1,0,0],
[0,0,0,1,0,0,1,0,0,1,0,1,0,1,0,0],
[0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,1],
[0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
]

var map_tile_object = load("res://objects/Map_tile.tscn")

func _ready():
	generate_map()
	$spawner.spawn_point = $Marker2D.global_position
	
func generate_map():
	for y in 9:
		for x in 16:
			if not map_mask[y][x]:
				var new_map_tile = map_tile_object.instantiate()
				new_map_tile.global_position = Vector2(x,y) * 64 + Vector2(32,32)
				add_child(new_map_tile)
				new_map_tile.get_node("AnimationPlayer").seek(randf_range(0,6.4))

func get_coordinates(coordinates: Vector2) -> bool:
	var map_coordintes =  coordinates / 64 
	return map_mask[ floor(map_coordintes.y) ][ floor(map_coordintes.x) ]
	
	
	
	
	
