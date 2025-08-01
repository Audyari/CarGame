extends CanvasLayer

@onready var speed_label: Label = $SpeedLabel if has_node("SpeedLabel") else null
var car_node: CharacterBody2D

func _ready() -> void:
	car_node = get_node("../Car") if has_node("../Car") else null
	setup_mobile_layout()
	print("TouchScreenButton UI ready!")

func _process(_delta: float) -> void:
	update_speedometer()

func update_speedometer() -> void:
	if speed_label and car_node and car_node.has_method("get_speed_kmh"):
		var speed = car_node.get_speed_kmh()
		speed_label.text = "Speed: %.0f km/h" % speed

func setup_mobile_layout() -> void:
	var screen_size = get_viewport().get_visible_rect().size

	$ButtonGas2.position = Vector2(screen_size.x - 150, screen_size.y - 150)
	$ButtonBrake2.position = Vector2(screen_size.x - 280, screen_size.y - 150)
	$ButtonLeft2.position = Vector2(50, screen_size.y - 150)
	$ButtonRight2.position = Vector2(180, screen_size.y - 150)
