extends CharacterBody2D

var desdir: Vector2
var speed: int = 300
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@export var area: Area2D
var areas: Array[Area2D]
var steering_speed: float = 1.5
@onready var root = get_parent().get_parent()

func _separation():
	var dir = Vector2.ZERO
	
	for i in areas:
		var boid: CharacterBody2D = i.get_parent()
		var boid_pos: Vector2 = boid.global_position
		var boid_dir: Vector2 = global_position.direction_to(boid_pos)
		var boid_dis: float = global_position.distance_to(boid_pos)
		
		dir += boid_dir / boid_dis
	
	
	dir = dir * -1
	dir = dir.normalized()
	
	return dir

func _alignment():
	var dir: Vector2 = Vector2.ZERO
	
	for i in areas:
		var boid = i.get_parent()
		dir += boid.velocity.normalized()
	
	
	dir = dir.normalized()
	
	return dir

func _cohesion():
	var dir: Vector2 = Vector2.ZERO
	var avg_pos: Vector2 = Vector2.ZERO
	var n: int = 0
	
	for i in areas:
		var boid = i.get_parent()
		avg_pos += boid.global_position
		n += 1
	
	
	avg_pos = avg_pos / n
	dir = global_position.direction_to(avg_pos)
	
	return dir

func _ready() -> void:
	desdir = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1))
	desdir = desdir.normalized()
	velocity = desdir * speed
	print(velocity)
	$Sprite2D.rotation = velocity.angle()
	move_and_slide()

func _physics_process(delta: float) -> void:
	_overflow()
	
	areas = area.get_overlapping_areas()
	
	$Area2D.scale = Vector2(1, 1) * root.radius_size
	
	var separation: Vector2 = _separation() * root.separation_weight
	var alignment: Vector2 = _alignment() * root.alignment_weight
	var cohesion: Vector2 = _cohesion() * root.cohesion_weight
	
	desdir += separation
	desdir += alignment
	desdir += cohesion
	
	desdir = desdir.normalized()
	
	velocity = _maketurn()
	
	move_and_slide()

func _overflow():
	global_position.x = wrap(global_position.x, 0, get_viewport().size.x)
	global_position.y = wrap(global_position.y, get_viewport().size.y, 0)

func _maketurn():
	var _velocity: Vector2
	
	var cross = velocity.cross(desdir)
	if (cross > 0):
		$Sprite2D.rotation += deg_to_rad(steering_speed)
	elif (cross < 0):
		$Sprite2D.rotation -= deg_to_rad(steering_speed)
	
	desdir = Vector2.RIGHT.rotated($Sprite2D.rotation).normalized()
	_velocity = desdir * speed
	return _velocity
