extends Camera2D

@export var randomStrength: float = 25.0
@export var shake_duration: float = 5.0  # Adjust this to how long you want the shake to last

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var shake_timer: float = 0.0

func shake():
	shake_strength = randomStrength
	shake_timer = shake_duration

func _process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		shake_strength = lerpf(shake_strength, 0, shake_timer * delta)  # Adjust the 3rd value for smoother shake
		offset = randomOffset()
		if shake_timer <= 0:
			offset = Vector2.ZERO  # Reset the offset after shaking

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
