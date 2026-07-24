extends Node3D

var character_mesh: MeshInstance3D
var vehicle_node: Node3D
var is_vehicle := false
var controls: Node = null

var move_speed := 4.0
var vehicle_speed := 9.0
var turn_speed := 2.0


func _ready() -> void:
	character_mesh = MeshInstance3D.new()
	var capsule = CapsuleMesh.new()
	capsule.height = 2.0
	capsule.radius = 0.4
	character_mesh.mesh = capsule
	var char_mat = StandardMaterial3D.new()
	char_mat.albedo_color = Color(0.2, 0.4, 0.9)
	char_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	character_mesh.material_override = char_mat
	character_mesh.position = Vector3(0, 1.0, 0)
	add_child(character_mesh)

	var vehicle_scene = load("res://harita/vehicles/bmw_m5.glb")
	if vehicle_scene != null:
		vehicle_node = vehicle_scene.instantiate()
		vehicle_node.position = Vector3(0, 0, 0)
		vehicle_node.visible = false
		add_child(vehicle_node)
	else:
		push_error("BMW modeli yuklenemedi!")


func _process(delta: float) -> void:
	if not controls:
		return
	if is_vehicle:
		_process_vehicle(delta)
	else:
		_process_character(delta)


func _process_character(delta: float) -> void:
	var move_vector = controls.get_move_vector()
	if move_vector.length() > 0.1:
		var move_dir = Vector3(move_vector.x, 0, move_vector.y)
		position += move_dir * move_speed * delta
		look_at(global_position + move_dir, Vector3.UP)


func _process_vehicle(delta: float) -> void:
	var forward = -global_transform.basis.z
	if controls.is_accel():
		position += forward * vehicle_speed * delta
	if controls.is_brake():
		position -= forward * vehicle_speed * 0.6 * delta
	if controls.is_steer_left():
		rotate_y(turn_speed * delta)
	if controls.is_steer_right():
		rotate_y(-turn_speed * delta)


func set_controls(c: Node) -> void:
	controls = c


func toggle() -> void:
	if is_vehicle:
		switch_to_character()
	else:
		switch_to_vehicle()


func switch_to_vehicle() -> void:
	if vehicle_node:
		vehicle_node.visible = true
	character_mesh.visible = false
	is_vehicle = true
	if controls:
		controls.set_vehicle_mode(true)
	print("Araca gecildi.")


func switch_to_character() -> void:
	if vehicle_node:
		vehicle_node.visible = false
	character_mesh.visible = true
	is_vehicle = false
	if controls:
		controls.set_vehicle_mode(false)
	print("Karaktere gecildi.")
