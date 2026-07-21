extends Node3D

# Ana kurulum script'i - haritayi (optimize edilmis MultiMesh yontemiyle)
# yukluyor. Gokyuzu/Environment hala devre disi (bir onceki testte
# supheliydi, harita calisinca ayri bir adimda tekrar deneyecegiz).

func _ready() -> void:
	print("Oyun baslatiliyor...")

	# Duz koyu mavi arka plan (Sky/ProceduralSkyMaterial henuz eklenmiyor)
	var world_env = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.4, 0.6, 0.9)
	world_env.environment = env
	add_child(world_env)

	# Gunes isigi
	var sun = DirectionalLight3D.new()
	sun.name = "Gunes"
	sun.rotation_degrees = Vector3(-45, -30, 0)
	sun.light_energy = 1.2
	add_child(sun)

	# Harita (MultiMesh ile optimize edilmis)
	var map_root = Node3D.new()
	map_root.name = "Harita"
	add_child(map_root)

	var MapLoaderScript = load("res://MapLoader.gd")
	var map_loader = MapLoaderScript.new()
	map_loader.build_map(map_root)

	# Test kamerasi - haritaya yukaridan bakiyor
	var camera = Camera3D.new()
	camera.name = "TestKamera"
	camera.position = Vector3(0, 120, 120)
	camera.rotation_degrees = Vector3(-45, 0, 0)
	camera.far = 2000.0
	camera.current = true
	add_child(camera)

	print("Kurulum tamamlandi.")
