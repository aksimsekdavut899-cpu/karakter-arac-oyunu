extends RefCounted

# level2_layout.json dosyasini okuyup haritayi kuruyor.
#
# ONEMLI OPTIMIZASYON: 4994 obje var ama sadece 45 farkli sekil (mesh).
# Bunlari 4994 ayri MeshInstance3D yerine, her sekil icin TEK bir
# MultiMeshInstance3D kullanarak ekliyoruz (GPU "instancing" teknigi).
# Bu, zayif donanimli telefonlarda COK daha az yuk bindirir.
#
# NOT: Unity sol-elli, Godot sag-elli koordinat sistemi kullanir,
# bu yuzden Z eksenini ters ceviriyoruz.

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

	# Once tum transformlari mesh_file'a gore grupla
	var groups := {}  # mesh_file -> Array[Transform3D]
	var skipped_count := 0

	for entry in entries:
		var mesh_file = entry.get("mesh_file")
		var transform_data = entry.get("transform")

		if mesh_file == null or transform_data == null:
			skipped_count += 1
			continue

		var pos = transform_data.get("position", {"x": 0, "y": 0, "z": 0})
		var rot = transform_data.get("rotation", {"x": 0, "y": 0, "z": 0, "w": 1})
		var scl = transform_data.get("scale", {"x": 1, "y": 1, "z": 1})

		# Unity (sol-elli) -> Godot (sag-elli) donusumu
		var godot_pos = Vector3(pos.x, pos.y, -pos.z)
		var godot_quat = Quaternion(-rot.x, -rot.y, rot.z, rot.w).normalized()
		var godot_scale = Vector3(scl.x, scl.y, scl.z)

		var basis = Basis(godot_quat).scaled(godot_scale)
		var t3d = Transform3D(basis, godot_pos)

		if not groups.has(mesh_file):
			groups[mesh_file] = []
		groups[mesh_file].append(t3d)

	print("Farkli mesh grubu: ", groups.size())

	# Simdi her grup icin TEK bir MultiMeshInstance3D olustur
	var placed_groups := 0
	var placed_instances := 0

	for mesh_file in groups.keys():
		var mesh_path = MESH_DIR + str(mesh_file)
		if not ResourceLoader.exists(mesh_path):
			continue

		var mesh: Mesh = load(mesh_path)
		if mesh == null:
			continue

		var transforms: Array = groups[mesh_file]

		var multimesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = mesh
		multimesh.instance_count = transforms.size()

		for i in range(transforms.size()):
			multimesh.set_instance_transform(i, transforms[i])

		var mm_instance = MultiMeshInstance3D.new()
		mm_instance.name = str(mesh_file).replace(".obj", "")
		mm_instance.multimesh = multimesh

		parent.add_child(mm_instance)
		placed_groups += 1
		placed_instances += transforms.size()

	print("Yerlestirilen grup: ", placed_groups, " | Toplam obje: ", placed_instances, " | Atlanan: ", skipped_count)
