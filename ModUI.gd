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

var preview_viewport: SubViewport
var preview_character: MeshInstance3D
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
	icon_button.gui_input.connect(_on_icon_gui_input)
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
	title.text = "« AKŞİMŞEK MOD »"
	title.position = Vector2(0, 18)
	title.size = Vector2(640, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(0.35, 1.0, 0.4))
	menu_panel.add_child(title)

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

	tab_character.modulate = Color(1, 1, 1)
	tab_vehicle.modulate = Color(0.5, 0.5, 0.5)

	var preview_button = Button.new()
	preview_button.flat = true
	preview_button.position = Vector2(20, 145)
	preview_button.size = Vector2(600, 240)
	preview_button.gui_input.connect(_on_preview_gui_input)
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
	penv.background_color = Color(0.15, 0.17, 0.22)
	preview_env.environment = penv
	preview_viewport.add_child(preview_env)

	var preview_light = DirectionalLight3D.new()
	preview_light.rotation_degrees = Vector3(-40, -30, 0)
	preview_viewport.add_child(preview_light)

	preview_camera = Camera3D.new()
	preview_viewport.add_child(preview_camera)

	preview_character = MeshInstance3D.new()
	var char_quad = QuadMesh.new()
	char_quad.size = Vector2(1.6, 2.4)
	preview_character.mesh = char_quad
	var char_mat = StandardMaterial3D.new()
	char_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	char_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var char_tex = load("res://ui/character_photo.png")
	if char_tex != null:
		char_mat.albedo_texture = char_tex
	else:
		char_mat.albedo_color = Color(0.2, 0.4, 0.9)
	preview_character.material_override = char_mat
	preview_character.position = Vector3(0, 1.2, 0)
	preview_viewport.add_child(preview_character)

	var vehicle_scene = load("res://harita/vehicles/bmw_m5.glb")
	if vehicle_scene != null:
		preview_vehicle = vehicle_scene.instantiate()
		preview_vehicle.position = Vector3(0, 0, 0)
		preview_vehicle.rotation.y = PI
		preview_vehicle.scale = Vector3(0.78, 0.78, 0.78)
		preview_viewport.add_child(preview_vehicle)

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


func _on_tab_character() -> void:
	selected_mode = "character"
	_show_character_preview()
	tab_character.modulate = Color(1, 1, 1)
	tab_vehicle.modulate = Color(0.5, 0.5, 0.5)


func _on_tab_vehicle() -> void:
	selected_mode = "vehicle"
	_show_vehicle_preview()
	tab_vehicle.modulate = Color(1, 1, 1)
	tab_character.modulate = Color(0.5, 0.5, 0.5)


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
	preview_camera.position = Vector3(1.6, 1.2, 2.6)
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


func _on_preview_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			preview_dragging = false
			preview_drag_start = event.position
		else:
			if not preview_dragging:
				_on_preview_tapped()
			preview_dragging = false
	elif event is InputEventScreenDrag:
		if event.position.distance_to(preview_drag_start) > 8:
			preview_dragging = true
		var current = preview_character if selected_mode == "character" else preview_vehicle
		if current:
			current.rotation.y -= event.relative.x * 0.01
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				preview_dragging = false
				preview_drag_start = event.position
			else:
				if not preview_dragging:
					_on_preview_tapped()
				preview_dragging = false
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			if event.position.distance_to(preview_drag_start) > 8:
				preview_dragging = true
			var current = preview_character if selected_mode == "character" else preview_vehicle
			if current:
				current.rotation.y -= event.relative.x * 0.01
