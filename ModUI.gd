extends CanvasLayer

var player: Node3D
var menu_panel: Panel
var is_menu_open := false
var selected_mode := "character"
var is_dragging := false
var drag_offset := Vector2.ZERO
var drag_start_pos := Vector2.ZERO
var preview_dragging := false
var preview_drag_start := Vector2.ZERO
var icon_touch_active := false

var preview_viewport: SubViewport
var preview_character: Node3D
var preview_vehicle: Node3D
var preview_camera: Camera3D

var tab_character: Button
var tab_vehicle: Button
var status_label: Label
var icon_button: TextureButton


func _ready() -> void:
	icon_button = TextureButton.new()
	icon_button.texture_normal = load("res://ui/mod_icon.png")
	icon_button.ignore_texture_size = true
	icon_button.stretch_mode = TextureButton.STRETCH_SCALE
	icon_button.position = Vector2(16, 16)
	icon_button.size = Vector2(200, 200)
	icon_button.pressed.connect(_on_icon_pressed)
	add_child(icon_button)

	menu_panel = Panel.new()
	menu_panel.position = Vector2(16, 226)
	menu_panel.size = Vector2(640, 440)
	menu_panel.visible = false

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.07, 0.09, 0.95)
	panel_style.border_color = Color(0.25, 1.0, 0.35)
	panel_style.shadow_size = 16
	panel_style.shadow_color = Color(0.1, 0.9, 0.3, 0.55)
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 20
	panel_style.corner_radius_top_right = 20
	panel_style.corner_radius_bottom_left = 20
	panel_style.corner_radius_bottom_right = 20
	menu_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(menu_panel)

	var title = Label.new()
	title.text = "AKŞİMŞEK MOD"
	title.position = Vector2(0, 18)
	title.size = Vector2(640, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.35, 1.0, 0.4))
	title.add_theme_color_override("font_outline_color", Color(0.15, 0.9, 0.25, 0.85))
	title.add_theme_constant_override("outline_size", 6)
	menu_panel.add_child(title)

	var bolt = Label.new()
	bolt.text = "⚡"
	bolt.position = Vector2(0, 46)
	bolt.size = Vector2(640, 24)
	bolt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bolt.add_theme_font_size_override("font_size", 18)
	bolt.add_theme_color_override("font_color", Color(0.35, 1.0, 0.4))
	menu_panel.add_child(bolt)

	var divider = ColorRect.new()
	divider.color = Color(0.25, 1.0, 0.35, 0.5)
	divider.position = Vector2(20, 64)
	divider.size = Vector2(600, 2)
	menu_panel.add_child(divider)

	tab_character = Button.new()
	tab_character.text = "KARAKTER"
	tab_character.position = Vector2(20, 70)
	tab_character.size = Vector2(295, 60)
	tab_character.add_theme_font_size_override("font_size", 20)
	tab_character.pressed.connect(_on_tab_character)
	menu_panel.add_child(tab_character)

	tab_vehicle = Button.new()
	tab_vehicle.text = "ARAC"
	tab_vehicle.position = Vector2(325, 70)
	tab_vehicle.size = Vector2(295, 60)
	tab_vehicle.add_theme_font_size_override("font_size", 20)
	tab_vehicle.pressed.connect(_on_tab_vehicle)
	menu_panel.add_child(tab_vehicle)

	_style_tab(tab_character, true)
	_style_tab(tab_vehicle, false)

	var preview_button = Button.new()
	preview_button.flat = true
	preview_button.position = Vector2(20, 145)
	preview_button.size = Vector2(600, 240)
	preview_button.pressed.connect(_on_preview_tapped)
	menu_panel.add_child(preview_button)

	preview_viewport = SubViewport.new()
	preview_viewport.size = Vector2i(600, 240)
	preview_viewport.own_world_3d = true
	preview_viewport.transparent_bg = false
	preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(preview_viewport)

	var preview_env = WorldEnvironment.new()
	var penv = Environment.new()
	penv.background_mode = Environment.BG_COLOR
	penv.background_color = Color(0.02, 0.02, 0.03)
	preview_env.environment = penv
	preview_viewport.add_child(preview_env)

	var preview_light = DirectionalLight3D.new()
	preview_light.rotation_degrees = Vector3(-40, -30, 0)
	preview_viewport.add_child(preview_light)
	_add_preview_grid_floor()

	preview_camera = Camera3D.new()
	preview_viewport.add_child(preview_camera)

	preview_character = Node3D.new()
	preview_character.position = Vector3(0, 0, 0)
	var pc_parts = []
	pc_parts.append([Vector3(0.4, 0.4, 0.4), Vector3(0, 1.7, 0)])
	pc_parts.append([Vector3(0.5, 0.7, 0.3), Vector3(0, 1.15, 0)])
	pc_parts.append([Vector3(0.18, 0.6, 0.18), Vector3(-0.34, 1.15, 0)])
	pc_parts.append([Vector3(0.18, 0.6, 0.18), Vector3(0.34, 1.15, 0)])
	pc_parts.append([Vector3(0.2, 0.7, 0.2), Vector3(-0.13, 0.45, 0)])
	pc_parts.append([Vector3(0.2, 0.7, 0.2), Vector3(0.13, 0.45, 0)])
	for part in pc_parts:
		var part_mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = part[0]
		part_mesh.mesh = box
		part_mesh.position = part[1]
		preview_character.add_child(part_mesh)
	preview_viewport.add_child(preview_character)
	_apply_hologram(preview_character, Color(0.2, 1.0, 0.4))

	var vehicle_scene = load("res://harita/vehicles/bmw_m5.glb")
	if vehicle_scene != null:
		preview_vehicle = vehicle_scene.instantiate()
		preview_vehicle.position = Vector3(0, 0, 0)
		preview_vehicle.scale = Vector3(0.78, 0.78, 0.78)
		preview_viewport.add_child(preview_vehicle)
		_apply_hologram(preview_vehicle, Color(0.2, 1.0, 0.4))
	else:
		var debug_box = MeshInstance3D.new()
		var db = BoxMesh.new()
		db.size = Vector3(1, 1, 1)
		debug_box.mesh = db
		var db_mat = StandardMaterial3D.new()
		db_mat.albedo_color = Color(1, 0, 1)
		db_mat.emission_enabled = true
		db_mat.emission = Color(1, 0, 1)
		debug_box.material_override = db_mat
		debug_box.position = Vector3(0, 0.5, 0)
		preview_viewport.add_child(debug_box)
	else:
		var debug_box = MeshInstance3D.new()
		var db = BoxMesh.new()
		db.size = Vector3(1, 1, 1)
		debug_box.mesh = db
		var db_mat = StandardMaterial3D.new()
		db_mat.albedo_color = Color(1, 0, 1)
		db_mat.emission_enabled = true
		db_mat.emission = Color(1, 0, 1)
		debug_box.material_override = db_mat
		debug_box.position = Vector3(0, 0.5, 0)
		preview_viewport.add_child(debug_box)

	var preview_rect = TextureRect.new()
	preview_rect.position = Vector2(20, 145)
	preview_rect.size = Vector2(600, 240)
	preview_rect.texture = preview_viewport.get_texture()
	preview_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_panel.add_child(preview_rect)

	status_label = Label.new()
	status_label.text = "Su an: Karakter"
	status_label.position = Vector2(20, 395)
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	menu_panel.add_child(status_label)

	_show_character_preview()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			var r = Rect2(icon_button.position, icon_button.size)
			if r.has_point(event.position):
				icon_touch_active = true
				is_dragging = false
				drag_start_pos = event.position
				drag_offset = event.position - icon_button.position
		else:
			icon_touch_active = false
			is_dragging = false
	elif event is InputEventScreenDrag:
		if icon_touch_active:
			if event.position.distance_to(drag_start_pos) > 10:
				is_dragging = true
			if is_dragging:
				icon_button.position = event.position - drag_offset
				_update_panel_position()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var r2 = Rect2(icon_button.position, icon_button.size)
				if r2.has_point(event.position):
					icon_touch_active = true
					is_dragging = false
					drag_start_pos = event.position
					drag_offset = event.position - icon_button.position
			else:
				icon_touch_active = false
				is_dragging = false
	elif event is InputEventMouseMotion:
		if icon_touch_active and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			if event.position.distance_to(drag_start_pos) > 10:
				is_dragging = true
			if is_dragging:
				icon_button.position = event.position - drag_offset
				_update_panel_position()


