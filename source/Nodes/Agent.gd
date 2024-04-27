extends Node2D
class_name Agent

const size := 30
const ticks_max := [8, 30, 20, 5, 2]
const diretion_change := [0.785398, -0.785398]
const spawn_points := [Vector2i(size, size),Vector2i( -size,  -size), Vector2i(size,0),Vector2i(-size,0), Vector2i(0,size), Vector2i(0,-size), Vector2i(-size,size), Vector2i(size,-size)]
const rect := Rect2i(Vector2i.ZERO, Vector2i.ONE*size-Vector2i.ONE)

var map:Map
var velocity := Vector2.ZERO
var coordinates:= Vector2i.ZERO
var coordinates_real := Vector2.ZERO

var tick := 0.0
var timer := 0.0

var colors := [Color.DARK_RED, Color.ANTIQUE_WHITE, Color.WEB_GREEN, Color.DARK_BLUE, Color.BLACK ]
var color:Color
var color_old:Color
enum TYPES {SPAWNER, SEEKER, WALKER, FOOD, DEAD }
@export var type: TYPES

static var live_agents :=0


func _ready() -> void:
	live_agents += 1
	map = get_parent()
	timer = randf_range(0.0,3.0)
	tick = ticks_max[type]
	color = colors[type]
	color_old = color
	
	coordinates = Vector2i(position / size)
	coordinates_real = coordinates
	position = coordinates * size
	#velocity = Vector2.RIGHT.rotated( randf() * PI ) * randf_range(1.0, 4.0)
	velocity = Vector2.LEFT * 0.05
	map.set_grid_value_v(coordinates, self)
	
func _physics_process(delta: float) -> void:
	match type:
		TYPES.SPAWNER:
			if timer > 0:
				timer -= delta
			else:
				map.add_agent(position + Vector2(spawn_points[randi()%8]), TYPES.SEEKER)
				timer = 3.0
				tick -= 1
				if tick <= 0:
					change_type(TYPES.DEAD)
		TYPES.SEEKER:
			var coordinates_new = get_new_position()
			#$Label.text = str(grid_coords)
			if coordinates != coordinates_new:
				var agent = map.get_grid_value_v( coordinates_new )
				if agent:
					if agent != self:
						match agent.type:
							TYPES.FOOD:
								agent.reduce_food()
								change_type(TYPES.WALKER)

						velocity = -velocity
						try_change_direction()
						#position_real += velocity
					else:
						print("nope")
				else:
					try_change_direction()
					update_position(coordinates_new)
					tick -= 1
					if tick <= 0:
						change_type(TYPES.DEAD)

		TYPES.WALKER:
			var coordinates_new = get_new_position()
			if coordinates != coordinates_new:
				var agent = map.get_grid_value_v( coordinates_new )
				if agent:
					if agent != self:
						velocity = -velocity
						try_change_direction()
						#position_real += velocity
					else:
						print("nope")
				else:
					update_position(coordinates_new)
					try_change_direction()
					tick -= 1
					if tick <= 0:
						change_type(TYPES.DEAD)
		TYPES.FOOD:
			if timer > 0:
				timer -= delta
			else:
				tick -= 1
				timer = 10.0
			if tick <= 0:
				change_type(TYPES.DEAD)
		TYPES.DEAD:
			tick -= delta
			if tick <= 0.0:
				live_agents -= 1
				map.set_grid_value_v(coordinates, null)
				set_physics_process(false)
				queue_free()
			color = colors[type].lerp(color_old, tick/ticks_max[type])
			queue_redraw()
			
func reduce_food():
	tick -= 1
	
func update_position(in_coordinates:Vector2):
	map.set_grid_value_v(coordinates, null)
	map.set_grid_value_v(in_coordinates, self)
	coordinates = in_coordinates
	position = coordinates * size
	
func get_new_position() -> Vector2i:
	coordinates_real += velocity
	var coordinates_new = Vector2i(coordinates_real)
	if coordinates_new.x < 0:
		coordinates_new.x = map.GRID_SIZE.x-1
	if coordinates_new.x > map.GRID_SIZE.x-1:
		coordinates_new.x = 0
	if coordinates_new.y < 0:
		coordinates_new.y = map.GRID_SIZE.y-1
	if coordinates_new.y > map.GRID_SIZE.y-1:
		coordinates_new.y = 0

	return coordinates_new

func change_type(new_type:TYPES):
	match new_type:
		TYPES.WALKER:
			velocity = velocity.normalized() * 0.005
	type = new_type
	tick = ticks_max[type]
	color_old = color
	color = colors[type]
	timer = 0.0
	queue_redraw()

func try_change_direction():
	var rand_value = randi()%5
	#if rand_value <= 1:
		#velocity = velocity.rotated(diretion_change[rand_value])


func _draw() -> void:
	draw_rect(rect, color)
