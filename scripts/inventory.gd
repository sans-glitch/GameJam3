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