func _on_icon_pressed() -> void:
	if is_dragging:
		return
	is_menu_open = not is_menu_open
	menu_panel.visible = is_menu_open


func _on_icon_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = false
			drag_start_pos = event.position
			drag_offset = event.position - icon_button.position
		else:
			is_dragging = false
	elif event is InputEventScreenDrag:
		if event.position.distance_to(drag_start_pos) > 12:
			is_dragging = true
		if is_dragging:
			icon_button.position = event.position - drag_offset
			_update_panel_position()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = false
				drag_start_pos = event.position
				drag_offset = event.position - icon_button.position
			else:
				is_dragging = false
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			if event.position.distance_to(drag_start_pos) > 12:
				is_dragging = true
			if is_dragging:
				icon_button.position = event.position - drag_offset
				_update_panel_position()


func _update_panel_position() -> void:
	menu_panel.position = Vector2(icon_button.position.x, icon_button.position.y + icon_button.size.y + 10)


func _apply_hologram(node: Node, base_color: Color) -> void:
	if node is MeshInstance3D:
		var holo_mat = StandardMaterial3D.new()
		holo_mat.albedo_color = Color(base_color.r, base_color.g, base_color.b, 0.06)
		holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		holo_mat.emission_enabled = true
		holo_mat.emission = base_color
		holo_mat.emission_energy_multiplier = 2.2
		holo_mat.rim_enabled = true
		holo_mat.rim = 1.0
		holo_mat.rim_tint = 0.85
		holo_mat.metallic = 0.0
		holo_mat.roughness = 1.0
		holo_mat.grow_amount = 0.01
		holo_mat.grow = true
		node.material_override = holo_mat
	for child in node.get_children():
		_apply_hologram(child, base_color)


