extends Node3D

# Oyun baslarken calisan ana kurulum script'i.
# GECICI EN BASIT TEST: sadece duz renk arka plan + kirmizi bir kup.
# Harita ve gokyuzu/ortam ayarlari suphelendigimiz icin gecici olarak kaldirildi.

func _ready() -> void:
	print("Oyun baslatiliyor (basit test modu)...")

	# Duz koyu mavi arka plan (Sky/ProceduralSkyMaterial kullanmiyoruz)
	var world_env = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.1, 0.15, 0.35)
	world_env.environment = env
	add_child(world_env)

	# Gunes isigi
	var sun = DirectionalLight3D.new()
	sun.name = "Gunes"
	sun.rotation_degrees = Vector3(-45, -30, 0)
	sun.light_energy = 1.2
	add_child(sun)

	# Basit test objesi: kirmizi bir kup, kameranin tam onunde
	var test_cube = MeshInstance3D.new()
	test_cube.name = "TestKup"
	var box = BoxMesh.new()
	box.size = Vector3(2, 2, 2)
	test_cube.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0, 0)
	test_cube.material_override = mat
	test_cube.position = Vector3(0, 0, 0)
	add_child(test_cube)

	# Basit kamera, kupe bakiyor
	var camera = Camera3D.new()
	camera.name = "TestKamera"
	camera.position = Vector3(0, 2, 6)
	camera.look_at(Vector3(0, 0, 0), Vector3.UP)
	camera.current = true
	add_child(camera)

	print("Kurulum tamamlandi (basit test modu).")
