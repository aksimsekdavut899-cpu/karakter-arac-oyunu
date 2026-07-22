extends RefCounted

func build_map(parent: Node3D) -> void:
print("En basit kutu testi (sadece renk, hicbir ekstra ayar yok)...")

var red_material = StandardMaterial3D.new()
red_material.albedo_color = Color(1, 0, 0)

var box = BoxMesh.new()
box.size = Vector3(20, 20, 20)

var mesh_instance = MeshInstance3D.new()
mesh_instance.mesh = box
mesh_instance.material_override = red_material
mesh_instance.position = Vector3(0, 0, 0)

parent.add_child(mesh_instance)
print("Kutu eklendi.")
