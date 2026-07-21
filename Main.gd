extends Node3D

func _ready() -> void:
var canvas = CanvasLayer.new()
add_child(canvas)

var bg = ColorRect.new()
bg.color = Color(1, 0, 0)
bg.set_anchors_preset(Control.PRESET_FULL_RECT)
canvas.add_child(bg)

var label = Label.new()
label.text = "TEST CALISIYOR"
label.add_theme_font_size_override("font_size", 60)
label.add_theme_color_override("font_color", Color(1, 1, 1))
label.position = Vector2(50, 50)
canvas.add_child(label)
