extends CanvasLayer

var move_vector := Vector2.ZERO
var is_vehicle_mode := false

var joystick_bg: Control
var joystick_knob: Control
var joystick_active := false
var joystick_touch_index := -1
var joystick_center := Vector2.ZERO
var joystick_radius := 70.0

var jump_button: Button
var crouch_button: Button
var accel_button: Button
var brake_button: Button
var steer_left_button: Button
var steer_right_button: Button

var accel_held := false
var brake_held := false
var steer_left_held := false
var steer_right_held := false


func _ready() -> void:
	layer = 5
	var vp_size = get_viewport().get_visible_rect().size

	joystick_bg = Control.new()
	joystick_bg.position = Vector2(60, vp_size.y - 220)
	joystick_bg.size = Vector2(140, 140)
	joystick_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(joystick_bg)

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(1, 1, 1, 0.15)
	bg_style.corner_radius_top_left = 70
	bg_style.corner_radius_top_right = 70
	bg_style.corner_radius_bottom_left = 70
	bg_style.corner_radius_bottom_right = 70
	bg_style.border_width_left = 3
	bg_style.border_width_right = 3
	bg_style.border_width_top = 3
	bg_style.border_width_bottom = 3
	bg_style.border_color = Color(1, 1, 1, 0.5)
	var bg_panel = Panel.new()
	bg_panel.size = Vector2(140, 140)
	bg_panel.add_theme_stylebox_override("panel", bg_style)
	bg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	joystick_bg.add_child(bg_panel)

	joystick_knob = Control.new()
	joystick_knob.position = Vector2(40, 40)
	joystick_knob.size = Vector2(60, 60)
	joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	joystick_bg.add_child(joystick_knob)

	var knob_style = StyleBoxFlat.new()
	knob_style.bg_color = Color(1, 1, 1, 0.55)
	knob_style.corner_radius_top_left = 30
	knob_style.corner_radius_top_right = 30
	knob_style.corner_radius_bottom_left = 30
	knob_style.corner_radius_bottom_right = 30
	var knob_panel = Panel.new()
	knob_panel.size = Vector2(60, 60)
	knob_panel.add_theme_stylebox_override("panel", knob_style)
	knob_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	joystick_knob.add_child(knob_panel)

	joystick_center = joystick_bg.position + joystick_bg.size / 2.0

	jump_button = _make_round_button(Vector2(vp_size.x - 100, vp_size.y - 260), "^")
	crouch_button = _make_round_button(Vector2(vp_size.x - 210, vp_size.y - 180), "v")

	accel_button = _make_round_button(Vector2(vp_size.x - 100, vp_size.y - 260), "^")
	brake_button = _make_round_button(Vector2(vp_size.x - 100, vp_size.y - 150), "v")
	steer_left_button = _make_round_button(Vector2(60, vp_size.y - 200), "<")
	steer_right_button = _make_round_button(Vector2(170, vp_size.y - 200), ">")

	accel_button.button_down.connect(func(): accel_held = true)
	accel_button.button_up.connect(func(): accel_held = false)
	brake_button.button_down.connect(func(): brake_held = true)
	brake_button.button_up.connect(func(): brake_held = false)
	steer_left_button.button_down.connect(func(): steer_left_held = true)
	steer_left_button.button_up.connect(func(): steer_left_held = false)
	steer_right_button.button_down.connect(func(): steer_right_held = true)
	steer_right_button.button_up.connect(func(): steer_right_held = false)

	set_vehicle_mode(false)


func _make_round_button(pos: Vector2, label: String) -> Button:
	var btn = Button.new()
	btn.text = label
	btn.position = pos
	btn.size = Vector2(90, 90)
	btn.add_theme_font_size_override("font_size", 30)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.18)
	style.corner_radius_top_left = 45
	style.corner_radius_top_right = 45
	style.corner_radius_bottom_left = 45
	style.corner_radius_bottom_right = 45
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(1, 1, 1, 0.6)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	add_child(btn)
	return btn


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if joystick_touch_index == -1 and joystick_bg.visible and event.position.distance_to(joystick_center) < 120:
				joystick_touch_index = event.index
				joystick_active = true
				_update_joystick(event.position)
		else:
			if event.index == joystick_touch_index:
				joystick_touch_index = -1
				joystick_active = false
				move_vector = Vector2.ZERO
				joystick_knob.position = Vector2(40, 40)
	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_index and joystick_active:
			_update_joystick(event.position)


func _update_joystick(touch_pos: Vector2) -> void:
	var offset = touch_pos - joystick_center
	if offset.length() > joystick_radius:
		offset = offset.normalized() * joystick_radius
	joystick_knob.position = Vector2(40, 40) + offset
	move_vector = offset / joystick_radius


func set_vehicle_mode(vehicle: bool) -> void:
	is_vehicle_mode = vehicle
	jump_button.visible = not vehicle
	crouch_button.visible = not vehicle
	joystick_bg.visible = not vehicle
	accel_button.visible = vehicle
	brake_button.visible = vehicle
	steer_left_button.visible = vehicle
	steer_right_button.visible = vehicle


func get_move_vector() -> Vector2:
	return move_vector


func is_accel() -> bool:
	return accel_held


func is_brake() -> bool:
	return brake_held


func is_steer_left() -> bool:
	return steer_left_held


func is_steer_right() -> bool:
	return steer_right_held
