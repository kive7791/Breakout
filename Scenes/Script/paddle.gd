extends CharacterBody2D

class_name Paddle

@export var speed: float = 100.0
@export var camera: Camera2D

# Making the direct of the paddle start at 0
var direction = Vector2.ZERO
#Bounding box of the camera
var camera_rect: Rect2
var half_width: float  

# COMMENT: drag and drop from Scene in order to get the refrence - FASTER
@onready var collision_shape_2d = $CollisionShape2D

func _ready() -> void:
	camera_rect = camera.get_viewport_rect()
	half_width = collision_shape_2d.shape.get_rect().size.x/2 * scale.x
	#print("Initial position: ", position)

# physics behind the paddle movement
func _physics_process(delta: float) -> void:
	var mouse_x = get_viewport().get_mouse_position().x
	# calculating the camera boundaries
	var camera_start_x = camera.position.x - camera_rect.size.x/2
	var camera_end_x = camera.position.x + camera_rect.size.x/2
	
	# Clamping the mouse bounds
	#clamp() func restricts a value within a specifed range. clamp(value, min, max)
	position.x = clamp(mouse_x, camera_start_x + half_width, camera_end_x - half_width)
