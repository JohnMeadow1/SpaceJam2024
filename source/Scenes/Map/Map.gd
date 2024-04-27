extends Node2D

class_name Map

const GRID_SIZE := Vector2i(16, 16)
const GRID_RES  := 720.0/15.0
const AGENT = preload("res://Nodes/Agent.tscn")
var grid :Array[Agent]

var entropy_max := 0.0
var difficulty  := 1.0
var entropy_avg := 2.0
var pitch := 1.0
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
@export var entropy:Label
@onready var game:Game

func _ready() -> void:
	grid.resize(GRID_SIZE.x * GRID_SIZE.y)

	set_physics_process(true)
	for i in 2:
		var pos = Vector2i(randi()%((GRID_SIZE.x-1)), randi()%((GRID_SIZE.y-1)))
		if not is_instance_valid(get_grid_value_v(pos)):
			add_agent(pos, Agent.TYPES.SPAWNER)
	for i in 10:
		var pos = Vector2i(randi()%((GRID_SIZE.x-1)), randi()%((GRID_SIZE.y-1)))
		if not get_grid_value_v(pos):
			add_agent(pos, Agent.TYPES.FOOD)
		#add_agent(Vector2(400,300) + Vector2.RIGHT.rotated(i/10.0* TAU + randf_range(-PI*0.05,PI*0.05)) * randf_range( 100, 200), Agent.TYPES.FOOD)

func _physics_process(delta: float) -> void:
	difficulty += delta / 240.0
	entropy.text = str("Sustained Entropy\n", Agent.live_agents)
	entropy_avg = get_updated_average_opt(entropy_avg, Agent.live_agents )
	entropy_max = max(entropy_max, Agent.live_agents)
	var thing = clamp(1.0 + (Agent.live_agents-entropy_avg), 0.2, 1.1)
	pitch = lerp(pitch, thing, 0.005)
	prints(pitch, Agent.live_agents, entropy_max, entropy_avg)
	AudioManager.set_pitch( pitch )
	if Agent.live_agents<=0:
		game.game_over()
		set_physics_process(false)

	#queue_redraw()
func get_updated_average_opt(average:float, input:float):
	var average_sample_size = 0.05
	return (average_sample_size * input) + (1.0 - average_sample_size) * average
	
func _input(event):
	if not game.is_game_over:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				var mouse_pos = get_global_mouse_position()/GRID_RES
				var agent = get_grid_value_v(mouse_pos)
				if agent:
					if agent.type == Agent.TYPES.WALKER:
						agent.change_type(Agent.TYPES.FOOD)
						AudioManager.play_button_sound()
					#else:
						#add_agent(get_global_mouse_position(), Agent.TYPES.SPAWNER)
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				var agent = get_grid_value_v (get_global_mouse_position()/GRID_RES)
				if agent:
					if agent.type == Agent.TYPES.WALKER:
						agent.change_type(Agent.TYPES.SPAWNER)
						AudioManager.play_button_sound()

func _draw():
	for y in GRID_SIZE.y-1:
		for x in GRID_SIZE.x-1:
			var rect_orgin = Vector2(x * GRID_RES, y * GRID_RES)
			draw_rect( Rect2(rect_orgin, Vector2(GRID_RES,GRID_RES)), Color(0,0,1,0.1), false )
			

func add_agent(in_position:Vector2, in_type:Agent.TYPES):
	if not get_grid_value_v(in_position):
		var new_agent = AGENT.instantiate()
		new_agent.position = in_position * GRID_RES
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
	
func get_grid_value_v( coords:Vector2i ) -> Agent:
	#var x:int = int(coords.x / GRID_RES)
	#var y:int = int(coords.y / GRID_RES)
	return grid[ coords.x + coords.y * GRID_SIZE.x ]
	
func set_grid_value_v( coords:Vector2i, value:Agent ):
	grid[ coords.x + coords.y * GRID_SIZE.x ] = value
	
	
#func initialize_grid():
	#for y in GRID_SIZE.y:
		#for x in GRID_SIZE.x:
			#grid.append(0)

