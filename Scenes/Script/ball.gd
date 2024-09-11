extends CharacterBody2D

class_name Ball

@export var speed: float = 100.0
@export var max_speed: float = 500.0
@export var lifes = 3
@export var death_zone: DeathZone

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
var active_balls: int = 1

func _ready() -> void:
	lifes_label.text = "Lifes: %d" % lifes
	start_position = position
	death_zone.life_lost.connect(on_life_lost)

func on_life_lost():
	lifes -= 1
	if active_balls > 1:
		active_balls -= 1
		#remove current ball
		queue_free()
	else:
		if lifes <= 0:
			game_over()
		else:
			pause_reset_ball()
			lifes_label.text = "Lifes: %d" % lifes

func pause_reset_ball():
	is_running = false
	position = start_position
	velocity = Vector2.ZERO
	
	start_text.visible = true
	visible = true
	start_text.text = "Click to Resume"
	
#Delta is the value in secs
func _physics_process(delta: float) -> void:
	if(not is_running):
		if(Input.is_action_just_pressed("click_window")):
			if(game_over_bool):
				get_tree().reload_current_scene()
			game_over_bool = false
			is_running = true
			start_text.visible = false
			visible = true
			#print("Click!")
		return
		
	var collision: KinematicCollision2D = move_and_collide(forward * speed * delta)
	if(collision):
		forward = forward.bounce(collision.get_normal())
		speed = clamp(speed + 0.5, 1, max_speed)

		if(collision.get_collider().is_in_group("Bricks")):
			collision.get_collider().queue_free()
			current_score += 10
			score_label.text = "SCORE: " + str(current_score)
			var camera = get_node("/root/Main/Camera2D")
			if camera:
				camera.shake()

		if(collision.get_collider().is_in_group("SlowMoPowerUp")):
			Engine.time_scale = 0.5 
			#Refrence $
			$SlowMo.start(0.5)
			#Mess around with SlowMo in order to also effect the paddle

		#check if the ball collided with the DoublePowerUp
		if(collision.get_collider().is_in_group("DoublePowerUp")):
			duplicate_ball(collision.get_collider().position)

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

func _on_slow_mo_timeout() -> void:
	Engine.time_scale = 0.1 
	pass # Replace with function body.

#Basically what the name of the func is: it duplicates the ball
func duplicate_ball(spawn_position: Vector2):
		#Create a new instance of the ball
		var new_ball = self.duplicate()
		
		var offset_y = 50
		new_ball.position = Vector2(spawn_position.x, spawn_position.y + offset_y)
		new_ball.speed = speed
		new_ball.forward = Vector2(1,1).normalized() * speed
		new_ball.is_running = true
		 
		get_parent().add_child(new_ball)

		active_balls += 1

func game_over():
	if active_balls <= 1:
		# Handle game over state, e.g., display game over text
		game_over_bool = true
		start_text.visible = true
		start_text.text = "GAME OVER, Click to Restart"
		is_running = false
		active_balls = 1 #reset for new game
