extends CharacterBody2D

var desdir: Vector2
var speed: int = 300
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@export var area: Area2D
var areas: Array[Area2D]
var steering_speed: float = 1.5

func _ready() -> void:
	desdir = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1))
	desdir = desdir.normalized()
	velocity = desdir * speed
	print(velocity)
	$Sprite2D.rotation = velocity.angle()
	move_and_slide()

func _process(delta: float) -> void:
	_overflow()
	areas = area.get_overlapping_areas()
	$VelocityLine.set_point_position(1, velocity.normalized() * 210)
	
	desdir += _separation()
	desdir += _alignment()
	desdir += _cohesion()
	
	desdir = desdir.normalized()
	
	var cross = velocity.cross(desdir)
	if (cross > 0):
		print("right")
		$Sprite2D.rotation += deg_to_rad(steering_speed)
	elif (cross < 0):
		$Sprite2D.rotation -= deg_to_rad(steering_speed)
	else:
		print("nowhere")
	
	desdir = Vector2.RIGHT.rotated($Sprite2D.rotation).normalized()
	velocity = desdir * speed
	move_and_slide()

func _separation():
	var dir = Vector2.ZERO
	for i in areas:
		dir += global_position.direction_to(i.get_parent().global_position) / global_position.distance_to(i.get_parent().global_position)
	dir = dir * -1
	dir = dir.normalized()
	return dir

func _alignment():
	var dir = Vector2.ZERO
	for i in areas:
		var par = i.get_parent()
		dir += par.velocity.normalized()
	dir = dir.normalized()
	return dir

func _cohesion():
	var dir = Vector2.ZERO
	var j = 0
	for i in areas:
		var par = i.get_parent()
		dir += par.global_position
		j += 1
	dir = dir / j
	dir = global_position.direction_to(dir)
	return dir

func _overflow():
	if (global_position.x > get_viewport().size.x):
		global_position.x = 0
	elif (global_position.x < 0):
		global_position.x = get_viewport().size.x
		
	if (global_position.y > get_viewport().size.y):
		global_position.y = 0
	elif (global_position.y < 0):
		global_position.y = get_viewport().size.y
