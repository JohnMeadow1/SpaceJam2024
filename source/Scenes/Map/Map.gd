extends Node2D

class_name Map

const GRID_RES  := 30
const GRID_SIZE := Vector2i(25, 25)
const AGENT = preload("res://Nodes/Agent.tscn")
var grid :Array[Agent]

var max_distance := 0.0


var map_mask := [
[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
]

@onready var game:Game

func _ready() -> void:
	grid.resize(GRID_SIZE.x * GRID_SIZE.y)

	set_physics_process(true)
	for i in 4:
		var pos = Vector2(randi()%((GRID_SIZE.x-1)*30), randi()%((GRID_SIZE.y-1)*30))
		if not get_grid_value_v(pos):
			add_agent(pos, Agent.TYPES.SPAWNER)
	for i in 20:
		var pos = Vector2(randi()%((GRID_SIZE.x-1)*30), randi()%((GRID_SIZE.y-1)*30))
		if not get_grid_value_v(pos):
			add_agent(pos, Agent.TYPES.FOOD)
		#add_agent(Vector2(400,300) + Vector2.RIGHT.rotated(i/10.0* TAU + randf_range(-PI*0.05,PI*0.05)) * randf_range( 100, 200), Agent.TYPES.FOOD)

func _physics_process(delta: float) -> void:
	if Agent.live_agents<=0:
		game.game_over()
		set_physics_process(false)
	#queue_redraw()
	
func _input(event):
	if not game.is_game_over:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				var agent = get_grid_value_v (get_global_mouse_position())
				if agent:
					if agent.type == Agent.TYPES.WALKER:
						agent.change_type(Agent.TYPES.FOOD)
					#else:
						#add_agent(get_global_mouse_position(), Agent.TYPES.SPAWNER)
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				var agent = get_grid_value_v (get_global_mouse_position())
				if agent:
					if agent.type == Agent.TYPES.WALKER:
						agent.change_type(Agent.TYPES.SPAWNER)

func _draw():
	for y in GRID_SIZE.y:
		for x in GRID_SIZE.x:
			var rect_orgin = Vector2(x * GRID_RES, y * GRID_RES)
			draw_rect( Rect2(rect_orgin, Vector2(GRID_RES,GRID_RES)), Color(1,1,0,0.1), false )
			

func add_agent(in_position:Vector2, in_type:Agent.TYPES):
	if not get_grid_value_v(in_position):
		var new_agent = AGENT.instantiate()
		new_agent.position = in_position
		new_agent.type = in_type
		add_child(new_agent)


#func add_obstacle(coords:Vector2):
	#set_grid_value_v(coords, 10000)
	#
#func remove_obstacle(coords:Vector2):
	#set_grid_value_v(coords, 0)

#func get_grid_value( x:float, y:float ):
	#return grid[ int(x) + int(y) * GRID_SIZE.x ]
	#
#func set_grid_value( x:float, y:float, value:int ):
	#grid[ int(x) + int(y) * GRID_SIZE.x ] = value
	
func get_grid_value_v( coords:Vector2 ) -> Agent:
	var x:int = int(coords.x / GRID_RES)
	var y:int = int(coords.y / GRID_RES)
	return grid[ x + y * GRID_SIZE.x ]
	
func set_grid_value_v( coords:Vector2i, value:Agent ):
	grid[ coords.x + coords.y * GRID_SIZE.x ] = value
	
	
#func initialize_grid():
	#for y in GRID_SIZE.y:
		#for x in GRID_SIZE.x:
			#grid.append(0)

