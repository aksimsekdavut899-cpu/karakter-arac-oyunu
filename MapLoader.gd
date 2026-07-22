extends RefCounted

const LAYOUT_PATH = "res://harita/level2_layout.json"
const MESH_DIR = "res://harita/meshes/"
const TEXTURE_PATH = "res://harita/textures/SimpleApocalypse_542.png"


func build_map(parent: Node3D) -> void:
	if not FileAccess.file_exists(LAYOUT_PATH):
		push_error("Harita yerlesim dosyasi bulunamadi: " + LAYOUT_PATH)
		return

	var file = FileAccess.open(LAYOUT_PATH, FileAccess.READ)
	var text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(text)
	if parse_result != OK:
		push_error("Harita JSON okunamadi: " + json.get_error_message())
		return

	var entries: Array = json.data
	print("Harita giris sayisi: ", entries.size())

	var atlas_material = StandardMaterial3D.new()
	if ResourceLoader.exists(TEXTURE_PATH):
		var atlas_texture = load(TEXTURE_PATH)
		atlas_material.albedo_texture = atlas_texture
		atlas_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	else:
		push_error("Doku bulunamadi: " + TEXTURE_PATH)

	var unique_mesh_files := {}
	for entry in entries:
		var mesh_file = entry.get("mesh_file")
		if mesh_file != null:
			unique_mesh_files[mesh_file] = true

	print("Benzersiz mesh sayisi: ", unique_mesh_files.size())

	var placed_count := 0
	for mesh_file in unique_mesh_files.keys():
		var mesh_path = MESH_DIR + str(mesh_file)
		if not ResourceLoader.exists(mesh_path):
			continue

		var mesh: Mesh = load(mesh_path)
		if mesh == null:
			continue

		var mesh_instance = MeshInstance3D.new()
		mesh_instance.name = str(mesh_file).replace(".obj", "")
		mesh_instance.mesh = mesh
		mesh_instance.transform = Transform3D.IDENTITY
		mesh_instance.material_override = atlas_material

		parent.add_child(mesh_instance)
		placed_count += 1

	print("Yerlestirilen benzersiz parca: ", placed_count)
