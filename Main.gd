extends Node3D

# Oyun baslarken calisan ana kurulum script'i.
# Her sey (harita, isik, gokyuzu) kod ile kuruluyor, elle sahne
# duzenlemesi gerekmiyor.

func _ready() -> void:
	print("Oyun baslatiliyor...")

	# Harita objesini olustur ve icini doldur
	var map_root = Node3D.new()
	map_root.name = "Harita"
	add_child(map_root)

	var MapLoaderScript = load("res://MapLoader.gd")
	var map_loader = MapLoaderScript.new()
	map_loader.build_map(map_root)

	# Gunes isigi
	var sun = DirectionalLight3D.new()
	sun.name = "Gunes"
	sun.rotation_degrees = Vector3(-45, -30, 0)
	sun.light_energy = 1.2
	add_child(sun)

	# Basit gokyuzu / ortam
	var world_env = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	env.sky = sky
	world_env.environment = env
	add_child(world_env)

	# Basit bir test kamerasi (haritayi yukaridan gorebilmek icin,
	# karakter/arac sistemi bir sonraki adimda eklenecek)
	var camera = Camera3D.new()
	camera.name = "TestKamera"
	camera.position = Vector3(0, 80, 80)
	camera.rotation_degrees = Vector3(-45, 0, 0)
	camera.current = true
	add_child(camera)

	print("Kurulum tamamlandi.")
