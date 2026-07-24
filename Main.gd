extends Node3D

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

	var ModUIScript = load("res://ModUI.gd")
	var mod_ui = ModUIScript.new()
	add_child(mod_ui)
	mod_ui.set_player(player)

	var spring_arm = SpringArm3D.new()
	spring_arm.name = "KameraKolu"
	spring_arm.position = Vector3(0, 2.2, 0)
	spring_arm.rotation_degrees = Vector3(-12, 0, 0)
	spring_arm.spring_length = 6.0
	player.add_child(spring_arm)

	var camera = Camera3D.new()
	camera.name = "TakipKamerasi"
	camera.current = true
	spring_arm.add_child(camera)

	var ControlsScript = load("res://ControlsUI.gd")
	var controls_ui = ControlsScript.new()
	add_child(controls_ui)
	player.set_controls(controls_ui)

	print("Kurulum tamamlandi.")
