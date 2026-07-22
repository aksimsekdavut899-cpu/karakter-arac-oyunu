extends RefCounted

const TEXTURE_PATH = "res://harita/textures/SimpleApocalypse_542.png"


func build_map(parent: Node3D) -> void:
print("Basit kutu testi baslatiliyor...")

var atlas_material = StandardMaterial3D.new()
if ResourceLoader.exists(TEXTURE_PATH):
var atlas_texture = load(TEXTURE_PATH)
atlas_material.albedo_texture = atlas_texture
atlas_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
print("Doku yuklendi.")
else:
print("HATA: doku bulunamadi!")

var box = BoxMesh.new()
box.size = Vector3(20, 20, 20)

var mesh_instance = MeshInstance3D.new()
mesh_instance.mesh = box
mesh_instance.material_override = atlas_material
mesh_instance.position = Vector3(0, 0, 0)

parent.add_child(mesh_instance)
print("Kutu eklendi.")
