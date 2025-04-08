extends Control

@onready var club_manager: Node2D = $"../Camera2D/ClubManager"
@onready var inventory: CanvasLayer = $CanvasLayer
@onready var course: Node2D = $"../Course"

func _ready() -> void:
	if club_manager.is_available_club("driver"):
		$CanvasLayer/Driver.show()
	else:
		$CanvasLayer/Driver.hide()
	if club_manager.is_available_club("putter"):
		$CanvasLayer/Putter.show()
	else:
		$CanvasLayer/Putter.hide()
	if club_manager.is_available_club("iron"):
		$CanvasLayer/Iron.show()
	else:
		$CanvasLayer/Iron.hide()
	if club_manager.is_available_club("wedge"):
		$CanvasLayer/Wedge.show()
	else:
		$CanvasLayer/Wedge.hide()
	if LevelManager.curr_level >=5:
		$CanvasLayer/BallRed.show()
	else:
		$CanvasLayer/BallRed.hide()
	if LevelManager.curr_level >=16:
		$CanvasLayer/BallGold.show()
	else:
		$CanvasLayer/BallGold.hide()
	if LevelManager.curr_level >=14:
		$CanvasLayer/Hat.show()
	else:
		$CanvasLayer/Hat.hide()	
	if LevelManager.curr_level >=8:
		$CanvasLayer/Glove.show()
	else:
		$CanvasLayer/Glove.hide()		
	

func show_red_ball():
	$CanvasLayer/BallRed.show()
	
func show_gold_ball():
	$CanvasLayer/BallGold.show()
	
func show_glove():
	$CanvasLayer/Glove.show()
	
func show_hat():
	$CanvasLayer/Hat.show()			

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle_inv()


func toggle_inv():
	if inventory.is_visible():
		inventory.hide()
		set_process(false)
		set_process_unhandled_input(false)
	else:
		inventory.show()
		set_process(true)
		set_process_unhandled_input(true)
	
	#code for what level goes here
	#$CanvasLayer/Iron.hide()	
	#$CanvasLayer/Wedge.hide()
#driver
func _on_texture_button_pressed() -> void:
	club_manager.set_club("driver")

func _on_putter_pressed() -> void:
	club_manager.set_club("putter")

func _on_iron_pressed() -> void:
	club_manager.set_club("iron")

func _on_wedge_pressed() -> void:
	club_manager.set_club("wedge")

func _on_background_pressed() -> void:
	inventory.hide()

func _on_ball_white_pressed() -> void:
	pass # Replace with function body.
	
func _on_ball_red_pressed() -> void:
	pass # Replace with function body.

func _on_ball_gold_pressed() -> void:
	pass # Replace with function body.

func _on_glove_pressed():
	toggle_inv()
	Dialogic.start("glovep2")
	
func _on_hat_pressed():
	$"../Camera2D/Sun".hide()
	
