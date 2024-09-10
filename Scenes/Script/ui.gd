#extends CanvasLayer
#
#class_name UI
#
#@onready var lifes_label = %LifesLabel
#@onready var game_lost_container = $GameLostContainer
#
#func _ready() -> void:
	##Amount of lives at start/game over not shown
	#set_lifes(3) 
	#game_lost_container.hide()
	#
##Set Lifes 
#func set_lifes(lifes: int):
	#lifes_label.text = "Lifes: %d" % lifes
#
##Show game over
#func game_over():
	#game_lost_container.show()
#
##Restart game
#func _on_game_lost_button_pressed() -> void:
	#get_tree().reload_current_scene()
