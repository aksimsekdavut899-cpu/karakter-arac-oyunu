extends Node3D

var character_mesh: MeshInstance3D
var vehicle_node: Node3D
var is_vehicle := false
var controls: Node = null

var move_speed := 4.0

var current_speed := 0.0
var max_speed := 14.0
var reverse_max_speed := 6.0
var accel_rate := 11.0
var brake_rate := 14.0
var friction_rate := 5.0
var wheelbase := 2.6

var steer_angle := 0.0
var max_steer_angle := 32.0
var steer_speed := 220.0

var debug_layer: CanvasLayer
var debug_label: Label


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
		vehicle_node.scale = Vector3(0.65, 0.65, 0.65)
		vehicle_node.visible = false
		add_child(vehicle_node)

		debug_layer = CanvasLayer.new()
		debug_layer.layer = 6
		add_child(debug_layer)
		debug_label = Label.new()
		debug_label.position = Vector2(20, 20)
		debug_label.size = Vector2(650, 900)
		debug_label.add_theme_font_size_override("font_size", 13)
		debug_label.add_theme_color_override("font_color", Color(1, 1, 0))
		debug_layer.add_child(debug_label)
		debug_label.text = _collect_node_names(vehicle_node, 0)
		debug_label.visible = false
	else:
		push_error("BMW modeli yuklenemedi!")


func _collect_node_names(node: Node, depth: int) -> String:
	var s = ""
	for child in node.get_children():
		var prefix = ""
		for i in range(depth):
			prefix += "  "
		s += prefix + child.name + " (" + child.get_class() + ")\n"
		s += _collect_node_names(child, depth + 1)
	return s


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
	var steer_input = 0.0
	if controls.is_steer_left():
		steer_input += 1.0
	if controls.is_steer_right():
		steer_input -= 1.0

	var target_steer_angle = steer_input * max_steer_angle
	steer_angle = move_toward(steer_angle, target_steer_angle, steer_speed * delta)

	if controls.is_accel():
		current_speed = move_toward(current_speed, max_speed, accel_rate * delta)
	elif controls.is_brake():
		if current_speed > 0.05:
			current_speed = move_toward(current_speed, 0.0, brake_rate * delta)
		else:
			current_speed = move_toward(current_speed, -reverse_max_speed, accel_rate * 0.7 * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, friction_rate * delta)

	if abs(current_speed) > 0.05:
		var speed_ratio = clamp(abs(current_speed) / max_speed, 0.0, 1.0)
		var effective_steer_deg = steer_angle * (1.15 - speed_ratio * 0.45)
		var steer_rad = deg_to_rad(effective_steer_deg)
		var turn_rate = (current_speed / wheelbase) * tan(steer_rad)
		rotate_y(turn_rate * delta)

	var forward = -global_transform.basis.z
	position += forward * current_speed * delta

	if vehicle_node:
		var speed_ratio2 = clamp(abs(current_speed) / max_speed, 0.0, 1.0)
		var target_lean = clamp(-steer_angle * 0.08 * speed_ratio2, -5.0, 5.0)
		vehicle_node.rotation_degrees.z = lerp(vehicle_node.rotation_degrees.z, target_lean, 6.0 * delta)


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
	current_speed = 0.0
	steer_angle = 0.0
	if controls:
		controls.set_vehicle_mode(true)
	if debug_label:
		debug_label.visible = true
	print("Araca gecildi.")


func switch_to_character() -> void:
	if vehicle_node:
		vehicle_node.visible = false
		vehicle_node.rotation_degrees.z = 0.0
	character_mesh.visible = true
	is_vehicle = false
	if controls:
		controls.set_vehicle_mode(false)
	if debug_label:
		debug_label.visible = false
	print("Karaktere gecildi.")
