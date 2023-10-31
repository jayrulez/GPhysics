extends Node3D

@onready var box_scene = preload("res://box.tscn")

var default_box: Node3D = null

@export var spawn_cool_down = 0.125
var current_cool_down = 0.0;
var spawn_count = 0
var stop_spawning = false
@export var spawn_batch_size = 10
@export var spawn_limit = 8000

var default_material: StandardMaterial3D = null
var custom_materials = Array()
@export var use_custom_material = true


var boxes = Array()

var rng = RandomNumberGenerator.new()

var fps_label: Label = null
var counter_label: Label = null


# Called when the node enters the scene tree for the first time.
func _ready():
	current_cool_down = spawn_cool_down
	default_box = box_scene.instantiate()
	default_material = _create_material()
	
	fps_label = find_child("UI").find_child("FPSLabel") as Label
	counter_label = find_child("UI").find_child("CounterLabel") as Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	print("current_cool_down: " + str(current_cool_down))
	if current_cool_down <= 0:
		spawn_cubes()
		current_cool_down = spawn_cool_down
	
	current_cool_down -= delta
	
	_update_fps_text()
	
func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			stop_spawning = !stop_spawning
			
		if event.keycode == KEY_M:
			_change_materials()
	
func _update_fps_text():
	fps_label.set_text("FPS: " + str(Engine.get_frames_per_second()))
	counter_label.set_text("Objects: " + str(spawn_count))
	
func _create_material() -> StandardMaterial3D:
	var mesh = default_box.find_child("Mesh") as MeshInstance3D
	var material = mesh.get_active_material(0).duplicate() as StandardMaterial3D
	
	var r = rng.randf()
	var g = rng.randf()
	var b = rng.randf()
	
	material.albedo_color = Color(r, g, b)
	
	return material
	
func _change_materials():
	use_custom_material = !use_custom_material;
	if use_custom_material:
		print("Using custom material")
	else:
		print("Using default material")
		
	for i in spawn_count:
		var mesh = boxes[i].find_child("Mesh") as MeshInstance3D
		if use_custom_material:
			if custom_materials[i] == null:
				custom_materials[i] = _create_material()
			mesh.set_surface_override_material(0, custom_materials[i])
		else:
			mesh.set_surface_override_material(0, default_material)
			custom_materials[i] = null
	
func spawn_cubes():
	if spawn_count >= spawn_limit:
		stop_spawning = true
	
	if box_scene == null or stop_spawning:
		return
		
	for i in spawn_batch_size:
		var box = box_scene.instantiate()
		box.position = Vector3(rng.randi_range(-35, 35), 80, rng.randi_range(-35, 35))
		boxes.append(box)
		add_child(box)
		spawn_count = spawn_count + 1
		custom_materials.append(null)
		var mesh = box.find_child("Mesh") as MeshInstance3D
		if use_custom_material:
			var material: StandardMaterial3D = _create_material()
			custom_materials[i] = null
			mesh.set_surface_override_material(0, material)
		else:
			mesh.set_surface_override_material(0, default_material)
	
