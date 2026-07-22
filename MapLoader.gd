extends RefCounted

func build_map(parent: Node3D) -> void:
print("Malzemesiz kutu testi...")

var box = BoxMesh.new()
box.size = Vector3(20, 20, 20)

var mesh_instance = MeshInstance3D.new()
mesh_instance.mesh = box
mesh_instance.position = Vector3(0, 0, 0)

parent.add_child(mesh_instance)
print("Kutu eklendi (malzemesiz).")
