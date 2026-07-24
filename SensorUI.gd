extends CanvasLayer

var player_ref: Node3D
var map_root: Node3D

var viewport: SubViewport
var cam: Camera3D
var display_rect: TextureRect
var player_marker: MeshInstance3D
var hologram_mat: StandardMaterial3D


func _ready() -> void:
	layer = 4

	viewport = SubViewport.new()
	viewport.size = Vector2i(260, 260)
	viewport.own_world_3d = true
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)

	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0, 0, 0, 0)
	env_node.environment = env
	viewport.add_child(env_node)

	cam = Camera3D.new()
	cam.position = Vector3(0, 30, 30)
	viewport.add_child(cam)

	hologram_mat = StandardMaterial3D.new()
	hologram_mat.albedo_color = Color(0, 1, 0, 0.4)
	hologram_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hologram_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hologram_mat.emission_enabled = true
	hologram_mat.emission = Color(0, 1, 0)
	hologram_mat.emission_energy_multiplier = 1.3

	_build_grid_floor()

	var vp_size = get_viewport().get_visible_rect().size
	display_rect = TextureRect.new()
	display_rect.position = Vector2(vp_size.x - 280, 20)
	display_rect.size = Vector2(260, 260)
	display_rect.texture = viewport.get_texture()
	display_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(display_rect)

	var border = StyleBoxFlat.new()
	border.bg_color = Color(0, 0, 0, 0)
	border.border_width_left = 2
	border.border_width_right = 2
	border.border_width_top = 2
	border.border_width_bottom = 2
	border.border_color = Color(0.2, 1, 0.3, 0.8)
	var border_panel = Panel.new()
	border_panel.position = display_rect.position
	border_panel.size = display_rect.size
	border_panel.add_theme_stylebox_override("panel", border)
	border_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(border_panel)


func _build_grid_floor() -> void:
	var grid_mesh = ArrayMesh.new()
	var verts = PackedVector3Array()
	var count = 20
	var extent = 60.0
	var step = extent * 2.0 / count
	for i in range(count + 1):
		var x = -extent + i * step
		verts.append(Vector3(x, 0, -extent))
		verts.append(Vector3(x, 0, extent))
	for i in range(count + 1):
		var z = -extent + i * step
		verts.append(Vector3(-extent, 0, z))
		verts.append(Vector3(extent, 0, z))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	grid_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	var grid_instance = MeshInstance3D.new()
	grid_instance.mesh = grid_mesh
	var grid_mat = StandardMaterial3D.new()
	grid_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	grid_mat.albedo_color = Color(0.15, 1.0, 0.25, 0.5)
	grid_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grid_instance.material_override = grid_mat
	viewport.add_child(grid_instance)


func setup_world(player: Node3D, map: Node3D) -> void:
	player_ref = player
	map_root = map
	_duplicate_meshes(map_root)


func _duplicate_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D and child.mesh != null:
			var dup = MeshInstance3D.new()
			dup.mesh = child.mesh
			dup.global_transform = child.global_transform
			dup.material_override = hologram_mat
			viewport.add_child(dup)
		_duplicate_meshes(child)


func _process(delta: float) -> void:
	if not player_ref:
		return
	if not player_marker:
		player_marker = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(1.5, 1.0, 3.0)
		player_marker.mesh = box
		var marker_mat = StandardMaterial3D.new()
		marker_mat.albedo_color = Color(0.3, 1.0, 0.4, 0.9)
		marker_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		marker_mat.emission_enabled = true
		marker_mat.emission = Color(0.3, 1.0, 0.4)
		marker_mat.emission_energy_multiplier = 2.0
		player_marker.material_override = marker_mat
		viewport.add_child(player_marker)

	player_marker.global_position = player_ref.global_position
	player_marker.rotation.y = player_ref.rotation.y

	cam.global_position = player_ref.global_position + Vector3(0, 30, 30)
	cam.look_at(player_ref.global_position, Vector3.UP)
