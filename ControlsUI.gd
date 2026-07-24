extends CanvasLayer

var move_vector := Vector2.ZERO
var is_vehicle_mode := false

var joystick_bg: Control
var joystick_knob: Control
var joystick_touch_index := -1
var joystick_center := Vector2.ZERO
var joystick_radius := 70.0

var jump_panel: Control
var crouch_panel: Control
var accel_panel: Control
var brake_panel: Control
var steer_left_panel: Control
var steer_right_panel: Control

var accel_held := false
var brake_held := false
var steer_left_held := false
var steer_right_held := false

var touch_actions := {}
var look_touch_index := -1
var look_delta := Vector2.ZERO
var free_touches := {}
var last_pinch_dist := 0.0
var zoom_delta := 0.0


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

	jump_panel = _make_action_panel(Vector2(vp_size.x - 100, vp_size.y - 260), "^")
	crouch_panel = _make_action_panel(Vector2(vp_size.x - 210, vp_size.y - 180), "v")

	accel_panel = _make_action_panel(Vector2(vp_size.x - 100, vp_size.y - 260), "^")
	brake_panel = _make_action_panel(Vector2(vp_size.x - 100, vp_size.y - 150), "v")
	steer_left_panel = _make_action_panel(Vector2(60, vp_size.y - 200), "<")
	steer_right_panel = _make_action_panel(Vector2(170, vp_size.y - 200), ">")

	set_vehicle_mode(false)


func _make_action_panel(pos: Vector2, label: String) -> Control:
	var ctrl = Control.new()
	ctrl.position = pos
	ctrl.size = Vector2(90, 90)
	ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ctrl)

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
	var panel = Panel.new()
	panel.size = Vector2(90, 90)
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ctrl.add_child(panel)

	var lbl = Label.new()
	lbl.text = label
	lbl.size = Vector2(90, 90)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 30)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ctrl.add_child(lbl)

	return ctrl


func _get_rect(ctrl: Control) -> Rect2:
	return Rect2(ctrl.position, ctrl.size)


func _action_at(pos: Vector2) -> String:
	if is_vehicle_mode:
		if accel_panel.visible and _get_rect(accel_panel).has_point(pos):
			return "accel"
		if brake_panel.visible and _get_rect(brake_panel).has_point(pos):
			return "brake"
		if steer_left_panel.visible and _get_rect(steer_left_panel).has_point(pos):
			return "steer_left"
		if steer_right_panel.visible and _get_rect(steer_right_panel).has_point(pos):
			return "steer_right"
	return ""


func _set_action_state(action: String, held: bool) -> void:
	if action == "accel":
		accel_held = held
	elif action == "brake":
		brake_held = held
	elif action == "steer_left":
		steer_left_held = held
	elif action == "steer_right":
		steer_right_held = held


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if joystick_touch_index == -1 and joystick_bg.visible and event.position.distance_to(joystick_center) < 120:
				joystick_touch_index = event.index
				_update_joystick(event.position)
				return
			var action = _action_at(event.position)
			if action != "":
				touch_actions[event.index] = action
				_set_action_state(action, true)
				return
			if look_touch_index == -1:
				look_touch_index = event.index
		else:
			if event.index == joystick_touch_index:
				joystick_touch_index = -1
				move_vector = Vector2.ZERO
				joystick_knob.position = Vector2(40, 40)
			elif touch_actions.has(event.index):
				var action = touch_actions[event.index]
				_set_action_state(action, false)
				touch_actions.erase(event.index)
			elif event.index == look_touch_index:
				look_touch_index = -1
	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_index:
			_update_joystick(event.position)
		elif event.index == look_touch_index:
			look_delta += event.relative


func _update_joystick(touch_pos: Vector2) -> void:
	var offset = touch_pos - joystick_center
	if offset.length() > joystick_radius:
		offset = offset.normalized() * joystick_radius
	joystick_knob.position = Vector2(40, 40) + offset
	move_vector = offset / joystick_radius


func set_vehicle_mode(vehicle: bool) -> void:
	is_vehicle_mode = vehicle
	jump_panel.visible = not vehicle
	crouch_panel.visible = not vehicle
	joystick_bg.visible = not vehicle
	accel_panel.visible = vehicle
	brake_panel.visible = vehicle
	steer_left_panel.visible = vehicle
	steer_right_panel.visible = vehicle


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


func get_look_delta() -> Vector2:
	var d = look_delta
	look_delta = Vector2.ZERO
	return d


func get_zoom_delta() -> float:
	var z = zoom_delta
	zoom_delta = 0.0
	return z
