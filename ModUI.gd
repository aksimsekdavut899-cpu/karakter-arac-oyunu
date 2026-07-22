extends CanvasLayer

var player: Node3D
var menu_panel: Panel
var is_menu_open := false


func _ready() -> void:
	var icon_button = TextureButton.new()
	icon_button.texture_normal = load("res://ui/mod_icon.png")
	icon_button.custom_minimum_size = Vector2(70, 70)
	icon_button.position = Vector2(10, 10)
	icon_button.pressed.connect(_on_icon_pressed)
	add_child(icon_button)

	menu_panel = Panel.new()
	menu_panel.position = Vector2(10, 90)
	menu_panel.size = Vector2(240, 130)
	menu_panel.visible = false
	add_child(menu_panel)

	var label = Label.new()
	label.text = "Mod Menu"
	label.position = Vector2(10, 10)
	menu_panel.add_child(label)

	var switch_button = Button.new()
	switch_button.text = "Karakter / Arac Degistir"
	switch_button.position = Vector2(10, 50)
	switch_button.size = Vector2(220, 60)
	switch_button.pressed.connect(_on_switch_pressed)
	menu_panel.add_child(switch_button)


func _on_icon_pressed() -> void:
	is_menu_open = not is_menu_open
	menu_panel.visible = is_menu_open


func _on_switch_pressed() -> void:
	if player:
		player.toggle()


func set_player(p: Node3D) -> void:
	player = p
