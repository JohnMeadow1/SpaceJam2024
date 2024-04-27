extends Node2D
class_name Enemy

@export var debug := false

var speed := 30.0
var hit_points := 1.0
var size = 0.0
var velocity = Vector2.ZERO

var facing := Vector2.LEFT

@onready var sprite := $fighter
@onready var map = get_parent()

func _ready():
	size = $CollisionShape2D.shape.radius

func _process(delta):
	facing = map.get_direction_vector(global_position).normalized()
	velocity += facing * speed * delta
	velocity -= velocity * 4 * delta
	position += velocity * delta
	sprite.rotation = velocity.angle()
#	sprite.rotation = lerp_angle( sprite.rotation, facing.angle(), 0.1 )

	if debug:
		$Label.visible = true
		$Label.text = str((( position ) / 64).floor() )
		$Label.text += "\n"+str(map.get_coordinates(position))

func _on_area_entered(area):
	if area is Headquarters:
		queue_free()

func damage(value):
	hit_points -= value
	if hit_points <= 0:
		queue_free()
		
