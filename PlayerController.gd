extends Node3D

var character_mesh: MeshInstance3D
var vehicle_node: Node3D
var is_vehicle := false


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
	print("Araca gecildi.")


func switch_to_character() -> void:
	if vehicle_node:
		vehicle_node.visible = false
	character_mesh.visible = true
	is_vehicle = false
	print("Karaktere gecildi.")
