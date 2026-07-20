extends RefCounted

# level2_layout.json dosyasini okuyup, icindeki her obje icin
# ilgili .obj mesh'ini res://harita/meshes/ klasorunden yukleyip
# dogru konum/donus/olcekte sahneye ekler.
#
# ONEMLI NOT: Unity sol-elli (left-handed) koordinat sistemi kullanir,
# Godot sag-elli (right-handed) kullanir. Bu yuzden Z eksenini ters
# ceviriyoruz. Ilk build'de harita ters/aynali gorunurse, ilk kontrol
# edilecek yer burasidir (asagidaki donusum formulu).

const LAYOUT_PATH = "res://harita/level2_layout.json"
const MESH_DIR = "res://harita/meshes/"


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
	print("Harita objesi sayisi: ", entries.size())

	var mesh_cache := {}
	var placed_count := 0
	var skipped_count := 0

	for entry in entries:
		var mesh_file = entry.get("mesh_file")
		var transform_data = entry.get("transform")

		if mesh_file == null or transform_data == null:
			skipped_count += 1
			continue

		var mesh: Mesh = null
		if mesh_cache.has(mesh_file):
			mesh = mesh_cache[mesh_file]
		else:
			var mesh_path = MESH_DIR + str(mesh_file)
			if ResourceLoader.exists(mesh_path):
				mesh = load(mesh_path)
			mesh_cache[mesh_file] = mesh

		if mesh == null:
			skipped_count += 1
			continue

		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = mesh
		mesh_instance.name = str(entry.get("game_object_name", "obje"))

		var pos = transform_data.get("position", {"x": 0, "y": 0, "z": 0})
		var rot = transform_data.get("rotation", {"x": 0, "y": 0, "z": 0, "w": 1})
		var scl = transform_data.get("scale", {"x": 1, "y": 1, "z": 1})

		# Unity (sol-elli) -> Godot (sag-elli) donusumu: Z eksenini ters cevir
		var godot_pos = Vector3(pos.x, pos.y, -pos.z)
		var godot_quat = Quaternion(-rot.x, -rot.y, rot.z, rot.w).normalized()
		var godot_scale = Vector3(scl.x, scl.y, scl.z)

		var basis = Basis(godot_quat).scaled(godot_scale)
		mesh_instance.transform = Transform3D(basis, godot_pos)

		parent.add_child(mesh_instance)
		placed_count += 1

	print("Yerlestirilen obje: ", placed_count, " | Atlanan: ", skipped_count)
