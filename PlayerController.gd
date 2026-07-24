extends Node3D

var character_mesh: MeshInstance3D
var vehicle_node: Node3D
var is_vehicle := false
var controls: Node = null

var move_speed := 4.0

var current_speed := 0.0
var max_speed := 28.0
var reverse_max_speed := 12.0
var accel_rate := 20.0
var brake_rate := 22.0
var friction_rate := 6.0
var wheelbase := 2.6

var steer_angle := 0.0
var max_steer_angle := 38.0
var steer_lerp_speed := 9.0

var front_wheels := []
var rear_wheels := []
var wheel_spin := 0.0
var wheel_radius := 0.33

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
		_identify_wheels(vehicle_node)

		debug_layer = CanvasLayer.new()
		debug_layer.layer = 6
		add_child(debug_layer)
		debug_label = Label.new()
		debug_label.position = Vector2(20, 20)
		debug_label.size = Vector2(650, 200)
		debug_label.add_theme_font_size_override("font_size", 14)
		debug_label.add_theme_color_override("font_color", Color(1, 1, 0))
		debug_layer.add_child(debug_label)
		debug_label.text = "On tekerlek: " + str(front_wheels.size()) + " | Arka tekerlek: " + str(rear_wheels.size())
		debug_label.visible = false
	else:
		push_error("BMW modeli yuklenemedi!")


func _identify_wheels(root: Node3D) -> void:
	var candidates = []
	_collect_mesh_centers(root, candidates)
	if candidates.size() < 4:
		return

	var min_y = candidates[0][1].y
	var max_y = candidates[0][1].y
	var min_z = candidates[0][1].z
	var max_z = candidates[0][1].z
	for c in candidates:
		min_y = min(min_y, c[1].y)
		max_y = max(max_y, c[1].y)
		min_z = min(min_z, c[1].z)
		max_z = max(max_z, c[1].z)

	var y_threshold = min_y + (max_y - min_y) * 0.35
	var z_mid = (min_z + max_z) * 0.5

	for c in candidates:
		var node = c[0]
		var center = c[1]
		if center.y <= y_threshold:
			if center.z < z_mid:
				front_wheels.append(node)
			else:
				rear_wheels.append(node)


func _collect_mesh_centers(node: Node, out_list: Array) -> void:
	for child in node.get_children():
		if child is MeshInstance3D and child.mesh != null:
			var aabb = child.mesh.get_aabb()
			var local_center = aabb.position + aabb.size / 2.0
			var world_center = child.global_transform * local_center
			var rel_center = vehicle_node.to_local(world_center)
			out_list.append([child, rel_center])
		_collect_mesh_centers(child, out_list)


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
	steer_angle = lerp(steer_angle, target_steer_angle, clamp(steer_lerp_speed * delta, 0.0, 1.0))

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

	wheel_spin += (current_speed / wheel_radius) * delta

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
