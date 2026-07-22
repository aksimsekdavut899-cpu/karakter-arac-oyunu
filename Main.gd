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

	var camera = Camera3D.new()
	camera.name = "TestKamera"
	camera.position = Vector3(0, 120, 120)
	camera.rotation_degrees = Vector3(-45, 0, 0)
	camera.far = 2000.0
	camera.current = true
	add_child(camera)

	print("Kurulum tamamlandi.")
