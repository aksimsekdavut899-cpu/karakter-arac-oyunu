extends Node3D

# Ana kurulum script'i - haritayi yukluyor.
# Debug: ekranda durum yazisi gosteriyoruz cunku telefonda konsol goremiyoruz.

var debug_label: Label

func log_status(msg: String) -> void:
print(msg)
if debug_label:
debug_label.text += msg + "\n"


func _ready() -> void:
# Debug ekran yazisi (sol ust kosede)
var canvas = CanvasLayer.new()
add_child(canvas)
debug_label = Label.new()
debug_label.position = Vector2(10, 10)
debug_label.add_theme_font_size_override("font_size", 20)
canvas.add_child(debug_label)

log_status("Oyun baslatiliyor...")

# Duz koyu mavi arka plan
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

# Harita
var map_root = Node3D.new()
map_root.name = "Harita"
add_child(map_root)

log_status("MapLoader yukleniyor...")
var MapLoaderScript = load("res://MapLoader.gd")
if MapLoaderScript == null:
log_status("HATA: MapLoader.gd yuklenemedi!")
else:
var map_loader = MapLoaderScript.new()
log_status("build_map cagriliyor...")
map_loader.build_map(map_root)
log_status("build_map bitti.")

# Test kamerasi - haritaya yukaridan bakiyor
var camera = Camera3D.new()
camera.name = "TestKamera"
camera.position = Vector3(0, 120, 120)
camera.rotation_degrees = Vector3(-45, 0, 0)
camera.far = 2000.0
camera.current = true
add_child(camera)

log_status("Kurulum tamamlandi.")
