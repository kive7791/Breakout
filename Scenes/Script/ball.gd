extends CharacterBody2D

class_name Ball

@export var speed: float = 100.0
@export var max_speed: float = 1000.0
@export var lifes = 3
@export var death_zone: DeathZone
#@export var ui: UI

@export var score_label: RichTextLabel
@export var start_text: RichTextLabel
@export var lifes_label: Label

var forward = Vector2(1,1).normalized()
const PADDLE_WIDTH: float = 100.0
var speed_up_factor = 1.05
var current_score: int = 0
var is_running: bool = false
var start_position: Vector2
var game_over_bool: bool = false

#_(funcname) means it has already been defined
#func _ready() -> void:
	#velocity = Vector2(1,1).normalized()

func _ready() -> void:
	#if ui != null:
		#ui.set_lifes(lifes)
	#else:
		#print("UI Null")
	lifes_label.text = "Lifes: %d" % lifes
	start_position = position
	death_zone.life_lost.connect(on_life_lost)


func on_life_lost():
	lifes -= 1
	
	if lifes == 0:
		game_over()
		#hide_all_except_end(get_tree().get_root()) - deleting everything
		#ui.game_over()
	else:
		reset_ball()
		lifes_label.text = "Lifes: %d" % lifes
		#ui.set_lifes(lifes)

func reset_ball():
	position = start_position
	velocity = Vector2.ZERO
	
#Delta is the value in secs
func _physics_process(delta: float) -> void:
	if(not is_running):
		if(Input.is_action_just_pressed("click_window")):
			if(game_over()):
				get_tree().reload_current_scene()
			game_over_bool = false
			is_running = true
			start_text.visible = false
			visible = true
			print("Click!")
		return
		
	var collision: KinematicCollision2D = move_and_collide(forward * speed * delta)
	if(collision):
		forward = forward.bounce(collision.get_normal())
		speed = clamp(speed + 0.5, 1, max_speed)

		if(collision.get_collider().is_in_group("Bricks")):
			collision.get_collider().queue_free()
			current_score += 10
			score_label.text = "SCORE: " + str(current_score)

		if(collision.get_collider().is_in_group("SlowMoPowerUp")):
			Engine.time_scale = 0.5 
			#Refrence $
			$SlowMo.start(0.5)

		# Paddle bounce should be based on ball position
		if(collision.get_collider().is_in_group("Paddle")):
			print(collision.get_collider().name)
			var paddle_x = collision.get_collider().position.x - PADDLE_WIDTH/2
			var pos_on_paddle = (position.x - paddle_x)/PADDLE_WIDTH
			print("Hit the paddle!" + str(pos_on_paddle))
			var bounce_angle = lerp(-PI * 0.7, -PI * 0.1, pos_on_paddle)
			forward = Vector2.from_angle(bounce_angle)
		
		# Handle game over
		if(collision.get_collider().is_in_group("GameOver")):
			is_running = false
			start_text.visible = true
			visible = true
			start_text.text = "GAME OVER"

func start_ball():
	position = start_position
	randomize()
	
	velocity = Vector2(randf_range(-1,1), randf_range(-.1, -1)).normalized() * speed

func _on_slow_mo_timeout() -> void:
	Engine.time_scale = 0.1 
	pass # Replace with function body.

func game_over():
	# Handle game over state, e.g., display game over text
	game_over_bool = true
	start_text.visible = true
	start_text.text = "GAME OVER"
	is_running = false
	#Error after game stops where someone can click again and have it run

# Simple func to hide all elements except end
func hide_all_except_end(node):
	if node == start_text:
		start_text.visible = true
	elif node is CanvasItem and node != start_text:
		node.visible = false
	
	#RECURSIVE CALL - trying to get all the children nodes to be hiden
	for child in node.get_children():
		hide_all_except_end(child)
