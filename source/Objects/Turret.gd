extends Area2D
class_name Turret

var bullet_object = load("res://objects/Bullet.tscn")

@export var bullet_range = 200
@export var bullet_speed = 500
@export var shoot_delay := 0.1

var current_target:Enemy
var has_enemy := false
var timer := 0.0

@onready var sprite = $body
@onready var bullet_spawn = $body/bullet_spawn
@onready var map = get_parent()

func _ready():
	pass

func register_on_map():
	map.add_obstacle(global_position)
	
func _process(delta):
	timer += delta
	if has_enemy:
		if is_instance_valid(current_target):
			var vector_to_target = (current_target.global_position - global_position)
			sprite.rotation = (vector_to_target).angle()
			
			if vector_to_target.length() - current_target.size > bullet_range:
				get_new_target()
			if timer >= shoot_delay:
				add_bullet()
				timer = 0.0
		else:
			get_new_target()

func get_new_target():
	has_enemy = false
	for area in get_overlapping_areas():
		current_target = area.get_parent()
		has_enemy = true
		break

func add_bullet():
	var new_bullet = bullet_object.instantiate()
	new_bullet.speed = bullet_speed
	new_bullet.max_range = bullet_range
	new_bullet.velocity = (current_target.global_position - global_position).normalized()
	add_child(new_bullet)
	new_bullet.global_position = bullet_spawn.global_position

func _on_area_entered(area):
	if area is Enemy:
		if not has_enemy:
			current_target = area
			has_enemy = true
