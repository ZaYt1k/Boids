extends Node

var map: Node2D
var radius_size: float
var separation_weight: float
var alignment_weight: float
var cohesion_weight: float
@onready var map_scene: PackedScene = preload("res://map.tscn")
@onready var boid_scene: PackedScene = preload("res://boid.tscn")

func _ready():
	map = map_scene.instantiate()
	add_child(map)

func _process(delta: float):
	radius_size = %Radius.get_node("HSlider").value
	separation_weight = %Separation.get_node("HSlider").value
	alignment_weight = %Alignment.get_node("HSlider").value
	cohesion_weight = %Cohesion.get_node("HSlider").value

func _restart_map():
	map.free()
	map = map_scene.instantiate()
	add_child(map)

func _add_boid():
	var boid = boid_scene.instantiate()
	map.add_child(boid)
	boid.global_position.x = randf_range(0, get_viewport().size.x)
	boid.global_position.y = randf_range(0, get_viewport().size.y)

func _remove_random_boid():
	var boids = map.get_children()
	var deleted = randi_range(0, boids.size() - 1)
	if (boids.size() > 0):
		boids[deleted].queue_free()

func _on_button_button_up() -> void:
	_restart_map()

func _on_add_button_up() -> void:
	_add_boid()

func _on_delete_button_up() -> void:
	_remove_random_boid()
