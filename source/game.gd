extends Node2D

const GRID_RES  = 30
const GRID_SIZE = Vector2(30, 20)

var grid = PackedInt32Array()
var edges = PackedVector2Array()

var target :Vector2
var max_distance = 0

@onready var hq := $HQ as Node2D

var map_mask = [
[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
[1,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,1,0,0,1,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,1,0,0,1,0,1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,1,1,0,0,1,0,1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,1,0,0,1,0,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,1,0,1,0,0,0,0,0,1,1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
]

func _ready():
	initialize_grid()
	target = hq.global_position
	add_obstacle( target )

	for y in GRID_SIZE.y:
		for x in GRID_SIZE.x:
			if map_mask[y][x] :
				var pos = Vector2( x, y )
				set_grid_value(x,y, 10000)
	
	for node in get_children():
		if node.has_method("register_on_map"):
			node.register_on_map()
	
	update_grid()
	
func add_obstacle(coords:Vector2):
	set_grid_valueV(coords, 10000)
func remove_obstacle(coords:Vector2):
	set_grid_valueV(coords, 999)
	
func update_grid():
	var start_pos = (target/GRID_RES).floor()
#	var start_pos = (get_global_mouse_position()/GRID_RES).floor()
	start_pos.x = clamp(start_pos.x, 0, GRID_SIZE.x-1)
	start_pos.y = clamp(start_pos.y, 0, GRID_SIZE.y-1)
	set_grid_value(start_pos.x, start_pos.y, 0)
	edges.append(start_pos)
	
#	if edges.size() > 0:
	while edges.size() > 0:
		var new_value = get_grid_value(edges[0].x , edges[0].y) + 1
		if new_value > max_distance:
			max_distance = new_value
		
		if edges[0].x+1 < GRID_SIZE.x && get_grid_value(edges[0].x+1 , edges[0].y) < 1000 :
			if get_grid_value(edges[0].x+1 , edges[0].y) > new_value:
				edges.append(Vector2(edges[0].x+1,edges[0].y))
				set_grid_value(edges[0].x+1, edges[0].y, new_value)
			
		if edges[0].y+1 < GRID_SIZE.y && get_grid_value(edges[0].x , edges[0].y+1) < 1000 :
			if get_grid_value(edges[0].x , edges[0].y+1) > new_value:
				edges.append(Vector2(edges[0].x,edges[0].y+1))
				set_grid_value(edges[0].x, edges[0].y+1, new_value)
			
		if edges[0].x-1 >= 0 && get_grid_value(edges[0].x-1 , edges[0].y) < 1000 :
			if get_grid_value(edges[0].x-1 , edges[0].y) > new_value:
				edges.append(Vector2(edges[0].x-1,edges[0].y))
				set_grid_value(edges[0].x-1, edges[0].y, new_value)
			
		if edges[0].y-1 >= 0 && get_grid_value(edges[0].x , edges[0].y-1) < 1000 :
			if get_grid_value(edges[0].x , edges[0].y-1) > new_value:
				edges.append(Vector2(edges[0].x,edges[0].y-1))
				set_grid_value(edges[0].x, edges[0].y-1, new_value)
		
		edges.remove_at(0)

func _input(event):
#	if event is InputEventMouseButton:
#		if event.button_index == BUTTON_LEFT and event.pressed:
#			add_obstacle(get_global_mouse_position())
#		if event.button_index == BUTTON_RIGHT and event.pressed:
#			remove_obstacle(get_global_mouse_position())
	pass

func _physics_process(delta):
	if Input.is_action_just_pressed("LMB"):
		if get_grid_valueV(get_global_mouse_position())>= 1000:
			var new_turret = load("res://objects/Turret.tscn").instantiate()
			new_turret.global_position = (get_global_mouse_position() / GRID_RES).floor() * GRID_RES + Vector2( GRID_RES,GRID_RES ) * 0.5
			add_child(new_turret)
			
	if Input.is_action_pressed("LMB"):
		add_obstacle(get_global_mouse_position())
		reset_grid()
		
	if Input.is_action_pressed("RMB"):
		remove_obstacle(get_global_mouse_position())
		reset_grid()

func reset_grid():
	for i in grid.size():
		if grid[i] < 1000:
			grid[i] = 999
	update_grid()
	queue_redraw()

func _draw():
	for y in GRID_SIZE.y:
		for x in GRID_SIZE.x:
			var rect_orgin = Vector2(x * GRID_RES, y * GRID_RES)
#			draw_rect( Rect2(rect_orgin, Vector2(GRID_RES,GRID_RES)), Color(0,0,float(get_grid_value(x,y))/max_distance), true )
			if get_grid_value(x,y) >= 1000:
				draw_rect( Rect2(rect_orgin, Vector2(GRID_RES,GRID_RES)), Color.DARK_GOLDENROD, true )
			else:
				draw_rect( Rect2(rect_orgin, Vector2(GRID_RES,GRID_RES)), Color(0,0,float(get_grid_value(x,y))/max_distance), true )
			draw_rect( Rect2(rect_orgin, Vector2(GRID_RES,GRID_RES)), Color(1,1,0,0.3), false )
			
#			draw_rect( Rect2(rect_orgin, Vector2(GRID_RES,GRID_RES)), Color.from_hsv(float(get_grid_value(x,y))/max_distance,1,1), true )

func get_direction_vector( coords ):
	coords = (coords/GRID_RES).floor()
	var direction = Vector2(-1,0)
	var minimum = get_grid_value(coords.x-1, coords.y)
	if get_grid_value(coords.x+1, coords.y) < minimum:
		minimum = get_grid_value(coords.x+1, coords.y)
		direction = Vector2(1,0)
	if get_grid_value(coords.x, coords.y-1) < minimum:
		minimum = get_grid_value(coords.x, coords.y-1)
		direction = Vector2(0,-1)
	if get_grid_value(coords.x, coords.y+1) < minimum:
		minimum = get_grid_value(coords.x, coords.y+1)
		direction = Vector2(0,1)
		
	if get_grid_value(coords.x+1, coords.y+1) < minimum:
		minimum = get_grid_value(coords.x+1, coords.y+1)
		direction = Vector2(1,1)
	if get_grid_value(coords.x-1, coords.y+1) < minimum:
		minimum = get_grid_value(coords.x-1, coords.y+1)
		direction = Vector2(-1,1)
	if get_grid_value(coords.x-1, coords.y-1) < minimum:
		minimum = get_grid_value(coords.x-1, coords.y-1)
		direction = Vector2(-1,-1)
	if get_grid_value(coords.x+1, coords.y-1) < minimum:
		minimum = get_grid_value(coords.x+1, coords.y-1)
		direction = Vector2(+1,-1)

#	direction.x = get_grid_value(coords.x-1, coords.y) - get_grid_value(coords.x+1, coords.y)
#	direction.y = get_grid_value(coords.x, coords.y-1) - get_grid_value(coords.x, coords.y+1)
	return direction
	

func get_grid_value( x:int, y:int ):
	return grid[ x + y * GRID_SIZE.x ]
	
func set_grid_value( x:int, y:int, value:int ):
	grid[ x + y * GRID_SIZE.x ] = value
	
func get_grid_valueV( coords:Vector2 ):
	var x:int = coords.x / GRID_RES
	var y:int = coords.y / GRID_RES
	return grid[ x + y * GRID_SIZE.x ]
	
func set_grid_valueV( coords:Vector2, value:int ):
	var x:int = coords.x / GRID_RES
	var y:int = coords.y / GRID_RES
	grid[ x + y * GRID_SIZE.x ] = value
	
	
func initialize_grid():
	for y in GRID_SIZE.y:
		for x in GRID_SIZE.x:
			grid.append(999)
