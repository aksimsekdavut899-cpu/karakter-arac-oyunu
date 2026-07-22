extends CanvasLayer

var player: Node3D
var menu_panel: Panel
var is_menu_open := false


func _ready() -> void:
	var icon_button = TextureButton.new()
	icon_button.texture_normal = load("res://ui/mod_icon.png")
	icon_button.ignore_texture_size = true
	icon_button.stretch_mode = TextureButton.STRETCH_SCALE
	icon_button.position = Vector2(16, 16)
	icon_button.size = Vector2(80, 80)
	icon_button.pressed.connect(_on_icon_pressed)
	add_child(icon_button)

	menu_panel = Panel.new()
	menu_panel.position = Vector2(16, 106)
	menu_panel.size = Vector2(320, 220)
	menu_panel.visible = false

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.08, 0.1, 0.92)
	panel_style.border_color = Color(0.7, 0.7, 0.75)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 16
	panel_style.corner_radius_top_right = 16
	panel_style.corner_radius_bottom_left = 16
	panel_style.corner_radius_bottom_right = 16
	menu_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(menu_panel)

	var title = Label.new()
	title.text = "MOD AKSIMSEK"
	title.position = Vector2(20, 16)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	menu_panel.add_child(title)

	var switch_button = Button.new()
	switch_button.text = "Karakter / Arac Degistir"
	switch_button.position = Vector2(20, 70)
	switch_button.size = Vector2(280, 70)
	switch_button.add_theme_font_size_override("font_size", 20)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.15, 0.45, 0.85)
	btn_style.corner_radius_top_left = 12
	btn_style.corner_radius_top_right = 12
	btn_style.corner_radius_bottom_left = 12
	btn_style.corner_radius_bottom_right = 12
	switch_button.add_theme_stylebox_override("normal", btn_style)

	var btn_style_hover = StyleBoxFlat.new()
	btn_style_hover.bg_color = Color(0.2, 0.55, 0.95)
	btn_style_hover.corner_radius_top_left = 12
	btn_style_hover.corner_radius_top_right = 12
	btn_style_hover.corner_radius_bottom_left = 12
	btn_style_hover.corner_radius_bottom_right = 12
	switch_button.add_theme_stylebox_override("hover", btn_style_hover)

	switch_button.pressed.connect(_on_switch_pressed)
	menu_panel.add_child(switch_button)

	var status_label = Label.new()
	status_label.text = "Su an: Karakter"
	status_label.name = "StatusLabel"
	status_label.position = Vector2(20, 160)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	menu_panel.add_child(status_label)


func _on_icon_pressed() -> void:
	is_menu_open = not is_menu_open
	menu_panel.visible = is_menu_open


func _on_switch_pressed() -> void:
	if player:
		player.toggle()
		var status_label = menu_panel.get_node("StatusLabel")
		if player.is_vehicle:
			status_label.text = "Su an: Arac"
		else:
			status_label.text = "Su an: Karakter"


func set_player(p: Node3D) -> void:
	player = p