func _add_preview_grid_floor() -> void:
	var grid_mesh = ArrayMesh.new()
	var verts = PackedVector3Array()
	var count = 16
	var extent = 5.0
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
	grid_mat.albedo_color = Color(0.3, 1.0, 0.4, 0.9)
	grid_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grid_instance.material_override = grid_mat
	grid_instance.position = Vector3(0, -0.05, 0)
	preview_viewport.add_child(grid_instance)


func _on_tab_character() -> void:
	selected_mode = "character"
	_show_character_preview()
	_style_tab(tab_character, true)
	_style_tab(tab_vehicle, false)


func _on_tab_vehicle() -> void:
	selected_mode = "vehicle"
	_show_vehicle_preview()
	_style_tab(tab_vehicle, true)
	_style_tab(tab_character, false)


func _style_tab(btn: Button, active: bool) -> void:
	var sb = StyleBoxFlat.new()
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	if active:
		sb.bg_color = Color(0.06, 0.16, 0.08, 0.9)
		sb.border_color = Color(0.35, 1.0, 0.4)
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
	else:
		sb.bg_color = Color(0.05, 0.05, 0.05, 0.9)
		sb.border_color = Color(0.15, 0.15, 0.15)
		btn.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)


func _show_character_preview() -> void:
	preview_character.visible = true
	if preview_vehicle:
		preview_vehicle.visible = false
	preview_camera.position = Vector3(1.2, 1.3, 3.2)
	preview_camera.look_at(Vector3(0, 1.0, 0), Vector3.UP)


func _show_vehicle_preview() -> void:
	preview_character.visible = false
	if preview_vehicle:
		preview_vehicle.visible = true
	preview_camera.position = Vector3(2.4, 1.5, 4.3)
	preview_camera.look_at(Vector3(0, 0.6, 0), Vector3.UP)


func _on_preview_tapped() -> void:
	if not player:
		return
	if selected_mode == "character":
		player.switch_to_character()
		status_label.text = "Su an: Karakter"
	else:
		player.switch_to_vehicle()
		status_label.text = "Su an: Arac"


func set_player(p: Node3D) -> void:
	player = p
