extends Node3D

var player_ref: Node3D
var camera_rig: Node3D
var spring_arm_ref: SpringArm3D
var controls_ref: Node

var cam_yaw := 0.0
var cam_pitch := -12.0
var look_sensitivity := 0.25
var target_spring_length := 6.0


func _ready() -> void:
	print("Oyun baslatiliyor...")

	var world_env = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.4, 0.6, 0.9)
	world_env.environment = env
	add_child(world_env)

	var sun = DirectionalLight3D.new()
	sun.name = "Gunes"
	sun.rotation_degrees = Vector3(-45, -30, 0)
	sun.light_energy = 1.2
	add_child(sun)

	var map_root = Node3D.new()
	map_root.name = "Harita"
	add_child(map_root)

	var MapLoaderScript = load("res://MapLoader.gd")
	var map_loader = MapLoaderScript.new()
	map_loader.build_map(map_root)

	var PlayerScript = load("res://PlayerController.gd")
	var player = PlayerScript.new()
	player.name = "Oyuncu"
	player.position = Vector3(0, 0, 0)
	add_child(player)
	player_ref = player

	var ModUIScript = load("res://ModUI.gd")
	var mod_ui = ModUIScript.new()
	add_child(mod_ui)
	mod_ui.set_player(player)

	camera_rig = Node3D.new()
	camera_rig.name = "KameraRig"
	add_child(camera_rig)

	var spring_arm = SpringArm3D.new()
	spring_arm.name = "KameraKolu"
	spring_arm.position = Vector3(0, 2.2, 0)
	spring_arm.rotation_degrees = Vector3(cam_pitch, 0, 0)
	spring_arm.spring_length = 6.0
	camera_rig.add_child(spring_arm)
	spring_arm_ref = spring_arm

	var camera = Camera3D.new()
	camera.name = "TakipKamerasi"
	camera.current = true
	spring_arm.add_child(camera)

	var ControlsScript = load("res://ControlsUI.gd")
	var controls_ui = ControlsScript.new()
	add_child(controls_ui)
	player.set_controls(controls_ui)
	controls_ref = controls_ui

	print("Kurulum tamamlandi.")


func _process(delta: float) -> void:
	if not player_ref or not camera_rig:
		return
	camera_rig.global_position = player_ref.global_position

if player_ref.is_vehicle:
target_rad = player_ref.rotation.y
current_rad = deg_to_rad(cam_yaw)
new_rad = lerp_angle(current_rad, target_rad, clamp(6.0 * delta, 0.0, 1.0))
aw = rad_to_deg(new_rad)
= lerp(cam_pitch, -10.0, 4.0 * delta)
controls_ref and controls_ref.is_accel():
g_length = lerp(target_spring_length, 7.0, 8.0 * delta)
controls_ref:
zd = controls_ref.get_zoom_delta()
g_length = clamp(target_spring_length + zd, 5.0, 20.0)
g_arm_ref.spring_length = lerp(spring_arm_ref.spring_length, target_spring_length, 5.0 * delta)
else:
g_arm_ref.spring_length = lerp(spring_arm_ref.spring_length, 6.0, 3.0 * delta)

if controls_ref and not player_ref.is_vehicle:
		var look = controls_ref.get_look_delta()
		if look.length() > 0.0:
			cam_yaw -= look.x * look_sensitivity
			cam_pitch -= look.y * look_sensitivity
			cam_pitch = clamp(cam_pitch, -60.0, 20.0)

	camera_rig.rotation_degrees = Vector3(0, cam_yaw, 0)
	spring_arm_ref.rotation_degrees = Vector3(cam_pitch, 0, 0)
